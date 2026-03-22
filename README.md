# OpenClaw 客户部署 SOP（Windows + Telegram 个人助手）

> Version: 2.0 | Updated: 2026-03-22 | Author: CEO

---

## 一、部署前准备

### 1.1 环境要求

| 项目 | 最低要求 |
|------|----------|
| OS | Windows 10/11（64-bit） |
| RAM | 4GB+ |
| 磁盘 | 2GB 空闲 |
| 网络 | 稳定互联网连接 |
| Node.js | v20+（推荐 v22 LTS） |

### 1.2 需要提前准备

| 项目 | 说明 | 获取方式 |
|------|------|----------|
| Telegram Bot Token | Bot 凭证 | @BotFather 创建 |
| 客户 Telegram User ID | 数字 ID | @userinfobot 获取 |
| AI Model API Key | Anthropic / MiniMax | Provider 官网申请 |
| RustDesk | 远程维护 | github.com/rustdesk/rustdesk/releases |

---

## 二、安装步骤

### Step 1: 安装 RustDesk（远程维护）

```powershell
# 下载最新版 RustDesk
# https://github.com/rustdesk/rustdesk/releases

# 静默安装
rustdesk.exe --silent-install

# 如有自建 Server，配置连接串
rustdesk.exe --config <your-encrypted-config-string>
```

**安装后：**
1. 记录客户的 RustDesk ID + 永久密码
2. 验证远程连接正常
3. RustDesk 默认开机自启（安装即服务）

### Step 2: 安装 WSL2 + Ubuntu

```powershell
# PowerShell (管理员)
wsl --install -d Ubuntu
# 重启电脑后设置 Ubuntu 用户名密码
```

### Step 3: 启用 systemd

```bash
# WSL 内执行
sudo tee /etc/wsl.conf >/dev/null <<'EOF'
[boot]
systemd=true
EOF
```

```powershell
# PowerShell 重启 WSL
wsl --shutdown
```

验证：
```bash
systemctl --user status
```

### Step 4: 安装 Node.js

```bash
# WSL 内
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs
node --version  # 确认 v22+
```

### Step 5: 安装 OpenClaw

```bash
# 方式一：npm 全局安装
npm install -g openclaw

# 方式二：pnpm
npm install -g pnpm
pnpm install -g openclaw

# 验证
openclaw --version
```

### Step 6: 初始化配置

```bash
openclaw configure
# 按向导操作：
# 1. 选择 Telegram channel
# 2. 输入 Bot Token
# 3. 配置 AI Model API Key
# 4. 选择 Gateway service → 安装
```

---

## 三、Agent 配置文件（openclaw.json）

> 替换所有 `<占位符>` 后写入客户机器 `~/.openclaw/openclaw.json`

```jsonc
{
  "agents": {
    "defaults": {
      "model": {
        "primary": "<MODEL>",                    // 例: "anthropic/claude-sonnet-4-6"
        "fallbacks": ["<FALLBACK_MODEL>"]         // 例: "anthropic/claude-sonnet-4-5"
      },
      "workspace": "<WORKSPACE_PATH>",           // 例: "/home/用户名/openclaw-workspace"
      "compaction": { "mode": "safeguard" }
    },
    "list": [
      {
        "id": "<AGENT_ID>",                      // 例: "assistant"（小写英文，唯一）
        "default": true,
        "name": "<AGENT_NAME>",                   // 例: "小助手"
        "workspace": "<WORKSPACE_PATH>",
        "model": {
          "primary": "<MODEL>",
          "fallbacks": ["<FALLBACK_MODEL>"]
        },
        "heartbeat": {
          "every": "2h",
          "target": "telegram",
          "to": "<CLIENT_TELEGRAM_USER_ID>",
          "prompt": "检查你的 NOW.md。如果有待办任务，继续执行。如果全部完成，回复 HEARTBEAT_OK。"
        },
        "tools": {
          "profile": "full",
          "fs": { "workspaceOnly": true }
        }
      }
    ]
  },

  "channels": {
    "telegram": {
      "enabled": true,
      "dmPolicy": "pairing",
      "streaming": "partial",
      "accounts": {
        "<AGENT_ID>": {
          "name": "<AGENT_NAME>",
          "enabled": true,
          "botToken": "<TELEGRAM_BOT_TOKEN>",
          "dmPolicy": "allowlist",
          "allowFrom": ["<CLIENT_TELEGRAM_USER_ID>"],
          "streaming": "partial"
        }
      }
    }
  },

  "gateway": {
    "port": 18789,
    "mode": "local",
    "bind": "loopback",
    "auth": {
      "mode": "token",
      "token": "<GATEWAY_TOKEN_64+>"              // openssl rand -hex 32
    }
  },

  "models": {
    "providers": {
      "anthropic": {
        "apiKey": "<ANTHROPIC_API_KEY>"
      }
      // 或 MiniMax（免费）:
      // "minimax-portal": {
      //   "baseUrl": "https://api.minimaxi.com/anthropic",
      //   "apiKey": "<MINIMAX_API_KEY>",
      //   "api": "anthropic-messages",
      //   "models": [{
      //     "id": "MiniMax-M2.7", "name": "MiniMax M2.7",
      //     "contextWindow": 200000, "maxTokens": 8192,
      //     "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 }
      //   }]
      // }
    }
  },

  "tools": {
    "web": {
      "search": {
        "perplexity": {
          "apiKey": "<PERPLEXITY_API_KEY>"         // 可选
        }
      }
    }
  },

  "hooks": {
    "internal": {
      "enabled": true,
      "entries": {
        "boot-md": { "enabled": true },
        "session-memory": { "enabled": true }
      }
    }
  },

  "bindings": [
    {
      "agentId": "<AGENT_ID>",
      "match": { "channel": "telegram", "accountId": "<AGENT_ID>" }
    }
  ]
}
```

### 占位符清单

| 占位符 | 说明 | 示例 |
|--------|------|------|
| `<AGENT_ID>` | Agent 唯一 ID（小写英文） | `assistant` |
| `<AGENT_NAME>` | 显示名称 | `小助手` |
| `<MODEL>` | 主模型 | `anthropic/claude-sonnet-4-6` |
| `<FALLBACK_MODEL>` | 备用模型 | `anthropic/claude-sonnet-4-5` |
| `<WORKSPACE_PATH>` | 工作目录（WSL 路径） | `/home/user/openclaw-workspace` |
| `<TELEGRAM_BOT_TOKEN>` | Bot Token | `123456:ABC-DEF...` |
| `<CLIENT_TELEGRAM_USER_ID>` | 客户 TG 数字 ID | `902773815` |
| `<GATEWAY_TOKEN_64+>` | 64 字符随机串 | `openssl rand -hex 32` 生成 |
| `<ANTHROPIC_API_KEY>` | Anthropic key | `sk-ant-...` |
| `<PERPLEXITY_API_KEY>` | 搜索 key（可选） | `pplx-...` |

---

## 四、安全加固（必做）

### 4.1 Gateway Token 加长

```bash
# 生成 64 字符随机 token
openssl rand -hex 32
```

### 4.2 文件系统隔离

已在配置文件中设置 `workspaceOnly: true`。

### 4.3 Telegram DM 配对

已在配置文件中设置 `dmPolicy: "allowlist"` + `allowFrom`。

首次使用：客户在 Telegram 给 Bot 发消息 → OpenClaw 生成配对码 → 在终端输入配对码确认。

---

## 五、Windows 系统加固（必做）

> 目标：确保电脑 7×24 不休眠、不自动重启、不被 Windows Update 中断服务。

### 5.1 关闭睡眠/休眠模式

```powershell
# PowerShell (管理员)

# 关闭所有睡眠/休眠
powercfg /change standby-timeout-ac 0
powercfg /change standby-timeout-dc 0
powercfg /change hibernate-timeout-ac 0
powercfg /change hibernate-timeout-dc 0
powercfg /change monitor-timeout-ac 0

# 彻底禁用休眠文件
powercfg /hibernate off

# 设置为高性能电源计划
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# 验证
powercfg /query
```

**GUI 备选：** 设置 → 系统 → 电源 → 屏幕和睡眠 → 全部设为「从不」

### 5.2 禁用 Windows Update 自动重启

```powershell
# PowerShell (管理员)

# 注册表禁止自动重启
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v NoAutoRebootWithLoggedOnUsers /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" /v AUOptions /t REG_DWORD /d 2 /f

# 禁用自动重启计划任务
schtasks /change /tn "\Microsoft\Windows\UpdateOrchestrator\Reboot" /disable 2>nul
schtasks /change /tn "\Microsoft\Windows\UpdateOrchestrator\Schedule Retry Scan" /disable 2>nul
schtasks /change /tn "\Microsoft\Windows\UpdateOrchestrator\Schedule Scan" /disable 2>nul
```

> AUOptions=2 = 「通知下载，通知安装」，不自动下载安装。

### 5.3 禁用自动维护任务

```powershell
# PowerShell (管理员)

# 禁用自动维护
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Schedule\Maintenance" /v MaintenanceDisabled /t REG_DWORD /d 1 /f

# 禁用维护相关计划任务
schtasks /change /tn "\Microsoft\Windows\TaskScheduler\Maintenance Configurator" /disable 2>nul
schtasks /change /tn "\Microsoft\Windows\Diagnosis\Scheduled" /disable 2>nul
schtasks /change /tn "\Microsoft\Windows\Defrag\ScheduledDefrag" /disable 2>nul
```

### 5.4 防止意外重启

```powershell
# 禁用 Windows Error Recovery 自动重启
bcdedit /set {default} recoveryenabled No

# 禁止系统故障时自动重启
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CrashControl" /v AutoReboot /t REG_DWORD /d 0 /f
```

### 5.5 验证

```powershell
powercfg /query | findstr "Sleep"
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" 2>nul
schtasks /query /tn "\Microsoft\Windows\UpdateOrchestrator\Reboot" 2>nul
```

---

## 六、开机自启配置

### 6.1 OpenClaw Gateway 自启（WSL 内）

```bash
openclaw gateway install
openclaw gateway status
```

### 6.2 WSL 开机自启（无需登录）

```powershell
# PowerShell (管理员)
schtasks /create /tn "WSL Boot" /tr "wsl.exe -d Ubuntu --exec /bin/true" /sc onstart /ru SYSTEM
```

### 6.3 启用 linger

```bash
sudo loginctl enable-linger "$(whoami)"
```

### 6.4 验证启动链

重启电脑后（不登录 Windows），从 WSL 检查：
```bash
systemctl --user is-enabled openclaw-gateway
systemctl --user status openclaw-gateway --no-pager
openclaw status
```

---

## 七、体验优化

### 7.1 SOUL.md 模板

在 workspace 根目录创建 `SOUL.md`：

```markdown
# 你的 AI 助手

## 性格
- 友好、专业、简洁
- 用中文回复（除非用户用其他语言）
- 记住用户的偏好和习惯

## 回复风格
- 直接回答问题，不废话
- 必要时用 bullet 或表格
- 不确定的事主动说明
```

### 7.2 USER.md 模板

```markdown
# 关于你

- **名字：** [客户姓名]
- **称呼：** [昵称]
- **时区：** [Asia/Bangkok]
- **语言：** 中文
- **备注：** [客户特殊需求/偏好]
```

---

## 八、增值功能

### 8.1 提醒功能

客户在 Telegram 中直接说：
- "提醒我明天下午 3 点开会"
- "每天早上 8 点提醒我吃药"

### 8.2 常用 Skills

天气查询：内置，无需配置。
网页搜索：需在配置中填入 Perplexity API Key。

### 8.3 Model Fallback

已在配置文件中设置。主模型不可用时自动切换备用。

---

## 九、验收 Checklist

```
□ 1.  RustDesk 远程连接正常
□ 2.  RustDesk ID + 密码已记录
□ 3.  睡眠/休眠已禁用
□ 4.  Windows Update 自动重启已禁用
□ 5.  自动维护任务已禁用
□ 6.  openclaw --version 正常
□ 7.  openclaw status 显示 gateway running
□ 8.  Telegram Bot 能收发消息
□ 9.  dmPolicy + allowFrom 已配置
□ 10. Gateway token ≥ 64 字符
□ 11. workspaceOnly: true
□ 12. streaming: partial 已开启
□ 13. SOUL.md + USER.md 已创建
□ 14. 重启电脑后 gateway 自动启动
□ 15. Memory 功能正常（跨会话记忆）
□ 16. 客户测试：发消息 → 收到回复
□ 17. 客户测试：提醒功能正常
```

---

## 十、故障排除

| 问题 | 解决方案 |
|------|----------|
| Bot 不回复 | `openclaw status` 检查 → `openclaw gateway restart` |
| WSL 重启后服务没起来 | 检查 `schtasks` + `loginctl enable-linger` |
| Telegram 配对失败 | 确认 Bot Token → `openclaw gateway restart` |
| 回复慢 | 检查网络；换更快的 model 或加 fallback |
| context 用尽 | `/new` 重置会话；或配置 compaction |
| 远程连接断了 | RustDesk 检查网络，确认服务运行 |
| API 额度用完 | 检查 provider 余额；fallback 自动切换 |
| Gateway token 忘了 | 查看 `~/.openclaw/openclaw.json` |

---

## 十一、维护与支持

### 日常维护
- **远程维护**：通过 RustDesk 连接
- **更新 OpenClaw**：`npm update -g openclaw`（WSL 内）
- **查看状态**：`openclaw status`

### 客户沟通模板
```
✅ AI 助手已部署完成！

📱 在 Telegram 找到 @[BotName] 开始使用
🔄 电脑重启后自动运行，无需手动操作
⚡ 如遇问题，我会通过 RustDesk 远程协助

试试发送：「你好」或「提醒我明天早上8点喝水」
```

---

*Updated: 2026-03-22 11:02 Bangkok*
