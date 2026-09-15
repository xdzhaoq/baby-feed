package com.youyou.nursing.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.youyou.nursing.domain.NcChartPoint;
import com.youyou.nursing.domain.NcSleep;

public interface NcSleepMapper
{
    NcSleep selectById(Long sleepId);

    List<NcSleep> selectList(NcSleep query);

    List<NcChartPoint> selectDailyChart(@Param("babyId") Long babyId, @Param("days") int days);

    int insert(NcSleep row);

    int update(NcSleep row);

    int deleteByIds(Long[] ids);
}
