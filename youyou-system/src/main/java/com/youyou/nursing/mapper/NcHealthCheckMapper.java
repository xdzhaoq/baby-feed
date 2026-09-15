package com.youyou.nursing.mapper;

import java.util.Date;
import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.youyou.nursing.domain.NcHealthCheck;

public interface NcHealthCheckMapper
{
    NcHealthCheck selectById(Long checkId);

    NcHealthCheck selectByBabyDate(@Param("babyId") Long babyId, @Param("checkDate") Date checkDate);

    List<NcHealthCheck> selectList(NcHealthCheck query);

    int insert(NcHealthCheck row);

    int update(NcHealthCheck row);
}
