package ptithcm.bean;

import java.sql.Date;
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
@RequestMapping("/loptinchi")
public class LopTinChiController {

    @Autowired
    private ConnectionHelper connHelper;

    @RequestMapping(method = RequestMethod.GET)
    public String show(@RequestParam(value = "maltc", required = false) Integer maltc,
            HttpSession session, ModelMap model) {
        String nhomQuyen = (String) session.getAttribute("nhomQuyen");
        if (!"PGV".equals(nhomQuyen) && !"KHOA".equals(nhomQuyen)) {
            return "redirect:/home";
        }
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        String maKhoa = (String) session.getAttribute("maKhoa");
        // sp_DsLopTinChi trả về MALTC, NIENKHOA, HOCKY, MAMH, NHOM, MAGV, MAKHOA, SOSVTOITHIEU, HUYLOP, TENMH, HOTENGV, SOSVDK
        List<Map<String, Object>> dsltc;
        List<Map<String, Object>> dsgv;
        if ("ALL".equals(maKhoa) || maKhoa == null || maKhoa.trim().isEmpty()) {
            dsltc = jdbc.queryForList("EXEC sp_DsLopTinChi NULL");
            dsgv = jdbc.queryForList("EXEC sp_DsGiangVienDropdown NULL");
        } else {
            dsltc = jdbc.queryForList("EXEC sp_DsLopTinChi ?", maKhoa);
            dsgv = jdbc.queryForList("EXEC sp_DsGiangVienDropdown ?", maKhoa);
        }
        model.addAttribute("dsltc", dsltc);
        model.addAttribute("dsmh", jdbc.queryForList("EXEC sp_DsMonHocDropdown"));
        model.addAttribute("dsgv", dsgv);
        model.addAttribute("khoaList", jdbc.queryForList("EXEC sp_DsKhoaDropdown"));
        model.addAttribute("selectedMaltc", maltc != null ? maltc : 0);
        return "loptinchi";
    }

    @RequestMapping(value = "/save", method = RequestMethod.POST)
    public String save(@RequestParam("action") String action,
            @RequestParam(value = "maltc", required = false) Integer maltc,
            @RequestParam("nienkhoa") String nienkhoa,
            @RequestParam("hocky") int hocky,
            @RequestParam("mamh") String mamh,
            @RequestParam("nhom") int nhom,
            @RequestParam("magv") String magv,
            @RequestParam("sosvtoithieu") int sosvtoithieu,
            @RequestParam(value = "huylop", required = false, defaultValue = "false") boolean huylop,
            @RequestParam(value = "maKhoa", required = false) String maKhoa,
            HttpSession session, RedirectAttributes ra) {
        System.out.println("===> DEBUG: LopTinChiController.save action=" + action + ", nienkhoa=" + nienkhoa
                + ", hocky=" + hocky + ", mamh=" + mamh + ", nhom=" + nhom + ", magv=" + magv + ", nhomQuyen="
                + session.getAttribute("nhomQuyen"));
        if (!"PGV".equals(session.getAttribute("nhomQuyen"))) {
            System.out.println("===> DEBUG: Blocked due to role: " + session.getAttribute("nhomQuyen"));
            return "redirect:/home";
        }

        if ("add".equals(action)) {
            int currentYear = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
            try {
                String startYearStr = nienkhoa.trim().substring(0, 4);
                int startYear = Integer.parseInt(startYearStr);
                if (startYear < currentYear) {
                    ra.addFlashAttribute("error", "Lỗi: Không được mở lớp tín chỉ cho niên khóa trong quá khứ ("
                            + nienkhoa + " < " + currentYear + ")!");
                    return "redirect:/loptinchi";
                }
            } catch (Exception e) {
                ra.addFlashAttribute("error", "Lỗi: Định dạng niên khóa không hợp lệ (ví dụ đúng: 2026-2027)!");
                return "redirect:/loptinchi";
            }
        }

        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        String kh = (maKhoa != null && !maKhoa.isEmpty()) ? maKhoa.trim() : (String) session.getAttribute("maKhoa");
        if (kh == null || "ALL".equals(kh)) {
            // Lấy khoa đầu tiên qua sp_DsKhoaDropdown
            List<Map<String, Object>> khoaRows = jdbc.queryForList("EXEC sp_DsKhoaDropdown");
            kh = khoaRows.isEmpty() ? null : khoaRows.get(0).get("MAKHOA").toString().trim();
        }
        try {
            if ("add".equals(action)) {
                jdbc.update("EXEC sp_ThemLopTinChi ?, ?, ?, ?, ?, ?, ?, ?",
                        nienkhoa.trim(), hocky, mamh.trim(), nhom, magv.trim(), kh, sosvtoithieu,
                        huylop ? 1 : 0);
                try {
                    // Lấy MALTC vừa tạo qua sp_DsLopTinChi lọc theo niên khóa/HK/môn/nhóm
                    List<Map<String, Object>> ltcRows = jdbc.queryForList(
                            "EXEC sp_TimMALTC ?, ?, ?, ?",
                            nienkhoa.trim(), hocky, mamh.trim(), nhom);
                    if (!ltcRows.isEmpty()) maltc = ((Number) ltcRows.get(0).get("MALTC")).intValue();
                } catch (Exception e) {
                }
                ra.addFlashAttribute("success", "Mở lớp tín chỉ thành công!");
            } else if (maltc != null) {
                jdbc.update("EXEC sp_SuaLopTinChi ?, ?, ?, ?, ?, ?, ?, ?",
                        maltc, nienkhoa.trim(), hocky, mamh.trim(), nhom, magv.trim(), sosvtoithieu,
                        huylop ? 1 : 0);
                ra.addFlashAttribute("success", "Cập nhật lớp tín chỉ thành công!");
            }
        } catch (Exception e) {
            System.err.println("===> DEBUG ERROR: " + e.getMessage());
            e.printStackTrace();
            ra.addFlashAttribute("error", "Lỗi: " + e.getMessage());
        }
        System.out.println("===> DEBUG: Redirecting back to /loptinchi with maltc=" + maltc);
        return "redirect:/loptinchi" + (maltc != null ? "?maltc=" + maltc : "");
    }

    @RequestMapping(value = "/delete", method = RequestMethod.POST)
    public String delete(@RequestParam("maltc") int maltc,
            @RequestParam(value = "nextMaltc", required = false) Integer nextMaltc,
            HttpSession session, RedirectAttributes ra) {
        if (!"PGV".equals(session.getAttribute("nhomQuyen"))) {
            return "redirect:/home";
        }
        try {
            connHelper.getJdbcTemplate(session)
                    .update("EXEC sp_XoaLopTinChi ?", maltc);
            ra.addFlashAttribute("success", "Xóa lớp tín chỉ thành công!");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Không thể xóa: " + e.getMessage());
            return "redirect:/loptinchi?maltc=" + maltc;
        }
        return "redirect:/loptinchi" + (nextMaltc != null ? "?maltc=" + nextMaltc : "");
    }
}
