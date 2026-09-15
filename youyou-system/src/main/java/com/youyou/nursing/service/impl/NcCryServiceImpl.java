package com.youyou.nursing.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.youyou.common.exception.ServiceException;
import com.youyou.nursing.constant.NursingConstants;
import com.youyou.nursing.domain.NcChartPoint;
import com.youyou.nursing.domain.NcCry;
import com.youyou.nursing.domain.NcCryChart;
import com.youyou.nursing.mapper.NcCryMapper;
import com.youyou.nursing.service.INcCryService;

@Service
public class NcCryServiceImpl implements INcCryService
{
    @Autowired
    private NcCryMapper cryMapper;

    @Autowired
    private NursingRecordHelper helper;

    @Override
    public NcCry selectById(Long cryId)
    {
        NcCry row = cryMapper.selectById(cryId);
        if (row == null)
        {
            throw new ServiceException("哭闹记录不存在");
        }
        helper.assertBaby(row.getBabyId());
        return row;
    }

    @Override
    public List<NcCry> selectList(NcCry query)
    {
        helper.assertBaby(query.getBabyId());
        return cryMapper.selectList(query);
    }

    @Override
    public int insert(NcCry row)
    {
        helper.assertBaby(row.getBabyId());
        helper.minutesBetween(row.getStartTime(), row.getEndTime());
        row.setOperatorId(helper.operatorId());
        row.setOperatorName(helper.operatorName());
        row.setCreateBy(helper.username());
        row.setRev(1);
        row.setDelFlag(NursingConstants.DEL_NORMAL);
        return cryMapper.insert(row);
    }

    @Override
    public int update(NcCry row)
    {
        NcCry db = selectById(row.getCryId());
        helper.assertRev(row.getRev(), db.getRev());
        helper.assertWritable(NursingConstants.MODULE_CRY, row.getCryId());
        helper.minutesBetween(row.getStartTime(), row.getEndTime());
        row.setBabyId(db.getBabyId());
        row.setUpdateBy(helper.username());
        row.setUpdateByName(helper.operatorName());
        int n = cryMapper.update(row);
        helper.assertUpdated(n);
        return n;
    }

    @Override
    public int deleteByIds(Long[] ids)
    {
        for (Long id : ids)
        {
            selectById(id);
            helper.assertWritable(NursingConstants.MODULE_CRY, id);
        }
        return cryMapper.deleteByIds(ids);
    }

    @Override
    public NcCryChart selectChart(Long babyId, int days)
    {
        helper.assertBaby(babyId);
        int n = days < 1 ? 14 : days;
        NcCryChart chart = new NcCryChart();
        chart.setHours(NursingChartHelper.fillHours(cryMapper.selectHourChart(babyId, n)));
        chart.setSoothe(cryMapper.selectSootheChart(babyId, n));
        return chart;
    }
}
