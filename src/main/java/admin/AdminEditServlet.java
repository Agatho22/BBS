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

@WebServlet("/admin/editBbs")
public class AdminEditServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger logger = LogManager.getLogger(AdminEditServlet.class);

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession();
        String userID = (String) session.getAttribute("userID");

        if (userID == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        try (UserDAO userDAO = new UserDAO()) {
            int adminCheckResult = userDAO.adminCheck(userID);
            if (adminCheckResult == 0) {
                out.println("<script>");
                out.println("alert('권한이 없습니다.');");
                out.println("location.href = 'adminBbs.jsp';");
                out.println("</script>");
                out.close();
                return;
            }
        } catch (Exception e) {
            logger.error("관리자 권한 확인 중 예외 발생", e);
            out.println("<script>");
            out.println("alert('권한 확인 중 오류가 발생했습니다.');");
            out.println("location.href = 'adminBbs.jsp';");
            out.println("</script>");
            out.close();
            return;
        }

        int bbsID;
        try {
            bbsID = Integer.parseInt(request.getParameter("bbsID"));
        } catch (NumberFormatException e) {
            logger.warn("잘못된 bbsID 입력: {}", request.getParameter("bbsID"));
            out.println("<script>");
            out.println("alert('유효하지 않은 글입니다.');");
            out.println("location.href = 'adminBbs.jsp';");
            out.println("</script>");
            out.close();
            return;
        }

        if (bbsID == 0) {
            out.println("<script>");
            out.println("alert('유효하지 않은 글입니다.');");
            out.println("location.href = 'adminBbs.jsp';");
            out.println("</script>");
            out.close();
            return;
        }

        try (BbsDAO bbsDAO = new BbsDAO()) {
            Bbs bbs = bbsDAO.getBbs(bbsID);

            if (bbs == null) {
                out.println("<script>");
                out.println("alert('해당 글을 찾을 수 없습니다.');");
                out.println("location.href = 'adminBbs.jsp';");
                out.println("</script>");
                out.close();
                return;
            }

            request.setAttribute("bbs", bbs);
            request.setAttribute("bbsID", bbsID);
            request.getRequestDispatcher("/adminEditBbs.jsp").forward(request, response);

        } catch (Exception e) {
            logger.error("게시글 조회 중 예외 발생", e);
            out.println("<script>");
            out.println("alert('게시글 조회 중 오류가 발생했습니다.');");
            out.println("location.href = 'adminBbs.jsp';");
            out.println("</script>");
            out.close();
        }
    }
}
