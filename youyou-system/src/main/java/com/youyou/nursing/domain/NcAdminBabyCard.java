package com.youyou.nursing.domain;

import java.util.Date;
import java.util.List;
import com.fasterxml.jackson.annotation.JsonFormat;

/** 管理员家庭总览里的宝宝卡片 */
public class NcAdminBabyCard
{
    private Long babyId;
    private String babyName;
    private Integer ageDays;
    private String momUserName;
    private Integer memberCount;
    private Integer onlineCount;
    private Integer unfinishedCare;
    private Integer feedCount;
    private Integer peeCount;
    private Integer familyMemberCount;
    private String memberNames;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date lastFeedTime;
    private String lastFeedOperator;
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date birthDate;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date createTime;
    private Boolean incomplete;
    /** red / yellow / none */
    private String alertLevel;
    private String alertTitle;
    private List<NcAlert> alerts;

    public Long getBabyId() { return babyId; }
    public void setBabyId(Long babyId) { this.babyId = babyId; }
    public String getBabyName() { return babyName; }
    public void setBabyName(String babyName) { this.babyName = babyName; }
    public Integer getAgeDays() { return ageDays; }
    public void setAgeDays(Integer ageDays) { this.ageDays = ageDays; }
    public String getMomUserName() { return momUserName; }
    public void setMomUserName(String momUserName) { this.momUserName = momUserName; }
    public Integer getMemberCount() { return memberCount; }
    public void setMemberCount(Integer memberCount) { this.memberCount = memberCount; }
    public Integer getOnlineCount() { return onlineCount; }
    public void setOnlineCount(Integer onlineCount) { this.onlineCount = onlineCount; }
    public Integer getFamilyMemberCount() { return familyMemberCount; }
    public void setFamilyMemberCount(Integer familyMemberCount) { this.familyMemberCount = familyMemberCount; }
    public String getMemberNames() { return memberNames; }
    public void setMemberNames(String memberNames) { this.memberNames = memberNames; }
    public Integer getUnfinishedCare() { return unfinishedCare; }
    public void setUnfinishedCare(Integer unfinishedCare) { this.unfinishedCare = unfinishedCare; }
    public Integer getFeedCount() { return feedCount; }
    public void setFeedCount(Integer feedCount) { this.feedCount = feedCount; }
    public Integer getPeeCount() { return peeCount; }
    public void setPeeCount(Integer peeCount) { this.peeCount = peeCount; }
    public Date getLastFeedTime() { return lastFeedTime; }
    public void setLastFeedTime(Date lastFeedTime) { this.lastFeedTime = lastFeedTime; }
    public String getLastFeedOperator() { return lastFeedOperator; }
    public void setLastFeedOperator(String lastFeedOperator) { this.lastFeedOperator = lastFeedOperator; }
    public Date getBirthDate() { return birthDate; }
    public void setBirthDate(Date birthDate) { this.birthDate = birthDate; }
    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date createTime) { this.createTime = createTime; }
    public Boolean getIncomplete() { return incomplete; }
    public void setIncomplete(Boolean incomplete) { this.incomplete = incomplete; }
    public String getAlertLevel() { return alertLevel; }
    public void setAlertLevel(String alertLevel) { this.alertLevel = alertLevel; }
    public String getAlertTitle() { return alertTitle; }
    public void setAlertTitle(String alertTitle) { this.alertTitle = alertTitle; }
    public List<NcAlert> getAlerts() { return alerts; }
    public void setAlerts(List<NcAlert> alerts) { this.alerts = alerts; }
}
