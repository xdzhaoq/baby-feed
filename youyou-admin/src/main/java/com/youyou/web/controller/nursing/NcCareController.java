package com.youyou.web.controller.nursing;

import java.util.Date;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
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
import com.youyou.common.enums.BusinessType;
import com.youyou.nursing.domain.NcCareItem;
import com.youyou.nursing.domain.NcCareLog;
import com.youyou.nursing.service.INcCareService;

@RestController
@RequestMapping("/nursing/care")
public class NcCareController extends BaseController
{
    @Autowired
    private INcCareService careService;

    @PreAuthorize("@ss.hasPermi('nursing:care:list')")
    @GetMapping("/today")
    public AjaxResult today(@RequestParam Long babyId,
            @RequestParam(required = false) @DateTimeFormat(pattern = "yyyy-MM-dd") Date careDate)
    {
        List<NcCareItem> list = careService.selectToday(babyId, careDate);
        return success(list);
    }

    @PreAuthorize("@ss.hasPermi('nursing:care:add')")
    @Log(title = "护理清单", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@Validated @RequestBody NcCareItem item)
    {
        return toAjax(careService.insertCustom(item));
    }

    @PreAuthorize("@ss.hasPermi('nursing:care:edit')")
    @Log(title = "护理清单", businessType = BusinessType.UPDATE)
    @PutMapping("/toggle")
    public AjaxResult toggle(@Validated @RequestBody NcCareLog log)
    {
        return toAjax(careService.toggle(log));
    }

    @PreAuthorize("@ss.hasPermi('nursing:care:remove') or @ss.hasPermi('nursing:care:edit')")
    @Log(title = "护理清单", businessType = BusinessType.DELETE)
    @DeleteMapping("/{itemId}")
    public AjaxResult remove(@PathVariable Long itemId, @RequestParam Long babyId)
    {
        return toAjax(careService.deleteCustom(itemId, babyId));
    }
}
