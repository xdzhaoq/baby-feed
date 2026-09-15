package com.youyou.nursing.domain;

import java.math.BigDecimal;
import java.util.Date;
import javax.validation.constraints.NotNull;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.youyou.common.core.domain.BaseEntity;

public class NcHealthCheck extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long checkId;
    @NotNull(message = "请选择宝宝")
    private Long babyId;
    @NotNull(message = "请选择日期")
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date checkDate;
    private BigDecimal tempAm;
    private BigDecimal tempPm;
    private String jaundice;
    private String umbilical;
    private String spirit;
    private String notes;
    private Long operatorId;
    private String operatorName;
    private Integer rev;
    private String delFlag;
    private String updateByName;

    public Long getCheckId() { return checkId; }
    public void setCheckId(Long checkId) { this.checkId = checkId; }
    public Long getBabyId() { return babyId; }
    public void setBabyId(Long babyId) { this.babyId = babyId; }
    public Date getCheckDate() { return checkDate; }
    public void setCheckDate(Date checkDate) { this.checkDate = checkDate; }
    public BigDecimal getTempAm() { return tempAm; }
    public void setTempAm(BigDecimal tempAm) { this.tempAm = tempAm; }
    public BigDecimal getTempPm() { return tempPm; }
    public void setTempPm(BigDecimal tempPm) { this.tempPm = tempPm; }
    public String getJaundice() { return jaundice; }
    public void setJaundice(String jaundice) { this.jaundice = jaundice; }
    public String getUmbilical() { return umbilical; }
    public void setUmbilical(String umbilical) { this.umbilical = umbilical; }
    public String getSpirit() { return spirit; }
    public void setSpirit(String spirit) { this.spirit = spirit; }
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
