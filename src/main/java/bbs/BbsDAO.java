package bbs;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.sql.*;
import java.util.ArrayList;
import java.util.Properties;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class BbsDAO implements AutoCloseable {

    private static final Logger logger = LogManager.getLogger(BbsDAO.class);
    private Connection conn;

    public BbsDAO() {
        Properties props = new Properties();

        try (InputStream input = getClass().getClassLoader().getResourceAsStream("db.properties")) {
            if (input == null) {
                logger.error("db.properties 파일을 찾을 수 없습니다.");
                throw new FileNotFoundException("db.properties 파일을 찾을 수 없습니다.");
            }
            props.load(input);
        } catch (IOException e) {
            logger.fatal("DB 설정 파일 로딩 실패", e);
            throw new RuntimeException("DB 설정 파일 로딩 실패", e);
        }

        try {
            String driver = props.getProperty("db.driver");
            String url = props.getProperty("db.url");
            String username = props.getProperty("db.username");
            String password = props.getProperty("db.password");

            Class.forName(driver);
            conn = DriverManager.getConnection(url, username, password);
        } catch (ClassNotFoundException e) {
            logger.fatal("JDBC 드라이버 로드 실패", e);
            throw new RuntimeException("JDBC 드라이버 로드 실패", e);
        } catch (SQLException e) {
            logger.fatal("DB 연결 실패", e);
            throw new RuntimeException("DB 연결 실패", e);
        }
    }

    @Override
    public void close() {
        if (conn != null) {
            try {
                conn.close();
                logger.info("DB 연결 정상 종료");
            } catch (SQLException e) {
                logger.warn("DB 연결 종료 중 오류", e);
            }
        }
    }

    public Bbs getBbs(int bbsID) {
        String SQL = "SELECT * FROM BBS WHERE bbsID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(SQL)) {
            pstmt.setInt(1, bbsID);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next())
                    return mapBbs(rs);
            }
        } catch (SQLException e) {
            logger.error("getBbs 실패", e);
        }
        return null;
    }

    public int write(String bbsTitle, String userID, String bbsContent, String isSecret) {
        int nextID = getNext();
        if (nextID == -1)
            throw new IllegalStateException("bbsID 값 가져오기 실패");

        String date = getDate();
        if (date == null)
            throw new IllegalStateException("날짜 가져오기 실패");

        String SQL = "INSERT INTO BBS (bbsID, bbsTitle, userID, bbsDate, bbsContent, bbsAvailable, isSecret) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(SQL)) {
            pstmt.setInt(1, nextID);
            pstmt.setString(2, bbsTitle);
            pstmt.setString(3, userID);
            pstmt.setString(4, date);
            pstmt.setString(5, bbsContent);
            pstmt.setInt(6, 1);
            pstmt.setString(7, isSecret);
            pstmt.executeUpdate();
            return nextID;
        } catch (SQLException e) {
            logger.error("write 실패", e);
            return -1;
        }
    }

    public int delete(int bbsID) {
        String SQL = "UPDATE BBS SET bbsAvailable = 0 WHERE bbsID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(SQL)) {
            pstmt.setInt(1, bbsID);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            logger.error("delete 실패", e);
            return -1;
        }
    }

    public int update(int bbsID, String bbsTitle, String bbsContent) {
        String SQL = "UPDATE BBS SET bbsTitle = ?, bbsContent = ? WHERE bbsID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(SQL)) {
            pstmt.setString(1, bbsTitle);
            pstmt.setString(2, bbsContent);
            pstmt.setInt(3, bbsID);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            logger.error("update 실패", e);
            return -1;
        }
    }

    public String getDate() {
        String SQL = "SELECT NOW()";
        try (PreparedStatement pstmt = conn.prepareStatement(SQL);
                ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                return rs.getString(1);
            }
        } catch (SQLException e) {
            logger.error("getDate 실패", e);
        }
        return null;
    }

    public int getNext() {
        String SQL = "SELECT bbsID FROM BBS ORDER BY bbsID DESC LIMIT 1";
        try (PreparedStatement pstmt = conn.prepareStatement(SQL);
                ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1) + 1;
            }
            return 1;
        } catch (SQLException e) {
            logger.error("getNext 실패", e);
        }
        return -1;
    }

    public boolean nextPage(int pageNumber) {
        int thresholdID = getNext() - (pageNumber - 1) * 10;
        String SQL = "SELECT 1 FROM BBS WHERE bbsID < ? AND bbsAvailable = 1 LIMIT 1";
        try (PreparedStatement pstmt = conn.prepareStatement(SQL)) {
            pstmt.setInt(1, thresholdID);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            logger.error("nextPage 실패", e);
        }
        return false;
    }

    public ArrayList<Bbs> getList(int pageNumber) {
        ArrayList<Bbs> list = new ArrayList<>();
        String SQL = "SELECT * FROM BBS WHERE bbsID < ? AND bbsAvailable = 1 ORDER BY bbsID DESC LIMIT 10";
        try (PreparedStatement pstmt = conn.prepareStatement(SQL)) {
            pstmt.setInt(1, getNext() - (pageNumber - 1) * 10);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapBbs(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("getList 실패", e);
        }
        return list;
    }

    public ArrayList<Bbs> searchList(String keyword, int pageNumber) {
        ArrayList<Bbs> list = new ArrayList<>();
        String SQL = "SELECT * FROM BBS WHERE bbsAvailable = 1 AND bbsTitle LIKE ? AND bbsID < ? ORDER BY bbsID DESC LIMIT 10";
        try (PreparedStatement pstmt = conn.prepareStatement(SQL)) {
            pstmt.setString(1, "%" + keyword + "%");
            pstmt.setInt(2, getNext() - (pageNumber - 1) * 10);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapBbs(rs));
                }
            }
        } catch (SQLException e) {
            logger.error("searchList 실패", e);
        }
        return list;
    }

    public String getRealName(int bbsID) {
        String SQL = "SELECT fileRealName FROM FileBbsMapping WHERE bbsID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(SQL)) {
            pstmt.setInt(1, bbsID);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next())
                    return rs.getString("fileRealName");
            }
        } catch (SQLException e) {
            logger.error("getRealName 실패", e);
        }
        return null;
    }

    public ArrayList<Integer> findBbsID(String userID) {
        ArrayList<Integer> list = new ArrayList<>();
        String SQL = "SELECT bbsID FROM BBS WHERE userID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(SQL)) {
            pstmt.setString(1, userID);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getInt("bbsID"));
                }
            }
        } catch (SQLException e) {
            logger.error("findBbsID 실패", e);
        }
        return list;
    }

    public int getMaxBbsID() {
        String SQL = "SELECT COALESCE(MAX(bbsID), 0) AS maxBbsID FROM BBS";
        try (PreparedStatement pstmt = conn.prepareStatement(SQL);
                ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("maxBbsID");
            }
        } catch (SQLException e) {
            logger.error("getMaxBbsID 실패", e);
        }
        return 0;
    }

    private Bbs mapBbs(ResultSet rs) throws SQLException {
        Bbs bbs = new Bbs();
        bbs.setBbsID(rs.getInt("bbsID"));
        bbs.setBbsTitle(rs.getString("bbsTitle"));
        bbs.setUserID(rs.getString("userID"));
        bbs.setBbsDate(rs.getString("bbsDate"));
        bbs.setBbsContent(rs.getString("bbsContent"));
        bbs.setBbsAvailable(rs.getInt("bbsAvailable"));
        bbs.setIsSecret(rs.getString("isSecret"));
        return bbs;
    }
}
