package com.youyou.nursing.service.impl;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.youyou.common.core.domain.entity.SysUser;
import com.youyou.common.exception.ServiceException;
import com.youyou.common.utils.SecurityUtils;
import com.youyou.common.utils.StringUtils;
import com.youyou.nursing.constant.NursingConstants;
import com.youyou.nursing.domain.NcBabyMember;
import com.youyou.nursing.mapper.NcBabyMapper;
import com.youyou.nursing.mapper.NcBabyMemberMapper;
import com.youyou.nursing.service.INcBabyMemberService;
import com.youyou.nursing.service.INursingAccessService;
import com.youyou.system.service.ISysUserService;

/**
 * 妈妈为本宝宝创建独立家人账号；停用不删除。
 */
@Service
public class NcBabyMemberServiceImpl implements INcBabyMemberService
{
    @Autowired
    private NcBabyMemberMapper memberMapper;

    @Autowired
    private NcBabyMapper babyMapper;

    @Autowired
    private ISysUserService userService;

    @Autowired
    private INursingAccessService accessService;

    @Override
    public NcBabyMember selectMemberById(Long memberId)
    {
        NcBabyMember member = memberMapper.selectMemberById(memberId);
        if (member == null)
        {
            throw new ServiceException("成员不存在");
        }
        accessService.assertBabyAccess(member.getBabyId());
        return member;
    }

    @Override
    public List<NcBabyMember> selectMemberList(NcBabyMember member)
    {
        if (member.getBabyId() == null)
        {
            throw new ServiceException("请先选择宝宝");
        }
        accessService.assertBabyAccess(member.getBabyId());
        return memberMapper.selectMemberList(member);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertMember(NcBabyMember member)
    {
        accessService.assertMomOfBaby(member.getBabyId());
        if (NursingConstants.TAG_MOM.equals(member.getRoleTag()))
        {
            throw new ServiceException("请通过超管创建宝宝来指定妈妈，不能在此新增妈妈");
        }
        String login = StringUtils.trim(member.getUserName());
        String password = member.getPassword();
        if (StringUtils.isEmpty(login) || !login.matches(NursingConstants.USERNAME_PATTERN))
        {
            throw new ServiceException("登录名格式非法，需字母开头、2-20 位字母数字或下划线");
        }
        if (StringUtils.isEmpty(password)
                || password.length() < NursingConstants.PASSWORD_MIN_LENGTH
                || password.length() > NursingConstants.PASSWORD_MAX_LENGTH)
        {
            throw new ServiceException("初始密码过短，至少 " + NursingConstants.PASSWORD_MIN_LENGTH + " 位");
        }
        if (userService.selectUserByUserName(login) != null)
        {
            throw new ServiceException("登录名已存在，请换一个");
        }
        Long familyRoleId = babyMapper.selectRoleIdByKey(NursingConstants.ROLE_FAMILY);
        if (familyRoleId == null)
        {
            throw new ServiceException("系统未配置家人角色，请先导入护理种子脚本");
        }
        SysUser user = new SysUser();
        user.setUserName(login);
        user.setNickName(member.getDisplayName());
        user.setPassword(SecurityUtils.encryptPassword(password));
        user.setStatus(NursingConstants.STATUS_NORMAL);
        user.setRoleIds(new Long[] { familyRoleId });
        user.setCreateBy(SecurityUtils.getUsername());
        user.setRemark("护理工作台家人账号");
        userService.insertUser(user);
        SysUser saved = userService.selectUserByUserName(login);

        member.setUserId(saved.getUserId());
        member.setStatus(NursingConstants.STATUS_NORMAL);
        member.setCreateBy(SecurityUtils.getUsername());
        return memberMapper.insertMember(member);
    }

    @Override
    public int updateMember(NcBabyMember member)
    {
        NcBabyMember db = selectMemberById(member.getMemberId());
        accessService.assertMomOfBaby(db.getBabyId());
        if (NursingConstants.TAG_MOM.equals(db.getRoleTag()) && member.getRoleTag() != null
                && !NursingConstants.TAG_MOM.equals(member.getRoleTag()))
        {
            throw new ServiceException("不能把妈妈改成其他角色");
        }
        member.setBabyId(db.getBabyId());
        member.setUpdateBy(SecurityUtils.getUsername());
        int rows = memberMapper.updateMember(member);
        if (StringUtils.isNotEmpty(member.getDisplayName()) && db.getUserId() != null)
        {
            SysUser user = new SysUser();
            user.setUserId(db.getUserId());
            user.setNickName(member.getDisplayName());
            userService.updateUserProfile(user);
        }
        return rows;
    }

    @Override
    public int changeStatus(NcBabyMember member)
    {
        NcBabyMember db = selectMemberById(member.getMemberId());
        accessService.assertMomOfBaby(db.getBabyId());
        if (NursingConstants.TAG_MOM.equals(db.getRoleTag()))
        {
            throw new ServiceException("不能停用妈妈账号，请联系超管");
        }
        db.setStatus(member.getStatus());
        db.setUpdateBy(SecurityUtils.getUsername());
        return memberMapper.updateMember(db);
    }

    @Override
    public int resetPassword(Long memberId, String password)
    {
        NcBabyMember db = selectMemberById(memberId);
        accessService.assertMomOfBaby(db.getBabyId());
        if (StringUtils.isEmpty(password)
                || password.length() < NursingConstants.PASSWORD_MIN_LENGTH
                || password.length() > NursingConstants.PASSWORD_MAX_LENGTH)
        {
            throw new ServiceException("密码过短，至少 " + NursingConstants.PASSWORD_MIN_LENGTH + " 位");
        }
        SysUser user = new SysUser();
        user.setUserId(db.getUserId());
        user.setPassword(SecurityUtils.encryptPassword(password));
        return userService.resetPwd(user);
    }

    @Override
    public int heartbeat(Long babyId)
    {
        accessService.assertBabyAccess(babyId);
        if (accessService.isAdmin())
        {
            return 1;
        }
        int rows = memberMapper.heartbeat(babyId, SecurityUtils.getUserId());
        return rows > 0 ? rows : 1;
    }
}
