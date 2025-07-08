package user;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.security.SecureRandom;
import java.util.Base64;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

@WebServlet("/adminUserUpdate")
public class AdminUserUpdateServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final Logger logger = LogManager.getLogger(AdminUserUpdateServlet.class);

    private String hashPassword(String password, byte[] salt) throws Exception {
        int iterations = 65536;
        int keyLength = 256;
        PBEKeySpec spec = new PBEKeySpec(password.toCharArray(), salt, iterations, keyLength);
        SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
        byte[] hash = factory.generateSecret(spec).getEncoded();
        return Base64.getEncoder().encodeToString(hash);
    }

    private String encodeSalt(byte[] salt) {
        return Base64.getEncoder().encodeToString(salt);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();

        String oldUserID = request.getParameter("oldUserID");
        String userID = request.getParameter("userID");
        String userPassword = request.getParameter("userPassword");
        String userName = request.getParameter("userName");
        String userEmail = request.getParameter("userEmail");
        String admin = request.getParameter("admin");

        if (oldUserID == null || oldUserID.trim().isEmpty()) {
            out.println("<script>alert('oldUserID가 없습니다.'); history.back();</script>");
            return;
        }

        try {
            SecureRandom random = new SecureRandom();
            byte[] salt = new byte[16];
            random.nextBytes(salt);
            String hashedPassword = hashPassword(userPassword, salt);
            String encodedSalt = encodeSalt(salt);

            User user = new User();
            user.setUserID(userID);
            user.setUserPassword(hashedPassword);
            user.setUserName(userName);
            user.setUserEmail(userEmail);
            user.setAdmin(admin);

            try (UserDAO userDAO = new UserDAO()) {
                int result = userDAO.userUpdate(user, oldUserID, encodedSalt);
                if (result > 0) {
                    out.println("<script>alert('회원 정보 변경 완료'); location.href='adminUser.jsp';</script>");
                } else {
                    out.println("<script>alert('회원 정보 변경 실패'); location.href='adminUser.jsp';</script>");
                }
            }
        } catch (Exception e) {
            logger.error("회원 정보 수정 중 예외 발생", e);
            out.println("<script>alert('시스템 오류가 발생했습니다. 관리자에게 문의하세요.'); history.back();</script>");
        }
    }
}
