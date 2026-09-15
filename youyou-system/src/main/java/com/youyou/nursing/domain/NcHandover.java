package com.youyou.nursing.domain;

import java.util.Date;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.youyou.common.core.domain.BaseEntity;

/** 值班交接 nc_handover */
public class NcHandover extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long handoverId;
    @NotNull(message = "请选择宝宝")
    private Long babyId;
    private Long fromUserId;
    private String fromUserName;
    @NotNull(message = "请选择交接给谁")
    private Long toUserId;
    private String toUserName;
    @NotNull(message = "请填写交接时间")
    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date handoverTime;
    @Size(max = 500, message = "备注不能超过500个字符")
    private String notes;

    public Long getHandoverId() { return handoverId; }
    public void setHandoverId(Long handoverId) { this.handoverId = handoverId; }
    public Long getBabyId() { return babyId; }
    public void setBabyId(Long babyId) { this.babyId = babyId; }
    public Long getFromUserId() { return fromUserId; }
    public void setFromUserId(Long fromUserId) { this.fromUserId = fromUserId; }
    public String getFromUserName() { return fromUserName; }
    public void setFromUserName(String fromUserName) { this.fromUserName = fromUserName; }
    public Long getToUserId() { return toUserId; }
    public void setToUserId(Long toUserId) { this.toUserId = toUserId; }
    public String getToUserName() { return toUserName; }
    public void setToUserName(String toUserName) { this.toUserName = toUserName; }
    public Date getHandoverTime() { return handoverTime; }
    public void setHandoverTime(Date handoverTime) { this.handoverTime = handoverTime; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
}
