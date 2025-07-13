package bbs;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/bbs/validateAccess")
public class ValidateBbsAccessServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession();
        String userID = (String) session.getAttribute("userID");

        if (userID == null) {
            out.println("<script>");
            out.println("alert('로그인을 하세요.');");
            out.println("location.href='login.jsp';");
            out.println("</script>");
            return;
        }

        String bbsIDParam = request.getParameter("bbsID");
        int bbsID = 0;

        try {
            bbsID = Integer.parseInt(bbsIDParam);
        } catch (NumberFormatException e) {
            out.println("<script>");
            out.println("alert('유효하지 않은 글입니다.');");
            out.println("location.href='bbs.jsp';");
            out.println("</script>");
            return;
        }

        if (bbsID == 0) {
            out.println("<script>");
            out.println("alert('유효하지 않은 글입니다.');");
            out.println("location.href='bbs.jsp';");
            out.println("</script>");
            return;
        }

        try (BbsDAO bbsDAO = new BbsDAO()) {
            Bbs bbs = bbsDAO.getBbs(bbsID);

            if (bbs == null || !userID.equals(bbs.getUserID())) {
                out.println("<script>");
                out.println("alert('권한이 없습니다.');");
                out.println("location.href='bbs.jsp';");
                out.println("</script>");
                return;
            }

            // 권한 확인 완료 후 수정 페이지로 이동
            response.sendRedirect("bbsEdit.jsp?bbsID=" + bbsID);
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<script>");
            out.println("alert('서버 오류 발생');");
            out.println("location.href='bbs.jsp';");
            out.println("</script>");
        }
    }
}
