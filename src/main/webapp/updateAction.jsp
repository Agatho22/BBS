<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bbs.Bbs, bbs.BbsDAO, user.UserDAO, file.FileDAO" %>
<%@ page import="java.io.*, java.util.*" %>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="org.apache.commons.io.FilenameUtils" %> <!-- 파일 이름 처리용 -->
<% request.setCharacterEncoding("UTF-8"); %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>게시글 수정</title>
</head>
<body>
<%
    // 로그인 체크
    String userID = (session.getAttribute("userID") != null) ? (String) session.getAttribute("userID") : null;
    if (userID == null) {
        displayAlertAndRedirect(response, "로그인을 해주세요.", "login.jsp");
        return;
    }

    // multipart/form-data 형식인지 확인
    boolean isMultipart = request.getContentType() != null && request.getContentType().toLowerCase().startsWith("multipart/");
    if (!isMultipart) {
        displayAlertAndRedirect(response, "잘못된 요청 형식입니다.", "bbs.jsp");
        return;
    }

    String directory = "/opt/upload"; // 파일 업로드 디렉토리 (톰캣 외부 경로 권장)
    File dir = new File(directory);
    if (!dir.exists()) dir.mkdirs(); // 업로드 디렉토리가 없으면 생성

    int maxSize = 1024 * 1024 * 100; // 최대 업로드 파일 크기: 100MB
    MultipartRequest multipartRequest = null;
    int bbsID = 0;

    try {
        // MultipartRequest로 업로드 처리
        multipartRequest = new MultipartRequest(request, directory, maxSize, "UTF-8", new DefaultFileRenamePolicy());

        // 게시글 ID 확인
        if (multipartRequest.getParameter("bbsID") != null) {
            bbsID = Integer.parseInt(multipartRequest.getParameter("bbsID"));
        }

        if (bbsID == 0) {
            displayAlertAndRedirect(response, "유효하지 않은 게시글입니다.", "bbs.jsp");
            return;
        }

        // 게시글 존재 여부 확인
        BbsDAO bbsDAO = new BbsDAO();
        Bbs bbs = bbsDAO.getBbs(bbsID);
        if (bbs == null) {
            displayAlertAndRedirect(response, "게시글이 존재하지 않습니다.", "bbs.jsp");
            return;
        }

        // 작성자 또는 관리자 권한 확인
        boolean isAdmin = "admin".equals(userID);
        if (!userID.equals(bbs.getUserID()) && !isAdmin) {
            displayAlertAndRedirect(response, "권한이 없습니다.", "bbs.jsp");
            return;
        }

        // 제목/내용 입력값 체크
        String title = multipartRequest.getParameter("bbsTitle");
        String content = multipartRequest.getParameter("bbsContent");
        if (title == null || content == null || title.trim().equals("") || content.trim().equals("")) {
            displayAlertAndGoBack(response, "입력이 안 된 항목이 있습니다.");
            return;
        }

        // 게시글 수정
        int result = bbsDAO.update(bbsID, title, content);
        if (result == -1) {
            displayAlertAndGoBack(response, "게시글 수정에 실패했습니다.");
            return;
        }

        // 파일 처리 시작
        @SuppressWarnings("unchecked")
        Enumeration<String> files = multipartRequest.getFileNames();

        while (files.hasMoreElements()) {
            String param = files.nextElement();
            String fileName = multipartRequest.getOriginalFileName(param);   // 사용자가 업로드한 원래 파일명
            String fileRealName = multipartRequest.getFilesystemName(param); // 실제 서버에 저장된 파일명

            if (fileName == null || fileRealName == null) continue;

            // 파일명에서 디렉토리 경로 제거 (보안 목적)
            fileRealName = FilenameUtils.getName(fileRealName);

            // 경로 조작 시도 방지 (../, /, \ 등 포함 금지)
           // apache commons IO lib 
            if (fileRealName.contains("..") || fileRealName.contains("/") || fileRealName.contains("\\")) {
                new File(directory, fileRealName).delete(); // 이미 저장된 경우 삭제
                displayAlertAndGoBack(response, "위험한 파일명입니다.");
                return;
            }

            // 허용된 확장자 체크
            String ext = fileName.substring(fileName.lastIndexOf(".") + 1).toLowerCase();
            List<String> allowedExt = Arrays.asList("jpg", "jpeg", "png", "pdf", "doc", "hwp", "xls");
            if (!allowedExt.contains(ext)) {
                new File(directory, fileRealName).delete();
                displayAlertAndGoBack(response, "허용되지 않은 파일 형식입니다.");
                return;
            }

            // 실제 파일 경로가 업로드 폴더 안에 있는지 확인
            File uploadedFile = new File(dir, fileRealName);
            if (!uploadedFile.getCanonicalPath().startsWith(dir.getCanonicalPath())) {
                uploadedFile.delete();
                displayAlertAndGoBack(response, "파일 경로가 유효하지 않습니다.");
                return;
            }

            // 파일 정보를 DB에 저장 또는 수정
            FileDAO fileDAO = new FileDAO();
            fileDAO.saveOrUpdate(fileName, fileRealName, bbsID);
        }

        // 성공 메시지 후 게시판으로 이동
        displayAlertAndRedirect(response, "수정이 완료되었습니다.", "bbs.jsp");

    } catch (Exception e) {
        // 예외 메시지 출력 (운영환경에서는 생략 또는 로그 저장 권장)
        displayAlertAndGoBack(response, "예외 발생: " + e.toString().replace("'", "\\'"));
    }
%>

<%!
    // 알림 후 특정 페이지로 이동하는 함수
    private void displayAlertAndRedirect(HttpServletResponse response, String msg, String url) throws IOException {
        PrintWriter out = response.getWriter();
        out.println("<script>alert('" + msg + "'); location.href='" + url + "';</script>");
    }

    // 알림 후 이전 페이지로 되돌아가는 함수
    private void displayAlertAndGoBack(HttpServletResponse response, String msg) throws IOException {
        PrintWriter out = response.getWriter();
        out.println("<script>alert('" + msg + "'); history.back();</script>");
    }
%>
</body>
</html>
