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

/**
 * Quản trị tài khoản - PGV only
 */
@Controller
@RequestMapping("/taikhoan")
public class TaiKhoanController {

    @Autowired
    private ConnectionHelper connHelper;

    @RequestMapping(method = RequestMethod.GET)
    public String show(@RequestParam(value = "login", required = false) String login,
                       HttpSession session, ModelMap model) {
        String nhomQuyen = (String) session.getAttribute("nhomQuyen");
        if (!"PGV".equals(nhomQuyen) && !"KHOA".equals(nhomQuyen)) {
            return "redirect:/home";
        }
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);

        // Fetch accounts including both Lecturers and Students with their status
        List<Map<String, Object>> dsTaiKhoan = jdbc.queryForList("EXEC sp_DanhSachTaiKhoan");
        model.addAttribute("dsTaiKhoan", dsTaiKhoan);

        // Fetch all lecturers
        List<Map<String, Object>> dsgv = jdbc.queryForList(
                "SELECT MAGV, HO + ' ' + TEN AS HOTEN, MAKHOA FROM GIANGVIEN ORDER BY TEN, HO");
        model.addAttribute("dsgv", dsgv);

        // Fetch all active students
        List<Map<String, Object>> dssv = jdbc.queryForList(
                "SELECT S.MASV, S.HO + ' ' + S.TEN AS HOTEN, L.MAKHOA, S.MALOP " +
                "FROM SINHVIEN S JOIN LOP L ON S.MALOP = L.MALOP " +
                "WHERE S.DANGHIHOC = 0 ORDER BY S.TEN, S.HO");
        model.addAttribute("dssv", dssv);
        
        List<Map<String, Object>> khoaList = jdbc.queryForList("SELECT RTRIM(MAKHOA) AS MAKHOA, TENKHOA FROM KHOA ORDER BY MAKHOA");
        model.addAttribute("khoaList", khoaList);
        model.addAttribute("selectedLogin", login != null ? login.trim() : "");
        return "taikhoan";
    }

    @RequestMapping(value = "/save", method = RequestMethod.POST)
    public String save(@RequestParam(required = false) String magv,
                       @RequestParam(required = false) String masv,
                       @RequestParam String login,
                       @RequestParam String matkhau,
                       @RequestParam String nhomQuyen,
                       @RequestParam(required = false) String maKhoa,
                       @RequestParam(required = false, defaultValue = "Active") String trangthai,
                       HttpSession session, RedirectAttributes ra) {
        String sessionQuyen = (String) session.getAttribute("nhomQuyen");
        if (!"PGV".equals(sessionQuyen) && !"KHOA".equals(sessionQuyen)) {
            return "redirect:/home";
        }
        if ("KHOA".equals(sessionQuyen) && "PGV".equals(nhomQuyen.trim())) {
            ra.addFlashAttribute("error", "Khoa không được cấp tài khoản nhóm PGV!");
            return "redirect:/taikhoan";
        }
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        
        // If role is SV, the username is student's MASV
        String linkedUser = magv;
        if ("SV".equals(nhomQuyen.trim())) {
            linkedUser = masv;
        }
        
        try {
            // Check for default system accounts (which don't have a linked user)
            if (linkedUser == null || linkedUser.trim().isEmpty()) {
                if (matkhau != null && !matkhau.trim().isEmpty()) {
                    try {
                        jdbc.execute("ALTER LOGIN [" + login.trim() + "] WITH PASSWORD = '" + matkhau.replace("'", "''") + "'");
                    } catch (Exception ex) {}
                }
                syncLoginStatus(jdbc, login.trim(), trangthai);
                ra.addFlashAttribute("success", "Cập nhật tài khoản hệ thống thành công!");
                return "redirect:/taikhoan?login=" + login.trim();
            }

            Long count = jdbc.queryForObject(
                "SELECT COUNT(*) FROM sys.database_principals WHERE name = ?",
                Long.class, linkedUser.trim());
            if (count == 0) {
                // Using stored procedure sp_TaoTaiKhoan
                // Map "SV" -> "NHOM_SV" database role, otherwise use the role directly
                String dbRole = "SV".equals(nhomQuyen.trim()) ? "NHOM_SV" : nhomQuyen.trim();
                jdbc.update("EXEC sp_TaoTaiKhoan ?, ?, ?, ?", 
                        login.trim(), matkhau, linkedUser.trim(), dbRole);
                syncLoginStatus(jdbc, login.trim(), trangthai);
                ra.addFlashAttribute("success", "Tạo tài khoản và phân quyền SQL Server thành công!");
            } else {
                // Get old login name
                String oldLogin = "";
                try {
                    oldLogin = jdbc.queryForObject(
                        "SELECT sp.name FROM sys.server_principals sp " +
                        "JOIN sys.database_principals dp ON sp.sid = dp.sid " +
                        "WHERE dp.name = ?",
                        String.class, linkedUser.trim()).trim();
                } catch (Exception e) {}

                // Cập nhật database role nếu thay đổi
                String dbRole = "SV".equals(nhomQuyen.trim()) ? "NHOM_SV" : nhomQuyen.trim();
                try {
                    String oldRole = jdbc.queryForObject(
                        "SELECT r.name FROM sys.database_role_members rm " +
                        "JOIN sys.database_principals r ON rm.role_principal_id = r.principal_id " +
                        "JOIN sys.database_principals m ON rm.member_principal_id = m.principal_id " +
                        "WHERE m.name = ?", String.class, linkedUser.trim());
                    if (oldRole != null && !oldRole.trim().equalsIgnoreCase(dbRole)) {
                        jdbc.execute("ALTER ROLE [" + oldRole + "] DROP MEMBER [" + linkedUser.trim() + "]");
                        jdbc.execute("ALTER ROLE [" + dbRole + "] ADD MEMBER [" + linkedUser.trim() + "]");
                    }
                } catch (Exception ex) {}
                
                // Sync SQL Login Password and Status
                if (!oldLogin.isEmpty()) {
                    if (matkhau != null && !matkhau.trim().isEmpty()) {
                        try {
                            jdbc.execute("ALTER LOGIN [" + oldLogin + "] WITH PASSWORD = '" + matkhau.replace("'", "''") + "'");
                        } catch (Exception ex) {}
                    }
                    syncLoginStatus(jdbc, oldLogin, trangthai);
                }
                ra.addFlashAttribute("success", "Cập nhật tài khoản thành công!");
            }
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Lỗi: " + e.getMessage());
        }
        return "redirect:/taikhoan?login=" + login.trim();
    }

    @RequestMapping(value = "/delete", method = RequestMethod.POST)
    public String delete(@RequestParam(required = false) String magv,
                          @RequestParam(required = false) String login,
                          HttpSession session, RedirectAttributes ra) {
        String sessionQuyen = (String) session.getAttribute("nhomQuyen");
        if (!"PGV".equals(sessionQuyen) && !"KHOA".equals(sessionQuyen)) {
            return "redirect:/home";
        }
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        
        String loginName = (login != null) ? login.trim() : "";
        String mGV = (magv != null) ? magv.trim() : "";
        
        if (mGV.isEmpty() && !loginName.isEmpty()) {
            try {
                mGV = jdbc.queryForObject(
                    "SELECT dp.name FROM sys.server_principals sp " +
                    "JOIN sys.database_principals dp ON sp.sid = dp.sid " +
                    "WHERE sp.name = ?",
                    String.class, loginName);
            } catch (Exception e) {}
        }
        if (loginName.isEmpty() && !mGV.isEmpty()) {
            try {
                loginName = jdbc.queryForObject(
                    "SELECT sp.name FROM sys.server_principals sp " +
                    "JOIN sys.database_principals dp ON sp.sid = dp.sid " +
                    "WHERE dp.name = ?",
                    String.class, mGV);
            } catch (Exception e) {}
        }

        if (loginName.equalsIgnoreCase("pgv_admin") || loginName.equalsIgnoreCase("admin") || loginName.equalsIgnoreCase("sv") || loginName.equalsIgnoreCase("khoa_all")) {
            ra.addFlashAttribute("error", "Không được xóa tài khoản hệ thống mặc định!");
            return "redirect:/taikhoan";
        }

        try {
            // Clean up SQL Login & Database User
            if (!loginName.isEmpty()) {
                try {
                    jdbc.execute("DROP LOGIN [" + loginName + "]");
                } catch (Exception e) {}
            }
            if (!mGV.isEmpty()) {
                try {
                    jdbc.execute("DROP USER [" + mGV + "]");
                } catch (Exception e) {}
            }

            ra.addFlashAttribute("success", "Xóa tài khoản thành công!");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Không thể xóa: " + e.getMessage());
        }
        return "redirect:/taikhoan";
    }

    private void syncLoginStatus(JdbcTemplate jdbc, String login, String trangthai) {
        try {
            if ("Locked".equalsIgnoreCase(trangthai)) {
                jdbc.execute("ALTER LOGIN [" + login + "] DISABLE");
            } else {
                jdbc.execute("ALTER LOGIN [" + login + "] ENABLE");
            }
        } catch (Exception e) {
            // Ignore if login cannot be enabled/disabled directly (e.g. built-in sa or system accounts)
        }
    }
}

// Trigger Eclipse WTP compilation at 1781996258.6082752
