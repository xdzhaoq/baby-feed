package com.youyou.nursing.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.youyou.nursing.domain.NcChartPoint;
import com.youyou.nursing.domain.NcDiaper;

public interface NcDiaperMapper
{
    NcDiaper selectById(Long diaperId);

    List<NcDiaper> selectList(NcDiaper query);

    List<NcChartPoint> selectDailyChart(@Param("babyId") Long babyId, @Param("days") int days);

    NcChartPoint selectTodayStat(@Param("babyId") Long babyId);

    int insert(NcDiaper row);

    int update(NcDiaper row);

    int deleteByIds(Long[] ids);
}
