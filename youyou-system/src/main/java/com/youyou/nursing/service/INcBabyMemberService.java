package com.youyou.nursing.service;

import java.util.List;
import com.youyou.nursing.domain.NcBabyMember;

public interface INcBabyMemberService
{
    NcBabyMember selectMemberById(Long memberId);

    List<NcBabyMember> selectMemberList(NcBabyMember member);

    int insertMember(NcBabyMember member);

    int updateMember(NcBabyMember member);

    int changeStatus(NcBabyMember member);

    int resetPassword(Long memberId, String password);

    int heartbeat(Long babyId);
}
