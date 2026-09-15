package com.youyou.nursing.domain;

import java.math.BigDecimal;
import java.util.Date;
import javax.validation.constraints.NotNull;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.youyou.common.core.domain.BaseEntity;

public class NcGrowth extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long growthId;
    @NotNull(message = "请选择宝宝")
    private Long babyId;
    @NotNull(message = "请选择测量日期")
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date measureDate;
    private BigDecimal weightKg;
    private BigDecimal heightCm;
    private BigDecimal headCm;
    private String notes;
    private Long operatorId;
    private String operatorName;
    private Integer rev;
    private String delFlag;
    private String updateByName;

    public Long getGrowthId() { return growthId; }
    public void setGrowthId(Long growthId) { this.growthId = growthId; }
    public Long getBabyId() { return babyId; }
    public void setBabyId(Long babyId) { this.babyId = babyId; }
    public Date getMeasureDate() { return measureDate; }
    public void setMeasureDate(Date measureDate) { this.measureDate = measureDate; }
    public BigDecimal getWeightKg() { return weightKg; }
    public void setWeightKg(BigDecimal weightKg) { this.weightKg = weightKg; }
    public BigDecimal getHeightCm() { return heightCm; }
    public void setHeightCm(BigDecimal heightCm) { this.heightCm = heightCm; }
    public BigDecimal getHeadCm() { return headCm; }
    public void setHeadCm(BigDecimal headCm) { this.headCm = headCm; }
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
