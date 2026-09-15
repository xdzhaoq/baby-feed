package com.youyou.web.controller.nursing;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.youyou.common.core.controller.BaseController;
import com.youyou.common.core.domain.AjaxResult;
import com.youyou.nursing.domain.NcRecordLock;
import com.youyou.nursing.service.INcRecordLockService;

/**
 * 记录级编辑锁：打开编辑时占用，对话框内心跳续期，关闭释放。
 */
@RestController
@RequestMapping("/nursing/lock")
public class NcRecordLockController extends BaseController
{
    @Autowired
    private INcRecordLockService lockService;

    @PostMapping
    public AjaxResult acquire(@RequestBody NcRecordLock lock)
    {
        return success(lockService.acquire(lock.getBabyId(), lock.getModuleCode(), lock.getRecordId()));
    }

    @PutMapping
    public AjaxResult heartbeat(@RequestBody NcRecordLock lock)
    {
        return success(lockService.heartbeat(lock.getBabyId(), lock.getModuleCode(), lock.getRecordId()));
    }

    @DeleteMapping
    public AjaxResult release(@RequestBody NcRecordLock lock)
    {
        return toAjax(lockService.release(lock.getModuleCode(), lock.getRecordId()));
    }
}
