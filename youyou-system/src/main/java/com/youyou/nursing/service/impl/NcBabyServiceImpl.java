package com.youyou.nursing.service.impl;

import java.math.BigDecimal;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import com.youyou.common.core.domain.entity.SysUser;
import com.youyou.common.exception.ServiceException;
import com.youyou.common.utils.SecurityUtils;
import com.youyou.common.utils.StringUtils;
import com.youyou.nursing.constant.NursingConstants;
import com.youyou.nursing.domain.NcBaby;
import com.youyou.nursing.domain.NcBabyMember;
import com.youyou.nursing.mapper.NcBabyMapper;
import com.youyou.nursing.mapper.NcBabyMemberMapper;
import com.youyou.nursing.service.INcBabyService;
import com.youyou.nursing.service.INursingAccessService;
import com.youyou.system.service.ISysUserService;

/**
 * 宝宝档案：超管创建时必须指定妈妈；已存在的妈妈登录名只关联、不改密。
 */
@Service
public class NcBabyServiceImpl implements INcBabyService
{
    @Autowired
    private NcBabyMapper babyMapper;

    @Autowired
    private NcBabyMemberMapper memberMapper;

    @Autowired
    private ISysUserService userService;

    @Autowired
    private INursingAccessService accessService;

    @Override
    public NcBaby selectBabyById(Long babyId)
    {
        accessService.assertBabyAccess(babyId);
        NcBaby baby = babyMapper.selectBabyById(babyId);
        if (baby == null)
        {
            throw new ServiceException("宝宝不存在");
        }
        return baby;
    }

    @Override
    public List<NcBaby> selectBabyList(NcBaby baby)
    {
        fillQueryScope(baby);
        return babyMapper.selectBabyList(baby);
    }

    @Override
    public List<NcBaby> selectMine()
    {
        NcBaby query = new NcBaby();
        fillQueryScope(query);
        return babyMapper.selectBabyList(query);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public int insertBaby(NcBaby baby)
    {
        if (!accessService.isAdmin())
        {
            throw new ServiceException("只有超管可以创建宝宝档案");
        }
        String momLogin = StringUtils.trim(baby.getMomUserName());
        String momTitle = StringUtils.trim(baby.getMomDisplayName());
        validateMeasures(baby);
        validateMomOnCreate(momLogin, momTitle, baby.getMomPassword());

        SysUser mom = resolveOrCreateMom(momLogin, momTitle, baby.getMomPassword());
        baby.setMomUserId(mom.getUserId());
        baby.setMomUserName(mom.getUserName());
        baby.setStatus(NursingConstants.STATUS_NORMAL);
        baby.setDelFlag(NursingConstants.DEL_NORMAL);
        baby.setRev(1);
        if (StringUtils.isEmpty(baby.getGender()))
        {
            baby.setGender("2");
        }
        baby.setMediaDir("baby/pending/");
        int rows = babyMapper.insertBaby(baby);
        String mediaDir = "baby/" + baby.getBabyId() + "/";
        baby.setMediaDir(mediaDir);
        babyMapper.updateMediaDir(baby.getBabyId(), mediaDir);

        if (memberMapper.selectByBabyAndUser(baby.getBabyId(), mom.getUserId()) == null)
        {
            NcBabyMember member = new NcBabyMember();
            member.setBabyId(baby.getBabyId());
            member.setUserId(mom.getUserId());
            member.setRoleTag(NursingConstants.TAG_MOM);
            member.setDisplayName(StringUtils.isNotEmpty(momTitle) ? momTitle : mom.getNickName());
            member.setStatus(NursingConstants.STATUS_NORMAL);
            member.setCreateBy(baby.getCreateBy());
            memberMapper.insertMember(member);
        }
        return rows;
    }

    @Override
    public int updateBaby(NcBaby baby)
    {
        accessService.assertBabyAccess(baby.getBabyId());
        if (!accessService.isAdmin())
        {
            accessService.assertMomOfBaby(baby.getBabyId());
        }
        validateMeasures(baby);
        return babyMapper.updateBaby(baby);
    }

    @Override
    public int deleteBabyByIds(Long[] babyIds)
    {
        if (!accessService.isAdmin())
        {
            throw new ServiceException("只有超管可以删除宝宝档案");
        }
        return babyMapper.deleteBabyByIds(babyIds);
    }

    private void fillQueryScope(NcBaby baby)
    {
        boolean admin = accessService.isAdmin();
        baby.setQueryAdmin(admin);
        if (!admin)
        {
            baby.setQueryUserId(SecurityUtils.getUserId());
        }
    }

    private void validateMeasures(NcBaby baby)
    {
        if (baby.getBirthWeightKg() != null && baby.getBirthWeightKg().compareTo(new BigDecimal("10")) > 0)
        {
            throw new ServiceException("出生体重请按千克填写，例如 3.20，不要填克数");
        }
        if (baby.getBirthHeightCm() != null && baby.getBirthHeightCm().compareTo(new BigDecimal("80")) > 0)
        {
            throw new ServiceException("出生身长请按厘米填写，一般在 40～60");
        }
        if (baby.getBirthHeadCm() != null && baby.getBirthHeadCm().compareTo(new BigDecimal("50")) > 0)
        {
            throw new ServiceException("出生头围请按厘米填写，一般在 30～40");
        }
    }

    private void validateMomOnCreate(String momLogin, String momTitle, String password)
    {
        if (StringUtils.isEmpty(momTitle))
        {
            throw new ServiceException("必须填写妈妈称呼");
        }
        if (StringUtils.isEmpty(momLogin) || !momLogin.matches(NursingConstants.USERNAME_PATTERN))
        {
            throw new ServiceException("妈妈登录名格式非法，需字母开头、2-20 位字母数字或下划线");
        }
        SysUser existed = userService.selectUserByUserName(momLogin);
        if (existed == null)
        {
            if (StringUtils.isEmpty(password)
                    || password.length() < NursingConstants.PASSWORD_MIN_LENGTH
                    || password.length() > NursingConstants.PASSWORD_MAX_LENGTH)
            {
                throw new ServiceException("新建妈妈账号时密码过短，至少 " + NursingConstants.PASSWORD_MIN_LENGTH + " 位");
            }
        }
    }

    /**
     * 登录名不存在 → 创建妈妈账号；已存在且是妈妈 → 只关联不改密；其它角色冲突则拒绝。
     */
    private SysUser resolveOrCreateMom(String momLogin, String momTitle, String password)
    {
        Long momRoleId = babyMapper.selectRoleIdByKey(NursingConstants.ROLE_MOM);
        if (momRoleId == null)
        {
            throw new ServiceException("系统未配置妈妈角色，请先导入护理种子脚本");
        }
        SysUser existed = userService.selectUserByUserName(momLogin);
        if (existed == null)
        {
            SysUser mom = new SysUser();
            mom.setUserName(momLogin);
            mom.setNickName(momTitle);
            mom.setPassword(SecurityUtils.encryptPassword(password));
            mom.setStatus(NursingConstants.STATUS_NORMAL);
            mom.setRoleIds(new Long[] { momRoleId });
            mom.setCreateBy(SecurityUtils.getUsername());
            mom.setRemark("护理工作台自动创建的妈妈账号");
            userService.insertUser(mom);
            return userService.selectUserByUserName(momLogin);
        }
        if (babyMapper.countUserRoleKey(existed.getUserId(), NursingConstants.ROLE_MOM) <= 0)
        {
            throw new ServiceException("登录名与已有账号冲突但不是妈妈，已拒绝创建");
        }
        if (NursingConstants.STATUS_DISABLE.equals(existed.getStatus()))
        {
            throw new ServiceException("该妈妈账号已停用，无法再关联宝宝");
        }
        return existed;
    }
}
