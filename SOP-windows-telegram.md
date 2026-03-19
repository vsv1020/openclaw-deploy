# OpenClaw 代部署 SOP — Windows + Telegram

---

## 核心卖点（给客户讲）

### 一句话
**把 AI 装进你的 Telegram，24 小时帮你干活。**

### 客户痛点 → 解法

| 痛点 | OpenClaw 解法 |
|------|-------------|
| 每天重复回答客户同样的问题 | AI 自动回复，7×24 不休息 |
| 员工下班后没人值班 | Bot 全天候在线 |
| 想用 ChatGPT 但不会搭 | 一键部署到 Telegram，零代码 |
| 担心数据泄露 | 跑在你自己的电脑上，数据不出门 |
| 多人协作群消息太多 | AI 自动总结、分类、提醒 |

### 跟 ChatGPT 的区别

| | ChatGPT | OpenClaw |
|---|---------|----------|
| 在哪用 | 网页/App | 直接在 Telegram 群里 |
| 数据 | 存在 OpenAI 服务器 | 存在你自己电脑 |
| 自定义 | 不能 | 完全自定义 AI 性格和能力 |
| 多人用 | 每人要登录 | 群里所有人直接用 |
| 费用 | $20/月/人 | 部署一次，按量付费（$3-10/月） |

### 能做什么

- 🤖 智能客服 — 自动回答常见问题
- 📋 任务管理 — 在群里下达任务、追踪进度
- 🌐 翻译 — 群内实时多语言翻译
- 📊 数据查询 — 连接你的业务系统查数据
- 📝 会议纪要 — 自动总结群聊内容
- ⏰ 提醒 — 定时提醒、日程管理

---

## 可选功能菜单（给客户选）

### 🧠 Soul（AI 性格模板）

| 模板 | 适合 | 说明 |
|------|------|------|
| 专业客服 | 电商/服务业 | 礼貌、精准、不闲聊 |
| 运营助手 | 团队管理 | 任务追踪、日报汇总、提醒 |
| 翻译官 | 跨国团队 | 只做翻译，不废话 |
| 销售顾问 | 销售团队 | 产品推荐、报价、跟进 |
| 知识库 | 企业内部 | 基于公司文档回答问题 |
| 自定义 | 任何场景 | 按客户需求定制 |

### 🔧 Tools（内置工具）

| 工具 | 功能 | 需要 |
|------|------|------|
| 网页搜索 | AI 能上网搜信息 | ✅ 默认可用 |
| 网页抓取 | 读取链接内容并总结 | ✅ 默认可用 |
| 定时提醒 | 设闹钟、定时任务 | ✅ 默认可用 |
| 文件读写 | 读写本地文件 | ✅ 默认可用 |
| 代码执行 | 运行脚本命令 | ⚠️ 需开启 |

### 📦 Skills（可安装技能包）

| 技能 | 功能 | 安装命令 |
|------|------|---------|
| GitHub | 管理 Issues/PR/代码审查 | `openclaw skills install github` |
| Notion | 创建/管理 Notion 页面 | `openclaw skills install notion` |
| 天气 | 查天气预报 | `openclaw skills install weather` |
| 总结 | 总结网页/视频/播客 | `openclaw skills install summarize` |
| Trello | 管理看板任务 | `openclaw skills install trello` |
| Slack | 跨平台消息 | `openclaw skills install slack` |
| 1Password | 安全管理密码 | `openclaw skills install 1password` |
| Obsidian | 管理笔记库 | `openclaw skills install obsidian` |
| Apple Notes | 管理苹果备忘录 | `openclaw skills install apple-notes` |
| Apple Reminders | 管理苹果提醒 | `openclaw skills install apple-reminders` |
| Things | 管理 Things 3 任务 | `openclaw skills install things-mac` |

### 📱 支持平台

| 平台 | 状态 | 说明 |
|------|------|------|
| Telegram | ✅ | Bot Token 即可 |
| Discord | ✅ | Bot Token + Server |
| LINE | ✅ 插件 | 需安装插件 + 公网 HTTPS |
| 微信 | ✅ 插件 | 需安装插件 |
| WhatsApp | ✅ | 需配置 |
| Signal | ✅ | 需配置 |
| iMessage | ✅ | 仅 Mac |
| Slack | ✅ | 需配置 |
| IRC | ✅ | 需配置 |

### 💰 定价（正式）

| 档位 | 一次性 | 月费 | 目标客户 | 包含 |
|------|--------|------|---------|------|
| 🟢 个人版 | $99 | — | 个人/自由职业 | 安装 + 1 平台 + 基础 Soul + 7 天支持 |
| 🔵 团队版 | $299 | $29/月 | 小团队 5-20 人 | 安装 + 多平台 + 自定义 Soul + 3 Skills + 30 天维护 |
| 🟣 企业版 | $499 | $99/月 | 企业 20+ 人 | 全部 + 对接业务系统 + 无限 Skills + 专属维护 |

### 📦 场景包（附加）

| 场景包 | 价格 | 包含 |
|--------|------|------|
| 🤖 客服包 | +$49 | 自动回复模板 + FAQ 知识库 + 工单流转 |
| 🌐 翻译包 | +$49 | 多语互译 + /lang 命令 + 语言自动识别 |
| 📋 运营包 | +$79 | 任务管理 + 日报汇总 + 提醒 + 会议纪要 |
| 🔗 集成包 | +$99 | 对接 Notion/GitHub/Trello 等第三方 |

### 💡 获客策略

| 渠道 | 行动 | 目标 |
|------|------|------|
| 私域 | Victor 1v1 触达认识的人 | 首批 3-5 单 |
| 小红书 | 「AI 帮我管团队」系列 3 篇 | 引流 |
| LINE/微信群 | 东南亚华人商圈分享 | 触达 |
| 老客户转介绍 | 部署完送 1 个月维护 | 裂变 |

---

## 前置准备（客户提供）

| 项目 | 说明 |
|------|------|
| Telegram Bot Token | 在 Telegram 找 @BotFather → /newbot → 拿到 Token |
| OpenAI API Key | https://platform.openai.com/api-keys 创建 |
| Windows 版本 | Windows 10/11 |

---

## Step 1：安装 Node.js

1. 打开 https://nodejs.org/
2. 下载 **LTS 版本**（22.x）
3. 双击安装，全部默认下一步
4. 打开 **PowerShell**，验证：
```powershell
node -v
npm -v
```

---

## Step 2：安装 OpenClaw

PowerShell 执行：
```powershell
npm install -g openclaw
```

验证：
```powershell
openclaw --version
```

---

## Step 3：初始化

```powershell
openclaw init
```

按提示完成初始化。

---

## Step 4：配置 Telegram

编辑配置文件 `C:\Users\用户名\.openclaw\openclaw.json`：

```json
{
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "这里填客户的 Bot Token"
    }
  },
  "models": {
    "default": "openai/gpt-4o-mini"
  }
}
```

---

## Step 5：配置 API Key

PowerShell 执行：
```powershell
$env:OPENAI_API_KEY = "sk-xxx这里填客户的Key"
```

永久设置（推荐）：
```powershell
[System.Environment]::SetEnvironmentVariable("OPENAI_API_KEY", "sk-xxx", "User")
```

---

## Step 6：创建工作目录 + Agent 文件

```powershell
mkdir C:\openclaw-workspace
```

在 `C:\openclaw-workspace\` 下创建两个文件：

**AGENTS.md**：
```markdown
# AI 助手

你是一个智能助手，帮助用户回答问题、处理任务。

## 规则
- 友好、专业
- 用中文回复
- 简洁明了
```

**SOUL.md**：
```markdown
# 性格

你是一个耐心、专业的 AI 助手。回答简洁有用。
```

---

## Step 7：启动

```powershell
openclaw gateway start
```

---

## Step 8：验证

1. 打开 Telegram
2. 搜索你创建的 Bot
3. 发送一条消息
4. 等待 AI 回复

如果收到 pairing code：
```powershell
openclaw pairing list telegram
openclaw pairing approve telegram <CODE>
```

---

## Step 9：开机自启（可选）

创建 `start-openclaw.bat`：
```bat
@echo off
set OPENAI_API_KEY=sk-xxx
openclaw gateway start
```

放入 Windows 启动文件夹：
```
Win+R → shell:startup → 把 bat 文件拖进去
```

---

## 常用命令

| 命令 | 用途 |
|------|------|
| `openclaw status` | 查看状态 |
| `openclaw gateway start` | 启动 |
| `openclaw gateway stop` | 停止 |
| `openclaw gateway restart` | 重启 |
| `openclaw pairing list telegram` | 查看配对 |
| `openclaw pairing approve telegram <CODE>` | 审批配对 |
| `openclaw logs --follow` | 查看日志 |

---

## 故障排查

| 问题 | 解决 |
|------|------|
| Bot 不回复 | 检查 `openclaw status`，确认 gateway 运行中 |
| pairing code | 用 `openclaw pairing approve` 审批 |
| API Key 错误 | 检查环境变量 `echo $env:OPENAI_API_KEY` |
| 端口占用 | 换端口：配置 `gateway.port` |

---

*SOP v1.0 — 2026-03-19*
