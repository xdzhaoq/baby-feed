package com.youyou.nursing.domain;

import java.util.Date;
import javax.validation.constraints.NotNull;
import com.fasterxml.jackson.annotation.JsonFormat;

/** 标记 / 撤销接种 */
public class NcVaccineMark
{
    @NotNull(message = "请选择宝宝")
    private Long babyId;
    @NotNull(message = "请选择疫苗剂次")
    private Long scheduleId;
    /** 1已接种 0撤销 */
    private String inoculated;
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date inoculateDate;
    private Long operatorId;
    private String operatorName;

    public Long getBabyId() { return babyId; }
    public void setBabyId(Long babyId) { this.babyId = babyId; }
    public Long getScheduleId() { return scheduleId; }
    public void setScheduleId(Long scheduleId) { this.scheduleId = scheduleId; }
    public String getInoculated() { return inoculated; }
    public void setInoculated(String inoculated) { this.inoculated = inoculated; }
    public Date getInoculateDate() { return inoculateDate; }
    public void setInoculateDate(Date inoculateDate) { this.inoculateDate = inoculateDate; }
    public Long getOperatorId() { return operatorId; }
    public void setOperatorId(Long operatorId) { this.operatorId = operatorId; }
    public String getOperatorName() { return operatorName; }
    public void setOperatorName(String operatorName) { this.operatorName = operatorName; }
}
