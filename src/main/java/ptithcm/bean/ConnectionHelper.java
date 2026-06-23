package ptithcm.bean;

import javax.servlet.http.HttpSession;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import org.springframework.stereotype.Component;

/**
 * Helper tạo JdbcTemplate dựa trên SQL Server Login
 * lưu trong session, thực thi phân quyền SQL Server.
 */
@Component
public class ConnectionHelper {
    private static final String DRIVER = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
    private static final String URL = "jdbc:sqlserver://localhost;databaseName=QLDSV_HTC;encrypt=false;trustServerCertificate=true";

    /**
     * Tạo JdbcTemplate với SQL Server login tương ứng nhóm quyền user.
     * - PGV  -> login pgv_admin
     * - KHOA -> login của GV phụ trách khoa (tạo qua sp_TaoTaiKhoan)
     * - SV   -> login sv
     * Nếu chưa login, dùng sa (cho trang login).
     */
    public JdbcTemplate getJdbcTemplate(HttpSession session) {
        String login = (String) session.getAttribute("sqlLogin");
        String password = (String) session.getAttribute("sqlPassword");
        if (login == null) {
            login = "sa";
            password = "123456";
        }
        DriverManagerDataSource ds = new DriverManagerDataSource();
        ds.setDriverClassName(DRIVER);
        ds.setUrl(URL);
        ds.setUsername(login);
        ds.setPassword(password);
        return new JdbcTemplate(ds);
    }

    /**
     * Tạo JdbcTemplate mặc định (sa) cho xác thực ban đầu.
     */
    public JdbcTemplate getDefaultJdbcTemplate() {
        DriverManagerDataSource ds = new DriverManagerDataSource();
        ds.setDriverClassName(DRIVER);
        ds.setUrl(URL);
        ds.setUsername("sa");
        ds.setPassword("123456");
        return new JdbcTemplate(ds);
    }
}
