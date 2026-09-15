package com.youyou.web.controller.nursing;

import java.io.IOException;
import java.util.List;
import javax.servlet.http.HttpServletResponse;
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
import org.springframework.web.multipart.MultipartFile;
import com.youyou.common.annotation.Log;
import com.youyou.common.core.controller.BaseController;
import com.youyou.common.core.domain.AjaxResult;
import com.youyou.common.core.page.TableDataInfo;
import com.youyou.common.enums.BusinessType;
import com.youyou.nursing.domain.NcMedia;
import com.youyou.nursing.service.INcMediaService;

@RestController
@RequestMapping("/nursing/media")
public class NcMediaController extends BaseController
{
    @Autowired
    private INcMediaService mediaService;

    @PreAuthorize("@ss.hasPermi('nursing:media:list')")
    @GetMapping("/list")
    public TableDataInfo list(NcMedia query)
    {
        startPage();
        List<NcMedia> list = mediaService.selectList(query);
        return getDataTable(list);
    }

    @PreAuthorize("@ss.hasPermi('nursing:media:query')")
    @GetMapping("/{mediaId:\\d+}")
    public AjaxResult getInfo(@PathVariable Long mediaId)
    {
        return success(mediaService.selectById(mediaId));
    }

    @PreAuthorize("@ss.hasPermi('nursing:media:add')")
    @Log(title = "宝宝相册", businessType = BusinessType.INSERT)
    @PostMapping("/upload")
    public AjaxResult upload(@RequestParam Long babyId,
            @RequestParam(required = false) String tagCode,
            @RequestParam(required = false) String description,
            @RequestParam(required = false) Long healthCheckId,
            @RequestParam("file") MultipartFile file)
    {
        return success(mediaService.upload(babyId, tagCode, description, healthCheckId, file));
    }

    @PreAuthorize("@ss.hasPermi('nursing:media:edit')")
    @Log(title = "宝宝相册", businessType = BusinessType.UPDATE)
    @PutMapping
    public AjaxResult edit(@Validated @RequestBody NcMedia row)
    {
        return toAjax(mediaService.updateMeta(row));
    }

    @PreAuthorize("@ss.hasPermi('nursing:media:remove')")
    @Log(title = "宝宝相册", businessType = BusinessType.DELETE)
    @DeleteMapping("/{mediaIds}")
    public AjaxResult remove(@RequestParam Long babyId, @PathVariable Long[] mediaIds)
    {
        return toAjax(mediaService.deleteByIds(babyId, mediaIds));
    }

    @PreAuthorize("@ss.hasPermi('nursing:media:list')")
    @GetMapping("/preview/{mediaId:\\d+}")
    public void preview(@PathVariable Long mediaId, HttpServletResponse response) throws IOException
    {
        mediaService.preview(mediaId, response);
    }

    @PreAuthorize("@ss.hasPermi('nursing:media:download')")
    @GetMapping("/download/{mediaId:\\d+}")
    public void download(@PathVariable Long mediaId, HttpServletResponse response) throws IOException
    {
        mediaService.download(mediaId, response);
    }

    @PreAuthorize("@ss.hasPermi('nursing:media:download')")
    @PostMapping("/download/batch")
    public void downloadBatch(@RequestParam Long babyId, @RequestBody Long[] mediaIds, HttpServletResponse response)
            throws IOException
    {
        mediaService.downloadBatch(babyId, mediaIds, response);
    }
}
