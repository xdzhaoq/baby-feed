# 新生儿护理工作台 · 一键打包（后端 jar + PC 静态页 + Android APK）
[CmdletBinding()]
param(
    [ValidateSet('all', 'server', 'backend', 'web', 'android')]
    [string]$Target,
    [switch]$Yes,
    [switch]$ConfigOnly
)

$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

$Root = Split-Path -Parent $PSScriptRoot
$ConfigFile = Join-Path $PSScriptRoot 'pack.config.ps1'
$Release = Join-Path $Root 'release'
$Ui = Join-Path $Root 'youyou-ui-vue3'
$Utf8 = New-Object System.Text.UTF8Encoding $false
$Utf8Bom = New-Object System.Text.UTF8Encoding $true

function Write-Utf8([string]$Path, [string]$Content) {
    $dir = Split-Path $Path
    if ($dir -and -not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    [System.IO.File]::WriteAllText($Path, $Content, $Utf8)
}

function Write-Utf8Lf([string]$Path, [string]$Content) {
    $lf = $Content -replace "`r`n", "`n" -replace "`r", "`n"
    if (-not $lf.EndsWith("`n")) { $lf += "`n" }
    Write-Utf8 $Path $lf
}

function Read-Utf8([string]$Path) {
    return [System.IO.File]::ReadAllText($Path, $Utf8)
}

function Info([string]$Message) { Write-Host $Message -ForegroundColor Cyan }
function Ok([string]$Message) { Write-Host $Message -ForegroundColor Green }
function Die([string]$Message) { Write-Host $Message -ForegroundColor Red; exit 1 }

function Ask([string]$Label, [string]$Current) {
    $typed = Read-Host ("  {0} [{1}]" -f $Label, $Current)
    if ([string]::IsNullOrWhiteSpace($typed)) { return $Current }
    return $typed.Trim()
}

function Need-Command([string]$Name) {
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        Die "找不到 $Name，请先安装并加入 PATH。"
    }
}

function Replace-Once([string]$Text, [string]$Pattern, [string]$Replacement, [string]$What) {
    $re = [regex]::new($Pattern)
    $m = $re.Match($Text)
    if (-not $m.Success) { Die "改配置失败，找不到：$What" }
    return $re.Replace($Text, $Replacement, 1)
}

function Normalize-PublicUrl([string]$Url) {
    $u = $Url.Trim().TrimEnd('/')
    if ($u -notmatch '^https?://') {
        Die "对外地址必须以 http:// 或 https:// 开头。"
    }
    $u = $u -replace '/prod-api$', ''
    return $u.TrimEnd('/')
}

function Assert-Port([int]$Port, [string]$Name) {
    if ($Port -lt 1 -or $Port -gt 65535) {
        Die "$Name 端口非法：$Port（TCP 端口只能是 1–65535）"
    }
}

function Get-AppServer([string]$PublicUrl) {
    return "$PublicUrl/prod-api"
}

function Save-PackConfig {
    param($Cfg)
    $pwdDb = $Cfg.DbPassword.Replace("'", "''")
    $pwdRedis = $Cfg.RedisPassword.Replace("'", "''")
    $body = @"
# 打包配置（可用记事本改，或运行 pack.bat 时按提示改）
# 密码等会写进 release/backend/config，不会改你本地开发用的 youyou-admin 源码配置。

# 浏览器和手机 App 打开的地址（不要末尾斜杠；不要带 /prod-api）
`$PublicUrl = '$($Cfg.PublicUrl)'

# 后端 jar 监听端口（Nginx /prod-api 反代到这里）。必须是 1–65535，不能写 70000
`$ServerPort = $($Cfg.ServerPort)

# 上传目录。Linux 服务器一般用 /home/youyou/uploadPath
`$UploadPath = '$($Cfg.UploadPath)'

# PostgreSQL
`$DbHost = '$($Cfg.DbHost)'
`$DbPort = $($Cfg.DbPort)
`$DbName = '$($Cfg.DbName)'
`$DbUser = '$($Cfg.DbUser)'
`$DbPassword = '$pwdDb'

# Redis（5.x 走 RESP2，Lettuce 默认即可）
`$RedisHost = '$($Cfg.RedisHost)'
`$RedisPort = $($Cfg.RedisPort)
`$RedisDatabase = $($Cfg.RedisDatabase)
`$RedisPassword = '$pwdRedis'

# Nginx（打进 release/nginx/nursing.conf）
`$NginxListenPort = $($Cfg.NginxListenPort)
`$NginxWebRoot = '$($Cfg.NginxWebRoot)'

# 打哪些：all / server / backend / web / android
# all=后端+PC+APK；server=后端+PC（不要 APK）
`$Target = '$($Cfg.Target)'

# Android 命令行 SDK。空则用环境变量 ANDROID_HOME
`$AndroidSdk = '$($Cfg.AndroidSdk)'
"@
    [System.IO.File]::WriteAllText($ConfigFile, $body.TrimStart("`r", "`n") + "`r`n", $Utf8Bom)
}

function Load-PackConfig {
    if (-not (Test-Path $ConfigFile)) {
        $example = Join-Path $PSScriptRoot 'pack.config.example.ps1'
        if (Test-Path $example) {
            Copy-Item $example $ConfigFile
            Die "已生成 scripts\pack.config.ps1（从示例复制）。请先填入数据库、Redis 密码和对外地址再打包。"
        }
        Die "缺少 $ConfigFile"
    }
    . $ConfigFile
    return [pscustomobject]@{
        PublicUrl        = $PublicUrl
        ServerPort       = [int]$ServerPort
        UploadPath       = $UploadPath
        DbHost           = $DbHost
        DbPort           = [int]$DbPort
        DbName           = $DbName
        DbUser           = $DbUser
        DbPassword       = $DbPassword
        RedisHost        = $RedisHost
        RedisPort        = [int]$RedisPort
        RedisDatabase    = [int]$RedisDatabase
        RedisPassword    = $RedisPassword
        NginxListenPort  = [int]$NginxListenPort
        NginxWebRoot     = $NginxWebRoot
        Target           = $Target
        AndroidSdk       = $AndroidSdk
    }
}

function Prompt-Config($Cfg) {
    Write-Host ''
    Write-Host '========== 新生儿护理工作台 · 打包 ==========' -ForegroundColor Yellow
    Write-Host '回车保留方括号里的当前值。'
    Write-Host ''
    Write-Host '[访问]' -ForegroundColor Yellow
    $Cfg.PublicUrl = Normalize-PublicUrl (Ask '对外地址（浏览器/App）' $Cfg.PublicUrl)
    $Cfg.ServerPort = [int](Ask '后端端口 server.port' $Cfg.ServerPort)
    $Cfg.NginxListenPort = [int](Ask 'Nginx listen（一般 80）' $Cfg.NginxListenPort)
    $Cfg.NginxWebRoot = Ask 'Nginx 静态目录 root' $Cfg.NginxWebRoot
    $Cfg.UploadPath = Ask '上传目录 profile' $Cfg.UploadPath
    Write-Host ''
    Write-Host '[PostgreSQL]' -ForegroundColor Yellow
    $Cfg.DbHost = Ask '主机' $Cfg.DbHost
    $Cfg.DbPort = [int](Ask '端口' $Cfg.DbPort)
    $Cfg.DbName = Ask '库名' $Cfg.DbName
    $Cfg.DbUser = Ask '用户' $Cfg.DbUser
    $Cfg.DbPassword = Ask '密码' $Cfg.DbPassword
    Write-Host ''
    Write-Host '[Redis]' -ForegroundColor Yellow
    $Cfg.RedisHost = Ask '主机' $Cfg.RedisHost
    $Cfg.RedisPort = [int](Ask '端口' $Cfg.RedisPort)
    $Cfg.RedisDatabase = [int](Ask 'database' $Cfg.RedisDatabase)
    $Cfg.RedisPassword = Ask '密码' $Cfg.RedisPassword
    Write-Host ''
    Write-Host '[打哪些] all=全部  server=后端+PC  backend  web  android' -ForegroundColor Yellow
    $Cfg.Target = (Ask 'Target' $Cfg.Target).ToLowerInvariant()
    if (@('all', 'server', 'backend', 'web', 'android') -notcontains $Cfg.Target) {
        Die "Target 只能是 all / server / backend / web / android"
    }
    if ($Cfg.Target -in @('all', 'android')) {
        $Cfg.AndroidSdk = Ask 'Android SDK 目录' $Cfg.AndroidSdk
    }
    return $Cfg
}

function Show-Summary($Cfg) {
    $app = Get-AppServer $Cfg.PublicUrl
    Write-Host ''
    Write-Host '将按下面配置打包：' -ForegroundColor Yellow
    Write-Host ("  对外地址     {0}" -f $Cfg.PublicUrl)
    Write-Host ("  App 接口     {0}" -f $app)
    Write-Host ("  后端端口     {0}" -f $Cfg.ServerPort)
    Write-Host ("  Nginx        listen {0}  root {1}  -> 127.0.0.1:{2}" -f $Cfg.NginxListenPort, $Cfg.NginxWebRoot, $Cfg.ServerPort)
    Write-Host ("  上传目录     {0}" -f $Cfg.UploadPath)
    Write-Host ("  PostgreSQL   {0}:{1}/{2}  user={3}" -f $Cfg.DbHost, $Cfg.DbPort, $Cfg.DbName, $Cfg.DbUser)
    Write-Host ("  Redis        {0}:{1} db={2}" -f $Cfg.RedisHost, $Cfg.RedisPort, $Cfg.RedisDatabase)
    Write-Host ("  产物         {0}" -f $Cfg.Target)
    Write-Host ''
}

function Apply-Configs($Cfg) {
    Info '写入配置…'
    $appServer = Get-AppServer $Cfg.PublicUrl

    $envApp = Join-Path $Ui '.env.app'
    $envText = @"
# App 打包：接口走 Nginx 的 /prod-api
VITE_APP_TITLE = 护理工作台
VITE_APP_ENV = app
VITE_APP_BASE_API =
VITE_APP_SERVER = $appServer
"@
    Write-Utf8 $envApp ($envText.Trim() + "`r`n")

    $srcYml = Join-Path $Root 'youyou-admin\src\main\resources\application.yml'
    $srcDruid = Join-Path $Root 'youyou-admin\src\main\resources\application-druid.yml'
    $yml = Read-Utf8 $srcYml
    $yml = Replace-Once $yml '(?m)(^[ \t]*profile:[ \t]*).*' ('${1}' + $Cfg.UploadPath) 'youyou.profile'
    $yml = Replace-Once $yml '(?m)(服务器的HTTP端口[^\r\n]*\r?\n[ \t]*port:[ \t]*)\d+' ('${1}' + $Cfg.ServerPort) 'server.port'
    $yml = Replace-Once $yml '(?m)(com\.youyou:[ \t]*).*' '${1}info' 'logging.level.com.youyou'
    $yml = Replace-Once $yml '(?m)(热部署开关[^\r\n]*\r?\n[ \t]*enabled:[ \t]*).*' '${1}false' 'devtools.restart'
    $yml = Replace-Once $yml '(?m)(#[ \t]*地址\r?\n[ \t]*host:[ \t]*).*' ('${1}' + $Cfg.RedisHost) 'redis.host'
    $yml = Replace-Once $yml '(?m)(端口，默认为6379[^\r\n]*\r?\n[ \t]*port:[ \t]*)\d+' ('${1}' + $Cfg.RedisPort) 'redis.port'
    $yml = Replace-Once $yml '(?m)(数据库索引[^\r\n]*\r?\n[ \t]*database:[ \t]*).*' ('${1}' + $Cfg.RedisDatabase) 'redis.database'
    $yml = Replace-Once $yml '(?m)(#[ \t]*密码\r?\n[ \t]*password:[ \t]*).*' ('${1}' + $Cfg.RedisPassword) 'redis.password'
    $yml = Replace-Once $yml '(?m)(pathMapping:[ \t]*).*' '${1}/prod-api' 'swagger.pathMapping'

    $druid = Read-Utf8 $srcDruid
    $jdbc = 'jdbc:postgresql://{0}:{1}/{2}?useUnicode=true&characterEncoding=UTF-8&allowMultiQueries=true&serverTimezone=Asia/Shanghai' -f $Cfg.DbHost, $Cfg.DbPort, $Cfg.DbName
    $druid = Replace-Once $druid '(?m)(master:\r?\n[ \t]*url:[ \t]*).*' ('${1}' + $jdbc) 'jdbc url'
    $druid = Replace-Once $druid '(?m)(master:\r?\n[ \t]*url:[ \t]*[^\r\n]+\r?\n[ \t]*username:[ \t]*).*' ('${1}' + $Cfg.DbUser) 'db username'
    $druid = Replace-Once $druid '(?m)(master:\r?\n[ \t]*url:[ \t]*[^\r\n]+\r?\n[ \t]*username:[ \t]*[^\r\n]+\r?\n[ \t]*password:[ \t]*).*' ('${1}' + $Cfg.DbPassword) 'db password'

    $cfgDir = Join-Path $Release 'backend\config'
    Write-Utf8 (Join-Path $cfgDir 'application.yml') $yml
    Write-Utf8 (Join-Path $cfgDir 'application-druid.yml') $druid

    $nginx = @"
# 新生儿护理工作台 · Nginx
# 静态页走本机，接口转到后端 $($Cfg.ServerPort)。前端生产环境 VITE_APP_BASE_API=/prod-api
#
# 使用：
#   1. 把本文件拷到 conf.d，或 include 进 nginx.conf
#   2. 按实际修改 root、listen、server_name
#   3. nginx -t && nginx -s reload
#
# 同机部署时：本机 $($Cfg.NginxListenPort) → 静态资源，/prod-api → 后端端口
# 端口必须是 1–65535。70000 非法，Nginx 会报 invalid port。
# 后端 application.yml 的 server.port 要和这里一致。

upstream nursing_api {
    server 127.0.0.1:$($Cfg.ServerPort);
    keepalive 32;
}

server {
    listen       $($Cfg.NginxListenPort);
    server_name  _;

    # 改成 release/web 的实际路径
    root   $($Cfg.NginxWebRoot);
    index  index.html;

    charset utf-8;
    client_max_body_size 110m;

    gzip on;
    gzip_static on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript application/xml image/svg+xml;

    location / {
        try_files `$uri `$uri/ /index.html;
    }

    location /prod-api/ {
        proxy_pass         http://nursing_api/;
        proxy_http_version 1.1;
        proxy_set_header   Host              `$host;
        proxy_set_header   X-Real-IP         `$remote_addr;
        proxy_set_header   X-Forwarded-For   `$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto `$scheme;
        proxy_set_header   Connection        "";
        proxy_connect_timeout 30s;
        proxy_send_timeout    120s;
        proxy_read_timeout    120s;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)`$ {
        expires 7d;
        access_log off;
        try_files `$uri =404;
    }
}
"@
    Write-Utf8 (Join-Path $Release 'nginx\nursing.conf') $nginx

    Write-BackendScripts
    Ok '配置已写入 release/ 与 youyou-ui-vue3/.env.app'
}

function Write-BackendScripts {
    $dir = Join-Path $Release 'backend'
    Write-Utf8 (Join-Path $dir 'start.bat') @"
@echo off
chcp 65001 >nul
cd /d %~dp0
set AppName=youyou-admin.jar
set JAVA_OPTS=--spring.config.additional-location=file:./config/

for /f "tokens=1" %%a in ('jps -l 2^>nul ^| findstr /i "%AppName%"') do (
    echo %AppName% 已在运行，pid=%%a
    goto :done
)

if not exist logs mkdir logs
start "youyou-admin" java %JAVA_OPTS% -jar %AppName%
echo 已启动 %AppName%
:done
if /i not "%~1"=="nopause" pause
"@

    Write-Utf8 (Join-Path $dir 'stop.bat') @"
@echo off
chcp 65001 >nul
cd /d %~dp0
set AppName=youyou-admin.jar
for /f "tokens=1" %%a in ('jps -l 2^>nul ^| findstr /i "%AppName%"') do (
    echo 停止 pid=%%a
    taskkill /PID %%a /F
    goto :done
)
echo 未在运行
:done
if /i not "%~1"=="nopause" pause
"@

    Write-Utf8 (Join-Path $dir 'restart.bat') @"
@echo off
chcp 65001 >nul
cd /d %~dp0
call stop.bat nopause
timeout /t 2 /nobreak >nul
call start.bat nopause
"@

    Write-Utf8Lf (Join-Path $dir 'start.sh') @'
#!/bin/sh
cd "$(dirname "$0")"
AppName=youyou-admin.jar
JAVA_OPTS="--spring.config.additional-location=file:./config/"
mkdir -p logs

pid=$(ps -ef | grep "$AppName" | grep -v grep | awk '{print $2}')
if [ -n "$pid" ]; then
    echo "$AppName already running, pid=$pid"
    exit 0
fi

nohup java $JAVA_OPTS -jar "$AppName" > logs/startup.log 2>&1 &
echo $! > logs/app.pid
echo "started $AppName pid=$!"
'@

    Write-Utf8Lf (Join-Path $dir 'stop.sh') @'
#!/bin/sh
cd "$(dirname "$0")"
AppName=youyou-admin.jar

pid=$(ps -ef | grep "$AppName" | grep -v grep | awk '{print $2}')
if [ -z "$pid" ]; then
    echo "$AppName is not running"
    rm -f logs/app.pid
    exit 0
fi

echo "stopping pid=$pid"
kill "$pid"
for i in 1 2 3 4 5 6 7 8 9 10; do
    pid=$(ps -ef | grep "$AppName" | grep -v grep | awk '{print $2}')
    [ -z "$pid" ] && break
    sleep 1
done
if [ -n "$pid" ]; then
    kill -9 "$pid"
    echo "killed pid=$pid"
else
    echo "stopped $AppName"
fi
rm -f logs/app.pid
'@

    Write-Utf8Lf (Join-Path $dir 'restart.sh') @'
#!/bin/sh
cd "$(dirname "$0")"
./stop.sh
sleep 2
./start.sh
echo "restarted youyou-admin.jar"
'@
}

function Invoke-Checked([string]$File, [string[]]$ArgList, [string]$WorkDir) {
    Info ("执行：{0} {1}" -f $File, ($ArgList -join ' '))
    Push-Location $WorkDir
    try {
        & $File @ArgList
        if ($null -ne $LASTEXITCODE -and $LASTEXITCODE -ne 0) {
            Die ("失败，exit={0}：{1}" -f $LASTEXITCODE, $File)
        }
    } finally {
        Pop-Location
    }
}

function Build-Backend {
    Need-Command mvn
    Info 'Maven 打包后端…'
    Invoke-Checked 'mvn' @('-pl', 'youyou-admin', '-am', 'package', '-DskipTests') $Root
    $jar = Join-Path $Root 'youyou-admin\target\youyou-admin.jar'
    if (-not (Test-Path $jar)) { Die "没有生成 $jar" }
    Copy-Item $jar (Join-Path $Release 'backend\youyou-admin.jar') -Force
    Ok '后端 jar 已放入 release/backend/'
}

function Build-Web {
    Need-Command npm
    Info 'Vite 生产构建（PC）…'
    $nm = Join-Path $Ui 'node_modules'
    if (-not (Test-Path $nm)) {
        Invoke-Checked 'npm' @('install') $Ui
    }
    Invoke-Checked 'npm' @('run', 'build:prod') $Ui
    $dist = Join-Path $Ui 'dist'
    $web = Join-Path $Release 'web'
    if (Test-Path $web) { Remove-Item $web -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $web | Out-Null
    Copy-Item (Join-Path $dist '*') $web -Recurse -Force
    Ok 'PC 前端已放入 release/web/'
}

function Build-Android($Cfg) {
    Need-Command npm
    $sdk = $Cfg.AndroidSdk
    if ([string]::IsNullOrWhiteSpace($sdk)) { $sdk = $env:ANDROID_HOME }
    if ([string]::IsNullOrWhiteSpace($sdk) -or -not (Test-Path $sdk)) {
        Die "找不到 Android SDK。请改 pack.config.ps1 的 AndroidSdk，或设置 ANDROID_HOME。"
    }
    $env:ANDROID_HOME = $sdk
    $env:ANDROID_SDK_ROOT = $sdk
    if (-not $env:JAVA_HOME -and (Test-Path 'D:\tools\zulu-21\zulu21.38.21-ca-jdk21.0.5-win_x64')) {
        $env:JAVA_HOME = 'D:\tools\zulu-21\zulu21.38.21-ca-jdk21.0.5-win_x64'
    }
    Info ("Android SDK = {0}" -f $sdk)
    $nm = Join-Path $Ui 'node_modules'
    if (-not (Test-Path $nm)) {
        Invoke-Checked 'npm' @('install') $Ui
    }
    Info 'Vite App 构建 + cap sync…'
    Invoke-Checked 'npm' @('run', 'build:app') $Ui
    $android = Join-Path $Ui 'android'
    $gp = Join-Path $android 'gradle.properties'
    $gpText = Read-Utf8 $gp
    if ($gpText -notmatch 'android.overridePathCheck') {
        Write-Utf8 $gp ($gpText.TrimEnd() + "`r`nandroid.overridePathCheck=true`r`n")
    }
    Write-Utf8 (Join-Path $android 'local.properties') ("sdk.dir=" + ($sdk -replace '\\', '/') + "`r`n")
    Info 'Gradle assembleDebug…'
    $gradlew = Join-Path $android 'gradlew.bat'
    Invoke-Checked $gradlew @('assembleDebug', '--no-daemon') $android
    $apk = Join-Path $android 'app\build\outputs\apk\debug\app-debug.apk'
    if (-not (Test-Path $apk)) { Die "没有生成 $apk" }

    $outAndroid = Join-Path $Release 'android'
    if (Test-Path $outAndroid) { Remove-Item $outAndroid -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $outAndroid | Out-Null
    Copy-Item $apk (Join-Path $outAndroid 'app-debug.apk') -Force
    Write-Utf8 (Join-Path $outAndroid 'README.md') @"
# Android 安装包

默认服务器已打进包内：$(Get-AppServer $Cfg.PublicUrl)
登录页只填账号密码。包名 ``com.nursing.workbench``。

把 ``app-debug.apk`` 拷到手机安装即可（需允许未知来源）。

源码工程在 ``youyou-ui-vue3/android``，需要重打时运行 ``pack.bat -Target android``。
"@
    Ok ("APK 已放入 release/android/app-debug.apk （{0:N1} MB）" -f ((Get-Item $apk).Length / 1MB))
}

function Copy-Sql {
    $src = Join-Path $Root 'sql\init.sql'
    $dstDir = Join-Path $Release 'sql'
    New-Item -ItemType Directory -Force -Path $dstDir | Out-Null
    Copy-Item $src (Join-Path $dstDir 'init.sql') -Force
}

function Write-ReleaseReadme($Cfg) {
    $app = Get-AppServer $Cfg.PublicUrl
    $apkLine = if ($Cfg.Target -in @('all', 'android')) {
        "Android 安装包已放入 ``android/app-debug.apk``，接口 ``$app``。拷到手机安装即可。"
    } else {
        "本次未打 Android。需要 APK 时运行 ``pack.bat -Target android``。"
    }
    Write-Utf8 (Join-Path $Release 'README.md') @"
# 部署包 · 新生儿护理工作台

$apkLine

## 内容

| 路径 | 说明 |
|---|---|
| ``web/`` | PC 前端静态资源（生产构建，接口前缀 ``/prod-api``） |
| ``backend/youyou-admin.jar`` | 后端服务，监听 $($Cfg.ServerPort) |
| ``backend/config/`` | 可改的库、Redis、上传目录；启动时覆盖 jar 内配置 |
| ``nginx/nursing.conf`` | Nginx：静态页 + 反代接口 |
| ``sql/init.sql`` | 空库一次性安装（有数据勿重复执行） |
| ``android/app-debug.apk`` | Android 安装包 |

对外访问：``$($Cfg.PublicUrl)``  
App 接口：``$app``

## 启动顺序

1. PostgreSQL、Redis 可用，且与 ``backend/config`` 里地址一致。空库先导入 ``sql/init.sql``。
2. 启动后端（在 ``backend`` 目录）：

Windows：``start.bat`` / ``stop.bat`` / ``restart.bat``  
Linux：``chmod +x *.sh`` 后 ``./start.sh`` / ``./stop.sh`` / ``./restart.sh``

从 Windows 拷到 Linux 后若提示「无法执行 / 找不到需要的文件」，是换行符问题，在 ``backend`` 目录执行：

$('```')bash
sed -i 's/\r`$//' *.sh
chmod +x *.sh
./start.sh
$('```')

$('```')bash
java -jar youyou-admin.jar --spring.config.additional-location=file:./config/
$('```')

3. 把 ``web/`` 放到 Nginx 的 ``root``（当前配置是 ``$($Cfg.NginxWebRoot)``，按机器改 ``nginx/nursing.conf``）。
4. 加载 conf 后 ``nginx -t``，再 reload。浏览器访问 $($Cfg.PublicUrl)，不要直接打前端开发端口。

默认超管：``admin`` / ``admin123``。相册走 RustFS，参数在后台「参数设置」``nursing.oss.*``。
"@

    $stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Write-Utf8 (Join-Path $Release 'PACK-INFO.txt') @"
打包时间: $stamp
对外地址: $($Cfg.PublicUrl)
App 接口: $app
后端端口: $($Cfg.ServerPort)
上传目录: $($Cfg.UploadPath)
PostgreSQL: $($Cfg.DbHost):$($Cfg.DbPort)/$($Cfg.DbName)  user=$($Cfg.DbUser)
Redis: $($Cfg.RedisHost):$($Cfg.RedisPort) db=$($Cfg.RedisDatabase)
Nginx: listen $($Cfg.NginxListenPort)  root $($Cfg.NginxWebRoot)
本次产物: $($Cfg.Target)
"@
}

# ---- main ----
$cfg = Load-PackConfig
if ($Target) { $cfg.Target = $Target }

$interactive = -not $Yes
if ($interactive) {
    $cfg = Prompt-Config $cfg
}

$cfg.PublicUrl = Normalize-PublicUrl $cfg.PublicUrl
Assert-Port $cfg.ServerPort '后端'
Assert-Port $cfg.NginxListenPort 'Nginx listen'
Assert-Port $cfg.DbPort 'PostgreSQL'
Assert-Port $cfg.RedisPort 'Redis'
Show-Summary $cfg

if ($interactive -and -not $Yes) {
    $go = Read-Host '开始打包？(Y/n)'
    if ($go -and $go.Trim() -notmatch '^(y|yes|是)?$') {
        Write-Host '已取消。'
        exit 0
    }
}

Save-PackConfig $cfg
Apply-Configs $cfg
Copy-Sql

$needBackend = $cfg.Target -in @('all', 'server', 'backend')
$needWeb = $cfg.Target -in @('all', 'server', 'web')
$needAndroid = $cfg.Target -in @('all', 'android')

if ($ConfigOnly) {
    Write-ReleaseReadme $cfg
    Ok '只改了配置，没有编译。产物配置在 release\'
    exit 0
}

# App 构建会覆盖 dist，所以先打 Android，再打 PC 前端
if ($needBackend) { Build-Backend }
if ($needAndroid) { Build-Android $cfg }
if ($needWeb) { Build-Web }

Write-ReleaseReadme $cfg
Ok ''
Ok '打包完成。产物在 release\'
if ($needAndroid) {
    Ok '  APK: release\android\app-debug.apk'
}
if ($needWeb) {
    Ok '  网页: release\web\'
}
if ($needBackend) {
    Ok '  后端: release\backend\youyou-admin.jar'
}
