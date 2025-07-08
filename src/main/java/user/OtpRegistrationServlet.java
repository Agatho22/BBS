package user;

import com.warrenstrange.googleauth.GoogleAuthenticatorKey;
import utils.OtpUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.net.URLEncoder;

/**
 * OtpRegistrationServlet
 * - 관리자 계정의 OTP 등록을 위한 서블릿 클래스입니다.
 * - 관리자 로그인 후 OTP 등록을 위해 최초로 접근되는 엔드포인트입니다.
 * - QR 코드 기반 OTP 앱(Google Authenticator 등) 등록 절차를 지원합니다.
 */
@WebServlet("/registerOtp")
public class OtpRegistrationServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    /**
     * GET 요청 처리 메서드
     * - OTP 비밀 키 생성 및 QR 코드 페이지 응답
     *
     * @param request 클라이언트 요청 객체
     * @param response 서버 응답 객체
     * @throws ServletException 서블릿 예외
     * @throws IOException 입출력 예외
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String userID = (String) session.getAttribute("pendingAdmin"); // OTP 등록 대기 중인 관리자 ID

        /**
         * 유효성 검사
         * - 세션이 새로 생성되었거나, pendingAdmin 속성이 없거나, 관리자가 아닌 경우 접근 차단
         */
        if (session.isNew() || userID == null || new UserDAO().adminCheck(userID) != 1) {
            response.setContentType("text/html; charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.println("<script>alert('관리자만 접근할 수 있습니다.'); location.href='login.jsp';</script>");
            return;
        }

        // OTP 비밀 키 생성
        GoogleAuthenticatorKey key = OtpUtil.createCredentials();
        String secret = key.getKey(); // 생성된 시크릿 키 추출

        // QR 코드 등록 URL 생성 및 URL 인코딩
        String qrUrl = OtpUtil.getQrCodeURL(userID, secret);
        String encodedQrUrl = URLEncoder.encode(qrUrl, "UTF-8");

        // 세션에 secret 저장 (OTP 코드 검증을 위한 기준값)
        session.setAttribute("otpSecret", secret);

        // 응답 HTML 페이지 작성
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();

        out.println("<!DOCTYPE html>");
        out.println("<html><head><meta charset='UTF-8'><title>OTP 등록</title></head><body>");
        out.println("<h2>OTP 앱 등록</h2>");
        out.println("<p>Google Authenticator 앱에서 아래 QR코드를 스캔하세요.</p>");

     // QR 코드 이미지 출력 (QR 코드 생성 URL에 인코딩된 URL 삽입)
        out.println("<img src=\"https://quickchart.io/qr?text=" + encodedQrUrl + "&size=200\" alt=\"QR Code\">");
        
        // 수동 입력용 키 제공
        out.println("<p>또는 수동으로 입력: <b>" + secret + "</b></p>");

        // 다음 단계로 이동 링크
        out.println("<p><a href='verifyOtp.jsp'>OTP 입력하기</a></p>");
        out.println("</body></html>");
    }
}
