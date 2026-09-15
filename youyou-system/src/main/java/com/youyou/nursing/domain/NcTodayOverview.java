package com.youyou.nursing.domain;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;
import com.fasterxml.jackson.annotation.JsonFormat;

/** 仪表盘今日概览 */
public class NcTodayOverview
{
    private Long babyId;
    private String babyName;
    private Integer ageDays;
    private Integer feedCount;
    private BigDecimal feedAmountMl;
    private Integer sleepMinutes;
    private Integer diaperCount;
    private Integer diaperAbnormalCount;
    private Integer peeCount;
    private Integer cryMinutes;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date lastFeedTime;
    private String lastFeedOperator;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date nextFeedTime;
    private Integer unfinishedCare;
    private Integer vaccineSoonCount;
    private List<NcCareItem> careTodos;
    private List<NcAlert> alerts;
    private List<String> onlineNames;
    private List<NcMessageMention> unreadMentions;
    private List<NcMedia> recentMedia;
    private List<NcGrowth> growthPoints;
    private String currentCaretaker;
    private String nextFeedOperator;

    public Long getBabyId() { return babyId; }
    public void setBabyId(Long babyId) { this.babyId = babyId; }
    public String getBabyName() { return babyName; }
    public void setBabyName(String babyName) { this.babyName = babyName; }
    public Integer getFeedCount() { return feedCount; }
    public void setFeedCount(Integer feedCount) { this.feedCount = feedCount; }
    public BigDecimal getFeedAmountMl() { return feedAmountMl; }
    public void setFeedAmountMl(BigDecimal feedAmountMl) { this.feedAmountMl = feedAmountMl; }
    public Integer getSleepMinutes() { return sleepMinutes; }
    public void setSleepMinutes(Integer sleepMinutes) { this.sleepMinutes = sleepMinutes; }
    public Integer getDiaperCount() { return diaperCount; }
    public void setDiaperCount(Integer diaperCount) { this.diaperCount = diaperCount; }
    public Integer getDiaperAbnormalCount() { return diaperAbnormalCount; }
    public void setDiaperAbnormalCount(Integer diaperAbnormalCount) { this.diaperAbnormalCount = diaperAbnormalCount; }
    public Integer getCryMinutes() { return cryMinutes; }
    public void setCryMinutes(Integer cryMinutes) { this.cryMinutes = cryMinutes; }
    public Date getLastFeedTime() { return lastFeedTime; }
    public void setLastFeedTime(Date lastFeedTime) { this.lastFeedTime = lastFeedTime; }
    public String getLastFeedOperator() { return lastFeedOperator; }
    public void setLastFeedOperator(String lastFeedOperator) { this.lastFeedOperator = lastFeedOperator; }
    public Date getNextFeedTime() { return nextFeedTime; }
    public void setNextFeedTime(Date nextFeedTime) { this.nextFeedTime = nextFeedTime; }
    public Integer getUnfinishedCare() { return unfinishedCare; }
    public void setUnfinishedCare(Integer unfinishedCare) { this.unfinishedCare = unfinishedCare; }
    public Integer getAgeDays() { return ageDays; }
    public void setAgeDays(Integer ageDays) { this.ageDays = ageDays; }
    public Integer getPeeCount() { return peeCount; }
    public void setPeeCount(Integer peeCount) { this.peeCount = peeCount; }
    public Integer getVaccineSoonCount() { return vaccineSoonCount; }
    public void setVaccineSoonCount(Integer vaccineSoonCount) { this.vaccineSoonCount = vaccineSoonCount; }
    public List<NcCareItem> getCareTodos() { return careTodos; }
    public void setCareTodos(List<NcCareItem> careTodos) { this.careTodos = careTodos; }
    public List<NcAlert> getAlerts() { return alerts; }
    public void setAlerts(List<NcAlert> alerts) { this.alerts = alerts; }
    public List<String> getOnlineNames() { return onlineNames; }
    public void setOnlineNames(List<String> onlineNames) { this.onlineNames = onlineNames; }
    public List<NcMessageMention> getUnreadMentions() { return unreadMentions; }
    public void setUnreadMentions(List<NcMessageMention> unreadMentions) { this.unreadMentions = unreadMentions; }
    public List<NcMedia> getRecentMedia() { return recentMedia; }
    public void setRecentMedia(List<NcMedia> recentMedia) { this.recentMedia = recentMedia; }
    public List<NcGrowth> getGrowthPoints() { return growthPoints; }
    public void setGrowthPoints(List<NcGrowth> growthPoints) { this.growthPoints = growthPoints; }
    public String getCurrentCaretaker() { return currentCaretaker; }
    public void setCurrentCaretaker(String currentCaretaker) { this.currentCaretaker = currentCaretaker; }
    public String getNextFeedOperator() { return nextFeedOperator; }
    public void setNextFeedOperator(String nextFeedOperator) { this.nextFeedOperator = nextFeedOperator; }
}
