package com.youyou.nursing.domain;

import java.util.Date;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.youyou.common.core.domain.BaseEntity;

public class NcSleep extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long sleepId;
    @NotNull(message = "请选择宝宝")
    private Long babyId;
    @NotNull(message = "入睡时间不能为空")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date startTime;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date endTime;
    @NotBlank(message = "请选择睡眠类型")
    private String sleepType;
    private Integer durationMin;
    private String notes;
    private Long operatorId;
    private String operatorName;
    private Integer rev;
    private String delFlag;
    private String updateByName;

    public Long getSleepId() { return sleepId; }
    public void setSleepId(Long sleepId) { this.sleepId = sleepId; }
    public Long getBabyId() { return babyId; }
    public void setBabyId(Long babyId) { this.babyId = babyId; }
    public Date getStartTime() { return startTime; }
    public void setStartTime(Date startTime) { this.startTime = startTime; }
    public Date getEndTime() { return endTime; }
    public void setEndTime(Date endTime) { this.endTime = endTime; }
    public String getSleepType() { return sleepType; }
    public void setSleepType(String sleepType) { this.sleepType = sleepType; }
    public Integer getDurationMin() { return durationMin; }
    public void setDurationMin(Integer durationMin) { this.durationMin = durationMin; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
    public Long getOperatorId() { return operatorId; }
    public void setOperatorId(Long operatorId) { this.operatorId = operatorId; }
    public String getOperatorName() { return operatorName; }
    public void setOperatorName(String operatorName) { this.operatorName = operatorName; }
    public Integer getRev() { return rev; }
    public void setRev(Integer rev) { this.rev = rev; }
    public String getDelFlag() { return delFlag; }
    public void setDelFlag(String delFlag) { this.delFlag = delFlag; }
    public String getUpdateByName() { return updateByName; }
    public void setUpdateByName(String updateByName) { this.updateByName = updateByName; }
}
