package com.youyou.nursing.domain;

import java.math.BigDecimal;
import java.util.Date;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.youyou.common.core.domain.BaseEntity;

public class NcFeeding extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long feedingId;

    @NotNull(message = "请选择宝宝")
    private Long babyId;

    @NotNull(message = "喂养时间不能为空")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date feedTime;

    @NotBlank(message = "请选择喂养方式")
    private String feedMethod;

    private BigDecimal amountMl;

    private Integer durationMin;

    private Integer leftDuration;

    private Integer rightDuration;

    private String burped;

    private Integer burpDuration;

    private String burpEffect;

    private String afterBehavior;

    private String notes;

    private Long operatorId;

    private String operatorName;

    private Integer rev;

    private String delFlag;

    private String updateByName;

    public Long getFeedingId() { return feedingId; }
    public void setFeedingId(Long feedingId) { this.feedingId = feedingId; }
    public Long getBabyId() { return babyId; }
    public void setBabyId(Long babyId) { this.babyId = babyId; }
    public Date getFeedTime() { return feedTime; }
    public void setFeedTime(Date feedTime) { this.feedTime = feedTime; }
    public String getFeedMethod() { return feedMethod; }
    public void setFeedMethod(String feedMethod) { this.feedMethod = feedMethod; }
    public BigDecimal getAmountMl() { return amountMl; }
    public void setAmountMl(BigDecimal amountMl) { this.amountMl = amountMl; }
    public Integer getDurationMin() { return durationMin; }
    public void setDurationMin(Integer durationMin) { this.durationMin = durationMin; }
    public Integer getLeftDuration() { return leftDuration; }
    public void setLeftDuration(Integer leftDuration) { this.leftDuration = leftDuration; }
    public Integer getRightDuration() { return rightDuration; }
    public void setRightDuration(Integer rightDuration) { this.rightDuration = rightDuration; }
    public String getBurped() { return burped; }
    public void setBurped(String burped) { this.burped = burped; }
    public Integer getBurpDuration() { return burpDuration; }
    public void setBurpDuration(Integer burpDuration) { this.burpDuration = burpDuration; }
    public String getBurpEffect() { return burpEffect; }
    public void setBurpEffect(String burpEffect) { this.burpEffect = burpEffect; }
    public String getAfterBehavior() { return afterBehavior; }
    public void setAfterBehavior(String afterBehavior) { this.afterBehavior = afterBehavior; }
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
