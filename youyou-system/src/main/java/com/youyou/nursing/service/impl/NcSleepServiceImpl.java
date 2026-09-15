package com.youyou.nursing.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.youyou.common.exception.ServiceException;
import com.youyou.nursing.constant.NursingConstants;
import com.youyou.nursing.domain.NcChartPoint;
import com.youyou.nursing.domain.NcSleep;
import com.youyou.nursing.mapper.NcSleepMapper;
import com.youyou.nursing.service.INcSleepService;

@Service
public class NcSleepServiceImpl implements INcSleepService
{
    @Autowired
    private NcSleepMapper sleepMapper;

    @Autowired
    private NursingRecordHelper helper;

    @Override
    public NcSleep selectById(Long sleepId)
    {
        NcSleep row = sleepMapper.selectById(sleepId);
        if (row == null)
        {
            throw new ServiceException("睡眠记录不存在");
        }
        helper.assertBaby(row.getBabyId());
        return row;
    }

    @Override
    public List<NcSleep> selectList(NcSleep query)
    {
        helper.assertBaby(query.getBabyId());
        return sleepMapper.selectList(query);
    }

    @Override
    public int insert(NcSleep row)
    {
        helper.assertBaby(row.getBabyId());
        row.setDurationMin(helper.minutesBetween(row.getStartTime(), row.getEndTime()));
        row.setOperatorId(helper.operatorId());
        row.setOperatorName(helper.operatorName());
        row.setCreateBy(helper.username());
        row.setRev(1);
        row.setDelFlag(NursingConstants.DEL_NORMAL);
        return sleepMapper.insert(row);
    }

    @Override
    public int update(NcSleep row)
    {
        NcSleep db = selectById(row.getSleepId());
        helper.assertRev(row.getRev(), db.getRev());
        helper.assertWritable(NursingConstants.MODULE_SLEEP, row.getSleepId());
        row.setBabyId(db.getBabyId());
        row.setDurationMin(helper.minutesBetween(row.getStartTime(), row.getEndTime()));
        row.setUpdateBy(helper.username());
        row.setUpdateByName(helper.operatorName());
        int n = sleepMapper.update(row);
        helper.assertUpdated(n);
        return n;
    }

    @Override
    public int deleteByIds(Long[] ids)
    {
        for (Long id : ids)
        {
            selectById(id);
            helper.assertWritable(NursingConstants.MODULE_SLEEP, id);
        }
        return sleepMapper.deleteByIds(ids);
    }

    @Override
    public List<NcChartPoint> selectDailyChart(Long babyId, int days)
    {
        helper.assertBaby(babyId);
        int n = days < 1 ? 7 : days;
        return NursingChartHelper.fillDays(sleepMapper.selectDailyChart(babyId, n), n);
    }
}
