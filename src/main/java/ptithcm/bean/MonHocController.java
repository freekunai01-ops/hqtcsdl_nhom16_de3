package ptithcm.bean;

import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequestMapping("/monhoc")
public class MonHocController {

    @Autowired
    private ConnectionHelper connHelper;

    @RequestMapping(method = RequestMethod.GET)
    public String show(@RequestParam(value = "mamh", required = false) String mamh,
                       HttpSession session, ModelMap model) {
        String nhomQuyen = (String) session.getAttribute("nhomQuyen");
        if (!"PGV".equals(nhomQuyen) && !"KHOA".equals(nhomQuyen)) {
            return "redirect:/home";
        }
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        List<Map<String, Object>> dsmh = jdbc.queryForList("SELECT * FROM MONHOC ORDER BY TENMH");

        int totalLT = 0, totalTH = 0, daMoLTC = 0;
        for (Map<String, Object> mh : dsmh) {
            int lt = mh.get("SOTIET_LT") != null ? ((Number) mh.get("SOTIET_LT")).intValue() : 0;
            int th = mh.get("SOTIET_TH") != null ? ((Number) mh.get("SOTIET_TH")).intValue() : 0;
            mh.put("TONGTIET", lt + th);
            int tc = (int) Math.round((double) lt / 15 + (double) th / 30);
            if (tc < 1 && (lt + th) > 0) tc = 1;
            mh.put("TINCHI", tc);
            totalLT += lt; totalTH += th;
            try {
                // Kiểm tra toàn bộ lịch sử LTC — bao gồm cả đã đóng
                int soLTC = jdbc.queryForObject("SELECT COUNT(*) FROM LOPTINCHI WHERE MAMH=?", Integer.class, mh.get("MAMH"));
                mh.put("SO_LTC", soLTC);
                if (soLTC > 0) daMoLTC++;
                // Kiểm tra lịch sử đăng ký/điểm để biết môn đã có dữ liệu sinh viên chưa
                int soDK = jdbc.queryForObject(
                    "SELECT COUNT(*) FROM DANGKY dk " +
                    "JOIN LOPTINCHI ltc ON dk.MALTC = ltc.MALTC " +
                    "WHERE ltc.MAMH=?", Integer.class, mh.get("MAMH"));
                mh.put("SO_DK", soDK);
            } catch (Exception e) { mh.put("SO_LTC", 0); mh.put("SO_DK", 0); }
        }
        model.addAttribute("dsmh", dsmh);
        model.addAttribute("totalMH", dsmh.size());
        model.addAttribute("daMoLTC", daMoLTC);
        model.addAttribute("totalLT", totalLT);
        model.addAttribute("totalTH", totalTH);
        model.addAttribute("selectedMamh", mamh != null ? mamh.trim() : "");
        return "monhoc";
    }

    @RequestMapping(value = "/save", method = RequestMethod.POST)
    public String save(@RequestParam("action") String action, @RequestParam("mamh") String mamh,
                       @RequestParam("tenmh") String tenmh, @RequestParam("sotietLT") int sotietLT,
                       @RequestParam("sotietTH") int sotietTH, HttpSession session, RedirectAttributes ra) {
        if (!"PGV".equals(session.getAttribute("nhomQuyen"))) return "redirect:/home";
        if (mamh == null || mamh.trim().isEmpty()) {
            ra.addFlashAttribute("error", "Mã MH không được bỏ trống!");
            return "redirect:/monhoc";
        }

        ra.addFlashAttribute("failedAction", action);
        ra.addFlashAttribute("failedMamh", mamh);
        ra.addFlashAttribute("failedTenmh", tenmh);
        ra.addFlashAttribute("failedSotietLT", sotietLT);
        ra.addFlashAttribute("failedSotietTH", sotietTH);

        if (tenmh == null || tenmh.trim().isEmpty()) {
            ra.addFlashAttribute("error", "Tên MH không được bỏ trống!");
            return "redirect:/monhoc?mamh=" + mamh.trim();
        }
        if (sotietLT < 0 || sotietTH < 0) {
            ra.addFlashAttribute("error", "Số tiết không được âm!");
            return "redirect:/monhoc?mamh=" + mamh.trim();
        }
        if (sotietLT + sotietTH <= 0) {
            ra.addFlashAttribute("error", "Tổng số tiết phải > 0!");
            return "redirect:/monhoc?mamh=" + mamh.trim();
        }

        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        try {
            if ("add".equals(action)) {
                int exists = jdbc.queryForObject("SELECT COUNT(*) FROM MONHOC WHERE MAMH=?", Integer.class, mamh.trim());
                if (exists > 0) {
                    ra.addFlashAttribute("error", "Mã MH '" + mamh.trim() + "' đã tồn tại!");
                    return "redirect:/monhoc?mamh=" + mamh.trim();
                }
                jdbc.update("EXEC sp_ThemMonHoc ?, ?, ?, ?",
                        mamh.trim(), tenmh.trim(), sotietLT, sotietTH);
                ra.addFlashAttribute("success", "Thêm môn học thành công!");
            } else {
                // ====== NGHIỆP VỤ ĐÚNG: Kiểm tra toàn bộ lịch sử LTC ======
                int ltcCount = jdbc.queryForObject(
                    "SELECT COUNT(*) FROM LOPTINCHI WHERE MAMH=?", Integer.class, mamh.trim());
                boolean daPhatSinhLTC = ltcCount > 0;

                if (daPhatSinhLTC) {
                    // Lấy số tiết gốc để so sánh
                    Map<String, Object> current = jdbc.queryForMap(
                        "SELECT SOTIET_LT, SOTIET_TH FROM MONHOC WHERE MAMH=?", mamh.trim());
                    int curLT = current.get("SOTIET_LT") != null ? ((Number) current.get("SOTIET_LT")).intValue() : 0;
                    int curTH = current.get("SOTIET_TH") != null ? ((Number) current.get("SOTIET_TH")).intValue() : 0;

                    // CHẶN: Không cho sửa số tiết nếu môn đã có điểm (DANGKY tồn tại)
                    int diemCount = jdbc.queryForObject(
                        "SELECT COUNT(*) FROM DANGKY dk " +
                        "JOIN LOPTINCHI ltc ON dk.MALTC = ltc.MALTC " +
                        "WHERE ltc.MAMH = ?", Integer.class, mamh.trim());

                    if (diemCount > 0 && (sotietLT != curLT || sotietTH != curTH)) {
                        ra.addFlashAttribute("error",
                            "Không thể sửa số tiết! Môn '" + mamh.trim() +
                            "' đã có " + diemCount + " lượt đăng ký/điểm lịch sử. " +
                            "Thay đổi số tiết sẽ ảnh hưởng tính chỉ/GPA của sinh viên.");
                        return "redirect:/monhoc?mamh=" + mamh.trim();
                    }

                    // Cho phép sửa nếu chỉ sửa tên hoặc số tiết chưa có điểm nhưng đã có LTC
                    if (sotietLT != curLT || sotietTH != curTH) {
                        // Đã có LTC nhưng chưa có điểm — cảnh báo nhưng cho sửa
                        jdbc.update("EXEC sp_SuaMonHoc ?, ?, ?, ?",
                                mamh.trim(), tenmh.trim(), sotietLT, sotietTH);
                        ra.addFlashAttribute("success",
                            "Cập nhật thành công! ⚠ Môn đã mở " + ltcCount + " LTC — " +
                            "thay đổi số tiết ảnh hưởng tín chỉ quy đổi trong báo cáo.");
                    } else {
                        // Chỉ sửa tên môn — an toàn tuyệt đối
                        jdbc.update("EXEC sp_SuaMonHoc ?, ?, ?, ?",
                                mamh.trim(), tenmh.trim(), sotietLT, sotietTH);
                        ra.addFlashAttribute("success", "Cập nhật tên môn học thành công!");
                    }
                } else {
                    // Môn chưa từng mở LTC — cho sửa tự do
                    jdbc.update("EXEC sp_SuaMonHoc ?, ?, ?, ?",
                            mamh.trim(), tenmh.trim(), sotietLT, sotietTH);
                    ra.addFlashAttribute("success", "Cập nhật môn học thành công!");
                }
            }
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Lỗi: " + e.getMessage());
            return "redirect:/monhoc?mamh=" + mamh.trim();
        }
        return "redirect:/monhoc?mamh=" + mamh.trim();
    }

    @RequestMapping(value = "/delete", method = RequestMethod.POST)
    public String delete(@RequestParam("mamh") String mamh,
                         @RequestParam(value = "nextMamh", required = false) String nextMamh,
                         HttpSession session, RedirectAttributes ra) {
        if (!"PGV".equals(session.getAttribute("nhomQuyen"))) return "redirect:/home";
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);

        // ====== NGHIỆP VỤ ĐÚNG: Kiểm tra toàn bộ lịch sử LTC (không phân biệt đang mở hay đã đóng) ======
        try {
            int ltcCount = jdbc.queryForObject(
                "SELECT COUNT(*) FROM LOPTINCHI WHERE MAMH=?", Integer.class, mamh.trim());
            if (ltcCount > 0) {
                // Kiểm tra thêm có điểm không để thông báo chi tiết hơn
                int diemCount = jdbc.queryForObject(
                    "SELECT COUNT(*) FROM DANGKY dk " +
                    "JOIN LOPTINCHI ltc ON dk.MALTC = ltc.MALTC " +
                    "WHERE ltc.MAMH = ?", Integer.class, mamh.trim());

                if (diemCount > 0) {
                    ra.addFlashAttribute("error",
                        "Không thể xóa! Môn '" + mamh.trim() + "' đã từng mở " + ltcCount +
                        " lớp tín chỉ và có " + diemCount + " lượt đăng ký/điểm của sinh viên. " +
                        "Cần giữ lại để bảo toàn phiếu điểm và báo cáo lịch sử.");
                } else {
                    ra.addFlashAttribute("error",
                        "Không thể xóa! Môn '" + mamh.trim() + "' đã từng mở " + ltcCount +
                        " lớp tín chỉ. Cần giữ lại để bảo toàn dữ liệu lịch sử.");
                }
                return "redirect:/monhoc?mamh=" + mamh.trim();
            }
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Lỗi kiểm tra: " + e.getMessage());
            return "redirect:/monhoc?mamh=" + mamh.trim();
        }

        try {
            jdbc.update("EXEC sp_XoaMonHoc ?", mamh.trim());
            ra.addFlashAttribute("success", "Xóa môn học '" + mamh.trim() + "' thành công!");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Không thể xóa: " + e.getMessage());
            return "redirect:/monhoc?mamh=" + mamh.trim();
        }
        return "redirect:/monhoc" + (nextMamh != null && !nextMamh.trim().isEmpty() ? "?mamh=" + nextMamh.trim() : "");
    }
}
