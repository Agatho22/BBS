<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.Properties, java.io.InputStream" %>
<%@ page import="org.apache.logging.log4j.Logger, org.apache.logging.log4j.LogManager" %>

<%
    Logger logger = LogManager.getLogger("IDCheckLogger");

    String userID = request.getParameter("userID");
    String result = "available"; // 기본값: 사용 가능

    if (userID == null || userID.trim().isEmpty()) {
        result = "invalid";
    } else {
        try (
            InputStream input = application.getResourceAsStream("/WEB-INF/classes/db.properties")
        ) {
            Properties props = new Properties();
            props.load(input);

            String driver = props.getProperty("db.driver");
            String url = props.getProperty("db.url");
            String username = props.getProperty("db.username");
            String password = props.getProperty("db.password");

            Class.forName(driver);

            try (
                Connection conn = DriverManager.getConnection(url, username, password);
                PreparedStatement pstmt = conn.prepareStatement("SELECT userID FROM users WHERE userID = ?");
            ) {
                pstmt.setString(1, userID);
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        result = "unavailable"; // 이미 존재
                    }
                }
            }

        } catch (Exception e) {
            result = "error"; // 예외 발생 시 클라이언트에게 error 상태 전달
            logger.error("아이디 중복 확인 중 오류 발생", e); // 서버에 로그 기록
        }
    }

    response.setContentType("text/plain");
    response.getWriter().write(result);
%>
