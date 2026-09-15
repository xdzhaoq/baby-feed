package com.youyou.nursing.service.impl;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.youyou.common.exception.ServiceException;
import com.youyou.common.utils.StringUtils;
import com.youyou.nursing.constant.NursingConstants;
import com.youyou.nursing.domain.NcBabyMember;
import com.youyou.nursing.domain.NcHandover;
import com.youyou.nursing.domain.NcMessage;
import com.youyou.nursing.domain.NcMessageMention;
import com.youyou.nursing.domain.NcOperLog;
import com.youyou.nursing.mapper.NcBabyMemberMapper;
import com.youyou.nursing.mapper.NcHandoverMapper;
import com.youyou.nursing.mapper.NcMessageMapper;
import com.youyou.nursing.mapper.NcOperLogMapper;
import com.youyou.nursing.service.INcCollabService;

@Service
public class NcCollabServiceImpl implements INcCollabService
{
    @Autowired
    private NcHandoverMapper handoverMapper;

    @Autowired
    private NcMessageMapper messageMapper;

    @Autowired
    private NcOperLogMapper operLogMapper;

    @Autowired
    private NcBabyMemberMapper memberMapper;

    @Autowired
    private NursingRecordHelper helper;

    @Override
    public List<NcHandover> selectHandoverList(NcHandover query)
    {
        helper.assertBaby(query.getBabyId());
        return handoverMapper.selectList(query);
    }

    @Override
    public int insertHandover(NcHandover row)
    {
        helper.assertBaby(row.getBabyId());
        if (row.getToUserId() == null)
        {
            throw new ServiceException("请选择交接给谁");
        }
        if (row.getToUserId().equals(helper.operatorId()))
        {
            throw new ServiceException("请选择其他成员交接");
        }
        NcBabyMember to = memberMapper.selectByBabyAndUser(row.getBabyId(), row.getToUserId());
        if (to == null || !NursingConstants.STATUS_NORMAL.equals(to.getStatus()))
        {
            throw new ServiceException("交接对象不是该宝宝的家庭成员");
        }
        if (row.getHandoverTime() == null)
        {
            row.setHandoverTime(new Date());
        }
        row.setFromUserId(helper.operatorId());
        row.setFromUserName(helper.operatorName());
        row.setToUserName(to.getDisplayName());
        row.setCreateBy(helper.username());
        int n = handoverMapper.insert(row);
        insertOperLog(row.getBabyId(), NursingConstants.MODULE_HANDOVER, NursingConstants.ACTION_CREATE,
                row.getFromUserName() + " 把宝宝交给 " + row.getToUserName());
        return n;
    }

    @Override
    public List<NcMessage> selectMessageList(NcMessage query)
    {
        helper.assertBaby(query.getBabyId());
        List<NcMessage> list = messageMapper.selectList(query);
        if (list == null || list.isEmpty())
        {
            return list;
        }
        List<Long> ids = new ArrayList<Long>();
        for (NcMessage item : list)
        {
            ids.add(item.getMessageId());
        }
        List<NcMessageMention> mentions = messageMapper.selectMentionsByMessageIds(ids);
        Map<Long, List<NcMessageMention>> grouped = new HashMap<Long, List<NcMessageMention>>();
        if (mentions != null)
        {
            for (NcMessageMention mention : mentions)
            {
                List<NcMessageMention> bucket = grouped.get(mention.getMessageId());
                if (bucket == null)
                {
                    bucket = new ArrayList<NcMessageMention>();
                    grouped.put(mention.getMessageId(), bucket);
                }
                bucket.add(mention);
            }
        }
        for (NcMessage item : list)
        {
            item.setMentions(grouped.get(item.getMessageId()));
        }
        return list;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertMessage(NcMessage row)
    {
        helper.assertBaby(row.getBabyId());
        if (StringUtils.isEmpty(row.getContent()))
        {
            throw new ServiceException("请填写留言");
        }
        row.setAuthorId(helper.operatorId());
        row.setAuthorName(helper.operatorName());
        row.setDelFlag(NursingConstants.DEL_NORMAL);
        int n = messageMapper.insert(row);
        if (row.getMentionUserIds() != null)
        {
            for (Long userId : row.getMentionUserIds())
            {
                if (userId == null || userId.equals(row.getAuthorId()))
                {
                    continue;
                }
                NcBabyMember member = memberMapper.selectByBabyAndUser(row.getBabyId(), userId);
                if (member == null || !NursingConstants.STATUS_NORMAL.equals(member.getStatus()))
                {
                    throw new ServiceException("只能 @ 当前宝宝的家庭成员");
                }
                NcMessageMention mention = new NcMessageMention();
                mention.setMessageId(row.getMessageId());
                mention.setBabyId(row.getBabyId());
                mention.setMentionedUserId(userId);
                mention.setMentionedName(member.getDisplayName());
                mention.setReadFlag("0");
                messageMapper.insertMention(mention);
            }
        }
        insertOperLog(row.getBabyId(), NursingConstants.MODULE_MESSAGE, NursingConstants.ACTION_CREATE, "发布留言");
        return n;
    }

    @Override
    public List<NcMessageMention> selectUnreadMentions(Long babyId)
    {
        helper.assertBaby(babyId);
        return messageMapper.selectUnread(babyId, helper.operatorId());
    }

    @Override
    public int markMentionRead(Long mentionId)
    {
        return messageMapper.markRead(mentionId, helper.operatorId());
    }

    @Override
    public int markAllMentionsRead(Long babyId)
    {
        helper.assertBaby(babyId);
        return messageMapper.markAllRead(babyId, helper.operatorId());
    }

    @Override
    public List<NcOperLog> selectOperLogList(NcOperLog query)
    {
        helper.assertBaby(query.getBabyId());
        return operLogMapper.selectList(query);
    }

    @Override
    public int insertOperLog(Long babyId, String moduleCode, String actionCode, String summary)
    {
        if (StringUtils.isEmpty(moduleCode) || StringUtils.isEmpty(summary))
        {
            return 0;
        }
        NcOperLog row = new NcOperLog();
        row.setBabyId(babyId);
        row.setModuleCode(moduleCode);
        row.setActionCode(StringUtils.isEmpty(actionCode) ? NursingConstants.ACTION_UPDATE : actionCode);
        row.setSummary(summary);
        row.setOperatorId(helper.operatorId());
        row.setOperatorName(helper.operatorName());
        return operLogMapper.insert(row);
    }
}
