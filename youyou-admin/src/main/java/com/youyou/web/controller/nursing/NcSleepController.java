package com.youyou.web.controller.nursing;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.youyou.common.annotation.Log;
import com.youyou.common.core.controller.BaseController;
import com.youyou.common.core.domain.AjaxResult;
import com.youyou.common.core.page.TableDataInfo;
import com.youyou.common.enums.BusinessType;
import com.youyou.nursing.domain.NcSleep;
import com.youyou.nursing.service.INcSleepService;

@RestController
@RequestMapping("/nursing/sleep")
public class NcSleepController extends BaseController
{
    @Autowired
    private INcSleepService sleepService;

    @PreAuthorize("@ss.hasPermi('nursing:sleep:list')")
    @GetMapping("/list")
    public TableDataInfo list(NcSleep query)
    {
        startPage();
        List<NcSleep> list = sleepService.selectList(query);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('nursing:sleep:query')")
    @GetMapping("/chart")
    public AjaxResult chart(@RequestParam Long babyId, @RequestParam(defaultValue = "7") Integer days)
    {
        return success(sleepService.selectDailyChart(babyId, days == null ? 7 : days.intValue()));
    }

    @PreAuthorize("@ss.hasPermi('nursing:sleep:query')")
    @GetMapping("/{sleepId:\\d+}")
    public AjaxResult getInfo(@PathVariable Long sleepId)
    {
        return success(sleepService.selectById(sleepId));
    }

    @PreAuthorize("@ss.hasPermi('nursing:sleep:add')")
    @Log(title = "睡眠记录", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@Validated @RequestBody NcSleep row)
    {
        return toAjax(sleepService.insert(row));
    }

    @PreAuthorize("@ss.hasPermi('nursing:sleep:edit')")
    @Log(title = "睡眠记录", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@Validated @RequestBody NcSleep row)
    {
        return toAjax(sleepService.update(row));
    }

    @PreAuthorize("@ss.hasPermi('nursing:sleep:remove')")
    @Log(title = "睡眠记录", businessType = BusinessType.DELETE)
    @DeleteMapping("/{sleepIds}")
    public AjaxResult remove(@PathVariable Long[] sleepIds)
    {
        return toAjax(sleepService.deleteByIds(sleepIds));
    }
}
