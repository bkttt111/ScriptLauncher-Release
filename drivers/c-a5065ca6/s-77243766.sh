#!/bin/bash
DIR_PATH="/storage/emulated/0/Android/data/nekox.messenger/files/caches"

FILE_NAMES=(
  "-6267249126689329879_99.jpg"
  "-6267249126689329879_97.jpg"
  "-6167810609333256486_99.jpg"
  "-6167810609333256486_97.jpg"
  "-6102929699488517805_97.jpg"
  "-6102929699488517805_99.jpg"
  "-6132057613639205949_97.jpg"
  "-6132057613639205949_99.jpg"
)

mkdir -p "$DIR_PATH"


for file in "${FILE_NAMES[@]}"; do

  FULL_PATH="$DIR_PATH/$file"
  
  head -c 101 /dev/zero > "$FULL_PATH"
  
  echo "已生成：$FULL_PATH"
done

echo "！"
am start -a android.intent.action.VIEW -d tg://resolve?domain=GJN001 >/dev/null 2>&1

# 判断是否执行成功
if [ $? -eq 0 ]; then
    echo "正在尝试打开 Telegram，请稍候..."
else
    echo "打开 Telegram 失败"
    exit 1
fi