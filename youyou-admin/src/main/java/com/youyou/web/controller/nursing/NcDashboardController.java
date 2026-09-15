package com.youyou.web.controller.nursing;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.youyou.common.core.controller.BaseController;
import com.youyou.common.core.domain.AjaxResult;
import com.youyou.nursing.service.INcDashboardService;

@RestController
@RequestMapping("/nursing/dashboard")
public class NcDashboardController extends BaseController
{
    @Autowired
    private INcDashboardService dashboardService;

    @PreAuthorize("@ss.hasPermi('nursing:dashboard:list')")
    @GetMapping("/today")
    public AjaxResult today(@RequestParam Long babyId)
    {
        return success(dashboardService.selectToday(babyId));
    }

    @PreAuthorize("@ss.hasPermi('nursing:dashboard:list')")
    @GetMapping("/admin")
    public AjaxResult admin()
    {
        return success(dashboardService.selectAdminOverview());
    }
}
