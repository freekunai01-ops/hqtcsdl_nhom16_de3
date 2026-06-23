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
@RequestMapping("/giangvien")
public class GiangVienController {

    @Autowired
    private ConnectionHelper connHelper;

    @RequestMapping(method = RequestMethod.GET)
    public String show(@RequestParam(value = "magv", required = false) String magv,
                       HttpSession session, ModelMap model) {
        String nhomQuyen = (String) session.getAttribute("nhomQuyen");
        if (!"PGV".equals(nhomQuyen) && !"KHOA".equals(nhomQuyen)) {
            return "redirect:/home";
        }
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        String maKhoa = (String) session.getAttribute("maKhoa");
        // sp_DsGiangVien trả về MAGV, HO, TEN, HOCVI, HOCHAM, CHUYENMON, MAKHOA, TENKHOA, SO_LTC
        List<Map<String, Object>> dsgv;
        if ("ALL".equals(maKhoa) || maKhoa == null || maKhoa.trim().isEmpty()) {
            dsgv = jdbc.queryForList("EXEC sp_DsGiangVien NULL");
        } else {
            dsgv = jdbc.queryForList("EXEC sp_DsGiangVien ?", maKhoa);
        }

        int dangDay = 0, gsPgsTs = 0, chuaPC = 0;
        for (Map<String, Object> gv : dsgv) {
            int soLTC = gv.get("SO_LTC") != null ? ((Number) gv.get("SO_LTC")).intValue() : 0;
            if (soLTC > 0) dangDay++; else chuaPC++;
            String hv = gv.get("HOCVI") != null ? gv.get("HOCVI").toString().trim() : "";
            String hh = gv.get("HOCHAM") != null ? gv.get("HOCHAM").toString().trim() : "";
            if (hh.contains("GS") || hh.contains("PGS") || hv.contains("Tiến sĩ") || hv.contains("TS")) gsPgsTs++;
        }
        model.addAttribute("dsgv", dsgv);
        model.addAttribute("totalGV", dsgv.size());
        model.addAttribute("dangDay", dangDay);
        model.addAttribute("gsPgsTs", gsPgsTs);
        model.addAttribute("chuaPC", chuaPC);
        model.addAttribute("khoaList", jdbc.queryForList("EXEC sp_DsKhoaDropdown"));
        model.addAttribute("selectedMagv", magv != null ? magv.trim() : "");
        return "giangvien";
    }

    @RequestMapping(value = "/save", method = RequestMethod.POST)
    public String save(@RequestParam("action") String action, @RequestParam("magv") String magv,
                       @RequestParam("ho") String ho, @RequestParam("ten") String ten,
                       @RequestParam("hocvi") String hocvi, @RequestParam("hocham") String hocham,
                       @RequestParam("chuyenmon") String chuyenmon, @RequestParam("maKhoa") String maKhoa,
                       HttpSession session, RedirectAttributes ra) {
        if (!"PGV".equals(session.getAttribute("nhomQuyen"))) return "redirect:/home";
        if (magv == null || magv.trim().isEmpty()) { ra.addFlashAttribute("error", "Mã GV không được bỏ trống!"); return "redirect:/giangvien"; }
        
        ra.addFlashAttribute("failedAction", action);
        ra.addFlashAttribute("failedMagv", magv);
        ra.addFlashAttribute("failedHo", ho);
        ra.addFlashAttribute("failedTen", ten);
        ra.addFlashAttribute("failedHocvi", hocvi);
        ra.addFlashAttribute("failedHocham", hocham);
        ra.addFlashAttribute("failedChuyenmon", chuyenmon);
        ra.addFlashAttribute("failedMaKhoa", maKhoa);

        if (ho == null || ho.trim().isEmpty()) { ra.addFlashAttribute("error", "Họ không được bỏ trống!"); return "redirect:/giangvien?magv=" + magv.trim(); }
        if (ten == null || ten.trim().isEmpty()) { ra.addFlashAttribute("error", "Tên không được bỏ trống!"); return "redirect:/giangvien?magv=" + magv.trim(); }

        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        try {
            if ("add".equals(action)) {
                // sp_ThemGiangVien kiểm tra trùng MAGV, raise error nếu trùng
                jdbc.update("EXEC sp_ThemGiangVien ?,?,?,?,?,?,?",
                        magv.trim(), ho.trim(), ten.trim(), hocvi.trim(), hocham.trim(), chuyenmon.trim(), maKhoa.trim());
                ra.addFlashAttribute("success", "Thêm giảng viên thành công!");
            } else {
                jdbc.update("EXEC sp_SuaGiangVien ?,?,?,?,?,?,?",
                        magv.trim(), ho.trim(), ten.trim(), hocvi.trim(), hocham.trim(), chuyenmon.trim(), maKhoa.trim());
                ra.addFlashAttribute("success", "Cập nhật giảng viên thành công!");
            }
        } catch (Exception e) { 
            ra.addFlashAttribute("error", "Lỗi: " + e.getMessage()); 
            return "redirect:/giangvien?magv=" + magv.trim();
        }
        return "redirect:/giangvien?magv=" + magv.trim();
    }

    @RequestMapping(value = "/delete", method = RequestMethod.POST)
    public String delete(@RequestParam("magv") String magv,
                         @RequestParam(value = "nextMagv", required = false) String nextMagv,
                         HttpSession session, RedirectAttributes ra) {
        if (!"PGV".equals(session.getAttribute("nhomQuyen"))) return "redirect:/home";
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        // sp_XoaGiangVien tự kiểm tra LTC, raise error nếu còn LTC
        // (Kiểm tra trước ở Java để hiển thị thông báo thân thiện)
        try {
            List<Map<String, Object>> gvRows = jdbc.queryForList("EXEC sp_DsGiangVien ?", magv.trim());
            if (!gvRows.isEmpty()) {
                int ltcCount = gvRows.get(0).get("SO_LTC") != null ? ((Number) gvRows.get(0).get("SO_LTC")).intValue() : 0;
                if (ltcCount > 0) {
                    ra.addFlashAttribute("error", "Không thể xóa! GV '" + magv.trim() + "' đã phụ trách " + ltcCount + " lớp tín chỉ.");
                    return "redirect:/giangvien?magv=" + magv.trim();
                }
            }
        } catch (Exception e) {}
        try {
            jdbc.update("EXEC sp_XoaGiangVien ?", magv.trim());
            ra.addFlashAttribute("success", "Xóa giảng viên thành công!");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Không thể xóa: " + e.getMessage());
            return "redirect:/giangvien?magv=" + magv.trim();
        }
        return "redirect:/giangvien" + (nextMagv != null && !nextMagv.trim().isEmpty() ? "?magv=" + nextMagv.trim() : "");
    }
}
