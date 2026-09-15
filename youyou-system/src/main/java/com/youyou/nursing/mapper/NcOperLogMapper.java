package com.youyou.nursing.mapper;

import java.util.List;
import com.youyou.nursing.domain.NcOperLog;

public interface NcOperLogMapper
{
    List<NcOperLog> selectList(NcOperLog query);

    int insert(NcOperLog row);
}
