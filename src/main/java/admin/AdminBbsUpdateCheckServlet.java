package admin;

import bbs.Bbs;
import bbs.BbsDAO;
import user.UserDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

@WebServlet("/adminBbsUpdateCheck")
public class AdminBbsUpdateCheckServlet extends HttpServlet {
	private static final long serialVersionUID = 1L; // 경고 제거
	private static final Logger logger = LogManager.getLogger(AdminBbsUpdateCheckServlet.class);

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        HttpSession session = request.getSession();
        String userID = (String) session.getAttribute("userID");

        if (userID == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // 관리자 권한 확인
        try (UserDAO userDAO = new UserDAO()) {
            if (userDAO.adminCheck(userID) == 0) {
                alertAndRedirect(response, "권한이 없습니다.", "adminBbs.jsp");
                return;
            }
        } catch (Exception e) {
            logger.error("관리자 권한 확인 중 예외 발생", e);
            alertAndRedirect(response, "시스템 오류가 발생했습니다.", "adminBbs.jsp");
            return;
        }

        // bbsID 파라미터 검증
        String bbsIDParam = request.getParameter("bbsID");
        int bbsID;

        if (bbsIDParam == null) {
            logger.warn("bbsID 파라미터 누락");
            alertAndRedirect(response, "잘못된 요청입니다.", "adminBbs.jsp");
            return;
        }

        try {
            bbsID = Integer.parseInt(bbsIDParam);
            if (bbsID <= 0) throw new NumberFormatException();
        } catch (NumberFormatException e) {
            logger.warn("잘못된 bbsID 요청: " + bbsIDParam);
            alertAndRedirect(response, "유효하지 않은 글입니다.", "adminBbs.jsp");
            return;
        }

        // 게시글 조회
        try (BbsDAO bbsDAO = new BbsDAO()) {
            Bbs bbs = bbsDAO.getBbs(bbsID);
            if (bbs == null) {
                logger.info("존재하지 않는 게시글 요청: bbsID=" + bbsID);
                alertAndRedirect(response, "해당 글을 찾을 수 없습니다.", "adminBbs.jsp");
                return;
            }

            // 게시글 정보를 JSP에 전달
            request.setAttribute("bbs", bbs);
            request.setAttribute("bbsID", bbsID);
            request.getRequestDispatcher("adminBbsUpdate.jsp").forward(request, response);

        } catch (Exception e) {
            logger.error("게시글 조회 중 예외 발생", e);
            alertAndRedirect(response, "글 조회 중 오류가 발생했습니다.", "adminBbs.jsp");
        }
    }

    private void alertAndRedirect(HttpServletResponse response, String message, String location) throws IOException {
        PrintWriter out = response.getWriter();
        out.println("<script>alert('" + message + "'); location.href='" + location + "';</script>");
    }
}
