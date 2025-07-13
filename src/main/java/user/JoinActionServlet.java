package user;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.*;
import java.util.stream.Collectors;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

@WebServlet("/joinAction")
public class JoinActionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger logger = LogManager.getLogger(JoinActionServlet.class);

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();

        String userID = request.getParameter("userID");
        String userPassword = request.getParameter("userPassword");
        String userName = request.getParameter("userName");
        String userEmail = request.getParameter("userEmail");

        if (userID == null || userPassword == null || userName == null || userEmail == null ||
            userID.trim().isEmpty() || userPassword.trim().isEmpty() ||
            userName.trim().isEmpty() || userEmail.trim().isEmpty()) {

            out.println("<script>alert('입력이 안 된 사항이 있습니다.'); history.back();</script>");
            return;
        }

        String[] worstPasswords = {
            "1234", "12345", "123456", "12345678", "123456789",
            "password", "admin", "qwerty", "qwer1234", "111111", "000000",
            "00000", "123321", "888888", "aaa111", "p@ssword",
            "11111111", "abcdef", "123qwe", "abcabc", "Qwerty",
            "passwd", "112233", "654321", "abc123", "Qweasd",
            "iloveyou", "123123", "666666", "a1b2c3", "Admin", "5201314"
        };

        List<String> worstList = Arrays.stream(worstPasswords)
                                       .map(String::toLowerCase)
                                       .collect(Collectors.toList());

        if (worstList.contains(userPassword.toLowerCase())) {
            out.println("<script>alert('사용할 수 없는 취약한 비밀번호입니다.'); history.back();</script>");
            return;
        }

        if (!userPassword.matches("^(?=.*[A-Za-z])(?=.*\\d)(?=.*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?]).{8,}$")) {
            out.println("<script>alert('비밀번호는 8자 이상이며, 영문자, 숫자, 특수문자를 포함해야 합니다.'); history.back();</script>");
            return;
        }

        if (userPassword.matches(".*(.)\\1{2,}.*")) {
            out.println("<script>alert('비밀번호에 동일한 문자가 3번 이상 반복될 수 없습니다.'); history.back();</script>");
            return;
        }

        if (userPassword.matches(".*(\\d)\\1{1,}.*")) {
            out.println("<script>alert('비밀번호에 반복된 숫자가 포함되어 있습니다.'); history.back();</script>");
            return;
        }

        String[] incSeqs = {"012", "123", "234", "345", "456", "567", "678", "789"};
        String[] decSeqs = {"987", "876", "765", "654", "543", "432", "321", "210"};

        for (String seq : incSeqs) {
            if (userPassword.contains(seq)) {
                out.println("<script>alert('비밀번호에 연속된 숫자가 포함되어 있습니다.'); history.back();</script>");
                return;
            }
        }
        for (String seq : decSeqs) {
            if (userPassword.contains(seq)) {
                out.println("<script>alert('비밀번호에 연속된 숫자가 포함되어 있습니다.'); history.back();</script>");
                return;
            }
        }

        String salt;
        String hashedPassword;
        try {
            SecureRandom random = new SecureRandom();
            byte[] saltBytes = new byte[16];
            random.nextBytes(saltBytes);
            StringBuilder sbSalt = new StringBuilder();
            for (byte b : saltBytes) {
                sbSalt.append(String.format("%02x", b));
            }
            salt = sbSalt.toString();

            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest((userPassword + salt).getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : hash) {
                sb.append(String.format("%02x", b));
            }
            hashedPassword = sb.toString();

        } catch (Exception e) {
            logger.error("비밀번호 해싱 중 예외 발생", e);
            out.println("<script>alert('시스템 오류가 발생했습니다. 관리자에게 문의하세요.'); history.back();</script>");
            return;
        }

        User user = new User();
        user.setUserID(userID);
        user.setUserPassword(hashedPassword);
        user.setUserName(userName);
        user.setUserEmail(userEmail);

        try (UserDAO userDAO = new UserDAO()) {
            int result = userDAO.join(user, salt);

            if (result == -1) {
                out.println("<script>alert('이미 존재하는 아이디입니다.'); history.back();</script>");
            } else {
                out.println("<script>alert('회원가입이 완료되었습니다.'); location.href = 'main.jsp';</script>");
            }
        } catch (Exception e) {
            logger.error("회원가입 처리 중 예외 발생", e);
            out.println("<script>alert('시스템 오류가 발생했습니다. 관리자에게 문의하세요.'); history.back();</script>");
        }
    }
}
