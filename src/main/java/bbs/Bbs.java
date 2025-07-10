package bbs;

public class Bbs {

    private int bbsID;
    private String bbsTitle;
    private String userID;
    private String bbsDate;
    private String bbsContent;
    private int bbsAvailable;
    private String isSecret; // 비밀글 여부 필드 추가

    public int getBbsID() {
        return bbsID;
    }

    public void setBbsID(int bbsID) {
        this.bbsID = bbsID;
    }

    public String getBbsTitle() {
        return bbsTitle;
    }

    public void setBbsTitle(String bbsTitle) {
        this.bbsTitle = bbsTitle;
    }

    public String getUserID() {
        return userID;
    }

    public void setUserID(String userID) {
        this.userID = userID;
    }

    public String getBbsDate() {
        return bbsDate;
    }

    public void setBbsDate(String bbsDate) {
        this.bbsDate = bbsDate;
    }

    public String getBbsContent() {
        return bbsContent;
    }

    public void setBbsContent(String bbsContent) {
        this.bbsContent = bbsContent;
    }

    public int getBbsAvailable() {
        return bbsAvailable;
    }

    public void setBbsAvailable(int bbsAvailable) {
        this.bbsAvailable = bbsAvailable;
    }

    // 비밀글 여부 getter/setter
    public String getIsSecret() {
        return isSecret;
    }

    public void setIsSecret(String isSecret) {
        this.isSecret = isSecret;
    }
}
