package com.youyou.nursing.service;

import java.util.List;
import com.youyou.nursing.domain.NcCry;
import com.youyou.nursing.domain.NcCryChart;

public interface INcCryService
{
    NcCry selectById(Long cryId);

    List<NcCry> selectList(NcCry query);

    int insert(NcCry row);

    int update(NcCry row);

    int deleteByIds(Long[] ids);

    NcCryChart selectChart(Long babyId, int days);
}
