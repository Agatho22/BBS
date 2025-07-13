package user;

import util.HtmlUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/findIDAction")
public class FindIDActionServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String code = request.getParameter("code");

        HttpSession session = request.getSession();
        String sessionCode = (String) session.getAttribute("authCode");

        if (sessionCode == null || !sessionCode.equals(code)) {
            out.println("<script>alert('인증 코드가 일치하지 않습니다.'); history.back();</script>");
            return;
        }

        try (UserDAO userDAO = new UserDAO()) { // try-with-resources 사용
            String userID = userDAO.findUserID(name, email);

            if (userID != null) {
                String safeUserID = HtmlUtil.escapeHtml(userID); // XSS 방지
                out.println("<script>alert('회원님의 아이디는: " + safeUserID + " 입니다.'); location.href='login.jsp';</script>");
            } else {
                out.println("<script>alert('일치하는 회원 정보가 없습니다.'); history.back();</script>");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('오류가 발생했습니다. 나중에 다시 시도해주세요.'); history.back();</script>");
        }
    }
}
