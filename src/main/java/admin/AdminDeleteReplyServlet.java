package admin;

import reply.ReplyDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/adminDeleteReply")
public class AdminDeleteReplyServlet extends HttpServlet {
    private static final long serialVersionUID = 1L; // 경고 제거

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String replyIDParam = request.getParameter("replyID");
        String bbsIDParam = request.getParameter("bbsID");

        try {
            int replyID = Integer.parseInt(replyIDParam);
            int bbsID = Integer.parseInt(bbsIDParam);

            try (ReplyDAO replyDAO = new ReplyDAO()) {
                replyDAO.delete(replyID);
            }

            response.sendRedirect("adminView.jsp?bbsID=" + bbsID);
        } catch (Exception e) {
            request.setAttribute("msg", "댓글 삭제에 실패했습니다.");
            request.setAttribute("redirect", "adminBbs.jsp");
            request.getRequestDispatcher("error.jsp").forward(request, response);
        }
    }
}
