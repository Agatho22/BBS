package admin;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import user.UserDAO;

import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/admin/deleteUser")
public class AdminDeleteUserServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        try (PrintWriter out = response.getWriter()) {

            HttpSession session = request.getSession();
            String sessionToken = (String) session.getAttribute("csrfToken");
            String requestToken = request.getParameter("csrfToken");

            // CSRF 토큰 검증
            if (sessionToken == null || !sessionToken.equals(requestToken)) {
                out.println("<script>alert('잘못된 접근입니다.'); location.href='adminUser.jsp';</script>");
                return;
            }

            String userID = request.getParameter("userID");

            if (userID == null || userID.trim().isEmpty() || "admin".equals(userID)) {
                out.println("<script>alert('유효하지 않은 요청입니다.'); location.href='adminUser.jsp';</script>");
                return;
            }

            try (UserDAO userDAO = new UserDAO()) {
                boolean result = userDAO.deleteUser(userID);
                if (result) {
                    out.println("<script>alert('회원 정보가 삭제되었습니다.'); location.href='adminUser.jsp';</script>");
                } else {
                    out.println("<script>alert('삭제 실패.'); history.back();</script>");
                }
            } catch (Exception e) {
                e.printStackTrace();
                out.println("<script>alert('오류 발생.'); location.href='adminUser.jsp';</script>");
            }

        }
    }

    // GET 요청 -> 리디렉션 처리
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("adminUser.jsp");
    }
}
