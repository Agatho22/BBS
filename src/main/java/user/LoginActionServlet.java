package user;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/loginAction")
public class LoginActionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession();
        String sessionUserID = (String) session.getAttribute("userID");
        if (sessionUserID != null) {
            out.println("<script>alert('이미 로그인 되어 있습니다.'); location.href = 'main.jsp';</script>");
            return;
        }

        String userID = request.getParameter("userID");
        String userPassword = request.getParameter("userPassword");

        if (userID == null || userPassword == null || userID.trim().isEmpty() || userPassword.trim().isEmpty()) {
            out.println("<script>alert('아이디와 비밀번호를 입력해주세요.'); history.back();</script>");
            return;
        }

        try (UserDAO userDAO = new UserDAO()) {

            // 계정 비활성화 여부 확인 (선택)
            if (userDAO.isDeactivated(userID)) {
                out.println("<script>alert('비활성화된 계정입니다.'); history.back();</script>");
                return;
            }

            // 계정 잠금 여부 확인
            if (userDAO.isAccountLocked(userID)) {
                out.println("<script>alert('로그인 3회 실패로 계정이 15분간 잠겼습니다.'); history.back();</script>");
                return;
            }

            int result = userDAO.login(userID, userPassword);

            if (result == 1) {
                userDAO.resetFailCount(userID); // 로그인 성공 시 카운트 초기화

                // 세션 고정 공격 방지
                session.invalidate(); // 기존 세션 무효화
                session = request.getSession(true); // 새로운 세션 생성

                int isAdmin = userDAO.adminCheck(userID);

                if (isAdmin == 1) {
                    session.setAttribute("pendingAdmin", userID);
                    out.println("<script>location.href = 'registerOtp';</script>");
                } else {
                    session.setAttribute("userID", userID);
                    out.println("<script>location.href = 'main.jsp';</script>");
                }

            } else if (result == 0) {
                userDAO.increaseFailCount(userID);
                out.println("<script>alert('비밀번호가 틀렸습니다.'); history.back();</script>");
            } else if (result == -1) {
                out.println("<script>alert('존재하지 않는 아이디입니다.'); history.back();</script>");
            } else {
                out.println("<script>alert('알 수 없는 오류가 발생했습니다.'); history.back();</script>");
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>alert('서버 오류가 발생했습니다.'); history.back();</script>");
        }
    }
}

