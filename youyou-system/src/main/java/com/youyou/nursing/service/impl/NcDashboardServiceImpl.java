package com.youyou.nursing.service.impl;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.youyou.common.constant.HttpStatus;
import com.youyou.common.exception.ServiceException;
import com.youyou.common.utils.StringUtils;
import com.youyou.nursing.constant.NursingConstants;
import com.youyou.nursing.domain.NcAdminBabyCard;
import com.youyou.nursing.domain.NcAdminOverview;
import com.youyou.nursing.domain.NcAlert;
import com.youyou.nursing.domain.NcBaby;
import com.youyou.nursing.domain.NcBabyMember;
import com.youyou.nursing.domain.NcCareItem;
import com.youyou.nursing.domain.NcGrowth;
import com.youyou.nursing.domain.NcHandover;
import com.youyou.nursing.domain.NcHealthCheck;
import com.youyou.nursing.domain.NcKnowledge;
import com.youyou.nursing.domain.NcMedia;
import com.youyou.nursing.domain.NcTodayOverview;
import com.youyou.nursing.domain.NcVaccineItem;
import com.youyou.nursing.mapper.NcBabyMapper;
import com.youyou.nursing.mapper.NcBabyMemberMapper;
import com.youyou.nursing.mapper.NcDashboardMapper;
import com.youyou.nursing.mapper.NcGrowthMapper;
import com.youyou.nursing.mapper.NcHandoverMapper;
import com.youyou.nursing.mapper.NcHealthCheckMapper;
import com.youyou.nursing.mapper.NcKnowledgeMapper;
import com.youyou.nursing.mapper.NcVaccineMapper;
import com.youyou.nursing.service.INcCareService;
import com.youyou.nursing.service.INcCollabService;
import com.youyou.nursing.service.INcDashboardService;
import com.youyou.nursing.service.INcMediaService;
import com.youyou.nursing.service.INursingAccessService;

@Service
public class NcDashboardServiceImpl implements INcDashboardService
{
    private static final BigDecimal FEVER = new BigDecimal("38.0");

    @Autowired
    private NcDashboardMapper dashboardMapper;

    @Autowired
    private NcKnowledgeMapper knowledgeMapper;

    @Autowired
    private NcBabyMapper babyMapper;

    @Autowired
    private NcBabyMemberMapper memberMapper;

    @Autowired
    private NcHealthCheckMapper healthMapper;

    @Autowired
    private NcVaccineMapper vaccineMapper;

    @Autowired
    private INcCareService careService;

    @Autowired
    private INcCollabService collabService;

    @Autowired
    private INcMediaService mediaService;

    @Autowired
    private NcGrowthMapper growthMapper;

    @Autowired
    private NcHandoverMapper handoverMapper;

    @Autowired
    private INursingAccessService accessService;

    @Autowired
    private NursingRecordHelper helper;

    @Override
    public NcTodayOverview selectToday(Long babyId)
    {
        helper.assertBaby(babyId);
        NcTodayOverview overview = dashboardMapper.selectTodayOverview(babyId);
        if (overview == null)
        {
            throw new ServiceException("宝宝不存在");
        }
        if (overview.getLastFeedTime() != null)
        {
            Calendar calendar = Calendar.getInstance();
            calendar.setTime(overview.getLastFeedTime());
            calendar.add(Calendar.HOUR_OF_DAY, NursingConstants.NEXT_FEED_HOURS);
            overview.setNextFeedTime(calendar.getTime());
        }
        NcBaby baby = babyMapper.selectBabyById(babyId);
        if (baby != null && baby.getBirthDate() != null)
        {
            long days = (startOfDay(new Date()).getTime() - startOfDay(baby.getBirthDate()).getTime()) / (24L * 3600 * 1000);
            overview.setAgeDays((int) Math.max(days, 0));
        }
        List<NcCareItem> todayCare = careService.selectToday(babyId, new Date());
        overview.setCareTodos(todayCare.stream().filter(item -> !"1".equals(item.getCompleted())).collect(Collectors.toList()));
        NcBabyMember query = new NcBabyMember();
        query.setBabyId(babyId);
        query.setStatus(NursingConstants.STATUS_NORMAL);
        List<String> online = memberMapper.selectMemberList(query).stream()
                .filter(m -> "1".equals(m.getOnlineFlag()))
                .map(NcBabyMember::getDisplayName)
                .collect(Collectors.toList());
        overview.setOnlineNames(online);

        NcHandover latestHandover = handoverMapper.selectLatest(babyId);
        if (latestHandover != null && latestHandover.getToUserName() != null)
        {
            overview.setCurrentCaretaker(latestHandover.getToUserName());
            overview.setNextFeedOperator(latestHandover.getToUserName());
        }
        else
        {
            if (!online.isEmpty())
            {
                overview.setCurrentCaretaker(online.get(0));
            }
            overview.setNextFeedOperator(overview.getLastFeedOperator());
        }

        List<NcVaccineItem> vaccines = vaccineMapper.selectBoard(babyId);
        Date today = startOfDay(new Date());
        int soon = 0;
        for (NcVaccineItem item : vaccines)
        {
            NcHealthServiceImpl.fillVaccineStatus(item, today);
            if ("soon".equals(item.getStatus()) || "overdue".equals(item.getStatus()))
            {
                soon++;
            }
        }
        overview.setVaccineSoonCount(soon);
        overview.setAlerts(buildAlerts(babyId, overview, vaccines));
        overview.setUnreadMentions(collabService.selectUnreadMentions(babyId));
        try
        {
            overview.setRecentMedia(mediaService.selectRecent(babyId, 6));
        }
        catch (Exception e)
        {
            overview.setRecentMedia(new ArrayList<NcMedia>());
        }
        NcGrowth growthQuery = new NcGrowth();
        growthQuery.setBabyId(babyId);
        List<NcGrowth> growths = growthMapper.selectList(growthQuery);
        if (growths != null && growths.size() > 8)
        {
            growths = new ArrayList<NcGrowth>(growths.subList(0, 8));
        }
        if (growths != null)
        {
            Collections.reverse(growths);
        }
        overview.setGrowthPoints(growths);
        return overview;
    }

    @Override
    public NcAdminOverview selectAdminOverview()
    {
        if (!accessService.isAdmin())
        {
            throw new ServiceException("仅超管可查看家庭总览", HttpStatus.FORBIDDEN);
        }
        List<NcAdminBabyCard> cards = dashboardMapper.selectAdminBabyCards();
        Date today = startOfDay(new Date());
        int incomplete = 0;
        int alertBabies = 0;
        for (NcAdminBabyCard card : cards)
        {
            if (card.getBirthDate() != null)
            {
                long days = (today.getTime() - startOfDay(card.getBirthDate()).getTime()) / (24L * 3600 * 1000);
                card.setAgeDays((int) Math.max(days, 0));
            }
            int familyMembers = card.getFamilyMemberCount() == null ? 0 : card.getFamilyMemberCount();
            boolean thinFamily = familyMembers <= 0;
            card.setIncomplete(thinFamily);
            if (thinFamily)
            {
                incomplete++;
            }
            NcTodayOverview mini = new NcTodayOverview();
            mini.setFeedCount(card.getFeedCount());
            mini.setPeeCount(card.getPeeCount());
            List<NcVaccineItem> vaccines = vaccineMapper.selectBoard(card.getBabyId());
            for (NcVaccineItem item : vaccines)
            {
                NcHealthServiceImpl.fillVaccineStatus(item, today);
            }
            List<NcAlert> alerts = buildAlerts(card.getBabyId(), mini, vaccines);
            card.setAlerts(alerts);
            if (alerts == null || alerts.isEmpty())
            {
                card.setAlertLevel("none");
            }
            else
            {
                boolean red = alerts.stream().anyMatch(a -> "red".equals(a.getLevel()));
                card.setAlertLevel(red ? "red" : "yellow");
                card.setAlertTitle(alerts.get(0).getTitle());
                alertBabies++;
            }
        }
        NcAdminOverview overview = new NcAdminOverview();
        overview.setBabies(cards);
        overview.setBabyCount(cards.size());
        overview.setFamilyCount((int) cards.stream().map(NcAdminBabyCard::getMomUserName).filter(StringUtils::isNotEmpty).distinct().count());
        overview.setIncompleteCount(incomplete);
        overview.setAlertBabyCount(alertBabies);
        overview.setOnlinePeopleCount(cards.stream().mapToInt(c -> c.getOnlineCount() == null ? 0 : c.getOnlineCount()).sum());
        overview.setSilentBabyCount((int) cards.stream().filter(c -> c.getFeedCount() == null || c.getFeedCount() == 0).count());
        return overview;
    }

    @Override
    public List<NcKnowledge> selectKnowledge(String category, String keyword)
    {
        NcKnowledge query = new NcKnowledge();
        query.setCategory(category);
        query.setSearchValue(keyword);
        return knowledgeMapper.selectList(query);
    }

    @Override
    public NcKnowledge selectKnowledgeById(Long kbId)
    {
        NcKnowledge kb = knowledgeMapper.selectById(kbId);
        if (kb == null)
        {
            throw new ServiceException("知识条目不存在");
        }
        return kb;
    }

    private List<NcAlert> buildAlerts(Long babyId, NcTodayOverview overview, List<NcVaccineItem> vaccines)
    {
        List<NcAlert> alerts = new ArrayList<NcAlert>();
        NcHealthCheck health = healthMapper.selectByBabyDate(babyId, new java.sql.Date(System.currentTimeMillis()));
        if (health != null)
        {
            if (isFever(health.getTempAm()) || isFever(health.getTempPm()))
            {
                alerts.add(new NcAlert("red", "体温偏高", "3 月龄内腋温达到或超过 38℃，尽快联系儿科，不要自行用药。", "发烧,发热,体温"));
            }
            if ("palms".equals(health.getJaundice()))
            {
                alerts.add(new NcAlert("red", "黄疸可能加重", "黄染到了手心脚心，尽快就医复查。", "黄疸,黄染,手心脚心"));
            }
            else if ("limbs".equals(health.getJaundice()) || "trunk".equals(health.getJaundice()))
            {
                alerts.add(new NcAlert("yellow", "黄疸需关注", "黄染已超过面部，建议对照应急指引并安排复查。", "黄疸,黄染"));
            }
            if ("ooze".equals(health.getUmbilical()) || "red".equals(health.getUmbilical()))
            {
                alerts.add(new NcAlert("red", "脐带有感染迹象", "红肿或渗液不要自行涂粉，尽快就诊。", "脐带,渗液,红肿,感染"));
            }
            else if ("moist".equals(health.getUmbilical()))
            {
                alerts.add(new NcAlert("yellow", "脐带潮湿", "保持干燥清洁，观察有没有红肿或气味。", "脐带"));
            }
            if ("lethargic".equals(health.getSpirit()))
            {
                alerts.add(new NcAlert("red", "精神反应差", "反应明显变弱时尽快就医。", "嗜睡,精神"));
            }
            else if ("sleepy".equals(health.getSpirit()) || "irritable".equals(health.getSpirit()))
            {
                alerts.add(new NcAlert("yellow", "精神需要留意", "对照吃奶和体温，必要时咨询儿科。", "嗜睡"));
            }
        }
        int hour = Calendar.getInstance().get(Calendar.HOUR_OF_DAY);
        int feeds = overview.getFeedCount() == null ? 0 : overview.getFeedCount();
        if (feeds == 0 && hour >= 12)
        {
            alerts.add(new NcAlert("yellow", "今天还没有喂养记录", "如果已经喂过，补记一条；如果确实没喂，尽快核对。", "奶量少,喂养"));
        }
        else if (feeds > 0 && feeds < 6 && hour >= 20)
        {
            alerts.add(new NcAlert("yellow", "今天奶次偏少，可留意", "对照尿量和精神，必要时联系儿科。", "奶量少,脱水,尿少"));
        }
        int pees = overview.getPeeCount() == null ? 0 : overview.getPeeCount();
        if (hour >= 18 && pees < 6)
        {
            String level = pees <= 3 ? "red" : "yellow";
            alerts.add(new NcAlert(level, "今天尿湿次数偏少", "24 小时少于约 6 次湿尿布时需要关注，结合吃奶和精神判断。", "尿少,脱水,奶量少"));
        }
        for (NcVaccineItem item : vaccines)
        {
            if ("overdue".equals(item.getStatus()))
            {
                alerts.add(new NcAlert("yellow", item.getVaccineName() + " 已过建议日期", "时间表仅供参考，以当地接种单位安排为准。", "疫苗"));
            }
            else if ("soon".equals(item.getStatus()))
            {
                alerts.add(new NcAlert("yellow", item.getVaccineName() + " 即将到期", "到期前可提前联系接种单位确认。", "疫苗"));
            }
        }
        List<NcKnowledge> kbs = knowledgeMapper.selectList(new NcKnowledge());
        for (NcAlert alert : alerts)
        {
            bindKb(alert, kbs);
        }
        return alerts;
    }

    private boolean isFever(BigDecimal temp)
    {
        return temp != null && temp.compareTo(FEVER) >= 0;
    }

    private void bindKb(NcAlert alert, List<NcKnowledge> kbs)
    {
        if (StringUtils.isEmpty(alert.getKeywords()))
        {
            return;
        }
        String[] keys = alert.getKeywords().split(",");
        for (NcKnowledge kb : kbs)
        {
            String hay = (kb.getKeywords() == null ? "" : kb.getKeywords()) + "," + (kb.getTitle() == null ? "" : kb.getTitle());
            for (String key : keys)
            {
                if (StringUtils.isNotEmpty(key) && hay.contains(key.trim()))
                {
                    alert.setKbId(kb.getKbId());
                    return;
                }
            }
        }
    }

    private Date startOfDay(Date date)
    {
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(date);
        calendar.set(Calendar.HOUR_OF_DAY, 0);
        calendar.set(Calendar.MINUTE, 0);
        calendar.set(Calendar.SECOND, 0);
        calendar.set(Calendar.MILLISECOND, 0);
        return calendar.getTime();
    }
}
