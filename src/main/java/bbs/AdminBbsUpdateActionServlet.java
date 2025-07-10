package bbs;

import user.UserDAO;

@WebServlet("/updateAdminBbs")
public class AdminBbsUpdateActionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        HttpSession session = request.getSession();
        PrintWriter out = response.getWriter();

        String userID = (String) session.getAttribute("userID");
        if (userID == null) {
            out.println("<script>alert('로그인을 하세요.'); location.href='login.jsp';</script>");
            return;
        }

        int bbsID = 0;
        try {
            bbsID = Integer.parseInt(request.getParameter("bbsID"));
        } catch (NumberFormatException e) {
            out.println("<script>alert('유효하지 않은 글입니다.'); location.href='adminBbs.jsp';</script>");
            return;
        }

        if (bbsID == 0) {
            out.println("<script>alert('유효하지 않은 글입니다.'); location.href='adminBbs.jsp';</script>");
            return;
        }

        UserDAO userDAO = new UserDAO();
        if (userDAO.adminCheck(userID) == 0) {
            out.println("<script>alert('권한이 없습니다.'); location.href='adminBbs.jsp';</script>");
            return;
        }

        BbsDAO bbsDAO = new BbsDAO();
        Bbs bbs = bbsDAO.getBbs(bbsID);
        if (bbs == null) {
            out.println("<script>alert('해당 글을 찾을 수 없습니다.'); location.href='adminBbs.jsp';</script>");
            return;
        }

        String bbsTitle = request.getParameter("bbsTitle");
        String bbsContent = request.getParameter("bbsContent");

        if (bbsTitle == null || bbsContent == null || bbsTitle.trim().isEmpty() || bbsContent.trim().isEmpty()) {
            out.println("<script>alert('입력이 안 된 사항이 있습니다.'); history.back();</script>");
            return;
        }

        int result = bbsDAO.update(bbsID, bbsTitle, bbsContent);
        if (result == -1) {
            out.println("<script>alert('글 수정 실패했습니다.'); history.back();</script>");
        } else {
            out.println("<script>location.href='adminBbs.jsp';</script>");
        }
    }
}
