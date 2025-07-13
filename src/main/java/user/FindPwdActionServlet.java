package user;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.security.SecureRandom;
import java.security.spec.KeySpec;
import java.sql.*;
import java.util.Base64;
import java.util.Properties;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

@WebServlet("/findPwdActionServlet")
public class FindPwdActionServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // 임시 비밀번호 생성
    private String generateTempPassword(int length) {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#";
        SecureRandom rnd = new SecureRandom();
        StringBuilder sb = new StringBuilder(length);
        for (int i = 0; i < length; i++) {
            sb.append(chars.charAt(rnd.nextInt(chars.length())));
        }
        return sb.toString();
    }

    // 솔트 생성
    private String generateSalt() {
        byte[] salt = new byte[16];
        new SecureRandom().nextBytes(salt);
        return Base64.getEncoder().encodeToString(salt);
    }

    // 비밀번호 해시 (PBKDF2)
    private String hashPassword(String password, String salt) throws Exception {
        KeySpec spec = new PBEKeySpec(password.toCharArray(), salt.getBytes(), 65536, 256);
        SecretKeyFactory factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA1");
        byte[] hash = factory.generateSecret(spec).getEncoded();
        return Base64.getEncoder().encodeToString(hash);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        String userID = request.getParameter("userID");
        String userName = request.getParameter("userName");
        String userEmail = request.getParameter("userEmail");

        if (userID == null || userName == null || userEmail == null ||
                userID.trim().isEmpty() || userName.trim().isEmpty() || userEmail.trim().isEmpty()) {
            request.setAttribute("msg", "모든 항목을 입력해주세요.");
            request.getRequestDispatcher("/findPwdResult.jsp").forward(request, response);
            return;
        }

        try {
            // DB 설정 로딩
            Properties props = new Properties();
            try (InputStream input = getClass().getClassLoader().getResourceAsStream("db.properties")) {
                if (input == null) {
                    throw new FileNotFoundException("db.properties 파일을 찾을 수 없습니다.");
                }
                props.load(input);
            }

            String driver = props.getProperty("db.driver");
            String url = props.getProperty("db.url");
            String username = props.getProperty("db.username");
            String password = props.getProperty("db.password");

            Class.forName(driver);

            try (Connection conn = DriverManager.getConnection(url, username, password)) {

                // 1. 사용자 확인
                String checkSql = "SELECT * FROM USER WHERE userID=? AND userName=? AND userEmail=?";
                try (PreparedStatement pstmt = conn.prepareStatement(checkSql)) {
                    pstmt.setString(1, userID);
                    pstmt.setString(2, userName);
                    pstmt.setString(3, userEmail);
                    try (ResultSet rs = pstmt.executeQuery()) {
                        if (!rs.next()) {
                            request.setAttribute("msg", "입력한 정보와 일치하는 회원이 없습니다.");
                            request.getRequestDispatcher("/findPwdResult.jsp").forward(request, response);
                            return;
                        }
                    }
                }

                // 2. 임시 비밀번호 생성 및 해싱
                String tempPassword = generateTempPassword(10);
                String salt = generateSalt();
                String hashedPassword = hashPassword(tempPassword, salt);

                // 3. DB 업데이트
                String updateSql = "UPDATE USER SET userPassword=?, salt=? WHERE userID=?";
                try (PreparedStatement updateStmt = conn.prepareStatement(updateSql)) {
                    updateStmt.setString(1, hashedPassword);
                    updateStmt.setString(2, salt);
                    updateStmt.setString(3, userID);
                    updateStmt.executeUpdate();
                }

                // 4. 결과 JSP로 전달
                request.setAttribute("tempPassword", tempPassword);
                request.setAttribute("msg", "임시 비밀번호가 발급되었습니다. 로그인 후 변경해주세요.");
                request.getRequestDispatcher("/findPwdResult.jsp").forward(request, response);

            }

        } catch (Exception e) {
            e.printStackTrace(); // 또는 logger.fatal(...)
            request.setAttribute("msg", "서버 오류가 발생했습니다. 관리자에게 문의하세요.");
            request.getRequestDispatcher("/findPwdResult.jsp").forward(request, response);
        }
    }
}
