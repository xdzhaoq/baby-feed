package com.youyou.nursing.domain;

import java.util.Date;
import javax.validation.constraints.NotBlank;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.youyou.common.core.domain.BaseEntity;

/** 护理清单事项（含当日完成状态） */
public class NcCareItem extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long itemId;
    private Long babyId;
    @NotBlank(message = "事项名称不能为空")
    private String itemName;
    private String isBuiltin;
    private Integer sortNum;
    private String status;
    private String delFlag;

    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date careDate;
    private Long logId;
    private String completed;
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date completeTime;
    private Long operatorId;
    private String operatorName;

    public Long getItemId() { return itemId; }
    public void setItemId(Long itemId) { this.itemId = itemId; }
    public Long getBabyId() { return babyId; }
    public void setBabyId(Long babyId) { this.babyId = babyId; }
    public String getItemName() { return itemName; }
    public void setItemName(String itemName) { this.itemName = itemName; }
    public String getIsBuiltin() { return isBuiltin; }
    public void setIsBuiltin(String isBuiltin) { this.isBuiltin = isBuiltin; }
    public Integer getSortNum() { return sortNum; }
    public void setSortNum(Integer sortNum) { this.sortNum = sortNum; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getDelFlag() { return delFlag; }
    public void setDelFlag(String delFlag) { this.delFlag = delFlag; }
    public Date getCareDate() { return careDate; }
    public void setCareDate(Date careDate) { this.careDate = careDate; }
    public Long getLogId() { return logId; }
    public void setLogId(Long logId) { this.logId = logId; }
    public String getCompleted() { return completed; }
    public void setCompleted(String completed) { this.completed = completed; }
    public Date getCompleteTime() { return completeTime; }
    public void setCompleteTime(Date completeTime) { this.completeTime = completeTime; }
    public Long getOperatorId() { return operatorId; }
    public void setOperatorId(Long operatorId) { this.operatorId = operatorId; }
    public String getOperatorName() { return operatorName; }
    public void setOperatorName(String operatorName) { this.operatorName = operatorName; }
}
