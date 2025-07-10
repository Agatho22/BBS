package user;

import com.warrenstrange.googleauth.GoogleAuthenticatorKey;
import utils.OtpUtil;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLEncoder;

@WebServlet("/registerOtp")
public class OtpRegistrationServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private static final Logger logger = LogManager.getLogger(OtpRegistrationServlet.class);

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String userID = (String) session.getAttribute("pendingAdmin");

        if (session.isNew() || userID == null) {
            logger.warn("비정상 접근 시도 또는 세션 없음");
            denyAccess(response);
            return;
        }

        try (UserDAO userDAO = new UserDAO()) {
            if (userDAO.adminCheck(userID) != 1) {
                logger.warn("관리자 인증 실패: {}", userID);
                denyAccess(response);
                return;
            }
        } catch (Exception e) {
            logger.error("DB 오류 - 관리자 확인 중 예외 발생", e);
            showErrorPage(response, "내부 서버 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.");
            return;
        }

        try {
            GoogleAuthenticatorKey key = OtpUtil.createCredentials();
            String secret = key.getKey();

            String qrUrl = OtpUtil.getQrCodeURL(userID, secret);
            String encodedQrUrl = URLEncoder.encode(qrUrl, "UTF-8");

            session.setAttribute("otpSecret", secret);

            response.setContentType("text/html; charset=UTF-8");
            try (PrintWriter out = response.getWriter()) {
                out.println("<!DOCTYPE html>");
                out.println("<html><head><meta charset='UTF-8'><title>OTP 등록</title></head><body>");
                out.println("<h2>OTP 앱 등록</h2>");
                out.println("<p>Google Authenticator 앱에서 아래 QR코드를 스캔하세요.</p>");
                out.println("<img src=\"https://quickchart.io/qr?text=" + encodedQrUrl + "&size=200\" alt=\"QR Code\">");
                out.println("<p>또는 수동으로 입력: <b>" + secret + "</b></p>");
                out.println("<p><a href='verifyOtp.jsp'>OTP 입력하기</a></p>");
                out.println("</body></html>");
            }

        } catch (Exception e) {
            logger.error("OTP 등록 처리 중 예외 발생", e);
            showErrorPage(response, "OTP 등록 중 문제가 발생했습니다.");
        }
    }

    private void denyAccess(HttpServletResponse response) throws IOException {
        response.setContentType("text/html; charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<script>alert('관리자만 접근할 수 있습니다.'); location.href='login.jsp';</script>");
        } catch (IOException e) {
            logger.error("denyAccess 응답 출력 실패", e);
            throw e;
        }
    }

    private void showErrorPage(HttpServletResponse response, String message) throws IOException {
        response.setContentType("text/html; charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.println("<html><body>");
            out.println("<h2>오류</h2>");
            out.println("<p>" + message + "</p>");
            out.println("<a href='login.jsp'>돌아가기</a>");
            out.println("</body></html>");
        }
    }
}
