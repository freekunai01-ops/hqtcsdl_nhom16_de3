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
    public String show(HttpSession session, ModelMap model) {
        String nhomQuyen = (String) session.getAttribute("nhomQuyen");
        if (!"PGV".equals(nhomQuyen) && !"KHOA".equals(nhomQuyen)) {
            return "redirect:/home";
        }
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        String maKhoa = (String) session.getAttribute("maKhoa");
        String baseQ = "SELECT G.*, K.TENKHOA FROM GIANGVIEN G JOIN KHOA K ON G.MAKHOA=K.MAKHOA ";
        List<Map<String, Object>> dsgv;
        if ("ALL".equals(maKhoa) || maKhoa == null || maKhoa.trim().isEmpty()) {
            dsgv = jdbc.queryForList(baseQ + "ORDER BY G.TEN, G.HO");
        } else {
            dsgv = jdbc.queryForList(baseQ + "WHERE G.MAKHOA=? ORDER BY G.TEN, G.HO", maKhoa);
        }

        int dangDay = 0, gsPgsTs = 0, chuaPC = 0;
        for (Map<String, Object> gv : dsgv) {
            try {
                int soLTC = jdbc.queryForObject("SELECT COUNT(*) FROM LOPTINCHI WHERE MAGV=?", Integer.class, gv.get("MAGV"));
                gv.put("SO_LTC", soLTC);
                if (soLTC > 0) dangDay++; else chuaPC++;
            } catch (Exception e) { gv.put("SO_LTC", 0); chuaPC++; }
            String hv = gv.get("HOCVI") != null ? gv.get("HOCVI").toString().trim() : "";
            String hh = gv.get("HOCHAM") != null ? gv.get("HOCHAM").toString().trim() : "";
            if (hh.contains("GS") || hh.contains("PGS") || hv.contains("Tiến sĩ") || hv.contains("TS")) gsPgsTs++;
        }
        model.addAttribute("dsgv", dsgv);
        model.addAttribute("totalGV", dsgv.size());
        model.addAttribute("dangDay", dangDay);
        model.addAttribute("gsPgsTs", gsPgsTs);
        model.addAttribute("chuaPC", chuaPC);
        model.addAttribute("khoaList", jdbc.queryForList("SELECT RTRIM(MAKHOA) AS MAKHOA, TENKHOA FROM KHOA ORDER BY MAKHOA"));
        return "giangvien";
    }

    @RequestMapping(value = "/save", method = RequestMethod.POST)
    public String save(@RequestParam String action, @RequestParam String magv,
                       @RequestParam String ho, @RequestParam String ten,
                       @RequestParam String hocvi, @RequestParam String hocham,
                       @RequestParam String chuyenmon, @RequestParam String maKhoa,
                       HttpSession session, RedirectAttributes ra) {
        if (!"PGV".equals(session.getAttribute("nhomQuyen"))) return "redirect:/home";
        if (magv == null || magv.trim().isEmpty()) { ra.addFlashAttribute("error", "Mã GV không được bỏ trống!"); return "redirect:/giangvien"; }
        if (ho == null || ho.trim().isEmpty()) { ra.addFlashAttribute("error", "Họ không được bỏ trống!"); return "redirect:/giangvien"; }
        if (ten == null || ten.trim().isEmpty()) { ra.addFlashAttribute("error", "Tên không được bỏ trống!"); return "redirect:/giangvien"; }

        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        try {
            if ("add".equals(action)) {
                int exists = jdbc.queryForObject("SELECT COUNT(*) FROM GIANGVIEN WHERE MAGV=?", Integer.class, magv.trim());
                if (exists > 0) { ra.addFlashAttribute("error", "Mã GV '" + magv.trim() + "' đã tồn tại!"); return "redirect:/giangvien"; }
                jdbc.update("INSERT INTO GIANGVIEN (MAGV,HO,TEN,HOCVI,HOCHAM,CHUYENMON,MAKHOA) VALUES (?,?,?,?,?,?,?)",
                        magv.trim(), ho.trim(), ten.trim(), hocvi.trim(), hocham.trim(), chuyenmon.trim(), maKhoa.trim());
                ra.addFlashAttribute("success", "Thêm giảng viên thành công!");
            } else {
                jdbc.update("UPDATE GIANGVIEN SET HO=?,TEN=?,HOCVI=?,HOCHAM=?,CHUYENMON=?,MAKHOA=? WHERE MAGV=?",
                        ho.trim(), ten.trim(), hocvi.trim(), hocham.trim(), chuyenmon.trim(), maKhoa.trim(), magv.trim());
                ra.addFlashAttribute("success", "Cập nhật giảng viên thành công!");
            }
        } catch (Exception e) { ra.addFlashAttribute("error", "Lỗi: " + e.getMessage()); }
        return "redirect:/giangvien";
    }

    @RequestMapping(value = "/delete", method = RequestMethod.POST)
    public String delete(@RequestParam String magv, HttpSession session, RedirectAttributes ra) {
        if (!"PGV".equals(session.getAttribute("nhomQuyen"))) return "redirect:/home";
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        try {
            int ltcCount = jdbc.queryForObject("SELECT COUNT(*) FROM LOPTINCHI WHERE MAGV=?", Integer.class, magv.trim());
            if (ltcCount > 0) {
                ra.addFlashAttribute("error", "Không thể xóa! GV '" + magv.trim() + "' đã phụ trách " + ltcCount + " lớp tín chỉ.");
                return "redirect:/giangvien";
            }
        } catch (Exception e) {}
        try {
            jdbc.update("DELETE FROM GIANGVIEN WHERE MAGV=?", magv.trim());
            ra.addFlashAttribute("success", "Xóa giảng viên thành công!");
        } catch (Exception e) { ra.addFlashAttribute("error", "Không thể xóa: " + e.getMessage()); }
        return "redirect:/giangvien";
    }
}
