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
import org.springframework.web.bind.annotation.RestController;
import com.youyou.common.annotation.Log;
import com.youyou.common.core.controller.BaseController;
import com.youyou.common.core.domain.AjaxResult;
import com.youyou.common.core.page.TableDataInfo;
import com.youyou.common.enums.BusinessType;
import com.youyou.nursing.domain.NcBaby;
import com.youyou.nursing.service.INcBabyService;

/**
 * 宝宝档案
 */
@RestController
@RequestMapping("/nursing/baby")
public class NcBabyController extends BaseController
{
    @Autowired
    private INcBabyService babyService;

    @PreAuthorize("@ss.hasPermi('nursing:baby:list')")
    @GetMapping("/list")
    public TableDataInfo list(NcBaby baby)
    {
        startPage();
        List<NcBaby> list = babyService.selectBabyList(baby);
        return getDataTable(list);
    }

    /**
     * 当前登录人可切换的宝宝（顶栏）
     */
    @GetMapping("/mine")
    public AjaxResult mine()
    {
        return success(babyService.selectMine());
    }

    @PreAuthorize("@ss.hasPermi('nursing:baby:query')")
    @GetMapping("/{babyId}")
    public AjaxResult getInfo(@PathVariable Long babyId)
    {
        return success(babyService.selectBabyById(babyId));
    }

    @PreAuthorize("@ss.hasPermi('nursing:baby:add')")
    @Log(title = "宝宝档案", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@Validated @RequestBody NcBaby baby)
    {
        baby.setCreateBy(getUsername());
        return toAjax(babyService.insertBaby(baby));
    }

    @PreAuthorize("@ss.hasPermi('nursing:baby:edit')")
    @Log(title = "宝宝档案", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@Validated @RequestBody NcBaby baby)
    {
        baby.setUpdateBy(getUsername());
        return toAjax(babyService.updateBaby(baby));
    }

    @PreAuthorize("@ss.hasPermi('nursing:baby:remove')")
    @Log(title = "宝宝档案", businessType = BusinessType.DELETE)
    @DeleteMapping("/{babyIds}")
    public AjaxResult remove(@PathVariable Long[] babyIds)
    {
        return toAjax(babyService.deleteBabyByIds(babyIds));
    }
}
