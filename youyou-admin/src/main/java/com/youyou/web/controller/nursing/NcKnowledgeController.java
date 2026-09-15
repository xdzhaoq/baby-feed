package com.youyou.web.controller.nursing;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.youyou.common.core.controller.BaseController;
import com.youyou.common.core.domain.AjaxResult;
import com.youyou.nursing.service.INcDashboardService;

@RestController
@RequestMapping("/nursing/knowledge")
public class NcKnowledgeController extends BaseController
{
    @Autowired
    private INcDashboardService dashboardService;

    @PreAuthorize("@ss.hasPermi('nursing:knowledge:list')")
    @GetMapping("/list")
    public AjaxResult list(@RequestParam(required = false) String category,
            @RequestParam(required = false) String keyword)
    {
        return success(dashboardService.selectKnowledge(category, keyword));
    }

    @PreAuthorize("@ss.hasPermi('nursing:knowledge:query')")
    @GetMapping("/{kbId}")
    public AjaxResult getInfo(@PathVariable Long kbId)
    {
        return success(dashboardService.selectKnowledgeById(kbId));
    }
}
