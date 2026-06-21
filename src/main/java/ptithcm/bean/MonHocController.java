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
    public String show(HttpSession session, ModelMap model) {
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
                int soLTC = jdbc.queryForObject("SELECT COUNT(*) FROM LOPTINCHI WHERE MAMH=?", Integer.class, mh.get("MAMH"));
                mh.put("SO_LTC", soLTC);
                if (soLTC > 0) daMoLTC++;
            } catch (Exception e) { mh.put("SO_LTC", 0); }
        }
        model.addAttribute("dsmh", dsmh);
        model.addAttribute("totalMH", dsmh.size());
        model.addAttribute("daMoLTC", daMoLTC);
        model.addAttribute("totalLT", totalLT);
        model.addAttribute("totalTH", totalTH);
        return "monhoc";
    }

    @RequestMapping(value = "/save", method = RequestMethod.POST)
    public String save(@RequestParam String action, @RequestParam String mamh,
                       @RequestParam String tenmh, @RequestParam int sotietLT,
                       @RequestParam int sotietTH, HttpSession session, RedirectAttributes ra) {
        if (!"PGV".equals(session.getAttribute("nhomQuyen"))) return "redirect:/home";
        if (mamh == null || mamh.trim().isEmpty()) { ra.addFlashAttribute("error", "Mã MH không được bỏ trống!"); return "redirect:/monhoc"; }
        if (tenmh == null || tenmh.trim().isEmpty()) { ra.addFlashAttribute("error", "Tên MH không được bỏ trống!"); return "redirect:/monhoc"; }
        if (sotietLT < 0 || sotietTH < 0) { ra.addFlashAttribute("error", "Số tiết không được âm!"); return "redirect:/monhoc"; }
        if (sotietLT + sotietTH <= 0) { ra.addFlashAttribute("error", "Tổng số tiết phải > 0!"); return "redirect:/monhoc"; }

        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        try {
            if ("add".equals(action)) {
                int exists = jdbc.queryForObject("SELECT COUNT(*) FROM MONHOC WHERE MAMH=?", Integer.class, mamh.trim());
                if (exists > 0) { ra.addFlashAttribute("error", "Mã MH '" + mamh.trim() + "' đã tồn tại!"); return "redirect:/monhoc"; }
                jdbc.update("INSERT INTO MONHOC (MAMH, TENMH, SOTIET_LT, SOTIET_TH) VALUES (?,?,?,?)",
                        mamh.trim(), tenmh.trim(), sotietLT, sotietTH);
                ra.addFlashAttribute("success", "Thêm môn học thành công!");
            } else {
                // Check if has LTC - warn about changing sotiet
                int ltcCount = jdbc.queryForObject("SELECT COUNT(*) FROM LOPTINCHI WHERE MAMH=?", Integer.class, mamh.trim());
                if (ltcCount > 0) {
                    ra.addFlashAttribute("success", "Cập nhật thành công! (⚠ Môn đã mở " + ltcCount + " LTC, thay đổi số tiết có thể ảnh hưởng tín chỉ/GPA)");
                } else {
                    ra.addFlashAttribute("success", "Cập nhật môn học thành công!");
                }
                jdbc.update("UPDATE MONHOC SET TENMH=?, SOTIET_LT=?, SOTIET_TH=? WHERE MAMH=?",
                        tenmh.trim(), sotietLT, sotietTH, mamh.trim());
            }
        } catch (Exception e) { ra.addFlashAttribute("error", "Lỗi: " + e.getMessage()); }
        return "redirect:/monhoc";
    }

    @RequestMapping(value = "/delete", method = RequestMethod.POST)
    public String delete(@RequestParam String mamh, HttpSession session, RedirectAttributes ra) {
        if (!"PGV".equals(session.getAttribute("nhomQuyen"))) return "redirect:/home";
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        try {
            int ltcCount = jdbc.queryForObject("SELECT COUNT(*) FROM LOPTINCHI WHERE MAMH=?", Integer.class, mamh.trim());
            if (ltcCount > 0) {
                ra.addFlashAttribute("error", "Không thể xóa! Môn '" + mamh.trim() + "' đã mở " + ltcCount + " lớp tín chỉ.");
                return "redirect:/monhoc";
            }
        } catch (Exception e) {}
        try {
            jdbc.update("DELETE FROM MONHOC WHERE MAMH=?", mamh.trim());
            ra.addFlashAttribute("success", "Xóa môn học thành công!");
        } catch (Exception e) { ra.addFlashAttribute("error", "Không thể xóa: " + e.getMessage()); }
        return "redirect:/monhoc";
    }
}
