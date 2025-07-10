package exception;

public class DataAccessException extends RuntimeException {
	private static final long serialVersionUID = 1L;
    public DataAccessException(String message, Throwable cause) {
        super(message, cause);
    }
}
// 사용자 정의 예외 클래스
