package com.youyou.nursing.domain;

import com.youyou.common.core.domain.BaseEntity;

/** 内置知识库 nc_knowledge */
public class NcKnowledge extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long kbId;
    private String category;
    private String title;
    private Integer urgency;
    private String keywords;
    private String content;
    private Integer sortNum;
    private String status;

    public Long getKbId() { return kbId; }
    public void setKbId(Long kbId) { this.kbId = kbId; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public Integer getUrgency() { return urgency; }
    public void setUrgency(Integer urgency) { this.urgency = urgency; }
    public String getKeywords() { return keywords; }
    public void setKeywords(String keywords) { this.keywords = keywords; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public Integer getSortNum() { return sortNum; }
    public void setSortNum(Integer sortNum) { this.sortNum = sortNum; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
