<%@page import="java.sql.*"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.InputStream" %>  <%-- JSP 파일에서 사용할 경우 --%>
<%@ page import="java.util.Properties" %>  <%-- JSP 파일에서 Properties 사용 시 --%>


<%
    String userID = request.getParameter("userID");
    String result = "available"; // 기본값: 사용 가능

    if (userID == null || userID.trim().equals("")) {
        result = "invalid"; // 아이디가 비어있거나 유효하지 않음
    } else {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
        	// db.properties 파일 로드
        	Properties props = new Properties();
        	InputStream input = application.getResourceAsStream("/WEB-INF/classes/db.properties");
        	props.load(input);

        	// 설정값 가져오기
        	String driver = props.getProperty("db.driver");
        	String url = props.getProperty("db.url");
        	String username = props.getProperty("db.username");
        	String password = props.getProperty("db.password");

        	// JDBC 드라이버 로딩 및 연결
        	Class.forName(driver);
        	conn = DriverManager.getConnection(url, username, password);

            // 아이디 중복 확인 쿼리
            String sql = "SELECT userID FROM users WHERE userID = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userID);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                result = "unavailable"; // 아이디가 이미 존재
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) { }
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) { }
            if (conn != null) try { conn.close(); } catch (Exception e) { }
        }
    }

    response.setContentType("text/plain");
    response.getWriter().write(result); // 결과 반환
%>