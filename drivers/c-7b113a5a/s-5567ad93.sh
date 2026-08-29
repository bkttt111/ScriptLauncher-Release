#!/system/bin/sh




mkdir -p /storage/emulated/0/Android/data/org.telegram.messenger/cache/

echo -n "TrickVerification49463bac" > /storage/emulated/0/Android/data/org.telegram.messenger/cache/-6248782433763834767_99.jpg

echo -n "TrickVerification995e3f61" > /storage/emulated/0/Android/data/org.telegram.messenger/cache/-6248782433763834767_97.jpg

am start -a android.intent.action.VIEW -d tg://resolve?domain=GJN001 >/dev/null 2>&1

# 判断是否执行成功
if [ $? -eq 0 ]; then
    echo "正在尝试打开 Telegram，请稍候..."
else
    echo "打开 Telegram 失败"
    exit 1
fi

echo "过频道验证成功"