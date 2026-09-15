package com.youyou.nursing.mapper;

import java.util.List;
import org.apache.ibatis.annotations.Param;
import com.youyou.nursing.domain.NcMessage;
import com.youyou.nursing.domain.NcMessageMention;

public interface NcMessageMapper
{
    List<NcMessage> selectList(NcMessage query);

    NcMessage selectById(Long messageId);

    int insert(NcMessage row);

    int insertMention(NcMessageMention mention);

    List<NcMessageMention> selectMentionsByMessageIds(@Param("messageIds") List<Long> messageIds);

    List<NcMessageMention> selectUnread(@Param("babyId") Long babyId, @Param("userId") Long userId);

    int markRead(@Param("mentionId") Long mentionId, @Param("userId") Long userId);

    int markAllRead(@Param("babyId") Long babyId, @Param("userId") Long userId);
}
