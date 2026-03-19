#!/bin/bash
# ====================================================
# OpenClaw 一键部署脚本 — macOS / Linux + Telegram
# ====================================================
# 用法:
#   curl -sL https://your-url/install.sh | bash
#   或: chmod +x install.sh && ./install.sh
# ====================================================

set -e

# Colors
G='\033[0;32m'; Y='\033[1;33m'; R='\033[0;31m'; C='\033[0;36m'; N='\033[0m'

echo ""
echo -e "${C}=====================================================${N}"
echo -e "${C}🦞 OpenClaw 一键部署${N}"
echo -e "${C}=====================================================${N}"
echo ""

# ----------------------------------------------------
# 1. 收集信息
# ----------------------------------------------------
read -p "📱 请输入 Telegram Bot Token: " TG_TOKEN
read -p "🔑 请输入 OpenAI API Key: " OPENAI_KEY
read -p "🤖 给你的 AI 取个名字（如：小助手）: " BOT_NAME
read -p "🌐 AI 用什么语言回复？（中文/English/ภาษาไทย）: " LANG

echo ""
echo -e "${Y}📦 选择场景包：${N}"
echo "  1. 通用助手（默认）"
echo "  2. 客服助手"
echo "  3. 翻译助手"
echo "  4. 运营助手"
read -p "请选择 (1/2/3/4): " SCENE
SCENE=${SCENE:-1}

echo ""
echo -e "${Y}⏳ 开始部署...${N}"
echo ""

# ----------------------------------------------------
# 2. 检查/安装 Node.js
# ----------------------------------------------------
echo -e "${Y}📥 Step 1/9: 检查 Node.js...${N}"
if command -v node &>/dev/null; then
    echo -e "${G}   ✅ Node.js $(node -v)${N}"
else
    echo -e "${Y}   ⏳ 安装 Node.js...${N}"
    OS=$(uname -s)
    if [ "$OS" = "Darwin" ]; then
        # macOS
        if command -v brew &>/dev/null; then
            brew install node
        else
            echo -e "${Y}   ⏳ 先安装 Homebrew...${N}"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            brew install node
        fi
    else
        # Linux (Debian/Ubuntu)
        if command -v apt-get &>/dev/null; then
            curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
            sudo apt-get install -y nodejs
        elif command -v dnf &>/dev/null; then
            curl -fsSL https://rpm.nodesource.com/setup_22.x | sudo bash -
            sudo dnf install -y nodejs
        elif command -v pacman &>/dev/null; then
            sudo pacman -S nodejs npm
        else
            echo -e "${R}   ❌ 无法自动安装 Node.js，请手动安装：https://nodejs.org/${N}"
            exit 1
        fi
    fi
    echo -e "${G}   ✅ Node.js $(node -v) 已安装${N}"
fi

# ----------------------------------------------------
# 3. 安装 OpenClaw
# ----------------------------------------------------
echo -e "${Y}📥 Step 2/9: 安装 OpenClaw...${N}"
npm install -g openclaw 2>/dev/null
echo -e "${G}   ✅ OpenClaw $(openclaw --version 2>/dev/null)${N}"

# ----------------------------------------------------
# 4. 设置 API Key
# ----------------------------------------------------
echo -e "${Y}🔑 Step 3/9: 设置 API Key...${N}"
SHELL_RC="$HOME/.bashrc"
[ -f "$HOME/.zshrc" ] && SHELL_RC="$HOME/.zshrc"

if ! grep -q "OPENAI_API_KEY" "$SHELL_RC" 2>/dev/null; then
    echo "export OPENAI_API_KEY=\"$OPENAI_KEY\"" >> "$SHELL_RC"
fi
export OPENAI_API_KEY="$OPENAI_KEY"
echo -e "${G}   ✅ API Key 已设置${N}"

# ----------------------------------------------------
# 5. 写配置
# ----------------------------------------------------
echo -e "${Y}⚙️  Step 4/9: 写入配置...${N}"

CONFIG_DIR="$HOME/.openclaw"
mkdir -p "$CONFIG_DIR"

WORKSPACE="$HOME/openclaw-workspace"

cat > "$CONFIG_DIR/openclaw.json" << CONFIGEOF
{
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "$TG_TOKEN",
      "dmPolicy": "open"
    }
  },
  "models": {
    "default": "openai/gpt-4o-mini"
  },
  "memory": {
    "enabled": true,
    "autoCapture": true,
    "provider": "core"
  },
  "tools": {
    "exec": {
      "host": "gateway",
      "security": "full",
      "ask": "off"
    },
    "elevated": {
      "enabled": true
    }
  },
  "browser": {
    "enabled": true
  },
  "workspace": "$WORKSPACE"
}
CONFIGEOF
echo -e "${G}   ✅ 配置已写入${N}"

# ----------------------------------------------------
# 6. 创建工作目录 + Agent 文件
# ----------------------------------------------------
echo -e "${Y}📝 Step 5/9: 创建 AI Agent...${N}"

mkdir -p "$WORKSPACE/memory/people"
mkdir -p "$WORKSPACE/memory/decisions"
mkdir -p "$WORKSPACE/memory/lessons"
mkdir -p "$WORKSPACE/memory/projects"

# SOUL.md
cat > "$WORKSPACE/SOUL.md" << EOF
# $BOT_NAME

## 性格
你是一个专业、友好的 AI 助手，名叫 $BOT_NAME。
- 回答简洁有用，不废话
- 用 $LANG 回复
- 不确定的事情诚实说不确定
- 保持礼貌和耐心
EOF

# MEMORY.md
cat > "$WORKSPACE/MEMORY.md" << EOF
# Memory

> $BOT_NAME 的长期记忆

请优先阅读：memory/INDEX.md
EOF

# memory/INDEX.md
cat > "$WORKSPACE/memory/INDEX.md" << EOF
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
EOF

# USER.md
cat > "$WORKSPACE/USER.md" << EOF
# 用户信息

- **Owner**: 待填写
- **Timezone**: Asia/Bangkok
EOF

# AGENTS.md（按场景包）
case $SCENE in
    2)
cat > "$WORKSPACE/AGENTS.md" << EOF
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
EOF
    ;;
    3)
cat > "$WORKSPACE/AGENTS.md" << EOF
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
EOF
    ;;
    4)
cat > "$WORKSPACE/AGENTS.md" << EOF
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
EOF
    ;;
    *)
cat > "$WORKSPACE/AGENTS.md" << EOF
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
EOF
    ;;
esac

echo -e "${G}   ✅ Agent 文件已创建（场景包 $SCENE）${N}"

# ----------------------------------------------------
# 7. 安装 Skills
# ----------------------------------------------------
echo -e "${Y}📦 Step 6/9: 安装常用 Skills...${N}"
openclaw skills install weather 2>/dev/null || true
openclaw skills install summarize 2>/dev/null || true
echo -e "${G}   ✅ Skills 已安装${N}"

# ----------------------------------------------------
# 8. 启动
# ----------------------------------------------------
echo -e "${Y}🚀 Step 7/9: 启动 OpenClaw...${N}"
openclaw gateway start &
sleep 8
echo -e "${G}   ✅ Gateway 已启动${N}"

echo -e "${G}🔗 Step 8/9: 自动配对已配置（open 模式）${N}"

# ----------------------------------------------------
# 9. 开机自启
# ----------------------------------------------------
echo -e "${Y}⚡ Step 9/9: 设置开机自启...${N}"

OS=$(uname -s)
if [ "$OS" = "Darwin" ]; then
    # macOS: launchd
    PLIST="$HOME/Library/LaunchAgents/com.openclaw.gateway.plist"
    cat > "$PLIST" << PLISTEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.openclaw.gateway</string>
    <key>ProgramArguments</key>
    <array>
        <string>$(which openclaw)</string>
        <string>gateway</string>
        <string>start</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>OPENAI_API_KEY</key>
        <string>$OPENAI_KEY</string>
        <key>PATH</key>
        <string>/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin</string>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/openclaw-stdout.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/openclaw-stderr.log</string>
</dict>
</plist>
PLISTEOF
    launchctl load "$PLIST" 2>/dev/null || true
    echo -e "${G}   ✅ macOS LaunchAgent 已设置（开机自启 + 自动重启）${N}"
else
    # Linux: systemd
    SERVICE_FILE="$HOME/.config/systemd/user/openclaw.service"
    mkdir -p "$(dirname "$SERVICE_FILE")"
    cat > "$SERVICE_FILE" << SVCEOF
[Unit]
Description=OpenClaw Gateway
After=network.target

[Service]
Type=simple
ExecStart=$(which openclaw) gateway start --foreground
Environment=OPENAI_API_KEY=$OPENAI_KEY
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
SVCEOF
    systemctl --user daemon-reload 2>/dev/null || true
    systemctl --user enable openclaw 2>/dev/null || true
    systemctl --user start openclaw 2>/dev/null || true
    echo -e "${G}   ✅ systemd 服务已设置（开机自启 + 自动重启）${N}"
fi

# ----------------------------------------------------
# 完成
# ----------------------------------------------------
echo ""
echo -e "${C}=====================================================${N}"
echo -e "${G}✅ 部署完成！一切就绪！${N}"
echo -e "${C}=====================================================${N}"
echo ""
echo -e "📋 部署信息:"
echo "   AI 名称:    $BOT_NAME"
echo "   场景包:     $SCENE"
echo "   模型:       GPT-4o-mini"
echo "   平台:       Telegram"
echo "   配对模式:   Open（无需审批）"
echo ""
echo -e "${G}🎉 现在就可以用了！${N}"
echo "   打开 Telegram → 搜索你的 Bot → 发消息 → AI 直接回复"
echo ""
echo -e "${Y}🔧 维护命令:${N}"
echo "   openclaw status          — 查看状态"
echo "   openclaw gateway restart — 重启"
echo "   openclaw gateway stop    — 停止"
echo "   openclaw logs --follow   — 查看日志"
echo ""
echo -e "${Y}📂 文件位置:${N}"
echo "   配置:  $CONFIG_DIR/openclaw.json"
echo "   Agent: $WORKSPACE/"
echo ""
echo -e "${Y}💰 月费预估: ~\$3-10（按实际消息量）${N}"
echo ""
