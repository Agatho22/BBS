package user;

import utils.OtpUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

/**
 * OtpVerificationServlet
 * - 관리자 OTP 인증을 처리하는 서블릿 클래스
 * - QR 코드 등록 후 사용자가 입력한 OTP를 검증하고, 인증에 성공하면 로그인 세션을 확정
 */
@WebServlet("/verifyOtp")
public class OtpVerificationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * POST 요청 처리 메서드
     * - 사용자가 입력한 OTP 코드와 세션 내 저장된 비밀 키(secret)를 비교하여 인증을 수행합니다.
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();

        // 클라이언트가 입력한 OTP 코드
        String codeStr = request.getParameter("otpCode");
        // 세션에 저장된 OTP 비밀 키
        String secret = (String) session.getAttribute("otpSecret");
        // OTP 인증 대기 중인 관리자 ID
        String pendingAdmin = (String) session.getAttribute("pendingAdmin");

        /**
         * 0. 세션 무효화 또는 로그인되지 않은 상태 차단
         * - 세션이 새로 생성되었거나, 관리자 인증 대상 정보가 없을 경우 접근 차단
         */
        if (session.isNew() || session.getAttribute("pendingAdmin") == null) {
            response.getWriter().println("<script>alert('세션이 만료되었거나 비정상 접근입니다.'); location.href='login.jsp';</script>");
            return;
        }

        /**
         * 1. 접근 유효성 검사
         * - 필수 정보 누락 또는 OTP 코드 형식이 잘못된 경우 차단
         */
        if (pendingAdmin == null || secret == null || codeStr == null || codeStr.length() != 6) {
            response.getWriter().println("<script>alert('잘못된 접근입니다.'); location.href='login.jsp';</script>");
            return;
        }

        /**
         * 2. 관리자 검증
         * - 실제 관리자인지 여부 확인 (UserDAO.adminCheck 사용)
         */
        if (new UserDAO().adminCheck(pendingAdmin) != 1) {
            response.getWriter().println("<script>alert('관리자가 아닙니다.'); location.href='login.jsp';</script>");
            return;
        }

        /**
         * 3. OTP 코드 숫자 파싱
         * - 사용자가 입력한 문자열을 정수로 변환
         * - 숫자가 아닌 값 입력 시 예외 처리
         */
        int code;
        try {
            code = Integer.parseInt(codeStr);
        } catch (NumberFormatException e) {
            response.getWriter().println("<script>alert('숫자만 입력하세요.'); location.href='verifyOtp.jsp';</script>");
            return;
        }

        /**
         * 4. OTP 인증
         * - OtpUtil.verifyCode를 이용하여 입력 코드의 유효성 검증
         * - 성공 시: 세션에 userID 설정 → 최종 로그인 확정
         * - 실패 시: 오류 메시지 출력
         */
        boolean isValid = OtpUtil.verifyCode(secret, code);
        if (isValid) {
            // 관리자 인증 성공 → 최종 로그인 확정
            session.setAttribute("userID", pendingAdmin);
            session.removeAttribute("otpSecret");
            session.removeAttribute("pendingAdmin");
            response.sendRedirect("adminMain.jsp");
        } else {
            response.getWriter().println("<script>alert('인증 실패'); location.href='verifyOtp.jsp';</script>");
        }
    }
}
