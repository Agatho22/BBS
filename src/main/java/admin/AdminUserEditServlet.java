package admin;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import user.User;
import user.UserDAO;

/**
 * 관리자 사용자 정보 수정 페이지 요청 처리 서블릿
 */
@WebServlet("/adminUserEditServlet")
public class AdminUserEditServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger logger = LogManager.getLogger(AdminUserEditServlet.class);

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String loginUserID = (String) request.getSession().getAttribute("userID");
        if (loginUserID == null || !"admin".equals(loginUserID)) {
            response.sendRedirect("main.jsp");
            return;
        }

        String oldUserID = request.getParameter("oldUserID");

        try (UserDAO dao = new UserDAO()) {
            if (oldUserID == null || oldUserID.trim().isEmpty()) {
                throw new IllegalArgumentException("유효하지 않은 사용자 ID입니다.");
            }

            User user = dao.getUserByID(oldUserID);
            if (user == null) {
                throw new IllegalStateException("사용자 정보를 찾을 수 없습니다.");
            }

            request.setAttribute("user", user);
            request.getRequestDispatcher("adminUpdate.jsp").forward(request, response);

        } catch (IllegalArgumentException | IllegalStateException e) {
            logger.warn("입력값 오류 또는 사용자 없음: {}", e.getMessage());
            response.sendRedirect("adminUserUpdate.jsp?error=" + URLEncoder.encode(e.getMessage(), "UTF-8"));
        } catch (Exception e) {
            logger.error("사용자 정보 조회 중 시스템 예외 발생", e);
            response.sendRedirect("adminUserUpdate.jsp?error=" + URLEncoder.encode("시스템 오류가 발생했습니다.", "UTF-8"));
        }
    }
}
