package com.youyou.nursing.mapper;

import org.apache.ibatis.annotations.Param;
import com.youyou.nursing.domain.NcRecordLock;

public interface NcRecordLockMapper
{
    NcRecordLock selectLock(@Param("moduleCode") String moduleCode, @Param("recordId") Long recordId);

    int insertLock(NcRecordLock lock);

    int renewLock(NcRecordLock lock);

    int deleteLock(@Param("moduleCode") String moduleCode, @Param("recordId") Long recordId, @Param("userId") Long userId);

    int deleteExpired();
}
