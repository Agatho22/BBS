package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.io.InputStream;
import java.util.Properties;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class DBUtil {

    private static final Logger logger = LogManager.getLogger(DBUtil.class);

    private static String url;
    private static String user;
    private static String password;
    private static String driver;

    static {
        try (InputStream in = DBUtil.class.getClassLoader().getResourceAsStream("db.properties")) {
            Properties props = new Properties();
            if (in == null) {
                logger.fatal("db.properties 파일을 찾을 수 없습니다.");
                throw new RuntimeException("DB 설정 파일 누락");
            }

            props.load(in);
            driver = props.getProperty("db.driver");
            url = props.getProperty("db.url");
            user = props.getProperty("db.username");
            password = props.getProperty("db.password");

            Class.forName(driver);
            logger.info("DB 드라이버 로딩 성공");
        } catch (Exception e) {
            logger.fatal("DB 설정 로딩 실패", e);
            throw new RuntimeException("DB 초기화 실패");
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(url, user, password);
    }
}
