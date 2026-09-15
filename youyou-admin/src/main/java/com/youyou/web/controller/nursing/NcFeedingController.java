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
import com.youyou.nursing.domain.NcFeeding;
import com.youyou.nursing.service.INcFeedingService;

@RestController
@RequestMapping("/nursing/feeding")
public class NcFeedingController extends BaseController
{
    @Autowired
    private INcFeedingService feedingService;

    @PreAuthorize("@ss.hasPermi('nursing:feeding:list')")
    @GetMapping("/list")
    public TableDataInfo list(NcFeeding query)
    {
        startPage();
        List<NcFeeding> list = feedingService.selectList(query);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('nursing:feeding:query')")
    @GetMapping("/chart")
    public AjaxResult chart(@RequestParam Long babyId, @RequestParam(defaultValue = "7") Integer days)
    {
        return success(feedingService.selectDailyChart(babyId, days == null ? 7 : days.intValue()));
    }

    @PreAuthorize("@ss.hasPermi('nursing:feeding:query')")
    @GetMapping("/{feedingId:\\d+}")
    public AjaxResult getInfo(@PathVariable Long feedingId)
    {
        return success(feedingService.selectById(feedingId));
    }

    @PreAuthorize("@ss.hasPermi('nursing:feeding:add')")
    @Log(title = "喂养记录", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@Validated @RequestBody NcFeeding row)
    {
        return toAjax(feedingService.insert(row));
    }

    @PreAuthorize("@ss.hasPermi('nursing:feeding:edit')")
    @Log(title = "喂养记录", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@Validated @RequestBody NcFeeding row)
    {
        return toAjax(feedingService.update(row));
    }

    @PreAuthorize("@ss.hasPermi('nursing:feeding:remove')")
    @Log(title = "喂养记录", businessType = BusinessType.DELETE)
    @DeleteMapping("/{feedingIds}")
    public AjaxResult remove(@PathVariable Long[] feedingIds)
    {
        return toAjax(feedingService.deleteByIds(feedingIds));
    }
}
