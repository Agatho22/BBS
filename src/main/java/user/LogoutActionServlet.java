package user;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/logoutAction")
public class LogoutActionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 세션 무효화
        HttpSession session = request.getSession(false); // 이미 있는 세션만 반환
        if (session != null) {
            session.invalidate();
        }

        // 메인 페이지로 리디렉션
        response.sendRedirect("main.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response); // POST 요청도 동일하게 처리
    }
}
