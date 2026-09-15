package com.youyou.nursing.domain;

import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;

/** 留言 @ 提醒 nc_message_mention */
public class NcMessageMention
{
    private Long mentionId;
    private Long messageId;
    private Long babyId;
    private Long mentionedUserId;
    private String mentionedName;
    private String readFlag;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date createTime;

    /** 仪表盘展示 */
    private String content;
    private String authorName;

    public Long getMentionId() { return mentionId; }
    public void setMentionId(Long mentionId) { this.mentionId = mentionId; }
    public Long getMessageId() { return messageId; }
    public void setMessageId(Long messageId) { this.messageId = messageId; }
    public Long getBabyId() { return babyId; }
    public void setBabyId(Long babyId) { this.babyId = babyId; }
    public Long getMentionedUserId() { return mentionedUserId; }
    public void setMentionedUserId(Long mentionedUserId) { this.mentionedUserId = mentionedUserId; }
    public String getMentionedName() { return mentionedName; }
    public void setMentionedName(String mentionedName) { this.mentionedName = mentionedName; }
    public String getReadFlag() { return readFlag; }
    public void setReadFlag(String readFlag) { this.readFlag = readFlag; }
    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date createTime) { this.createTime = createTime; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public String getAuthorName() { return authorName; }
    public void setAuthorName(String authorName) { this.authorName = authorName; }
}
