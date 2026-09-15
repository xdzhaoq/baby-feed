package com.youyou.nursing.service.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.youyou.common.constant.HttpStatus;
import com.youyou.common.core.domain.model.LoginUser;
import com.youyou.common.exception.ServiceException;
import com.youyou.common.utils.SecurityUtils;
import com.youyou.common.utils.StringUtils;
import com.youyou.nursing.constant.NursingConstants;
import com.youyou.nursing.domain.NcBabyMember;
import com.youyou.nursing.mapper.NcBabyMemberMapper;
import com.youyou.nursing.service.INursingAccessService;

/**
 * 跨宝宝访问一律 403
 */
@Service
public class NursingAccessServiceImpl implements INursingAccessService
{
    @Autowired
    private NcBabyMemberMapper memberMapper;

    @Override
    public boolean isAdmin()
    {
        return SecurityUtils.isAdmin(SecurityUtils.getUserId());
    }

    @Override
    public NcBabyMember assertBabyAccess(Long babyId)
    {
        if (babyId == null)
        {
            throw new ServiceException("未指定宝宝", HttpStatus.BAD_REQUEST);
        }
        if (isAdmin())
        {
            return null;
        }
        NcBabyMember member = memberMapper.selectByBabyAndUser(babyId, SecurityUtils.getUserId());
        if (member == null || !NursingConstants.STATUS_NORMAL.equals(member.getStatus()))
        {
            throw new ServiceException("无权访问该宝宝的数据", HttpStatus.FORBIDDEN);
        }
        return member;
    }

    @Override
    public void assertMomOfBaby(Long babyId)
    {
        if (isAdmin())
        {
            return;
        }
        NcBabyMember member = assertBabyAccess(babyId);
        if (member == null || !NursingConstants.TAG_MOM.equals(member.getRoleTag()))
        {
            throw new ServiceException("只有妈妈可以管理家庭成员", HttpStatus.FORBIDDEN);
        }
    }

    @Override
    public String currentOperatorName()
    {
        LoginUser loginUser = SecurityUtils.getLoginUser();
        if (loginUser.getUser() != null && StringUtils.isNotEmpty(loginUser.getUser().getNickName()))
        {
            return loginUser.getUser().getNickName();
        }
        return SecurityUtils.getUsername();
    }
}
