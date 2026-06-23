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
import org.springframework.transaction.support.TransactionTemplate;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;

/**
 * Nhập điểm - PGV nhập/sửa, KHOA xem read-only
 * HM = CC*0.1 + GK*0.3 + CK*0.6
 */
@Controller
@RequestMapping("/diem")
public class DiemController {

    @Autowired
    private ConnectionHelper connHelper;

    @RequestMapping(method = RequestMethod.GET)
    public String show(@RequestParam(value = "nienkhoa", required = false) String nienkhoa,
                       @RequestParam(value = "hocky", required = false) Integer hocky,
                       @RequestParam(value = "mamh", required = false) String mamh,
                       @RequestParam(value = "nhom", required = false) Integer nhom,
                       HttpSession session, ModelMap model) {
        String nhomQuyen = (String) session.getAttribute("nhomQuyen");
        if (!"PGV".equals(nhomQuyen) && !"KHOA".equals(nhomQuyen)) return "redirect:/home";
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        String maKhoa = (String) session.getAttribute("maKhoa");
        reloadDropdowns(jdbc, nhomQuyen, maKhoa, model);
        
        if (nienkhoa != null && hocky != null && mamh != null && nhom != null) {
            executeLoadDiem(nienkhoa, hocky, mamh, nhom, session, model, jdbc, maKhoa, nhomQuyen);
        }
        return "diem";
    }

    @RequestMapping(value = "/load", method = RequestMethod.POST)
    public String loadDiem(@RequestParam("nienkhoa") String nienkhoa, @RequestParam("hocky") int hocky,
                           @RequestParam("mamh") String mamh, @RequestParam("nhom") int nhom,
                           HttpSession session, ModelMap model) {
        String nhomQuyen = (String) session.getAttribute("nhomQuyen");
        if (!"PGV".equals(nhomQuyen) && !"KHOA".equals(nhomQuyen)) return "redirect:/home";
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        String maKhoa = (String) session.getAttribute("maKhoa");
        
        executeLoadDiem(nienkhoa, hocky, mamh, nhom, session, model, jdbc, maKhoa, nhomQuyen);
        return "diem";
    }

    private void executeLoadDiem(String nienkhoa, int hocky, String mamh, int nhom,
                                 HttpSession session, ModelMap model, JdbcTemplate jdbc,
                                 String maKhoa, String nhomQuyen) {
        // Tìm LTC
        List<Map<String, Object>> ltcRows;
        if ("ALL".equals(maKhoa) || maKhoa == null || maKhoa.trim().isEmpty()) {
            ltcRows = jdbc.queryForList(
                "SELECT LTC.MALTC, LTC.HUYLOP, LTC.SOSVTOITHIEU, GV.HO + ' ' + GV.TEN AS HOTENGV, K.TENKHOA, RTRIM(LTC.MAKHOA) AS MAKHOA " +
                "FROM LOPTINCHI LTC JOIN GIANGVIEN GV ON LTC.MAGV=GV.MAGV JOIN KHOA K ON LTC.MAKHOA=K.MAKHOA " +
                "WHERE LTC.NIENKHOA=? AND LTC.HOCKY=? AND LTC.MAMH=? AND LTC.NHOM=?",
                nienkhoa.trim(), hocky, mamh.trim(), nhom);
        } else {
            ltcRows = jdbc.queryForList(
                "SELECT LTC.MALTC, LTC.HUYLOP, LTC.SOSVTOITHIEU, GV.HO + ' ' + GV.TEN AS HOTENGV, K.TENKHOA, RTRIM(LTC.MAKHOA) AS MAKHOA " +
                "FROM LOPTINCHI LTC JOIN GIANGVIEN GV ON LTC.MAGV=GV.MAGV JOIN KHOA K ON LTC.MAKHOA=K.MAKHOA " +
                "WHERE LTC.NIENKHOA=? AND LTC.HOCKY=? AND LTC.MAMH=? AND LTC.NHOM=? AND LTC.MAKHOA=?",
                nienkhoa.trim(), hocky, mamh.trim(), nhom, maKhoa);
        }

        if (ltcRows.isEmpty()) {
            model.addAttribute("error", "Không tìm thấy lớp tín chỉ!");
            reloadDropdowns(jdbc, nhomQuyen, maKhoa, model);
            return;
        }

        Map<String, Object> ltcInfo = ltcRows.get(0);
        int maltc = (Integer) ltcInfo.get("MALTC");
        boolean huylop = ltcInfo.get("HUYLOP") != null && (Boolean) ltcInfo.get("HUYLOP");
        String tenmh = jdbc.queryForObject("SELECT TENMH FROM MONHOC WHERE MAMH=?", String.class, mamh.trim());

        // Load SV + điểm + tính HM server-side
        List<Map<String, Object>> dssv = jdbc.queryForList(
            "SELECT DK.MASV, SV.HO + ' ' + SV.TEN AS HOTENSV, SV.MALOP, " +
            "DK.DIEM_CC, DK.DIEM_GK, DK.DIEM_CK " +
            "FROM DANGKY DK JOIN SINHVIEN SV ON DK.MASV=SV.MASV " +
            "WHERE DK.MALTC=? AND (DK.HUYDANGKY=0 OR DK.HUYDANGKY IS NULL) " +
            "ORDER BY SV.TEN, SV.HO", maltc);

        // Thống kê
        int totalSV = dssv.size(), daNhap = 0, chuaNhap = 0, dat = 0, rot = 0;
        for (Map<String, Object> sv : dssv) {
            Double cc = toDouble(sv.get("DIEM_CC")), gk = toDouble(sv.get("DIEM_GK")), ck = toDouble(sv.get("DIEM_CK"));
            if (ck != null) {
                daNhap++;
                double hm = (cc != null ? cc : 0) * 0.1 + (gk != null ? gk : 0) * 0.3 + ck * 0.6;
                sv.put("DIEM_HM", Math.round(hm * 100.0) / 100.0);
                if (hm >= 5) dat++; else rot++;
            } else { chuaNhap++; sv.put("DIEM_HM", null); }
        }

        model.addAttribute("dssv", dssv);
        model.addAttribute("maltc", maltc);
        model.addAttribute("classKhoa", ltcInfo.get("MAKHOA"));
        model.addAttribute("nienkhoa", nienkhoa.trim());
        model.addAttribute("hocky", hocky);
        model.addAttribute("mamh", mamh.trim());
        model.addAttribute("tenmh", tenmh);
        model.addAttribute("nhom", nhom);
        model.addAttribute("hotenGV", ltcInfo.get("HOTENGV"));
        model.addAttribute("tenKhoa", ltcInfo.get("TENKHOA"));
        model.addAttribute("sosvToithieu", ltcInfo.get("SOSVTOITHIEU"));
        model.addAttribute("huylop", huylop);
        model.addAttribute("totalSV", totalSV);
        model.addAttribute("daNhap", daNhap);
        model.addAttribute("chuaNhap", chuaNhap);
        model.addAttribute("dat", dat);
        model.addAttribute("rot", rot);
        model.addAttribute("tyLeDat", totalSV > 0 && daNhap > 0 ? Math.round(dat * 100.0 / daNhap) : 0);
        reloadDropdowns(jdbc, nhomQuyen, maKhoa, model);
    }

    @RequestMapping(value = "/save", method = RequestMethod.POST)
    public String saveDiem(@RequestParam("maltc") int maltc, @RequestParam("nienkhoa") String nienkhoa,
                           @RequestParam("hocky") int hocky, @RequestParam("mamh") String mamh, @RequestParam("nhom") int nhom,
                           @RequestParam("masv[]") String[] masvArr,
                           @RequestParam("diemCC[]") String[] diemCCArr,
                           @RequestParam("diemGK[]") String[] diemGKArr,
                           @RequestParam("diemCK[]") String[] diemCKArr,
                           HttpSession session, RedirectAttributes ra) {
        String nhomQuyen = (String) session.getAttribute("nhomQuyen");
        if (!"PGV".equals(nhomQuyen) && !"KHOA".equals(nhomQuyen)) {
            ra.addFlashAttribute("error", "Bạn không có quyền ghi điểm!");
            return "redirect:/diem";
        }
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        try {
            if ("KHOA".equals(nhomQuyen)) {
                String maKhoa = (String) session.getAttribute("maKhoa");
                String classKhoa = jdbc.queryForObject(
                    "SELECT RTRIM(MAKHOA) FROM LOPTINCHI WHERE MALTC = ?", String.class, maltc);
                if (!"ALL".equals(maKhoa) && !maKhoa.equals(classKhoa)) {
                    ra.addFlashAttribute("error", "Bạn không có quyền ghi điểm cho lớp của khoa khác!");
                    return "redirect:/diem?nienkhoa=" + nienkhoa.trim() + "&hocky=" + hocky + "&mamh=" + mamh.trim() + "&nhom=" + nhom;
                }
            }
            // Validate trước
            for (int i = 0; i < masvArr.length; i++) {
                Double cc = parseDoubleOrNull(diemCCArr[i]), gk = parseDoubleOrNull(diemGKArr[i]), ck = parseDoubleOrNull(diemCKArr[i]);
                if (cc != null && (cc < 0 || cc > 10)) { ra.addFlashAttribute("error", "Điểm CC SV " + masvArr[i] + " phải từ 0-10!"); return "redirect:/diem?nienkhoa=" + nienkhoa.trim() + "&hocky=" + hocky + "&mamh=" + mamh.trim() + "&nhom=" + nhom; }
                if (gk != null && (gk < 0 || gk > 10)) { ra.addFlashAttribute("error", "Điểm GK SV " + masvArr[i] + " phải từ 0-10!"); return "redirect:/diem?nienkhoa=" + nienkhoa.trim() + "&hocky=" + hocky + "&mamh=" + mamh.trim() + "&nhom=" + nhom; }
                if (ck != null && (ck < 0 || ck > 10)) { ra.addFlashAttribute("error", "Điểm CK SV " + masvArr[i] + " phải từ 0-10!"); return "redirect:/diem?nienkhoa=" + nienkhoa.trim() + "&hocky=" + hocky + "&mamh=" + mamh.trim() + "&nhom=" + nhom; }
            }
            PlatformTransactionManager txManager = new DataSourceTransactionManager(jdbc.getDataSource());
            TransactionTemplate tx = new TransactionTemplate(txManager);
            tx.execute(status -> {
                for (int i = 0; i < masvArr.length; i++) {
                    Double cc = parseDoubleOrNull(diemCCArr[i]), gk = parseDoubleOrNull(diemGKArr[i]), ck = parseDoubleOrNull(diemCKArr[i]);
                    jdbc.update("EXEC sp_GhiDiem ?, ?, ?, ?, ?",
                        maltc, masvArr[i].trim(), cc != null ? cc.intValue() : null, gk, ck);
                }
                return null;
            });
            ra.addFlashAttribute("success", "Ghi điểm thành công cho " + masvArr.length + " sinh viên!");
        } catch (Exception e) { ra.addFlashAttribute("error", "Lỗi ghi điểm: " + e.getMessage()); }
        return "redirect:/diem?nienkhoa=" + nienkhoa.trim() + "&hocky=" + hocky + "&mamh=" + mamh.trim() + "&nhom=" + nhom;
    }

    private void reloadDropdowns(JdbcTemplate jdbc, String nhomQuyen, String maKhoa, ModelMap model) {
        model.addAttribute("dsmh", jdbc.queryForList("SELECT MAMH, TENMH FROM MONHOC ORDER BY TENMH"));
        List<Map<String, Object>> khoaList = jdbc.queryForList("SELECT RTRIM(MAKHOA) AS MAKHOA, TENKHOA FROM KHOA ORDER BY MAKHOA");
        model.addAttribute("khoaList", khoaList);
        if ("ALL".equals(maKhoa) || maKhoa == null || maKhoa.trim().isEmpty()) {
            model.addAttribute("dsNienKhoa", jdbc.queryForList("SELECT DISTINCT NIENKHOA FROM LOPTINCHI ORDER BY NIENKHOA DESC"));
        } else {
            model.addAttribute("dsNienKhoa", jdbc.queryForList("SELECT DISTINCT NIENKHOA FROM LOPTINCHI WHERE MAKHOA=? ORDER BY NIENKHOA DESC", maKhoa));
        }
    }

    private Double toDouble(Object o) { if (o == null) return null; return ((Number) o).doubleValue(); }
    private Double parseDoubleOrNull(String s) { if (s == null || s.trim().isEmpty()) return null; try { return Double.parseDouble(s.trim()); } catch (Exception e) { return null; } }
}
