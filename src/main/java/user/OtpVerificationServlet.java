package user;

import utils.OtpUtil;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * OtpVerificationServlet
 * - 관리자 OTP 인증을 처리하는 서블릿 클래스
 * - QR 코드 등록 후 사용자가 입력한 OTP를 검증하고, 인증에 성공하면 로그인 세션을 확정
 */
@WebServlet("/verifyOtp")
public class OtpVerificationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");
        HttpSession session = request.getSession();

        String codeStr = request.getParameter("otpCode");
        String secret = (String) session.getAttribute("otpSecret");
        String pendingAdmin = (String) session.getAttribute("pendingAdmin");

        try (PrintWriter out = response.getWriter()) {

            if (session.isNew() || pendingAdmin == null) {
                out.println("<script>alert('세션이 만료되었거나 비정상 접근입니다.'); location.href='login.jsp';</script>");
                return;
            }

            if (secret == null || codeStr == null || codeStr.length() != 6) {
                out.println("<script>alert('잘못된 접근입니다.'); location.href='login.jsp';</script>");
                return;
            }

            try (UserDAO userDAO = new UserDAO()) {
                if (userDAO.adminCheck(pendingAdmin) != 1) {
                    out.println("<script>alert('관리자가 아닙니다.'); location.href='login.jsp';</script>");
                    return;
                }
            } catch (Exception e) {
                out.println("<script>alert('관리자 확인 중 오류 발생'); location.href='login.jsp';</script>");
                return;
            }

            int code;
            try {
                code = Integer.parseInt(codeStr);
            } catch (NumberFormatException e) {
                out.println("<script>alert('숫자만 입력하세요.'); location.href='verifyOtp.jsp';</script>");
                return;
            }

            boolean isValid = OtpUtil.verifyCode(secret, code);
            if (isValid) {
                session.setAttribute("userID", pendingAdmin);
                session.removeAttribute("otpSecret");
                session.removeAttribute("pendingAdmin");
                response.sendRedirect("adminMain.jsp");
            } else {
                out.println("<script>alert('인증 실패'); location.href='verifyOtp.jsp';</script>");
            }

        }
    }
}
