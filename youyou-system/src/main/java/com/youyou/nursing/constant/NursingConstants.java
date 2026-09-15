package com.youyou.nursing.constant;

/**
 * 护理工作台常量
 */
public class NursingConstants
{
    public static final String ROLE_ADMIN = "admin";

    public static final String ROLE_MOM = "mom";

    public static final String ROLE_FAMILY = "family";

    /** 家庭角色标签：妈妈 */
    public static final String TAG_MOM = "mom";

    public static final String STATUS_NORMAL = "0";

    public static final String STATUS_DISABLE = "1";

    public static final String DEL_NORMAL = "0";

    public static final String DEL_REMOVED = "2";

    /** 登录名：字母开头，字母数字下划线，2-20 位 */
    public static final String USERNAME_PATTERN = "^[a-zA-Z][a-zA-Z0-9_]{1,19}$";

    public static final int PASSWORD_MIN_LENGTH = 5;

    public static final int PASSWORD_MAX_LENGTH = 20;

    public static final String MODULE_FEEDING = "feeding";

    public static final String MODULE_SLEEP = "sleep";

    public static final String MODULE_DIAPER = "diaper";

    public static final String MODULE_CRY = "cry";

    public static final String MODULE_HEALTH = "health";

    public static final String MODULE_GROWTH = "growth";

    public static final String MODULE_CARE = "care";

    public static final String MODULE_MEDIA = "media";

    public static final String MODULE_HANDOVER = "handover";

    public static final String MODULE_MESSAGE = "message";

    public static final String MODULE_BABY = "baby";

    public static final String MODULE_MEMBER = "member";

    public static final String ACTION_CREATE = "create";

    public static final String ACTION_UPDATE = "update";

    public static final String ACTION_DELETE = "delete";

    public static final String MEDIA_IMAGE = "image";

    public static final String MEDIA_VIDEO = "video";

    /** 编辑锁默认 5 分钟 */
    public static final int LOCK_TTL_SECONDS = 300;

    /** 仪表盘参考下次喂养间隔（小时） */
    public static final int NEXT_FEED_HOURS = 3;
}
