package reply;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/writeReply")
public class WriteReplyServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession();
        String userID = (String) session.getAttribute("userID");

        String replyContent = request.getParameter("replyContent");
        String bbsIDParam = request.getParameter("bbsID");
        int bbsID = 0;

        try {
            bbsID = Integer.parseInt(bbsIDParam);
        } catch (NumberFormatException e) {
            response.sendRedirect("bbs.jsp");
            return;
        }

        // 로그인 및 입력 체크
        if (userID == null || replyContent == null || replyContent.trim().isEmpty()) {
            try (PrintWriter out = response.getWriter()) {
                out.println("<script>alert('로그인 후 댓글을 작성할 수 있습니다.'); location.href='login.jsp';</script>");
            }
            return;
        }

        // try-with-resources 사용하여 리소스 누수 방지
        try (ReplyDAO replyDAO = new ReplyDAO()) {
            int result = replyDAO.write(bbsID, userID, replyContent);
            if (result == 1) {
                response.sendRedirect("view.jsp?bbsID=" + bbsID);
            } else {
                try (PrintWriter out = response.getWriter()) {
                    out.println("<script>alert('댓글 작성에 실패했습니다.'); history.back();</script>");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            try (PrintWriter out = response.getWriter()) {
                out.println("<script>alert('서버 오류가 발생했습니다.'); history.back();</script>");
            }
        }
    }
}
