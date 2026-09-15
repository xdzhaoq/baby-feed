package com.youyou.nursing.service;

import java.util.List;
import com.youyou.nursing.domain.NcChartPoint;
import com.youyou.nursing.domain.NcSleep;

public interface INcSleepService
{
    NcSleep selectById(Long sleepId);

    List<NcSleep> selectList(NcSleep query);

    int insert(NcSleep row);

    int update(NcSleep row);

    int deleteByIds(Long[] ids);

    List<NcChartPoint> selectDailyChart(Long babyId, int days);
}
