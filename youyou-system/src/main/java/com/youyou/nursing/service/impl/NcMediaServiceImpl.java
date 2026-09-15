package com.youyou.nursing.service.impl;

import java.io.IOException;
import java.io.InputStream;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;
import javax.servlet.http.HttpServletResponse;
import org.apache.commons.io.IOUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import com.youyou.common.exception.ServiceException;
import com.youyou.common.utils.StringUtils;
import com.youyou.common.utils.file.FileUtils;
import com.youyou.nursing.constant.NursingConstants;
import com.youyou.nursing.domain.NcBaby;
import com.youyou.nursing.domain.NcHealthCheck;
import com.youyou.nursing.domain.NcMedia;
import com.youyou.nursing.mapper.NcBabyMapper;
import com.youyou.nursing.mapper.NcHealthCheckMapper;
import com.youyou.nursing.mapper.NcMediaMapper;
import com.youyou.nursing.service.INcMediaService;
import com.youyou.nursing.service.INcOssService;

@Service
public class NcMediaServiceImpl implements INcMediaService
{
    private static final Set<String> IMAGE_EXT = new HashSet<String>(Arrays.asList(".jpg", ".jpeg", ".png", ".webp", ".gif"));

    private static final Set<String> VIDEO_EXT = new HashSet<String>(Arrays.asList(".mp4"));

    private static final Set<String> IMAGE_MIME = new HashSet<String>(Arrays.asList(
            "image/jpeg", "image/png", "image/webp", "image/gif"));

    private static final Set<String> VIDEO_MIME = new HashSet<String>(Arrays.asList("video/mp4"));

    @Autowired
    private NcMediaMapper mediaMapper;

    @Autowired
    private NcBabyMapper babyMapper;

    @Autowired
    private NcHealthCheckMapper healthMapper;

    @Autowired
    private INcOssService ossService;

    @Autowired
    private NursingRecordHelper helper;

    @Override
    public NcMedia selectById(Long mediaId)
    {
        NcMedia row = mediaMapper.selectById(mediaId);
        if (row == null)
        {
            throw new ServiceException("相册文件不存在");
        }
        helper.assertBaby(row.getBabyId());
        return row;
    }

    @Override
    public List<NcMedia> selectList(NcMedia query)
    {
        helper.assertBaby(query.getBabyId());
        return mediaMapper.selectList(query);
    }

    @Override
    public List<NcMedia> selectRecent(Long babyId, int limit)
    {
        helper.assertBaby(babyId);
        return mediaMapper.selectRecent(babyId, limit);
    }

    @Override
    public NcMedia upload(Long babyId, String tagCode, String description, Long healthCheckId, MultipartFile file)
    {
        helper.assertBaby(babyId);
        if (file == null || file.isEmpty())
        {
            throw new ServiceException("请选择要上传的文件");
        }
        long max = ossService.maxFileSize();
        if (file.getSize() > max)
        {
            throw new ServiceException("单个文件不能超过 100MB");
        }
        String original = file.getOriginalFilename();
        if (StringUtils.isEmpty(original))
        {
            original = "unnamed";
        }
        original = original.replace("\\", "/");
        int slash = original.lastIndexOf('/');
        if (slash >= 0)
        {
            original = original.substring(slash + 1);
        }
        String ext = extension(original);
        String mime = file.getContentType() == null ? "" : file.getContentType().toLowerCase();
        String mediaType = resolveType(ext, mime);
        if (healthCheckId != null)
        {
            NcHealthCheck health = healthMapper.selectById(healthCheckId);
            if (health == null || !babyId.equals(health.getBabyId()))
            {
                throw new ServiceException("关联的健康自检不属于当前宝宝");
            }
        }
        NcBaby baby = babyMapper.selectBabyById(babyId);
        if (baby == null)
        {
            throw new ServiceException("宝宝不存在");
        }
        String dir = baby.getMediaDir();
        if (StringUtils.isEmpty(dir))
        {
            dir = "baby/" + babyId + "/";
        }
        if (!dir.endsWith("/"))
        {
            dir = dir + "/";
        }
        String day = new SimpleDateFormat("yyyyMMdd").format(new Date());
        String objectKey = dir + day + "/" + UUID.randomUUID().toString().replace("-", "") + ext;
        InputStream in = null;
        try
        {
            in = file.getInputStream();
            ossService.putObject(objectKey, in, file.getSize(), StringUtils.isEmpty(mime) ? "application/octet-stream" : mime);
        }
        catch (IOException e)
        {
            throw new ServiceException("读取上传文件失败");
        }
        finally
        {
            IOUtils.closeQuietly(in);
        }
        NcMedia row = new NcMedia();
        row.setBabyId(babyId);
        row.setFileName(original);
        row.setObjectKey(objectKey);
        row.setMimeType(StringUtils.isEmpty(mime) ? "application/octet-stream" : mime);
        row.setFileSize(file.getSize());
        row.setMediaType(mediaType);
        row.setTagCode(StringUtils.isEmpty(tagCode) ? "daily" : tagCode);
        row.setDescription(description);
        row.setHealthCheckId(healthCheckId);
        row.setUploaderId(helper.operatorId());
        row.setUploaderName(helper.operatorName());
        row.setDelFlag(NursingConstants.DEL_NORMAL);
        try
        {
            mediaMapper.insert(row);
        }
        catch (RuntimeException e)
        {
            try
            {
                ossService.deleteObject(objectKey);
            }
            catch (Exception ignored)
            {
            }
            throw e;
        }
        return row;
    }

    @Override
    public int updateMeta(NcMedia row)
    {
        NcMedia db = selectById(row.getMediaId());
        if (row.getHealthCheckId() != null)
        {
            NcHealthCheck health = healthMapper.selectById(row.getHealthCheckId());
            if (health == null || !db.getBabyId().equals(health.getBabyId()))
            {
                throw new ServiceException("关联的健康自检不属于当前宝宝");
            }
        }
        db.setTagCode(StringUtils.isEmpty(row.getTagCode()) ? "daily" : row.getTagCode());
        db.setDescription(row.getDescription());
        db.setHealthCheckId(row.getHealthCheckId());
        db.setUpdateBy(helper.username());
        return mediaMapper.updateMeta(db);
    }

    @Override
    public int deleteByIds(Long babyId, Long[] mediaIds)
    {
        helper.assertBaby(babyId);
        if (mediaIds == null || mediaIds.length == 0)
        {
            throw new ServiceException("请选择要删除的文件");
        }
        int n = 0;
        for (Long id : mediaIds)
        {
            NcMedia row = mediaMapper.selectById(id);
            if (row == null)
            {
                continue;
            }
            if (!babyId.equals(row.getBabyId()))
            {
                throw new ServiceException("不能删除其他宝宝的相册");
            }
            helper.assertBaby(row.getBabyId());
            if (StringUtils.isNotEmpty(row.getObjectKey()))
            {
                String key = row.getObjectKey();
                if (key.contains("..") || key.startsWith("/") || !key.startsWith("baby/" + babyId + "/"))
                {
                    throw new ServiceException("相册对象键不合法");
                }
                ossService.deleteObject(key);
            }
            n += mediaMapper.markDelete(id);
        }
        return n;
    }

    @Override
    public void download(Long mediaId, HttpServletResponse response) throws IOException
    {
        NcMedia row = selectById(mediaId);
        response.setContentType(StringUtils.isEmpty(row.getMimeType()) ? "application/octet-stream" : row.getMimeType());
        FileUtils.setAttachmentResponseHeader(response, row.getFileName());
        ossService.writeObject(row.getObjectKey(), response.getOutputStream());
    }

    @Override
    public void preview(Long mediaId, HttpServletResponse response) throws IOException
    {
        NcMedia row = selectById(mediaId);
        String mime = StringUtils.isEmpty(row.getMimeType()) ? "application/octet-stream" : row.getMimeType();
        response.setContentType(mime);
        response.setHeader("Cache-Control", "private, max-age=300");
        String encoded = FileUtils.percentEncode(StringUtils.isEmpty(row.getFileName()) ? "file" : row.getFileName());
        response.setHeader("Content-Disposition", "inline; filename=" + encoded + ";filename*=utf-8''" + encoded);
        ossService.writeObject(row.getObjectKey(), response.getOutputStream());
    }

    @Override
    public void downloadBatch(Long babyId, Long[] mediaIds, HttpServletResponse response) throws IOException
    {
        helper.assertBaby(babyId);
        if (mediaIds == null || mediaIds.length == 0)
        {
            throw new ServiceException("请选择要下载的文件");
        }
        response.setContentType("application/zip");
        FileUtils.setAttachmentResponseHeader(response, "baby-album.zip");
        ZipOutputStream zip = new ZipOutputStream(response.getOutputStream());
        try
        {
            Set<String> used = new HashSet<String>();
            for (Long id : mediaIds)
            {
                NcMedia row = mediaMapper.selectById(id);
                if (row == null || !babyId.equals(row.getBabyId()))
                {
                    continue;
                }
                String entryName = uniqueName(used, safeZipName(row.getFileName()), row.getMediaId());
                zip.putNextEntry(new ZipEntry(entryName));
                ossService.writeObject(row.getObjectKey(), zip);
                zip.closeEntry();
            }
            zip.finish();
        }
        finally
        {
            IOUtils.closeQuietly(zip);
        }
    }

    private String resolveType(String ext, String mime)
    {
        boolean image = IMAGE_EXT.contains(ext) || IMAGE_MIME.contains(mime);
        boolean video = VIDEO_EXT.contains(ext) || VIDEO_MIME.contains(mime);
        if (image && !video)
        {
            return NursingConstants.MEDIA_IMAGE;
        }
        if (video && !image)
        {
            return NursingConstants.MEDIA_VIDEO;
        }
        throw new ServiceException("仅支持 JPG / PNG / WEBP / GIF 图片和 MP4 视频");
    }

    private String extension(String fileName)
    {
        int dot = fileName.lastIndexOf('.');
        if (dot < 0)
        {
            return "";
        }
        return fileName.substring(dot).toLowerCase();
    }

    private String safeZipName(String name)
    {
        if (StringUtils.isEmpty(name))
        {
            return "file";
        }
        return name.replace("\\", "_").replace("/", "_").replace("..", "_");
    }

    private String uniqueName(Set<String> used, String name, Long mediaId)
    {
        String candidate = name;
        if (used.contains(candidate))
        {
            int dot = name.lastIndexOf('.');
            if (dot > 0)
            {
                candidate = name.substring(0, dot) + "-" + mediaId + name.substring(dot);
            }
            else
            {
                candidate = name + "-" + mediaId;
            }
        }
        used.add(candidate);
        return candidate;
    }
}
