package com.youyou.nursing.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.youyou.nursing.domain.NcChartPoint;
import com.youyou.nursing.domain.NcFeeding;

public interface NcFeedingMapper
{
    NcFeeding selectById(Long feedingId);

    List<NcFeeding> selectList(NcFeeding query);

    List<NcChartPoint> selectDailyChart(@Param("babyId") Long babyId, @Param("days") int days);

    int insert(NcFeeding row);

    int update(NcFeeding row);

    int deleteByIds(Long[] ids);
}
