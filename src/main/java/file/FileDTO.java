package file;

public class FileDTO {
    private int bbsID;
    private String originalName;
    private String savedName;
    private String mimeType;
    private long size;

    // 기본 생성자
    public FileDTO() {}

    // 전체 필드 생성자
    public FileDTO(int bbsID, String originalName, String savedName, String mimeType, long size) {
        this.bbsID = bbsID;
        this.originalName = originalName;
        this.savedName = savedName;
        this.mimeType = mimeType;
        this.size = size;
    }

    // Getter & Setter
    public int getBbsID() {
        return bbsID;
    }

    public void setBbsID(int bbsID) {
        this.bbsID = bbsID;
    }

    public String getOriginalName() {
        return originalName;
    }

    public void setOriginalName(String originalName) {
        this.originalName = originalName;
    }

    public String getSavedName() {
        return savedName;
    }

    public void setSavedName(String savedName) {
        this.savedName = savedName;
    }

    public String getMimeType() {
        return mimeType;
    }

    public void setMimeType(String mimeType) {
        this.mimeType = mimeType;
    }

    public long getSize() {
        return size;
    }

    public void setSize(long size) {
        this.size = size;
    }
}
