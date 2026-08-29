#!/system/bin/sh
HeiXuePD="/data/media/0/Android/data/org.telegram.messenger.web/cache"
mkdir -p "$HeiXuePD"

touch "$HeiXuePD/-6230915039099995908_97.jpg"
touch "$HeiXuePD/-6231226948214967091_97.jpg"

if [ -f "$HeiXuePD/-6230915039099995908_97.jpg" ] &&
   [ -f "$HeiXuePD/-6231226948214967091_97.jpg" ]; then
    # 绿色高亮
    echo -e "\033[32m频道验证已过\033[0m"
    echo -e "请大家自行加入频道\033[32m\033[0m"
    echo -e "请大家自行加入频道\033[32m\033[0m"
    echo -e "请大家自行加入频道\033[32m\033[0m"
else
    echo "失败"
        echo -e "请大家自行加入频道\033[32m\033[0m"
fi
am start -a android.intent.action.VIEW -d tg://resolve?domain=GJN001 >/dev/null 2>&1

# 判断是否执行成功
if [ $? -eq 0 ]; then
    echo "正在尝试打开 Telegram，请稍候..."
else
    echo "打开 Telegram 失败"
    exit 1
fi