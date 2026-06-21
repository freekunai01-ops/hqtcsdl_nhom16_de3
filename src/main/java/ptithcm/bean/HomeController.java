package ptithcm.bean;

import java.util.List;
import java.util.Map;
import javax.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.*;

@Controller
public class HomeController {

    @Autowired
    private ConnectionHelper connHelper;

    @RequestMapping(value = {"/", "/home"})
    public String home(HttpSession session, ModelMap model) {
        if (session.getAttribute("nhomQuyen") == null) {
            return "redirect:/login";
        }
        String nhomQuyen = (String) session.getAttribute("nhomQuyen");
        if ("PGV".equals(nhomQuyen) || "KHOA".equals(nhomQuyen)) {
            try {
                List<Map<String, Object>> khoaList = connHelper.getJdbcTemplate(session)
                        .queryForList("SELECT RTRIM(MAKHOA) AS MAKHOA, TENKHOA FROM KHOA ORDER BY MAKHOA");
                session.setAttribute("khoaList", khoaList);
            } catch (Exception e) {
                // ignore
            }
        }

        // Lấy tên khoa hiện tại
        String maKhoa = (String) session.getAttribute("maKhoa");
        if (maKhoa != null) {
            try {
                String tenKhoa = connHelper.getJdbcTemplate(session).queryForObject(
                        "SELECT TENKHOA FROM KHOA WHERE MAKHOA = ?", String.class, maKhoa.trim());
                model.addAttribute("tenKhoa", tenKhoa);
            } catch (Exception e) {
                model.addAttribute("tenKhoa", maKhoa);
            }
        }
        return "home";
    }

    @RequestMapping(value = "/change-khoa", method = RequestMethod.POST)
    public String changeKhoa(@RequestParam("maKhoa") String maKhoa, HttpSession session, javax.servlet.http.HttpServletRequest request) {
        session.setAttribute("maKhoa", maKhoa.trim());
        String referer = request.getHeader("Referer");
        if (referer != null && !referer.isEmpty()) {
            return "redirect:" + referer;
        }
        return "redirect:/home";
    }
}
