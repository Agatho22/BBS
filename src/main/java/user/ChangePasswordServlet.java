package user;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Arrays;
import java.util.List;

@WebServlet("/ChangePasswordAction")
public class ChangePasswordServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        try (PrintWriter out = response.getWriter()) {

            HttpSession session = request.getSession();
            String userID = (String) session.getAttribute("userID");
            if (userID == null) {
                out.println("<script>alert('로그인이 필요합니다.'); location.href='login.jsp';</script>");
                return;
            }

            String currentPassword = request.getParameter("currentPassword");
            String newPassword = request.getParameter("newPassword");
            String confirmPassword = request.getParameter("confirmPassword");

            if (currentPassword == null || newPassword == null || confirmPassword == null ||
                currentPassword.trim().isEmpty() || newPassword.trim().isEmpty() || confirmPassword.trim().isEmpty()) {
                out.println("<script>alert('모든 항목을 입력하세요.'); history.back();</script>");
                return;
            }

            if (!newPassword.equals(confirmPassword)) {
                out.println("<script>alert('새 비밀번호가 일치하지 않습니다.'); history.back();</script>");
                return;
            }

            // 비밀번호 정책 검사
            String pw = newPassword;
            List<String> worstPasswords = Arrays.asList(
                    "1234", "12345", "123456", "12345678", "123456789", "password", "admin", "qwerty",
                    "qwer1234", "111111", "000000", "00000", "123321", "888888", "aaa111", "p@ssword",
                    "11111111", "abcdef", "123qwe", "abcabc", "Qwerty", "passwd", "112233", "654321",
                    "abc123", "Qweasd", "iloveyou", "123123", "666666", "a1b2c3", "Admin", "5201314"
            );
            for (String bad : worstPasswords) {
                if (pw.equalsIgnoreCase(bad)) {
                    out.println("<script>alert('너무 쉬운 비밀번호입니다. 다른 비밀번호를 사용해주세요.'); history.back();</script>");
                    return;
                }
            }

            if (!pw.matches("^(?=.*[A-Za-z])(?=.*\\d)(?=.*[!@#$%^&*()_+\\-=[\\]{};':\"\\\\|,.<>/?]).{8,}$")) {
                out.println("<script>alert('비밀번호는 8자 이상이며, 영문자, 숫자, 특수문자를 모두 포함해야 합니다.'); history.back();</script>");
                return;
            }

            if (pw.matches(".*(.)\\1{2,}.*")) {
                out.println("<script>alert('비밀번호에 동일한 문자가 3번 이상 반복될 수 없습니다.'); history.back();</script>");
                return;
            }

            if (pw.matches(".*(\\d)\\1{1,}.*")) {
                out.println("<script>alert('비밀번호에 반복된 숫자가 포함되어 있습니다.'); history.back();</script>");
                return;
            }

            String[] incSeqs = {"012", "123", "234", "345", "456", "567", "678", "789"};
            String[] decSeqs = {"987", "876", "765", "654", "543", "432", "321", "210"};
            for (String seq : incSeqs) {
                if (pw.contains(seq)) {
                    out.println("<script>alert('비밀번호에 연속된 숫자가 포함되어 있습니다.'); history.back();</script>");
                    return;
                }
            }
            for (String seq : decSeqs) {
                if (pw.contains(seq)) {
                    out.println("<script>alert('비밀번호에 연속된 숫자가 포함되어 있습니다.'); history.back();</script>");
                    return;
                }
            }

            try (UserDAO userDAO = new UserDAO()) { // 리소스 누수 방지
                int loginResult = userDAO.login(userID, currentPassword);
                if (loginResult != 1) {
                    out.println("<script>alert('현재 비밀번호가 올바르지 않습니다.'); history.back();</script>");
                    return;
                }

                int result = userDAO.updatePassword(userID, newPassword);
                if (result == 1) {
                    out.println("<script>alert('비밀번호가 성공적으로 변경되었습니다. 다시 로그인해주세요.'); location.href = 'logoutAction.jsp';</script>");
                } else {
                    out.println("<script>alert('비밀번호 변경에 실패했습니다.'); history.back();</script>");
                }
            } catch (Exception e) {
                e.printStackTrace();
                out.println("<script>alert('서버 오류가 발생했습니다.'); history.back();</script>");
            }

        }
    }
}
