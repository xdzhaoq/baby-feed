package com.youyou.nursing.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.youyou.common.exception.ServiceException;
import com.youyou.nursing.constant.NursingConstants;
import com.youyou.nursing.domain.NcGrowth;
import com.youyou.nursing.mapper.NcGrowthMapper;
import com.youyou.nursing.service.INcGrowthService;

@Service
public class NcGrowthServiceImpl implements INcGrowthService
{
    @Autowired
    private NcGrowthMapper growthMapper;

    @Autowired
    private NursingRecordHelper helper;

    @Override
    public NcGrowth selectById(Long growthId)
    {
        NcGrowth row = growthMapper.selectById(growthId);
        if (row == null)
        {
            throw new ServiceException("生长记录不存在");
        }
        helper.assertBaby(row.getBabyId());
        return row;
    }

    @Override
    public List<NcGrowth> selectList(NcGrowth query)
    {
        helper.assertBaby(query.getBabyId());
        return growthMapper.selectList(query);
    }

    @Override
    public int insert(NcGrowth row)
    {
        helper.assertBaby(row.getBabyId());
        row.setOperatorId(helper.operatorId());
        row.setOperatorName(helper.operatorName());
        row.setCreateBy(helper.username());
        row.setRev(1);
        row.setDelFlag(NursingConstants.DEL_NORMAL);
        return growthMapper.insert(row);
    }

    @Override
    public int update(NcGrowth row)
    {
        NcGrowth db = selectById(row.getGrowthId());
        helper.assertRev(row.getRev(), db.getRev());
        helper.assertWritable(NursingConstants.MODULE_GROWTH, row.getGrowthId());
        row.setBabyId(db.getBabyId());
        row.setUpdateBy(helper.username());
        row.setUpdateByName(helper.operatorName());
        int n = growthMapper.update(row);
        helper.assertUpdated(n);
        return n;
    }

    @Override
    public int deleteByIds(Long[] ids)
    {
        for (Long id : ids)
        {
            selectById(id);
            helper.assertWritable(NursingConstants.MODULE_GROWTH, id);
        }
        return growthMapper.deleteByIds(ids);
    }
}
