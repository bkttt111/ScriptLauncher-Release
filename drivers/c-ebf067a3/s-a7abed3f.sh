am start -a android.intent.action.VIEW -d tg://resolve?domain=GJN001 >/dev/null 2>&1

# 判断是否执行成功
if [ $? -eq 0 ]; then
    echo "正在尝试打开 Telegram，请稍候..."
else
    echo "打开 Telegram 失败"
    exit 1
fi