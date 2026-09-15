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
import com.youyou.nursing.domain.NcHealthCheck;
import com.youyou.nursing.domain.NcVaccineItem;
import com.youyou.nursing.domain.NcVaccineMark;
import com.youyou.nursing.service.INcHealthService;

@RestController
@RequestMapping("/nursing/health")
public class NcHealthController extends BaseController
{
    @Autowired
    private INcHealthService healthService;

    @PreAuthorize("@ss.hasPermi('nursing:health:list')")
    @GetMapping("/list")
    public TableDataInfo list(NcHealthCheck query)
    {
        startPage();
        List<NcHealthCheck> list = healthService.selectList(query);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('nursing:health:query')")
    @GetMapping("/{checkId:\\d+}")
    public AjaxResult getInfo(@PathVariable Long checkId)
    {
        return success(healthService.selectById(checkId));
    }

    @PreAuthorize("@ss.hasPermi('nursing:health:add')")
    @Log(title = "健康自检", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@Validated @RequestBody NcHealthCheck row)
    {
        return toAjax(healthService.insert(row));
    }

    @PreAuthorize("@ss.hasPermi('nursing:health:edit')")
    @Log(title = "健康自检", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@Validated @RequestBody NcHealthCheck row)
    {
        return toAjax(healthService.update(row));
    }

    @PreAuthorize("@ss.hasPermi('nursing:health:list')")
    @GetMapping("/vaccine")
    public AjaxResult vaccine(@RequestParam Long babyId)
    {
        List<NcVaccineItem> list = healthService.selectVaccineBoard(babyId);
        return success(list);
    }

    @PreAuthorize("@ss.hasPermi('nursing:vaccine:edit')")
    @Log(title = "疫苗接种", businessType = BusinessType.UPDATE)
    @PutMapping("/vaccine")
    public AjaxResult markVaccine(@Validated @RequestBody NcVaccineMark mark)
    {
        return toAjax(healthService.markVaccine(mark));
    }

    @PreAuthorize("@ss.hasPermi('nursing:vaccine:edit')")
    @Log(title = "疫苗时间表", businessType = BusinessType.INSERT)
    @PostMapping("/vaccine/schedule")
    public AjaxResult addSchedule(@RequestParam Long babyId, @Validated @RequestBody NcVaccineItem item)
    {
        return toAjax(healthService.insertSchedule(babyId, item));
    }

    @PreAuthorize("@ss.hasPermi('nursing:vaccine:edit')")
    @Log(title = "疫苗时间表", businessType = BusinessType.DELETE)
    @DeleteMapping("/vaccine/schedule/{scheduleId}")
    public AjaxResult removeSchedule(@PathVariable Long scheduleId, @RequestParam Long babyId)
    {
        return toAjax(healthService.deleteSchedule(babyId, scheduleId));
    }
}
