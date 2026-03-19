# OpenClaw 15 分钟快速部署（Windows + Telegram）

---

## 准备（部署前让客户先做好）

发给客户这 3 件事：

```
部署前请准备：
1. 打开 https://nodejs.org/ → 下载安装 LTS 版本（一路下一步）
2. 打开 Telegram → 搜索 @BotFather → 发 /newbot → 取名 → 拿到 Bot Token
3. 打开 https://platform.openai.com/api-keys → 注册/登录 → 创建 API Key
```

---

## 部署开始（15 分钟）

### 第 1 分钟：远程连接

```
客户电脑开 PowerShell（管理员模式）
远程：用 AnyDesk / ToDesk / TeamViewer 连上
```

### 第 2-3 分钟：安装 OpenClaw

```powershell
npm install -g openclaw
openclaw --version
```

### 第 4 分钟：初始化

```powershell
openclaw init
```

### 第 5-6 分钟：写配置

```powershell
# 一键写入配置
$config = @'
{
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "客户TOKEN"
    }
  },
  "models": {
    "default": "openai/gpt-4o-mini"
  }
}
'@
$config | Out-File -Encoding utf8 "$env:USERPROFILE\.openclaw\openclaw.json"
```

### 第 7 分钟：设置 API Key

```powershell
[System.Environment]::SetEnvironmentVariable("OPENAI_API_KEY", "客户KEY", "User")
$env:OPENAI_API_KEY = "客户KEY"
```

### 第 8-10 分钟：创建 Agent

```powershell
mkdir "$env:USERPROFILE\openclaw-workspace" -Force
```

**AGENTS.md**（根据客户选的档位/场景包写）：

```powershell
@'
# AI 助手

你是 XXX 公司的智能助手。

## 职责
- 回答团队成员的问题
- 帮助管理任务和提醒
- 总结讨论内容

## 规则
- 用中文回复
- 简洁专业
- 不确定的事情说"我不确定"
'@ | Out-File -Encoding utf8 "$env:USERPROFILE\openclaw-workspace\AGENTS.md"
```

**SOUL.md**：

```powershell
@'
# 性格
你是一个专业、友好的 AI 助手。回答简洁有用，不废话。
'@ | Out-File -Encoding utf8 "$env:USERPROFILE\openclaw-workspace\SOUL.md"
```

### 第 11 分钟：启动

```powershell
openclaw gateway start
```

### 第 12 分钟：验证

```powershell
openclaw status
```

### 第 13 分钟：Telegram 配对

1. 客户打开 Telegram → 搜索 Bot → 发一条消息
2. 看到 pairing code

```powershell
openclaw pairing list telegram
openclaw pairing approve telegram CODE
```

### 第 14 分钟：测试

客户在 Telegram 发消息 → AI 回复 → 确认正常

### 第 15 分钟：设置开机自启

```powershell
$bat = @"
@echo off
set OPENAI_API_KEY=客户KEY
openclaw gateway start
"@
$bat | Out-File -Encoding ascii "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\openclaw.bat"
```

---

## 部署完成 Checklist

```
□ Node.js 已安装
□ OpenClaw 已安装
□ openclaw.json 配置正确
□ OPENAI_API_KEY 已设置
□ AGENTS.md + SOUL.md 已创建
□ Gateway 已启动
□ Telegram Bot 已配对
□ 测试消息正常回复
□ 开机自启已设置
□ 客户已知道基本命令（status/restart）
```

---

## 交付给客户的卡片

```
✅ 部署完成！

你的 AI 助手已上线：
• Telegram Bot: @你的bot名
• 模型: GPT-4o-mini
• 状态: 运行中

常用命令（PowerShell）:
• openclaw status — 查看状态
• openclaw gateway restart — 重启
• openclaw logs --follow — 看日志

月费预估: ~$3-10/月（按实际使用量）

有问题联系：Victor（微信/Telegram）
```

---

## 场景包快速模板

### 客服包 AGENTS.md
```markdown
# 客服助手

你是 XXX 公司的客服 AI。

## 职责
- 回答客户常见问题
- 引导客户解决问题
- 无法解决时转人工

## FAQ
- Q: 营业时间？ A: 周一至周六 9:00-18:00
- Q: 怎么联系？ A: 电话 xxx / 微信 xxx
（客户提供 FAQ 列表填入）

## 规则
- 礼貌专业
- 不确定就说"我帮您转接人工客服"
```

### 翻译包 AGENTS.md
```markdown
# 翻译助手

你是群组翻译机器人。只做翻译，不闲聊。

## 规则
- 检测到泰语 → 翻译成中文
- 检测到中文 → 翻译成泰语
- 已是目标语言 → 不回复
- 表情/短语（ok、555）→ 不翻译

## 格式
🌐 [TH→ZH]
翻译内容
```

### 运营包 AGENTS.md
```markdown
# 运营助手

你是团队运营 AI。

## 职责
- 记录任务：有人说"任务：xxx" → 记下来
- 每日汇总：有人说"今日汇总" → 总结今天讨论
- 提醒：有人说"提醒我 xxx" → 设置提醒
- 会议纪要：有人说"总结一下" → 总结最近讨论

## 规则
- 主动性低，被叫才动
- 格式化输出（bullet/表格）
```
