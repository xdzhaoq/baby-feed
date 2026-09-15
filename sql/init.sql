-- =============================================================================
-- 新生儿护理工作台 · 安装脚本（唯一完整脚本）
-- 版本：2026-09-15
-- 适用：PostgreSQL 12+
-- 内含：新生儿护理工作台系统表 + 代码生成视图 + 护理业务表/种子
--       （含 RustFS 参数、护理清单隐藏表、不含「新生儿护理工作台官网」菜单）
--
-- 用法：
--   1. 在 postgres 默认库建库（库已存在可跳过）：
--        CREATE DATABASE "youyou" WITH OWNER = postgres ENCODING = 'UTF8' TEMPLATE = template0;
--   2. 连接到 youyou，执行本文件全文。
--      psql -U postgres -d youyou -f "baby-feed/sql/init.sql"
--
-- 注意：会清空并重建新生儿护理工作台表与 nc_* 表，只用于空库或允许整库重装的环境。
--       不预置任何宝宝。默认超管 admin / admin123。认证仍用新生儿护理工作台 JWT。
-- =============================================================================
-- #############################################################################
-- 第一部分 · 新生儿护理工作台底座（系统表、默认 admin、Quartz、find_in_set）
-- #############################################################################

/*
 Navicat Premium Dump SQL

 Source Server         : localhost_5432
 Source Server Type    : PostgreSQL
 Source Server Version : 120011 (120011)
 Source Host           : localhost:5432
 Source Catalog        : youyou
 Source Schema         : public

 Target Server Type    : PostgreSQL
 Target Server Version : 120011 (120011)
 File Encoding         : 65001

 Date: 08/07/2024 16:11:48
*/



-- ----------------------------
-- Table structure for gen_table
-- ----------------------------
DROP TABLE IF EXISTS "public"."gen_table";
CREATE TABLE "public"."gen_table" (
                                      "table_id" bigserial,
                                      "table_name" varchar(200) COLLATE "pg_catalog"."default",
                                      "table_comment" varchar(500) COLLATE "pg_catalog"."default",
                                      "sub_table_name" varchar(64) COLLATE "pg_catalog"."default",
                                      "sub_table_fk_name" varchar(64) COLLATE "pg_catalog"."default",
                                      "class_name" varchar(100) COLLATE "pg_catalog"."default",
                                      "tpl_category" varchar(200) COLLATE "pg_catalog"."default",
                                      "tpl_web_type" varchar(30)  COLLATE "pg_catalog"."default",
                                      "package_name" varchar(100) COLLATE "pg_catalog"."default",
                                      "module_name" varchar(30) COLLATE "pg_catalog"."default",
                                      "business_name" varchar(30) COLLATE "pg_catalog"."default",
                                      "function_name" varchar(50) COLLATE "pg_catalog"."default",
                                      "function_author" varchar(50) COLLATE "pg_catalog"."default",
                                      "gen_type" char(1) COLLATE "pg_catalog"."default",
                                      "gen_path" varchar(200) COLLATE "pg_catalog"."default",
                                      "options" varchar(1000) COLLATE "pg_catalog"."default",
                                      "create_by" varchar(64) COLLATE "pg_catalog"."default",
                                      "create_time" timestamp(6),
                                      "update_by" varchar(64) COLLATE "pg_catalog"."default",
                                      "update_time" timestamp(6),
                                      "remark" varchar(500) COLLATE "pg_catalog"."default"
)
;
COMMENT ON COLUMN "public"."gen_table"."table_id" IS '编号';
COMMENT ON COLUMN "public"."gen_table"."table_name" IS '表名称';
COMMENT ON COLUMN "public"."gen_table"."table_comment" IS '表描述';
COMMENT ON COLUMN "public"."gen_table"."sub_table_name" IS '关联子表的表名';
COMMENT ON COLUMN "public"."gen_table"."sub_table_fk_name" IS '子表关联的外键名';
COMMENT ON COLUMN "public"."gen_table"."class_name" IS '实体类名称';
COMMENT ON COLUMN "public"."gen_table"."tpl_category" IS '使用的模板（crud单表操作 tree树表操作）';
COMMENT ON COLUMN "public"."gen_table"."tpl_web_type" IS '前端模板类型（element-ui模版 element-plus模版）';
COMMENT ON COLUMN "public"."gen_table"."package_name" IS '生成包路径';
COMMENT ON COLUMN "public"."gen_table"."module_name" IS '生成模块名';
COMMENT ON COLUMN "public"."gen_table"."business_name" IS '生成业务名';
COMMENT ON COLUMN "public"."gen_table"."function_name" IS '生成功能名';
COMMENT ON COLUMN "public"."gen_table"."function_author" IS '生成功能作者';
COMMENT ON COLUMN "public"."gen_table"."gen_type" IS '生成代码方式（0zip压缩包 1自定义路径）';
COMMENT ON COLUMN "public"."gen_table"."gen_path" IS '生成路径（不填默认项目路径）';
COMMENT ON COLUMN "public"."gen_table"."options" IS '其它生成选项';
COMMENT ON COLUMN "public"."gen_table"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."gen_table"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."gen_table"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."gen_table"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."gen_table"."remark" IS '备注';
COMMENT ON TABLE "public"."gen_table" IS '代码生成业务表';

-- ----------------------------
-- Records of gen_table
-- ----------------------------

-- ----------------------------
-- Table structure for gen_table_column
-- ----------------------------
DROP TABLE IF EXISTS "public"."gen_table_column";
CREATE TABLE "public"."gen_table_column" (
                                             "column_id" bigserial,
                                             "table_id" varchar(64) COLLATE "pg_catalog"."default",
                                             "column_name" varchar(200) COLLATE "pg_catalog"."default",
                                             "column_comment" varchar(500) COLLATE "pg_catalog"."default",
                                             "column_type" varchar(100) COLLATE "pg_catalog"."default",
                                             "java_type" varchar(500) COLLATE "pg_catalog"."default",
                                             "java_field" varchar(200) COLLATE "pg_catalog"."default",
                                             "is_pk" char(1) COLLATE "pg_catalog"."default",
                                             "is_increment" char(1) COLLATE "pg_catalog"."default",
                                             "is_required" char(1) COLLATE "pg_catalog"."default",
                                             "is_insert" char(1) COLLATE "pg_catalog"."default",
                                             "is_edit" char(1) COLLATE "pg_catalog"."default",
                                             "is_list" char(1) COLLATE "pg_catalog"."default",
                                             "is_query" char(1) COLLATE "pg_catalog"."default",
                                             "query_type" varchar(200) COLLATE "pg_catalog"."default",
                                             "html_type" varchar(200) COLLATE "pg_catalog"."default",
                                             "dict_type" varchar(200) default '',
                                             "sort" int4,
                                             "create_by" varchar(64) COLLATE "pg_catalog"."default",
                                             "create_time" timestamp(6),
                                             "update_by" varchar(64) COLLATE "pg_catalog"."default",
                                             "update_time" timestamp(6)
)
;
COMMENT ON COLUMN "public"."gen_table_column"."column_id" IS '编号';
COMMENT ON COLUMN "public"."gen_table_column"."table_id" IS '归属表编号';
COMMENT ON COLUMN "public"."gen_table_column"."column_name" IS '列名称';
COMMENT ON COLUMN "public"."gen_table_column"."column_comment" IS '列描述';
COMMENT ON COLUMN "public"."gen_table_column"."column_type" IS '列类型';
COMMENT ON COLUMN "public"."gen_table_column"."java_type" IS 'JAVA类型';
COMMENT ON COLUMN "public"."gen_table_column"."java_field" IS 'JAVA字段名';
COMMENT ON COLUMN "public"."gen_table_column"."is_pk" IS '是否主键（1是）';
COMMENT ON COLUMN "public"."gen_table_column"."is_increment" IS '是否自增（1是）';
COMMENT ON COLUMN "public"."gen_table_column"."is_required" IS '是否必填（1是）';
COMMENT ON COLUMN "public"."gen_table_column"."is_insert" IS '是否为插入字段（1是）';
COMMENT ON COLUMN "public"."gen_table_column"."is_edit" IS '是否编辑字段（1是）';
COMMENT ON COLUMN "public"."gen_table_column"."is_list" IS '是否列表字段（1是）';
COMMENT ON COLUMN "public"."gen_table_column"."is_query" IS '是否查询字段（1是）';
COMMENT ON COLUMN "public"."gen_table_column"."query_type" IS '查询方式（等于、不等于、大于、小于、范围）';
COMMENT ON COLUMN "public"."gen_table_column"."html_type" IS '显示类型（文本框、文本域、下拉框、复选框、单选框、日期控件）';
COMMENT ON COLUMN "public"."gen_table_column"."dict_type" IS '字典类型';
COMMENT ON COLUMN "public"."gen_table_column"."sort" IS '排序';
COMMENT ON COLUMN "public"."gen_table_column"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."gen_table_column"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."gen_table_column"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."gen_table_column"."update_time" IS '更新时间';
COMMENT ON TABLE "public"."gen_table_column" IS '代码生成业务表字段';

-- ----------------------------
-- Records of gen_table_column
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_blob_triggers
-- ----------------------------
DROP TABLE IF EXISTS "public"."qrtz_blob_triggers";
CREATE TABLE "public"."qrtz_blob_triggers" (
                                               "sched_name" varchar(120) COLLATE "pg_catalog"."default" NOT NULL,
                                               "trigger_name" varchar(200) COLLATE "pg_catalog"."default" NOT NULL,
                                               "trigger_group" varchar(200) COLLATE "pg_catalog"."default" NOT NULL,
                                               "blob_data" bytea
)
;

-- ----------------------------
-- Records of qrtz_blob_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_calendars
-- ----------------------------
DROP TABLE IF EXISTS "public"."qrtz_calendars";
CREATE TABLE "public"."qrtz_calendars" (
                                           "sched_name" varchar(120) COLLATE "pg_catalog"."default" NOT NULL,
                                           "calendar_name" varchar(200) COLLATE "pg_catalog"."default" NOT NULL,
                                           "calendar" bytea NOT NULL
)
;

-- ----------------------------
-- Records of qrtz_calendars
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_cron_triggers
-- ----------------------------
DROP TABLE IF EXISTS "public"."qrtz_cron_triggers";
CREATE TABLE "public"."qrtz_cron_triggers" (
                                               "sched_name" varchar(120) COLLATE "pg_catalog"."default" NOT NULL,
                                               "trigger_name" varchar(200) COLLATE "pg_catalog"."default" NOT NULL,
                                               "trigger_group" varchar(200) COLLATE "pg_catalog"."default" NOT NULL,
                                               "cron_expression" varchar(200) COLLATE "pg_catalog"."default" NOT NULL,
                                               "time_zone_id" varchar(80) COLLATE "pg_catalog"."default"
)
;

-- ----------------------------
-- Records of qrtz_cron_triggers
-- ----------------------------
INSERT INTO "public"."qrtz_cron_triggers" VALUES ('youyouScheduler', 'TASK_CLASS_NAME1', 'DEFAULT', '0/10 * * * * ?', 'Asia/Shanghai');
INSERT INTO "public"."qrtz_cron_triggers" VALUES ('youyouScheduler', 'TASK_CLASS_NAME2', 'DEFAULT', '0/15 * * * * ?', 'Asia/Shanghai');
INSERT INTO "public"."qrtz_cron_triggers" VALUES ('youyouScheduler', 'TASK_CLASS_NAME3', 'DEFAULT', '0/20 * * * * ?', 'Asia/Shanghai');

-- ----------------------------
-- Table structure for qrtz_fired_triggers
-- ----------------------------
DROP TABLE IF EXISTS "public"."qrtz_fired_triggers";
CREATE TABLE "public"."qrtz_fired_triggers" (
                                                "sched_name" varchar(120) COLLATE "pg_catalog"."default" NOT NULL,
                                                "entry_id" varchar(95) COLLATE "pg_catalog"."default" NOT NULL,
                                                "trigger_name" varchar(200) COLLATE "pg_catalog"."default" NOT NULL,
                                                "trigger_group" varchar(200) COLLATE "pg_catalog"."default" NOT NULL,
                                                "instance_name" varchar(200) COLLATE "pg_catalog"."default" NOT NULL,
                                                "fired_time" int8 NOT NULL,
                                                "sched_time" int8 NOT NULL,
                                                "priority" int4 NOT NULL,
                                                "state" varchar(16) COLLATE "pg_catalog"."default" NOT NULL,
                                                "job_name" varchar(200) COLLATE "pg_catalog"."default",
                                                "job_group" varchar(200) COLLATE "pg_catalog"."default",
                                                "is_nonconcurrent" varchar(20) COLLATE "pg_catalog"."default",
                                                "requests_recovery" varchar(20) COLLATE "pg_catalog"."default"
)
;

-- ----------------------------
-- Records of qrtz_fired_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_job_details
-- ----------------------------
DROP TABLE IF EXISTS "public"."qrtz_job_details" cascade;
CREATE TABLE "public"."qrtz_job_details" (
                                             "sched_name" varchar(120) COLLATE "pg_catalog"."default" NOT NULL,
                                             "job_name" varchar(200) COLLATE "pg_catalog"."default" NOT NULL,
                                             "job_group" varchar(200) COLLATE "pg_catalog"."default" NOT NULL,
                                             "description" varchar(250) COLLATE "pg_catalog"."default",
                                             "job_class_name" varchar(250) COLLATE "pg_catalog"."default" NOT NULL,
                                             "is_durable" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
                                             "is_nonconcurrent" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
                                             "is_update_data" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
                                             "requests_recovery" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
                                             "job_data" bytea
)
;

-- ----------------------------
-- Records of qrtz_job_details
-- ----------------------------
INSERT INTO "public"."qrtz_job_details" VALUES ('youyouScheduler', 'TASK_CLASS_NAME1', 'DEFAULT', NULL, 'com.youyou.quartz.util.QuartzDisallowConcurrentExecution', 'false', 'true', 'false', 'false', E'\\254\\355\\000\\005sr\\000\\025org.quartz.JobDataMap\\237\\260\\203\\350\\277\\251\\260\\313\\002\\000\\000xr\\000&org.quartz.utils.StringKeyDirtyFlagMap\\202\\010\\350\\303\\373\\305](\\002\\000\\001Z\\000\\023allowsTransientDataxr\\000\\035org.quartz.utils.DirtyFlagMap\\023\\346.\\255(v\\012\\316\\002\\000\\002Z\\000\\005dirtyL\\000\\003mapt\\000\\017Ljava/util/Map;xp\\001sr\\000\\021java.util.HashMap\\005\\007\\332\\301\\303\\026`\\321\\003\\000\\002F\\000\\012loadFactorI\\000\\011thresholdxp?@\\000\\000\\000\\000\\000\\014w\\010\\000\\000\\000\\020\\000\\000\\000\\001t\\000\\017TASK_PROPERTIESsr\\000\\036com.youyou.quartz.domain.SysJob\\000\\000\\000\\000\\000\\000\\000\\001\\002\\000\\010L\\000\\012concurrentt\\000\\022Ljava/lang/String;L\\000\\016cronExpressionq\\000~\\000\\011L\\000\\014invokeTargetq\\000~\\000\\011L\\000\\010jobGroupq\\000~\\000\\011L\\000\\005jobIdt\\000\\020Ljava/lang/Long;L\\000\\007jobNameq\\000~\\000\\011L\\000\\015misfirePolicyq\\000~\\000\\011L\\000\\006statusq\\000~\\000\\011xr\\000''com.youyou.common.core.domain.BaseEntity\\000\\000\\000\\000\\000\\000\\000\\001\\002\\000\\007L\\000\\010createByq\\000~\\000\\011L\\000\\012createTimet\\000\\020Ljava/util/Date;L\\000\\006paramsq\\000~\\000\\003L\\000\\006remarkq\\000~\\000\\011L\\000\\013searchValueq\\000~\\000\\011L\\000\\010updateByq\\000~\\000\\011L\\000\\012updateTimeq\\000~\\000\\014xpt\\000\\005adminsr\\000\\016java.util.Datehj\\201\\001KYt\\031\\003\\000\\000xpw\\010\\000\\000\\001y\\250Q\\233\\030xpt\\000\\000pppt\\000\\0011t\\000\\0160/10 * * * * ?t\\000\\021ryTask.ryNoParamst\\000\\007DEFAULTsr\\000\\016java.lang.Long;\\213\\344\\220\\314\\217#\\337\\002\\000\\001J\\000\\005valuexr\\000\\020java.lang.Number\\206\\254\\225\\035\\013\\224\\340\\213\\002\\000\\000xp\\000\\000\\000\\000\\000\\000\\000\\001t\\000\\030\\347\\263\\273\\347\\273\\237\\351\\273\\230\\350\\256\\244\\357\\274\\210\\346\\227\\240\\345\\217\\202\\357\\274\\211t\\000\\0013t\\000\\0011x\\000');
INSERT INTO "public"."qrtz_job_details" VALUES ('youyouScheduler', 'TASK_CLASS_NAME2', 'DEFAULT', NULL, 'com.youyou.quartz.util.QuartzDisallowConcurrentExecution', 'false', 'true', 'false', 'false', E'\\254\\355\\000\\005sr\\000\\025org.quartz.JobDataMap\\237\\260\\203\\350\\277\\251\\260\\313\\002\\000\\000xr\\000&org.quartz.utils.StringKeyDirtyFlagMap\\202\\010\\350\\303\\373\\305](\\002\\000\\001Z\\000\\023allowsTransientDataxr\\000\\035org.quartz.utils.DirtyFlagMap\\023\\346.\\255(v\\012\\316\\002\\000\\002Z\\000\\005dirtyL\\000\\003mapt\\000\\017Ljava/util/Map;xp\\001sr\\000\\021java.util.HashMap\\005\\007\\332\\301\\303\\026`\\321\\003\\000\\002F\\000\\012loadFactorI\\000\\011thresholdxp?@\\000\\000\\000\\000\\000\\014w\\010\\000\\000\\000\\020\\000\\000\\000\\001t\\000\\017TASK_PROPERTIESsr\\000\\036com.youyou.quartz.domain.SysJob\\000\\000\\000\\000\\000\\000\\000\\001\\002\\000\\010L\\000\\012concurrentt\\000\\022Ljava/lang/String;L\\000\\016cronExpressionq\\000~\\000\\011L\\000\\014invokeTargetq\\000~\\000\\011L\\000\\010jobGroupq\\000~\\000\\011L\\000\\005jobIdt\\000\\020Ljava/lang/Long;L\\000\\007jobNameq\\000~\\000\\011L\\000\\015misfirePolicyq\\000~\\000\\011L\\000\\006statusq\\000~\\000\\011xr\\000''com.youyou.common.core.domain.BaseEntity\\000\\000\\000\\000\\000\\000\\000\\001\\002\\000\\007L\\000\\010createByq\\000~\\000\\011L\\000\\012createTimet\\000\\020Ljava/util/Date;L\\000\\006paramsq\\000~\\000\\003L\\000\\006remarkq\\000~\\000\\011L\\000\\013searchValueq\\000~\\000\\011L\\000\\010updateByq\\000~\\000\\011L\\000\\012updateTimeq\\000~\\000\\014xpt\\000\\005adminsr\\000\\016java.util.Datehj\\201\\001KYt\\031\\003\\000\\000xpw\\010\\000\\000\\001y\\250Q\\233\\030xpt\\000\\000pppt\\000\\0011t\\000\\0160/15 * * * * ?t\\000\\025ryTask.ryParams(''ry'')t\\000\\007DEFAULTsr\\000\\016java.lang.Long;\\213\\344\\220\\314\\217#\\337\\002\\000\\001J\\000\\005valuexr\\000\\020java.lang.Number\\206\\254\\225\\035\\013\\224\\340\\213\\002\\000\\000xp\\000\\000\\000\\000\\000\\000\\000\\002t\\000\\030\\347\\263\\273\\347\\273\\237\\351\\273\\230\\350\\256\\244\\357\\274\\210\\346\\234\\211\\345\\217\\202\\357\\274\\211t\\000\\0013t\\000\\0011x\\000');
INSERT INTO "public"."qrtz_job_details" VALUES ('youyouScheduler', 'TASK_CLASS_NAME3', 'DEFAULT', NULL, 'com.youyou.quartz.util.QuartzDisallowConcurrentExecution', 'false', 'true', 'false', 'false', E'\\254\\355\\000\\005sr\\000\\025org.quartz.JobDataMap\\237\\260\\203\\350\\277\\251\\260\\313\\002\\000\\000xr\\000&org.quartz.utils.StringKeyDirtyFlagMap\\202\\010\\350\\303\\373\\305](\\002\\000\\001Z\\000\\023allowsTransientDataxr\\000\\035org.quartz.utils.DirtyFlagMap\\023\\346.\\255(v\\012\\316\\002\\000\\002Z\\000\\005dirtyL\\000\\003mapt\\000\\017Ljava/util/Map;xp\\001sr\\000\\021java.util.HashMap\\005\\007\\332\\301\\303\\026`\\321\\003\\000\\002F\\000\\012loadFactorI\\000\\011thresholdxp?@\\000\\000\\000\\000\\000\\014w\\010\\000\\000\\000\\020\\000\\000\\000\\001t\\000\\017TASK_PROPERTIESsr\\000\\036com.youyou.quartz.domain.SysJob\\000\\000\\000\\000\\000\\000\\000\\001\\002\\000\\010L\\000\\012concurrentt\\000\\022Ljava/lang/String;L\\000\\016cronExpressionq\\000~\\000\\011L\\000\\014invokeTargetq\\000~\\000\\011L\\000\\010jobGroupq\\000~\\000\\011L\\000\\005jobIdt\\000\\020Ljava/lang/Long;L\\000\\007jobNameq\\000~\\000\\011L\\000\\015misfirePolicyq\\000~\\000\\011L\\000\\006statusq\\000~\\000\\011xr\\000''com.youyou.common.core.domain.BaseEntity\\000\\000\\000\\000\\000\\000\\000\\001\\002\\000\\007L\\000\\010createByq\\000~\\000\\011L\\000\\012createTimet\\000\\020Ljava/util/Date;L\\000\\006paramsq\\000~\\000\\003L\\000\\006remarkq\\000~\\000\\011L\\000\\013searchValueq\\000~\\000\\011L\\000\\010updateByq\\000~\\000\\011L\\000\\012updateTimeq\\000~\\000\\014xpt\\000\\005adminsr\\000\\016java.util.Datehj\\201\\001KYt\\031\\003\\000\\000xpw\\010\\000\\000\\001y\\250Q\\233\\030xpt\\000\\000pppt\\000\\0011t\\000\\0160/20 * * * * ?t\\0008ryTask.ryMultipleParams(''ry'', true, 2000L, 316.50D, 100)t\\000\\007DEFAULTsr\\000\\016java.lang.Long;\\213\\344\\220\\314\\217#\\337\\002\\000\\001J\\000\\005valuexr\\000\\020java.lang.Number\\206\\254\\225\\035\\013\\224\\340\\213\\002\\000\\000xp\\000\\000\\000\\000\\000\\000\\000\\003t\\000\\030\\347\\263\\273\\347\\273\\237\\351\\273\\230\\350\\256\\244\\357\\274\\210\\345\\244\\232\\345\\217\\202\\357\\274\\211t\\000\\0013t\\000\\0011x\\000');

-- ----------------------------
-- Table structure for qrtz_locks
-- ----------------------------
DROP TABLE IF EXISTS "public"."qrtz_locks";
CREATE TABLE "public"."qrtz_locks" (
                                       "sched_name" varchar(120) COLLATE "pg_catalog"."default" NOT NULL,
                                       "lock_name" varchar(40) COLLATE "pg_catalog"."default" NOT NULL
)
;

-- ----------------------------
-- Records of qrtz_locks
-- ----------------------------
INSERT INTO "public"."qrtz_locks" VALUES ('youyouScheduler', 'TRIGGER_ACCESS');
INSERT INTO "public"."qrtz_locks" VALUES ('youyouScheduler', 'STATE_ACCESS');

-- ----------------------------
-- Table structure for qrtz_paused_trigger_grps
-- ----------------------------
DROP TABLE IF EXISTS "public"."qrtz_paused_trigger_grps";
CREATE TABLE "public"."qrtz_paused_trigger_grps" (
                                                     "sched_name" varchar(120) COLLATE "pg_catalog"."default" NOT NULL,
                                                     "trigger_group" varchar(200) COLLATE "pg_catalog"."default" NOT NULL
)
;

-- ----------------------------
-- Records of qrtz_paused_trigger_grps
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_scheduler_state
-- ----------------------------
DROP TABLE IF EXISTS "public"."qrtz_scheduler_state";
CREATE TABLE "public"."qrtz_scheduler_state" (
                                                 "sched_name" varchar(120) COLLATE "pg_catalog"."default" NOT NULL,
                                                 "instance_name" varchar(200) COLLATE "pg_catalog"."default" NOT NULL,
                                                 "last_checkin_time" int8 NOT NULL,
                                                 "checkin_interval" int8 NOT NULL
)
;

-- ----------------------------
-- Records of qrtz_scheduler_state
-- ----------------------------
INSERT INTO "public"."qrtz_scheduler_state" VALUES ('youyouScheduler', 'LAPTOP-3MPMV2DO1622082068199', 1622082356557, 15000);

-- ----------------------------
-- Table structure for qrtz_simple_triggers
-- ----------------------------
DROP TABLE IF EXISTS "public"."qrtz_simple_triggers";
CREATE TABLE "public"."qrtz_simple_triggers" (
                                                 "sched_name" varchar(120) COLLATE "pg_catalog"."default" NOT NULL,
                                                 "trigger_name" varchar(200) COLLATE "pg_catalog"."default" NOT NULL,
                                                 "trigger_group" varchar(200) COLLATE "pg_catalog"."default" NOT NULL,
                                                 "repeat_count" int8 NOT NULL,
                                                 "repeat_interval" int8 NOT NULL,
                                                 "times_triggered" int8 NOT NULL
)
;

-- ----------------------------
-- Records of qrtz_simple_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_simprop_triggers
-- ----------------------------
DROP TABLE IF EXISTS "public"."qrtz_simprop_triggers";
CREATE TABLE "public"."qrtz_simprop_triggers" (
                                                  "sched_name" varchar(120) COLLATE "pg_catalog"."default" NOT NULL,
                                                  "trigger_name" varchar(200) COLLATE "pg_catalog"."default" NOT NULL,
                                                  "trigger_group" varchar(200) COLLATE "pg_catalog"."default" NOT NULL,
                                                  "str_prop_1" varchar(512) COLLATE "pg_catalog"."default",
                                                  "str_prop_2" varchar(512) COLLATE "pg_catalog"."default",
                                                  "str_prop_3" varchar(512) COLLATE "pg_catalog"."default",
                                                  "int_prop_1" int4,
                                                  "int_prop_2" int4,
                                                  "long_prop_1" int8,
                                                  "long_prop_2" int8,
                                                  "dec_prop_1" numeric(13,4),
                                                  "dec_prop_2" numeric(13,4),
                                                  "bool_prop_1" varchar(2) COLLATE "pg_catalog"."default",
                                                  "bool_prop_2" varchar(2) COLLATE "pg_catalog"."default"
)
;

-- ----------------------------
-- Records of qrtz_simprop_triggers
-- ----------------------------

-- ----------------------------
-- Table structure for qrtz_triggers
-- ----------------------------
DROP TABLE IF EXISTS "public"."qrtz_triggers";
CREATE TABLE "public"."qrtz_triggers" (
                                          "sched_name" varchar(120) COLLATE "pg_catalog"."default" NOT NULL,
                                          "trigger_name" varchar(200) COLLATE "pg_catalog"."default" NOT NULL,
                                          "trigger_group" varchar(200) COLLATE "pg_catalog"."default" NOT NULL,
                                          "job_name" varchar(200) COLLATE "pg_catalog"."default" NOT NULL,
                                          "job_group" varchar(200) COLLATE "pg_catalog"."default" NOT NULL,
                                          "description" varchar(250) COLLATE "pg_catalog"."default",
                                          "next_fire_time" int8,
                                          "prev_fire_time" int8,
                                          "priority" int4,
                                          "trigger_state" varchar(16) COLLATE "pg_catalog"."default" NOT NULL,
                                          "trigger_type" varchar(8) COLLATE "pg_catalog"."default" NOT NULL,
                                          "start_time" int8 NOT NULL,
                                          "end_time" int8,
                                          "calendar_name" varchar(200) COLLATE "pg_catalog"."default",
                                          "misfire_instr" int2,
                                          "job_data" bytea
)
;

-- ----------------------------
-- Records of qrtz_triggers
-- ----------------------------
INSERT INTO "public"."qrtz_triggers" VALUES ('youyouScheduler', 'TASK_CLASS_NAME3', 'DEFAULT', 'TASK_CLASS_NAME3', 'DEFAULT', NULL, 1622082080000, -1, 5, 'PAUSED', 'CRON', 1622082068000, 0, NULL, 2, E'\\\\x');
INSERT INTO "public"."qrtz_triggers" VALUES ('youyouScheduler', 'TASK_CLASS_NAME1', 'DEFAULT', 'TASK_CLASS_NAME1', 'DEFAULT', NULL, 1622082070000, -1, 5, 'PAUSED', 'CRON', 1622082068000, 0, NULL, 2, E'\\\\x');
INSERT INTO "public"."qrtz_triggers" VALUES ('youyouScheduler', 'TASK_CLASS_NAME2', 'DEFAULT', 'TASK_CLASS_NAME2', 'DEFAULT', NULL, 1622082075000, -1, 5, 'PAUSED', 'CRON', 1622082068000, 0, NULL, 2, E'\\\\x');

-- ----------------------------
-- Table structure for sys_config
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_config";
CREATE TABLE "public"."sys_config" (
                                       "config_id" bigserial,
                                       "config_name" varchar(100) COLLATE "pg_catalog"."default",
                                       "config_key" varchar(100) COLLATE "pg_catalog"."default",
                                       "config_value" varchar(500) COLLATE "pg_catalog"."default",
                                       "config_type" char(1) COLLATE "pg_catalog"."default",
                                       "create_by" varchar(64) COLLATE "pg_catalog"."default",
                                       "create_time" timestamp(6),
                                       "update_by" varchar(64) COLLATE "pg_catalog"."default",
                                       "update_time" timestamp(6),
                                       "remark" varchar(500) COLLATE "pg_catalog"."default"
)
;
COMMENT ON COLUMN "public"."sys_config"."config_id" IS '参数主键';
COMMENT ON COLUMN "public"."sys_config"."config_name" IS '参数名称';
COMMENT ON COLUMN "public"."sys_config"."config_key" IS '参数键名';
COMMENT ON COLUMN "public"."sys_config"."config_value" IS '参数键值';
COMMENT ON COLUMN "public"."sys_config"."config_type" IS '系统内置（Y是 N否）';
COMMENT ON COLUMN "public"."sys_config"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_config"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_config"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_config"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_config"."remark" IS '备注';
COMMENT ON TABLE "public"."sys_config" IS '参数配置表';

-- ----------------------------
-- Records of sys_config
-- ----------------------------
INSERT INTO "public"."sys_config" VALUES (1, '主框架页-默认皮肤样式名称', 'sys.index.skinName', 'skin-blue', 'Y', 'admin', '2021-05-26 18:56:31', 'admin', '2021-05-27 09:07:43.532263', '蓝色 skin-blue、绿色 skin-green、紫色 skin-purple、红色 skin-red、黄色 skin-yellow');
INSERT INTO "public"."sys_config" VALUES (2, '用户管理-账号初始密码', 'sys.user.initPassword', '123456', 'Y', 'admin', '2021-05-26 18:56:31', 'admin', '2021-05-27 10:15:52.394492', '初始化密码 123456');
INSERT INTO "public"."sys_config" VALUES (3, '主框架页-侧边栏主题', 'sys.index.sideTheme', 'theme-dark', 'Y', 'admin', '2021-05-26 18:56:31', 'admin', NULL, '深色主题theme-dark，浅色主题theme-light');
insert into "public"."sys_config" VALUES(4, '账号自助-验证码开关',  'sys.account.captchaEnabled', 'true', 'Y', 'admin', current_Timestamp, 'admin', null, '是否开启验证码功能（true开启，false关闭）');
insert into "public"."sys_config" VALUES(5, '账号自助-是否开启用户注册功能', 'sys.account.registerUser', 'false', 'Y', 'admin', current_Timestamp, 'admin', null, '是否开启注册用户功能（true开启，false关闭）');

-- ----------------------------
-- Table structure for sys_dept
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_dept";
CREATE TABLE "public"."sys_dept" (
                                     "dept_id" bigserial,
                                     "parent_id" int8 default 0,
                                     "ancestors" varchar(50) COLLATE "pg_catalog"."default",
                                     "dept_name" varchar(30) COLLATE "pg_catalog"."default",
                                     "order_num" int4,
                                     "leader" varchar(20) COLLATE "pg_catalog"."default",
                                     "phone" varchar(11) COLLATE "pg_catalog"."default",
                                     "email" varchar(50) COLLATE "pg_catalog"."default",
                                     "status" char(1) COLLATE "pg_catalog"."default",
                                     "del_flag" char(1) COLLATE "pg_catalog"."default" DEFAULT 0,
                                     "create_by" varchar(64) COLLATE "pg_catalog"."default",
                                     "create_time" timestamp(6),
                                     "update_by" varchar(64) COLLATE "pg_catalog"."default",
                                     "update_time" timestamp(6)
)
;
COMMENT ON COLUMN "public"."sys_dept"."dept_id" IS '部门id';
COMMENT ON COLUMN "public"."sys_dept"."parent_id" IS '父部门id';
COMMENT ON COLUMN "public"."sys_dept"."ancestors" IS '祖级列表';
COMMENT ON COLUMN "public"."sys_dept"."dept_name" IS '部门名称';
COMMENT ON COLUMN "public"."sys_dept"."order_num" IS '显示顺序';
COMMENT ON COLUMN "public"."sys_dept"."leader" IS '负责人';
COMMENT ON COLUMN "public"."sys_dept"."phone" IS '联系电话';
COMMENT ON COLUMN "public"."sys_dept"."email" IS '邮箱';
COMMENT ON COLUMN "public"."sys_dept"."status" IS '部门状态（0正常 1停用）';
COMMENT ON COLUMN "public"."sys_dept"."del_flag" IS '删除标志（0代表存在 2代表删除）';
COMMENT ON COLUMN "public"."sys_dept"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_dept"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_dept"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_dept"."update_time" IS '更新时间';
COMMENT ON TABLE "public"."sys_dept" IS '部门表';

-- ----------------------------
-- Records of sys_dept
-- ----------------------------
INSERT INTO "public"."sys_dept" VALUES (102, 100, '0,100', '长沙分公司', 2, '猫头虎', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2021-05-26 18:56:27', '', NULL);
INSERT INTO "public"."sys_dept" VALUES (104, 101, '0,100,101', '市场部门', 2, '猫头虎', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2021-05-26 18:56:27', '', NULL);
INSERT INTO "public"."sys_dept" VALUES (105, 101, '0,100,101', '测试部门', 3, '猫头虎', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2021-05-26 18:56:27', '', NULL);
INSERT INTO "public"."sys_dept" VALUES (106, 101, '0,100,101', '财务部门', 4, '猫头虎', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2021-05-26 18:56:28', '', NULL);
INSERT INTO "public"."sys_dept" VALUES (107, 101, '0,100,101', '运维部门', 5, '猫头虎', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2021-05-26 18:56:28', '', NULL);
INSERT INTO "public"."sys_dept" VALUES (108, 102, '0,100,102', '市场部门', 1, '猫头虎', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2021-05-26 18:56:28', '', NULL);
INSERT INTO "public"."sys_dept" VALUES (109, 102, '0,100,102', '财务部门', 2, '猫头虎', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2021-05-26 18:56:28', '', NULL);
INSERT INTO "public"."sys_dept" VALUES (103, 101, '0,100,101', '研发部门', 1, '猫头虎', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2021-05-26 18:56:27', 'admin', '2021-05-27 09:05:25.083296');
INSERT INTO "public"."sys_dept" VALUES (101, 100, '0,100', '深圳总公司', 1, '猫头虎', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2021-05-26 18:56:27', 'admin', '2021-05-27 09:05:25.091901');
INSERT INTO "public"."sys_dept" VALUES (100, 0, '0', '新生儿护理工作台', 0, '猫头虎', '15888888888', 'ry@qq.com', '0', '0', 'admin', '2021-05-26 18:56:27', 'admin', '2021-05-27 10:00:30.143076');

-- ----------------------------
-- Table structure for sys_dict_data
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_dict_data";
CREATE TABLE "public"."sys_dict_data" (
                                          "dict_code" bigserial,
                                          "dict_sort" int4,
                                          "dict_label" varchar(100) COLLATE "pg_catalog"."default",
                                          "dict_value" varchar(100) COLLATE "pg_catalog"."default",
                                          "dict_type" varchar(100) COLLATE "pg_catalog"."default",
                                          "css_class" varchar(100) COLLATE "pg_catalog"."default",
                                          "list_class" varchar(100) COLLATE "pg_catalog"."default",
                                          "is_default" char(1) COLLATE "pg_catalog"."default",
                                          "status" char(1) COLLATE "pg_catalog"."default",
                                          "create_by" varchar(64) COLLATE "pg_catalog"."default",
                                          "create_time" timestamp(6),
                                          "update_by" varchar(64) COLLATE "pg_catalog"."default",
                                          "update_time" timestamp(6),
                                          "remark" varchar(500) COLLATE "pg_catalog"."default"
)
;
COMMENT ON COLUMN "public"."sys_dict_data"."dict_code" IS '字典编码';
COMMENT ON COLUMN "public"."sys_dict_data"."dict_sort" IS '字典排序';
COMMENT ON COLUMN "public"."sys_dict_data"."dict_label" IS '字典标签';
COMMENT ON COLUMN "public"."sys_dict_data"."dict_value" IS '字典键值';
COMMENT ON COLUMN "public"."sys_dict_data"."dict_type" IS '字典类型';
COMMENT ON COLUMN "public"."sys_dict_data"."css_class" IS '样式属性（其他样式扩展）';
COMMENT ON COLUMN "public"."sys_dict_data"."list_class" IS '表格回显样式';
COMMENT ON COLUMN "public"."sys_dict_data"."is_default" IS '是否默认（Y是 N否）';
COMMENT ON COLUMN "public"."sys_dict_data"."status" IS '状态（0正常 1停用）';
COMMENT ON COLUMN "public"."sys_dict_data"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_dict_data"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_dict_data"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_dict_data"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_dict_data"."remark" IS '备注';
COMMENT ON TABLE "public"."sys_dict_data" IS '字典数据表';

-- ----------------------------
-- Records of sys_dict_data
-- ----------------------------
insert into sys_dict_data values(1,  1,  '男',       '0',       'sys_user_sex',        '',   '',        'Y', '0', 'admin', current_timestamp, '', null, '性别男');
insert into sys_dict_data values(2,  2,  '女',       '1',       'sys_user_sex',        '',   '',        'N', '0', 'admin', current_timestamp, '', null, '性别女');
insert into sys_dict_data values(3,  3,  '未知',     '2',       'sys_user_sex',        '',   '',        'N', '0', 'admin', current_timestamp, '', null, '性别未知');
insert into sys_dict_data values(4,  1,  '显示',     '0',       'sys_show_hide',       '',   'primary', 'Y', '0', 'admin', current_timestamp, '', null, '显示菜单');
insert into sys_dict_data values(5,  2,  '隐藏',     '1',       'sys_show_hide',       '',   'danger',  'N', '0', 'admin', current_timestamp, '', null, '隐藏菜单');
insert into sys_dict_data values(6,  1,  '正常',     '0',       'sys_normal_disable',  '',   'primary', 'Y', '0', 'admin', current_timestamp, '', null, '正常状态');
insert into sys_dict_data values(7,  2,  '停用',     '1',       'sys_normal_disable',  '',   'danger',  'N', '0', 'admin', current_timestamp, '', null, '停用状态');
insert into sys_dict_data values(8,  1,  '正常',     '0',       'sys_job_status',      '',   'primary', 'Y', '0', 'admin', current_timestamp, '', null, '正常状态');
insert into sys_dict_data values(9,  2,  '暂停',     '1',       'sys_job_status',      '',   'danger',  'N', '0', 'admin', current_timestamp, '', null, '停用状态');
insert into sys_dict_data values(10, 1,  '默认',     'DEFAULT', 'sys_job_group',       '',   '',        'Y', '0', 'admin', current_timestamp, '', null, '默认分组');
insert into sys_dict_data values(11, 2,  '系统',     'SYSTEM',  'sys_job_group',       '',   '',        'N', '0', 'admin', current_timestamp, '', null, '系统分组');
insert into sys_dict_data values(12, 1,  '是',       'Y',       'sys_yes_no',          '',   'primary', 'Y', '0', 'admin', current_timestamp, '', null, '系统默认是');
insert into sys_dict_data values(13, 2,  '否',       'N',       'sys_yes_no',          '',   'danger',  'N', '0', 'admin', current_timestamp, '', null, '系统默认否');
insert into sys_dict_data values(14, 1,  '通知',     '1',       'sys_notice_type',     '',   'warning', 'Y', '0', 'admin', current_timestamp, '', null, '通知');
insert into sys_dict_data values(15, 2,  '公告',     '2',       'sys_notice_type',     '',   'success', 'N', '0', 'admin', current_timestamp, '', null, '公告');
insert into sys_dict_data values(16, 1,  '正常',     '0',       'sys_notice_status',   '',   'primary', 'Y', '0', 'admin', current_timestamp, '', null, '正常状态');
insert into sys_dict_data values(17, 2,  '关闭',     '1',       'sys_notice_status',   '',   'danger',  'N', '0', 'admin', current_timestamp, '', null, '关闭状态');
insert into sys_dict_data values(18, 1,  '新增',     '1',       'sys_oper_type',       '',   'info',    'N', '0', 'admin', current_timestamp, '', null, '新增操作');
insert into sys_dict_data values(19, 2,  '修改',     '2',       'sys_oper_type',       '',   'info',    'N', '0', 'admin', current_timestamp, '', null, '修改操作');
insert into sys_dict_data values(20, 3,  '删除',     '3',       'sys_oper_type',       '',   'danger',  'N', '0', 'admin', current_timestamp, '', null, '删除操作');
insert into sys_dict_data values(21, 4,  '授权',     '4',       'sys_oper_type',       '',   'primary', 'N', '0', 'admin', current_timestamp, '', null, '授权操作');
insert into sys_dict_data values(22, 5,  '导出',     '5',       'sys_oper_type',       '',   'warning', 'N', '0', 'admin', current_timestamp, '', null, '导出操作');
insert into sys_dict_data values(23, 6,  '导入',     '6',       'sys_oper_type',       '',   'warning', 'N', '0', 'admin', current_timestamp, '', null, '导入操作');
insert into sys_dict_data values(24, 7,  '强退',     '7',       'sys_oper_type',       '',   'danger',  'N', '0', 'admin', current_timestamp, '', null, '强退操作');
insert into sys_dict_data values(25, 8,  '生成代码', '8',       'sys_oper_type',       '',   'warning', 'N', '0', 'admin', current_timestamp, '', null, '生成操作');
insert into sys_dict_data values(26, 9,  '清空数据', '9',       'sys_oper_type',       '',   'danger',  'N', '0', 'admin', current_timestamp, '', null, '清空操作');
insert into sys_dict_data values(27, 1,  '成功',     '0',       'sys_common_status',   '',   'primary', 'N', '0', 'admin', current_timestamp, '', null, '正常状态');
insert into sys_dict_data values(28, 2,  '失败',     '1',       'sys_common_status',   '',   'danger',  'N', '0', 'admin', current_timestamp, '', null, '停用状态');

-- ----------------------------
-- Table structure for sys_dict_type
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_dict_type";
CREATE TABLE "public"."sys_dict_type" (
                                          "dict_id" bigserial,
                                          "dict_name" varchar(100) COLLATE "pg_catalog"."default",
                                          "dict_type" varchar(100) COLLATE "pg_catalog"."default",
                                          "status" char(1) COLLATE "pg_catalog"."default",
                                          "create_by" varchar(64) COLLATE "pg_catalog"."default",
                                          "create_time" timestamp(6),
                                          "update_by" varchar(64) COLLATE "pg_catalog"."default",
                                          "update_time" timestamp(6),
                                          "remark" varchar(500) COLLATE "pg_catalog"."default"
)
;
COMMENT ON COLUMN "public"."sys_dict_type"."dict_id" IS '字典主键';
COMMENT ON COLUMN "public"."sys_dict_type"."dict_name" IS '字典名称';
COMMENT ON COLUMN "public"."sys_dict_type"."dict_type" IS '字典类型';
COMMENT ON COLUMN "public"."sys_dict_type"."status" IS '状态（0正常 1停用）';
COMMENT ON COLUMN "public"."sys_dict_type"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_dict_type"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_dict_type"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_dict_type"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_dict_type"."remark" IS '备注';
COMMENT ON TABLE "public"."sys_dict_type" IS '字典类型表';

-- ----------------------------
-- Records of sys_dict_type
-- ----------------------------
INSERT INTO "public"."sys_dict_type" VALUES (2, '菜单状态', 'sys_show_hide', '0', 'admin', '2021-05-26 18:56:30', '', NULL, '菜单状态列表');
INSERT INTO "public"."sys_dict_type" VALUES (3, '系统开关', 'sys_normal_disable', '0', 'admin', '2021-05-26 18:56:30', '', NULL, '系统开关列表');
INSERT INTO "public"."sys_dict_type" VALUES (4, '任务状态', 'sys_job_status', '0', 'admin', '2021-05-26 18:56:30', '', NULL, '任务状态列表');
INSERT INTO "public"."sys_dict_type" VALUES (5, '任务分组', 'sys_job_group', '0', 'admin', '2021-05-26 18:56:30', '', NULL, '任务分组列表');
INSERT INTO "public"."sys_dict_type" VALUES (6, '系统是否', 'sys_yes_no', '0', 'admin', '2021-05-26 18:56:30', '', NULL, '系统是否列表');
INSERT INTO "public"."sys_dict_type" VALUES (7, '通知类型', 'sys_notice_type', '0', 'admin', '2021-05-26 18:56:30', '', NULL, '通知类型列表');
INSERT INTO "public"."sys_dict_type" VALUES (8, '通知状态', 'sys_notice_status', '0', 'admin', '2021-05-26 18:56:30', '', NULL, '通知状态列表');
INSERT INTO "public"."sys_dict_type" VALUES (9, '操作类型', 'sys_oper_type', '0', 'admin', '2021-05-26 18:56:30', '', NULL, '操作类型列表');
INSERT INTO "public"."sys_dict_type" VALUES (10, '系统状态', 'sys_common_status', '0', 'admin', '2021-05-26 18:56:30', '', NULL, '登录状态列表');
INSERT INTO "public"."sys_dict_type" VALUES (1, '用户性别', 'sys_user_sex', '0', 'admin', '2021-05-26 18:56:30', 'admin', '2021-05-27 10:07:12.015926', '用户性别列表');

-- ----------------------------
-- Table structure for sys_job
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_job";
CREATE TABLE "public"."sys_job" (
                                    "job_id" bigserial,
                                    "job_name" varchar(64) COLLATE "pg_catalog"."default" NOT NULL,
                                    "job_group" varchar(64) COLLATE "pg_catalog"."default" NOT NULL,
                                    "invoke_target" varchar(500) COLLATE "pg_catalog"."default" NOT NULL,
                                    "cron_expression" varchar(255) COLLATE "pg_catalog"."default",
                                    "misfire_policy" varchar(20) COLLATE "pg_catalog"."default",
                                    "concurrent" char(1) COLLATE "pg_catalog"."default",
                                    "status" char(1) COLLATE "pg_catalog"."default",
                                    "create_by" varchar(64) COLLATE "pg_catalog"."default",
                                    "create_time" timestamp(6),
                                    "update_by" varchar(64) COLLATE "pg_catalog"."default",
                                    "update_time" timestamp(6),
                                    "remark" varchar(500) COLLATE "pg_catalog"."default"
)
;
COMMENT ON COLUMN "public"."sys_job"."job_id" IS '任务ID';
COMMENT ON COLUMN "public"."sys_job"."job_name" IS '任务名称';
COMMENT ON COLUMN "public"."sys_job"."job_group" IS '任务组名';
COMMENT ON COLUMN "public"."sys_job"."invoke_target" IS '调用目标字符串';
COMMENT ON COLUMN "public"."sys_job"."cron_expression" IS 'cron执行表达式';
COMMENT ON COLUMN "public"."sys_job"."misfire_policy" IS '计划执行错误策略（1立即执行 2执行一次 3放弃执行）';
COMMENT ON COLUMN "public"."sys_job"."concurrent" IS '是否并发执行（0允许 1禁止）';
COMMENT ON COLUMN "public"."sys_job"."status" IS '状态（0正常 1暂停）';
COMMENT ON COLUMN "public"."sys_job"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_job"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_job"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_job"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_job"."remark" IS '备注信息';
COMMENT ON TABLE "public"."sys_job" IS '定时任务调度表';

-- ----------------------------
-- Records of sys_job
-- ----------------------------
INSERT INTO "public"."sys_job" VALUES (1, '系统默认（无参）', 'DEFAULT', 'ryTask.ryNoParams', '0/10 * * * * ?', '3', '1', '1', 'admin', '2021-05-26 18:56:31', '', NULL, '');
INSERT INTO "public"."sys_job" VALUES (2, '系统默认（有参）', 'DEFAULT', 'ryTask.ryParams(''ry'')', '0/15 * * * * ?', '3', '1', '1', 'admin', '2021-05-26 18:56:31', '', NULL, '');
INSERT INTO "public"."sys_job" VALUES (3, '系统默认（多参）', 'DEFAULT', 'ryTask.ryMultipleParams(''ry'', true, 2000L, 316.50D, 100)', '0/20 * * * * ?', '3', '1', '1', 'admin', '2021-05-26 18:56:31', '', NULL, '');

-- ----------------------------
-- Table structure for sys_job_log
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_job_log";
CREATE TABLE "public"."sys_job_log" (
                                        "job_log_id" bigserial,
                                        "job_name" varchar(64) COLLATE "pg_catalog"."default" NOT NULL,
                                        "job_group" varchar(64) COLLATE "pg_catalog"."default" NOT NULL,
                                        "invoke_target" varchar(500) COLLATE "pg_catalog"."default" NOT NULL,
                                        "job_message" varchar(500) COLLATE "pg_catalog"."default",
                                        "status" char(1) COLLATE "pg_catalog"."default",
                                        "exception_info" varchar(2000) COLLATE "pg_catalog"."default",
                                        "create_time" timestamp(6)
)
;
COMMENT ON COLUMN "public"."sys_job_log"."job_log_id" IS '任务日志ID';
COMMENT ON COLUMN "public"."sys_job_log"."job_name" IS '任务名称';
COMMENT ON COLUMN "public"."sys_job_log"."job_group" IS '任务组名';
COMMENT ON COLUMN "public"."sys_job_log"."invoke_target" IS '调用目标字符串';
COMMENT ON COLUMN "public"."sys_job_log"."job_message" IS '日志信息';
COMMENT ON COLUMN "public"."sys_job_log"."status" IS '执行状态（0正常 1失败）';
COMMENT ON COLUMN "public"."sys_job_log"."exception_info" IS '异常信息';
COMMENT ON COLUMN "public"."sys_job_log"."create_time" IS '创建时间';
COMMENT ON TABLE "public"."sys_job_log" IS '定时任务调度日志表';

-- ----------------------------
-- Records of sys_job_log
-- ----------------------------

-- ----------------------------
-- Table structure for sys_logininfor
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_logininfor";
CREATE TABLE "public"."sys_logininfor" (
                                           "info_id" bigserial,
                                           "user_name" varchar(50) COLLATE "pg_catalog"."default",
                                           "ipaddr" varchar(128) COLLATE "pg_catalog"."default",
                                           "login_location" varchar(255) COLLATE "pg_catalog"."default",
                                           "browser" varchar(50) COLLATE "pg_catalog"."default",
                                           "os" varchar(50) COLLATE "pg_catalog"."default",
                                           "status" char(1) COLLATE "pg_catalog"."default",
                                           "msg" varchar(255) COLLATE "pg_catalog"."default",
                                           "login_time" timestamp(6)
)
;
COMMENT ON COLUMN "public"."sys_logininfor"."info_id" IS '访问ID';
COMMENT ON COLUMN "public"."sys_logininfor"."user_name" IS '用户账号';
COMMENT ON COLUMN "public"."sys_logininfor"."ipaddr" IS '登录IP地址';
COMMENT ON COLUMN "public"."sys_logininfor"."login_location" IS '登录地点';
COMMENT ON COLUMN "public"."sys_logininfor"."browser" IS '浏览器类型';
COMMENT ON COLUMN "public"."sys_logininfor"."os" IS '操作系统';
COMMENT ON COLUMN "public"."sys_logininfor"."status" IS '登录状态（0成功 1失败）';
COMMENT ON COLUMN "public"."sys_logininfor"."msg" IS '提示消息';
COMMENT ON COLUMN "public"."sys_logininfor"."login_time" IS '访问时间';
COMMENT ON TABLE "public"."sys_logininfor" IS '系统访问记录';

-- ----------------------------
-- Records of sys_logininfor
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_menu";
CREATE TABLE "public"."sys_menu" (
                                     "menu_id" bigserial,
                                     "menu_name" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
                                     "parent_id" int8 default 0,
                                     "order_num" int4,
                                     "path" varchar(200) COLLATE "pg_catalog"."default",
                                     "component" varchar(255) COLLATE "pg_catalog"."default",
                                     "query" varchar(255) COLLATE "pg_catalog"."default",
                                     route_name        varchar(50)     default '',
                                     "is_frame" int4,
                                     "is_cache" int4 default 0,
                                     "menu_type" char(1) COLLATE "pg_catalog"."default",
                                     "visible" char(1) COLLATE "pg_catalog"."default",
                                     "status" int2,
                                     "perms" varchar(100) COLLATE "pg_catalog"."default",
                                     "icon" varchar(100) COLLATE "pg_catalog"."default",
                                     "create_by" varchar(64) COLLATE "pg_catalog"."default",
                                     "create_time" timestamp(6),
                                     "update_by" varchar(64) COLLATE "pg_catalog"."default",
                                     "update_time" timestamp(6),
                                     "remark" varchar(500) COLLATE "pg_catalog"."default"
)
;
COMMENT ON COLUMN "public"."sys_menu"."menu_id" IS '菜单ID';
COMMENT ON COLUMN "public"."sys_menu"."menu_name" IS '菜单名称';
COMMENT ON COLUMN "public"."sys_menu"."parent_id" IS '父菜单ID';
COMMENT ON COLUMN "public"."sys_menu"."order_num" IS '显示顺序';
COMMENT ON COLUMN "public"."sys_menu"."path" IS '路由地址';
COMMENT ON COLUMN "public"."sys_menu"."component" IS '组件路径';
COMMENT ON COLUMN "public"."sys_menu"."query" IS '路由参数';
COMMENT ON COLUMN "public"."sys_menu"."route_name" IS '路由名称';
COMMENT ON COLUMN "public"."sys_menu"."is_frame" IS '是否为外链（0是 1否）';
COMMENT ON COLUMN "public"."sys_menu"."is_cache" IS '是否缓存（0缓存 1不缓存）';
COMMENT ON COLUMN "public"."sys_menu"."menu_type" IS '菜单类型（M目录 C菜单 F按钮）';
COMMENT ON COLUMN "public"."sys_menu"."visible" IS '菜单状态（0显示 1隐藏）';
COMMENT ON COLUMN "public"."sys_menu"."status" IS '菜单状态（0正常 1停用）';
COMMENT ON COLUMN "public"."sys_menu"."perms" IS '权限标识';
COMMENT ON COLUMN "public"."sys_menu"."icon" IS '菜单图标';
COMMENT ON COLUMN "public"."sys_menu"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_menu"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_menu"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_menu"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_menu"."remark" IS '备注';
COMMENT ON TABLE "public"."sys_menu" IS '菜单权限表';

-- ----------------------------
-- 初始化-菜单信息表数据
-- ----------------------------
-- 一级菜单
insert into sys_menu values('1', '系统管理', '0', '1', 'system',           null, '', '', 1, 0, 'M', '0', '0', '', 'system',   'admin', current_timestamp, '', null, '系统管理目录');
insert into sys_menu values('2', '系统监控', '0', '2', 'monitor',          null, '', '', 1, 0, 'M', '0', '0', '', 'monitor',  'admin', current_timestamp, '', null, '系统监控目录');
insert into sys_menu values('3', '系统工具', '0', '3', 'tool',             null, '', '', 1, 0, 'M', '0', '0', '', 'tool',     'admin', current_timestamp, '', null, '系统工具目录');
-- 已下线：新生儿护理工作台官网
-- insert into sys_menu values('4', '新生儿护理工作台官网', '0', '4', 'http://youyou.vip', null, '', '', 0, 0, 'M', '0', '0', '', 'guide',    'admin', current_timestamp, '', null, '新生儿护理工作台官网地址');
-- 二级菜单
insert into sys_menu values('100',  '用户管理', '1',   '1', 'user',       'system/user/index',        '', '', 1, 0, 'C', '0', '0', 'system:user:list',        'user',          'admin', current_timestamp, '', null, '用户管理菜单');
insert into sys_menu values('101',  '角色管理', '1',   '2', 'role',       'system/role/index',        '', '', 1, 0, 'C', '0', '0', 'system:role:list',        'peoples',       'admin', current_timestamp, '', null, '角色管理菜单');
insert into sys_menu values('102',  '菜单管理', '1',   '3', 'menu',       'system/menu/index',        '', '', 1, 0, 'C', '0', '0', 'system:menu:list',        'tree-table',    'admin', current_timestamp, '', null, '菜单管理菜单');
insert into sys_menu values('103',  '部门管理', '1',   '4', 'dept',       'system/dept/index',        '', '', 1, 0, 'C', '0', '0', 'system:dept:list',        'tree',          'admin', current_timestamp, '', null, '部门管理菜单');
insert into sys_menu values('104',  '岗位管理', '1',   '5', 'post',       'system/post/index',        '', '', 1, 0, 'C', '0', '0', 'system:post:list',        'post',          'admin', current_timestamp, '', null, '岗位管理菜单');
insert into sys_menu values('105',  '字典管理', '1',   '6', 'dict',       'system/dict/index',        '', '', 1, 0, 'C', '0', '0', 'system:dict:list',        'dict',          'admin', current_timestamp, '', null, '字典管理菜单');
insert into sys_menu values('106',  '参数设置', '1',   '7', 'config',     'system/config/index',      '', '', 1, 0, 'C', '0', '0', 'system:config:list',      'edit',          'admin', current_timestamp, '', null, '参数设置菜单');
insert into sys_menu values('107',  '通知公告', '1',   '8', 'notice',     'system/notice/index',      '', '', 1, 0, 'C', '0', '0', 'system:notice:list',      'message',       'admin', current_timestamp, '', null, '通知公告菜单');
insert into sys_menu values('108',  '日志管理', '1',   '9', 'log',        '',                         '', '', 1, 0, 'M', '0', '0', '',                        'log',           'admin', current_timestamp, '', null, '日志管理菜单');
insert into sys_menu values('109',  '在线用户', '2',   '1', 'online',     'monitor/online/index',     '', '', 1, 0, 'C', '0', '0', 'monitor:online:list',     'online',        'admin', current_timestamp, '', null, '在线用户菜单');
insert into sys_menu values('110',  '定时任务', '2',   '2', 'job',        'monitor/job/index',        '', '', 1, 0, 'C', '0', '0', 'monitor:job:list',        'job',           'admin', current_timestamp, '', null, '定时任务菜单');
insert into sys_menu values('111',  '数据监控', '2',   '3', 'druid',      'monitor/druid/index',      '', '', 1, 0, 'C', '0', '0', 'monitor:druid:list',      'druid',         'admin', current_timestamp, '', null, '数据监控菜单');
insert into sys_menu values('112',  '服务监控', '2',   '4', 'server',     'monitor/server/index',     '', '', 1, 0, 'C', '0', '0', 'monitor:server:list',     'server',        'admin', current_timestamp, '', null, '服务监控菜单');
insert into sys_menu values('113',  '缓存监控', '2',   '5', 'cache',      'monitor/cache/index',      '', '', 1, 0, 'C', '0', '0', 'monitor:cache:list',      'redis',         'admin', current_timestamp, '', null, '缓存监控菜单');
insert into sys_menu values('114',  '缓存列表', '2',   '6', 'cacheList',  'monitor/cache/list',       '', '', 1, 0, 'C', '0', '0', 'monitor:cache:list',      'redis-list',    'admin', current_timestamp, '', null, '缓存列表菜单');
insert into sys_menu values('115',  '表单构建', '3',   '1', 'build',      'tool/build/index',         '', '', 1, 0, 'C', '0', '0', 'tool:build:list',         'build',         'admin', current_timestamp, '', null, '表单构建菜单');
insert into sys_menu values('116',  '代码生成', '3',   '2', 'gen',        'tool/gen/index',           '', '', 1, 0, 'C', '0', '0', 'tool:gen:list',           'code',          'admin', current_timestamp, '', null, '代码生成菜单');
insert into sys_menu values('117',  '系统接口', '3',   '3', 'swagger',    'tool/swagger/index',       '', '', 1, 0, 'C', '0', '0', 'tool:swagger:list',       'swagger',       'admin', current_timestamp, '', null, '系统接口菜单');
-- 三级菜单
insert into sys_menu values('500',  '操作日志', '108', '1', 'operlog',    'monitor/operlog/index',    '', '', 1, 0, 'C', '0', '0', 'monitor:operlog:list',    'form',          'admin', current_timestamp, '', null, '操作日志菜单');
insert into sys_menu values('501',  '登录日志', '108', '2', 'logininfor', 'monitor/logininfor/index', '', '', 1, 0, 'C', '0', '0', 'monitor:logininfor:list', 'logininfor',    'admin', current_timestamp, '', null, '登录日志菜单');
-- 用户管理按钮
insert into sys_menu values('1000', '用户查询', '100', '1',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:query',          '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1001', '用户新增', '100', '2',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:add',            '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1002', '用户修改', '100', '3',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:edit',           '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1003', '用户删除', '100', '4',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:remove',         '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1004', '用户导出', '100', '5',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:export',         '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1005', '用户导入', '100', '6',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:import',         '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1006', '重置密码', '100', '7',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:user:resetPwd',       '#', 'admin', current_timestamp, '', null, '');
-- 角色管理按钮
insert into sys_menu values('1007', '角色查询', '101', '1',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:query',          '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1008', '角色新增', '101', '2',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:add',            '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1009', '角色修改', '101', '3',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:edit',           '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1010', '角色删除', '101', '4',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:remove',         '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1011', '角色导出', '101', '5',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:role:export',         '#', 'admin', current_timestamp, '', null, '');
-- 菜单管理按钮
insert into sys_menu values('1012', '菜单查询', '102', '1',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:query',          '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1013', '菜单新增', '102', '2',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:add',            '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1014', '菜单修改', '102', '3',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:edit',           '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1015', '菜单删除', '102', '4',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:menu:remove',         '#', 'admin', current_timestamp, '', null, '');
-- 部门管理按钮
insert into sys_menu values('1016', '部门查询', '103', '1',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:query',          '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1017', '部门新增', '103', '2',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:add',            '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1018', '部门修改', '103', '3',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:edit',           '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1019', '部门删除', '103', '4',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:dept:remove',         '#', 'admin', current_timestamp, '', null, '');
-- 岗位管理按钮
insert into sys_menu values('1020', '岗位查询', '104', '1',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:query',          '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1021', '岗位新增', '104', '2',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:add',            '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1022', '岗位修改', '104', '3',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:edit',           '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1023', '岗位删除', '104', '4',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:remove',         '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1024', '岗位导出', '104', '5',  '', '', '', '', 1, 0, 'F', '0', '0', 'system:post:export',         '#', 'admin', current_timestamp, '', null, '');
-- 字典管理按钮
insert into sys_menu values('1025', '字典查询', '105', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:query',          '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1026', '字典新增', '105', '2', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:add',            '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1027', '字典修改', '105', '3', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:edit',           '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1028', '字典删除', '105', '4', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:remove',         '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1029', '字典导出', '105', '5', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:dict:export',         '#', 'admin', current_timestamp, '', null, '');
-- 参数设置按钮
insert into sys_menu values('1030', '参数查询', '106', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:query',        '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1031', '参数新增', '106', '2', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:add',          '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1032', '参数修改', '106', '3', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:edit',         '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1033', '参数删除', '106', '4', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:remove',       '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1034', '参数导出', '106', '5', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:config:export',       '#', 'admin', current_timestamp, '', null, '');
-- 通知公告按钮
insert into sys_menu values('1035', '公告查询', '107', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:query',        '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1036', '公告新增', '107', '2', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:add',          '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1037', '公告修改', '107', '3', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:edit',         '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1038', '公告删除', '107', '4', '#', '', '', '', 1, 0, 'F', '0', '0', 'system:notice:remove',       '#', 'admin', current_timestamp, '', null, '');
-- 操作日志按钮
insert into sys_menu values('1039', '操作查询', '500', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:query',      '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1040', '操作删除', '500', '2', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:remove',     '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1041', '日志导出', '500', '3', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:operlog:export',     '#', 'admin', current_timestamp, '', null, '');
-- 登录日志按钮
insert into sys_menu values('1042', '登录查询', '501', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:query',   '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1043', '登录删除', '501', '2', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:remove',  '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1044', '日志导出', '501', '3', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:export',  '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1045', '账户解锁', '501', '4', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:logininfor:unlock',  '#', 'admin', current_timestamp, '', null, '');
-- 在线用户按钮
insert into sys_menu values('1046', '在线查询', '109', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:query',       '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1047', '批量强退', '109', '2', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:batchLogout', '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1048', '单条强退', '109', '3', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:online:forceLogout', '#', 'admin', current_timestamp, '', null, '');
-- 定时任务按钮
insert into sys_menu values('1049', '任务查询', '110', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:query',          '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1050', '任务新增', '110', '2', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:add',            '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1051', '任务修改', '110', '3', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:edit',           '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1052', '任务删除', '110', '4', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:remove',         '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1053', '状态修改', '110', '5', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:changeStatus',   '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1054', '任务导出', '110', '6', '#', '', '', '', 1, 0, 'F', '0', '0', 'monitor:job:export',         '#', 'admin', current_timestamp, '', null, '');
-- 代码生成按钮
insert into sys_menu values('1055', '生成查询', '116', '1', '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:query',             '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1056', '生成修改', '116', '2', '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:edit',              '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1057', '生成删除', '116', '3', '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:remove',            '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1058', '导入代码', '116', '4', '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:import',            '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1059', '预览代码', '116', '5', '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:preview',           '#', 'admin', current_timestamp, '', null, '');
insert into sys_menu values('1060', '生成代码', '116', '6', '#', '', '', '', 1, 0, 'F', '0', '0', 'tool:gen:code',              '#', 'admin', current_timestamp, '', null, '');

-- ----------------------------
-- Table structure for sys_notice
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_notice";
CREATE TABLE "public"."sys_notice" (
                                       "notice_id" bigserial,
                                       "notice_title" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
                                       "notice_type" char(1) COLLATE "pg_catalog"."default" NOT NULL,
                                       "notice_content" text COLLATE "pg_catalog"."default",
                                       "status" char(1) COLLATE "pg_catalog"."default",
                                       "create_by" varchar(64) COLLATE "pg_catalog"."default",
                                       "create_time" timestamp(6),
                                       "update_by" varchar(64) COLLATE "pg_catalog"."default",
                                       "update_time" timestamp(6),
                                       "remark" varchar(255) COLLATE "pg_catalog"."default"
)
;
COMMENT ON COLUMN "public"."sys_notice"."notice_id" IS '公告ID';
COMMENT ON COLUMN "public"."sys_notice"."notice_title" IS '公告标题';
COMMENT ON COLUMN "public"."sys_notice"."notice_type" IS '公告类型（1通知 2公告）';
COMMENT ON COLUMN "public"."sys_notice"."notice_content" IS '公告内容';
COMMENT ON COLUMN "public"."sys_notice"."status" IS '公告状态（0正常 1关闭）';
COMMENT ON COLUMN "public"."sys_notice"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_notice"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_notice"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_notice"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_notice"."remark" IS '备注';
COMMENT ON TABLE "public"."sys_notice" IS '通知公告表';

-- ----------------------------
-- Records of sys_notice
-- ----------------------------
INSERT INTO "public"."sys_notice" VALUES (2, '维护通知：2018-07-01 新生儿护理工作台系统凌晨维护', '1', '\xe7bbb4e68aa4e58685e5aeb9', '0', 'admin', '2021-05-26 18:56:31', '', NULL, '管理员');
INSERT INTO "public"."sys_notice" VALUES (1, '温馨提醒：2018-07-01 新生儿护理工作台新版本发布啦', '2', '\', '0', 'admin', '2021-05-26 18:56:31', 'admin', '2021-05-27 09:08:41.403262', '管理员');

-- ----------------------------
-- Table structure for sys_oper_log
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_oper_log";
CREATE TABLE "public"."sys_oper_log" (
                                         "oper_id" bigserial,
                                         "title" varchar(50) COLLATE "pg_catalog"."default",
                                         "business_type" int4,
                                         "method" varchar(100) COLLATE "pg_catalog"."default",
                                         "request_method" varchar(10) COLLATE "pg_catalog"."default",
                                         "operator_type" int4,
                                         "oper_name" varchar(50) COLLATE "pg_catalog"."default",
                                         "dept_name" varchar(50) COLLATE "pg_catalog"."default",
                                         "oper_url" varchar(255) COLLATE "pg_catalog"."default",
                                         "oper_ip" varchar(128) COLLATE "pg_catalog"."default",
                                         "oper_location" varchar(255) COLLATE "pg_catalog"."default",
                                         "oper_param" varchar(2000) COLLATE "pg_catalog"."default",
                                         "json_result" varchar(2000) COLLATE "pg_catalog"."default",
                                         "status" int4,
                                         "error_msg" varchar(2000) COLLATE "pg_catalog"."default",
                                         "oper_time" timestamp(6),
                                         cost_time    int8      default 0
)
;
COMMENT ON COLUMN "public"."sys_oper_log"."oper_id" IS '日志主键';
COMMENT ON COLUMN "public"."sys_oper_log"."title" IS '模块标题';
COMMENT ON COLUMN "public"."sys_oper_log"."business_type" IS '业务类型（0其它 1新增 2修改 3删除）';
COMMENT ON COLUMN "public"."sys_oper_log"."method" IS '方法名称';
COMMENT ON COLUMN "public"."sys_oper_log"."request_method" IS '请求方式';
COMMENT ON COLUMN "public"."sys_oper_log"."operator_type" IS '操作类别（0其它 1后台用户 2手机端用户）';
COMMENT ON COLUMN "public"."sys_oper_log"."oper_name" IS '操作人员';
COMMENT ON COLUMN "public"."sys_oper_log"."dept_name" IS '部门名称';
COMMENT ON COLUMN "public"."sys_oper_log"."oper_url" IS '请求URL';
COMMENT ON COLUMN "public"."sys_oper_log"."oper_ip" IS '主机地址';
COMMENT ON COLUMN "public"."sys_oper_log"."oper_location" IS '操作地点';
COMMENT ON COLUMN "public"."sys_oper_log"."oper_param" IS '请求参数';
COMMENT ON COLUMN "public"."sys_oper_log"."json_result" IS '返回参数';
COMMENT ON COLUMN "public"."sys_oper_log"."status" IS '操作状态（0正常 1异常）';
COMMENT ON COLUMN "public"."sys_oper_log"."error_msg" IS '错误消息';
COMMENT ON COLUMN "public"."sys_oper_log"."oper_time" IS '操作时间';
COMMENT ON TABLE "public"."sys_oper_log" IS '操作日志记录';

-- ----------------------------
-- Table structure for sys_post
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_post";
CREATE TABLE "public"."sys_post" (
                                     "post_id" bigserial,
                                     "post_code" varchar(64) COLLATE "pg_catalog"."default" NOT NULL,
                                     "post_name" varchar(50) COLLATE "pg_catalog"."default" NOT NULL,
                                     "post_sort" int4 NOT NULL,
                                     "status" char(1) COLLATE "pg_catalog"."default" NOT NULL,
                                     "create_by" varchar(64) COLLATE "pg_catalog"."default",
                                     "create_time" timestamp(6),
                                     "update_by" varchar(64) COLLATE "pg_catalog"."default",
                                     "update_time" timestamp(6),
                                     "remark" varchar(500) COLLATE "pg_catalog"."default"
)
;
COMMENT ON COLUMN "public"."sys_post"."post_id" IS '岗位ID';
COMMENT ON COLUMN "public"."sys_post"."post_code" IS '岗位编码';
COMMENT ON COLUMN "public"."sys_post"."post_name" IS '岗位名称';
COMMENT ON COLUMN "public"."sys_post"."post_sort" IS '显示顺序';
COMMENT ON COLUMN "public"."sys_post"."status" IS '状态（0正常 1停用）';
COMMENT ON COLUMN "public"."sys_post"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_post"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_post"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_post"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_post"."remark" IS '备注';
COMMENT ON TABLE "public"."sys_post" IS '岗位信息表';

-- ----------------------------
-- Records of sys_post
-- ----------------------------
INSERT INTO "public"."sys_post" VALUES (2, 'se', '项目经理', 2, '0', 'admin', '2021-05-26 18:56:28', '', NULL, '');
INSERT INTO "public"."sys_post" VALUES (3, 'hr', '人力资源', 3, '0', 'admin', '2021-05-26 18:56:28', '', NULL, '');
INSERT INTO "public"."sys_post" VALUES (4, 'user', '普通员工', 4, '0', 'admin', '2021-05-26 18:56:28', '', NULL, '');
INSERT INTO "public"."sys_post" VALUES (1, 'ceo', '董事长', 1, '0', 'admin', '2021-05-26 18:56:28', 'admin', '2021-05-27 09:07:17.160973', '');

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_role";
CREATE TABLE "public"."sys_role" (
                                     "role_id" bigserial,
                                     "role_name" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
                                     "role_key" varchar(100) COLLATE "pg_catalog"."default" NOT NULL,
                                     "role_sort" int4 NOT NULL,
                                     "data_scope" char(1) COLLATE "pg_catalog"."default",
                                     "menu_check_strictly" bool,
                                     "dept_check_strictly" bool,
                                     "status" char(1) COLLATE "pg_catalog"."default" NOT NULL,
                                     "del_flag" char(1) COLLATE "pg_catalog"."default" DEFAULT 0,
                                     "create_by" varchar(64) COLLATE "pg_catalog"."default",
                                     "create_time" timestamp(6),
                                     "update_by" varchar(64) COLLATE "pg_catalog"."default",
                                     "update_time" timestamp(6),
                                     "remark" varchar(500) COLLATE "pg_catalog"."default"
)
;
COMMENT ON COLUMN "public"."sys_role"."role_id" IS '角色ID';
COMMENT ON COLUMN "public"."sys_role"."role_name" IS '角色名称';
COMMENT ON COLUMN "public"."sys_role"."role_key" IS '角色权限字符串';
COMMENT ON COLUMN "public"."sys_role"."role_sort" IS '显示顺序';
COMMENT ON COLUMN "public"."sys_role"."data_scope" IS '数据范围（1：全部数据权限 2：自定数据权限 3：本部门数据权限 4：本部门及以下数据权限）';
COMMENT ON COLUMN "public"."sys_role"."menu_check_strictly" IS '菜单树选择项是否关联显示';
COMMENT ON COLUMN "public"."sys_role"."dept_check_strictly" IS '部门树选择项是否关联显示';
COMMENT ON COLUMN "public"."sys_role"."status" IS '角色状态（0正常 1停用）';
COMMENT ON COLUMN "public"."sys_role"."del_flag" IS '删除标志（0代表存在 2代表删除）';
COMMENT ON COLUMN "public"."sys_role"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_role"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_role"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_role"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_role"."remark" IS '备注';
COMMENT ON TABLE "public"."sys_role" IS '角色信息表';

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO "public"."sys_role" VALUES (1, '超级管理员', 'admin', 1, '1', 't', 't', '0', '0', 'admin', '2021-05-26 18:56:28', '', NULL, '超级管理员');
INSERT INTO "public"."sys_role" VALUES (2, '普通角色', 'common', 2, '2', 'f', 'f', '0', '0', 'admin', '2021-05-26 18:56:28', 'admin', '2021-05-27 09:55:51.961721', '普通角色');

-- ----------------------------
-- Table structure for sys_role_dept
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_role_dept";
CREATE TABLE "public"."sys_role_dept" (
                                          "role_id" int8 NOT NULL,
                                          "dept_id" int8 NOT NULL
)
;
COMMENT ON COLUMN "public"."sys_role_dept"."role_id" IS '角色ID';
COMMENT ON COLUMN "public"."sys_role_dept"."dept_id" IS '部门ID';
COMMENT ON TABLE "public"."sys_role_dept" IS '角色和部门关联表';

-- ----------------------------
-- Records of sys_role_dept
-- ----------------------------
INSERT INTO "public"."sys_role_dept" VALUES (2, 100);
INSERT INTO "public"."sys_role_dept" VALUES (2, 101);
INSERT INTO "public"."sys_role_dept" VALUES (2, 105);

-- ----------------------------
-- Table structure for sys_role_menu
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_role_menu";
CREATE TABLE "public"."sys_role_menu" (
                                          "role_id" int8 NOT NULL,
                                          "menu_id" int8 NOT NULL
)
;
COMMENT ON COLUMN "public"."sys_role_menu"."role_id" IS '角色ID';
COMMENT ON COLUMN "public"."sys_role_menu"."menu_id" IS '菜单ID';
COMMENT ON TABLE "public"."sys_role_menu" IS '角色和菜单关联表';

-- ----------------------------
-- Records of sys_role_menu
-- ----------------------------
INSERT INTO "public"."sys_role_menu" VALUES (2, 1);
INSERT INTO "public"."sys_role_menu" VALUES (2, 100);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1001);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1002);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1003);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1004);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1005);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1006);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1007);
INSERT INTO "public"."sys_role_menu" VALUES (2, 101);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1008);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1009);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1010);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1011);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1012);
INSERT INTO "public"."sys_role_menu" VALUES (2, 102);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1013);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1014);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1015);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1016);
INSERT INTO "public"."sys_role_menu" VALUES (2, 103);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1017);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1018);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1019);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1020);
INSERT INTO "public"."sys_role_menu" VALUES (2, 104);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1021);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1022);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1023);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1024);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1025);
INSERT INTO "public"."sys_role_menu" VALUES (2, 105);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1026);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1027);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1028);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1029);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1030);
INSERT INTO "public"."sys_role_menu" VALUES (2, 106);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1031);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1032);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1033);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1034);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1035);
INSERT INTO "public"."sys_role_menu" VALUES (2, 107);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1036);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1037);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1038);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1039);
INSERT INTO "public"."sys_role_menu" VALUES (2, 108);
INSERT INTO "public"."sys_role_menu" VALUES (2, 500);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1040);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1041);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1042);
INSERT INTO "public"."sys_role_menu" VALUES (2, 501);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1043);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1044);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1045);
INSERT INTO "public"."sys_role_menu" VALUES (2, 2);
INSERT INTO "public"."sys_role_menu" VALUES (2, 109);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1046);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1047);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1048);
INSERT INTO "public"."sys_role_menu" VALUES (2, 110);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1049);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1050);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1051);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1052);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1053);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1054);
INSERT INTO "public"."sys_role_menu" VALUES (2, 111);
INSERT INTO "public"."sys_role_menu" VALUES (2, 112);
INSERT INTO "public"."sys_role_menu" VALUES (2, 113);
INSERT INTO "public"."sys_role_menu" VALUES (2, 3);
INSERT INTO "public"."sys_role_menu" VALUES (2, 114);
INSERT INTO "public"."sys_role_menu" VALUES (2, 115);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1055);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1058);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1056);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1057);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1059);
INSERT INTO "public"."sys_role_menu" VALUES (2, 1060);
INSERT INTO "public"."sys_role_menu" VALUES (2, 116);
-- INSERT INTO "public"."sys_role_menu" VALUES (2, 4);

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_user";
CREATE TABLE "public"."sys_user" (
                                     "user_id" bigserial,
                                     "dept_id" int8,
                                     "user_name" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
                                     "nick_name" varchar(30) COLLATE "pg_catalog"."default" NOT NULL,
                                     "user_type" varchar(2) COLLATE "pg_catalog"."default",
                                     "email" varchar(50) COLLATE "pg_catalog"."default",
                                     "phonenumber" varchar(11) COLLATE "pg_catalog"."default",
                                     "sex" char(1) COLLATE "pg_catalog"."default",
                                     "avatar" varchar(100) COLLATE "pg_catalog"."default",
                                     "password" varchar(100) COLLATE "pg_catalog"."default",
                                     "status" char(1) COLLATE "pg_catalog"."default",
                                     "del_flag" char(1) default '0',
                                     "login_ip" varchar(128) COLLATE "pg_catalog"."default",
                                     "login_date" timestamp(6),
                                     "create_by" varchar(64) COLLATE "pg_catalog"."default",
                                     "create_time" timestamp(6),
                                     "update_by" varchar(64) COLLATE "pg_catalog"."default",
                                     "update_time" timestamp(6),
                                     "remark" varchar(500) COLLATE "pg_catalog"."default"
)
;
COMMENT ON COLUMN "public"."sys_user"."user_id" IS '用户ID';
COMMENT ON COLUMN "public"."sys_user"."dept_id" IS '部门ID';
COMMENT ON COLUMN "public"."sys_user"."user_name" IS '用户账号';
COMMENT ON COLUMN "public"."sys_user"."nick_name" IS '用户昵称';
COMMENT ON COLUMN "public"."sys_user"."user_type" IS '用户类型（00系统用户）';
COMMENT ON COLUMN "public"."sys_user"."email" IS '用户邮箱';
COMMENT ON COLUMN "public"."sys_user"."phonenumber" IS '手机号码';
COMMENT ON COLUMN "public"."sys_user"."sex" IS '用户性别（0男 1女 2未知）';
COMMENT ON COLUMN "public"."sys_user"."avatar" IS '头像地址';
COMMENT ON COLUMN "public"."sys_user"."password" IS '密码';
COMMENT ON COLUMN "public"."sys_user"."status" IS '帐号状态（0正常 1停用）';
COMMENT ON COLUMN "public"."sys_user"."del_flag" IS '删除标志（0代表存在 2代表删除）';
COMMENT ON COLUMN "public"."sys_user"."login_ip" IS '最后登录IP';
COMMENT ON COLUMN "public"."sys_user"."login_date" IS '最后登录时间';
COMMENT ON COLUMN "public"."sys_user"."create_by" IS '创建者';
COMMENT ON COLUMN "public"."sys_user"."create_time" IS '创建时间';
COMMENT ON COLUMN "public"."sys_user"."update_by" IS '更新者';
COMMENT ON COLUMN "public"."sys_user"."update_time" IS '更新时间';
COMMENT ON COLUMN "public"."sys_user"."remark" IS '备注';
COMMENT ON TABLE "public"."sys_user" IS '用户信息表';

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO "public"."sys_user" VALUES (2, 105, 'ry', '猫头虎', '00', 'ry@qq.com', '15666666666', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', '2021-05-26 18:56:28', 'admin', '2021-05-26 18:56:28', 'admin', '2021-05-27 09:55:37.595036', '测试员');
INSERT INTO "public"."sys_user" VALUES (1, 103, 'admin', '猫头虎', '00', 'ry@163.com', '15888888888', '1', '', '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE8ByOhJIrdAu2', '0', '0', '127.0.0.1', '2021-05-27 10:21:19.689', 'admin', '2021-05-26 18:56:28', '', '2021-05-27 10:21:19.694616', '管理员');

-- ----------------------------
-- Table structure for sys_user_post
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_user_post";
CREATE TABLE "public"."sys_user_post" (
                                          "user_id" int8 NOT NULL,
                                          "post_id" int8 NOT NULL
)
;
COMMENT ON COLUMN "public"."sys_user_post"."user_id" IS '用户ID';
COMMENT ON COLUMN "public"."sys_user_post"."post_id" IS '岗位ID';
COMMENT ON TABLE "public"."sys_user_post" IS '用户与岗位关联表';

-- ----------------------------
-- Records of sys_user_post
-- ----------------------------
INSERT INTO "public"."sys_user_post" VALUES (1, 1);
INSERT INTO "public"."sys_user_post" VALUES (2, 2);

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS "public"."sys_user_role";
CREATE TABLE "public"."sys_user_role" (
                                          "user_id" int8 NOT NULL,
                                          "role_id" int8 NOT NULL
)
;
COMMENT ON COLUMN "public"."sys_user_role"."user_id" IS '用户ID';
COMMENT ON COLUMN "public"."sys_user_role"."role_id" IS '角色ID';
COMMENT ON TABLE "public"."sys_user_role" IS '用户和角色关联表';

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
INSERT INTO "public"."sys_user_role" VALUES (1, 1);
INSERT INTO "public"."sys_user_role" VALUES (2, 2);

-- ----------------------------
-- Primary Key structure for table gen_table
-- ----------------------------
ALTER TABLE "public"."gen_table" ADD CONSTRAINT "gen_table_pkey" PRIMARY KEY ("table_id");

-- ----------------------------
-- Primary Key structure for table gen_table_column
-- ----------------------------
ALTER TABLE "public"."gen_table_column" ADD CONSTRAINT "gen_table_column_pkey" PRIMARY KEY ("column_id");

-- ----------------------------
-- Primary Key structure for table qrtz_blob_triggers
-- ----------------------------
ALTER TABLE "public"."qrtz_blob_triggers" ADD CONSTRAINT "QRTZ_BLOB_TRIGGERS_pkey" PRIMARY KEY ("sched_name", "trigger_name", "trigger_group");

-- ----------------------------
-- Primary Key structure for table qrtz_calendars
-- ----------------------------
ALTER TABLE "public"."qrtz_calendars" ADD CONSTRAINT "QRTZ_CALENDARS_pkey" PRIMARY KEY ("sched_name", "calendar_name");

-- ----------------------------
-- Primary Key structure for table qrtz_cron_triggers
-- ----------------------------
ALTER TABLE "public"."qrtz_cron_triggers" ADD CONSTRAINT "QRTZ_CRON_TRIGGERS_pkey" PRIMARY KEY ("sched_name", "trigger_name", "trigger_group");

-- ----------------------------
-- Primary Key structure for table qrtz_fired_triggers
-- ----------------------------
ALTER TABLE "public"."qrtz_fired_triggers" ADD CONSTRAINT "QRTZ_FIRED_TRIGGERS_pkey" PRIMARY KEY ("sched_name", "entry_id");

-- ----------------------------
-- Primary Key structure for table qrtz_job_details
-- ----------------------------
ALTER TABLE "public"."qrtz_job_details" ADD CONSTRAINT "QRTZ_JOB_DETAILS_pkey" PRIMARY KEY ("sched_name", "job_name", "job_group");

-- ----------------------------
-- Primary Key structure for table qrtz_locks
-- ----------------------------
ALTER TABLE "public"."qrtz_locks" ADD CONSTRAINT "QRTZ_LOCKS_pkey" PRIMARY KEY ("sched_name", "lock_name");

-- ----------------------------
-- Primary Key structure for table qrtz_paused_trigger_grps
-- ----------------------------
ALTER TABLE "public"."qrtz_paused_trigger_grps" ADD CONSTRAINT "QRTZ_PAUSED_TRIGGER_GRPS_pkey" PRIMARY KEY ("sched_name", "trigger_group");

-- ----------------------------
-- Primary Key structure for table qrtz_scheduler_state
-- ----------------------------
ALTER TABLE "public"."qrtz_scheduler_state" ADD CONSTRAINT "QRTZ_SCHEDULER_STATE_pkey" PRIMARY KEY ("sched_name", "instance_name");

-- ----------------------------
-- Primary Key structure for table qrtz_simple_triggers
-- ----------------------------
ALTER TABLE "public"."qrtz_simple_triggers" ADD CONSTRAINT "QRTZ_SIMPLE_TRIGGERS_pkey" PRIMARY KEY ("sched_name", "trigger_name", "trigger_group");

-- ----------------------------
-- Primary Key structure for table qrtz_simprop_triggers
-- ----------------------------
ALTER TABLE "public"."qrtz_simprop_triggers" ADD CONSTRAINT "QRTZ_SIMPROP_TRIGGERS_pkey" PRIMARY KEY ("sched_name", "trigger_name", "trigger_group");

-- ----------------------------
-- Indexes structure for table qrtz_triggers
-- ----------------------------
CREATE INDEX "sched_name" ON "public"."qrtz_triggers" USING btree (
                                                                   "sched_name" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST,
                                                                   "job_name" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST,
                                                                   "job_group" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
    );

-- ----------------------------
-- Primary Key structure for table qrtz_triggers
-- ----------------------------
ALTER TABLE "public"."qrtz_triggers" ADD CONSTRAINT "QRTZ_TRIGGERS_pkey" PRIMARY KEY ("sched_name", "trigger_name", "trigger_group");

-- ----------------------------
-- Primary Key structure for table sys_config
-- ----------------------------
ALTER TABLE "public"."sys_config" ADD CONSTRAINT "sys_config_pkey" PRIMARY KEY ("config_id");

-- ----------------------------
-- Primary Key structure for table sys_dept
-- ----------------------------
ALTER TABLE "public"."sys_dept" ADD CONSTRAINT "sys_dept_pkey" PRIMARY KEY ("dept_id");

-- ----------------------------
-- Primary Key structure for table __data
-- ----------------------------
ALTER TABLE "public"."sys_dict_data" ADD CONSTRAINT "sys_dict_data_pkey" PRIMARY KEY ("dict_code");

-- ----------------------------
-- Indexes structure for table sys_dict_type
-- ----------------------------
CREATE INDEX "dict_type" ON "public"."sys_dict_type" USING btree (
                                                                  "dict_type" COLLATE "pg_catalog"."default" "pg_catalog"."text_ops" ASC NULLS LAST
    );

-- ----------------------------
-- Primary Key structure for table sys_dict_type
-- ----------------------------
ALTER TABLE "public"."sys_dict_type" ADD CONSTRAINT "sys_dict_type_pkey" PRIMARY KEY ("dict_id");

-- ----------------------------
-- Primary Key structure for table sys_job
-- ----------------------------
ALTER TABLE "public"."sys_job" ADD CONSTRAINT "sys_job_pkey" PRIMARY KEY ("job_id", "job_name", "job_group");

-- ----------------------------
-- Primary Key structure for table sys_job_log
-- ----------------------------
ALTER TABLE "public"."sys_job_log" ADD CONSTRAINT "sys_job_log_pkey" PRIMARY KEY ("job_log_id");

-- ----------------------------
-- Primary Key structure for table sys_logininfor
-- ----------------------------
ALTER TABLE "public"."sys_logininfor" ADD CONSTRAINT "sys_logininfor_pkey" PRIMARY KEY ("info_id");

-- ----------------------------
-- Primary Key structure for table sys_menu
-- ----------------------------
ALTER TABLE "public"."sys_menu" ADD CONSTRAINT "sys_menu_pkey" PRIMARY KEY ("menu_id");

-- ----------------------------
-- Primary Key structure for table sys_notice
-- ----------------------------
ALTER TABLE "public"."sys_notice" ADD CONSTRAINT "sys_notice_pkey" PRIMARY KEY ("notice_id");

-- ----------------------------
-- Primary Key structure for table sys_oper_log
-- ----------------------------
ALTER TABLE "public"."sys_oper_log" ADD CONSTRAINT "sys_oper_log_pkey" PRIMARY KEY ("oper_id");

-- ----------------------------
-- Primary Key structure for table sys_post
-- ----------------------------
ALTER TABLE "public"."sys_post" ADD CONSTRAINT "sys_post_pkey" PRIMARY KEY ("post_id");

-- ----------------------------
-- Primary Key structure for table sys_role
-- ----------------------------
ALTER TABLE "public"."sys_role" ADD CONSTRAINT "sys_role_pkey" PRIMARY KEY ("role_id");

-- ----------------------------
-- Primary Key structure for table sys_role_dept
-- ----------------------------
ALTER TABLE "public"."sys_role_dept" ADD CONSTRAINT "sys_role_dept_pkey" PRIMARY KEY ("role_id", "dept_id");

-- ----------------------------
-- Primary Key structure for table sys_role_menu
-- ----------------------------
ALTER TABLE "public"."sys_role_menu" ADD CONSTRAINT "sys_role_menu_pkey" PRIMARY KEY ("role_id", "menu_id");

-- ----------------------------
-- Primary Key structure for table sys_user
-- ----------------------------
ALTER TABLE "public"."sys_user" ADD CONSTRAINT "sys_user_pkey" PRIMARY KEY ("user_id");

-- ----------------------------
-- Primary Key structure for table sys_user_post
-- ----------------------------
ALTER TABLE "public"."sys_user_post" ADD CONSTRAINT "sys_user_post_pkey" PRIMARY KEY ("user_id", "post_id");

-- ----------------------------
-- Primary Key structure for table sys_user_role
-- ----------------------------
ALTER TABLE "public"."sys_user_role" ADD CONSTRAINT "sys_user_role_pkey" PRIMARY KEY ("user_id", "role_id");

-- ----------------------------
-- Foreign Keys structure for table qrtz_blob_triggers
-- ----------------------------
ALTER TABLE "public"."qrtz_blob_triggers" ADD CONSTRAINT "QRTZ_BLOB_TRIGGERS_ibfk_1" FOREIGN KEY ("sched_name", "trigger_name", "trigger_group") REFERENCES "public"."qrtz_triggers" ("sched_name", "trigger_name", "trigger_group") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table qrtz_cron_triggers
-- ----------------------------
ALTER TABLE "public"."qrtz_cron_triggers" ADD CONSTRAINT "QRTZ_CRON_TRIGGERS_ibfk_1" FOREIGN KEY ("sched_name", "trigger_name", "trigger_group") REFERENCES "public"."qrtz_triggers" ("sched_name", "trigger_name", "trigger_group") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table qrtz_simple_triggers
-- ----------------------------
ALTER TABLE "public"."qrtz_simple_triggers" ADD CONSTRAINT "QRTZ_SIMPLE_TRIGGERS_ibfk_1" FOREIGN KEY ("sched_name", "trigger_name", "trigger_group") REFERENCES "public"."qrtz_triggers" ("sched_name", "trigger_name", "trigger_group") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table qrtz_simprop_triggers
-- ----------------------------
ALTER TABLE "public"."qrtz_simprop_triggers" ADD CONSTRAINT "QRTZ_SIMPROP_TRIGGERS_ibfk_1" FOREIGN KEY ("sched_name", "trigger_name", "trigger_group") REFERENCES "public"."qrtz_triggers" ("sched_name", "trigger_name", "trigger_group") ON DELETE NO ACTION ON UPDATE NO ACTION;

-- ----------------------------
-- Foreign Keys structure for table qrtz_triggers
-- ----------------------------
ALTER TABLE "public"."qrtz_triggers" ADD CONSTRAINT "QRTZ_TRIGGERS_ibfk_1" FOREIGN KEY ("sched_name", "job_name", "job_group") REFERENCES "public"."qrtz_job_details" ("sched_name", "job_name", "job_group") ON DELETE NO ACTION ON UPDATE NO ACTION;



CREATE OR REPLACE FUNCTION "public"."find_in_set"(int8, varchar)
    RETURNS "pg_catalog"."bool" AS $BODY$
DECLARE
    STR ALIAS FOR $1;
    STRS ALIAS FOR $2;
    POS INTEGER;
    STATUS BOOLEAN;
BEGIN
    SELECT POSITION( ','||STR||',' IN ','||STRS||',') INTO POS;
    IF POS > 0 THEN
        STATUS = TRUE;
    ELSE
        STATUS = FALSE;
    END IF;
    RETURN STATUS;
END;
$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;


alter sequence sys_user_user_id_seq  restart  3;
alter sequence sys_config_config_id_seq  restart  100;
alter sequence sys_dept_dept_id_seq  restart  110;
alter sequence sys_dict_data_dict_code_seq  restart  29;
alter sequence sys_dict_type_dict_id_seq  restart  11;
alter sequence sys_job_job_id_seq  restart  4;
alter sequence sys_menu_menu_id_seq  restart  2000;
alter sequence sys_notice_notice_id_seq  restart  3;
alter sequence sys_post_post_id_seq  restart  5;
alter sequence sys_role_role_id_seq  restart  3;

-- #############################################################################
-- 第二部分 · 代码生成器视图与 substring_index
-- #############################################################################

DROP VIEW IF EXISTS list_column;
DROP VIEW IF EXISTS list_table;

create view list_column as
SELECT c.relname                                                                           AS table_name,
       a.attname                                                                           AS column_name,
       d.description                                                                       AS column_comment,
       CASE
           WHEN a.attnotnull AND con.conname IS NULL THEN 1
           ELSE 0
           END                                                                             AS is_required,
       CASE
           WHEN con.conname IS NOT NULL THEN 1
           ELSE 0
           END                                                                             AS is_pk,
       a.attnum                                                                            AS sort,
       CASE
           WHEN "position"(pg_get_expr(ad.adbin, ad.adrelid), ((c.relname::text || '_'::text) || a.attname
                           ::text) || '_seq'::text) > 0 THEN 1
           ELSE 0
           END                                                                             AS is_increment,
       btrim(
                   CASE
                       WHEN t.typelem <> 0::oid AND t.typlen = '-1'::integer THEN 'ARRAY'::text
            ELSE
            CASE
                WHEN t.typtype = 'd'::"char" THEN format_type(t.typbasetype, NULL::integer)
                ELSE format_type(a.atttypid, NULL::integer)
            END
        END, '"'::text) AS column_type
FROM pg_attribute a
         JOIN (pg_class c
    JOIN pg_namespace n ON c.relnamespace = n.oid) ON a.attrelid = c.oid
         LEFT JOIN pg_description d ON d.objoid = c.oid AND a.attnum = d.objsubid
         LEFT JOIN pg_constraint con ON con.conrelid = c.oid AND (a.attnum = ANY (con.conkey))
         LEFT JOIN pg_attrdef ad ON a.attrelid = ad.adrelid AND a.attnum = ad.adnum
         LEFT JOIN pg_type t ON a.atttypid = t.oid
WHERE (c.relkind = ANY (ARRAY['r'::"char", 'p'::"char"]))
  AND a.attnum > 0
  AND n.nspname = 'public'::name
  AND not a.attisdropped
  ORDER BY c.relname, a.attnum;

create view list_table as
SELECT c.relname              AS table_name,
       obj_description(c.oid) AS table_comment,
       CURRENT_TIMESTAMP      AS create_time,
       CURRENT_TIMESTAMP      AS update_time
FROM pg_class c
         LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE (c.relkind = ANY (ARRAY['r'::"char", 'p'::"char"]))
  AND c.relname !~~ 'spatial_%'::text AND n.nspname = 'public'::name AND n.nspname <> ''::name;

CREATE OR REPLACE FUNCTION substring_index(varchar, varchar, integer)
RETURNS varchar AS $$
DECLARE
tokens varchar[];
length integer ;
indexnum integer;
BEGIN
tokens := pg_catalog.string_to_array($1, $2);
length := pg_catalog.array_upper(tokens, 1);
indexnum := length - ($3 * -1) + 1;
IF $3 >= 0 THEN
RETURN pg_catalog.array_to_string(tokens[1:$3], $2);
ELSE
RETURN pg_catalog.array_to_string(tokens[indexnum:length], $2);
END IF;
END;
$$ IMMUTABLE STRICT LANGUAGE PLPGSQL;

-- #############################################################################
-- 第三部分 · 护理业务表 + 种子（角色/字典/菜单/疫苗/清单/知识库/RustFS）
-- #############################################################################

BEGIN;

-- =============================================================================
-- 护理业务表 + 种子（角色 / 字典 / 菜单 / 疫苗 / 清单 / 知识库 / RustFS）
-- 账号仍用新生儿护理工作台 sys_user / sys_role。不预置任何宝宝数据。
-- =============================================================================


-- ---------------------------------------------------------------------------
-- 1. 宝宝档案
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS nc_baby CASCADE;
CREATE TABLE nc_baby (
    baby_id          bigserial      PRIMARY KEY,
    baby_name        varchar(50)    NOT NULL,
    nickname         varchar(50),
    gender           char(1)        DEFAULT '2',          -- 0男 1女 2未知，字典 sys_user_sex
    birth_date       date           NOT NULL,
    birth_weight_kg  numeric(6,3),
    birth_height_cm  numeric(5,1),
    birth_head_cm    numeric(5,1),
    mom_user_id      int8           NOT NULL,            -- 必须绑定妈妈账号（sys_user.user_id）
    mom_user_name    varchar(30)    NOT NULL,            -- 冗余登录名，便于超管复核
    media_dir        varchar(200)   NOT NULL,            -- RustFS 隔离目录，如 baby/{id}/
    status           char(1)        DEFAULT '0',         -- 0正常 1停用
    del_flag         char(1)        DEFAULT '0',         -- 0存在 2删除
    rev              int4           DEFAULT 1 NOT NULL,  -- 乐观锁版本
    create_by        varchar(64)    DEFAULT '',
    create_time      timestamp(6)   DEFAULT current_timestamp,
    update_by        varchar(64)    DEFAULT '',
    update_time      timestamp(6),
    remark           varchar(500)
);
COMMENT ON TABLE  nc_baby IS '宝宝档案（超管创建时必须指定妈妈）';
COMMENT ON COLUMN nc_baby.mom_user_id IS '妈妈账号 user_id；二胎场景同一妈妈可绑定多个宝宝';
COMMENT ON COLUMN nc_baby.media_dir   IS '该宝宝在 RustFS/OBS 上的独立媒体目录';
COMMENT ON COLUMN nc_baby.rev         IS '乐观锁版本，客户端提交时携带 baseRev，冲突返回 409';

CREATE INDEX idx_nc_baby_mom ON nc_baby (mom_user_id) WHERE del_flag = '0';

-- ---------------------------------------------------------------------------
-- 2. 家庭成员（宝宝 ↔ 账号）
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS nc_baby_member CASCADE;
CREATE TABLE nc_baby_member (
    member_id        bigserial      PRIMARY KEY,
    baby_id          int8           NOT NULL REFERENCES nc_baby (baby_id),
    user_id          int8           NOT NULL,            -- sys_user.user_id
    role_tag         varchar(20)    NOT NULL,            -- mom/dad/grandma/maternal_grandma/nanny/other
    display_name     varchar(30)    NOT NULL,            -- 家庭内称呼
    status           char(1)        DEFAULT '0',         -- 0正常 1停用（停用不删，历史仍显示姓名）
    last_heartbeat   timestamp(6),                       -- 在线心跳，约每 20 秒；超过约 45 秒视为离线
    create_by        varchar(64)    DEFAULT '',
    create_time      timestamp(6)   DEFAULT current_timestamp,
    update_by        varchar(64)    DEFAULT '',
    update_time      timestamp(6),
    remark           varchar(500),
    CONSTRAINT uk_nc_baby_member UNIQUE (baby_id, user_id)
);
COMMENT ON TABLE  nc_baby_member IS '宝宝家庭成员；服务端必须按此表校验跨宝宝 403';
COMMENT ON COLUMN nc_baby_member.role_tag IS '家庭角色标签，字典 nc_family_role';
COMMENT ON COLUMN nc_baby_member.last_heartbeat IS '页面心跳时间，用于「谁正在照顾宝宝」';

CREATE INDEX idx_nc_baby_member_user ON nc_baby_member (user_id);
CREATE INDEX idx_nc_baby_member_online ON nc_baby_member (baby_id, last_heartbeat);

-- ---------------------------------------------------------------------------
-- 3. 通用编辑锁（5 分钟过期，心跳续期）
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS nc_record_lock CASCADE;
CREATE TABLE nc_record_lock (
    lock_id          bigserial      PRIMARY KEY,
    baby_id          int8           NOT NULL REFERENCES nc_baby (baby_id),
    module_code      varchar(30)    NOT NULL,            -- feeding/sleep/diaper/cry/health/growth/media
    record_id        int8           NOT NULL,
    locker_user_id   int8           NOT NULL,
    locker_name      varchar(30)    NOT NULL,
    expire_time      timestamp(6)   NOT NULL,
    heartbeat_time   timestamp(6)   DEFAULT current_timestamp,
    CONSTRAINT uk_nc_record_lock UNIQUE (module_code, record_id)
);
COMMENT ON TABLE nc_record_lock IS '记录级编辑锁；他人打开提示占用者姓名';

CREATE INDEX idx_nc_record_lock_expire ON nc_record_lock (expire_time);

-- ---------------------------------------------------------------------------
-- 4. 喂养（含拍嗝）
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS nc_feeding CASCADE;
CREATE TABLE nc_feeding (
    feeding_id       bigserial      PRIMARY KEY,
    baby_id          int8           NOT NULL REFERENCES nc_baby (baby_id),
    feed_time        timestamp(6)   NOT NULL,
    feed_method      varchar(20)    NOT NULL,            -- breast/bottle_breast/formula/mixed/solid
    amount_ml        numeric(6,1),
    duration_min     int4,
    left_duration    int4,
    right_duration   int4,
    burped           char(1)        DEFAULT '0',         -- 0未拍嗝 1已拍嗝
    burp_duration    int4,
    burp_effect      varchar(20),                        -- good/partial/none
    after_behavior   varchar(50),
    notes            varchar(500),
    operator_id      int8           NOT NULL,
    operator_name    varchar(30)    NOT NULL,
    rev              int4           DEFAULT 1 NOT NULL,
    del_flag         char(1)        DEFAULT '0',
    create_by        varchar(64)    DEFAULT '',
    create_time      timestamp(6)   DEFAULT current_timestamp,
    update_by        varchar(64)    DEFAULT '',
    update_by_name   varchar(30),
    update_time      timestamp(6),
    remark           varchar(500)
);
COMMENT ON TABLE nc_feeding IS '喂养记录（含拍嗝）';

CREATE INDEX idx_nc_feeding_baby_time ON nc_feeding (baby_id, feed_time DESC) WHERE del_flag = '0';

-- ---------------------------------------------------------------------------
-- 5. 睡眠
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS nc_sleep CASCADE;
CREATE TABLE nc_sleep (
    sleep_id         bigserial      PRIMARY KEY,
    baby_id          int8           NOT NULL REFERENCES nc_baby (baby_id),
    start_time       timestamp(6)   NOT NULL,
    end_time         timestamp(6),
    sleep_type       varchar(10)    NOT NULL,            -- night 夜间 / nap 白天小睡
    duration_min     int4,                               -- 由起止时间计算后落库，便于统计
    notes            varchar(500),
    operator_id      int8           NOT NULL,
    operator_name    varchar(30)    NOT NULL,
    rev              int4           DEFAULT 1 NOT NULL,
    del_flag         char(1)        DEFAULT '0',
    create_by        varchar(64)    DEFAULT '',
    create_time      timestamp(6)   DEFAULT current_timestamp,
    update_by        varchar(64)    DEFAULT '',
    update_by_name   varchar(30),
    update_time      timestamp(6),
    remark           varchar(500)
);
COMMENT ON TABLE nc_sleep IS '睡眠记录';

CREATE INDEX idx_nc_sleep_baby_time ON nc_sleep (baby_id, start_time DESC) WHERE del_flag = '0';

-- ---------------------------------------------------------------------------
-- 6. 尿布 / 排泄
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS nc_diaper CASCADE;
CREATE TABLE nc_diaper (
    diaper_id        bigserial      PRIMARY KEY,
    baby_id          int8           NOT NULL REFERENCES nc_baby (baby_id),
    record_time      timestamp(6)   NOT NULL,
    diaper_type      varchar(10)    NOT NULL,            -- pee / poop / both
    stool_texture    varchar(20),                        -- normal/watery/bloody/mucus/other
    notes            varchar(500),
    operator_id      int8           NOT NULL,
    operator_name    varchar(30)    NOT NULL,
    rev              int4           DEFAULT 1 NOT NULL,
    del_flag         char(1)        DEFAULT '0',
    create_by        varchar(64)    DEFAULT '',
    create_time      timestamp(6)   DEFAULT current_timestamp,
    update_by        varchar(64)    DEFAULT '',
    update_by_name   varchar(30),
    update_time      timestamp(6),
    remark           varchar(500)
);
COMMENT ON TABLE nc_diaper IS '尿布与排泄记录';

CREATE INDEX idx_nc_diaper_baby_time ON nc_diaper (baby_id, record_time DESC) WHERE del_flag = '0';

-- ---------------------------------------------------------------------------
-- 7. 哭闹 / 安抚
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS nc_cry CASCADE;
CREATE TABLE nc_cry (
    cry_id           bigserial      PRIMARY KEY,
    baby_id          int8           NOT NULL REFERENCES nc_baby (baby_id),
    start_time       timestamp(6)   NOT NULL,
    end_time         timestamp(6),
    intensity        varchar(10)    NOT NULL,            -- mild/medium/severe
    possible_cause   varchar(100),
    soothe_methods   varchar(200),                       -- 逗号分隔多选
    soothe_effect    varchar(20),                        -- effective/partial/none
    notes            varchar(500),
    operator_id      int8           NOT NULL,
    operator_name    varchar(30)    NOT NULL,
    rev              int4           DEFAULT 1 NOT NULL,
    del_flag         char(1)        DEFAULT '0',
    create_by        varchar(64)    DEFAULT '',
    create_time      timestamp(6)   DEFAULT current_timestamp,
    update_by        varchar(64)    DEFAULT '',
    update_by_name   varchar(30),
    update_time      timestamp(6),
    remark           varchar(500)
);
COMMENT ON TABLE nc_cry IS '哭闹与安抚记录';

CREATE INDEX idx_nc_cry_baby_time ON nc_cry (baby_id, start_time DESC) WHERE del_flag = '0';

-- ---------------------------------------------------------------------------
-- 8. 日常护理清单（内置项 baby_id 为空；自定义项绑定宝宝）
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS nc_care_item CASCADE;
CREATE TABLE nc_care_item (
    item_id          bigserial      PRIMARY KEY,
    baby_id          int8           REFERENCES nc_baby (baby_id),
    item_name        varchar(50)    NOT NULL,
    is_builtin       char(1)        DEFAULT '0',         -- 1内置模板 0自定义
    sort_num         int4           DEFAULT 0,
    status           char(1)        DEFAULT '0',
    del_flag         char(1)        DEFAULT '0',
    create_by        varchar(64)    DEFAULT '',
    create_time      timestamp(6)   DEFAULT current_timestamp,
    update_by        varchar(64)    DEFAULT '',
    update_time      timestamp(6),
    remark           varchar(500)
);
COMMENT ON TABLE nc_care_item IS '护理清单事项；baby_id 为空表示系统内置模板';

CREATE INDEX idx_nc_care_item_baby ON nc_care_item (baby_id);

DROP TABLE IF EXISTS nc_care_log CASCADE;
CREATE TABLE nc_care_log (
    log_id           bigserial      PRIMARY KEY,
    baby_id          int8           NOT NULL REFERENCES nc_baby (baby_id),
    item_id          int8           NOT NULL REFERENCES nc_care_item (item_id),
    care_date        date           NOT NULL,
    completed        char(1)        DEFAULT '0',
    complete_time    timestamp(6),
    operator_id      int8,
    operator_name    varchar(30),
    create_time      timestamp(6)   DEFAULT current_timestamp,
    update_time      timestamp(6),
    CONSTRAINT uk_nc_care_log UNIQUE (baby_id, item_id, care_date)
);
COMMENT ON TABLE nc_care_log IS '护理清单每日完成记录；未完成项在仪表盘提醒';

CREATE INDEX idx_nc_care_log_date ON nc_care_log (baby_id, care_date, completed);

DROP TABLE IF EXISTS nc_care_hidden CASCADE;
CREATE TABLE nc_care_hidden (
    baby_id          int8           NOT NULL REFERENCES nc_baby (baby_id),
    item_id          int8           NOT NULL REFERENCES nc_care_item (item_id),
    create_time      timestamp(6)   DEFAULT current_timestamp,
    PRIMARY KEY (baby_id, item_id)
);
COMMENT ON TABLE nc_care_hidden IS '本宝宝已移除的护理事项；内置模板对其他宝宝仍可见';

-- ---------------------------------------------------------------------------
-- 9. 每日健康自检
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS nc_health_check CASCADE;
CREATE TABLE nc_health_check (
    check_id         bigserial      PRIMARY KEY,
    baby_id          int8           NOT NULL REFERENCES nc_baby (baby_id),
    check_date       date           NOT NULL,
    temp_am          numeric(4,1),
    temp_pm          numeric(4,1),
    jaundice         varchar(20),                        -- none/face/trunk/limbs/palms
    umbilical        varchar(20),                        -- dry/moist/ooze/red
    spirit           varchar(20),                        -- good/sleepy/irritable/lethargic
    notes            varchar(500),
    operator_id      int8           NOT NULL,
    operator_name    varchar(30)    NOT NULL,
    rev              int4           DEFAULT 1 NOT NULL,
    del_flag         char(1)        DEFAULT '0',
    create_by        varchar(64)    DEFAULT '',
    create_time      timestamp(6)   DEFAULT current_timestamp,
    update_by        varchar(64)    DEFAULT '',
    update_by_name   varchar(30),
    update_time      timestamp(6),
    remark           varchar(500),
    CONSTRAINT uk_nc_health_check UNIQUE (baby_id, check_date)
);
COMMENT ON TABLE nc_health_check IS '每日健康自检（体温/黄疸/脐带/精神）';

-- ---------------------------------------------------------------------------
-- 10. 疫苗时间表（系统种子）与接种记录
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS nc_vaccine_schedule CASCADE;
CREATE TABLE nc_vaccine_schedule (
    schedule_id      bigserial      PRIMARY KEY,
    vaccine_code     varchar(30)    NOT NULL,
    vaccine_name     varchar(80)    NOT NULL,
    dose_no          int4           NOT NULL,
    total_doses      int4           NOT NULL,
    due_age_days     int4           NOT NULL,            -- 出生后第几天到期
    remind_before    int4           DEFAULT 3,           -- 到期前几天提醒
    sort_num         int4           DEFAULT 0,
    remark           varchar(200)
);
COMMENT ON TABLE nc_vaccine_schedule IS '0-6 月龄国家免疫规划时间表（仅供参考）';

DROP TABLE IF EXISTS nc_vaccine_record CASCADE;
CREATE TABLE nc_vaccine_record (
    record_id        bigserial      PRIMARY KEY,
    baby_id          int8           NOT NULL REFERENCES nc_baby (baby_id),
    schedule_id      int8           NOT NULL REFERENCES nc_vaccine_schedule (schedule_id),
    inoculated       char(1)        DEFAULT '0',
    inoculate_date   date,
    operator_id      int8,
    operator_name    varchar(30),
    create_time      timestamp(6)   DEFAULT current_timestamp,
    update_time      timestamp(6),
    CONSTRAINT uk_nc_vaccine_record UNIQUE (baby_id, schedule_id)
);
COMMENT ON TABLE nc_vaccine_record IS '宝宝疫苗接种标记（可撤销）';

-- ---------------------------------------------------------------------------
-- 11. 生长记录
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS nc_growth CASCADE;
CREATE TABLE nc_growth (
    growth_id        bigserial      PRIMARY KEY,
    baby_id          int8           NOT NULL REFERENCES nc_baby (baby_id),
    measure_date     date           NOT NULL,
    weight_kg        numeric(6,3),
    height_cm        numeric(5,1),
    head_cm          numeric(5,1),
    notes            varchar(500),
    operator_id      int8           NOT NULL,
    operator_name    varchar(30)    NOT NULL,
    rev              int4           DEFAULT 1 NOT NULL,
    del_flag         char(1)        DEFAULT '0',
    create_by        varchar(64)    DEFAULT '',
    create_time      timestamp(6)   DEFAULT current_timestamp,
    update_by        varchar(64)    DEFAULT '',
    update_by_name   varchar(30),
    update_time      timestamp(6),
    remark           varchar(500)
);
COMMENT ON TABLE nc_growth IS '生长记录（体重/身长/头围）';

CREATE INDEX idx_nc_growth_baby_date ON nc_growth (baby_id, measure_date DESC) WHERE del_flag = '0';

-- ---------------------------------------------------------------------------
-- 12. 宝宝相册 / 成长日记（文件在 RustFS，库内只存元数据）
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS nc_media CASCADE;
CREATE TABLE nc_media (
    media_id         bigserial      PRIMARY KEY,
    baby_id          int8           NOT NULL REFERENCES nc_baby (baby_id),
    file_name        varchar(200)   NOT NULL,
    object_key       varchar(500)   NOT NULL,            -- RustFS 对象键，按宝宝目录隔离
    mime_type        varchar(80)    NOT NULL,
    file_size        int8           NOT NULL,            -- 字节，单文件 ≤ 100MB
    media_type       varchar(10)    NOT NULL,            -- image / video
    tag_code         varchar(20)    DEFAULT 'daily',     -- 字典 nc_media_tag
    description      varchar(500),
    health_check_id  int8,                               -- 可选关联某条健康自检
    uploader_id      int8           NOT NULL,
    uploader_name    varchar(30)    NOT NULL,
    del_flag         char(1)        DEFAULT '0',
    create_time      timestamp(6)   DEFAULT current_timestamp,
    update_by        varchar(64)    DEFAULT '',
    update_time      timestamp(6)
);
COMMENT ON TABLE  nc_media IS '媒体元数据；删除记录时必须同步删除 RustFS 对象';
COMMENT ON COLUMN nc_media.object_key IS 'S3/RustFS 对象键，展示用带鉴权 URL，禁止 base64 内嵌';

CREATE INDEX idx_nc_media_baby_time ON nc_media (baby_id, create_time DESC) WHERE del_flag = '0';
CREATE INDEX idx_nc_media_tag ON nc_media (baby_id, tag_code) WHERE del_flag = '0';

-- ---------------------------------------------------------------------------
-- 13. 交接记录
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS nc_handover CASCADE;
CREATE TABLE nc_handover (
    handover_id      bigserial      PRIMARY KEY,
    baby_id          int8           NOT NULL REFERENCES nc_baby (baby_id),
    from_user_id     int8           NOT NULL,
    from_user_name   varchar(30)    NOT NULL,
    to_user_id       int8           NOT NULL,
    to_user_name     varchar(30)    NOT NULL,
    handover_time    timestamp(6)   NOT NULL,
    notes            varchar(500),
    create_by        varchar(64)    DEFAULT '',
    create_time      timestamp(6)   DEFAULT current_timestamp
);
COMMENT ON TABLE nc_handover IS '值班交接：谁在何时把宝宝交给谁';

CREATE INDEX idx_nc_handover_baby_time ON nc_handover (baby_id, handover_time DESC);

-- ---------------------------------------------------------------------------
-- 14. 留言板（支持 @成员）
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS nc_message CASCADE;
CREATE TABLE nc_message (
    message_id       bigserial      PRIMARY KEY,
    baby_id          int8           NOT NULL REFERENCES nc_baby (baby_id),
    content          varchar(1000)  NOT NULL,
    author_id        int8           NOT NULL,
    author_name      varchar(30)    NOT NULL,
    create_time      timestamp(6)   DEFAULT current_timestamp,
    del_flag         char(1)        DEFAULT '0'
);
COMMENT ON TABLE nc_message IS '家庭留言板';

CREATE INDEX idx_nc_message_baby ON nc_message (baby_id, create_time DESC) WHERE del_flag = '0';

DROP TABLE IF EXISTS nc_message_mention CASCADE;
CREATE TABLE nc_message_mention (
    mention_id       bigserial      PRIMARY KEY,
    message_id       int8           NOT NULL REFERENCES nc_message (message_id) ON DELETE CASCADE,
    baby_id          int8           NOT NULL,
    mentioned_user_id int8          NOT NULL,
    mentioned_name   varchar(30)    NOT NULL,
    read_flag        char(1)        DEFAULT '0',         -- 仪表盘提醒，读后标记
    create_time      timestamp(6)   DEFAULT current_timestamp
);
COMMENT ON TABLE nc_message_mention IS '留言 @ 提醒；未读在仪表盘展示';

CREATE INDEX idx_nc_mention_user ON nc_message_mention (mentioned_user_id, read_flag);

-- ---------------------------------------------------------------------------
-- 15. 业务操作日志（按宝宝/模块筛选；与新生儿护理工作台 sys_oper_log 互补）
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS nc_oper_log CASCADE;
CREATE TABLE nc_oper_log (
    log_id           bigserial      PRIMARY KEY,
    baby_id          int8,
    module_code      varchar(30)    NOT NULL,
    action_code      varchar(20)    NOT NULL,            -- create/update/delete/login/handover
    summary          varchar(200)   NOT NULL,
    operator_id      int8           NOT NULL,
    operator_name    varchar(30)    NOT NULL,
    create_time      timestamp(6)   DEFAULT current_timestamp
);
COMMENT ON TABLE nc_oper_log IS '协作中心操作日志';

CREATE INDEX idx_nc_oper_log_baby ON nc_oper_log (baby_id, create_time DESC);
CREATE INDEX idx_nc_oper_log_module ON nc_oper_log (module_code, create_time DESC);

-- ---------------------------------------------------------------------------
-- 16. 知识库（急救手册 / 喂养睡眠护理）
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS nc_knowledge CASCADE;
CREATE TABLE nc_knowledge (
    kb_id            bigserial      PRIMARY KEY,
    category         varchar(20)    NOT NULL,            -- emergency/feeding/sleep/care
    title            varchar(100)   NOT NULL,
    urgency          int2           DEFAULT 1,           -- 1居家观察 3尽快就医 5立即拨打120
    keywords         varchar(200),
    content          text           NOT NULL,
    sort_num         int4           DEFAULT 0,
    status           char(1)        DEFAULT '0',
    create_time      timestamp(6)   DEFAULT current_timestamp,
    update_time      timestamp(6)
);
COMMENT ON TABLE  nc_knowledge IS '内置知识库；仪表盘红色预警可按 keywords 直达';
COMMENT ON COLUMN nc_knowledge.urgency IS '1=居家观察 3=尽快就医 5=立即拨打120';

CREATE INDEX idx_nc_knowledge_cat ON nc_knowledge (category, sort_num);

-- ---------------------------------------------------------------------------
-- 在线成员视图（心跳 45 秒内视为在线）
-- ---------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_nc_online_member AS
SELECT m.member_id,
       m.baby_id,
       m.user_id,
       m.role_tag,
       m.display_name,
       m.last_heartbeat,
       CASE
           WHEN m.last_heartbeat IS NOT NULL
                AND m.last_heartbeat > (current_timestamp - interval '45 seconds')
           THEN '1' ELSE '0'
       END AS online_flag
  FROM nc_baby_member m
 WHERE m.status = '0';

COMMENT ON VIEW v_nc_online_member IS '家庭页在线状态：心跳超过约 45 秒视为离线';

-- =============================================================================
-- 新生儿护理工作台 · 种子数据
-- 新库请优先执行 sql/nursing.sql（03 + 本文件的合并件）。
-- 依赖：03-nursing-schema.sql
-- 不预置任何宝宝 / 家庭成员数据（由超管创建）
-- 已含 RustFS AccessKey / SecretKey / Region，新库不必再跑 05
-- =============================================================================


-- ---------------------------------------------------------------------------
-- 角色：妈妈 / 家人（超管沿用新生儿护理工作台 role_id=1 admin）
-- ---------------------------------------------------------------------------
INSERT INTO sys_role (role_id, role_name, role_key, role_sort, data_scope,
                      menu_check_strictly, dept_check_strictly, status, del_flag,
                      create_by, create_time, remark)
VALUES (3, '妈妈', 'mom', 3, '2', 't', 't', '0', '0', 'admin', current_timestamp,
        '管理本宝宝家庭成员，可读写所属宝宝全部护理数据；跨宝宝由 nc_baby_member 强制隔离'),
       (4, '家人', 'family', 4, '2', 't', 't', '0', '0', 'admin', current_timestamp,
        '爸爸/奶奶/月嫂等；不能管理成员，只能读写所属宝宝数据')
ON CONFLICT (role_id) DO NOTHING;

SELECT setval('sys_role_role_id_seq', GREATEST((SELECT MAX(role_id) FROM sys_role), 1));

-- ---------------------------------------------------------------------------
-- 参数：RustFS / OBS（家庭服务器本地，不接第三方云）
-- ---------------------------------------------------------------------------
INSERT INTO sys_config (config_id, config_name, config_key, config_value, config_type,
                        create_by, create_time, remark)
VALUES (100, '护理媒体-RustFS地址', 'nursing.oss.endpoint', 'http://127.0.0.1:9000', 'Y',
        'admin', current_timestamp, 'RustFS/S3 兼容 endpoint，仅指向本机家庭服务器'),
       (101, '护理媒体-存储桶', 'nursing.oss.bucket', 'nursing', 'Y',
        'admin', current_timestamp, '按宝宝隔离的对象存储桶名'),
       (102, '护理媒体-单文件上限字节', 'nursing.oss.maxFileSize', '104857600', 'Y',
        'admin', current_timestamp, '100MB = 104857600'),
       (103, '编辑锁过期秒数', 'nursing.lock.ttlSeconds', '300', 'Y',
        'admin', current_timestamp, '同一记录编辑锁 5 分钟自动过期'),
       (104, '在线心跳间隔秒', 'nursing.presence.intervalSeconds', '20', 'Y',
        'admin', current_timestamp, '打开页面约每 20 秒上报心跳'),
       (105, '离线判定秒数', 'nursing.presence.offlineSeconds', '45', 'Y',
        'admin', current_timestamp, '超过约 45 秒无心跳视为离线'),
       (106, '护理媒体-AccessKey', 'nursing.oss.accessKey', 'rustfsadmin', 'Y',
        'admin', current_timestamp, 'RustFS 默认账号，请按实际部署修改'),
       (107, '护理媒体-SecretKey', 'nursing.oss.secretKey', 'rustfsadmin', 'Y',
        'admin', current_timestamp, 'RustFS 默认密钥，请按实际部署修改'),
       (108, '护理媒体-Region', 'nursing.oss.region', 'us-east-1', 'Y',
        'admin', current_timestamp, 'S3 兼容签名用区域，RustFS 可保持 us-east-1')
ON CONFLICT (config_id) DO NOTHING;

SELECT setval('sys_config_config_id_seq', GREATEST((SELECT MAX(config_id) FROM sys_config), 1));

-- ---------------------------------------------------------------------------
-- 字典类型
-- ---------------------------------------------------------------------------
INSERT INTO sys_dict_type (dict_id, dict_name, dict_type, status, create_by, create_time, remark)
VALUES (100, '家庭角色标签', 'nc_family_role', '0', 'admin', current_timestamp, '妈妈创建家人时的角色标签'),
       (101, '喂养方式', 'nc_feed_method', '0', 'admin', current_timestamp, NULL),
       (102, '拍嗝效果', 'nc_burp_effect', '0', 'admin', current_timestamp, NULL),
       (103, '睡眠类型', 'nc_sleep_type', '0', 'admin', current_timestamp, NULL),
       (104, '尿布类型', 'nc_diaper_type', '0', 'admin', current_timestamp, NULL),
       (105, '大便性状', 'nc_stool_texture', '0', 'admin', current_timestamp, '异常项前端用红色标记'),
       (106, '哭闹程度', 'nc_cry_intensity', '0', 'admin', current_timestamp, NULL),
       (107, '安抚效果', 'nc_soothe_effect', '0', 'admin', current_timestamp, NULL),
       (108, '安抚方式', 'nc_soothe_method', '0', 'admin', current_timestamp, '多选'),
       (109, '黄疸观察', 'nc_jaundice', '0', 'admin', current_timestamp, '按风险绿/黄/红着色'),
       (110, '脐带情况', 'nc_umbilical', '0', 'admin', current_timestamp, NULL),
       (111, '精神状态', 'nc_spirit', '0', 'admin', current_timestamp, NULL),
       (112, '相册标签', 'nc_media_tag', '0', 'admin', current_timestamp, NULL),
       (113, '知识库分类', 'nc_kb_category', '0', 'admin', current_timestamp, NULL)
ON CONFLICT (dict_id) DO NOTHING;

SELECT setval('sys_dict_type_dict_id_seq', GREATEST((SELECT MAX(dict_id) FROM sys_dict_type), 1));

-- ---------------------------------------------------------------------------
-- 字典数据（dict_code 从 100 起，避开新生儿护理工作台内置 1-28）
-- ---------------------------------------------------------------------------
INSERT INTO sys_dict_data (dict_code, dict_sort, dict_label, dict_value, dict_type,
                           css_class, list_class, is_default, status, create_by, create_time, remark)
VALUES
-- 家庭角色
(100, 1, '妈妈',   'mom',                'nc_family_role', '', 'primary', 'Y', '0', 'admin', current_timestamp, NULL),
(101, 2, '爸爸',   'dad',                'nc_family_role', '', 'info',    'N', '0', 'admin', current_timestamp, NULL),
(102, 3, '奶奶',   'grandma',            'nc_family_role', '', '',        'N', '0', 'admin', current_timestamp, NULL),
(103, 4, '外婆',   'maternal_grandma',   'nc_family_role', '', '',        'N', '0', 'admin', current_timestamp, NULL),
(104, 5, '月嫂',   'nanny',              'nc_family_role', '', 'warning', 'N', '0', 'admin', current_timestamp, NULL),
(105, 6, '其他',   'other',              'nc_family_role', '', '',        'N', '0', 'admin', current_timestamp, NULL),
-- 喂养方式
(110, 1, '亲喂母乳', 'breast',          'nc_feed_method', '', 'primary', 'Y', '0', 'admin', current_timestamp, NULL),
(111, 2, '瓶喂母乳', 'bottle_breast',   'nc_feed_method', '', 'success', 'N', '0', 'admin', current_timestamp, NULL),
(112, 3, '配方奶',   'formula',         'nc_feed_method', '', 'info',    'N', '0', 'admin', current_timestamp, NULL),
(113, 4, '混合喂养', 'mixed',           'nc_feed_method', '', 'warning', 'N', '0', 'admin', current_timestamp, NULL),
(114, 5, '辅食',     'solid',           'nc_feed_method', '', '',        'N', '0', 'admin', current_timestamp, NULL),
-- 拍嗝
(120, 1, '效果好',   'good',            'nc_burp_effect', '', 'success', 'Y', '0', 'admin', current_timestamp, NULL),
(121, 2, '一般',     'partial',         'nc_burp_effect', '', 'warning', 'N', '0', 'admin', current_timestamp, NULL),
(122, 3, '未排出',   'none',            'nc_burp_effect', '', 'danger',  'N', '0', 'admin', current_timestamp, NULL),
-- 睡眠
(130, 1, '夜间睡眠', 'night',           'nc_sleep_type', '', 'primary', 'Y', '0', 'admin', current_timestamp, '信息蓝'),
(131, 2, '白天小睡', 'nap',             'nc_sleep_type', '', 'success', 'N', '0', 'admin', current_timestamp, '安心绿'),
-- 尿布
(140, 1, '尿尿',     'pee',             'nc_diaper_type', '', 'info',    'Y', '0', 'admin', current_timestamp, NULL),
(141, 2, '便便',     'poop',            'nc_diaper_type', '', 'warning', 'N', '0', 'admin', current_timestamp, NULL),
(142, 3, '尿+便',    'both',            'nc_diaper_type', '', '',        'N', '0', 'admin', current_timestamp, NULL),
-- 大便性状
(150, 1, '正常',         'normal',      'nc_stool_texture', '', 'success', 'Y', '0', 'admin', current_timestamp, NULL),
(151, 2, '稀便(水样)',   'watery',      'nc_stool_texture', '', 'danger',  'N', '0', 'admin', current_timestamp, '异常红'),
(152, 3, '带血丝',       'bloody',      'nc_stool_texture', '', 'danger',  'N', '0', 'admin', current_timestamp, '异常红'),
(153, 4, '黏液便',       'mucus',       'nc_stool_texture', '', 'danger',  'N', '0', 'admin', current_timestamp, '异常红'),
(154, 5, '其他异常',     'other',       'nc_stool_texture', '', 'warning', 'N', '0', 'admin', current_timestamp, NULL),
-- 哭闹
(160, 1, '轻微',     'mild',            'nc_cry_intensity', '', 'success', 'Y', '0', 'admin', current_timestamp, NULL),
(161, 2, '中等',     'medium',          'nc_cry_intensity', '', 'warning', 'N', '0', 'admin', current_timestamp, NULL),
(162, 3, '很严重',   'severe',          'nc_cry_intensity', '', 'danger',  'N', '0', 'admin', current_timestamp, NULL),
(170, 1, '有效缓解', 'effective',       'nc_soothe_effect', '', 'success', 'Y', '0', 'admin', current_timestamp, NULL),
(171, 2, '部分缓解', 'partial',         'nc_soothe_effect', '', 'warning', 'N', '0', 'admin', current_timestamp, NULL),
(172, 3, '无效',     'none',            'nc_soothe_effect', '', 'danger',  'N', '0', 'admin', current_timestamp, NULL),
(180, 1, '抱起安抚', 'hold',            'nc_soothe_method', '', '', 'N', '0', 'admin', current_timestamp, NULL),
(181, 2, '拍嗝',     'burp',            'nc_soothe_method', '', '', 'N', '0', 'admin', current_timestamp, NULL),
(182, 3, '换尿布',   'diaper',          'nc_soothe_method', '', '', 'N', '0', 'admin', current_timestamp, NULL),
(183, 4, '喂奶',     'feed',            'nc_soothe_method', '', '', 'N', '0', 'admin', current_timestamp, NULL),
(184, 5, '白噪音',   'white_noise',     'nc_soothe_method', '', '', 'N', '0', 'admin', current_timestamp, NULL),
(185, 6, '摇晃/晃床', 'rock',           'nc_soothe_method', '', '', 'N', '0', 'admin', current_timestamp, NULL),
-- 健康
(190, 1, '未见黄染',     'none',        'nc_jaundice', '', 'success', 'Y', '0', 'admin', current_timestamp, '绿'),
(191, 2, '面部黄染',     'face',        'nc_jaundice', '', 'warning', 'N', '0', 'admin', current_timestamp, '黄'),
(192, 3, '蔓延躯干',     'trunk',       'nc_jaundice', '', 'warning', 'N', '0', 'admin', current_timestamp, '黄'),
(193, 4, '蔓延四肢',     'limbs',       'nc_jaundice', '', 'warning', 'N', '0', 'admin', current_timestamp, '黄'),
(194, 5, '手心脚心黄染', 'palms',       'nc_jaundice', '', 'danger',  'N', '0', 'admin', current_timestamp, '红'),
(200, 1, '干燥结痂', 'dry',             'nc_umbilical', '', 'success', 'Y', '0', 'admin', current_timestamp, '绿'),
(201, 2, '潮湿',     'moist',           'nc_umbilical', '', 'warning', 'N', '0', 'admin', current_timestamp, '黄'),
(202, 3, '有渗液',   'ooze',            'nc_umbilical', '', 'danger',  'N', '0', 'admin', current_timestamp, '红'),
(203, 4, '红肿',     'red',             'nc_umbilical', '', 'danger',  'N', '0', 'admin', current_timestamp, '红'),
(210, 1, '精神可',   'good',            'nc_spirit', '', 'success', 'Y', '0', 'admin', current_timestamp, '绿'),
(211, 2, '嗜睡',     'sleepy',          'nc_spirit', '', 'warning', 'N', '0', 'admin', current_timestamp, '黄'),
(212, 3, '易激惹',   'irritable',       'nc_spirit', '', 'warning', 'N', '0', 'admin', current_timestamp, '黄'),
(213, 4, '反应差',   'lethargic',       'nc_spirit', '', 'danger',  'N', '0', 'admin', current_timestamp, '红'),
-- 相册
(220, 1, '日常',     'daily',           'nc_media_tag', '', '',        'Y', '0', 'admin', current_timestamp, NULL),
(221, 2, '黄疸记录', 'jaundice',        'nc_media_tag', '', 'warning', 'N', '0', 'admin', current_timestamp, NULL),
(222, 3, '皮疹记录', 'rash',            'nc_media_tag', '', 'danger',  'N', '0', 'admin', current_timestamp, NULL),
(223, 4, '疫苗记录', 'vaccine',         'nc_media_tag', '', 'info',    'N', '0', 'admin', current_timestamp, NULL),
(224, 5, '满月照',   'full_month',      'nc_media_tag', '', 'primary', 'N', '0', 'admin', current_timestamp, NULL),
(225, 6, '表情包',   'meme',            'nc_media_tag', '', 'success', 'N', '0', 'admin', current_timestamp, NULL),
(226, 7, '全家福',   'family',          'nc_media_tag', '', '',        'N', '0', 'admin', current_timestamp, NULL),
(227, 8, '其他',     'other',           'nc_media_tag', '', '',        'N', '0', 'admin', current_timestamp, NULL),
-- 知识库分类
(230, 1, '急救手册', 'emergency',       'nc_kb_category', '', 'danger',  'Y', '0', 'admin', current_timestamp, NULL),
(231, 2, '喂养知识', 'feeding',         'nc_kb_category', '', 'primary', 'N', '0', 'admin', current_timestamp, NULL),
(232, 3, '睡眠知识', 'sleep',           'nc_kb_category', '', 'info',    'N', '0', 'admin', current_timestamp, NULL),
(233, 4, '护理知识', 'care',            'nc_kb_category', '', 'success', 'N', '0', 'admin', current_timestamp, NULL)
ON CONFLICT (dict_code) DO NOTHING;

SELECT setval('sys_dict_data_dict_code_seq', GREATEST((SELECT MAX(dict_code) FROM sys_dict_data), 1));

-- ---------------------------------------------------------------------------
-- 菜单（2000 段，避开新生儿护理工作台 1-117 / 500-501 / 1000+ 按钮）
-- status 字段为 int2，与新生儿护理工作台脚本一致写入 0
-- ---------------------------------------------------------------------------
INSERT INTO sys_menu (menu_id, menu_name, parent_id, order_num, path, component, query, route_name,
                      is_frame, is_cache, menu_type, visible, status, perms, icon,
                      create_by, create_time, remark)
VALUES
(2000, '总览',       0, 0, 'overview',  NULL, '', '', 1, 0, 'M', '0', 0, '', 'dashboard', 'admin', current_timestamp, '总览分组'),
(2001, '仪表盘',     2000, 1, 'dashboard', 'nursing/dashboard/index', '', '', 1, 0, 'C', '0', 0, 'nursing:dashboard:list', 'index', 'admin', current_timestamp, NULL),
(2016, '宝宝档案',   2000, 2, 'baby',      'nursing/baby/index',      '', '', 1, 0, 'C', '0', 0, 'nursing:baby:list',      'peoples', 'admin', current_timestamp, '超管创建宝宝并指定妈妈'),

(2002, '日常记录',   0, 1, 'daily', NULL, '', '', 1, 0, 'M', '0', 0, '', 'date', 'admin', current_timestamp, NULL),
(2003, '喂养管理',   2002, 1, 'feeding', 'nursing/feeding/index', '', '', 1, 0, 'C', '0', 0, 'nursing:feeding:list', 'documentation', 'admin', current_timestamp, NULL),
(2004, '睡眠管理',   2002, 2, 'sleep',   'nursing/sleep/index',   '', '', 1, 0, 'C', '0', 0, 'nursing:sleep:list',   'time-range', 'admin', current_timestamp, NULL),
(2005, '尿布排泄',   2002, 3, 'diaper',  'nursing/diaper/index',  '', '', 1, 0, 'C', '0', 0, 'nursing:diaper:list',  'list', 'admin', current_timestamp, NULL),
(2006, '哭闹安抚',   2002, 4, 'cry',     'nursing/cry/index',     '', '', 1, 0, 'C', '0', 0, 'nursing:cry:list',     'message', 'admin', current_timestamp, NULL),

(2007, '照护健康',   0, 2, 'health', NULL, '', '', 1, 0, 'M', '0', 0, '', 'example', 'admin', current_timestamp, NULL),
(2008, '护理清单',   2007, 1, 'care',    'nursing/care/index',    '', '', 1, 0, 'C', '0', 0, 'nursing:care:list',    'checkbox', 'admin', current_timestamp, NULL),
(2009, '健康与疫苗', 2007, 2, 'checkup', 'nursing/health/index',  '', '', 1, 0, 'C', '0', 0, 'nursing:health:list',  'monitor', 'admin', current_timestamp, NULL),
(2010, '生长记录',   2007, 3, 'growth',  'nursing/growth/index',  '', '', 1, 0, 'C', '0', 0, 'nursing:growth:list',  'chart', 'admin', current_timestamp, NULL),
(2011, '宝宝相册',   2007, 4, 'album',   'nursing/media/index',   '', '', 1, 0, 'C', '0', 0, 'nursing:media:list',   'build', 'admin', current_timestamp, NULL),

(2012, '家庭与应急', 0, 3, 'family', NULL, '', '', 1, 0, 'M', '0', 0, '', 'peoples', 'admin', current_timestamp, NULL),
(2013, '家庭与成员', 2012, 1, 'member',     'nursing/member/index',     '', '', 1, 0, 'C', '0', 0, 'nursing:member:list',     'user', 'admin', current_timestamp, NULL),
(2014, '协作中心',   2012, 2, 'collab',     'nursing/collab/index',     '', '', 1, 0, 'C', '0', 0, 'nursing:collab:list',     'message', 'admin', current_timestamp, NULL),
(2015, '突发情况手册', 2012, 3, 'knowledge', 'nursing/knowledge/index', '', '', 1, 0, 'C', '0', 0, 'nursing:knowledge:list', 'guide', 'admin', current_timestamp, NULL),

-- 按钮
(2101, '喂养查询', 2003, 1, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:feeding:query',  '#', 'admin', current_timestamp, NULL),
(2102, '喂养新增', 2003, 2, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:feeding:add',    '#', 'admin', current_timestamp, NULL),
(2103, '喂养修改', 2003, 3, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:feeding:edit',   '#', 'admin', current_timestamp, NULL),
(2104, '喂养删除', 2003, 4, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:feeding:remove', '#', 'admin', current_timestamp, NULL),

(2111, '睡眠查询', 2004, 1, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:sleep:query',  '#', 'admin', current_timestamp, NULL),
(2112, '睡眠新增', 2004, 2, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:sleep:add',    '#', 'admin', current_timestamp, NULL),
(2113, '睡眠修改', 2004, 3, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:sleep:edit',   '#', 'admin', current_timestamp, NULL),
(2114, '睡眠删除', 2004, 4, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:sleep:remove', '#', 'admin', current_timestamp, NULL),

(2121, '尿布查询', 2005, 1, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:diaper:query',  '#', 'admin', current_timestamp, NULL),
(2122, '尿布新增', 2005, 2, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:diaper:add',    '#', 'admin', current_timestamp, NULL),
(2123, '尿布修改', 2005, 3, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:diaper:edit',   '#', 'admin', current_timestamp, NULL),
(2124, '尿布删除', 2005, 4, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:diaper:remove', '#', 'admin', current_timestamp, NULL),

(2131, '哭闹查询', 2006, 1, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:cry:query',  '#', 'admin', current_timestamp, NULL),
(2132, '哭闹新增', 2006, 2, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:cry:add',    '#', 'admin', current_timestamp, NULL),
(2133, '哭闹修改', 2006, 3, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:cry:edit',   '#', 'admin', current_timestamp, NULL),
(2134, '哭闹删除', 2006, 4, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:cry:remove', '#', 'admin', current_timestamp, NULL),

(2141, '清单查询', 2008, 1, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:care:query',  '#', 'admin', current_timestamp, NULL),
(2142, '清单完成', 2008, 2, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:care:edit',   '#', 'admin', current_timestamp, NULL),
(2143, '清单新增', 2008, 3, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:care:add',    '#', 'admin', current_timestamp, NULL),
(2144, '清单删除', 2008, 4, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:care:remove', '#', 'admin', current_timestamp, NULL),

(2151, '健康查询', 2009, 1, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:health:query',  '#', 'admin', current_timestamp, NULL),
(2152, '健康新增', 2009, 2, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:health:add',    '#', 'admin', current_timestamp, NULL),
(2153, '健康修改', 2009, 3, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:health:edit',   '#', 'admin', current_timestamp, NULL),
(2154, '疫苗标记', 2009, 4, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:vaccine:edit',  '#', 'admin', current_timestamp, NULL),

(2161, '生长查询', 2010, 1, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:growth:query',  '#', 'admin', current_timestamp, NULL),
(2162, '生长新增', 2010, 2, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:growth:add',    '#', 'admin', current_timestamp, NULL),
(2163, '生长修改', 2010, 3, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:growth:edit',   '#', 'admin', current_timestamp, NULL),
(2164, '生长删除', 2010, 4, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:growth:remove', '#', 'admin', current_timestamp, NULL),

(2171, '相册查询', 2011, 1, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:media:query',    '#', 'admin', current_timestamp, NULL),
(2172, '相册上传', 2011, 2, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:media:add',      '#', 'admin', current_timestamp, NULL),
(2173, '相册修改', 2011, 3, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:media:edit',     '#', 'admin', current_timestamp, NULL),
(2174, '相册删除', 2011, 4, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:media:remove',   '#', 'admin', current_timestamp, NULL),
(2175, '相册下载', 2011, 5, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:media:download', '#', 'admin', current_timestamp, NULL),

(2181, '成员查询', 2013, 1, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:member:query',    '#', 'admin', current_timestamp, NULL),
(2182, '成员新增', 2013, 2, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:member:add',      '#', 'admin', current_timestamp, '仅妈妈'),
(2183, '成员修改', 2013, 3, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:member:edit',     '#', 'admin', current_timestamp, '仅妈妈'),
(2184, '重置密码', 2013, 4, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:member:resetPwd', '#', 'admin', current_timestamp, '仅妈妈'),
(2185, '停用启用', 2013, 5, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:member:disable',  '#', 'admin', current_timestamp, '仅妈妈'),

(2191, '协作查询', 2014, 1, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:collab:query', '#', 'admin', current_timestamp, NULL),
(2192, '交接新增', 2014, 2, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:handover:add', '#', 'admin', current_timestamp, NULL),
(2193, '留言新增', 2014, 3, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:message:add',  '#', 'admin', current_timestamp, NULL),

(2201, '手册查询', 2015, 1, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:knowledge:query', '#', 'admin', current_timestamp, NULL),

(2211, '档案查询', 2016, 1, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:baby:query',  '#', 'admin', current_timestamp, NULL),
(2212, '档案新增', 2016, 2, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:baby:add',    '#', 'admin', current_timestamp, '仅超管'),
(2213, '档案修改', 2016, 3, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:baby:edit',   '#', 'admin', current_timestamp, NULL),
(2214, '档案删除', 2016, 4, '', '', '', '', 1, 0, 'F', '0', 0, 'nursing:baby:remove', '#', 'admin', current_timestamp, '仅超管')
ON CONFLICT (menu_id) DO NOTHING;

SELECT setval('sys_menu_menu_id_seq', GREATEST((SELECT MAX(menu_id) FROM sys_menu), 1));

-- 妈妈：全部护理菜单 + 成员管理按钮；不含宝宝新增/删除（超管专属）
INSERT INTO sys_role_menu (role_id, menu_id)
SELECT 3, m.menu_id
  FROM sys_menu m
 WHERE m.menu_id BETWEEN 2000 AND 2214
   AND m.menu_id NOT IN (2212, 2214)
ON CONFLICT (role_id, menu_id) DO NOTHING;

-- 家人：读写护理数据，只能查看成员，不能管账号，不能建宝宝
INSERT INTO sys_role_menu (role_id, menu_id)
SELECT 4, m.menu_id
  FROM sys_menu m
 WHERE m.menu_id BETWEEN 2000 AND 2214
   AND m.menu_id NOT IN (2182, 2183, 2184, 2185, 2212, 2213, 2214)
ON CONFLICT (role_id, menu_id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 内置护理清单模板（baby_id 为空）；可重复执行
-- ---------------------------------------------------------------------------
DELETE FROM nc_care_item WHERE is_builtin = '1' AND baby_id IS NULL;
INSERT INTO nc_care_item (item_name, is_builtin, sort_num, status, del_flag, create_by, remark)
VALUES ('脐带护理', '1', 1, '0', '0', 'admin', '内置'),
       ('维生素D', '1', 2, '0', '0', 'admin', '内置'),
       ('洗澡',     '1', 3, '0', '0', 'admin', '内置'),
       ('抚触',     '1', 4, '0', '0', 'admin', '内置'),
       ('排气操',   '1', 5, '0', '0', 'admin', '内置'),
       ('剪指甲',   '1', 6, '0', '0', 'admin', '内置');

-- ---------------------------------------------------------------------------
-- 0-6 月龄国家免疫规划时间表（仅供参考，以当地接种单位安排为准）
-- due_age_days 按出生后满月近似：1月=30 天；可重复执行
-- ---------------------------------------------------------------------------
DELETE FROM nc_vaccine_record;
DELETE FROM nc_vaccine_schedule;
INSERT INTO nc_vaccine_schedule (vaccine_code, vaccine_name, dose_no, total_doses, due_age_days, remind_before, sort_num, remark)
VALUES ('BCG',    '卡介苗',                 1, 1, 0,   3, 10, '出生时'),
       ('HepB',   '乙肝疫苗',               1, 3, 0,   3, 20, '出生时第 1 剂'),
       ('HepB',   '乙肝疫苗',               2, 3, 30,  3, 30, '1 月龄第 2 剂'),
       ('IPV',    '脊髓灰质炎灭活疫苗',     1, 3, 60,  3, 40, '2 月龄第 1 剂'),
       ('IPV',    '脊髓灰质炎灭活疫苗',     2, 3, 90,  3, 50, '3 月龄第 2 剂'),
       ('DTaP',   '百白破疫苗',             1, 3, 90,  3, 60, '3 月龄第 1 剂'),
       ('IPV',    '脊髓灰质炎灭活疫苗',     3, 3, 120, 3, 70, '4 月龄第 3 剂'),
       ('DTaP',   '百白破疫苗',             2, 3, 120, 3, 80, '4 月龄第 2 剂'),
       ('DTaP',   '百白破疫苗',             3, 3, 150, 3, 90, '5 月龄第 3 剂'),
       ('HepB',   '乙肝疫苗',               3, 3, 180, 3, 100, '6 月龄第 3 剂'),
       ('MPSV-A', 'A 群流脑多糖疫苗',       1, 2, 180, 3, 110, '6 月龄第 1 剂');

-- ---------------------------------------------------------------------------
-- 知识库种子（可重复执行）
-- ---------------------------------------------------------------------------
DELETE FROM nc_knowledge;
INSERT INTO nc_knowledge (category, title, urgency, keywords, sort_num, content)
VALUES
('emergency', '新生儿气道异物 · 海姆立克法', 5, '呛奶,异物,窒息,海姆立克,急救,120', 10,
 $kb$分级：⭐⭐⭐⭐⭐ 立即拨打 120，同时开始施救。

1. 确认宝宝无法哭出声、面色发紫或呼吸停止。
2. 前臂托住宝宝，面朝下、头略低于躯干，用掌根在肩胛之间拍击 5 次。
3. 翻转成面朝上，两指按压胸骨下半段 5 次。
4. 拍背与按压交替，直到异物排出或急救人员接手。
5. 若失去反应，立即转为心肺复苏。

本条只作家庭应急提示，不能替代专业急救培训。$kb$),

('emergency', '新生儿心肺复苏（CPR）', 5, '心跳,呼吸停止,心肺复苏,CPR,120', 20,
 $kb$分级：⭐⭐⭐⭐⭐ 立即拨打 120。

1. 把宝宝放在坚硬平面，开放气道。
2. 口对口鼻给予 2 次轻微吹气，看到胸廓微微起伏即可。
3. 两指按压胸骨下半段，深度约胸廓前后径的 1/3，频率约每分钟 100–120 次。
4. 按压与吹气按 30:2（单人）持续，直到宝宝有反应或急救人员接手。$kb$),

('emergency', '高热或持续发热', 3, '发烧,发热,体温,抽搐', 30,
 $kb$分级：⭐⭐⭐ 尽快就医。

新生儿（尤其 3 月龄内）腋温 ≥38℃，或精神变差、吃奶明显减少，不要自行退烧药，尽快儿科就诊。
居家先解开多余衣物、补充喂养，并记录体温时间。$kb$),

('emergency', '黄疸加重', 3, '黄疸,黄染,手心脚心,嗜睡', 40,
 $kb$分级：⭐⭐⭐ 尽快就医。

需要尽快就医的信号：黄染蔓延到四肢或手心脚心、精神差、吃奶少、尿色深、大便发白。
仅面部轻微黄染且精神吃奶正常，可居家观察并按医嘱复查经皮胆红素。$kb$),

('emergency', '脐带红肿或渗液', 3, '脐带,渗液,红肿,感染,臭味', 50,
 $kb$分级：⭐⭐⭐ 尽快就医。

脐周皮肤发红扩散、有脓性分泌物或臭味、宝宝发热，提示感染迹象，尽快就诊。
日常保持干燥清洁，不要自行涂不明粉末。$kb$),

('emergency', '喂养不足或尿量偏少', 3, '奶量少,脱水,尿少,体重不增', 60,
 $kb$分级：⭐⭐⭐ 尽快就医。

24 小时尿湿少于 6 次、囟门凹陷、哭时泪少、体重不增或下降，属于需关注/需处理信号。
先核对最近喂养记录与间隔，并联系儿科。$kb$),

('emergency', '吐奶后精神如常', 1, '溢奶,吐奶,观察', 70,
 $kb$分级：⭐ 居家观察。

少量溢奶、拍嗝后缓解、精神反应正常，多为胃容量小或吸入空气。
喷射性呕吐、胆汁样呕吐、腹胀或血便，升级为尽快就医。$kb$),

('feeding', '胃容量参考（按周龄）', 1, '胃容量,奶量,喂养', 80,
 $kb$仅供家庭记录对照，不是医嘱目标。

- 出生当天：约 5–7 ml/次
- 第 3 天：约 22–27 ml/次
- 第 7 天：约 45–60 ml/次
- 2 周：约 60–90 ml/次
- 1 月：约 80–150 ml/次

实际奶量因体重和喂养方式差异很大，以宝宝尿量、精神、体重趋势为准。$kb$),

('feeding', '饥饿信号三档', 1, '饥饿,早期信号,晚期信号,哭闹', 90,
 $kb$- 早期：张嘴、转头觅食、吮手。此时喂养最顺利。
- 中期：蠕动不安、轻声哼唧。
- 晚期：大哭。提示「已饿很久」，先安抚再喂，避免双方更焦虑。$kb$),

('feeding', '拍嗝手法', 1, '拍嗝,胀气,吐奶', 100,
 $kb$1. 竖抱，下巴靠在大人肩上，空心掌由下向上轻拍背部。
2. 坐姿：一手托颏，身体略前倾，另一手拍背。
3. 拍 3–5 分钟仍无嗝、但宝宝安稳，可停止，不必强求。$kb$),

('sleep', '昼夜睡眠节律', 1, '睡眠,小睡,夜间', 110,
 $kb$新生儿一昼夜睡眠常达 14–17 小时，且昼夜不分。
夜间睡眠用信息蓝标记、白天小睡用安心绿标记，便于看出节律是否在慢慢拉开。
连续超过 4–5 小时不醒且日龄很小，需观察是否该喂一次，避免低血糖风险，具体听医嘱。$kb$),

('care', '脐带护理要点', 1, '脐带,护理清单', 120,
 $kb$保持脐部干燥清洁；洗完澡用干净棉签蘸温开水轻拭周围皮肤，再晾干。
不要包裹过紧或覆盖不透气敷料。出现红肿渗液按急救条目处理。$kb$);

COMMIT;