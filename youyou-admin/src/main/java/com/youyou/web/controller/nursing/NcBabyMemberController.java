package com.youyou.web.controller.nursing;

import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.validation.annotation.Validated;
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
import com.youyou.nursing.domain.NcBabyMember;
import com.youyou.nursing.service.INcBabyMemberService;

/**
 * 家庭成员
 */
@RestController
@RequestMapping("/nursing/member")
public class NcBabyMemberController extends BaseController
{
    @Autowired
    private INcBabyMemberService memberService;

    @PreAuthorize("@ss.hasPermi('nursing:member:list')")
    @GetMapping("/list")
    public TableDataInfo list(NcBabyMember member)
    {
        startPage();
        List<NcBabyMember> list = memberService.selectMemberList(member);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('nursing:member:query')")
    @GetMapping("/{memberId}")
    public AjaxResult getInfo(@PathVariable Long memberId)
    {
        return success(memberService.selectMemberById(memberId));
    }

    @PreAuthorize("@ss.hasPermi('nursing:member:add')")
    @Log(title = "家庭成员", businessType = BusinessType.INSERT)
    @PostMapping
    public AjaxResult add(@Validated @RequestBody NcBabyMember member)
    {
        return toAjax(memberService.insertMember(member));
    }

    @PreAuthorize("@ss.hasPermi('nursing:member:edit')")
    @Log(title = "家庭成员", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@Validated @RequestBody NcBabyMember member)
    {
        return toAjax(memberService.updateMember(member));
    }

    @PreAuthorize("@ss.hasPermi('nursing:member:disable')")
    @Log(title = "家庭成员", businessType = BusinessType.UPDATE)
    @PutMapping("/changeStatus")
    public AjaxResult changeStatus(@RequestBody NcBabyMember member)
    {
        return toAjax(memberService.changeStatus(member));
    }

    @PreAuthorize("@ss.hasPermi('nursing:member:resetPwd')")
    @Log(title = "家庭成员", businessType = BusinessType.UPDATE)
    @PutMapping("/resetPwd")
    public AjaxResult resetPwd(@RequestBody Map<String, Object> body)
    {
        Long memberId = Long.valueOf(String.valueOf(body.get("memberId")));
        String password = String.valueOf(body.get("password"));
        return toAjax(memberService.resetPassword(memberId, password));
    }

    /**
     * 打开页面约每 20 秒上报；超过约 45 秒无心跳视为离线
     */
    @PutMapping("/heartbeat")
    public AjaxResult heartbeat(@RequestParam Long babyId)
    {
        memberService.heartbeat(babyId);
        return AjaxResult.success();
    }
}
