package com.youyou.nursing.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.youyou.nursing.domain.NcMedia;

public interface NcMediaMapper
{
    NcMedia selectById(Long mediaId);

    List<NcMedia> selectList(NcMedia query);

    List<NcMedia> selectRecent(@Param("babyId") Long babyId, @Param("limit") int limit);

    int insert(NcMedia row);

    int updateMeta(NcMedia row);

    int markDelete(Long mediaId);
}
