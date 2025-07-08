<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.Properties, java.io.InputStream" %>
<%@ page import="org.apache.logging.log4j.Logger, org.apache.logging.log4j.LogManager" %>

<%
    Logger logger = LogManager.getLogger("IDCheck");

    String userID = request.getParameter("userID");
    if (userID == null || userID.trim().equals("")) {
        out.print("아이디를 입력해주세요.");
        return;
    }

    try (InputStream input = application.getResourceAsStream("/WEB-INF/classes/db.properties")) {

        if (input == null) {
            logger.error("db.properties 파일을 찾을 수 없습니다.");
            out.print("시스템 설정 오류입니다. 관리자에게 문의해주세요.");
            return;
        }

        Properties props = new Properties();
        props.load(input);

        String driver = props.getProperty("db.driver");
        String url = props.getProperty("db.url");
        String username = props.getProperty("db.username");
        String password = props.getProperty("db.password");

        try {
            Class.forName(driver);
        } catch (ClassNotFoundException cnfe) {
            logger.fatal("JDBC 드라이버 로딩 실패", cnfe);
            out.print("서버 설정 오류입니다.");
            return;
        }

        try (
            Connection conn = DriverManager.getConnection(url, username, password);
            PreparedStatement pstmt = conn.prepareStatement("SELECT userID FROM USER WHERE userID = ?");
        ) {
            pstmt.setString(1, userID);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    out.print("이미 사용 중인 아이디입니다.");
                } else {
                    out.print("사용 가능한 아이디입니다.");
                }
            }
        } catch (SQLException sqle) {
            logger.error("DB 연결 또는 쿼리 실행 중 오류 발생", sqle);
            out.print("DB 처리 중 오류가 발생했습니다.");
        }

    } catch (Exception e) {
        logger.error("예상치 못한 예외 발생", e);
        out.print("시스템 오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
    }
%>
