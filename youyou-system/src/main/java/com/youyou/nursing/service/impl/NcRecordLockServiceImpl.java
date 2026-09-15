package com.youyou.nursing.service.impl;

import java.util.Calendar;
import java.util.Date;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.youyou.common.constant.HttpStatus;
import com.youyou.common.exception.ServiceException;
import com.youyou.common.utils.SecurityUtils;
import com.youyou.common.utils.StringUtils;
import com.youyou.nursing.constant.NursingConstants;
import com.youyou.nursing.domain.NcRecordLock;
import com.youyou.nursing.mapper.NcRecordLockMapper;
import com.youyou.nursing.service.INcRecordLockService;
import com.youyou.nursing.service.INursingAccessService;

@Service
public class NcRecordLockServiceImpl implements INcRecordLockService
{
    @Autowired
    private NcRecordLockMapper lockMapper;

    @Autowired
    private INursingAccessService accessService;

    @Override
    public NcRecordLock acquire(Long babyId, String moduleCode, Long recordId)
    {
        accessService.assertBabyAccess(babyId);
        lockMapper.deleteExpired();
        return takeLock(babyId, moduleCode, recordId, false);
    }

    @Override
    public NcRecordLock heartbeat(Long babyId, String moduleCode, Long recordId)
    {
        accessService.assertBabyAccess(babyId);
        return takeLock(babyId, moduleCode, recordId, true);
    }

    @Override
    public int release(String moduleCode, Long recordId)
    {
        return lockMapper.deleteLock(moduleCode, recordId, SecurityUtils.getUserId());
    }

    @Override
    public void assertWritable(String moduleCode, Long recordId)
    {
        lockMapper.deleteExpired();
        NcRecordLock db = lockMapper.selectLock(moduleCode, recordId);
        if (db != null && !SecurityUtils.getUserId().equals(db.getLockerUserId())
                && db.getExpireTime() != null && db.getExpireTime().after(new Date()))
        {
            throw new ServiceException("该记录正在被其他成员编辑，请稍后再试（占用者：" + db.getLockerName() + "）",
                    HttpStatus.CONFLICT);
        }
    }

    private NcRecordLock takeLock(Long babyId, String moduleCode, Long recordId, boolean heartbeatOnly)
    {
        if (babyId == null || recordId == null || StringUtils.isEmpty(moduleCode))
        {
            throw new ServiceException("加锁参数不完整");
        }
        Long userId = SecurityUtils.getUserId();
        String name = accessService.currentOperatorName();
        Date expire = plusSeconds(NursingConstants.LOCK_TTL_SECONDS);
        NcRecordLock db = lockMapper.selectLock(moduleCode, recordId);
        if (db == null)
        {
            if (heartbeatOnly)
            {
                throw new ServiceException("编辑锁已失效，请重新打开记录");
            }
            NcRecordLock lock = new NcRecordLock();
            lock.setBabyId(babyId);
            lock.setModuleCode(moduleCode);
            lock.setRecordId(recordId);
            lock.setLockerUserId(userId);
            lock.setLockerName(name);
            lock.setExpireTime(expire);
            lockMapper.insertLock(lock);
            return lock;
        }
        boolean expired = db.getExpireTime() == null || db.getExpireTime().before(new Date());
        if (!expired && !userId.equals(db.getLockerUserId()))
        {
            throw new ServiceException("该记录正在被其他成员编辑，请稍后再试（占用者：" + db.getLockerName() + "）",
                    HttpStatus.CONFLICT);
        }
        db.setBabyId(babyId);
        db.setLockerUserId(userId);
        db.setLockerName(name);
        db.setExpireTime(expire);
        lockMapper.renewLock(db);
        return db;
    }

    private Date plusSeconds(int seconds)
    {
        Calendar calendar = Calendar.getInstance();
        calendar.add(Calendar.SECOND, seconds);
        return calendar.getTime();
    }
}
