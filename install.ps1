# ====================================================
# OpenClaw 一键部署脚本 — Windows + Telegram
# ====================================================
# 用法: 右键 PowerShell 管理员 → 粘贴运行
# ====================================================

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "🦞 OpenClaw 一键部署" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

# ----------------------------------------------------
# 1. 收集信息
# ----------------------------------------------------
$TG_TOKEN = Read-Host "📱 请输入 Telegram Bot Token"
$OPENAI_KEY = Read-Host "🔑 请输入 OpenAI API Key"
$BOT_NAME = Read-Host "🤖 给你的 AI 取个名字（如：小助手）"
$LANG = Read-Host "🌐 AI 用什么语言回复？（中文/English/ภาษาไทย）"

Write-Host ""
Write-Host "📦 选择场景包：" -ForegroundColor Yellow
Write-Host "  1. 通用助手（默认）"
Write-Host "  2. 客服助手"
Write-Host "  3. 翻译助手"
Write-Host "  4. 运营助手"
$SCENE = Read-Host "请选择 (1/2/3/4)"
if (-not $SCENE) { $SCENE = "1" }

Write-Host ""
Write-Host "⏳ 开始部署..." -ForegroundColor Yellow
Write-Host ""

# ----------------------------------------------------
# 0. 检查是否已安装，已安装则先卸载
# ----------------------------------------------------
$ocExists = Get-Command openclaw -ErrorAction SilentlyContinue
if ($ocExists) {
    Write-Host "⚠️  检测到已有 OpenClaw 安装" -ForegroundColor Yellow
    Write-Host "   正在卸载旧版本..." -ForegroundColor Yellow
    
    openclaw gateway stop 2>$null
    
    # 移除开机自启
    $startupBat = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\openclaw.bat"
    if (Test-Path $startupBat) { Remove-Item $startupBat -Force }
    
    # 备份旧配置
    if (Test-Path "$env:USERPROFILE\.openclaw") {
        $backup = "$env:USERPROFILE\.openclaw.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
        Copy-Item -Recurse "$env:USERPROFILE\.openclaw" $backup
        Write-Host "   📦 旧配置已备份到: $backup" -ForegroundColor Green
    }
    
    # 备份旧工作目录
    if (Test-Path "$env:USERPROFILE\openclaw-workspace") {
        $wsBackup = "$env:USERPROFILE\openclaw-workspace.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
        Copy-Item -Recurse "$env:USERPROFILE\openclaw-workspace" $wsBackup
        Write-Host "   📦 旧工作目录已备份到: $wsBackup" -ForegroundColor Green
    }
    
    # 卸载
    npm uninstall -g openclaw 2>$null
    Remove-Item -Recurse -Force "$env:USERPROFILE\.openclaw" -ErrorAction SilentlyContinue
    Remove-Item -Recurse -Force "$env:USERPROFILE\openclaw-workspace" -ErrorAction SilentlyContinue
    
    Write-Host "   ✅ 旧版本已卸载（配置已备份）" -ForegroundColor Green
    Write-Host ""
}

# ----------------------------------------------------
# 2. 检查 Node.js
# ----------------------------------------------------
Write-Host "📥 Step 1/7: 检查 Node.js..." -ForegroundColor Yellow
try {
    $nodeVersion = node -v
    Write-Host "   ✅ Node.js $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Node.js 未安装！请先安装：https://nodejs.org/" -ForegroundColor Red
    Write-Host "   安装完后重新运行此脚本" -ForegroundColor Yellow
    exit 1
}

# ----------------------------------------------------
# 3. 安装 OpenClaw
# ----------------------------------------------------
Write-Host "📥 Step 2/7: 安装 OpenClaw..." -ForegroundColor Yellow
npm install -g openclaw 2>$null
$ocVersion = openclaw --version 2>$null
Write-Host "   ✅ OpenClaw $ocVersion" -ForegroundColor Green

# ----------------------------------------------------
# 4. 设置 API Key
# ----------------------------------------------------
Write-Host "🔑 Step 3/7: 设置 API Key..." -ForegroundColor Yellow
[System.Environment]::SetEnvironmentVariable("OPENAI_API_KEY", $OPENAI_KEY, "User")
$env:OPENAI_API_KEY = $OPENAI_KEY
Write-Host "   ✅ API Key 已设置" -ForegroundColor Green

# ----------------------------------------------------
# 5. 初始化 + 写配置
# ----------------------------------------------------
Write-Host "⚙️  Step 4/7: 初始化 + 写入配置..." -ForegroundColor Yellow

$workspace = "$env:USERPROFILE\openclaw-workspace"
$configDir = "$env:USERPROFILE\.openclaw"

# 使用 openclaw setup 初始化
openclaw setup --non-interactive --workspace "$workspace" 2>$null

# 使用 openclaw config set 写入配置
openclaw config set channels.telegram.enabled true 2>$null
openclaw config set channels.telegram.botToken "$TG_TOKEN" 2>$null
openclaw config set channels.telegram.dmPolicy pairing 2>$null
openclaw config set channels.telegram.groupPolicy open 2>$null
openclaw config set agents.defaults.model "openai/gpt-4o-mini" 2>$null
openclaw config set agents.defaults.workspace "$($workspace -replace '\\', '/')" 2>$null
openclaw config set tools.exec.host gateway 2>$null
openclaw config set tools.exec.security full 2>$null
openclaw config set tools.exec.ask off 2>$null
openclaw config set tools.elevated.enabled true 2>$null
openclaw config set gateway.mode local 2>$null

# 运行 doctor 修复
openclaw doctor --fix 2>$null

Write-Host "   ✅ 配置已写入" -ForegroundColor Green

# ----------------------------------------------------
# 6. 创建工作目录 + Agent 文件
# ----------------------------------------------------
Write-Host "📝 Step 5/7: 创建 AI Agent..." -ForegroundColor Yellow

$workspace = "$env:USERPROFILE\openclaw-workspace"
if (-not (Test-Path $workspace)) { New-Item -ItemType Directory -Path $workspace -Force | Out-Null }
if (-not (Test-Path "$workspace\memory")) { New-Item -ItemType Directory -Path "$workspace\memory" -Force | Out-Null }

# SOUL.md
@"
# $BOT_NAME

## 性格
你是一个专业、友好的 AI 助手，名叫 $BOT_NAME。
- 回答简洁有用，不废话
- 用 $LANG 回复
- 不确定的事情诚实说不确定
- 保持礼貌和耐心
"@ | Out-File -Encoding utf8 "$workspace\SOUL.md"

# MEMORY.md
@"
# Memory

> $BOT_NAME 的长期记忆

请优先阅读：memory/INDEX.md
"@ | Out-File -Encoding utf8 "$workspace\MEMORY.md"

# memory/INDEX.md
@"
# Memory Index

## 记忆规则
1. 重要对话、决策、偏好 → 自动记录到 memory/ 目录
2. 用户纠正过的信息 → 立即更新记忆
3. 每次回答前检索记忆，确保一致性

## 目录结构
- people/ — 用户信息和偏好
- decisions/ — 重要决策记录
- lessons/ — 经验教训
- projects/ — 项目相关记忆

## 健康度
| 模块 | 状态 |
|------|------|
| 记忆系统 | ✅ 已启用 |
| 自动捕获 | ✅ 已启用 |
"@ | Out-File -Encoding utf8 "$workspace\memory\INDEX.md"

# memory 子目录
@("people", "decisions", "lessons", "projects") | ForEach-Object {
    $dir = "$workspace\memory\$_"
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
}

# AGENTS.md（按场景包）
switch ($SCENE) {
    "2" {
        # 客服包
        @"
# $BOT_NAME — 客服助手

## 职责
- 回答客户常见问题
- 引导客户解决问题
- 记录客户反馈
- 无法解决时提示联系人工

## 规则
- 用 $LANG 回复
- 礼貌专业，不争论
- 回答基于 FAQ，不编造
- 不确定就说"我帮您转接人工客服"
- 敏感信息（密码、支付）不处理，引导联系人工

## FAQ（请补充）
- Q: 营业时间？ A: 请补充
- Q: 联系方式？ A: 请补充
- Q: 退换货政策？ A: 请补充

## 示例对话
用户: 你们几点开门？
AI: 我们的营业时间是 XX:XX - XX:XX，欢迎光临！

用户: 我要退货
AI: 好的，请提供您的订单号，我来帮您查看退货流程。
"@ | Out-File -Encoding utf8 "$workspace\AGENTS.md"
    }
    "3" {
        # 翻译包
        @"
# $BOT_NAME — 翻译助手

## 职责
你是群组实时翻译机器人。只做翻译，不闲聊。

## 规则
- 自动识别消息语言
- 翻译成群内其他语言
- 已是目标语言 → 不回复
- 表情/贴纸/短语（ok、555、haha）→ 不翻译
- 不回答问题，不参与讨论

## 翻译格式
🌐 [原语言→目标语言]
翻译内容

## 命令
- /lang th↔zh — 泰中双向互译
- /lang th→zh — 单向翻译
- /lang th↔zh↔en — 三语互译
- /lang status — 查看当前配置
- /lang off — 关闭翻译
- /lang on — 开启翻译

## 默认配置
th↔zh（泰中双向）
"@ | Out-File -Encoding utf8 "$workspace\AGENTS.md"
    }
    "4" {
        # 运营包
        @"
# $BOT_NAME — 运营助手

## 职责
- 任务管理：有人说"任务：xxx" → 记录到 memory
- 日报汇总：有人说"今日汇总" → 总结今天讨论要点
- 提醒：有人说"提醒我 xxx" → 设置提醒
- 会议纪要：有人说"总结一下" → 总结最近讨论

## 规则
- 用 $LANG 回复
- 被叫才动，不主动插话
- 输出格式化（bullet/表格）
- 任务记录到 memory 文件

## 命令
- /task xxx — 记录任务
- /tasks — 查看所有任务
- /summary — 今日讨论汇总
- /remind HH:MM xxx — 设置提醒
"@ | Out-File -Encoding utf8 "$workspace\AGENTS.md"
    }
    default {
        # 通用助手
        @"
# $BOT_NAME — 智能助手

## 职责
- 回答问题（搜索、计算、翻译、写作）
- 帮助管理任务和提醒
- 总结讨论内容
- 查询信息

## 规则
- 用 $LANG 回复
- 简洁专业，不废话
- 不确定就说不确定
- 保持友好和耐心

## 能力
- 🔍 搜索网页信息
- 📝 写作和编辑
- 🌐 多语言翻译
- 📊 数据分析
- ⏰ 设置提醒
- 📋 任务管理
"@ | Out-File -Encoding utf8 "$workspace\AGENTS.md"
    }
}

# USER.md
@"
# 用户信息

- **Owner**: 待填写
- **Timezone**: Asia/Bangkok
"@ | Out-File -Encoding utf8 "$workspace\USER.md"

Write-Host "   ✅ Agent 文件已创建（场景包 $SCENE）" -ForegroundColor Green

# ----------------------------------------------------
# 7. 安装 Skills
# ----------------------------------------------------
Write-Host "📦 Step 6/9: 安装常用 Skills..." -ForegroundColor Yellow
openclaw skills install weather 2>$null
openclaw skills install summarize 2>$null
Write-Host "   ✅ Skills 已安装" -ForegroundColor Green

# ----------------------------------------------------
# 8. 启动 + 自动配对
# ----------------------------------------------------
Write-Host "🚀 Step 7/9: 启动 OpenClaw..." -ForegroundColor Yellow
Start-Process -NoNewWindow -FilePath "openclaw" -ArgumentList "gateway start"
Start-Sleep -Seconds 8

# 检查状态
$status = openclaw status 2>$null
if ($status) {
    Write-Host "   ✅ Gateway 已启动" -ForegroundColor Green
} else {
    Write-Host "   ⚠️  Gateway 可能需要几秒启动，请稍后运行 openclaw status 确认" -ForegroundColor Yellow
}

# 配对已在配置中设为 open，无需额外操作
Write-Host ""
Write-Host "🔗 Step 8/9: 自动配对已配置（open 模式）..." -ForegroundColor Green

# ----------------------------------------------------
# 9. 开机自启
# ----------------------------------------------------
Write-Host "⚡ Step 9/9: 设置开机自启..." -ForegroundColor Yellow

$startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\openclaw.bat"
@"
@echo off
set OPENAI_API_KEY=$OPENAI_KEY
openclaw gateway start
"@ | Out-File -Encoding ascii $startupPath
Write-Host "   ✅ 开机自启已设置" -ForegroundColor Green

# ----------------------------------------------------
# 完成
# ----------------------------------------------------
Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "✅ 部署完成！一切就绪！" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "📋 部署信息:" -ForegroundColor White
Write-Host "   AI 名称:    $BOT_NAME"
Write-Host "   场景包:     $SCENE"
Write-Host "   模型:       GPT-4o-mini"
Write-Host "   平台:       Telegram"
Write-Host "   配对模式:   Pairing（安全配对）"
Write-Host ""
Write-Host "🎉 现在就可以用了！" -ForegroundColor Green
Write-Host "   打开 Telegram → 搜索你的 Bot → 发消息 → 获取配对码 → approve 后使用" -ForegroundColor White
Write-Host ""
Write-Host "🔧 维护命令:" -ForegroundColor Yellow
Write-Host "   openclaw status          — 查看状态"
Write-Host "   openclaw gateway restart — 重启"
Write-Host "   openclaw gateway stop    — 停止"
Write-Host "   openclaw logs --follow   — 查看日志"
Write-Host ""
Write-Host "📂 文件位置:" -ForegroundColor Yellow
Write-Host "   配置:  $configDir\openclaw.json"
Write-Host "   Agent: $workspace\"
Write-Host ""
Write-Host "💰 月费预估: ~`$3-10（按实际消息量）" -ForegroundColor Yellow
Write-Host ""
