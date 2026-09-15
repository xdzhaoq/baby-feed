package com.youyou.nursing.domain;

import java.util.Date;
import com.fasterxml.jackson.annotation.JsonFormat;
import com.youyou.common.core.domain.BaseEntity;

/**
 * 记录编辑锁 nc_record_lock
 */
public class NcRecordLock extends BaseEntity
{
    private static final long serialVersionUID = 1L;

    private Long lockId;

    private Long babyId;

    private String moduleCode;

    private Long recordId;

    private Long lockerUserId;

    private String lockerName;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date expireTime;

    @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private Date heartbeatTime;

    public Long getLockId()
    {
        return lockId;
    }

    public void setLockId(Long lockId)
    {
        this.lockId = lockId;
    }

    public Long getBabyId()
    {
        return babyId;
    }

    public void setBabyId(Long babyId)
    {
        this.babyId = babyId;
    }

    public String getModuleCode()
    {
        return moduleCode;
    }

    public void setModuleCode(String moduleCode)
    {
        this.moduleCode = moduleCode;
    }

    public Long getRecordId()
    {
        return recordId;
    }

    public void setRecordId(Long recordId)
    {
        this.recordId = recordId;
    }

    public Long getLockerUserId()
    {
        return lockerUserId;
    }

    public void setLockerUserId(Long lockerUserId)
    {
        this.lockerUserId = lockerUserId;
    }

    public String getLockerName()
    {
        return lockerName;
    }

    public void setLockerName(String lockerName)
    {
        this.lockerName = lockerName;
    }

    public Date getExpireTime()
    {
        return expireTime;
    }

    public void setExpireTime(Date expireTime)
    {
        this.expireTime = expireTime;
    }

    public Date getHeartbeatTime()
    {
        return heartbeatTime;
    }

    public void setHeartbeatTime(Date heartbeatTime)
    {
        this.heartbeatTime = heartbeatTime;
    }
}
