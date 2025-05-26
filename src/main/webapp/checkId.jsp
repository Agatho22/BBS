<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.Properties, java.io.InputStream" %>
<%
    String userID = request.getParameter("userID");
    if (userID == null || userID.trim().equals("")) {
        out.print("아이디를 입력해주세요.");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        // db.properties 파일 읽기
        Properties props = new Properties();
        InputStream input = application.getResourceAsStream("/WEB-INF/classes/db.properties");
        props.load(input);

        String driver = props.getProperty("db.driver");
        String url = props.getProperty("db.url");
        String username = props.getProperty("db.username");
        String password = props.getProperty("db.password");

        Class.forName(driver);
        conn = DriverManager.getConnection(url, username, password);

        String sql = "SELECT userID FROM USER WHERE userID = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userID);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            out.print("이미 사용 중인 아이디입니다.");
        } else {
            out.print("사용 가능한 아이디입니다.");
        }
    } catch (Exception e) {
        out.print("DB 오류 발생: " + e.getMessage());
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ignored) {}
        if (pstmt != null) try { pstmt.close(); } catch (Exception ignored) {}
        if (conn != null) try { conn.close(); } catch (Exception ignored) {}
    }
%>
