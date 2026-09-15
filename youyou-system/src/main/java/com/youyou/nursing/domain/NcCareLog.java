package com.youyou.nursing.domain;

import java.util.Date;
import javax.validation.constraints.NotNull;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.youyou.common.core.domain.BaseEntity;

/** 护理清单完成切换 */
public class NcCareLog extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    @NotNull(message = "请选择宝宝")
    private Long babyId;
    @NotNull(message = "请选择事项")
    private Long itemId;
    @NotNull(message = "请选择日期")
    @JsonFormat(pattern = "yyyy-MM-dd")
    private Date careDate;
    private String completed;
    private Long operatorId;
    private String operatorName;

    public Long getBabyId() { return babyId; }
    public void setBabyId(Long babyId) { this.babyId = babyId; }
    public Long getItemId() { return itemId; }
    public void setItemId(Long itemId) { this.itemId = itemId; }
    public Date getCareDate() { return careDate; }
    public void setCareDate(Date careDate) { this.careDate = careDate; }
    public String getCompleted() { return completed; }
    public void setCompleted(String completed) { this.completed = completed; }
    public Long getOperatorId() { return operatorId; }
    public void setOperatorId(Long operatorId) { this.operatorId = operatorId; }
    public String getOperatorName() { return operatorName; }
    public void setOperatorName(String operatorName) { this.operatorName = operatorName; }
}
