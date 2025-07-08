package bbs;

import user.UserDAO;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/deleteBbs")
public class DeleteBbsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger logger = LogManager.getLogger(DeleteBbsServlet.class);

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        try (PrintWriter out = response.getWriter()) {

            HttpSession session = request.getSession();
            String userID = (String) session.getAttribute("userID");

            if (userID == null) {
                logger.warn("비로그인 상태에서 게시글 삭제 시도");
                out.println("<script>alert('로그인을 하세요.'); location.href='login.jsp';</script>");
                return;
            }

            String bbsIDParam = request.getParameter("bbsID");
            if (bbsIDParam == null || bbsIDParam.trim().isEmpty()) {
                logger.warn("bbsID 파라미터 누락");
                out.println("<script>alert('유효하지 않은 요청입니다.'); location.href='bbs.jsp';</script>");
                return;
            }

            int bbsID;
            try {
                bbsID = Integer.parseInt(bbsIDParam);
            } catch (NumberFormatException e) {
                logger.warn("bbsID 파싱 실패: " + bbsIDParam, e);
                out.println("<script>alert('유효하지 않은 글입니다.'); location.href='bbs.jsp';</script>");
                return;
            }

            UserDAO userDAO = new UserDAO();
            int adminCheckResult = userDAO.adminCheck(userID);
            if (adminCheckResult == 0) {
                logger.warn("비관리자 사용자({})가 글 삭제 시도", userID);
                out.println("<script>alert('권한이 없습니다.'); location.href='adminBbs.jsp';</script>");
                return;
            }

            try (BbsDAO bbsDAO = new BbsDAO()) {
                int result = bbsDAO.delete(bbsID);
                if (result == -1) {
                    logger.error("글 삭제 실패: bbsID={}", bbsID);
                    out.println("<script>alert('글 삭제 실패하였습니다.'); history.back();</script>");
                } else {
                    logger.info("게시글 삭제 완료: bbsID={}, by {}", bbsID, userID);
                    out.println("<script>alert('글 삭제 완료하였습니다.'); location.href='adminBbs.jsp';</script>");
                }
            } catch (RuntimeException e) {
                logger.error("게시글 삭제 중 예외 발생: bbsID=" + bbsID, e);
                out.println("<script>alert('오류가 발생했습니다. 관리자에게 문의하세요.'); history.back();</script>");
            }

        } catch (IOException e) {
            logger.fatal("응답 스트림 처리 중 오류 발생", e);
            throw new ServletException("응답 출력 중 오류 발생", e);
        }
    }
}
