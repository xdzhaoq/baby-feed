package com.youyou.nursing.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.youyou.nursing.domain.NcBaby;

/**
 * 宝宝档案
 */
public interface NcBabyMapper
{
    NcBaby selectBabyById(Long babyId);

    List<NcBaby> selectBabyList(NcBaby baby);

    int insertBaby(NcBaby baby);

    int updateBaby(NcBaby baby);

    int updateMediaDir(@Param("babyId") Long babyId, @Param("mediaDir") String mediaDir);

    int deleteBabyByIds(Long[] babyIds);

    Long selectRoleIdByKey(String roleKey);

    int countUserRoleKey(@Param("userId") Long userId, @Param("roleKey") String roleKey);
}
