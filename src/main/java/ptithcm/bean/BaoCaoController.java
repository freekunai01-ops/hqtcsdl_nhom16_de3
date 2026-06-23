package ptithcm.bean;

import java.util.List;
import java.util.Map;
import java.util.HashMap;
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
        String nhom = (String) session.getAttribute("nhomQuyen");
        String khoa = (String) session.getAttribute("maKhoa");
        model.addAttribute("khoaList", jdbc.queryForList("SELECT RTRIM(MAKHOA) AS MAKHOA, TENKHOA FROM KHOA ORDER BY MAKHOA"));
        model.addAttribute("dsmh", jdbc.queryForList("SELECT MAMH, TENMH FROM MONHOC ORDER BY TENMH"));
        if ("KHOA".equals(nhom) && khoa != null && !khoa.equals("ALL")) {
            model.addAttribute("dsLop", jdbc.queryForList("SELECT L.MALOP, L.TENLOP, L.KHOAHOC FROM LOP L WHERE L.MAKHOA=? ORDER BY L.MALOP", khoa.trim()));
        } else {
            model.addAttribute("dsLop", jdbc.queryForList("SELECT L.MALOP, L.TENLOP, L.KHOAHOC FROM LOP L ORDER BY L.MALOP"));
        }
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
                String targetK = "ALL";
                if ("PGV".equals(sessionNhom)) {
                    if (selectedKhoa != null && !selectedKhoa.isEmpty() && !selectedKhoa.equals("ALL")) {
                        targetK = selectedKhoa.trim();
                        model.addAttribute("tenKhoa", tenKhoa);
                    } else {
                        model.addAttribute("tenKhoa", "TOÀN TRƯỜNG");
                    }
                } else {
                    targetK = sessionKhoa.trim();
                    model.addAttribute("tenKhoa", gettenKhoa(jdbc, sessionKhoa));
                }
                data = jdbc.queryForList("EXEC sp_InDSLTC ?, ?, ?", nienkhoa.trim(), hocky, targetK);
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
                    List<Map<String, Object>> data = jdbc.queryForList("EXEC sp_InDSSVLTC ?", maltc);
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
                    List<Map<String, Object>> data = jdbc.queryForList("EXEC sp_InBangDiemLTC ?", maltc);
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
                        data = jdbc.queryForList("EXEC sp_InPhieuDiem ?, ?, ?", targetSV.trim(), nienkhoa.trim(), hocky);
                    } else {
                        data = jdbc.queryForList("EXEC sp_InPhieuDiem ?", targetSV.trim());
                    }
                    
                    model.addAttribute("svInfo", svInfo.get(0));
                    model.addAttribute("data", data);
                    model.addAttribute("soMon", data.size());
                }
            }
            else if ("BANG_DIEM_TK".equals(reportType)) {
                // KHOA chỉ được in bảng điểm lớp thuộc khoa mình
                String lopQuery = "PGV".equals(sessionNhom)
                        ? "SELECT L.MALOP, L.TENLOP, L.KHOAHOC, L.MAKHOA, K.TENKHOA FROM LOP L JOIN KHOA K ON L.MAKHOA=K.MAKHOA WHERE L.MALOP=?"
                        : "SELECT L.MALOP, L.TENLOP, L.KHOAHOC, L.MAKHOA, K.TENKHOA FROM LOP L JOIN KHOA K ON L.MAKHOA=K.MAKHOA WHERE L.MALOP=? AND L.MAKHOA=?";
                List<Map<String, Object>> lopInfo = "PGV".equals(sessionNhom)
                        ? jdbc.queryForList(lopQuery, malop.trim())
                        : jdbc.queryForList(lopQuery, malop.trim(), sessionKhoa.trim());
                if (lopInfo.isEmpty()) {
                    model.addAttribute("error", "Không tìm thấy lớp học!");
                } else {
                    List<Map<String, Object>> dsmhCross;
                    List<Map<String, Object>> diemData;

                    if ("hk".equals(phamvi) && nienkhoa != null && !nienkhoa.trim().isEmpty() && hocky != null) {
                        dsmhCross = jdbc.queryForList("EXEC sp_GetMonHocCross ?, ?, ?", malop.trim(), nienkhoa.trim(), hocky);
                        diemData = jdbc.queryForList("EXEC sp_GetDiemDataCross ?, ?, ?", malop.trim(), nienkhoa.trim(), hocky);
                    } else {
                        dsmhCross = jdbc.queryForList("EXEC sp_GetMonHocCross ?", malop.trim());
                        diemData = jdbc.queryForList("EXEC sp_GetDiemDataCross ?", malop.trim());
                    }

                    List<Map<String, Object>> dssv = jdbc.queryForList(
                            "SELECT MASV, HO + ' ' + TEN AS HOTENSV FROM SINHVIEN WHERE MALOP=? ORDER BY MASV",
                            malop.trim());

                    Map<String, Object> diemMap = new HashMap<>();
                    for (Map<String, Object> row : diemData) {
                        String masvVal = row.get("MASV") != null ? row.get("MASV").toString().trim() : "";
                        String mamhVal = row.get("MAMH") != null ? row.get("MAMH").toString().trim() : "";
                        Object diemVal = row.get("DIEM");
                        if (!masvVal.isEmpty() && !mamhVal.isEmpty() && diemVal != null) {
                            diemMap.put(masvVal + "_" + mamhVal, diemVal);
                        }
                    }

                    model.addAttribute("lopInfo", lopInfo.get(0));
                    model.addAttribute("dsmhCross", dsmhCross);
                    model.addAttribute("dssv", dssv);
                    model.addAttribute("diemMap", diemMap);
                }
            }
        } catch (Exception e) {
            model.addAttribute("error", "Lỗi tạo báo cáo: " + e.getMessage());
        }

        model.addAttribute("khoaList", jdbc.queryForList("SELECT RTRIM(MAKHOA) AS MAKHOA, TENKHOA FROM KHOA ORDER BY MAKHOA"));
        model.addAttribute("dsmh", jdbc.queryForList("SELECT MAMH, TENMH FROM MONHOC ORDER BY TENMH"));
        if ("KHOA".equals(sessionNhom) && sessionKhoa != null && !sessionKhoa.equals("ALL")) {
            model.addAttribute("dsLop", jdbc.queryForList("SELECT L.MALOP, L.TENLOP, L.KHOAHOC FROM LOP L WHERE L.MAKHOA=? ORDER BY L.MALOP", sessionKhoa.trim()));
        } else {
            model.addAttribute("dsLop", jdbc.queryForList("SELECT L.MALOP, L.TENLOP, L.KHOAHOC FROM LOP L ORDER BY L.MALOP"));
        }
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
