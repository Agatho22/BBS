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
 * 관리자 계정의 OTP 등록을 위한 서블릿.
 * 관리자 로그인 후 최초로 OTP를 등록할 때 접근되는 엔드포인트(API가 서버에서 리소스에 접근할 수 있도록 가능하게 하는 URL)
 */
@WebServlet("/registerOtp")
public class OtpRegistrationServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    /**
     * GET 요청 시 OTP 키를 생성하고 QR코드를 출력하는 HTML 페이지를 응답
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        String userID = (String) session.getAttribute("pendingAdmin"); // OTP 등록 대기 중인 관리자 ID

        // 세션이 새로 생성되었거나, pendingAdmin이 없거나, 관리자가 아닌 경우 접근 차단
       // pendingAdmin - HttpSession 객체의 속성(attribute) 이름으로, OTP 등록이 완료되기 전 단계에서 로그인한 '관리자' 사용자를 임시로 식별하기 위해 저장해둔 ID 값
        if (session.isNew() || userID == null || new UserDAO().adminCheck(userID) != 1) {
            response.setContentType("text/html; charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.println("<script>alert('관리자만 접근할 수 있습니다.'); location.href='login.jsp';</script>");
            return;
        }

        // OTP 비밀키 생성
        GoogleAuthenticatorKey key = OtpUtil.createCredentials(); // GoogleAuthenticator용 키 생성
        String secret = key.getKey(); // 비밀 키 추출

        // QR코드 URL 생성 (앱에 등록할 수 있도록)
        String qrUrl = OtpUtil.getQrCodeURL(userID, secret); // TOTP URI 생성
        String encodedQrUrl = URLEncoder.encode(qrUrl, "UTF-8"); // URL 인코딩 (QR API에 맞게)

        // 세션에 secret 저장 (나중에 인증 시 비교용)
        session.setAttribute("otpSecret", secret);

        // HTML 응답 작성
        response.setContentType("text/html; charset=UTF-8");
        PrintWriter out = response.getWriter();

        out.println("<!DOCTYPE html>");
        out.println("<html><head><meta charset='UTF-8'><title>OTP 등록</title></head><body>");
        out.println("<h2>OTP 앱 등록</h2>");
        out.println("<p>Google Authenticator 앱에서 아래 QR코드를 스캔하세요.</p>");

        // QR 코드 이미지 출력 (QR Code Generator API 활용) -> 해당 QR 기능 2023년에 종료(수정해야함)
        out.println("<img src='https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=" + encodedQrUrl + "' alt='QR Code'>");

        // 수동 입력용 키 제공
        out.println("<p>또는 수동으로 입력: <b>" + secret + "</b></p>");

        // 다음 단계로 이동
        out.println("<p><a href='verifyOtp.jsp'>OTP 입력하기</a></p>");
        out.println("</body></html>");
    }
}
