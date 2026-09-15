package com.youyou.nursing.mapper;

import java.util.List;
import com.youyou.nursing.domain.NcHandover;

public interface NcHandoverMapper
{
    List<NcHandover> selectList(NcHandover query);

    NcHandover selectLatest(Long babyId);

    int insert(NcHandover row);
}
