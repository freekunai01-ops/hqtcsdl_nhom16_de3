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
            // sp_DsLopHocChinh trả về MALOP, TENLOP, MAKHOA, SISO
            List<Map<String, Object>> dsLopHC;
            if ("PGV".equals(nhomQuyen) && ("ALL".equals(maKhoa) || maKhoa == null)) {
                dsLopHC = jdbc.queryForList("EXEC sp_DsLopHocChinh NULL");
            } else {
                dsLopHC = jdbc.queryForList("EXEC sp_DsLopHocChinh ?", maKhoa);
            }
            model.addAttribute("dsLopHC", dsLopHC);

            // Load DS SV trong lớp đang chọn — sp_DsSVTrongLop trả về MASV, HO, TEN, MALOP, DANGHIHOC, KHOAHOC
            String selectedLopHC = (String) session.getAttribute("selectedLopHC");
            if (selectedLopHC != null && !selectedLopHC.isEmpty()) {
                List<Map<String, Object>> dsSvLop = jdbc.queryForList("EXEC sp_DsSVTrongLop ?", selectedLopHC);

                int currentYear = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
                for (Map<String, Object> sv : dsSvLop) {
                    String kh = sv.get("KHOAHOC") != null ? sv.get("KHOAHOC").toString().trim() : "";
                    int totNghiep = 0;
                    if (kh.length() >= 9) {
                        try {
                            int endY = Integer.parseInt(kh.substring(5, 9));
                            if (endY <= currentYear)
                                totNghiep = 1;
                        } catch (Exception e) {
                        }
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

        // Thông tin SV đang chọn — sp_ThongTinSV trả về MASV, HO, TEN, MALOP, DANGHIHOC, TENLOP, MAKHOA, KHOAHOC
        List<Map<String, Object>> svInfoList = jdbc.queryForList("EXEC sp_ThongTinSV ?", masv);
        if (!svInfoList.isEmpty()) {
            Map<String, Object> svInfo = svInfoList.get(0);
            String kh = svInfo.get("KHOAHOC") != null ? svInfo.get("KHOAHOC").toString().trim() : "";
            int totNghiep = 0;
            if (kh.length() >= 9) {
                try {
                    int endY = Integer.parseInt(kh.substring(5, 9));
                    int currentYear = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
                    if (endY <= currentYear)
                        totNghiep = 1;
                } catch (Exception e) {
                }
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
        if (nk == null) {
            nk = "2025-2026";
            hk = 1;
        }

        model.addAttribute("nienkhoa", nk);
        model.addAttribute("hocky", hk);

        // sp_DsLopTinChiMo trả về MALTC, MAMH, TENMH, NHOM, SOSVTOITHIEU, SOTIET_LT, SOTIET_TH, HOTENGV, SOSVDK
        List<Map<String, Object>> dsltc = jdbc.queryForList("EXEC sp_DsLopTinChiMo ?, ?", nk, hk);

        // Tính tín chỉ cho mỗi LTC
        for (Map<String, Object> ltc : dsltc) {
            int lt = ltc.get("SOTIET_LT") != null ? ((Number) ltc.get("SOTIET_LT")).intValue() : 0;
            int th = ltc.get("SOTIET_TH") != null ? ((Number) ltc.get("SOTIET_TH")).intValue() : 0;
            int tc = (lt > 0 ? lt / 15 : 0) + (th > 0 ? th / 30 : 0);
            if (tc == 0)
                tc = 1;
            ltc.put("TINCHI", tc);
        }
        model.addAttribute("dsltc", dsltc);

        // DS đã đăng ký — sp_DsDaKy trả về MALTC
        List<Map<String, Object>> daDangKy = jdbc.queryForList("EXEC sp_DsDaKy ?", masv);
        model.addAttribute("daDangKy", daDangKy);

        // DS LTC đã đăng ký — sp_DsDangKyTheoSV trả về MALTC, NIENKHOA, HOCKY, TENMH, NHOM, SOTIET_LT, SOTIET_TH, DIEM_HM
        List<Map<String, Object>> myLTC = jdbc.queryForList("EXEC sp_DsDangKyTheoSV ?", masv);

        for (Map<String, Object> m : myLTC) {
            int lt = m.get("SOTIET_LT") != null ? ((Number) m.get("SOTIET_LT")).intValue() : 0;
            int th = m.get("SOTIET_TH") != null ? ((Number) m.get("SOTIET_TH")).intValue() : 0;
            int tc = (lt > 0 ? lt / 15 : 0) + (th > 0 ? th / 30 : 0);
            if (tc == 0)
                tc = 1;
            m.put("TINCHI", tc);
        }
        model.addAttribute("myLTC", myLTC);

        // Đếm số môn đã ĐK trong HK hiện tại — sp_DemDKTheoHK trả về SO_DK
        List<Map<String, Object>> dkHKRows = jdbc.queryForList("EXEC sp_DemDKTheoHK ?, ?, ?", masv, nk, hk);
        int daDangKyHK = dkHKRows.isEmpty() ? 0 : ((Number) dkHKRows.get(0).get("SO_DK")).intValue();
        model.addAttribute("daDangKyHK", daDangKyHK);

        return "dangky";
    }

    /** PGV chọn lớp HC */
    @RequestMapping(value = "/selectLop", method = RequestMethod.POST)
    public String selectLop(@RequestParam("malop") String malop, HttpSession session) {
        if (!"PGV".equals(session.getAttribute("nhomQuyen")) && !"KHOA".equals(session.getAttribute("nhomQuyen"))) {
            return "redirect:/home";
        }
        session.setAttribute("selectedLopHC", malop.trim());
        session.removeAttribute("selectedMasv"); // reset SV khi đổi lớp
        return "redirect:/dangky";
    }

    /** PGV chọn SV từ danh sách */
    @RequestMapping(value = "/selectStudent", method = RequestMethod.POST)
    public String selectStudent(@RequestParam("masv") String masv, HttpSession session, RedirectAttributes ra) {
        if (!"PGV".equals(session.getAttribute("nhomQuyen")) && !"KHOA".equals(session.getAttribute("nhomQuyen"))) {
            return "redirect:/home";
        }
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        try {
            List<Map<String, Object>> svRows = jdbc.queryForList("EXEC sp_ThongTinSV ?", masv.trim());
            if (svRows.isEmpty()) {
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
    public String search(@RequestParam("nienkhoa") String nienkhoa, @RequestParam("hocky") int hocky, RedirectAttributes ra) {
        ra.addFlashAttribute("flashNienkhoa", nienkhoa.trim());
        ra.addFlashAttribute("flashHocky", hocky);
        return "redirect:/dangky";
    }

    @RequestMapping(value = "/saveMultiple", method = RequestMethod.POST)
    public String saveMultiple(@RequestParam(value = "selectedLtcs", required = false) List<Integer> selectedLtcs,
            @RequestParam("nienkhoa") String nienkhoa, @RequestParam("hocky") int hocky,
            HttpSession session, RedirectAttributes ra) {
        String nhomQuyen = (String) session.getAttribute("nhomQuyen");
        if (!"SV".equals(nhomQuyen) && !"PGV".equals(nhomQuyen))
            return "redirect:/home";

        String masv = "SV".equals(nhomQuyen) ? (String) session.getAttribute("masv")
                : (String) session.getAttribute("selectedMasv");
        if (masv == null || masv.isEmpty()) {
            ra.addFlashAttribute("error", "Không xác định được sinh viên đăng ký!");
            return "redirect:/dangky";
        }

        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        final int MAX_MON_PER_HK = 8;

        try {
            List<Map<String, Object>> dkHKRows2 = jdbc.queryForList("EXEC sp_DemDKTheoHK ?, ?, ?", masv, nienkhoa.trim(), hocky);
            int alreadyRegistered = dkHKRows2.isEmpty() ? 0 : ((Number) dkHKRows2.get(0).get("SO_DK")).intValue();

            int newCount = (selectedLtcs != null) ? selectedLtcs.size() : 0;
            if (alreadyRegistered + newCount > MAX_MON_PER_HK) {
                int coTheDK = MAX_MON_PER_HK - alreadyRegistered;
                if (coTheDK <= 0) {
                    ra.addFlashAttribute("error",
                            "Đã đạt giới hạn " + MAX_MON_PER_HK + " môn/học kỳ! Hiện tại đã đăng ký " +
                                    alreadyRegistered + " môn trong HK" + hocky + "/" + nienkhoa
                                    + ". Hãy hủy bớt trước.");
                } else {
                    ra.addFlashAttribute("error",
                            "Vượt giới hạn " + MAX_MON_PER_HK + " môn/HK! Đã ĐK " + alreadyRegistered +
                                    " môn, chỉ thêm tối đa " + coTheDK + " nữa. Bạn chọn " + newCount + " môn.");
                }
                ra.addFlashAttribute("flashNienkhoa", nienkhoa);
                ra.addFlashAttribute("flashHocky", hocky);
                return "redirect:/dangky";
            }

            int registered = 0;

            if (selectedLtcs != null) {
                for (int maltc : selectedLtcs) {
                    jdbc.update("EXEC sp_DangKyLTC ?, ?", maltc, masv);
                    registered++;
                }
            }

            String msg = "Đã đăng ký " + registered + " lớp tín chỉ thành công!";
            ra.addFlashAttribute("success", msg);
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Lỗi lưu đăng ký: " + e.getMessage());
        }
        ra.addFlashAttribute("flashNienkhoa", nienkhoa);
        ra.addFlashAttribute("flashHocky", hocky);
        return "redirect:/dangky";
    }

    @RequestMapping(value = "/cancel", method = RequestMethod.POST)
    public String cancelOne(@RequestParam("maltc") int maltc, HttpSession session, RedirectAttributes ra) {
        String nhomQuyen = (String) session.getAttribute("nhomQuyen");
        if (!"SV".equals(nhomQuyen) && !"PGV".equals(nhomQuyen))
            return "redirect:/home";
        String masv = "SV".equals(nhomQuyen) ? (String) session.getAttribute("masv")
                : (String) session.getAttribute("selectedMasv");
        if (masv == null || masv.isEmpty()) {
            ra.addFlashAttribute("error", "Không xác định được sinh viên!");
            return "redirect:/dangky";
        }
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        try {
            // sp_KiemTraDiemCK trả về DIEM_CK (null nếu chưa có)
            List<Map<String, Object>> rows = jdbc.queryForList("EXEC sp_KiemTraDiemCK ?, ?", maltc, masv);
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
