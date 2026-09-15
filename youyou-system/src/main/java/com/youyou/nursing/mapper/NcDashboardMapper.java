package com.youyou.nursing.mapper;

import java.util.List;
import com.youyou.nursing.domain.NcAdminBabyCard;
import com.youyou.nursing.domain.NcTodayOverview;

public interface NcDashboardMapper
{
    NcTodayOverview selectTodayOverview(Long babyId);

    List<NcAdminBabyCard> selectAdminBabyCards();
}
