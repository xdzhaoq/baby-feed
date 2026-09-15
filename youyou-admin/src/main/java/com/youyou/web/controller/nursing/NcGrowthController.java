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
import com.youyou.nursing.domain.NcGrowth;
import com.youyou.nursing.service.INcGrowthService;

@RestController
@RequestMapping("/nursing/growth")
public class NcGrowthController extends BaseController
{
    @Autowired
    private INcGrowthService growthService;

    @PreAuthorize("@ss.hasPermi('nursing:growth:list')")
    @GetMapping("/list")
    public TableDataInfo list(NcGrowth query)
    {
        startPage();
        List<NcGrowth> list = growthService.selectList(query);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('nursing:growth:query')")
    @GetMapping("/chart")
    public AjaxResult chart(@RequestParam Long babyId)
    {
        NcGrowth query = new NcGrowth();
        query.setBabyId(babyId);
        return success(growthService.selectList(query));
    }

    @PreAuthorize("@ss.hasPermi('nursing:growth:query')")
    @GetMapping("/{growthId:\\d+}")
    public AjaxResult getInfo(@PathVariable Long growthId)
    {
        return success(growthService.selectById(growthId));
    }

    @PreAuthorize("@ss.hasPermi('nursing:growth:add')")
    @Log(title = "生长记录", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@Validated @RequestBody NcGrowth row)
    {
        return toAjax(growthService.insert(row));
    }

    @PreAuthorize("@ss.hasPermi('nursing:growth:edit')")
    @Log(title = "生长记录", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@Validated @RequestBody NcGrowth row)
    {
        return toAjax(growthService.update(row));
    }

    @PreAuthorize("@ss.hasPermi('nursing:growth:remove')")
    @Log(title = "生长记录", businessType = BusinessType.DELETE)
    @DeleteMapping("/{growthIds}")
    public AjaxResult remove(@PathVariable Long[] growthIds)
    {
        return toAjax(growthService.deleteByIds(growthIds));
    }
}
