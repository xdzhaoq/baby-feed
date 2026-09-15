package com.youyou.nursing.service;

import java.io.IOException;
import java.util.List;
import javax.servlet.http.HttpServletResponse;
import org.springframework.web.multipart.MultipartFile;
import com.youyou.nursing.domain.NcMedia;

public interface INcMediaService
{
    NcMedia selectById(Long mediaId);

    List<NcMedia> selectList(NcMedia query);

    List<NcMedia> selectRecent(Long babyId, int limit);

    NcMedia upload(Long babyId, String tagCode, String description, Long healthCheckId, MultipartFile file);

    int updateMeta(NcMedia row);

    int deleteByIds(Long babyId, Long[] mediaIds);

    void download(Long mediaId, HttpServletResponse response) throws IOException;

    void preview(Long mediaId, HttpServletResponse response) throws IOException;

    void downloadBatch(Long babyId, Long[] mediaIds, HttpServletResponse response) throws IOException;
}
