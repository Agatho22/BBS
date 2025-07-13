package user;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;
import java.util.Properties;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

@WebServlet("/checkID")
public class CheckIDServlet extends HttpServlet {
    private static final Logger logger = LogManager.getLogger(CheckIDServlet.class);
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/plain; charset=UTF-8");

        String userID = request.getParameter("userID");
        if (userID == null || userID.trim().isEmpty()) {
            response.getWriter().print("아이디를 입력해주세요.");
            return;
        }

        try (InputStream input = getServletContext().getResourceAsStream("/WEB-INF/classes/db.properties")) {
            Properties props = new Properties();
            props.load(input);

            String driver = props.getProperty("db.driver");
            String url = props.getProperty("db.url");
            String username = props.getProperty("db.username");
            String password = props.getProperty("db.password");

            Class.forName(driver);

            try (Connection conn = DriverManager.getConnection(url, username, password);
                 PreparedStatement pstmt = conn.prepareStatement("SELECT userID FROM USER WHERE userID = ?")) {

                pstmt.setString(1, userID);
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        response.getWriter().print("이미 사용 중인 아이디입니다.");
                    } else {
                        response.getWriter().print("사용 가능한 아이디입니다.");
                    }
                }
            }

        } catch (Exception e) {
            logger.error("아이디 중복 확인 중 예외 발생", e);
            response.getWriter().print("시스템 오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
        }
    }
}
