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
import com.youyou.nursing.domain.NcCry;
import com.youyou.nursing.service.INcCryService;

@RestController
@RequestMapping("/nursing/cry")
public class NcCryController extends BaseController
{
    @Autowired
    private INcCryService cryService;

    @PreAuthorize("@ss.hasPermi('nursing:cry:list')")
    @GetMapping("/list")
    public TableDataInfo list(NcCry query)
    {
        startPage();
        List<NcCry> list = cryService.selectList(query);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('nursing:cry:query')")
    @GetMapping("/chart")
    public AjaxResult chart(@RequestParam Long babyId, @RequestParam(defaultValue = "14") Integer days)
    {
        return success(cryService.selectChart(babyId, days == null ? 14 : days.intValue()));
    }

    @PreAuthorize("@ss.hasPermi('nursing:cry:query')")
    @GetMapping("/{cryId:\\d+}")
    public AjaxResult getInfo(@PathVariable Long cryId)
    {
        return success(cryService.selectById(cryId));
    }

    @PreAuthorize("@ss.hasPermi('nursing:cry:add')")
    @Log(title = "哭闹记录", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@Validated @RequestBody NcCry row)
    {
        return toAjax(cryService.insert(row));
    }

    @PreAuthorize("@ss.hasPermi('nursing:cry:edit')")
    @Log(title = "哭闹记录", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@Validated @RequestBody NcCry row)
    {
        return toAjax(cryService.update(row));
    }

    @PreAuthorize("@ss.hasPermi('nursing:cry:remove')")
    @Log(title = "哭闹记录", businessType = BusinessType.DELETE)
    @DeleteMapping("/{cryIds}")
    public AjaxResult remove(@PathVariable Long[] cryIds)
    {
        return toAjax(cryService.deleteByIds(cryIds));
    }
}
