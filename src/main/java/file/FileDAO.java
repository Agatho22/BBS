package file;

import java.sql.*;
import java.util.ArrayList;
import java.util.Properties;
import java.io.InputStream;
import java.io.File;
import java.io.FileNotFoundException;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

public class FileDAO implements AutoCloseable {
    private static final Logger logger = LogManager.getLogger(FileDAO.class);
    private Connection conn;

    public FileDAO() throws SQLException {
        try {
            Properties props = new Properties();
            try (InputStream input = getClass().getClassLoader().getResourceAsStream("db.properties")) {
                if (input == null) {
                    logger.error("db.properties 파일을 찾을 수 없습니다.");
                    throw new FileNotFoundException("db.properties 파일을 찾을 수 없습니다.");
                }
                props.load(input);
            }

            String driver = props.getProperty("db.driver");
            String url = props.getProperty("db.url");
            String username = props.getProperty("db.username");
            String password = props.getProperty("db.password");

            Class.forName(driver);
            conn = DriverManager.getConnection(url, username, password);
        } catch (ClassNotFoundException | SQLException e) {
            logger.fatal("DB 연결 실패", e);
            throw new SQLException("DB 연결 실패", e);
        } catch (Exception e) {
            logger.fatal("설정 파일 로딩 또는 DB 연결 중 예외 발생", e);
            throw new RuntimeException("설정 파일 로딩 또는 연결 중 오류", e);
        }
    }

    @Override
    public void close() {
        if (conn != null) {
            try {
                conn.close();
                logger.debug("DB 연결 종료");
            } catch (SQLException e) {
                logger.warn("DB 연결 종료 중 예외 발생", e);
            }
        }
    }

    private boolean isBbsIDExists(int bbsID) {
        String sql = "SELECT COUNT(*) FROM BBS WHERE bbsID = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, bbsID);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            logger.error("bbsID 존재 여부 확인 중 오류", e);
            return false;
        }
    }

    public int insertFile(String fileName, String fileRealName, int bbsID) {
        if (!isBbsIDExists(bbsID)) {
            logger.warn("bbsID {}가 존재하지 않아 파일 삽입 중단", bbsID);
            return -1;
        }

        String sql = "INSERT INTO FileBbsMapping (fileName, fileRealName, bbsID) VALUES (?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, fileName);
            pstmt.setString(2, fileRealName);
            pstmt.setInt(3, bbsID);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            logger.error("파일 업로드 중 오류", e);
            return -1;
        }
    }

    public void saveOrUpdate(String fileName, String fileRealName, int bbsID) {
        String checkSQL = "SELECT COUNT(*) FROM FileBbsMapping WHERE bbsID = ?";
        String updateSQL = "UPDATE FileBbsMapping SET fileName = ?, fileRealName = ? WHERE bbsID = ?";
        String insertSQL = "INSERT INTO FileBbsMapping (fileName, fileRealName, bbsID) VALUES (?, ?, ?)";

        try (
                PreparedStatement checkStmt = conn.prepareStatement(checkSQL)) {
            checkStmt.setInt(1, bbsID);
            try (ResultSet rs = checkStmt.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    try (PreparedStatement updateStmt = conn.prepareStatement(updateSQL)) {
                        updateStmt.setString(1, fileName);
                        updateStmt.setString(2, fileRealName);
                        updateStmt.setInt(3, bbsID);
                        updateStmt.executeUpdate();
                    }
                } else {
                    try (PreparedStatement insertStmt = conn.prepareStatement(insertSQL)) {
                        insertStmt.setString(1, fileName);
                        insertStmt.setString(2, fileRealName);
                        insertStmt.setInt(3, bbsID);
                        insertStmt.executeUpdate();
                    }
                }
            }
        } catch (SQLException e) {
            logger.error("파일 정보 저장/업데이트 실패", e);
        }
    }

    public int upload(String fileName, String fileRealName, int bbsID) {
        if (!isBbsIDExists(bbsID)) {
            logger.warn("bbsID {}가 존재하지 않아 파일 업로드 중단", bbsID);
            return -1;
        }

        String SQL = "INSERT INTO FileBbsMapping (fileName, fileRealName, bbsID) VALUES (?, ?, ?)";
        try (PreparedStatement pstmt = conn.prepareStatement(SQL)) {
            pstmt.setString(1, fileName);
            pstmt.setString(2, fileRealName);
            pstmt.setInt(3, bbsID);
            return pstmt.executeUpdate();
        } catch (SQLException e) {
            logger.error("파일 업로드 중 오류", e);
        }
        return -1;
    }

    public void saveOrUpdateFile(String fileName, String fileRealName, int bbsID) {
        String checkSQL = "SELECT COUNT(*) FROM FileBbsMapping WHERE bbsID = ?";
        String updateSQL = "UPDATE FileBbsMapping SET fileName = ?, fileRealName = ? WHERE bbsID = ?";
        String insertSQL = "INSERT INTO FileBbsMapping (fileName, fileRealName, bbsID) VALUES (?, ?, ?)";

        try (PreparedStatement checkStmt = conn.prepareStatement(checkSQL)) {
            checkStmt.setInt(1, bbsID);
            try (ResultSet rs = checkStmt.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    try (PreparedStatement updateStmt = conn.prepareStatement(updateSQL)) {
                        updateStmt.setString(1, fileName);
                        updateStmt.setString(2, fileRealName);
                        updateStmt.setInt(3, bbsID);
                        updateStmt.executeUpdate();
                        logger.info("파일 정보 업데이트 성공 - bbsID: {}", bbsID);
                    }
                } else {
                    try (PreparedStatement insertStmt = conn.prepareStatement(insertSQL)) {
                        insertStmt.setString(1, fileName);
                        insertStmt.setString(2, fileRealName);
                        insertStmt.setInt(3, bbsID);
                        insertStmt.executeUpdate();
                        logger.info("파일 정보 신규 등록 성공 - bbsID: {}", bbsID);
                    }
                }
            }
        } catch (SQLException e) {
            logger.error("파일 정보 저장/수정 중 오류", e);
        }
    }

    public ArrayList<File> getFileList(int bbsID) {
        ArrayList<File> list = new ArrayList<>();
        String sql = "SELECT fileName, fileRealName FROM FileBbsMapping WHERE bbsID = ?";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, bbsID);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(new File(rs.getString("fileName"), rs.getString("fileRealName")));
                }
            }
        } catch (SQLException e) {
            logger.error("파일 목록 조회 중 오류", e);
        }

        return list;
    }

    public ArrayList<String> getRealFileNamesByBbsID(int bbsID) {
        ArrayList<String> fileList = new ArrayList<>();
        String sql = "SELECT fileRealName FROM FileBbsMapping WHERE bbsID = ?";

        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, bbsID);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    fileList.add(rs.getString("fileRealName"));
                }
            }
        } catch (SQLException e) {
            logger.error("bbsID로 파일명 조회 중 오류", e);
        }

        return fileList;
    }
}
