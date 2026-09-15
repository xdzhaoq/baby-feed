# baby-feed · 新生儿护理工作台

家庭侧记录喂养、睡眠、尿布、哭闹、护理清单和健康；电脑给超管建档、看家庭总览，手机给妈妈/家人记日常。

认证继续用 JWT。默认超管：`admin` / `admin123`（仅 `user_id = 1` 视为护理超管）。

## 技术栈

| 层 | 说明 |
|---|---|
| 后端 | Spring Boot 2.5、JWT、MyBatis、PostgreSQL 12+、Redis |
| 前端 | Vue 3、Vite、Element Plus |
| 对象存储 | RustFS（S3 兼容），参数在库表 `sys_config` 的 `nursing.oss.*` |
| 手机 | 同一套前端，宽度 &lt; 960px 或 Capacitor 原生壳走手机布局；Android 用 Capacitor 6 |

## 目录

```
baby-feed/
├── youyou-admin          # 启动模块 YouyouApplication，默认端口 8080
├── youyou-framework      # 安全 / Redis / 数据源
├── youyou-system         # 系统管理 + 护理业务（com.youyou.nursing）
├── youyou-common
├── youyou-quartz
├── youyou-generator
├── youyou-ui-vue3        # 前端（PC 侧栏 + 手机壳）
└── sql/init.sql          # 唯一完整安装脚本
```

Maven 坐标是 `com.youyou`，工程名是 `baby-feed`。

## 角色

| 角色 | 说明 |
|---|---|
| 超管 `admin` | 建档、指定妈妈、家庭运营总览；可代记日常，不当值班人。仪表盘默认家庭总览，点宝宝卡片才进协查 |
| 妈妈 `mom` | 今日照护手账；可管理本宝宝家人账号，不能新增/删除宝宝档案 |
| 家人 `family` | 记日常；不能管成员、不能改宝宝档案 |

跨宝宝隔离以 `nc_baby_member` 为准。种子**不包含任何宝宝**，要先由超管建档。

## 环境

后端配置：

- `youyou-admin/src/main/resources/application.yml`（端口、Redis、JWT）
- `youyou-admin/src/main/resources/application-druid.yml`（PostgreSQL）

当前开发库、Redis 默认指向本机 `127.0.0.1`。账号密码写在上述两个文件里，**不要把真实密码提交到 Git**。现网地址和密码放在本地 `scripts/pack.config.ps1`（该文件已 gitignore）。没有该文件时，可先复制 `scripts/pack.config.example.ps1`。Redis 5.x 需走 RESP2。相册默认共用桶 `nursing`，按前缀 `baby/{id}/` 隔离，可在后台「参数设置」改 `nursing.oss.*`。

本地空库安装（会清空并重建表，有数据的库不要跑）：

```bash
# 在 postgres 库建库（已存在可跳过）
psql -U postgres -c "CREATE DATABASE youyou OWNER postgres ENCODING 'UTF8' TEMPLATE template0;"

# 连上目标库执行这一份
psql -U postgres -d youyou -f sql/init.sql
```

库名要和 `application-druid.yml` 一致。

## 部署包

打好的 PC 前端、后端 jar、Nginx 配置、Android APK 在 `release/`。用法见 `release/README.md`。

改配置并重新打包（在 `baby-feed` 根目录）：

```bat
pack.bat
```

- 按提示改配置，一路回车则用 `scripts/pack.config.ps1` 里的默认值。
- 不提问直接打：`pack.bat -Yes`（完全按配置文件，**打哪些看里面的 `$Target`**）。
- 只改配置不编译：`pack.bat -ConfigOnly`。
- 指定产物（会覆盖配置文件里的 `$Target`）：

| 命令 | 产物 |
|---|---|
| `pack.bat -Yes -Target all` | 后端 jar + PC 前端 + Android APK |
| `pack.bat -Yes -Target server` | 后端 jar + PC 前端（不要 APK） |
| `pack.bat -Yes -Target backend` | 只打后端 |
| `pack.bat -Yes -Target web` | 只打 PC 前端 |
| `pack.bat -Yes -Target android` | 只打 APK |

对外地址、库、Redis、Nginx 等先改本地 `scripts/pack.config.ps1`（可从 `pack.config.example.ps1` 复制），或运行 `pack.bat` 时在提示里改。打完看 `release/`。`release/` 和 `pack.config.ps1` 含部署密码，不要提交。

## 启动

需要 JDK 8+（本机可用 21）、Maven、Node 18+、已启动的 PostgreSQL 与 Redis。

```bash
# 后端（在 baby-feed 根目录）
mvn -pl youyou-admin -am package -DskipTests
java -jar youyou-admin/target/youyou-admin.jar

# 前端
cd youyou-ui-vue3
npm install
npm run dev -- --port 5173 --host
```

浏览器打开 http://localhost:5173 ，接口经 `/dev-api` 代理到 `localhost:8080`。

登录页标题为「新生儿护理工作台」。PC 为侧栏工作台；窄屏或 App 内为底栏：今日 / 记录 / 记一笔 / 健康 / 家庭。系统管理只给电脑超管使用。

## Android

同一套 Vue，不另开小程序工程。本机已最小化安装 Android 命令行 SDK（`D:\tools\android-sdk`），不必装 Android Studio。日常用根目录 `pack.bat` 一起打。

```bat
pack.bat -Target android
```

接口地址写在 `.env.app` 的 `VITE_APP_SERVER`（打包脚本会按对外地址自动写）。登录页只填账号密码。包名 `com.nursing.workbench`。本期不做 iOS。Debug APK：`android/app/build/outputs/apk/debug/app-debug.apk`，`release/android/app-debug.apk` 是已打好的一份。

## 媒体与清单

- 文件进 RustFS，库里只存 `nc_media.object_key`
- 护理清单：自定义事项可删；内置事项对本宝宝隐藏（`nc_care_hidden`）
- 疫苗时间表为国家免疫规划 0–6 月龄参考，不能替代接种单位安排
