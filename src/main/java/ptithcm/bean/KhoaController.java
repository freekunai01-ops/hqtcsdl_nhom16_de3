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

@Controller
@RequestMapping("/khoa")
public class KhoaController {

    @Autowired
    private ConnectionHelper connHelper;

    @RequestMapping(method = RequestMethod.GET)
    public String show(@RequestParam(value = "makhoa", required = false) String makhoa,
                       HttpSession session, ModelMap model) {
        String nhomQuyen = (String) session.getAttribute("nhomQuyen");
        if (!"PGV".equals(nhomQuyen) && !"KHOA".equals(nhomQuyen)) {
            return "redirect:/home";
        }
        
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        // sp_DsKhoa trả về MAKHOA, TENKHOA, LOP_COUNT, GV_COUNT
        List<Map<String, Object>> khoaList = jdbc.queryForList("EXEC sp_DsKhoa");

        model.addAttribute("khoaList", khoaList);
        model.addAttribute("totalKhoa", khoaList.size());
        model.addAttribute("selectedMakhoa", makhoa != null ? makhoa.trim() : "");
        return "khoa";
    }

    @RequestMapping(value = "/save", method = RequestMethod.POST)
    public String save(@RequestParam("action") String action,
                       @RequestParam("makhoa") String makhoa,
                       @RequestParam("tenkhoa") String tenkhoa,
                       HttpSession session, RedirectAttributes ra) {
        if (!"PGV".equals(session.getAttribute("nhomQuyen"))) {
            return "redirect:/home";
        }
        if (makhoa == null || makhoa.trim().isEmpty()) {
            ra.addFlashAttribute("error", "Mã khoa không được bỏ trống!");
            return "redirect:/khoa";
        }

        ra.addFlashAttribute("failedAction", action);
        ra.addFlashAttribute("failedMakhoa", makhoa);
        ra.addFlashAttribute("failedTenkhoa", tenkhoa);

        if (tenkhoa == null || tenkhoa.trim().isEmpty()) {
            ra.addFlashAttribute("error", "Tên khoa không được bỏ trống!");
            return "redirect:/khoa?makhoa=" + makhoa.trim();
        }

        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        try {
            if ("add".equals(action)) {
                jdbc.update("EXEC sp_ThemKhoa ?, ?", makhoa.trim(), tenkhoa.trim());
                ra.addFlashAttribute("success", "Thêm khoa thành công!");
            } else {
                jdbc.update("EXEC sp_SuaKhoa ?, ?", makhoa.trim(), tenkhoa.trim());
                ra.addFlashAttribute("success", "Cập nhật khoa thành công!");
            }
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Lỗi: " + e.getMessage());
            return "redirect:/khoa?makhoa=" + makhoa.trim();
        }
        return "redirect:/khoa?makhoa=" + makhoa.trim();
    }

    @RequestMapping(value = "/delete", method = RequestMethod.POST)
    public String delete(@RequestParam("makhoa") String makhoa,
                         @RequestParam(value = "nextMakhoa", required = false) String nextMakhoa,
                         HttpSession session, RedirectAttributes ra) {
        if (!"PGV".equals(session.getAttribute("nhomQuyen"))) {
            return "redirect:/home";
        }
        JdbcTemplate jdbc = connHelper.getJdbcTemplate(session);
        try {
            jdbc.update("EXEC sp_XoaKhoa ?", makhoa.trim());
            ra.addFlashAttribute("success", "Xóa khoa thành công!");
        } catch (Exception e) {
            ra.addFlashAttribute("error", "Lỗi: " + e.getMessage());
            return "redirect:/khoa?makhoa=" + makhoa.trim();
        }
        return "redirect:/khoa" + (nextMakhoa != null && !nextMakhoa.trim().isEmpty() ? "?makhoa=" + nextMakhoa.trim() : "");
    }
}
