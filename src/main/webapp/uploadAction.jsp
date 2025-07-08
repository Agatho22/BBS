<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="bbs.Bbs" %>
<%@ page import="bbs.BbsDAO" %>
<%@ page import="file.FileDAO" %>
<%@ page import="java.io.File" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<!DOCTYPE html>
<html>
<head>
	<meta charset="UTF-8">
	<link rel="stylesheet" href="css/custom.css">
	<title>JSP 파일 업로드</title>
</head>
<body>
	<%
		
		// 세션에서 사용자 ID 가져오기
		String userID = null;
		if (session.getAttribute("userID") != null) {
			userID = (String) session.getAttribute("userID");
		}
		
		// bbsID 가져오기
		int bbsID = 0;
		if (request.getParameter("bbsID") != null) {
			bbsID = Integer.parseInt(request.getParameter("bbsID"));
		}
		
		// 업로드 파일 저장 경로
		BbsDAO bbsDAO = new BbsDAO();
	        int maxBbsID = bbsDAO.getMaxBbsID();
	        
	        // 새 bbsID는 최대 bbsID + 1
	        int newBbsID = maxBbsID + 1;
	    String directory = application.getRealPath("/upload/" + newBbsID + "/");
		
	    File dir = new File(directory);
	    if (!dir.exists()) {
	        dir.mkdirs(); // 여러 단계의 디렉터리 생성
	    }
		
		int maxSize = 1024 * 1024 * 100;
		String encoding = "UTF-8";
		
		MultipartRequest multipartRequest
		= new MultipartRequest(request, directory, maxSize, encoding,
				new DefaultFileRenamePolicy());
		
		 // 파일 정보 가져오기
		String fileName = multipartRequest.getOriginalFileName("file");
		String fileRealName = multipartRequest.getFilesystemName("file");
		
		// BbsDAO, FileDAO 객체 생성
		FileDAO fileDAO = new FileDAO();
		
		Bbs bbs = bbsDAO.getBbs(bbsID);
		
		// 파일 정보를 DB에 저장
		int result = fileDAO.upload(fileName, fileRealName, newBbsID);

        if (result > 0) {
        	out.write("<p>파일 업로드 내용</p>");
            out.write("<p>게시글 번호 : " + newBbsID + "</p>");
            out.write("<p>파일명 : " + fileName + "</p>");
            out.write("<p>실제 파일명 : " + fileRealName + "</p>");
        //} else {
        //    out.println("<script>alert('파일 업로드 중 오류가 발생했습니다.'); history.back();</script>");
        }
		
	%>
</body>
</html>