<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.io.File" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="bbs.BbsDAO" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>JSP 파일 다운로드</title>
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
<style>
    body {
        background-color: #121212;
        color: #e0e0e0;
        font-family: 'Arial', sans-serif;
    }
    .btn-primary {
        background-color: #1f1f1f;
        border: none;
        color: #e0e0e0;
    }
    .btn-primary:hover {
        background-color: #333;
    }
    .container {
        max-width: 600px;
        margin-top: 40px;
        background-color: #1f1f1f;
        padding: 30px;
        border-radius: 8px;
        box-shadow: 0 4px 8px rgba(0, 0, 0, 0.3);
    }
</style>
</head>
<body>
<div class="container">
    <h2>파일 다운로드</h2>
    <hr>
    <%
        // 세션에서 사용자 ID 가져오기
        String userID = null;
        if (session.getAttribute("userID") != null) {
            userID = (String) session.getAttribute("userID");
        }

        // bbsID 가져오기
        int bbsID = 0;
        if (request.getParameter("bbsID") != null) {
            try {
                bbsID = Integer.parseInt(request.getParameter("bbsID"));
            } catch (NumberFormatException e) {
                out.println("<div class='alert alert-danger'>유효하지 않은 BBS ID입니다.</div>");
                return;
            }
        }

        // 파일 디렉토리 가져오기
        String directory = "/opt/upload"; // Tomcat 외부 디렉토리
        File dir = new File(directory);
        String[] files = dir.list();
        System.out.println(directory.toString());
        
        BbsDAO BbsDAO = new BbsDAO();
        String RealPath = BbsDAO.getRealName(bbsID);

        if (files != null && files.length > 0) {
            for (String file : files) {
            	if ( file != null && file.equals(RealPath)) {
                String encodedFile = URLEncoder.encode(file, "UTF-8");
                String fileUrl = request.getContextPath() + "/downloadAction?file=" + encodedFile;
                out.write("<a href=\"" + fileUrl + "\" class=\"btn btn-primary mb-2\">" + file + "</a><br>");
            	}
            }
        } else {
            out.write("<div class='alert alert-info'>해당 게시물에는 다운로드 가능한 파일이 없습니다.</div>");
        }
    %>
</div>
</body>
</html>