package com.youyou.nursing.domain;

import java.util.List;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import com.youyou.common.core.domain.BaseEntity;

/** 家庭留言 nc_message */
public class NcMessage extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long messageId;
    @NotNull(message = "请选择宝宝")
    private Long babyId;
    @NotBlank(message = "请填写留言")
    @Size(max = 1000, message = "留言不能超过1000个字符")
    private String content;
    private Long authorId;
    private String authorName;
    private String delFlag;

    /** 被 @ 的成员 userId，不落本表 */
    private List<Long> mentionUserIds;

    private List<NcMessageMention> mentions;

    public Long getMessageId() { return messageId; }
    public void setMessageId(Long messageId) { this.messageId = messageId; }
    public Long getBabyId() { return babyId; }
    public void setBabyId(Long babyId) { this.babyId = babyId; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public Long getAuthorId() { return authorId; }
    public void setAuthorId(Long authorId) { this.authorId = authorId; }
    public String getAuthorName() { return authorName; }
    public void setAuthorName(String authorName) { this.authorName = authorName; }
    public String getDelFlag() { return delFlag; }
    public void setDelFlag(String delFlag) { this.delFlag = delFlag; }
    public List<Long> getMentionUserIds() { return mentionUserIds; }
    public void setMentionUserIds(List<Long> mentionUserIds) { this.mentionUserIds = mentionUserIds; }
    public List<NcMessageMention> getMentions() { return mentions; }
    public void setMentions(List<NcMessageMention> mentions) { this.mentions = mentions; }
}
