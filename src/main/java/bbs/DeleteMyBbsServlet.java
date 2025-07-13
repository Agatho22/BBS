package bbs;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import org.apache.logging.log4j.Logger;
import org.apache.logging.log4j.LogManager;

@WebServlet("/deleteMyBbs")
public class DeleteMyBbsServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger logger = LogManager.getLogger(DeleteMyBbsServlet.class);

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
                out.println("<script>alert('로그인이 필요합니다.'); location.href='login.jsp';</script>");
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
                logger.warn("bbsID 파싱 실패: {}", bbsIDParam, e);
                out.println("<script>alert('유효하지 않은 글입니다.'); location.href='bbs.jsp';</script>");
                return;
            }

            try (BbsDAO bbsDAO = new BbsDAO()) {
                Bbs bbs = bbsDAO.getBbs(bbsID);
                if (bbs == null) {
                    logger.warn("존재하지 않는 글 요청: bbsID={}", bbsID);
                    out.println("<script>alert('존재하지 않는 글입니다.'); location.href='bbs.jsp';</script>");
                    return;
                }

                // 본인 글인지 확인
                if (!userID.equals(bbs.getUserID())) {
                    logger.warn("본인이 작성하지 않은 글 삭제 시도: userID={}, 글 작성자={}", userID, bbs.getUserID());
                    out.println("<script>alert('자신의 글만 삭제할 수 있습니다.'); location.href='bbs.jsp';</script>");
                    return;
                }

                int result = bbsDAO.delete(bbsID);
                if (result == -1) {
                    logger.error("글 삭제 실패: bbsID={}", bbsID);
                    out.println("<script>alert('글 삭제에 실패했습니다.'); history.back();</script>");
                } else {
                    logger.info("사용자 게시글 삭제 성공: bbsID={}, by {}", bbsID, userID);
                    out.println("<script>alert('게시글이 삭제되었습니다.'); location.href='bbs.jsp';</script>");
                }
            }

        } catch (Exception e) {
            logger.fatal("예외 발생", e);
            throw new ServletException("글 삭제 중 오류 발생", e);
        }
    }
}
