package user;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

@WebServlet("/loginAction")
public class LoginActionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger logger = LogManager.getLogger(LoginActionServlet.class);

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        try (PrintWriter out = response.getWriter()) {
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

                if (userDAO.isAccountLocked(userID)) {
                    logger.warn("계정 잠금 상태 로그인 시도: {}", userID);
                    out.println("<script>alert('로그인 3회 실패로 계정이 15분간 잠겼습니다.'); history.back();</script>");
                    return;
                }

                int result = userDAO.login(userID, userPassword);

                switch (result) {
                    case 1:
                        userDAO.resetFailCount(userID);
                        int isAdmin = userDAO.adminCheck(userID);

                        if (isAdmin == 1) {
                            session.setAttribute("pendingAdmin", userID);
                            session.removeAttribute("userID");
                            out.println("<script>location.href = 'registerOtp';</script>");
                        } else {
                            session.setAttribute("userID", userID);
                            out.println("<script>location.href = 'main.jsp';</script>");
                        }
                        break;

                    case 0:
                        userDAO.increaseFailCount(userID);
                        logger.info("비밀번호 틀림: {}", userID);
                        out.println("<script>alert('비밀번호가 틀렸습니다.'); history.back();</script>");
                        break;

                    case -1:
                        logger.info("존재하지 않는 ID로 로그인 시도: {}", userID);
                        out.println("<script>alert('존재하지 않는 아이디입니다.'); history.back();</script>");
                        break;

                    default:
                        logger.error("비정상적인 로그인 결과 발생. userID={}, result={}", userID, result);
                        out.println("<script>alert('알 수 없는 오류가 발생했습니다.'); history.back();</script>");
                        break;
                }

            } catch (Exception e) {
                logger.error("로그인 처리 중 예외 발생: {}", e.getMessage(), e);
                out.println("<script>alert('서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.'); history.back();</script>");
            }

        } catch (IOException e) {
            logger.fatal("응답 스트림 처리 중 오류 발생", e);
            throw new ServletException("응답 출력 중 오류 발생", e);
        }
    }
}
