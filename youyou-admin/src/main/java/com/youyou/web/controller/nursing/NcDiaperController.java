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
import com.youyou.nursing.domain.NcDiaper;
import com.youyou.nursing.service.INcDiaperService;

@RestController
@RequestMapping("/nursing/diaper")
public class NcDiaperController extends BaseController
{
    @Autowired
    private INcDiaperService diaperService;

    @PreAuthorize("@ss.hasPermi('nursing:diaper:list')")
    @GetMapping("/list")
    public TableDataInfo list(NcDiaper query)
    {
        startPage();
        List<NcDiaper> list = diaperService.selectList(query);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('nursing:diaper:query')")
    @GetMapping("/chart")
    public AjaxResult chart(@RequestParam Long babyId, @RequestParam(defaultValue = "7") Integer days)
    {
        return success(diaperService.selectChart(babyId, days == null ? 7 : days.intValue()));
    }

    @PreAuthorize("@ss.hasPermi('nursing:diaper:query')")
    @GetMapping("/{diaperId:\\d+}")
    public AjaxResult getInfo(@PathVariable Long diaperId)
    {
        return success(diaperService.selectById(diaperId));
    }

    @PreAuthorize("@ss.hasPermi('nursing:diaper:add')")
    @Log(title = "尿布记录", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@Validated @RequestBody NcDiaper row)
    {
        return toAjax(diaperService.insert(row));
    }

    @PreAuthorize("@ss.hasPermi('nursing:diaper:edit')")
    @Log(title = "尿布记录", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@Validated @RequestBody NcDiaper row)
    {
        return toAjax(diaperService.update(row));
    }

    @PreAuthorize("@ss.hasPermi('nursing:diaper:remove')")
    @Log(title = "尿布记录", businessType = BusinessType.DELETE)
    @DeleteMapping("/{diaperIds}")
    public AjaxResult remove(@PathVariable Long[] diaperIds)
    {
        return toAjax(diaperService.deleteByIds(diaperIds));
    }
}
