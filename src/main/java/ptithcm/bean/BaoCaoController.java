package ptithcm.bean;

import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.*;

/**
 * Báo cáo - 5 loại:
 * 1. DS Lớp tín chỉ
 * 2. DS SV đăng ký LTC
 * 3. Bảng điểm hết môn
 * 4. Phiếu điểm SV
 * 5. Bảng điểm tổng kết (Cross-Tab)
 */
@Controller
@RequestMapping("/baocao")
public class BaoCaoController {

    @Autowired
    private ConnectionHelper connHelper;

    @RequestMapping(method = RequestMethod.GET)
    public String show(HttpSession session, ModelMap model) {
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        model.addAttribute("khoaList", jdbc.queryForList("SELECT RTRIM(MAKHOA) AS MAKHOA, TENKHOA FROM KHOA ORDER BY MAKHOA"));
        model.addAttribute("dsmh", jdbc.queryForList("SELECT MAMH, TENMH FROM MONHOC ORDER BY TENMH"));
        model.addAttribute("dsLop", jdbc.queryForList("SELECT L.MALOP, L.TENLOP, L.KHOAHOC FROM LOP L ORDER BY L.MALOP"));
        model.addAttribute("dsNienKhoa", jdbc.queryForList("SELECT DISTINCT NIENKHOA FROM LOPTINCHI ORDER BY NIENKHOA DESC", String.class));
        model.addAttribute("dsHocKy", jdbc.queryForList("SELECT DISTINCT HOCKY FROM LOPTINCHI ORDER BY HOCKY", Integer.class));
        return "baocao";
    }

    @RequestMapping(value = "/preview", method = RequestMethod.POST)
    public String previewReport(@RequestParam(value = "reportType") String reportType,
                                @RequestParam(value = "nienkhoa", required = false) String nienkhoa,
                                @RequestParam(value = "hocky", required = false) Integer hocky,
                                @RequestParam(value = "mamh", required = false) String mamh,
                                @RequestParam(value = "nhom", required = false) Integer nhom,
                                @RequestParam(value = "masv", required = false) String masv,
                                @RequestParam(value = "malop", required = false) String malop,
                                @RequestParam(value = "maKhoa", required = false) String maKhoa,
                                @RequestParam(value = "phamvi", required = false) String phamvi,
                                HttpSession session, ModelMap model) {
        buildReport(reportType, nienkhoa, hocky, mamh, nhom, masv, malop, maKhoa, phamvi, session, model);
        return "baocao";
    }

    @RequestMapping(value = "/print", method = RequestMethod.POST)
    public String printReport(@RequestParam(value = "reportType") String reportType,
                              @RequestParam(value = "nienkhoa", required = false) String nienkhoa,
                              @RequestParam(value = "hocky", required = false) Integer hocky,
                              @RequestParam(value = "mamh", required = false) String mamh,
                              @RequestParam(value = "nhom", required = false) Integer nhom,
                              @RequestParam(value = "masv", required = false) String masv,
                              @RequestParam(value = "malop", required = false) String malop,
                              @RequestParam(value = "maKhoa", required = false) String maKhoa,
                              @RequestParam(value = "phamvi", required = false) String phamvi,
                              HttpSession session, ModelMap model) {
        buildReport(reportType, nienkhoa, hocky, mamh, nhom, masv, malop, maKhoa, phamvi, session, model);
        return "baocao_report";
    }

    private void buildReport(String reportType, String nienkhoa, Integer hocky,
                             String mamh, Integer nhom, String masv, String malop,
                             String maKhoa, String phamvi,
                             HttpSession session, ModelMap model) {
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        String sessionNhom = (String) session.getAttribute("nhomQuyen");
        String sessionKhoa = (String) session.getAttribute("maKhoa");

        String selectedKhoa = (maKhoa != null && !maKhoa.trim().isEmpty()) ? maKhoa.trim() : sessionKhoa;
        String tenKhoa = gettenKhoa(jdbc, selectedKhoa);

        model.addAttribute("reportType", reportType);
        model.addAttribute("nienkhoa", nienkhoa != null ? nienkhoa.trim() : "");
        model.addAttribute("hocky", hocky);
        model.addAttribute("mamh", mamh != null ? mamh.trim() : "");
        model.addAttribute("nhom", nhom);
        model.addAttribute("masv", masv != null ? masv.trim() : "");
        model.addAttribute("malop", malop != null ? malop.trim() : "");
        model.addAttribute("maKhoa", selectedKhoa);
        model.addAttribute("phamvi", phamvi != null ? phamvi.trim() : "all");

        // SV chỉ được xem Phiếu điểm cá nhân
        if ("SV".equals(sessionNhom) && !"PHIEU_DIEM".equals(reportType)) {
            reportType = "PHIEU_DIEM";
        }

        try {
            if ("DS_LTC".equals(reportType)) {
                List<Map<String, Object>> data;
                if ("PGV".equals(sessionNhom)) {
                    if (selectedKhoa == null || selectedKhoa.isEmpty() || selectedKhoa.equals("ALL")) {
                        data = jdbc.queryForList(
                            "SELECT MH.TENMH, LTC.NHOM, GV.HO + ' ' + GV.TEN AS HOTENGV, LTC.SOSVTOITHIEU, " +
                            "(SELECT COUNT(*) FROM DANGKY DK WHERE DK.MALTC=LTC.MALTC AND (DK.HUYDANGKY=0 OR DK.HUYDANGKY IS NULL)) AS SOSVDK " +
                            "FROM LOPTINCHI LTC " +
                            "JOIN MONHOC MH ON LTC.MAMH=MH.MAMH " +
                            "JOIN GIANGVIEN GV ON LTC.MAGV=GV.MAGV " +
                            "WHERE LTC.NIENKHOA=? AND LTC.HOCKY=? AND LTC.HUYLOP=0 " +
                            "ORDER BY MH.TENMH, LTC.NHOM", nienkhoa.trim(), hocky);
                        model.addAttribute("tenKhoa", "TOÀN TRƯỜNG");
                    } else {
                        data = jdbc.queryForList(
                            "SELECT MH.TENMH, LTC.NHOM, GV.HO + ' ' + GV.TEN AS HOTENGV, LTC.SOSVTOITHIEU, " +
                            "(SELECT COUNT(*) FROM DANGKY DK WHERE DK.MALTC=LTC.MALTC AND (DK.HUYDANGKY=0 OR DK.HUYDANGKY IS NULL)) AS SOSVDK " +
                            "FROM LOPTINCHI LTC " +
                            "JOIN MONHOC MH ON LTC.MAMH=MH.MAMH " +
                            "JOIN GIANGVIEN GV ON LTC.MAGV=GV.MAGV " +
                            "WHERE LTC.NIENKHOA=? AND LTC.HOCKY=? AND LTC.MAKHOA=? AND LTC.HUYLOP=0 " +
                            "ORDER BY MH.TENMH, LTC.NHOM", nienkhoa.trim(), hocky, selectedKhoa);
                        model.addAttribute("tenKhoa", tenKhoa);
                    }
                } else {
                    data = jdbc.queryForList(
                        "SELECT MH.TENMH, LTC.NHOM, GV.HO + ' ' + GV.TEN AS HOTENGV, LTC.SOSVTOITHIEU, " +
                        "(SELECT COUNT(*) FROM DANGKY DK WHERE DK.MALTC=LTC.MALTC AND (DK.HUYDANGKY=0 OR DK.HUYDANGKY IS NULL)) AS SOSVDK " +
                        "FROM LOPTINCHI LTC " +
                        "JOIN MONHOC MH ON LTC.MAMH=MH.MAMH " +
                        "JOIN GIANGVIEN GV ON LTC.MAGV=GV.MAGV " +
                        "WHERE LTC.NIENKHOA=? AND LTC.HOCKY=? AND LTC.MAKHOA=? AND LTC.HUYLOP=0 " +
                        "ORDER BY MH.TENMH, LTC.NHOM", nienkhoa.trim(), hocky, sessionKhoa);
                    model.addAttribute("tenKhoa", gettenKhoa(jdbc, sessionKhoa));
                }
                model.addAttribute("data", data);
            }
            else if ("DS_SV_DK".equals(reportType)) {
                List<Map<String, Object>> ltcRows;
                if ("PGV".equals(sessionNhom) && (selectedKhoa == null || selectedKhoa.isEmpty() || selectedKhoa.equals("ALL"))) {
                    ltcRows = jdbc.queryForList("SELECT MALTC FROM LOPTINCHI WHERE NIENKHOA=? AND HOCKY=? AND MAMH=? AND NHOM=?", nienkhoa.trim(), hocky, mamh.trim(), nhom);
                    model.addAttribute("tenKhoa", "TOÀN TRƯỜNG");
                } else {
                    String targetK = "PGV".equals(sessionNhom) ? selectedKhoa : sessionKhoa;
                    ltcRows = jdbc.queryForList("SELECT MALTC FROM LOPTINCHI WHERE NIENKHOA=? AND HOCKY=? AND MAMH=? AND NHOM=? AND MAKHOA=?", nienkhoa.trim(), hocky, mamh.trim(), nhom, targetK);
                    model.addAttribute("tenKhoa", gettenKhoa(jdbc, targetK));
                }
                if (ltcRows.isEmpty()) {
                    model.addAttribute("error", "Không tìm thấy Lớp tín chỉ này!");
                } else {
                    Integer maltc = (Integer) ltcRows.get(0).get("MALTC");
                    String tenmh = jdbc.queryForObject("SELECT TENMH FROM MONHOC WHERE MAMH=?", String.class, mamh.trim());
                    List<Map<String, Object>> data = jdbc.queryForList(
                            "SELECT SV.MASV, SV.HO, SV.TEN, SV.PHAI, SV.MALOP " +
                            "FROM DANGKY DK JOIN SINHVIEN SV ON DK.MASV=SV.MASV " +
                            "WHERE DK.MALTC=? AND (DK.HUYDANGKY=0 OR DK.HUYDANGKY IS NULL) " +
                            "ORDER BY SV.MASV", maltc);
                    model.addAttribute("data", data);
                    model.addAttribute("tenmh", tenmh);
                }
            }
            else if ("BANG_DIEM".equals(reportType)) {
                List<Map<String, Object>> ltcRows;
                if ("PGV".equals(sessionNhom) && (selectedKhoa == null || selectedKhoa.isEmpty() || selectedKhoa.equals("ALL"))) {
                    ltcRows = jdbc.queryForList("SELECT MALTC FROM LOPTINCHI WHERE NIENKHOA=? AND HOCKY=? AND MAMH=? AND NHOM=?", nienkhoa.trim(), hocky, mamh.trim(), nhom);
                    model.addAttribute("tenKhoa", "TOÀN TRƯỜNG");
                } else {
                    String targetK = "PGV".equals(sessionNhom) ? selectedKhoa : sessionKhoa;
                    ltcRows = jdbc.queryForList("SELECT MALTC FROM LOPTINCHI WHERE NIENKHOA=? AND HOCKY=? AND MAMH=? AND NHOM=? AND MAKHOA=?", nienkhoa.trim(), hocky, mamh.trim(), nhom, targetK);
                    model.addAttribute("tenKhoa", gettenKhoa(jdbc, targetK));
                }
                if (ltcRows.isEmpty()) {
                    model.addAttribute("error", "Không tìm thấy Lớp tín chỉ này!");
                } else {
                    Integer maltc = (Integer) ltcRows.get(0).get("MALTC");
                    String tenmh = jdbc.queryForObject("SELECT TENMH FROM MONHOC WHERE MAMH=?", String.class, mamh.trim());
                    List<Map<String, Object>> data = jdbc.queryForList(
                            "SELECT SV.MASV, SV.HO, SV.TEN, SV.MALOP, DK.DIEM_CC, DK.DIEM_GK, DK.DIEM_CK, " +
                            "dbo.fn_DiemHetMon(DK.DIEM_CC, DK.DIEM_GK, DK.DIEM_CK) AS DIEM_HM " +
                            "FROM DANGKY DK JOIN SINHVIEN SV ON DK.MASV=SV.MASV " +
                            "WHERE DK.MALTC=? AND (DK.HUYDANGKY=0 OR DK.HUYDANGKY IS NULL) " +
                            "ORDER BY SV.MASV", maltc);
                    model.addAttribute("data", data);
                    model.addAttribute("tenmh", tenmh);
                }
            }
            else if ("PHIEU_DIEM".equals(reportType)) {
                String targetSV = "SV".equals(sessionNhom) ? (String) session.getAttribute("masv") : masv;
                List<Map<String, Object>> svInfo = jdbc.queryForList(
                        "SELECT SV.MASV, SV.HO, SV.TEN, SV.MALOP, L.TENLOP, K.TENKHOA " +
                        "FROM SINHVIEN SV JOIN LOP L ON SV.MALOP=L.MALOP " +
                        "JOIN KHOA K ON L.MAKHOA=K.MAKHOA WHERE SV.MASV=?", targetSV.trim());
                if (svInfo.isEmpty()) {
                    model.addAttribute("error", "Không tìm thấy sinh viên!");
                } else {
                    List<Map<String, Object>> data;
                    if ("hk".equals(phamvi) && nienkhoa != null && !nienkhoa.isEmpty() && hocky != null) {
                        data = jdbc.queryForList(
                                "SELECT MH.TENMH, " +
                                "MAX(dbo.fn_DiemHetMon(DK.DIEM_CC, DK.DIEM_GK, DK.DIEM_CK)) AS DIEM " +
                                "FROM DANGKY DK " +
                                "JOIN LOPTINCHI LTC ON DK.MALTC=LTC.MALTC " +
                                "JOIN MONHOC MH ON LTC.MAMH=MH.MAMH " +
                                "WHERE DK.MASV=? AND (DK.HUYDANGKY=0 OR DK.HUYDANGKY IS NULL) " +
                                "AND DK.DIEM_CK IS NOT NULL " +
                                "AND LTC.NIENKHOA=? AND LTC.HOCKY=? " +
                                "GROUP BY MH.TENMH ORDER BY MH.TENMH", targetSV.trim(), nienkhoa.trim(), hocky);
                    } else {
                        data = jdbc.queryForList(
                                "SELECT MH.TENMH, " +
                                "MAX(dbo.fn_DiemHetMon(DK.DIEM_CC, DK.DIEM_GK, DK.DIEM_CK)) AS DIEM " +
                                "FROM DANGKY DK " +
                                "JOIN LOPTINCHI LTC ON DK.MALTC=LTC.MALTC " +
                                "JOIN MONHOC MH ON LTC.MAMH=MH.MAMH " +
                                "WHERE DK.MASV=? AND (DK.HUYDANGKY=0 OR DK.HUYDANGKY IS NULL) " +
                                "AND DK.DIEM_CK IS NOT NULL " +
                                "GROUP BY MH.TENMH ORDER BY MH.TENMH", targetSV.trim());
                    }
                    
                    // Tính điểm chữ + thang 4 cho từng môn
                    double totalThang4 = 0;
                    int count = 0;
                    for (Map<String, Object> row : data) {
                        Object diemObj = row.get("DIEM");
                        if (diemObj != null) {
                            double diem = ((Number) diemObj).doubleValue();
                            String diemChu;
                            double thang4;
                            if (diem >= 9.0) { diemChu = "A+"; thang4 = 4.0; }
                            else if (diem >= 8.5) { diemChu = "A"; thang4 = 4.0; }
                            else if (diem >= 8.0) { diemChu = "B+"; thang4 = 3.5; }
                            else if (diem >= 7.0) { diemChu = "B"; thang4 = 3.0; }
                            else if (diem >= 6.5) { diemChu = "C+"; thang4 = 2.5; }
                            else if (diem >= 5.5) { diemChu = "C"; thang4 = 2.0; }
                            else if (diem >= 5.0) { diemChu = "D+"; thang4 = 1.5; }
                            else if (diem >= 4.0) { diemChu = "D"; thang4 = 1.0; }
                            else { diemChu = "F"; thang4 = 0.0; }
                            row.put("DIEMCHU", diemChu);
                            row.put("THANG4", thang4);
                            totalThang4 += thang4;
                            count++;
                        }
                    }
                    double gpa = count > 0 ? Math.round((totalThang4 / count) * 100.0) / 100.0 : 0;
                    String xepLoai;
                    if (gpa >= 3.6) xepLoai = "Xuất sắc";
                    else if (gpa >= 3.2) xepLoai = "Giỏi";
                    else if (gpa >= 2.5) xepLoai = "Khá";
                    else if (gpa >= 2.0) xepLoai = "Trung bình";
                    else xepLoai = "Yếu";
                    
                    model.addAttribute("svInfo", svInfo.get(0));
                    model.addAttribute("data", data);
                    model.addAttribute("soMon", count);
                    model.addAttribute("gpa", gpa);
                    model.addAttribute("xepLoai", xepLoai);
                }
            }
            else if ("BANG_DIEM_TK".equals(reportType)) {
                List<Map<String, Object>> lopInfo = jdbc.queryForList(
                        "SELECT L.MALOP, L.TENLOP, L.KHOAHOC, L.MAKHOA, K.TENKHOA " +
                        "FROM LOP L JOIN KHOA K ON L.MAKHOA=K.MAKHOA WHERE L.MALOP=?", malop.trim());
                if (lopInfo.isEmpty()) {
                    model.addAttribute("error", "Không tìm thấy lớp học!");
                } else {
                    // lopMaKhoa used only for display; NOT used to filter queries
                    // so that common subjects opened by other departments are also included
                    List<Map<String, Object>> dsmhCross;
                    List<Map<String, Object>> diemData;

                    if ("hk".equals(phamvi) && nienkhoa != null && !nienkhoa.trim().isEmpty() && hocky != null) {
                        dsmhCross = jdbc.queryForList(
                                "SELECT DISTINCT MH.MAMH, MH.TENMH FROM DANGKY DK " +
                                "JOIN LOPTINCHI LTC ON DK.MALTC=LTC.MALTC " +
                                "JOIN MONHOC MH ON LTC.MAMH=MH.MAMH " +
                                "JOIN SINHVIEN SV ON DK.MASV=SV.MASV " +
                                "WHERE SV.MALOP=? AND (DK.HUYDANGKY=0 OR DK.HUYDANGKY IS NULL) " +
                                "AND DK.DIEM_CK IS NOT NULL " +
                                "AND LTC.NIENKHOA=? AND LTC.HOCKY=? " +
                                "ORDER BY MH.TENMH", malop.trim(), nienkhoa.trim(), hocky);

                        diemData = jdbc.queryForList(
                                "SELECT DK.MASV, LTC.MAMH, " +
                                "MAX(dbo.fn_DiemHetMon(DK.DIEM_CC, DK.DIEM_GK, DK.DIEM_CK)) AS DIEM " +
                                "FROM DANGKY DK " +
                                "JOIN LOPTINCHI LTC ON DK.MALTC=LTC.MALTC " +
                                "JOIN SINHVIEN SV ON DK.MASV=SV.MASV " +
                                "WHERE SV.MALOP=? AND (DK.HUYDANGKY=0 OR DK.HUYDANGKY IS NULL) " +
                                "AND DK.DIEM_CK IS NOT NULL " +
                                "AND LTC.NIENKHOA=? AND LTC.HOCKY=? " +
                                "GROUP BY DK.MASV, LTC.MAMH", malop.trim(), nienkhoa.trim(), hocky);
                    } else {
                        dsmhCross = jdbc.queryForList(
                                "SELECT DISTINCT MH.MAMH, MH.TENMH FROM DANGKY DK " +
                                "JOIN LOPTINCHI LTC ON DK.MALTC=LTC.MALTC " +
                                "JOIN MONHOC MH ON LTC.MAMH=MH.MAMH " +
                                "JOIN SINHVIEN SV ON DK.MASV=SV.MASV " +
                                "WHERE SV.MALOP=? AND (DK.HUYDANGKY=0 OR DK.HUYDANGKY IS NULL) " +
                                "AND DK.DIEM_CK IS NOT NULL " +
                                "ORDER BY MH.TENMH", malop.trim());

                        diemData = jdbc.queryForList(
                                "SELECT DK.MASV, LTC.MAMH, " +
                                "MAX(dbo.fn_DiemHetMon(DK.DIEM_CC, DK.DIEM_GK, DK.DIEM_CK)) AS DIEM " +
                                "FROM DANGKY DK " +
                                "JOIN LOPTINCHI LTC ON DK.MALTC=LTC.MALTC " +
                                "JOIN SINHVIEN SV ON DK.MASV=SV.MASV " +
                                "WHERE SV.MALOP=? AND (DK.HUYDANGKY=0 OR DK.HUYDANGKY IS NULL) " +
                                "AND DK.DIEM_CK IS NOT NULL " +
                                "GROUP BY DK.MASV, LTC.MAMH", malop.trim());
                    }

                    List<Map<String, Object>> dssv = jdbc.queryForList(
                            "SELECT MASV, HO + ' ' + TEN AS HOTENSV FROM SINHVIEN WHERE MALOP=? ORDER BY MASV",
                            malop.trim());

                    model.addAttribute("lopInfo", lopInfo.get(0));
                    model.addAttribute("dsmhCross", dsmhCross);
                    model.addAttribute("dssv", dssv);
                    model.addAttribute("diemData", diemData);
                }
            }
        } catch (Exception e) {
            model.addAttribute("error", "Lỗi tạo báo cáo: " + e.getMessage());
        }

        model.addAttribute("khoaList", jdbc.queryForList("SELECT RTRIM(MAKHOA) AS MAKHOA, TENKHOA FROM KHOA ORDER BY MAKHOA"));
        model.addAttribute("dsmh", jdbc.queryForList("SELECT MAMH, TENMH FROM MONHOC ORDER BY TENMH"));
        model.addAttribute("dsLop", jdbc.queryForList("SELECT L.MALOP, L.TENLOP, L.KHOAHOC FROM LOP L ORDER BY L.MALOP"));
        model.addAttribute("dsNienKhoa", jdbc.queryForList("SELECT DISTINCT NIENKHOA FROM LOPTINCHI ORDER BY NIENKHOA DESC", String.class));
        model.addAttribute("dsHocKy", jdbc.queryForList("SELECT DISTINCT HOCKY FROM LOPTINCHI ORDER BY HOCKY", Integer.class));
    }

    private String gettenKhoa(JdbcTemplate jdbc, String maKhoa) {
        try {
            return jdbc.queryForObject("SELECT TENKHOA FROM KHOA WHERE MAKHOA=?", String.class, maKhoa);
        } catch (Exception e) {
            return maKhoa;
        }
    }
}
