<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="user.UserDAO"%>
<%@ page import="user.User"%>
<%@ page import="java.io.PrintWriter"%>
<%@ page import="java.util.*"%>
<%@ page import="java.util.stream.Collectors"%>
<%@ page import="java.security.MessageDigest" %>
<%@ page import="java.security.SecureRandom" %>
<% request.setCharacterEncoding("UTF-8"); %>

<jsp:useBean id="user" class="user.User" scope="page" />
<jsp:setProperty name="user" property="userID" />
<jsp:setProperty name="user" property="userPassword" />
<jsp:setProperty name="user" property="userName" />
<jsp:setProperty name="user" property="userEmail" />
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>JSP 게시판 웹 사이트</title>
</head>
<body>
<%
    String pw = user.getUserPassword();
    String[] worstPasswords = {
        "1234", "12345", "123456", "12345678", "123456789",
        "password", "admin", "qwerty", "qwer1234", "111111", "000000",
        "00000", "123321", "888888", "aaa111", "p@ssword",
        "11111111", "abcdef", "123qwe", "abcabc", "Qwerty",
        "passwd", "112233", "654321", "abc123", "Qweasd",
        "iloveyou", "123123", "666666", "a1b2c3", "Admin", "5201314"
    };

    if (user.getUserID() == null || pw == null || user.getUserName() == null || user.getUserEmail() == null) {
        PrintWriter script = response.getWriter();
        script.println("<script>alert('입력이 안 된 사항이 있습니다.'); history.back();</script>");
        script.close();
        return;
    }

    List<String> worstList = Arrays.stream(worstPasswords)
                                   .map(String::toLowerCase)
                                   .collect(Collectors.toList());
    if (worstList.contains(pw.toLowerCase())) {
        PrintWriter script = response.getWriter();
        script.println("<script>alert('사용할 수 없는 취약한 비밀번호입니다. 다른 비밀번호를 입력해주세요.'); history.back();</script>");
        script.close();
        return;
    }

    if (!pw.matches("^(?=.*[A-Za-z])(?=.*\\d)(?=.*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?]).{8,}$")) {
        PrintWriter script = response.getWriter();
        script.println("<script>alert('비밀번호는 8자 이상이며, 영문자, 숫자, 특수문자를 모두 포함해야 합니다.'); history.back();</script>");
        script.close();
        return;
    }

    if (pw.matches(".*(.)\\1{2,}.*")) {
        PrintWriter script = response.getWriter();
        script.println("<script>alert('비밀번호에 동일한 문자가 3번 이상 반복될 수 없습니다.'); history.back();</script>");
        script.close();
        return;
    }

    if (pw.matches(".*(\\d)\\1{1,}.*")) {
        PrintWriter script = response.getWriter();
        script.println("<script>alert('비밀번호에 반복된 숫자가 포함되어 있습니다.'); history.back();</script>");
        script.close();
        return;
    }

    String[] incSeqs = {"012", "123", "234", "345", "456", "567", "678", "789"};
    String[] decSeqs = {"987", "876", "765", "654", "543", "432", "321", "210"};
    boolean foundSeq = false;

    for (String seq : incSeqs) {
        if (pw.contains(seq)) {
            foundSeq = true;
            break;
        }
    }
    for (String seq : decSeqs) {
        if (pw.contains(seq)) {
            foundSeq = true;
            break;
        }
    }

    if (foundSeq) {
        PrintWriter script = response.getWriter();
        script.println("<script>alert('비밀번호에 연속된 숫자가 포함되어 있습니다.'); history.back();</script>");
        script.close();
        return;
    }

    // 🔐 솔트 생성
    SecureRandom random = new SecureRandom();
    byte[] saltBytes = new byte[16];
    random.nextBytes(saltBytes);
    StringBuilder sbSalt = new StringBuilder();
    for (byte b : saltBytes) {
        sbSalt.append(String.format("%02x", b));
    }
    String salt = sbSalt.toString();

    // 🔐 SHA-256 + 솔트 해싱
    String hashedPassword = null;
    try {
        MessageDigest md = MessageDigest.getInstance("SHA-256");
        byte[] hash = md.digest((pw + salt).getBytes("UTF-8"));
        StringBuilder sb = new StringBuilder();
        for (byte b : hash) {
            sb.append(String.format("%02x", b));
        }
        hashedPassword = sb.toString();
    } catch (Exception e) {
        out.println("<p>비밀번호 해싱 중 오류 발생</p>");
        e.printStackTrace();
        return;
    }

    // 비밀번호를 해시로 덮어쓰기
    user.setUserPassword(hashedPassword);

    // 회원가입 처리
    UserDAO userDAO = new UserDAO();
    int result = userDAO.join(user, salt);  // salt 함께 넘김
    PrintWriter script = response.getWriter();

    if (result == -1) {
        script.println("<script>alert('이미 존재하는 아이디입니다.'); history.back();</script>");
    } else {
        script.println("<script>alert('회원가입이 완료되었습니다.'); location.href = 'main.jsp';</script>");
    }
    script.close();
%>
</body>
</html>
