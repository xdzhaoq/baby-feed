package com.youyou.nursing.mapper;

import java.util.List;
import com.youyou.nursing.domain.NcVaccineItem;
import com.youyou.nursing.domain.NcVaccineMark;

public interface NcVaccineMapper
{
    List<NcVaccineItem> selectBoard(Long babyId);

    NcVaccineItem selectScheduleById(Long scheduleId);

    int insertSchedule(NcVaccineItem item);

    int deleteRecordsBySchedule(Long scheduleId);

    int deleteSchedule(Long scheduleId);

    int upsertRecord(NcVaccineMark mark);
}
