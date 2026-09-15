package com.youyou.nursing.service.impl;

import java.util.Date;
import java.util.concurrent.TimeUnit;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import com.youyou.common.constant.HttpStatus;
import com.youyou.common.exception.ServiceException;
import com.youyou.common.utils.SecurityUtils;
import com.youyou.nursing.service.INcRecordLockService;
import com.youyou.nursing.service.INursingAccessService;

/**
 * 日常记录共用：鉴权、乐观锁、操作人
 */
@Component
public class NursingRecordHelper
{
    @Autowired
    private INursingAccessService accessService;

    @Autowired
    private INcRecordLockService lockService;

    public void assertBaby(Long babyId)
    {
        if (babyId == null)
        {
            throw new ServiceException("请先选择宝宝");
        }
        accessService.assertBabyAccess(babyId);
    }

    public void assertRev(Integer clientRev, Integer dbRev)
    {
        if (clientRev == null || dbRev == null || !clientRev.equals(dbRev))
        {
            throw new ServiceException("该记录已被其他成员更新，请按记录粒度合并后重试", HttpStatus.CONFLICT);
        }
    }

    public void assertWritable(String moduleCode, Long recordId)
    {
        lockService.assertWritable(moduleCode, recordId);
    }

    public Long operatorId()
    {
        return SecurityUtils.getUserId();
    }

    public String operatorName()
    {
        return accessService.currentOperatorName();
    }

    public String username()
    {
        return SecurityUtils.getUsername();
    }

    /**
     * 由起止时间计算分钟；未结束返回 null。结束早于开始则拒绝。
     */
    public Integer minutesBetween(Date start, Date end)
    {
        if (start == null || end == null)
        {
            return null;
        }
        long diff = end.getTime() - start.getTime();
        if (diff < 0)
        {
            throw new ServiceException("结束时间不能早于开始时间");
        }
        return (int) TimeUnit.MILLISECONDS.toMinutes(diff);
    }

    public void assertUpdated(int rows)
    {
        if (rows == 0)
        {
            throw new ServiceException("该记录已被其他成员更新，请按记录粒度合并后重试", HttpStatus.CONFLICT);
        }
    }
}
