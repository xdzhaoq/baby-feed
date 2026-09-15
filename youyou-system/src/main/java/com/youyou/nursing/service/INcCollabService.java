package com.youyou.nursing.service;

import java.util.List;
import com.youyou.nursing.domain.NcHandover;
import com.youyou.nursing.domain.NcMessage;
import com.youyou.nursing.domain.NcMessageMention;
import com.youyou.nursing.domain.NcOperLog;

public interface INcCollabService
{
    List<NcHandover> selectHandoverList(NcHandover query);

    int insertHandover(NcHandover row);

    List<NcMessage> selectMessageList(NcMessage query);

    int insertMessage(NcMessage row);

    List<NcMessageMention> selectUnreadMentions(Long babyId);

    int markMentionRead(Long mentionId);

    int markAllMentionsRead(Long babyId);

    List<NcOperLog> selectOperLogList(NcOperLog query);

    int insertOperLog(Long babyId, String moduleCode, String actionCode, String summary);
}
