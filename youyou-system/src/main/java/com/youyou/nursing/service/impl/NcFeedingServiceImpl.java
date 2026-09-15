package com.youyou.nursing.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.youyou.common.exception.ServiceException;
import com.youyou.nursing.constant.NursingConstants;
import com.youyou.nursing.domain.NcChartPoint;
import com.youyou.nursing.domain.NcFeeding;
import com.youyou.nursing.mapper.NcFeedingMapper;
import com.youyou.nursing.service.INcFeedingService;

@Service
public class NcFeedingServiceImpl implements INcFeedingService
{
    @Autowired
    private NcFeedingMapper feedingMapper;

    @Autowired
    private NursingRecordHelper helper;

    @Override
    public NcFeeding selectById(Long feedingId)
    {
        NcFeeding row = feedingMapper.selectById(feedingId);
        if (row == null)
        {
            throw new ServiceException("喂养记录不存在");
        }
        helper.assertBaby(row.getBabyId());
        return row;
    }

    @Override
    public List<NcFeeding> selectList(NcFeeding query)
    {
        helper.assertBaby(query.getBabyId());
        return feedingMapper.selectList(query);
    }

    @Override
    public int insert(NcFeeding row)
    {
        helper.assertBaby(row.getBabyId());
        fillDuration(row);
        row.setOperatorId(helper.operatorId());
        row.setOperatorName(helper.operatorName());
        row.setCreateBy(helper.username());
        row.setRev(1);
        row.setDelFlag(NursingConstants.DEL_NORMAL);
        if (row.getBurped() == null)
        {
            row.setBurped("0");
        }
        return feedingMapper.insert(row);
    }

    @Override
    public int update(NcFeeding row)
    {
        NcFeeding db = selectById(row.getFeedingId());
        helper.assertRev(row.getRev(), db.getRev());
        helper.assertWritable(NursingConstants.MODULE_FEEDING, row.getFeedingId());
        fillDuration(row);
        row.setBabyId(db.getBabyId());
        row.setUpdateBy(helper.username());
        row.setUpdateByName(helper.operatorName());
        if (row.getBurped() == null)
        {
            row.setBurped(db.getBurped());
        }
        int n = feedingMapper.update(row);
        helper.assertUpdated(n);
        return n;
    }

    @Override
    public int deleteByIds(Long[] ids)
    {
        for (Long id : ids)
        {
            selectById(id);
            helper.assertWritable(NursingConstants.MODULE_FEEDING, id);
        }
        return feedingMapper.deleteByIds(ids);
    }

    @Override
    public List<NcChartPoint> selectDailyChart(Long babyId, int days)
    {
        helper.assertBaby(babyId);
        int n = days < 1 ? 7 : days;
        return NursingChartHelper.fillDays(feedingMapper.selectDailyChart(babyId, n), n);
    }

    private void fillDuration(NcFeeding row)
    {
        if (row.getDurationMin() == null
                && (row.getLeftDuration() != null || row.getRightDuration() != null))
        {
            int left = row.getLeftDuration() == null ? 0 : row.getLeftDuration();
            int right = row.getRightDuration() == null ? 0 : row.getRightDuration();
            row.setDurationMin(left + right);
        }
    }
}
