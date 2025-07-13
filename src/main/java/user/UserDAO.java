package user;

import java.sql.*;
import java.security.SecureRandom;
import java.util.Properties;
import java.io.InputStream;
import java.util.ArrayList;
import java.security.MessageDigest;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class UserDAO implements AutoCloseable {
    private Connection conn;
    private static final Logger logger = LogManager.getLogger(UserDAO.class);

    public UserDAO() {
        try {
            Properties props = new Properties();
            try (InputStream input = getClass().getClassLoader().getResourceAsStream("db.properties")) {
                if (input == null) {
                    throw new IllegalStateException("db.properties 파일을 찾을 수 없습니다.");
                }
                props.load(input);
            }

            String dbURL = props.getProperty("db.url");
            String dbID = props.getProperty("db.username");
            String dbPassword = props.getProperty("db.password");
            String dbDriver = props.getProperty("db.driver");

            Class.forName(dbDriver);
            conn = DriverManager.getConnection(dbURL, dbID, dbPassword);
        } catch (Exception e) {
            logger.fatal("DB 연결 실패", e);
            throw new RuntimeException("DB 연결 실패", e);
        }
    }

    @Override
    public void close() {
        try {
            if (conn != null)
                conn.close();
        } catch (SQLException e) {
            logger.warn("Connection 닫기 실패", e);
        }
    }

    private void logAndThrow(String message, Exception e) {
        logger.error(message, e);
        throw new RuntimeException(message, e);
    }

    public String hashSHA256(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : hash)
                sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            logAndThrow("hashSHA256 실패", e);
            return null;
        }
    }

    public String getSHA256WithSalt(String password, String salt) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest((password + salt).getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : hash)
                sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            logAndThrow("getSHA256WithSalt 실패", e);
            return null;
        }
    }

    public String generateSalt() {
        SecureRandom random = new SecureRandom();
        byte[] salt = new byte[16];
        random.nextBytes(salt);
        StringBuilder sb = new StringBuilder();
        for (byte b : salt)
            sb.append(String.format("%02x", b));
        return sb.toString();
    }

    public int login(String userID, String userPassword) {
        String sql = "SELECT userPassword, salt FROM USER WHERE userID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userID);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    String dbPassword = rs.getString("userPassword");
                    String dbSalt = rs.getString("salt");
                    String inputHash = (dbSalt == null || dbSalt.isEmpty())
                            ? hashSHA256(userPassword)
                            : getSHA256WithSalt(userPassword, dbSalt);
                    return dbPassword.equals(inputHash) ? 1 : 0;
                } else {
                    return -1;
                }
            }
        } catch (SQLException e) {
            logAndThrow("login() 실패", e);
            return -2;
        }
    }

    public boolean isAccountLocked(String userID) {
        String sql = "SELECT loginFailCount, lastFailTime FROM USER WHERE userID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userID);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    int failCount = rs.getInt("loginFailCount");
                    Timestamp lastFailTime = rs.getTimestamp("lastFailTime");
                    if (failCount >= 3 && lastFailTime != null) {
                        long now = System.currentTimeMillis();
                        long diff = now - lastFailTime.getTime();
                        if (diff < 60 * 1000) {
                            return true;
                        } else {
                            resetFailCount(userID);
                        }
                    }
                }
            }
        } catch (SQLException e) {
            logAndThrow("isAccountLocked() 실패", e);
        }
        return false;
    }

    public void resetFailCount(String userID) {
        String sql = "UPDATE USER SET loginFailCount = 0, lastFailTime = NULL WHERE userID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userID);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            logAndThrow("resetFailCount() 실패", e);
        }
    }

    public void increaseFailCount(String userID) {
        String sql = "UPDATE USER SET loginFailCount = loginFailCount + 1, lastFailTime = NOW() WHERE userID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userID);
            pstmt.executeUpdate();
        } catch (SQLException e) {
            logAndThrow("increaseFailCount() 실패", e);
        }
    }

    public boolean isDeactivated(String userID) {
        String sql = "SELECT status FROM USER WHERE userID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userID);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    String status = rs.getString("status");
                    return "deactivated".equalsIgnoreCase(status) || "withdrawn".equalsIgnoreCase(status);
                }
            }
        } catch (SQLException e) {
            logAndThrow("isDeactivated() 실패", e);
        }
        return false;
    }

    public int adminCheck(String userID) {
        String sql = "SELECT admin FROM USER WHERE userID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userID);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next())
                    return rs.getInt("admin");
            }
        } catch (SQLException e) {
            logAndThrow("adminCheck() 실패", e);
        }
        return 0;
    }

    public ArrayList<User> getUserList() {
        ArrayList<User> list = new ArrayList<>();
        String sql = "SELECT userID, userPassword, userName, userEmail FROM USER";
        try (PreparedStatement pstmt = conn.prepareStatement(sql); ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                User user = new User();
                user.setUserID(rs.getString("userID"));
                user.setUserPassword(rs.getString("userPassword"));
                user.setUserName(rs.getString("userName"));
                user.setUserEmail(rs.getString("userEmail"));
                list.add(user);
            }
        } catch (SQLException e) {
            logAndThrow("getUserList() 실패", e);
        }
        return list;
    }

    public int join(User user, String salt) {
        String sql = "INSERT INTO USER (userID, userPassword, userName, userEmail, admin, salt, loginFailCount, isLocked, lastFailTime) VALUES (?, ?, ?, ?, 0, ?, 0, FALSE, NULL)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, user.getUserID());
            pstmt.setString(2, user.getUserPassword());
            pstmt.setString(3, user.getUserName());
            pstmt.setString(4, user.getUserEmail());
            pstmt.setString(5, salt);
            return pstmt.executeUpdate();
        } catch (SQLIntegrityConstraintViolationException e) {
            logger.warn("join() - 아이디 중복", e);
            return -1;
        } catch (SQLException e) {
            logAndThrow("join() 실패", e);
            return -2;
        }
    }

    public int updatePassword(String userID, String newPassword) {
        String sql = "UPDATE USER SET userPassword = ?, salt = ? WHERE userID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            String salt = generateSalt();
            String hashedPassword = getSHA256WithSalt(newPassword, salt);
            pstmt.setString(1, hashedPassword);
            pstmt.setString(2, salt);
            pstmt.setString(3, userID);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            logAndThrow("updatePassword() 실패", e);
            return -1;
        }
    }

    // [추가] 비밀번호 포함 사용자 정보 수정
    public int userUpdateWithPassword(User user, String oldUserID, String salt) {
        String sql = "UPDATE USER SET userID = ?, userPassword = ?, userName = ?, userEmail = ?, admin = ?, salt = ? WHERE userID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, user.getUserID());
            pstmt.setString(2, user.getUserPassword());
            pstmt.setString(3, user.getUserName());
            pstmt.setString(4, user.getUserEmail());
            pstmt.setInt(5, "admin".equals(user.getAdmin()) ? 1 : 0);
            pstmt.setString(6, salt);
            pstmt.setString(7, oldUserID);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            logAndThrow("userUpdateWithPassword() 실패", e);
            return -1;
        }
    }

    // [추가] 비밀번호 없이 사용자 정보만 수정
    public int userUpdateWithoutPassword(User user, String oldUserID) {
        String sql = "UPDATE USER SET userID = ?, userName = ?, userEmail = ?, admin = ? WHERE userID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, user.getUserID());
            pstmt.setString(2, user.getUserName());
            pstmt.setString(3, user.getUserEmail());
            pstmt.setInt(4, "admin".equals(user.getAdmin()) ? 1 : 0);
            pstmt.setString(5, oldUserID);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            logAndThrow("userUpdateWithoutPassword() 실패", e);
            return -1;
        }
    }

    public int deleteUser(String userID, String userPassword) {
        String sql = "SELECT userPassword, salt FROM USER WHERE userID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userID);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    String dbPassword = rs.getString("userPassword");
                    String salt = rs.getString("salt");
                    String inputHash = (salt == null || salt.isEmpty()) ? hashSHA256(userPassword)
                            : getSHA256WithSalt(userPassword, salt);
                    if (dbPassword.equals(inputHash)) {
                        String deleteSQL = "DELETE FROM USER WHERE userID = ?";
                        try (PreparedStatement deletePstmt = conn.prepareStatement(deleteSQL)) {
                            deletePstmt.setString(1, userID);
                            return deletePstmt.executeUpdate();
                        }
                    } else {
                        return 0;
                    }
                } else {
                    return -1;
                }
            }
        } catch (SQLException e) {
            logAndThrow("deleteUser() 실패", e);
            return -2;
        }
    }

    public boolean deleteUser(String userID) {
        String sql = "DELETE FROM USER WHERE userID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userID);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            logAndThrow("deleteUser(admin) 실패", e);
            return false;
        }
    }

    public String findUserID(String name, String email) {
        String sql = "SELECT userID FROM USER WHERE userName = ? AND userEmail = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, name);
            pstmt.setString(2, email);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next())
                    return rs.getString("userID");
            }
        } catch (SQLException e) {
            logAndThrow("findUserID() 실패", e);
        }
        return null;
    }

    public boolean saveOtpSecret(String userID, String secret) {
        String sql = "UPDATE USER SET otpSecret = ? WHERE userID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, secret);
            pstmt.setString(2, userID);
            return pstmt.executeUpdate() == 1;
        } catch (SQLException e) {
            logAndThrow("saveOtpSecret() 실패", e);
            return false;
        }
    }

    public User getUserByID(String userID) {
        String sql = "SELECT userID, userName, userEmail, admin FROM USER WHERE userID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userID);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setUserID(rs.getString("userID"));
                    user.setUserName(rs.getString("userName"));
                    user.setUserEmail(rs.getString("userEmail"));
                    user.setAdmin(rs.getInt("admin") == 1 ? "admin" : "user");
                    return user;
                }
            }
        } catch (SQLException e) {
            logAndThrow("getUserByID() 실패", e);
        }
        return null;
    }

}
