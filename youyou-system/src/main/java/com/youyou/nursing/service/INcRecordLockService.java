package com.youyou.nursing.service;

import com.youyou.nursing.domain.NcRecordLock;

public interface INcRecordLockService
{
    NcRecordLock acquire(Long babyId, String moduleCode, Long recordId);

    NcRecordLock heartbeat(Long babyId, String moduleCode, Long recordId);

    int release(String moduleCode, Long recordId);

    void assertWritable(String moduleCode, Long recordId);
}
