package com.youyou.nursing.mapper;

import java.util.List;
import com.youyou.nursing.domain.NcGrowth;

public interface NcGrowthMapper
{
    NcGrowth selectById(Long growthId);

    List<NcGrowth> selectList(NcGrowth query);

    int insert(NcGrowth row);

    int update(NcGrowth row);

    int deleteByIds(Long[] ids);
}
