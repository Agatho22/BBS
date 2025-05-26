<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ page import="java.io.*, user.UserDAO" %>
<%
    request.setCharacterEncoding("UTF-8");

	// 세션에서 로그인한 사용자 ID 확인
    String userID = (String) session.getAttribute("userID");
    if (userID == null) {
    	// 로그인하지 않은 경우 로그인 페이지로 리디렉션
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('로그인이 필요합니다.')");
        script.println("location.href = 'login.jsp';");
        script.println("</script>");
        return;
    }
    
    // 사용자 입력값 받기
    String currentPassword = request.getParameter("currentPassword");
    String newPassword = request.getParameter("newPassword");
    String confirmPassword = request.getParameter("confirmPassword");

    // 입력값이 하나라도 비어 있으면 되돌아감
    if (currentPassword == null || newPassword == null || confirmPassword == null ||
        currentPassword.equals("") || newPassword.equals("") || confirmPassword.equals("")) {
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('모든 항목을 입력하세요.');");
        script.println("history.back();");
        script.println("</script>");
        return;
    } 

    // 새 비밀번호와 확인 비밀번호가 일치하지 않으면 되돌아감
    if (!newPassword.equals(confirmPassword)) {
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('새 비밀번호가 일치하지 않습니다.');");
        script.println("history.back();");
        script.println("</script>");
        return;
    }

    // 비밀번호 정책 검사 시작
    String pw = newPassword;
    
 // 자주 사용되는 최악의 비밀번호 목록 (사용 금지)
    String[] worstPasswords = {
        "1234", "12345", "123456", "12345678", "123456789",
        "password", "admin", "qwerty", "qwer1234", "111111", "000000",
        "00000", "123321", "888888", "aaa111", "p@ssword",
        "11111111", "abcdef", "123qwe", "abcabc", "Qwerty",
        "passwd", "112233", "654321", "abc123", "Qweasd",
        "iloveyou", "123123", "666666", "a1b2c3", "Admin", "5201314"
    };

    // 최악의 비밀번호와 일치하는 경우 차단
    for (String bad : worstPasswords) {
        if (pw.equalsIgnoreCase(bad)) {
            PrintWriter script = response.getWriter();
            script.println("<script>alert('너무 쉬운 비밀번호입니다. 다른 비밀번호를 사용해주세요.'); history.back();</script>");
            script.close();
            return;
        }
    }

 	// 8자 이상, 영문+숫자+특수문자 포함 검사
    if (!pw.matches("^(?=.*[A-Za-z])(?=.*\\d)(?=.*[!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?]).{8,}$")) {
        PrintWriter script = response.getWriter();
        script.println("<script>alert('비밀번호는 8자 이상이며, 영문자, 숫자, 특수문자를 모두 포함해야 합니다.'); history.back();</script>");
        script.close();
        return;
    }

 	// 동일한 문자 3회 이상 반복 금지 (예: aaa, 111)
    if (pw.matches(".*(.)\\1{2,}.*")) {
        PrintWriter script = response.getWriter();
        script.println("<script>alert('비밀번호에 동일한 문자가 3번 이상 반복될 수 없습니다.'); history.back();</script>");
        script.close();
        return;
    }

    // 숫자 반복 (예: 11, 22) 금지
    if (pw.matches(".*(\\d)\\1{1,}.*")) {
        PrintWriter script = response.getWriter();
        script.println("<script>alert('비밀번호에 반복된 숫자가 포함되어 있습니다.'); history.back();</script>");
        script.close();
        return;
    }

 	// 연속된 숫자(오름차순, 내림차순) 금지
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
    // 비밀번호 정책 검사 끝

    // DAO 객체 생성
    UserDAO userDAO = new UserDAO();
    
 // 현재 비밀번호가 올바른지 확인 (SHA-256 + salt로 검증)
    int loginResult = userDAO.login(userID, currentPassword);
    if (loginResult != 1) {
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('현재 비밀번호가 올바르지 않습니다.');");
        script.println("history.back();");
        script.println("</script>");
        return;
    }
    
 	// 비밀번호 업데이트 시도 (UserDAO 내부에서 SHA-256 + salt 적용)
    int result = userDAO.updatePassword(userID, newPassword);
    if (result == 1) {
    	 // 성공 시 로그아웃 처리 → 재로그인 유도
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('비밀번호가 성공적으로 변경되었습니다. 다시 로그인해주세요.');");
        script.println("location.href = 'logoutAction.jsp';");
        script.println("</script>");
    } else {
    	// 실패 시 오류 알림
        PrintWriter script = response.getWriter();
        script.println("<script>");
        script.println("alert('비밀번호 변경에 실패했습니다.');");
        script.println("history.back();");
        script.println("</script>");
    }
%>