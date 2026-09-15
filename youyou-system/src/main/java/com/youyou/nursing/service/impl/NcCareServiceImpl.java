package com.youyou.nursing.service.impl;

import java.util.Date;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.youyou.common.exception.ServiceException;
import com.youyou.common.utils.StringUtils;
import com.youyou.nursing.constant.NursingConstants;
import com.youyou.nursing.domain.NcCareItem;
import com.youyou.nursing.domain.NcCareLog;
import com.youyou.nursing.mapper.NcCareItemMapper;
import com.youyou.nursing.service.INcCareService;

@Service
public class NcCareServiceImpl implements INcCareService
{
    @Autowired
    private NcCareItemMapper careMapper;

    @Autowired
    private NursingRecordHelper helper;

    @Override
    public List<NcCareItem> selectToday(Long babyId, Date careDate)
    {
        helper.assertBaby(babyId);
        Date day = careDate == null ? new java.sql.Date(System.currentTimeMillis()) : careDate;
        List<NcCareItem> list = careMapper.selectTodayList(babyId, day);
        for (NcCareItem item : list)
        {
            item.setCareDate(day);
        }
        return list;
    }

    @Override
    public int insertCustom(NcCareItem item)
    {
        helper.assertBaby(item.getBabyId());
        item.setIsBuiltin("0");
        item.setStatus(NursingConstants.STATUS_NORMAL);
        item.setDelFlag(NursingConstants.DEL_NORMAL);
        item.setCreateBy(helper.username());
        if (item.getSortNum() == null)
        {
            item.setSortNum(100);
        }
        return careMapper.insertItem(item);
    }

    @Override
    public int deleteCustom(Long itemId, Long babyId)
    {
        helper.assertBaby(babyId);
        NcCareItem db = careMapper.selectById(itemId);
        if (db == null)
        {
            throw new ServiceException("事项不存在");
        }
        if (isBuiltin(db))
        {
            careMapper.hideItem(babyId, itemId);
            return 1;
        }
        if (!babyId.equals(db.getBabyId()))
        {
            throw new ServiceException("无权删除该事项");
        }
        int n = careMapper.deleteCustom(itemId, babyId);
        if (n == 0)
        {
            throw new ServiceException("删除失败");
        }
        return n;
    }

    private boolean isBuiltin(NcCareItem item)
    {
        return item.getBabyId() == null || "1".equals(StringUtils.trim(item.getIsBuiltin()));
    }

    @Override
    public int toggle(NcCareLog log)
    {
        helper.assertBaby(log.getBabyId());
        if (log.getCareDate() == null)
        {
            log.setCareDate(new Date());
        }
        if (log.getCompleted() == null)
        {
            log.setCompleted("1");
        }
        log.setOperatorId(helper.operatorId());
        log.setOperatorName(helper.operatorName());
        return careMapper.upsertLog(log);
    }
}
