package com.youyou.nursing.service;

import java.util.List;
import com.youyou.nursing.domain.NcChartPoint;
import com.youyou.nursing.domain.NcFeeding;

public interface INcFeedingService
{
    NcFeeding selectById(Long feedingId);

    List<NcFeeding> selectList(NcFeeding query);

    int insert(NcFeeding row);

    int update(NcFeeding row);

    int deleteByIds(Long[] ids);

    List<NcChartPoint> selectDailyChart(Long babyId, int days);
}
