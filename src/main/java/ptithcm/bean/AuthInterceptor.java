package ptithcm.bean;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

/**
 * Interceptor kiểm tra đăng nhập.
 * Chặn tất cả request trừ /login, /css, /js, /images.
 */
public class AuthInterceptor extends HandlerInterceptorAdapter {

    @Override
    public boolean preHandle(HttpServletRequest request,
                             HttpServletResponse response,
                             Object handler) throws Exception {
        String uri = request.getRequestURI();
        String ctx = request.getContextPath();

        // Cho phép truy cập trang login và static resources
        if (uri.equals(ctx + "/login") || uri.equals(ctx + "/")
                || uri.startsWith(ctx + "/css/")
                || uri.startsWith(ctx + "/js/")
                || uri.startsWith(ctx + "/images/")) {
            return true;
        }

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("nhomQuyen") == null) {
            response.sendRedirect(ctx + "/login");
            return false;
        }
        return true;
    }
}
