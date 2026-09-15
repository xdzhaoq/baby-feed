package com.youyou.nursing.service;

import java.util.List;
import com.youyou.nursing.domain.NcHealthCheck;
import com.youyou.nursing.domain.NcVaccineItem;
import com.youyou.nursing.domain.NcVaccineMark;

public interface INcHealthService
{
    NcHealthCheck selectById(Long checkId);

    List<NcHealthCheck> selectList(NcHealthCheck query);

    int insert(NcHealthCheck row);

    int update(NcHealthCheck row);

    List<NcVaccineItem> selectVaccineBoard(Long babyId);

    int insertSchedule(Long babyId, NcVaccineItem item);

    int deleteSchedule(Long babyId, Long scheduleId);

    int markVaccine(NcVaccineMark mark);
}
