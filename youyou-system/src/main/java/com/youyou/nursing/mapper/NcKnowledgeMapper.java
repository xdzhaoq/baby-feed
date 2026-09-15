package com.youyou.nursing.mapper;

import java.util.List;
import com.youyou.nursing.domain.NcKnowledge;

public interface NcKnowledgeMapper
{
    List<NcKnowledge> selectList(NcKnowledge query);

    NcKnowledge selectById(Long kbId);
}
