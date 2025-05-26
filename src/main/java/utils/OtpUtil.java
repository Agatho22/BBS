package utils;

import com.warrenstrange.googleauth.GoogleAuthenticator;
import com.warrenstrange.googleauth.GoogleAuthenticatorKey;

public class OtpUtil {

    public static GoogleAuthenticatorKey createCredentials() {
        GoogleAuthenticator gAuth = new GoogleAuthenticator();
        return gAuth.createCredentials();
    }

    public static String getQrCodeURL(String userID, String secret) {
        return "otpauth://totp/MySecureApp:" + userID + "?secret=" + secret + "&issuer=MySecureApp";
    }

    public static boolean verifyCode(String secret, int code) {
        GoogleAuthenticator gAuth = new GoogleAuthenticator();
        return gAuth.authorize(secret, code);
    }
}
