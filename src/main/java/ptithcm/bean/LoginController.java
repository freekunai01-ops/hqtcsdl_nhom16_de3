package ptithcm.bean;

import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.*;

@Controller
public class LoginController {

    private static final String DRIVER = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
    private static final String URL = "jdbc:sqlserver://localhost;databaseName=QLDSV_HTC;encrypt=false;trustServerCertificate=true";

    @Autowired
    private ConnectionHelper connHelper;

    @RequestMapping(value = "/login", method = RequestMethod.GET)
    public String showLogin() {
        return "login";
    }

    @RequestMapping(value = "/login", method = RequestMethod.POST)
    public String doLogin(@RequestParam String loginType,
                          @RequestParam String username,
                          @RequestParam(required = false) String password,
                          @RequestParam(required = false) String selectedRole,
                          HttpSession session,
                          ModelMap model) {
        try {
            if ("SV".equals(loginType)) {
                // === SINH VIÊN: Dùng chung SQL Login 'sv' để kết nối ===
                DriverManagerDataSource ds = new DriverManagerDataSource();
                ds.setDriverClassName(DRIVER);
                ds.setUrl(URL);
                ds.setUsername("sv");
                ds.setPassword("sv123");
                JdbcTemplate userJdbc = new JdbcTemplate(ds);

                // Kiểm tra mã sinh viên và mật khẩu trong bảng SINHVIEN
                String sql = "SELECT MASV, HO, TEN, MALOP, PASSWORD FROM SINHVIEN " +
                             "WHERE MASV = ? AND DANGHIHOC = 0";
                List<Map<String, Object>> rows = userJdbc.queryForList(sql, username.trim());
                if (rows.isEmpty()) {
                    model.addAttribute("loginType", loginType);
                    model.addAttribute("username", username);
                    model.addAttribute("error", "Mã sinh viên không tồn tại hoặc đã nghỉ học!");
                    return "login";
                }
                
                Map<String, Object> sv = rows.get(0);
                String dbPassword = sv.get("PASSWORD") != null ? sv.get("PASSWORD").toString().trim() : "";
                if (!dbPassword.equals(password)) {
                    model.addAttribute("loginType", loginType);
                    model.addAttribute("username", username);
                    model.addAttribute("error", "Mật khẩu sinh viên không đúng!");
                    return "login";
                }

                String masv = sv.get("MASV").toString().trim();
                String ho = sv.get("HO").toString().trim();
                String ten = sv.get("TEN").toString().trim();
                String malop = sv.get("MALOP").toString().trim();

                // Lấy mã khoa từ lớp
                String maKhoa = userJdbc.queryForObject(
                        "SELECT MAKHOA FROM LOP WHERE MALOP = ?",
                        String.class, malop).trim();

                session.setAttribute("nhomQuyen", "SV");
                session.setAttribute("masv", masv);
                session.setAttribute("hoTen", ho + " " + ten);
                session.setAttribute("displayName", ho + " " + ten);
                session.setAttribute("maKhoa", maKhoa);
                session.setAttribute("maLop", malop);
                session.setAttribute("sqlLogin", "sv");
                session.setAttribute("sqlPassword", "sv123");

            } else {
                // === GIẢNG VIÊN / PGV / KHOA: Đăng nhập trực tiếp bằng SQL Server Login ===
                DriverManagerDataSource ds = new DriverManagerDataSource();
                ds.setDriverClassName(DRIVER);
                ds.setUrl(URL);
                ds.setUsername(username.trim());
                ds.setPassword(password);
                JdbcTemplate userJdbc = new JdbcTemplate(ds);

                // Gọi stored procedure sp_ThongTinDangNhap để lấy thông tin user
                List<Map<String, Object>> results;
                try {
                    results = userJdbc.queryForList("EXEC sp_ThongTinDangNhap ?", username.trim());
                } catch (Exception e) {
                    model.addAttribute("loginType", loginType);
                    model.addAttribute("username", username);
                    model.addAttribute("selectedRole", selectedRole);
                    model.addAttribute("error", "Tên đăng nhập hoặc mật khẩu SQL Server không đúng!");
                    return "login";
                }

                if (results.isEmpty()) {
                    model.addAttribute("loginType", loginType);
                    model.addAttribute("username", username);
                    model.addAttribute("selectedRole", selectedRole);
                    model.addAttribute("error", "Tài khoản không tồn tại trên hệ thống!");
                    return "login";
                }

                Map<String, Object> info = results.get(0);
                String userId = info.get("USERNAME").toString().trim();
                String hoTen = info.get("HOTEN").toString().trim();
                String nhomQuyen = info.get("ROLENAME").toString().trim();

                // Kiểm tra xem nhóm quyền được chọn ở giao diện có khớp với phân quyền thực tế trong CSDL không
                if (selectedRole != null && !selectedRole.trim().isEmpty() && !selectedRole.equals(nhomQuyen)) {
                    model.addAttribute("loginType", loginType);
                    model.addAttribute("username", username);
                    model.addAttribute("selectedRole", selectedRole);
                    model.addAttribute("error", "Nhóm quyền chọn đăng nhập không khớp với phân quyền của tài khoản!");
                    return "login";
                }

                session.setAttribute("nhomQuyen", nhomQuyen);
                session.setAttribute("displayName", hoTen);
                session.setAttribute("loginName", username.trim());
                session.setAttribute("sqlLogin", username.trim());
                session.setAttribute("sqlPassword", password);

                // Xác định mã khoa (maKhoa) dựa trên quyền
                String maKhoa = "";
                if ("PGV".equals(nhomQuyen) || "KHOA".equals(nhomQuyen)) {
                    List<Map<String, Object>> khoaList = userJdbc.queryForList(
                            "SELECT RTRIM(MAKHOA) AS MAKHOA, TENKHOA FROM KHOA ORDER BY MAKHOA");
                    session.setAttribute("khoaList", khoaList);
                }

                if ("PGV".equals(nhomQuyen)) {
                    maKhoa = "ALL";
                } else if ("KHOA".equals(nhomQuyen)) {
                    try {
                        String mk = userJdbc.queryForObject(
                                "SELECT RTRIM(MAKHOA) FROM GIANGVIEN WHERE MAGV = ?",
                                String.class, userId);
                        maKhoa = (mk != null && !mk.trim().isEmpty()) ? mk.trim() : "ALL";
                    } catch (Exception e) {
                        maKhoa = "ALL";
                    }
                }
                session.setAttribute("maKhoa", maKhoa);
            }
            return "redirect:/home";
        } catch (Exception e) {
            model.addAttribute("loginType", loginType);
            model.addAttribute("username", username);
            model.addAttribute("selectedRole", selectedRole);
            model.addAttribute("error", "Lỗi đăng nhập: " + e.getMessage());
            return "login";
        }
    }

    @RequestMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/login";
    }
}
