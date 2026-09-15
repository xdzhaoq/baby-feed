# 打包配置（可用记事本改，或运行 pack.bat 时按提示改）
# 复制本文件为 pack.config.ps1 后填入真实地址和密码。pack.config.ps1 已加入 .gitignore，不要提交。
# 密码等会写进 release/backend/config，不会改你本地开发用的 youyou-admin 源码配置。

# 浏览器和手机 App 打开的地址（不要末尾斜杠；不要带 /prod-api）
$PublicUrl = 'http://127.0.0.1'

# 后端 jar 监听端口（Nginx /prod-api 反代到这里）。必须是 1–65535，不能写 70000
$ServerPort = 8080

# 上传目录。Linux 服务器一般用 /home/youyou/uploadPath
$UploadPath = 'D:/youyou/uploadPath'

# PostgreSQL
$DbHost = '127.0.0.1'
$DbPort = 5432
$DbName = 'youyou'
$DbUser = 'postgres'
$DbPassword = 'postgres'

# Redis（5.x 走 RESP2，Lettuce 默认即可）
$RedisHost = '127.0.0.1'
$RedisPort = 6379
$RedisDatabase = 0
$RedisPassword = ''

# Nginx（打进 release/nginx/nursing.conf）
$NginxListenPort = 80
$NginxWebRoot = '/opt/nursing/web'

# 打哪些：all / server / backend / web / android
# all=后端+PC+APK；server=后端+PC（不要 APK）
$Target = 'server'

# Android 命令行 SDK。空则用环境变量 ANDROID_HOME
$AndroidSdk = 'D:\tools\android-sdk'
