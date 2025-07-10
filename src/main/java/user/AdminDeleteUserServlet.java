package user;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

@WebServlet("/adminDeleteAction")
public class AdminDeleteUserServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger logger = LogManager.getLogger(AdminDeleteUserServlet.class);

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        String userID = request.getParameter("userID");

        try (PrintWriter out = response.getWriter()) {

            if (userID == null || userID.trim().isEmpty()) {
                logger.warn("삭제 요청 실패: 유효하지 않은 userID");
                out.println("<script>alert('유효하지 않은 요청입니다.'); history.back();</script>");
                return;
            }

            try (UserDAO userDAO = new UserDAO()) {
                boolean result = userDAO.deleteUser(userID);

                if (result) {
                    logger.info("사용자 삭제 성공: {}", userID);
                    out.println("<script>alert('회원님의 정보가 성공적으로 삭제되었습니다.'); location.href = 'adminUser.jsp';</script>");
                } else {
                    logger.warn("사용자 삭제 실패: DB에서 삭제 실패 또는 존재하지 않음 - userID: {}", userID);
                    out.println("<script>alert('정보 삭제에 실패했습니다.'); history.back();</script>");
                }

            } catch (Exception e) {
                logger.error("사용자 삭제 처리 중 DB 오류 발생", e);
                out.println("<script>alert('서버 오류로 삭제에 실패했습니다.'); history.back();</script>");
            }

        } catch (IOException e) {
            logger.fatal("응답 출력 스트림 오류", e);
            throw new ServletException("응답 처리 중 예외 발생", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("adminUser.jsp");
    }
}
