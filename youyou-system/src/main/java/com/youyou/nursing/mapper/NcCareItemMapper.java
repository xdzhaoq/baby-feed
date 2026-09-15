package com.youyou.nursing.mapper;

import java.util.Date;
import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.youyou.nursing.domain.NcCareItem;
import com.youyou.nursing.domain.NcCareLog;

public interface NcCareItemMapper
{
    List<NcCareItem> selectTodayList(@Param("babyId") Long babyId, @Param("careDate") Date careDate);

    NcCareItem selectById(Long itemId);

    int insertItem(NcCareItem item);

    int deleteCustom(@Param("itemId") Long itemId, @Param("babyId") Long babyId);

    int hideItem(@Param("babyId") Long babyId, @Param("itemId") Long itemId);

    int upsertLog(NcCareLog log);
}
