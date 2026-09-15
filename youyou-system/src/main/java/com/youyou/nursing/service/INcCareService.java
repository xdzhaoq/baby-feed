package com.youyou.nursing.service;

import java.util.Date;
import java.util.List;
import com.youyou.nursing.domain.NcCareItem;
import com.youyou.nursing.domain.NcCareLog;

public interface INcCareService
{
    List<NcCareItem> selectToday(Long babyId, Date careDate);

    int insertCustom(NcCareItem item);

    int deleteCustom(Long itemId, Long babyId);

    int toggle(NcCareLog log);
}
