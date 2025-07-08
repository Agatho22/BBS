<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bbs.Bbs" %>
<%@ page import="bbs.BbsDAO" %>
<%@ page import="java.io.PrintWriter" %>
<% request.setCharacterEncoding("UTF-8"); %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>JSP 게시판 웹 사이트</title>
</head>
<body>
<%
    String userID = (String) session.getAttribute("userID");
    if (userID == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='login.jsp';</script>");
        return;
    }

    int bbsID = 0;
    try {
        bbsID = Integer.parseInt(request.getParameter("bbsID"));
    } catch (Exception e) {
        out.println("<script>alert('유효하지 않은 글입니다.'); location.href='bbs.jsp';</script>");
        return;
    }

    BbsDAO bbsDAO = new BbsDAO();
    Bbs bbs = bbsDAO.getBbs(bbsID);

    if (bbs == null) {
        out.println("<script>alert('존재하지 않는 글입니다.'); location.href='bbs.jsp';</script>");
        return;
    }

    if (!userID.equals(bbs.getUserID())) {
        out.println("<script>alert('권한이 없습니다.'); location.href='bbs.jsp';</script>");
        return;
    }

    int result = bbsDAO.delete(bbsID);
    if (result == -1) {
        out.println("<script>alert('글 삭제에 실패했습니다.'); history.back();</script>");
    } else {
        out.println("<script>alert('삭제되었습니다.'); location.href='bbs.jsp';</script>");
    }
%>
</body>
</html>
