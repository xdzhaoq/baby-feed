package com.youyou.nursing.domain;

import java.util.List;

/** 超管家庭运营总览 */
public class NcAdminOverview
{
    private Integer babyCount;
    private Integer familyCount;
    private Integer incompleteCount;
    private Integer alertBabyCount;
    private Integer onlinePeopleCount;
    private Integer silentBabyCount;
    private List<NcAdminBabyCard> babies;

    public Integer getBabyCount() { return babyCount; }
    public void setBabyCount(Integer babyCount) { this.babyCount = babyCount; }
    public Integer getFamilyCount() { return familyCount; }
    public void setFamilyCount(Integer familyCount) { this.familyCount = familyCount; }
    public Integer getIncompleteCount() { return incompleteCount; }
    public void setIncompleteCount(Integer incompleteCount) { this.incompleteCount = incompleteCount; }
    public Integer getAlertBabyCount() { return alertBabyCount; }
    public void setAlertBabyCount(Integer alertBabyCount) { this.alertBabyCount = alertBabyCount; }
    public Integer getOnlinePeopleCount() { return onlinePeopleCount; }
    public void setOnlinePeopleCount(Integer onlinePeopleCount) { this.onlinePeopleCount = onlinePeopleCount; }
    public Integer getSilentBabyCount() { return silentBabyCount; }
    public void setSilentBabyCount(Integer silentBabyCount) { this.silentBabyCount = silentBabyCount; }
    public List<NcAdminBabyCard> getBabies() { return babies; }
    public void setBabies(List<NcAdminBabyCard> babies) { this.babies = babies; }
}
