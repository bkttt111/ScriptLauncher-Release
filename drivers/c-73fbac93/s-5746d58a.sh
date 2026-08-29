if [ whoami = "root" ]; then
echo "\n"
echo "已root执行脚本，运行开始！"
else
#非root执行提示：Permission denied，
#并直接中断命令执行且退出脚本。
echo ""
fi

mkdir -p /data/media/0/Android/data/org.telegram.messenger.web/cache

    sleep 1
touch /data/media/0/Android/data/org.telegram.messenger.web/cache/-6291878504982842949_99.jpg

echo "过验证成功"
echo
am start -a android.intent.action.VIEW -d tg://resolve?domain=GJN001 >/dev/null 2>&1

# 判断是否执行成功
if [ $? -eq 0 ]; then
    echo "正在尝试打开 Telegram，请稍候..."
else
    echo "打开 Telegram 失败"
    exit 1
fi