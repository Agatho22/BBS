package utils;

import com.warrenstrange.googleauth.GoogleAuthenticator;
import com.warrenstrange.googleauth.GoogleAuthenticatorKey;

/**
 * OtpUtil 클래스 - Google Authenticator 기반의 OTP(일회용 비밀번호) 기능을 지원
 * 주요 기능:
 *  - OTP 시크릿 키 생성
 *  - OTP QR 코드 URL 생성
 *  - 사용자 입력 코드 검증
 */
public class OtpUtil {

    /**
     * 새로운 OTP 자격 증명을 생성
     * 
     * @return 생성된 시크릿(secret)과 토큰 정보를 담은 GoogleAuthenticatorKey 객체
     * @see GoogleAuthenticator#createCredentials()
     */
    public static GoogleAuthenticatorKey createCredentials() {
        // GoogleAuthenticator 인스턴스 생성
        GoogleAuthenticator gAuth = new GoogleAuthenticator();
        // 시크릿 키와 초기 토큰 정보를 생성하여 반환
        return gAuth.createCredentials();
    }

    /**
     * OTP QR 코드 URL을 생성
     * 이 URL은 사용자가 Google Authenticator 앱에 계정을 추가할 때 사용
     * 
     * @param userID 인증 대상 사용자 식별자
     * @param secret 생성된 OTP 시크릿 키 문자열
     * @return otpauth URI 형식의 QR 코드 URL
     * @see <a href="https://github.com/wstrange/GoogleAuth">GoogleAuth 프로젝트</a>
     */
    public static String getQrCodeURL(String userID, String secret) {
        // otpauth URI : 앱 이름, 사용자 ID, 시크릿, 발행자 정보를 포함
        return "otpauth://totp/MySecureApp:" + userID
                + "?secret=" + secret
                + "&issuer=MySecureApp";
    }

    /**
     * 사용자가 입력한 OTP 코드를 검증
     * 내부적으로 시크릿 키를 기반으로 현재 시간의 유효한 코드인지 확인
     * 
     * @param secret 검증에 사용되는 OTP 시크릿 키
     * @param code 사용자가 입력한 6자리 정수형 OTP 코드
     * @return 검증 성공 시 true, 실패 시 false
     * @see GoogleAuthenticator#authorize(String, int)
     */
    public static boolean verifyCode(String secret, int code) {
        // GoogleAuthenticator를 통해 입력 코드의 유효성을 검사
        GoogleAuthenticator gAuth = new GoogleAuthenticator();
        return gAuth.authorize(secret, code);
    }
}
