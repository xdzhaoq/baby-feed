package com.youyou.nursing.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.youyou.nursing.domain.NcChartPoint;
import com.youyou.nursing.domain.NcCry;

public interface NcCryMapper
{
    NcCry selectById(Long cryId);

    List<NcCry> selectList(NcCry query);

    List<NcChartPoint> selectHourChart(@Param("babyId") Long babyId, @Param("days") int days);

    List<NcChartPoint> selectSootheChart(@Param("babyId") Long babyId, @Param("days") int days);

    int insert(NcCry row);

    int update(NcCry row);

    int deleteByIds(Long[] ids);
}
