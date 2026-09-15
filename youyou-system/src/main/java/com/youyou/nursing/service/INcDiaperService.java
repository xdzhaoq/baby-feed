package com.youyou.nursing.service;

import java.util.List;
import com.youyou.nursing.domain.NcDiaper;
import com.youyou.nursing.domain.NcDiaperChart;

public interface INcDiaperService
{
    NcDiaper selectById(Long diaperId);

    List<NcDiaper> selectList(NcDiaper query);

    int insert(NcDiaper row);

    int update(NcDiaper row);

    int deleteByIds(Long[] ids);

    NcDiaperChart selectChart(Long babyId, int days);
}
