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
                       @RequestParam(value = "masv", required = false) String masv,
                       HttpSession session, ModelMap model) {
        String nhomQuyen = (String) session.getAttribute("nhomQuyen");
        if (!"PGV".equals(nhomQuyen) && !"KHOA".equals(nhomQuyen)) {
            return "redirect:/home";
        }
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);

        // sp_DsLop trả về MALOP, TENLOP, KHOAHOC, MAKHOA, TENKHOA, SISO
        String maKhoa = (String) session.getAttribute("maKhoa");
        List<Map<String, Object>> dslop;
        if ("ALL".equals(maKhoa) || maKhoa == null || maKhoa.trim().isEmpty()) {
            dslop = jdbc.queryForList("EXEC sp_DsLop NULL");
        } else {
            dslop = jdbc.queryForList("EXEC sp_DsLop ?", maKhoa);
        }

        // Fetch danh sách khoa cho bộ lọc
        List<Map<String, Object>> dskhoa = jdbc.queryForList("EXEC sp_DsKhoaDropdown");
        model.addAttribute("dskhoa", dskhoa);
        model.addAttribute("dslop", dslop);

        // Tổng SV toàn hệ thống
        try {
            List<Map<String, Object>> tongRows = jdbc.queryForList("EXEC sp_TongSinhVien");
            int totalSv = tongRows.isEmpty() ? 0 : ((Number) tongRows.get(0).get("TONG_SV")).intValue();
            model.addAttribute("totalSv", totalSv);
        } catch (Exception e) { model.addAttribute("totalSv", 0); }

        // Auto-select lớp đầu tiên nếu chưa chọn
        if ((malop == null || malop.isEmpty()) && !dslop.isEmpty()) {
            malop = dslop.get(0).get("MALOP").toString().trim();
        }

        // Load danh sách SV — sp_DsSinhVienTheoLop trả về MASV, HO, TEN, ... KHOAHOC, LUOT_DK
        if (malop != null && !malop.isEmpty()) {
            List<Map<String, Object>> dssv = jdbc.queryForList("EXEC sp_DsSinhVienTheoLop ?", malop.trim());

            int currentYear = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
            for (Map<String, Object> sv : dssv) {
                String kh = sv.get("KHOAHOC") != null ? sv.get("KHOAHOC").toString().trim() : "";
                int tn = 0;
                if (kh.length() >= 9) {
                    try {
                        int endY = Integer.parseInt(kh.substring(5, 9));
                        if (endY <= currentYear) tn = 1;
                    } catch (Exception e) {}
                }
                sv.put("TOTNGHIEP", tn);
            }

            model.addAttribute("dssv", dssv);
            model.addAttribute("selectedLop", malop.trim());
            model.addAttribute("selectedMasv", masv != null ? masv.trim() : "");

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

            // Thông tin lớp — lấy từ dslop đã có
            for (Map<String, Object> lop : dslop) {
                if (malop.trim().equals(lop.get("MALOP") != null ? lop.get("MALOP").toString().trim() : "")) {
                    model.addAttribute("lopKhoaHoc", lop.get("KHOAHOC"));
                    model.addAttribute("lopMaKhoa", lop.get("MAKHOA"));
                    break;
                }
            }
        }
        return "sinhvien";
    }

    @RequestMapping(value = "/save", method = RequestMethod.POST)
    public String save(@RequestParam("action") String action,
                       @RequestParam("masv") String masv,
                       @RequestParam("ho") String ho,
                       @RequestParam("ten") String ten,
                       @RequestParam("malop") String malop,
                       @RequestParam(value = "phai", required = false, defaultValue = "false") boolean phai,
                       @RequestParam(value = "ngaysinh", required = false) String ngaysinh,
                       @RequestParam(value = "diachi", required = false) String diachi,
                       @RequestParam(value = "danghihoc", required = false, defaultValue = "false") boolean danghihoc,
                       HttpSession session, RedirectAttributes ra) {
        if (!"PGV".equals(session.getAttribute("nhomQuyen"))) {
            return "redirect:/home";
        }
        if (masv == null || masv.trim().isEmpty()) {
            ra.addFlashAttribute("error", "Mã SV không được bỏ trống!");
            return "redirect:/sinhvien?malop=" + malop.trim();
        }

        ra.addFlashAttribute("failedAction", action);
        ra.addFlashAttribute("failedMasv", masv);
        ra.addFlashAttribute("failedHo", ho);
        ra.addFlashAttribute("failedTen", ten);
        ra.addFlashAttribute("failedMalop", malop);
        ra.addFlashAttribute("failedPhai", phai);
        ra.addFlashAttribute("failedNgaysinh", ngaysinh);
        ra.addFlashAttribute("failedDiachi", diachi);
        ra.addFlashAttribute("failedDanghihoc", danghihoc);

        if (ho == null || ho.trim().isEmpty()) {
            ra.addFlashAttribute("error", "Họ không được bỏ trống!");
            return "redirect:/sinhvien?malop=" + malop.trim() + "&masv=" + masv.trim();
        }
        if (ten == null || ten.trim().isEmpty()) {
            ra.addFlashAttribute("error", "Tên không được bỏ trống!");
            return "redirect:/sinhvien?malop=" + malop.trim() + "&masv=" + masv.trim();
        }
        if (malop == null || malop.trim().isEmpty()) {
            ra.addFlashAttribute("error", "Lớp không được bỏ trống!");
            return "redirect:/sinhvien?malop=" + malop.trim() + "&masv=" + masv.trim();
        }

        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        String password = masv.trim();
        try {
            if ("add".equals(action)) {
                jdbc.update("EXEC sp_ThemSinhVien ?, ?, ?, ?, ?, ?, ?, ?, ?",
                        masv.trim(), ho.trim(), ten.trim(), phai ? 1 : 0,
                        (diachi != null && !diachi.isEmpty()) ? diachi.trim() : null,
                        (ngaysinh != null && !ngaysinh.isEmpty()) ? ngaysinh : null,
                        malop.trim(), danghihoc ? 1 : 0, password);
                ra.addFlashAttribute("success", "Thêm sinh viên thành công!");
            } else {
                jdbc.update("EXEC sp_SuaSinhVien ?, ?, ?, ?, ?, ?, ?, ?",
                        masv.trim(), ho.trim(), ten.trim(), phai ? 1 : 0,
                        (diachi != null && !diachi.isEmpty()) ? diachi.trim() : null,
                        (ngaysinh != null && !ngaysinh.isEmpty()) ? ngaysinh : null,
                        malop.trim(), danghihoc ? 1 : 0);
                ra.addFlashAttribute("success", "Cập nhật sinh viên thành công!");
            }
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Lỗi: " + e.getMessage());
            return "redirect:/sinhvien?malop=" + malop.trim() + "&masv=" + masv.trim();
        }
        return "redirect:/sinhvien?malop=" + malop.trim() + "&masv=" + masv.trim();
    }

    @RequestMapping(value = "/delete", method = RequestMethod.POST)
    public String delete(@RequestParam("masv") String masv,
                         @RequestParam("malop") String malop,
                         @RequestParam(value = "nextMasv", required = false) String nextMasv,
                         HttpSession session, RedirectAttributes ra) {
        if (!"PGV".equals(session.getAttribute("nhomQuyen"))) {
            return "redirect:/home";
        }
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        // Kiểm tra có đăng ký không qua sp_DemDangKyTheoSV
        try {
            List<Map<String, Object>> dkRows = jdbc.queryForList("EXEC sp_DemDangKyTheoSV ?", masv.trim());
            int dkCount = dkRows.isEmpty() ? 0 : ((Number) dkRows.get(0).get("LUOT_DK")).intValue();
            if (dkCount > 0) {
                ra.addFlashAttribute("error", "Không thể xóa SV " + masv.trim() + " vì đã có " + dkCount + " lượt đăng ký! Dùng 'Đang nghỉ học' thay vì xóa.");
                return "redirect:/sinhvien?malop=" + malop.trim() + "&masv=" + masv.trim();
            }
        } catch (Exception e) {}
        try {
            jdbc.update("EXEC sp_XoaSinhVien ?", masv.trim());
            ra.addFlashAttribute("success", "Xóa sinh viên thành công!");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Không thể xóa: " + e.getMessage());
            return "redirect:/sinhvien?malop=" + malop.trim() + "&masv=" + masv.trim();
        }
        return "redirect:/sinhvien?malop=" + malop.trim() + (nextMasv != null && !nextMasv.trim().isEmpty() ? "&masv=" + nextMasv.trim() : "");
    }
}
