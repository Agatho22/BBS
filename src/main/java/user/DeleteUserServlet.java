package user;

import javax.servlet.ServletException;

@WebServlet("/deleteUser")
public class DeleteUserServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 인코딩 및 응답 설정
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession();
        String userID = (String) session.getAttribute("userID");
        String userPassword = request.getParameter("userPassword");

        // 로그인 상태 확인
        if (userID == null) {
        	out.println("<script>");
        	out.println("alert('로그인이 필요합니다.');");
        	out.println("location.href='/login.jsp';");
        	out.println("</script>");
            return;
        }

        // 비밀번호 미입력 처리
        if (userPassword == null || userPassword.trim().isEmpty()) {
            out.println("<script>alert('비밀번호를 입력해주세요.'); history.back();</script>");
            return;
        }

        UserDAO userDAO = new UserDAO();
        int result = userDAO.deleteUser(userID, userPassword);

        if (result == 1) {
            session.invalidate(); // 세션 초기화 (로그아웃)
            out.println("<script>alert('회원님의 정보가 성공적으로 삭제되었습니다.'); location.href='index.jsp';</script>");
        } else if (result == 0) {
            out.println("<script>alert('비밀번호가 틀렸습니다.'); history.back();</script>");
        } else {
            out.println("<script>alert('회원 탈퇴 중 오류가 발생했습니다.'); history.back();</script>");
        }
    }
}
