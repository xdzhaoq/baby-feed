package com.youyou.nursing.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.youyou.nursing.domain.NcBabyMember;

/**
 * 家庭成员
 */
public interface NcBabyMemberMapper
{
    NcBabyMember selectMemberById(Long memberId);

    NcBabyMember selectByBabyAndUser(@Param("babyId") Long babyId, @Param("userId") Long userId);

    List<NcBabyMember> selectMemberList(NcBabyMember member);

    int insertMember(NcBabyMember member);

    int updateMember(NcBabyMember member);

    int heartbeat(@Param("babyId") Long babyId, @Param("userId") Long userId);
}
