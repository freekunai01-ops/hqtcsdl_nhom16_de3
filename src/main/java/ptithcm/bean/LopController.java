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
@RequestMapping("/lop")
public class LopController {

    @Autowired
    private ConnectionHelper connHelper;

    @RequestMapping(method = RequestMethod.GET)
    public String showLop(@RequestParam(value = "malop", required = false) String malop,
                          HttpSession session, ModelMap model) {
        String nhomQuyen = (String) session.getAttribute("nhomQuyen");
        if (!"PGV".equals(nhomQuyen) && !"KHOA".equals(nhomQuyen)) {
            return "redirect:/home";
        }
        loadData(session, model);
        model.addAttribute("selectedMalop", malop != null ? malop.trim() : "");
        return "lop";
    }

    @RequestMapping(value = "/save", method = RequestMethod.POST)
    public String saveLop(@RequestParam String action,
                          @RequestParam String maLop,
                          @RequestParam String tenLop,
                          @RequestParam String khoaHoc,
                          @RequestParam String maKhoa,
                          HttpSession session,
                          RedirectAttributes ra) {
        if (!"PGV".equals(session.getAttribute("nhomQuyen"))) {
            return "redirect:/home";
        }

        // Validate required fields
        if (maLop == null || maLop.trim().isEmpty()) {
            ra.addFlashAttribute("error", "Lỗi: Mã lớp không được bỏ trống!");
            return "redirect:/lop";
        }
        
        // Helper to set inputs back to view in case of redirect
        ra.addFlashAttribute("failedAction", action);
        ra.addFlashAttribute("failedMaLop", maLop);
        ra.addFlashAttribute("failedTenLop", tenLop);
        ra.addFlashAttribute("failedKhoaHoc", khoaHoc);
        ra.addFlashAttribute("failedMaKhoa", maKhoa);

        if (tenLop == null || tenLop.trim().isEmpty()) {
            ra.addFlashAttribute("error", "Lỗi: Tên lớp không được bỏ trống!");
            return "redirect:/lop?malop=" + maLop.trim();
        }
        if (khoaHoc == null || khoaHoc.trim().isEmpty()) {
            ra.addFlashAttribute("error", "Lỗi: Khóa học không được bỏ trống!");
            return "redirect:/lop?malop=" + maLop.trim();
        }

        // Validate KHOAHOC format: yyyy-yyyy
        String kh = khoaHoc.trim();
        if (!kh.matches("\\d{4}-\\d{4}")) {
            ra.addFlashAttribute("error", "Lỗi: Khóa học phải có dạng yyyy-yyyy (ví dụ: 2024-2028)!");
            return "redirect:/lop?malop=" + maLop.trim();
        }
        int startYear = Integer.parseInt(kh.substring(0, 4));
        int endYear = Integer.parseInt(kh.substring(5, 9));
        if (endYear <= startYear) {
            ra.addFlashAttribute("error", "Lỗi: Năm kết thúc phải lớn hơn năm bắt đầu!");
            return "redirect:/lop?malop=" + maLop.trim();
        }
        
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);

        if ("add".equals(action)) {
            // Check for past enrollment year — only warn, allow current year
            int currentYear = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
            if (startYear < currentYear) {
                ra.addFlashAttribute("error", "Lỗi: Không được thêm lớp cho khóa học trong quá khứ (" + khoaHoc + " < " + currentYear + ")!");
                return "redirect:/lop?malop=" + maLop.trim();
            }
            // Check duplicate MALOP
            int count = jdbc.queryForObject("SELECT COUNT(*) FROM LOP WHERE MALOP=?", Integer.class, maLop.trim());
            if (count > 0) {
                ra.addFlashAttribute("error", "Lỗi: Mã lớp " + maLop.trim() + " đã tồn tại!");
                return "redirect:/lop?malop=" + maLop.trim();
            }
        } else {
            // Update: check if trying to change MAKHOA or KHOAHOC when students exist
            int svCount = jdbc.queryForObject(
                "SELECT COUNT(*) FROM SINHVIEN WHERE MALOP=?", Integer.class, maLop.trim());
            if (svCount > 0) {
                // Get current MAKHOA and KHOAHOC
                Map<String, Object> currentClass = jdbc.queryForMap(
                    "SELECT MAKHOA, KHOAHOC FROM LOP WHERE MALOP=?", maLop.trim());
                String currentMaKhoa = currentClass.get("MAKHOA") != null ? currentClass.get("MAKHOA").toString().trim() : "";
                String currentKhoaHoc = currentClass.get("KHOAHOC") != null ? currentClass.get("KHOAHOC").toString().trim() : "";
                
                if (!maKhoa.trim().equals(currentMaKhoa)) {
                    ra.addFlashAttribute("error", "Lỗi: Không được đổi khoa cho lớp " + maLop.trim() + " vì đã có sinh viên!");
                    return "redirect:/lop?malop=" + maLop.trim();
                }
                if (!kh.equals(currentKhoaHoc)) {
                    ra.addFlashAttribute("error", "Lỗi: Không được đổi khóa học cho lớp " + maLop.trim() + " vì đã có sinh viên!");
                    return "redirect:/lop?malop=" + maLop.trim();
                }
            }
        }

        try {
            if ("add".equals(action)) {
                jdbc.update("EXEC sp_ThemLop ?, ?, ?, ?",
                        maLop.trim(), tenLop.trim(), kh, maKhoa.trim());
                ra.addFlashAttribute("success", "Thêm lớp " + maLop.trim() + " thành công!");
            } else {
                jdbc.update("EXEC sp_SuaLop ?, ?, ?, ?",
                        maLop.trim(), tenLop.trim(), kh, maKhoa.trim());
                ra.addFlashAttribute("success", "Cập nhật lớp " + maLop.trim() + " thành công!");
            }
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Lỗi: " + e.getMessage());
            return "redirect:/lop?malop=" + maLop.trim();
        }
        return "redirect:/lop?malop=" + maLop.trim();
    }

    @RequestMapping(value = "/delete", method = RequestMethod.POST)
    public String deleteLop(@RequestParam String maLop,
                            @RequestParam(required = false) String nextMaLop,
                            HttpSession session, RedirectAttributes ra) {
        if (!"PGV".equals(session.getAttribute("nhomQuyen"))) {
            return "redirect:/home";
        }
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        
        // Check student count
        int svCount = jdbc.queryForObject(
            "SELECT COUNT(*) FROM SINHVIEN WHERE MALOP=?", Integer.class, maLop.trim());
        if (svCount > 0) {
            ra.addFlashAttribute("error", "Không thể xóa lớp " + maLop.trim() + " vì đã có " + svCount + " sinh viên! Xóa chỉ cho lớp tạo nhầm, chưa có SV.");
            return "redirect:/lop?malop=" + maLop.trim();
        }
        
        // Check if graduated
        try {
            String khoaHoc = jdbc.queryForObject("SELECT KHOAHOC FROM LOP WHERE MALOP=?", String.class, maLop.trim());
            if (khoaHoc != null && khoaHoc.length() >= 9) {
                int endYear = Integer.parseInt(khoaHoc.substring(5, 9));
                int currentYear = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
                if (endYear <= currentYear) {
                    ra.addFlashAttribute("error", "Không thể xóa lớp " + maLop.trim() + " vì đã tốt nghiệp (khóa " + khoaHoc + "). Dữ liệu lịch sử phải được giữ lại.");
                    return "redirect:/lop?malop=" + maLop.trim();
                }
            }
        } catch (Exception e) { /* ignore parse errors */ }

        try {
            jdbc.update("EXEC sp_XoaLop ?", maLop.trim());
            ra.addFlashAttribute("success", "Xóa lớp " + maLop.trim() + " thành công!");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Không thể xóa: " + e.getMessage());
            return "redirect:/lop?malop=" + maLop.trim();
        }
        return "redirect:/lop" + (nextMaLop != null && !nextMaLop.trim().isEmpty() ? "?malop=" + nextMaLop.trim() : "");
    }

    private void loadData(HttpSession session, ModelMap model) {
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        String nhomQuyen = (String) session.getAttribute("nhomQuyen");
        String maKhoa = (String) session.getAttribute("maKhoa");

        String baseQuery = "SELECT L.*, K.TENKHOA FROM LOP L JOIN KHOA K ON L.MAKHOA=K.MAKHOA ";
        List<Map<String, Object>> dslop;
        if ("ALL".equals(maKhoa) || maKhoa == null || maKhoa.trim().isEmpty()) {
            dslop = jdbc.queryForList(baseQuery + "ORDER BY L.MALOP");
        } else {
            dslop = jdbc.queryForList(baseQuery + "WHERE L.MAKHOA=? ORDER BY L.MALOP", maKhoa);
        }

        int currentYear = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
        int totalLop = dslop.size(), dangHoc = 0, daTotNghiep = 0;
        for (Map<String, Object> lop : dslop) {
            try {
                int siso = jdbc.queryForObject("SELECT COUNT(*) FROM SINHVIEN WHERE MALOP=?", Integer.class, lop.get("MALOP"));
                lop.put("SISO", siso);
            } catch (Exception e) { lop.put("SISO", 0); }
            String kh = lop.get("KHOAHOC") != null ? lop.get("KHOAHOC").toString() : "";
            int tn = 0;
            if (kh.length() >= 9) {
                try { int endY = Integer.parseInt(kh.substring(5, 9)); if (endY <= currentYear) tn = 1; } catch (Exception e) {}
            }
            lop.put("TOTNGHIEP", tn);
            if (tn == 1) daTotNghiep++; else dangHoc++;
        }
        model.addAttribute("dslop", dslop);
        model.addAttribute("totalLop", totalLop);
        model.addAttribute("dangHoc", dangHoc);
        model.addAttribute("daTotNghiep", daTotNghiep);

        List<Map<String, Object>> khoaList = jdbc.queryForList(
                "SELECT RTRIM(MAKHOA) AS MAKHOA, TENKHOA FROM KHOA ORDER BY MAKHOA");
        model.addAttribute("khoaList", khoaList);
    }
}
