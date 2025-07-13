package reply;

import java.sql.Timestamp;

public class Reply {
    private int replyID;
    private int bbsID;
    private String userID;
    private String replyContent;
    private Timestamp replyDate;

    public Reply(int replyID, int bbsID, String userID, String replyContent, Timestamp replyDate) {
        this.replyID = replyID;
        this.bbsID = bbsID;
        this.userID = userID;
        this.replyContent = replyContent;
        this.replyDate = replyDate;
    }

    // Getter methods
    public int getReplyID() {
        return replyID;
    }

    public int getBbsID() {
        return bbsID;
    }

    public String getUserID() {
        return userID;
    }

    public String getReplyContent() {
        return replyContent;
    }

    public Timestamp getReplyDate() {
        return replyDate;
    }
}
