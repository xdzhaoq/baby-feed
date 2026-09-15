package com.youyou.nursing.domain;

import java.util.Date;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.youyou.common.core.domain.BaseEntity;

public class NcDiaper extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long diaperId;
    @NotNull(message = "请选择宝宝")
    private Long babyId;
    @NotNull(message = "时间不能为空")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date recordTime;
    @NotBlank(message = "请选择类型")
    private String diaperType;
    private String stoolTexture;
    private String notes;
    private Long operatorId;
    private String operatorName;
    private Integer rev;
    private String delFlag;
    private String updateByName;

    public Long getDiaperId() { return diaperId; }
    public void setDiaperId(Long diaperId) { this.diaperId = diaperId; }
    public Long getBabyId() { return babyId; }
    public void setBabyId(Long babyId) { this.babyId = babyId; }
    public Date getRecordTime() { return recordTime; }
    public void setRecordTime(Date recordTime) { this.recordTime = recordTime; }
    public String getDiaperType() { return diaperType; }
    public void setDiaperType(String diaperType) { this.diaperType = diaperType; }
    public String getStoolTexture() { return stoolTexture; }
    public void setStoolTexture(String stoolTexture) { this.stoolTexture = stoolTexture; }
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
