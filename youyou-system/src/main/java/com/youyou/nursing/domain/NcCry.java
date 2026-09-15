package com.youyou.nursing.domain;

import java.util.Date;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.youyou.common.core.domain.BaseEntity;

public class NcCry extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long cryId;
    @NotNull(message = "请选择宝宝")
    private Long babyId;
    @NotNull(message = "开始时间不能为空")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date startTime;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date endTime;
    @NotBlank(message = "请选择程度")
    private String intensity;
    private String possibleCause;
    private String sootheMethods;
    private String sootheEffect;
    private String notes;
    private Long operatorId;
    private String operatorName;
    private Integer rev;
    private String delFlag;
    private String updateByName;

    public Long getCryId() { return cryId; }
    public void setCryId(Long cryId) { this.cryId = cryId; }
    public Long getBabyId() { return babyId; }
    public void setBabyId(Long babyId) { this.babyId = babyId; }
    public Date getStartTime() { return startTime; }
    public void setStartTime(Date startTime) { this.startTime = startTime; }
    public Date getEndTime() { return endTime; }
    public void setEndTime(Date endTime) { this.endTime = endTime; }
    public String getIntensity() { return intensity; }
    public void setIntensity(String intensity) { this.intensity = intensity; }
    public String getPossibleCause() { return possibleCause; }
    public void setPossibleCause(String possibleCause) { this.possibleCause = possibleCause; }
    public String getSootheMethods() { return sootheMethods; }
    public void setSootheMethods(String sootheMethods) { this.sootheMethods = sootheMethods; }
    public String getSootheEffect() { return sootheEffect; }
    public void setSootheEffect(String sootheEffect) { this.sootheEffect = sootheEffect; }
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
