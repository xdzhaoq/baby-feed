package com.youyou.nursing.service;

import com.youyou.nursing.domain.NcBabyMember;

/**
 * 按宝宝隔离：前端传的 babyId 不可信，必须在服务端校验。
 */
public interface INursingAccessService
{
    boolean isAdmin();

    /**
     * 当前用户是否可读写该宝宝；否则抛出 403
     */
    NcBabyMember assertBabyAccess(Long babyId);

    /**
     * 超管或该宝宝的妈妈才能管理成员
     */
    void assertMomOfBaby(Long babyId);

    /** 当前登录人展示名（昵称优先） */
    String currentOperatorName();
}
