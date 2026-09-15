package com.youyou.web.controller.nursing;

import java.util.List;
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
import com.youyou.nursing.domain.NcHandover;
import com.youyou.nursing.domain.NcMessage;
import com.youyou.nursing.domain.NcOperLog;
import com.youyou.nursing.service.INcCollabService;

@RestController
@RequestMapping("/nursing")
public class NcCollabController extends BaseController
{
    @Autowired
    private INcCollabService collabService;

    @PreAuthorize("@ss.hasPermi('nursing:collab:query')")
    @GetMapping("/handover/list")
    public TableDataInfo handoverList(NcHandover query)
    {
        startPage();
        List<NcHandover> list = collabService.selectHandoverList(query);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('nursing:handover:add')")
    @Log(title = "值班交接", businessType = BusinessType.INSERT)
    @PostMapping("/handover")
    public AjaxResult addHandover(@Validated @RequestBody NcHandover row)
    {
        return toAjax(collabService.insertHandover(row));
    }

    @PreAuthorize("@ss.hasPermi('nursing:collab:query')")
    @GetMapping("/message/list")
    public TableDataInfo messageList(NcMessage query)
    {
        startPage();
        List<NcMessage> list = collabService.selectMessageList(query);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('nursing:message:add')")
    @Log(title = "家庭留言", businessType = BusinessType.INSERT)
    @PostMapping("/message")
    public AjaxResult addMessage(@Validated @RequestBody NcMessage row)
    {
        return toAjax(collabService.insertMessage(row));
    }

    @PreAuthorize("@ss.hasPermi('nursing:collab:query')")
    @GetMapping("/message/unread")
    public AjaxResult unread(@RequestParam Long babyId)
    {
        return success(collabService.selectUnreadMentions(babyId));
    }

    @PreAuthorize("@ss.hasPermi('nursing:collab:query')")
    @PutMapping("/message/mention/{mentionId}/read")
    public AjaxResult markRead(@PathVariable Long mentionId)
    {
        return toAjax(collabService.markMentionRead(mentionId));
    }

    @PreAuthorize("@ss.hasPermi('nursing:collab:query')")
    @PutMapping("/message/readAll")
    public AjaxResult readAll(@RequestParam Long babyId)
    {
        return toAjax(collabService.markAllMentionsRead(babyId));
    }

    @PreAuthorize("@ss.hasPermi('nursing:collab:query')")
    @GetMapping("/operlog/list")
    public TableDataInfo operLogList(NcOperLog query)
    {
        startPage();
        List<NcOperLog> list = collabService.selectOperLogList(query);
        return getDataTable(list);
    }
}
