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
    public String show(HttpSession session, ModelMap model) {
        String nhomQuyen = (String) session.getAttribute("nhomQuyen");
        if (!"PGV".equals(nhomQuyen) && !"KHOA".equals(nhomQuyen)) {
            return "redirect:/home";
        }
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        String maKhoa = (String) session.getAttribute("maKhoa");
        List<Map<String, Object>> dsltc;
        List<Map<String, Object>> dsgv;
        if ("ALL".equals(maKhoa) || maKhoa == null || maKhoa.trim().isEmpty()) {
            dsltc = jdbc.queryForList(
                "SELECT LTC.*, MH.TENMH, GV.HO + ' ' + GV.TEN AS HOTENGV, " +
                "(SELECT COUNT(*) FROM DANGKY DK WHERE DK.MALTC=LTC.MALTC AND (DK.HUYDANGKY=0 OR DK.HUYDANGKY IS NULL)) AS SOSVDK " +
                "FROM LOPTINCHI LTC JOIN MONHOC MH ON LTC.MAMH=MH.MAMH JOIN GIANGVIEN GV ON LTC.MAGV=GV.MAGV " +
                "ORDER BY LTC.NIENKHOA DESC, LTC.HOCKY, MH.TENMH, LTC.NHOM");
            dsgv = jdbc.queryForList("SELECT MAGV, HO + ' ' + TEN AS HOTENGV FROM GIANGVIEN ORDER BY TEN");
        } else {
            dsltc = jdbc.queryForList(
                "SELECT LTC.*, MH.TENMH, GV.HO + ' ' + GV.TEN AS HOTENGV, " +
                "(SELECT COUNT(*) FROM DANGKY DK WHERE DK.MALTC=LTC.MALTC AND (DK.HUYDANGKY=0 OR DK.HUYDANGKY IS NULL)) AS SOSVDK " +
                "FROM LOPTINCHI LTC JOIN MONHOC MH ON LTC.MAMH=MH.MAMH JOIN GIANGVIEN GV ON LTC.MAGV=GV.MAGV " +
                "WHERE LTC.MAKHOA=? ORDER BY LTC.NIENKHOA DESC, LTC.HOCKY, MH.TENMH, LTC.NHOM", maKhoa);
            dsgv = jdbc.queryForList("SELECT MAGV, HO + ' ' + TEN AS HOTENGV FROM GIANGVIEN WHERE MAKHOA=? ORDER BY TEN", maKhoa);
        }
        model.addAttribute("dsltc", dsltc);
        model.addAttribute("dsmh", jdbc.queryForList("SELECT MAMH, TENMH FROM MONHOC ORDER BY TENMH"));
        model.addAttribute("dsgv", dsgv);
        model.addAttribute("khoaList", jdbc.queryForList("SELECT RTRIM(MAKHOA) AS MAKHOA, TENKHOA FROM KHOA ORDER BY MAKHOA"));
        return "loptinchi";
    }

    @RequestMapping(value = "/save", method = RequestMethod.POST)
    public String save(@RequestParam String action,
                       @RequestParam(required = false) Integer maltc,
                       @RequestParam String nienkhoa,
                       @RequestParam int hocky,
                       @RequestParam String mamh,
                       @RequestParam int nhom,
                       @RequestParam String magv,
                       @RequestParam int sosvtoithieu,
                       @RequestParam(required = false, defaultValue = "40") int sosvtoida,
                       @RequestParam(required = false, defaultValue = "false") boolean huylop,
                       @RequestParam(required = false) String ngaybatdauDk,
                       @RequestParam(required = false) String ngayketthucDk,
                       @RequestParam(required = false) String ngayhethanHuy,
                       @RequestParam(required = false) String lydohuy,
                       @RequestParam(required = false) String maKhoa,
                       HttpSession session, RedirectAttributes ra) {
        if (!"PGV".equals(session.getAttribute("nhomQuyen"))) {
            return "redirect:/home";
        }
        
        if ("add".equals(action)) {
            int currentYear = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
            try {
                String startYearStr = nienkhoa.trim().substring(0, 4);
                int startYear = Integer.parseInt(startYearStr);
                if (startYear < currentYear) {
                    ra.addFlashAttribute("error", "Lỗi: Không được mở lớp tín chỉ cho niên khóa trong quá khứ (" + nienkhoa + " < " + currentYear + ")!");
                    return "redirect:/loptinchi";
                }
            } catch (Exception e) {
                ra.addFlashAttribute("error", "Lỗi: Định dạng niên khóa không hợp lệ (ví dụ đúng: 2026-2027)!");
                return "redirect:/loptinchi";
            }
        }

        // Parse deadline dates
        Date dbBatdau = null, dbKetthuc = null, dbHethan = null;
        try {
            if (ngaybatdauDk != null && !ngaybatdauDk.isEmpty()) dbBatdau = Date.valueOf(ngaybatdauDk);
            if (ngayketthucDk != null && !ngayketthucDk.isEmpty()) dbKetthuc = Date.valueOf(ngayketthucDk);
            if (ngayhethanHuy != null && !ngayhethanHuy.isEmpty()) dbHethan = Date.valueOf(ngayhethanHuy);
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Lỗi: Định dạng ngày không hợp lệ!");
            return "redirect:/loptinchi";
        }

        // Validate date order: batdau <= ketthuc <= hethan
        if (dbBatdau != null && dbKetthuc != null && dbBatdau.after(dbKetthuc)) {
            ra.addFlashAttribute("error", "Lỗi: Ngày bắt đầu ĐK phải trước hoặc bằng ngày kết thúc ĐK!");
            return "redirect:/loptinchi";
        }
        if (dbKetthuc != null && dbHethan != null && dbKetthuc.after(dbHethan)) {
            ra.addFlashAttribute("error", "Lỗi: Ngày kết thúc ĐK phải trước hoặc bằng hạn hủy!");
            return "redirect:/loptinchi";
        }

        // Validate: hủy lớp phải có lý do
        if (huylop && (lydohuy == null || lydohuy.trim().isEmpty())) {
            ra.addFlashAttribute("error", "Lỗi: Hủy lớp phải nhập lý do hủy!");
            return "redirect:/loptinchi";
        }

        // Validate: sĩ số tối đa >= tối thiểu
        if (sosvtoida < sosvtoithieu) {
            ra.addFlashAttribute("error", "Lỗi: Sĩ số tối đa (" + sosvtoida + ") phải >= sĩ số tối thiểu (" + sosvtoithieu + ")!");
            return "redirect:/loptinchi";
        }

        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        String kh = (maKhoa != null && !maKhoa.isEmpty()) ? maKhoa.trim() : (String) session.getAttribute("maKhoa");
        if (kh == null || "ALL".equals(kh)) {
            kh = jdbc.queryForObject("SELECT TOP 1 MAKHOA FROM KHOA ORDER BY MAKHOA", String.class);
        }
        String lydo = (lydohuy != null && !lydohuy.trim().isEmpty()) ? lydohuy.trim() : null;
        try {
            if ("add".equals(action)) {
                jdbc.update("INSERT INTO LOPTINCHI (NIENKHOA,HOCKY,MAMH,NHOM,MAGV,MAKHOA,SOSVTOITHIEU,SOSVTOIDA,HUYLOP,NGAYBATDAU_DK,NGAYKETTHUC_DK,NGAYHETHAN_HUY,LYDOHUY) " +
                            "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)",
                        nienkhoa.trim(), hocky, mamh.trim(), nhom, magv.trim(), kh, sosvtoithieu, sosvtoida, huylop,
                        dbBatdau, dbKetthuc, dbHethan, lydo);
                ra.addFlashAttribute("success", "Mở lớp tín chỉ thành công!");
            } else if (maltc != null) {
                jdbc.update("UPDATE LOPTINCHI SET NIENKHOA=?,HOCKY=?,MAMH=?,NHOM=?,MAGV=?,SOSVTOITHIEU=?,SOSVTOIDA=?,HUYLOP=?," +
                            "NGAYBATDAU_DK=?,NGAYKETTHUC_DK=?,NGAYHETHAN_HUY=?,LYDOHUY=? WHERE MALTC=?",
                        nienkhoa.trim(), hocky, mamh.trim(), nhom, magv.trim(), sosvtoithieu, sosvtoida, huylop,
                        dbBatdau, dbKetthuc, dbHethan, lydo, maltc);
                ra.addFlashAttribute("success", "Cập nhật lớp tín chỉ thành công!");
            }
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Lỗi: " + e.getMessage());
        }
        return "redirect:/loptinchi";
    }

    @RequestMapping(value = "/delete", method = RequestMethod.POST)
    public String delete(@RequestParam int maltc,
                         HttpSession session, RedirectAttributes ra) {
        if (!"PGV".equals(session.getAttribute("nhomQuyen"))) {
            return "redirect:/home";
        }
        try {
            connHelper.getJdbcTemplate(session)
                    .update("DELETE FROM LOPTINCHI WHERE MALTC=?", maltc);
            ra.addFlashAttribute("success", "Xóa lớp tín chỉ thành công!");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Không thể xóa: " + e.getMessage());
        }
        return "redirect:/loptinchi";
    }
}
