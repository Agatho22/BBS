package admin;

import user.UserDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

@WebServlet("/adminResetPassword")
public class AdminResetPasswordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String TEMP_PASSWORD = "temp1234";
    private static final Logger logger = LogManager.getLogger(AdminResetPasswordServlet.class);


    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession();
        PrintWriter out = response.getWriter();

        String sessionToken = (String) session.getAttribute("csrfToken");
        String requestToken = request.getParameter("csrfToken");
        String userID = request.getParameter("userID");

        if (sessionToken == null || !sessionToken.equals(requestToken)) {
            out.println("<script>alert('잘못된 요청입니다.'); location.href='adminUser.jsp';</script>");
            return;
        }

        if (userID == null || userID.trim().isEmpty() || "admin".equalsIgnoreCase(userID.trim())) {
            out.println("<script>alert('유효하지 않은 사용자 ID입니다.'); location.href='adminUser.jsp';</script>");
            return;
        }

        try (UserDAO userDAO = new UserDAO()) {
            int result = userDAO.updatePassword(userID.trim(), TEMP_PASSWORD);
            if (result > 0) {
                out.println("<script>alert('비밀번호가 초기화되었습니다.'); location.href='adminUser.jsp';</script>");
            } else {
                out.println("<script>alert('초기화 실패: 존재하지 않는 사용자이거나 처리 중 오류가 발생했습니다.'); location.href='adminUser.jsp';</script>");
            }
        } catch (IllegalArgumentException e) {
            logger.warn("잘못된 요청 파라미터: {}", e.getMessage());
            out.println("<script>alert('잘못된 입력입니다: " + e.getMessage() + "'); location.href='adminUser.jsp';</script>");
        } catch (RuntimeException e) {
            logger.error("서버 내부 오류 발생", e);
            out.println("<script>alert('서버 내부 오류가 발생했습니다. 관리자에게 문의하세요.'); location.href='adminUser.jsp';</script>");
        } catch (Exception e) {
            logger.fatal("예기치 못한 오류", e);
            out.println("<script>alert('알 수 없는 오류가 발생했습니다.'); location.href='adminUser.jsp';</script>");
        }
    }
}
