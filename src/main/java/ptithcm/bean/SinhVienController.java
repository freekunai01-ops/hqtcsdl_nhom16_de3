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
@RequestMapping("/sinhvien")
public class SinhVienController {

    @Autowired
    private ConnectionHelper connHelper;

    @RequestMapping(method = RequestMethod.GET)
    public String show(@RequestParam(value = "malop", required = false) String malop,
                       HttpSession session, ModelMap model) {
        String nhomQuyen = (String) session.getAttribute("nhomQuyen");
        if (!"PGV".equals(nhomQuyen) && !"KHOA".equals(nhomQuyen)) {
            return "redirect:/home";
        }
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        List<Map<String, Object>> dslop;
        
        // Danh sách lớp (lọc theo maKhoa trong session cho cả PGV và KHOA)
        String maKhoa = (String) session.getAttribute("maKhoa");
        if ("ALL".equals(maKhoa) || maKhoa == null || maKhoa.trim().isEmpty()) {
             dslop = jdbc.queryForList("SELECT MALOP, TENLOP, MAKHOA FROM LOP ORDER BY MALOP");
        } else {
             dslop = jdbc.queryForList("SELECT MALOP, TENLOP, MAKHOA FROM LOP WHERE MAKHOA=? ORDER BY MALOP", maKhoa);
        }

        // Thêm SISO cho mỗi lớp (an toàn, try-catch từng lớp)
        for (Map<String, Object> lop : dslop) {
            try {
                int siso = jdbc.queryForObject("SELECT COUNT(*) FROM SINHVIEN WHERE MALOP=?",
                    Integer.class, lop.get("MALOP"));
                lop.put("SISO", siso);
            } catch (Exception e) { lop.put("SISO", 0); }
        }

        // Fetch danh sách khoa cho bộ lọc
        List<Map<String, Object>> dskhoa = jdbc.queryForList("SELECT MAKHOA, TENKHOA FROM KHOA ORDER BY MAKHOA");
        model.addAttribute("dskhoa", dskhoa);
        model.addAttribute("dslop", dslop);

        // Tổng SV toàn hệ thống
        try {
            int totalSv = jdbc.queryForObject("SELECT COUNT(*) FROM SINHVIEN", Integer.class);
            model.addAttribute("totalSv", totalSv);
        } catch (Exception e) { model.addAttribute("totalSv", 0); }

        // Auto-select lớp đầu tiên nếu chưa chọn
        if ((malop == null || malop.isEmpty()) && !dslop.isEmpty()) {
            malop = dslop.get(0).get("MALOP").toString().trim();
        }

        // Load danh sách SV
        if (malop != null && !malop.isEmpty()) {
            List<Map<String, Object>> dssv = jdbc.queryForList(
                    "SELECT * FROM SINHVIEN WHERE MALOP=? ORDER BY TEN, HO", malop.trim());
            
            // Thêm LUOT_DK cho mỗi SV (an toàn)
            for (Map<String, Object> sv : dssv) {
                try {
                    int dk = jdbc.queryForObject("SELECT COUNT(*) FROM DANGKY WHERE MASV=?",
                        Integer.class, sv.get("MASV"));
                    sv.put("LUOT_DK", dk);
                } catch (Exception e) { sv.put("LUOT_DK", 0); }
            }

            model.addAttribute("dssv", dssv);
            model.addAttribute("selectedLop", malop.trim());

            // Stats
            int svInLop = dssv.size(), nam = 0, nu = 0, nghiHoc = 0;
            for (Map<String, Object> sv : dssv) {
                Object phai = sv.get("PHAI");
                if (phai != null && (phai.equals(true) || phai.equals(1))) nu++; else nam++;
                Object dnh = sv.get("DANGHIHOC");
                if (dnh != null && (dnh.equals(true) || dnh.equals(1))) nghiHoc++;
            }
            model.addAttribute("svInLop", svInLop);
            model.addAttribute("svNam", nam);
            model.addAttribute("svNu", nu);
            model.addAttribute("svNghiHoc", nghiHoc);

            // Thông tin lớp
            try {
                Map<String, Object> lopInfo = jdbc.queryForMap(
                    "SELECT L.KHOAHOC, K.MAKHOA FROM LOP L JOIN KHOA K ON L.MAKHOA=K.MAKHOA WHERE L.MALOP=?",
                    malop.trim());
                model.addAttribute("lopKhoaHoc", lopInfo.get("KHOAHOC"));
                model.addAttribute("lopMaKhoa", lopInfo.get("MAKHOA"));
            } catch (Exception e) {}
        }
        return "sinhvien";
    }

    @RequestMapping(value = "/save", method = RequestMethod.POST)
    public String save(@RequestParam String action,
                       @RequestParam String masv,
                       @RequestParam String ho,
                       @RequestParam String ten,
                       @RequestParam String malop,
                       @RequestParam(required = false, defaultValue = "false") boolean phai,
                       @RequestParam(required = false) String ngaysinh,
                       @RequestParam(required = false) String diachi,
                       @RequestParam(required = false, defaultValue = "false") boolean danghihoc,
                       HttpSession session, RedirectAttributes ra) {
        if (!"PGV".equals(session.getAttribute("nhomQuyen"))) {
            return "redirect:/home";
        }
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        String password = masv.trim();
        try {
            if ("add".equals(action)) {
                jdbc.update("INSERT INTO SINHVIEN (MASV,HO,TEN,MALOP,PHAI,NGAYSINH,DIACHI,DANGHIHOC,PASSWORD) " +
                            "VALUES (?,?,?,?,?,?,?,?,?)",
                        masv.trim(), ho.trim(), ten.trim(), malop.trim(),
                        phai ? 1 : 0,
                        (ngaysinh != null && !ngaysinh.isEmpty()) ? ngaysinh : null,
                        (diachi != null && !diachi.isEmpty()) ? diachi.trim() : null,
                        danghihoc ? 1 : 0, password);
                ra.addFlashAttribute("success", "Thêm sinh viên thành công!");
            } else {
                jdbc.update("UPDATE SINHVIEN SET HO=?,TEN=?,MALOP=?,PHAI=?,NGAYSINH=?," +
                            "DIACHI=?,DANGHIHOC=?,PASSWORD=? WHERE MASV=?",
                        ho.trim(), ten.trim(), malop.trim(),
                        phai ? 1 : 0,
                        (ngaysinh != null && !ngaysinh.isEmpty()) ? ngaysinh : null,
                        (diachi != null && !diachi.isEmpty()) ? diachi.trim() : null,
                        danghihoc ? 1 : 0, password, masv.trim());
                ra.addFlashAttribute("success", "Cập nhật sinh viên thành công!");
            }
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Lỗi: " + e.getMessage());
        }
        return "redirect:/sinhvien?malop=" + malop.trim();
    }

    @RequestMapping(value = "/delete", method = RequestMethod.POST)
    public String delete(@RequestParam String masv,
                         @RequestParam String malop,
                         HttpSession session, RedirectAttributes ra) {
        if (!"PGV".equals(session.getAttribute("nhomQuyen"))) {
            return "redirect:/home";
        }
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        // Kiểm tra có đăng ký không
        try {
            int dkCount = jdbc.queryForObject("SELECT COUNT(*) FROM DANGKY WHERE MASV=?", Integer.class, masv.trim());
            if (dkCount > 0) {
                ra.addFlashAttribute("error", "Không thể xóa SV " + masv.trim() + " vì đã có " + dkCount + " lượt đăng ký! Dùng 'Đang nghỉ học' thay vì xóa.");
                return "redirect:/sinhvien?malop=" + malop.trim();
            }
        } catch (Exception e) {}
        try {
            jdbc.update("DELETE FROM SINHVIEN WHERE MASV=?", masv.trim());
            ra.addFlashAttribute("success", "Xóa sinh viên thành công!");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Không thể xóa: " + e.getMessage());
        }
        return "redirect:/sinhvien?malop=" + malop.trim();
    }
}
