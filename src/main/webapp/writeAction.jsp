<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="bbs.BbsDAO"%>
<%@ page import="user.UserDAO"%>
<%@ page import="file.FileDAO"%>
<%@ page import="java.io.*"%>
<%@ page import="java.util.*"%>
<%@ page import="java.util.UUID"%>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy"%>
<%@ page import="com.oreilly.servlet.MultipartRequest"%>
<%
request.setCharacterEncoding("UTF-8");

// 로그인 확인
String userID = (String) session.getAttribute("userID");
if (userID == null) {
    out.println("<script>alert('로그인을 하세요.'); location.href='login.jsp';</script>");
    return;
}

//디렉토리 설정

//임시 파일이 저장될 디렉토리 경로 (파일 업로드 중간 저장소)
String tempDirectory = "/opt/upload/temp";
//실제 파일이 최종 저장될 디렉토리 경로
String finalDirectory = "/opt/upload";
//임시 디렉토리 객체 생성
File tempDir = new File(tempDirectory);
//임시 디렉토리가 존재하지 않으면 생성
if (!tempDir.exists()) tempDir.mkdirs();
//최종 디렉토리 객체 생성
File finalDir = new File(finalDirectory);
//최종 디렉토리가 존재하지 않으면 생성
if (!finalDir.exists()) finalDir.mkdirs();

// 파일 업로드 처리
int maxSize = 1024 * 1024 * 100;
String encoding = "UTF-8";
MultipartRequest multipartRequest = null;

try {
    multipartRequest = new MultipartRequest(request, tempDirectory, maxSize, encoding, new DefaultFileRenamePolicy());
} catch (Exception e) {
    out.println("<script>alert('파일 업로드 중 오류가 발생했습니다.'); history.back();</script>");
    return;
}

// 게시글 정보
String bbsTitle = multipartRequest.getParameter("bbsTitle");
String bbsContent = multipartRequest.getParameter("bbsContent");
String isSecret = multipartRequest.getParameter("isSecret");
if (isSecret == null) isSecret = "N";

if (bbsTitle == null || bbsContent == null || bbsTitle.trim().equals("") || bbsContent.trim().equals("")) {
    out.println("<script>alert('입력이 안 된 항목이 있습니다.'); history.back();</script>");
    return;
}

// 파일 정보
String fileName = multipartRequest.getOriginalFileName("file");
String fileRealName = multipartRequest.getFilesystemName("file");
String newFileName = null;
File tempFile = null;
File finalFile = null;

if (fileName != null && fileRealName != null) {
    String ext = fileRealName.substring(fileRealName.lastIndexOf(".") + 1).toLowerCase();
    List<String> allowedExt = Arrays.asList("jpg", "jpeg", "png", "gif", "pdf", "txt");

    if (!allowedExt.contains(ext) || !fileRealName.matches("(?i).+\\.(jpg|jpeg|png|gif|pdf|txt)$")) {
        new File(tempDirectory, fileRealName).delete();
        out.println("<script>alert('허용되지 않은 파일 형식입니다.'); history.back();</script>");
        return;
    }

    if (fileName.toLowerCase().matches(".*(\\.jsp|\\.php|\\.asp|\\.exe).*")) {
        new File(tempDirectory, fileRealName).delete();
        out.println("<script>alert('파일명에 허용되지 않은 문자열이 포함되어 있습니다.'); history.back();</script>");
        return;
    }

    // MIME 타입 검사
    tempFile = new File(tempDirectory, fileRealName);
    String mimeType = application.getMimeType(tempFile.getAbsolutePath());
    if (mimeType == null || !mimeType.startsWith("image/")) {
        tempFile.delete();
        out.println("<script>alert('이미지 파일만 업로드 가능합니다.'); history.back();</script>");
        return;
    }

    // 악성 코드 문자열 검사
    try (Scanner scanner = new Scanner(tempFile)) {
        while (scanner.hasNextLine()) {
            String line = scanner.nextLine().toLowerCase();
            if (line.contains("<%") || line.contains("java.lang.") || line.contains("request.getparameter") || line.contains("eval(")) {
                tempFile.delete();
                out.println("<script>alert('파일 내용에 악성 코드가 포함되어 있습니다.'); history.back();</script>");
                return;
            }
        }
    } catch (Exception e) {
        tempFile.delete();
        out.println("<script>alert('파일 검사 중 오류 발생'); history.back();</script>");
        return;
    }

    // 파일 이름 난수화 후 이동
    newFileName = UUID.randomUUID().toString() + "." + ext;
    finalFile = new File(finalDirectory, newFileName);
    if (!tempFile.renameTo(finalFile)) {
        tempFile.delete();
        out.println("<script>alert('파일 이동 실패'); history.back();</script>");
        return;
    }

    // 실행 권한 제거
    finalFile.setExecutable(false, false);
    finalFile.setReadable(true, false);
    finalFile.setWritable(true, false);
}

// 게시글 저장
BbsDAO bbsDAO = new BbsDAO();
int newBbsID = bbsDAO.write(bbsTitle, userID, bbsContent, isSecret);
if (newBbsID == -1) {
    if (finalFile != null) finalFile.delete();
    out.println("<script>alert('글 작성 실패'); history.back();</script>");
    return;
}

// 파일 정보 저장
if (fileName != null && newFileName != null) {
    FileDAO fileDAO = new FileDAO();
    int fileResult = fileDAO.upload(fileName, newFileName, newBbsID);
    if (fileResult <= 0) {
        if (finalFile != null) finalFile.delete();
        out.println("<script>alert('파일 저장 실패'); history.back();</script>");
        return;
    }
}

// 관리자 여부에 따라 이동
UserDAO userDAO = new UserDAO();
boolean isAdmin = (userDAO.adminCheck(userID) != 0);
out.println("<script>alert('글 작성 완료'); location.href='" + (isAdmin ? "adminBbs.jsp" : "bbs.jsp") + "';</script>");
%>
