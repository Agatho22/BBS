package bbs;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.sql.*;
import java.util.ArrayList;
import java.util.Properties;

import exception.DataAccessException;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class BbsDAO implements AutoCloseable {

    private static final Logger logger = LogManager.getLogger(BbsDAO.class);
    private final Properties props = new Properties();

    public BbsDAO() {
        try (InputStream input = getClass().getClassLoader().getResourceAsStream("db.properties")) {
            if (input == null) {
                throw new FileNotFoundException("db.properties 파일을 찾을 수 없습니다.");
            }
            props.load(input);
        } catch (IOException e) {
            logger.fatal("DB 설정 파일 로딩 실패", e);
            throw new DataAccessException("DB 설정 파일 로딩 실패", e);
        }
    }

    private Connection getConnection() throws SQLException, ClassNotFoundException {
        try {
            String driver = props.getProperty("db.driver");
            String url = props.getProperty("db.url");
            String username = props.getProperty("db.username");
            String password = props.getProperty("db.password");

            Class.forName(driver);
            return DriverManager.getConnection(url, username, password);
        } catch (SQLException | ClassNotFoundException e) {
            logger.error("DB 연결 실패", e);
            throw new DataAccessException("DB 연결 실패", e);
        }
    }

    @Override
    public void close() {
        // DAO 자원 해제 로직은 현재 없음
    }

    public Bbs getBbs(int bbsID) {
        String SQL = "SELECT * FROM BBS WHERE bbsID = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(SQL)) {
            pstmt.setInt(1, bbsID);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return mapBbs(rs);
            }
        } catch (Exception e) {
            logger.error("getBbs 실패", e);
            throw new DataAccessException("게시글 조회 실패", e);
        }
        return null;
    }

    public int write(Bbs bbs) {
        String SQL = "INSERT INTO BBS (bbsTitle, userID, bbsDate, bbsContent, bbsAvailable, isSecret) VALUES (?, ?, NOW(), ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(SQL, Statement.RETURN_GENERATED_KEYS)) {
            pstmt.setString(1, bbs.getBbsTitle());
            pstmt.setString(2, bbs.getUserID());
            pstmt.setString(3, bbs.getBbsContent());
            pstmt.setInt(4, 1); // bbsAvailable
            pstmt.setString(5, bbs.getIsSecret());

            pstmt.executeUpdate();

            try (ResultSet rs = pstmt.getGeneratedKeys()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            logger.error("write 실패", e);
            throw new DataAccessException("게시글 작성 실패", e);
        }
        return -1;
    }

    public int delete(int bbsID) {
        String SQL = "UPDATE BBS SET bbsAvailable = 0 WHERE bbsID = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(SQL)) {
            pstmt.setInt(1, bbsID);
            return pstmt.executeUpdate();
        } catch (Exception e) {
            logger.error("delete 실패", e);
            throw new DataAccessException("게시글 삭제 실패", e);
        }
    }

    public int update(int bbsID, String bbsTitle, String bbsContent) {
        String SQL = "UPDATE BBS SET bbsTitle = ?, bbsContent = ? WHERE bbsID = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(SQL)) {
            pstmt.setString(1, bbsTitle);
            pstmt.setString(2, bbsContent);
            pstmt.setInt(3, bbsID);
            return pstmt.executeUpdate();
        } catch (Exception e) {
            logger.error("update 실패", e);
            throw new DataAccessException("게시글 수정 실패", e);
        }
    }

    public ArrayList<Bbs> getList(int pageNumber) {
        ArrayList<Bbs> list = new ArrayList<>();
        String SQL = "SELECT * FROM BBS WHERE bbsAvailable = 1 ORDER BY bbsID DESC LIMIT ?, 10";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(SQL)) {
            pstmt.setInt(1, (pageNumber - 1) * 10);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapBbs(rs));
                }
            }
        } catch (Exception e) {
            logger.error("getList 실패", e);
            throw new DataAccessException("게시글 목록 조회 실패", e);
        }
        return list;
    }

    public boolean nextPage(int pageNumber) {
        String SQL = "SELECT 1 FROM BBS WHERE bbsAvailable = 1 LIMIT ?, 1";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(SQL)) {
            pstmt.setInt(1, pageNumber * 10);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            logger.error("nextPage 실패", e);
            throw new DataAccessException("다음 페이지 유무 확인 실패", e);
        }
    }

    public ArrayList<Bbs> searchList(String keyword, int pageNumber) {
        ArrayList<Bbs> list = new ArrayList<>();
        String SQL = "SELECT * FROM BBS WHERE bbsAvailable = 1 AND (bbsTitle LIKE ? OR bbsContent LIKE ?) ORDER BY bbsID DESC LIMIT ?, 10";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(SQL)) {
            pstmt.setString(1, "%" + keyword + "%");
            pstmt.setString(2, "%" + keyword + "%");
            pstmt.setInt(3, (pageNumber - 1) * 10);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapBbs(rs));
                }
            }
        } catch (Exception e) {
            logger.error("searchList 실패", e);
            throw new DataAccessException("검색 결과 조회 실패", e);
        }
        return list;
    }

    public String getRealName(int bbsID) {
        String SQL = "SELECT fileRealName FROM FileBbsMapping WHERE bbsID = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(SQL)) {
            pstmt.setInt(1, bbsID);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getString("fileRealName");
            }
        } catch (Exception e) {
            logger.error("getRealName 실패", e);
            throw new DataAccessException("파일 이름 조회 실패", e);
        }
        return null;
    }

    public ArrayList<Integer> findBbsID(String userID) {
        ArrayList<Integer> list = new ArrayList<>();
        String SQL = "SELECT bbsID FROM BBS WHERE userID = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(SQL)) {
            pstmt.setString(1, userID);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getInt("bbsID"));
                }
            }
        } catch (Exception e) {
            logger.error("findBbsID 실패", e);
            throw new DataAccessException("작성 게시글 ID 조회 실패", e);
        }
        return list;
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
