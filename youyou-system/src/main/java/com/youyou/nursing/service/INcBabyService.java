package com.youyou.nursing.service;

import java.util.List;
import com.youyou.nursing.domain.NcBaby;

public interface INcBabyService
{
    NcBaby selectBabyById(Long babyId);

    List<NcBaby> selectBabyList(NcBaby baby);

    List<NcBaby> selectMine();

    int insertBaby(NcBaby baby);

    int updateBaby(NcBaby baby);

    int deleteBabyByIds(Long[] babyIds);
}
