package user;

import utils.OtpUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/verifyOtp")
public class OtpVerificationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        HttpSession session = request.getSession();

        String codeStr = request.getParameter("otpCode");
        String secret = (String) session.getAttribute("otpSecret");
        String pendingAdmin = (String) session.getAttribute("pendingAdmin");

        // 0. 세션 무효화 또는 로그인되지 않은 상태 차단
        if (session.isNew() || session.getAttribute("pendingAdmin") == null) {
            response.getWriter().println("<script>alert('세션이 만료되었거나 비정상 접근입니다.'); location.href='login.jsp';</script>");
            return;
        }
        
        // 1. 접근 유효성 검사
        if (pendingAdmin == null || secret == null || codeStr == null || codeStr.length() != 6) {
            response.getWriter().println("<script>alert('잘못된 접근입니다.'); location.href='login.jsp';</script>");
            return;
        }

        // 2. 관리자 검증
        if (new UserDAO().adminCheck(pendingAdmin) != 1) {
            response.getWriter().println("<script>alert('관리자가 아닙니다.'); location.href='login.jsp';</script>");
            return;
        }

        // 3. OTP 코드 숫자 파싱
        int code;
        try {
            code = Integer.parseInt(codeStr);
        } catch (NumberFormatException e) {
            response.getWriter().println("<script>alert('숫자만 입력하세요.'); location.href='verifyOtp.jsp';</script>");
            return;
        }

        // 4. OTP 인증
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
