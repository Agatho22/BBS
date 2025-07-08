package user;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/adminDeleteUser")
public class AdminDeleteUserServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        String userID = request.getParameter("userID");

        PrintWriter out = response.getWriter();

        if (userID == null || userID.trim().isEmpty()) {
            out.println("<script>");
            out.println("alert('유효하지 않은 요청입니다.');");
            out.println("history.back();");
            out.println("</script>");
            return;
        }

        UserDAO userDAO = new UserDAO();
        boolean result = userDAO.deleteUser(userID);

        if (result) {
            out.println("<script>");
            out.println("alert('회원님의 정보가 성공적으로 삭제되었습니다.');");
            out.println("location.href = 'adminUser.jsp';");
            out.println("</script>");
        } else {
            out.println("<script>");
            out.println("alert('정보 삭제에 실패했습니다.');");
            out.println("history.back();");
            out.println("</script>");
        }

        out.close();
    }

    // GET 요청이 들어올 경우 POST로 리다이렉트 (보안상 권장)
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("adminUser.jsp");
    }
}
