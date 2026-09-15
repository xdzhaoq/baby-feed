package com.youyou.nursing.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.youyou.common.exception.ServiceException;
import com.youyou.nursing.constant.NursingConstants;
import com.youyou.nursing.domain.NcChartPoint;
import com.youyou.nursing.domain.NcDiaper;
import com.youyou.nursing.domain.NcDiaperChart;
import com.youyou.nursing.mapper.NcDiaperMapper;
import com.youyou.nursing.service.INcDiaperService;

@Service
public class NcDiaperServiceImpl implements INcDiaperService
{
    @Autowired
    private NcDiaperMapper diaperMapper;

    @Autowired
    private NursingRecordHelper helper;

    @Override
    public NcDiaper selectById(Long diaperId)
    {
        NcDiaper row = diaperMapper.selectById(diaperId);
        if (row == null)
        {
            throw new ServiceException("尿布记录不存在");
        }
        helper.assertBaby(row.getBabyId());
        return row;
    }

    @Override
    public List<NcDiaper> selectList(NcDiaper query)
    {
        helper.assertBaby(query.getBabyId());
        return diaperMapper.selectList(query);
    }

    @Override
    public int insert(NcDiaper row)
    {
        helper.assertBaby(row.getBabyId());
        if ("pee".equals(row.getDiaperType()))
        {
            row.setStoolTexture(null);
        }
        row.setOperatorId(helper.operatorId());
        row.setOperatorName(helper.operatorName());
        row.setCreateBy(helper.username());
        row.setRev(1);
        row.setDelFlag(NursingConstants.DEL_NORMAL);
        return diaperMapper.insert(row);
    }

    @Override
    public int update(NcDiaper row)
    {
        NcDiaper db = selectById(row.getDiaperId());
        helper.assertRev(row.getRev(), db.getRev());
        helper.assertWritable(NursingConstants.MODULE_DIAPER, row.getDiaperId());
        row.setBabyId(db.getBabyId());
        if ("pee".equals(row.getDiaperType()))
        {
            row.setStoolTexture(null);
        }
        row.setUpdateBy(helper.username());
        row.setUpdateByName(helper.operatorName());
        int n = diaperMapper.update(row);
        helper.assertUpdated(n);
        return n;
    }

    @Override
    public int deleteByIds(Long[] ids)
    {
        for (Long id : ids)
        {
            selectById(id);
            helper.assertWritable(NursingConstants.MODULE_DIAPER, id);
        }
        return diaperMapper.deleteByIds(ids);
    }

    @Override
    public NcDiaperChart selectChart(Long babyId, int days)
    {
        helper.assertBaby(babyId);
        int n = days < 1 ? 7 : days;
        NcDiaperChart chart = new NcDiaperChart();
        NcChartPoint today = diaperMapper.selectTodayStat(babyId);
        chart.setTodayCount(today == null || today.getCount() == null ? Integer.valueOf(0) : today.getCount());
        chart.setTodayAbnormal(today == null || today.getExtra() == null ? Integer.valueOf(0) : today.getExtra());
        chart.setDays(NursingChartHelper.fillDays(diaperMapper.selectDailyChart(babyId, n), n));
        return chart;
    }
}
