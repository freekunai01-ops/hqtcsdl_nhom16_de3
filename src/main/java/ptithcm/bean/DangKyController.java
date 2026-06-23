package ptithcm.bean;

import java.util.Collections;
import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import org.springframework.web.servlet.support.RequestContextUtils;

/**
 * Đăng ký lớp tín chỉ - SV và PGV
 * PGV: chọn lớp HC → tìm SV theo MASV/họ tên → chọn SV → đăng ký/hủy LTC
 * SV: MASV khóa theo tài khoản → chỉ đăng ký/hủy cho chính mình
 */
@Controller
@RequestMapping("/dangky")
public class DangKyController {

    @Autowired
    private ConnectionHelper connHelper;

    @RequestMapping(method = RequestMethod.GET)
    public String show(HttpSession session, ModelMap model, HttpServletRequest request) {
        String nhomQuyen = (String) session.getAttribute("nhomQuyen");
        if (!"SV".equals(nhomQuyen) && !"PGV".equals(nhomQuyen) && !"KHOA".equals(nhomQuyen)) {
            return "redirect:/home";
        }

        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);

        // PGV/KHOA: load DS lớp HC để chọn
        if ("PGV".equals(nhomQuyen) || "KHOA".equals(nhomQuyen)) {
            String maKhoa = (String) session.getAttribute("maKhoa");
            List<Map<String, Object>> dsLopHC;
            if ("PGV".equals(nhomQuyen) && ("ALL".equals(maKhoa) || maKhoa == null)) {
                dsLopHC = jdbc.queryForList(
                    "SELECT L.MALOP, L.TENLOP, L.MAKHOA, " +
                    "(SELECT COUNT(*) FROM SINHVIEN SV WHERE SV.MALOP=L.MALOP) AS SISO " +
                    "FROM LOP L ORDER BY L.MALOP");
            } else {
                dsLopHC = jdbc.queryForList(
                    "SELECT L.MALOP, L.TENLOP, L.MAKHOA, " +
                    "(SELECT COUNT(*) FROM SINHVIEN SV WHERE SV.MALOP=L.MALOP) AS SISO " +
                    "FROM LOP L WHERE L.MAKHOA=? ORDER BY L.MALOP", maKhoa);
            }
            model.addAttribute("dsLopHC", dsLopHC);

            // Load DS SV trong lớp đang chọn
            String selectedLopHC = (String) session.getAttribute("selectedLopHC");
            if (selectedLopHC != null && !selectedLopHC.isEmpty()) {
                List<Map<String, Object>> dsSvLop = jdbc.queryForList(
                    "SELECT SV.MASV, SV.HO, SV.TEN, SV.MALOP, SV.DANGHIHOC, L.KHOAHOC " +
                    "FROM SINHVIEN SV JOIN LOP L ON SV.MALOP=L.MALOP " +
                    "WHERE SV.MALOP=? ORDER BY SV.TEN, SV.HO", selectedLopHC);
                
                int currentYear = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
                for (Map<String, Object> sv : dsSvLop) {
                    String kh = sv.get("KHOAHOC") != null ? sv.get("KHOAHOC").toString().trim() : "";
                    int totNghiep = 0;
                    if (kh.length() >= 9) {
                        try {
                            int endY = Integer.parseInt(kh.substring(5, 9));
                            if (endY <= currentYear) totNghiep = 1;
                        } catch (Exception e) {}
                    }
                    sv.put("TOTNGHIEP", totNghiep);
                }
                model.addAttribute("dsSvLop", dsSvLop);
                model.addAttribute("selectedLopHC", selectedLopHC);
            }
        }

        // Xác định MASV
        String masv;
        if ("SV".equals(nhomQuyen)) {
            masv = (String) session.getAttribute("masv");
        } else {
            masv = (String) session.getAttribute("selectedMasv");
        }

        if (masv == null || masv.isEmpty()) {
            return "dangky";
        }

        // Thông tin SV đang chọn
        List<Map<String, Object>> svInfoList = jdbc.queryForList(
            "SELECT SV.MASV, SV.HO, SV.TEN, SV.MALOP, SV.DANGHIHOC, L.TENLOP, L.MAKHOA, L.KHOAHOC " +
            "FROM SINHVIEN SV JOIN LOP L ON SV.MALOP=L.MALOP WHERE SV.MASV=?", masv);
        if (!svInfoList.isEmpty()) {
            Map<String, Object> svInfo = svInfoList.get(0);
            String kh = svInfo.get("KHOAHOC") != null ? svInfo.get("KHOAHOC").toString().trim() : "";
            int totNghiep = 0;
            if (kh.length() >= 9) {
                try {
                    int endY = Integer.parseInt(kh.substring(5, 9));
                    int currentYear = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
                    if (endY <= currentYear) totNghiep = 1;
                } catch (Exception e) {}
            }
            svInfo.put("TOTNGHIEP", totNghiep);
            model.addAttribute("svInfo", svInfo);
        } else {
            return "dangky";
        }

        // Check for flashed search parameters
        Map<String, ?> flashMap = RequestContextUtils.getInputFlashMap(request);
        String nk = null;
        Integer hk = null;
        if (flashMap != null) {
            nk = (String) flashMap.get("flashNienkhoa");
            hk = (Integer) flashMap.get("flashHocky");
        }
        if (nk == null) { nk = "2025-2026"; hk = 1; }

        model.addAttribute("nienkhoa", nk);
        model.addAttribute("hocky", hk);

        // DS lớp tín chỉ chưa hủy
        List<Map<String, Object>> dsltc = jdbc.queryForList(
            "SELECT LTC.MALTC, MH.MAMH, MH.TENMH, LTC.NHOM, LTC.SOSVTOITHIEU, LTC.SOSVTOIDA, " +
            "MH.SOTIET_LT, MH.SOTIET_TH, " +
            "LTC.NGAYBATDAU_DK, LTC.NGAYKETTHUC_DK, LTC.NGAYHETHAN_HUY, " +
            "GV.HO + ' ' + GV.TEN AS HOTENGV, " +
            "(SELECT COUNT(*) FROM DANGKY DK WHERE DK.MALTC=LTC.MALTC AND (DK.HUYDANGKY=0 OR DK.HUYDANGKY IS NULL)) AS SOSVDK " +
            "FROM LOPTINCHI LTC " +
            "JOIN MONHOC MH ON LTC.MAMH=MH.MAMH " +
            "JOIN GIANGVIEN GV ON LTC.MAGV=GV.MAGV " +
            "WHERE LTC.NIENKHOA=? AND LTC.HOCKY=? AND LTC.HUYLOP=0 " +
            "ORDER BY MH.TENMH, LTC.NHOM", nk, hk);

        // Tính tín chỉ cho mỗi LTC
        for (Map<String, Object> ltc : dsltc) {
            int lt = ltc.get("SOTIET_LT") != null ? ((Number) ltc.get("SOTIET_LT")).intValue() : 0;
            int th = ltc.get("SOTIET_TH") != null ? ((Number) ltc.get("SOTIET_TH")).intValue() : 0;
            int tc = (lt > 0 ? lt / 15 : 0) + (th > 0 ? th / 30 : 0);
            if (tc == 0) tc = 1;
            ltc.put("TINCHI", tc);
        }
        model.addAttribute("dsltc", dsltc);

        // DS đã đăng ký
        List<Map<String, Object>> daDangKy = jdbc.queryForList(
            "SELECT DK.MALTC FROM DANGKY DK WHERE DK.MASV=? AND (DK.HUYDANGKY=0 OR DK.HUYDANGKY IS NULL)", masv);
        model.addAttribute("daDangKy", daDangKy);

        // DS LTC đã đăng ký — tất cả niên khóa
        List<Map<String, Object>> myLTC = jdbc.queryForList(
            "SELECT LTC.MALTC, LTC.NIENKHOA, LTC.HOCKY, MH.TENMH, LTC.NHOM, " +
            "MH.SOTIET_LT, MH.SOTIET_TH, " +
            "LTC.NGAYHETHAN_HUY, " +
            "CASE WHEN DK.DIEM_CK IS NOT NULL THEN " +
            "  ROUND(dbo.fn_DiemHetMon(DK.DIEM_CC, DK.DIEM_GK, DK.DIEM_CK), 2) " +
            "  ELSE NULL END AS DIEM_HM " +
            "FROM DANGKY DK " +
            "JOIN LOPTINCHI LTC ON DK.MALTC=LTC.MALTC " +
            "JOIN MONHOC MH ON LTC.MAMH=MH.MAMH " +
            "WHERE DK.MASV=? AND (DK.HUYDANGKY=0 OR DK.HUYDANGKY IS NULL) " +
            "ORDER BY LTC.NIENKHOA DESC, LTC.HOCKY DESC, MH.TENMH", masv);

        for (Map<String, Object> m : myLTC) {
            int lt = m.get("SOTIET_LT") != null ? ((Number) m.get("SOTIET_LT")).intValue() : 0;
            int th = m.get("SOTIET_TH") != null ? ((Number) m.get("SOTIET_TH")).intValue() : 0;
            int tc = (lt > 0 ? lt / 15 : 0) + (th > 0 ? th / 30 : 0);
            if (tc == 0) tc = 1;
            m.put("TINCHI", tc);
        }
        model.addAttribute("myLTC", myLTC);

        // Đếm số môn đã ĐK trong HK hiện tại
        int daDangKyHK = jdbc.queryForObject(
            "SELECT COUNT(*) FROM DANGKY DK " +
            "JOIN LOPTINCHI LTC ON DK.MALTC=LTC.MALTC " +
            "WHERE DK.MASV=? AND LTC.NIENKHOA=? AND LTC.HOCKY=? " +
            "AND (DK.HUYDANGKY=0 OR DK.HUYDANGKY IS NULL)",
            Integer.class, masv, nk, hk);
        model.addAttribute("daDangKyHK", daDangKyHK);

        return "dangky";
    }

    /** PGV chọn lớp HC */
    @RequestMapping(value = "/selectLop", method = RequestMethod.POST)
    public String selectLop(@RequestParam String malop, HttpSession session) {
        if (!"PGV".equals(session.getAttribute("nhomQuyen")) && !"KHOA".equals(session.getAttribute("nhomQuyen"))) {
            return "redirect:/home";
        }
        session.setAttribute("selectedLopHC", malop.trim());
        session.removeAttribute("selectedMasv"); // reset SV khi đổi lớp
        return "redirect:/dangky";
    }

    /** PGV chọn SV từ danh sách */
    @RequestMapping(value = "/selectStudent", method = RequestMethod.POST)
    public String selectStudent(@RequestParam String masv, HttpSession session, RedirectAttributes ra) {
        if (!"PGV".equals(session.getAttribute("nhomQuyen")) && !"KHOA".equals(session.getAttribute("nhomQuyen"))) {
            return "redirect:/home";
        }
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        try {
            Long count = jdbc.queryForObject("SELECT COUNT(*) FROM SINHVIEN WHERE MASV=?", Long.class, masv.trim());
            if (count == 0) {
                ra.addFlashAttribute("error", "Không tìm thấy sinh viên với mã: " + masv);
                session.removeAttribute("selectedMasv");
            } else {
                session.setAttribute("selectedMasv", masv.trim());
                ra.addFlashAttribute("success", "Đã chọn sinh viên: " + masv);
            }
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Lỗi: " + e.getMessage());
        }
        return "redirect:/dangky";
    }

    @RequestMapping(value = "/search", method = RequestMethod.POST)
    public String search(@RequestParam String nienkhoa, @RequestParam int hocky, RedirectAttributes ra) {
        ra.addFlashAttribute("flashNienkhoa", nienkhoa.trim());
        ra.addFlashAttribute("flashHocky", hocky);
        return "redirect:/dangky";
    }

    @RequestMapping(value = "/saveMultiple", method = RequestMethod.POST)
    public String saveMultiple(@RequestParam(required = false) List<Integer> selectedLtcs,
                               @RequestParam String nienkhoa, @RequestParam int hocky,
                               HttpSession session, RedirectAttributes ra) {
        String nhomQuyen = (String) session.getAttribute("nhomQuyen");
        if (!"SV".equals(nhomQuyen) && !"PGV".equals(nhomQuyen)) return "redirect:/home";

        String masv = "SV".equals(nhomQuyen) ? (String) session.getAttribute("masv") : (String) session.getAttribute("selectedMasv");
        if (masv == null || masv.isEmpty()) {
            ra.addFlashAttribute("error", "Không xác định được sinh viên đăng ký!");
            return "redirect:/dangky";
        }

        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        final int MAX_MON_PER_HK = 8;

        try {
            int alreadyRegistered = jdbc.queryForObject(
                "SELECT COUNT(*) FROM DANGKY DK JOIN LOPTINCHI LTC ON DK.MALTC=LTC.MALTC " +
                "WHERE DK.MASV=? AND LTC.NIENKHOA=? AND LTC.HOCKY=? " +
                "AND (DK.HUYDANGKY=0 OR DK.HUYDANGKY IS NULL)",
                Integer.class, masv, nienkhoa.trim(), hocky);

            int newCount = (selectedLtcs != null) ? selectedLtcs.size() : 0;
            if (alreadyRegistered + newCount > MAX_MON_PER_HK) {
                int coTheDK = MAX_MON_PER_HK - alreadyRegistered;
                if (coTheDK <= 0) {
                    ra.addFlashAttribute("error",
                        "Đã đạt giới hạn " + MAX_MON_PER_HK + " môn/học kỳ! Hiện tại đã đăng ký " +
                        alreadyRegistered + " môn trong HK" + hocky + "/" + nienkhoa + ". Hãy hủy bớt trước.");
                } else {
                    ra.addFlashAttribute("error",
                        "Vượt giới hạn " + MAX_MON_PER_HK + " môn/HK! Đã ĐK " + alreadyRegistered +
                        " môn, chỉ thêm tối đa " + coTheDK + " nữa. Bạn chọn " + newCount + " môn.");
                }
                ra.addFlashAttribute("flashNienkhoa", nienkhoa);
                ra.addFlashAttribute("flashHocky", hocky);
                return "redirect:/dangky";
            }

            int registered = 0, skippedFull = 0, skippedDeadline = 0;
            java.sql.Date today = new java.sql.Date(System.currentTimeMillis());

            if (selectedLtcs != null) {
                for (int maltc : selectedLtcs) {
                    Map<String, Object> ltcInfo = jdbc.queryForMap(
                        "SELECT SOSVTOIDA, NGAYBATDAU_DK, NGAYKETTHUC_DK FROM LOPTINCHI WHERE MALTC=?", maltc);
                    java.sql.Date batdau = (java.sql.Date) ltcInfo.get("NGAYBATDAU_DK");
                    java.sql.Date ketthuc = (java.sql.Date) ltcInfo.get("NGAYKETTHUC_DK");
                    if (batdau != null && today.before(batdau)) { skippedDeadline++; continue; }
                    if (ketthuc != null && today.after(ketthuc)) { skippedDeadline++; continue; }

                    int existCount = jdbc.queryForObject(
                        "SELECT COUNT(*) FROM DANGKY WHERE MALTC=? AND MASV=?", Integer.class, maltc, masv);
                    if (existCount > 0) {
                        jdbc.update("EXEC sp_DangKyLTC ?, ?", maltc, masv);
                    } else {
                        Integer sosvToida = (Integer) ltcInfo.get("SOSVTOIDA");
                        int currentDK = jdbc.queryForObject(
                            "SELECT COUNT(*) FROM DANGKY WHERE MALTC=? AND (HUYDANGKY=0 OR HUYDANGKY IS NULL)",
                            Integer.class, maltc);
                        if (sosvToida != null && currentDK >= sosvToida) { skippedFull++; continue; }
                        jdbc.update("EXEC sp_DangKyLTC ?, ?", maltc, masv);
                    }
                    registered++;
                }
            }

            String msg = "Đã đăng ký " + registered + " lớp tín chỉ thành công!";
            if (skippedFull > 0) msg += " (Bỏ qua " + skippedFull + " lớp đã đầy)";
            if (skippedDeadline > 0) msg += " (Bỏ qua " + skippedDeadline + " lớp ngoài hạn ĐK)";
            ra.addFlashAttribute("success", msg);
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Lỗi lưu đăng ký: " + e.getMessage());
        }
        ra.addFlashAttribute("flashNienkhoa", nienkhoa);
        ra.addFlashAttribute("flashHocky", hocky);
        return "redirect:/dangky";
    }

    @RequestMapping(value = "/cancel", method = RequestMethod.POST)
    public String cancelOne(@RequestParam int maltc, HttpSession session, RedirectAttributes ra) {
        String nhomQuyen = (String) session.getAttribute("nhomQuyen");
        if (!"SV".equals(nhomQuyen) && !"PGV".equals(nhomQuyen)) return "redirect:/home";
        String masv = "SV".equals(nhomQuyen) ? (String) session.getAttribute("masv") : (String) session.getAttribute("selectedMasv");
        if (masv == null || masv.isEmpty()) {
            ra.addFlashAttribute("error", "Không xác định được sinh viên!");
            return "redirect:/dangky";
        }
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        try {
            java.sql.Date today = new java.sql.Date(System.currentTimeMillis());
            List<Map<String, Object>> ltcRows = jdbc.queryForList("SELECT NGAYHETHAN_HUY FROM LOPTINCHI WHERE MALTC=?", maltc);
            if (!ltcRows.isEmpty() && ltcRows.get(0).get("NGAYHETHAN_HUY") != null) {
                java.sql.Date hanHuy = (java.sql.Date) ltcRows.get(0).get("NGAYHETHAN_HUY");
                if (today.after(hanHuy)) {
                    ra.addFlashAttribute("error", "Không thể hủy — đã quá hạn hủy đăng ký (" + hanHuy + ")!");
                    return "redirect:/dangky";
                }
            }
            List<Map<String, Object>> rows = jdbc.queryForList("SELECT DIEM_CK FROM DANGKY WHERE MALTC=? AND MASV=?", maltc, masv);
            if (!rows.isEmpty() && rows.get(0).get("DIEM_CK") != null) {
                ra.addFlashAttribute("error", "Không thể hủy — môn này đã có điểm cuối kỳ!");
            } else {
                jdbc.update("EXEC sp_HuyDangKyLTC ?, ?", maltc, masv);
                ra.addFlashAttribute("success", "Đã hủy đăng ký lớp tín chỉ #" + maltc);
            }
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Lỗi hủy: " + e.getMessage());
        }
        return "redirect:/dangky";
    }
}
