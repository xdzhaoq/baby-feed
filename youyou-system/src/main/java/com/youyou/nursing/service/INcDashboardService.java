package com.youyou.nursing.service;

import java.util.List;
import com.youyou.nursing.domain.NcAdminOverview;
import com.youyou.nursing.domain.NcKnowledge;
import com.youyou.nursing.domain.NcTodayOverview;

public interface INcDashboardService
{
    NcTodayOverview selectToday(Long babyId);

    NcAdminOverview selectAdminOverview();

    List<NcKnowledge> selectKnowledge(String category, String keyword);

    NcKnowledge selectKnowledgeById(Long kbId);
}
