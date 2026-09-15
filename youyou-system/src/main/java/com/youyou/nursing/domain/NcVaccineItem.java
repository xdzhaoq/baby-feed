package com.youyou.nursing.domain;

import java.util.Date;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import com.fasterxml.jackson.annotation.JsonFormat;

/** 疫苗时间表 + 接种状态 */
public class NcVaccineItem
{
    private Long scheduleId;
    private String vaccineCode;
    @NotBlank(message = "疫苗名称不能为空")
    private String vaccineName;
    private Integer doseNo;
    private Integer totalDoses;
    @NotNull(message = "请填写建议日龄")
    private Integer dueAgeDays;
    private Integer remindBefore;
    private Integer sortNum;
    private String remark;
    private Long recordId;
    private String inoculated;
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date inoculateDate;
    private String operatorName;
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date dueDate;
    /** done / overdue / soon / wait */
    private String status;
    private Integer remainDays;

    public Long getScheduleId() { return scheduleId; }
    public void setScheduleId(Long scheduleId) { this.scheduleId = scheduleId; }
    public String getVaccineCode() { return vaccineCode; }
    public void setVaccineCode(String vaccineCode) { this.vaccineCode = vaccineCode; }
    public String getVaccineName() { return vaccineName; }
    public void setVaccineName(String vaccineName) { this.vaccineName = vaccineName; }
    public Integer getDoseNo() { return doseNo; }
    public void setDoseNo(Integer doseNo) { this.doseNo = doseNo; }
    public Integer getTotalDoses() { return totalDoses; }
    public void setTotalDoses(Integer totalDoses) { this.totalDoses = totalDoses; }
    public Integer getDueAgeDays() { return dueAgeDays; }
    public void setDueAgeDays(Integer dueAgeDays) { this.dueAgeDays = dueAgeDays; }
    public Integer getRemindBefore() { return remindBefore; }
    public void setRemindBefore(Integer remindBefore) { this.remindBefore = remindBefore; }
    public Integer getSortNum() { return sortNum; }
    public void setSortNum(Integer sortNum) { this.sortNum = sortNum; }
    public String getRemark() { return remark; }
    public void setRemark(String remark) { this.remark = remark; }
    public Long getRecordId() { return recordId; }
    public void setRecordId(Long recordId) { this.recordId = recordId; }
    public String getInoculated() { return inoculated; }
    public void setInoculated(String inoculated) { this.inoculated = inoculated; }
    public Date getInoculateDate() { return inoculateDate; }
    public void setInoculateDate(Date inoculateDate) { this.inoculateDate = inoculateDate; }
    public String getOperatorName() { return operatorName; }
    public void setOperatorName(String operatorName) { this.operatorName = operatorName; }
    public Date getDueDate() { return dueDate; }
    public void setDueDate(Date dueDate) { this.dueDate = dueDate; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Integer getRemainDays() { return remainDays; }
    public void setRemainDays(Integer remainDays) { this.remainDays = remainDays; }
}
