package com.youyou.nursing.service.impl;

import java.util.Calendar;
import java.util.Date;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.youyou.common.exception.ServiceException;
import com.youyou.common.utils.StringUtils;
import com.youyou.nursing.constant.NursingConstants;
import com.youyou.nursing.domain.NcHealthCheck;
import com.youyou.nursing.domain.NcVaccineItem;
import com.youyou.nursing.domain.NcVaccineMark;
import com.youyou.nursing.mapper.NcHealthCheckMapper;
import com.youyou.nursing.mapper.NcVaccineMapper;
import com.youyou.nursing.service.INcHealthService;

@Service
public class NcHealthServiceImpl implements INcHealthService
{
    @Autowired
    private NcHealthCheckMapper healthMapper;

    @Autowired
    private NcVaccineMapper vaccineMapper;

    @Autowired
    private NursingRecordHelper helper;

    @Override
    public NcHealthCheck selectById(Long checkId)
    {
        NcHealthCheck row = healthMapper.selectById(checkId);
        if (row == null)
        {
            throw new ServiceException("自检记录不存在");
        }
        helper.assertBaby(row.getBabyId());
        return row;
    }

    @Override
    public List<NcHealthCheck> selectList(NcHealthCheck query)
    {
        helper.assertBaby(query.getBabyId());
        return healthMapper.selectList(query);
    }

    @Override
    public int insert(NcHealthCheck row)
    {
        helper.assertBaby(row.getBabyId());
        NcHealthCheck exists = healthMapper.selectByBabyDate(row.getBabyId(), row.getCheckDate());
        if (exists != null)
        {
            throw new ServiceException("该日已有自检，请直接修改原记录");
        }
        row.setOperatorId(helper.operatorId());
        row.setOperatorName(helper.operatorName());
        row.setCreateBy(helper.username());
        row.setRev(1);
        row.setDelFlag(NursingConstants.DEL_NORMAL);
        return healthMapper.insert(row);
    }

    @Override
    public int update(NcHealthCheck row)
    {
        NcHealthCheck db = selectById(row.getCheckId());
        helper.assertRev(row.getRev(), db.getRev());
        helper.assertWritable(NursingConstants.MODULE_HEALTH, row.getCheckId());
        row.setBabyId(db.getBabyId());
        row.setUpdateBy(helper.username());
        row.setUpdateByName(helper.operatorName());
        int n = healthMapper.update(row);
        helper.assertUpdated(n);
        return n;
    }

    @Override
    public List<NcVaccineItem> selectVaccineBoard(Long babyId)
    {
        helper.assertBaby(babyId);
        List<NcVaccineItem> list = vaccineMapper.selectBoard(babyId);
        Date today = startOfDay(new Date());
        for (NcVaccineItem item : list)
        {
            fillVaccineStatus(item, today);
        }
        return list;
    }

    @Override
    public int insertSchedule(Long babyId, NcVaccineItem item)
    {
        helper.assertBaby(babyId);
        if (item.getDueAgeDays() < 0 || item.getDueAgeDays() > 730)
        {
            throw new ServiceException("建议日龄请填 0–730（0 为出生当天）");
        }
        if (item.getDoseNo() == null || item.getDoseNo() < 1)
        {
            item.setDoseNo(1);
        }
        if (item.getTotalDoses() == null || item.getTotalDoses() < item.getDoseNo())
        {
            item.setTotalDoses(item.getDoseNo());
        }
        if (item.getRemindBefore() == null || item.getRemindBefore() < 0)
        {
            item.setRemindBefore(3);
        }
        if (StringUtils.isEmpty(item.getVaccineCode()))
        {
            item.setVaccineCode("C" + System.currentTimeMillis() % 1000000000L);
        }
        else if (item.getVaccineCode().length() > 30)
        {
            item.setVaccineCode(item.getVaccineCode().substring(0, 30));
        }
        item.setSortNum(item.getDueAgeDays() * 10 + item.getDoseNo());
        return vaccineMapper.insertSchedule(item);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int deleteSchedule(Long babyId, Long scheduleId)
    {
        helper.assertBaby(babyId);
        NcVaccineItem db = vaccineMapper.selectScheduleById(scheduleId);
        if (db == null)
        {
            throw new ServiceException("接种项不存在");
        }
        vaccineMapper.deleteRecordsBySchedule(scheduleId);
        int n = vaccineMapper.deleteSchedule(scheduleId);
        if (n == 0)
        {
            throw new ServiceException("删除失败");
        }
        return n;
    }

    @Override
    public int markVaccine(NcVaccineMark mark)
    {
        helper.assertBaby(mark.getBabyId());
        if (mark.getInoculated() == null)
        {
            mark.setInoculated("1");
        }
        if ("1".equals(mark.getInoculated()) && mark.getInoculateDate() == null)
        {
            mark.setInoculateDate(new Date());
        }
        if ("0".equals(mark.getInoculated()))
        {
            mark.setInoculateDate(null);
        }
        mark.setOperatorId(helper.operatorId());
        mark.setOperatorName(helper.operatorName());
        return vaccineMapper.upsertRecord(mark);
    }

    static void fillVaccineStatus(NcVaccineItem item, Date today)
    {
        if ("1".equals(item.getInoculated()))
        {
            item.setStatus("done");
            item.setRemainDays(null);
            return;
        }
        if (item.getDueDate() == null)
        {
            item.setStatus("wait");
            return;
        }
        long diff = (item.getDueDate().getTime() - today.getTime()) / (24L * 3600 * 1000);
        item.setRemainDays((int) diff);
        int remind = item.getRemindBefore() == null ? 3 : item.getRemindBefore();
        if (diff < 0)
        {
            item.setStatus("overdue");
        }
        else if (diff <= remind)
        {
            item.setStatus("soon");
        }
        else
        {
            item.setStatus("wait");
        }
    }

    private Date startOfDay(Date date)
    {
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(date);
        calendar.set(Calendar.HOUR_OF_DAY, 0);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);
        return calendar.getTime();
    }
}
