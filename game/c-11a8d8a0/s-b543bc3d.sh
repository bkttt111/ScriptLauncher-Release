#!/system/bin/sh
cd "$(dirname "$0")" || exit 1

SO=""
for f in lib2026*.so; do
    [ -e "$f" ] || continue
    if [ -z "$SO" ] || [ "$f" \> "$SO" ]; then
        SO="$f"
    fi
done
if [ -z "$SO" ]; then
    for f in *.so; do
        [ -e "$f" ] || continue
        SO="$f"
        break
    done
fi
if [ -z "$SO" ]; then
    echo "[错误] 目录下没有找到 .so 内核文件" >&2
    exit 1
fi
chmod 700 "$SO" 2>/dev/null
echo "[内核] 使用: $SO"

LIST="全部卡密.txt"
RESULT="成功卡密.log"

HOLD=6
BATCH=6
CLEAN_WAIT=2

cleanup() {
    pkill -9 -f "$SO" 2>/dev/null
    sleep "$CLEAN_WAIT"
}

echo "======================================"
echo "     嗯嗯启动器 · bk优化"
echo "--------------------------------------"
echo "     欢迎使用 baka优化启动器"
echo "     官方频道 @bkqdq888"
echo "--------------------------------------"
echo " [1] 输入新卡密 (重新导入, 会清除旧记录)"
echo " [2] 使用已有卡密测试 (读取上次复制粘贴的卡密)"
echo "======================================"

# ===== 首次运行/无卡密检测 =====
# 判断是否"没有任何可用的卡密数据"：
#   - 全部卡密.txt 不存在 或 为空(无非空行)
#   - 且 成功卡密.log 不存在 或 为空
# 满足则视为首次使用，自动进入【导入新卡密】，避免选2后因 0 卡密直接退出。
list_empty=0; [ ! -s "$LIST" ] && list_empty=1     # 不存在或空文件 → 视为无卡密
rslt_empty=0; [ ! -s "$RESULT" ] && rslt_empty=1   # 不存在或空文件 → 视为无记忆
if [ "$list_empty" = "1" ] && [ "$rslt_empty" = "1" ]; then
    echo "  (检测到首次使用: 还没有任何卡密数据)"
    echo "  (已自动进入【导入新卡密】流程, 导入后会自动生成 全部卡密.txt)"
    choice=1
else
    printf " 请输入选择 [1/2]: "
    read choice
fi

if [ "$choice" = "1" ]; then
    echo ""
    echo "【注意】导入新卡密将【清除】之前导入的所有旧卡密及成功记录！"
    echo " 请一次性粘贴你的所有卡密 (一行一个)。"
    echo " 粘贴完毕后输入 y 并回车 结束导入。"
    echo "--------------------------------------"
    > "$LIST"
    rm -f "$RESULT"
    n=0
    while IFS= read -r line || [ -n "$line" ]; do
        [ -z "$line" ] && continue
        [ "$line" = "y" ] && break
        case "$line" in
            EN*) echo "$line" >> "$LIST"; n=$((n+1)) ;;
            *)   echo "  (跳过格式不符: $line)" ;;
        esac
    done
    echo "--------------------------------------"
    echo "✅ 全新导入完成: 共 $n 个新卡密"
    echo "   已【清除】上次的成功卡密记录"
    echo ""
fi

echo "[并行启动] 每批并行 $BATCH 个, 进程常驻>=${HOLD}s 判定成功"
cleanup

TMP_LIST="/data/local/tmp/kmlist_$$.txt"
: > "$TMP_LIST"
if [ -s "$RESULT" ]; then
    while IFS= read -r pk || [ -n "$pk" ]; do
        [ -z "$pk" ] && continue
        echo "$pk" >> "$TMP_LIST"
        echo "[记忆] 优先尝试上次成功卡密: $pk"
    done < "$RESULT"
fi
grep -v '^[[:space:]]*$' "$LIST" >> "$TMP_LIST"

KEYS_FILE="/data/local/tmp/kml_keys_$$.txt"
: > "$KEYS_FILE"
prev=""
while IFS= read -r key || [ -n "$key" ]; do
    [ -z "$key" ] && continue
    case " $prev " in *" $key "*) continue;; esac
    prev="$prev $key"
    echo "$key" >> "$KEYS_FILE"
done < "$TMP_LIST"
rm -f "$TMP_LIST"
TOTAL=$(grep -c . "$KEYS_FILE")
[ -z "$TOTAL" ] && TOTAL=0
echo "[载入] 共 $TOTAL 个去重卡密"

# 卡密为空时（两个文件存在但没有有效卡密内容）：引导用户导入，而不是跑 0 个直接 ALLDONE
if [ "$TOTAL" = "0" ]; then
    echo "--------------------------------------"
    echo "[提示] 当前没有任何可测试的卡密数据。"
    echo "[提示] 请把卡密粘贴进 全部卡密.txt (一行一个)，"
    echo "      或重新运行本脚本并选择【1】输入新卡密。"
    echo "--------------------------------------"
    cleanup
    echo "EMPTY: 无可用卡密，请先导入卡密"
    exit 1
fi


found_key=""
pos=0
{
    batch=0
    started=0
    batch_keys=""
    while IFS= read -r key || [ -n "$key" ]; do
        [ -z "$key" ] && continue
        batch_keys="$batch_keys $key"
        started=$((started+1))
        ./"$SO" -k "$key" --record-mirror >/dev/null 2>&1 &
        if [ $started -ge $BATCH ]; then
            batch=$((batch+1))
            echo ""
            echo "=== 批次$batch (并行 $started 个) ==="
            alive=1
            sec=0
            while [ $alive -eq 1 ] && [ $sec -lt "$HOLD" ]; do
                sleep 1; sec=$((sec+1))
                cnt=$(pgrep -c -f "$SO" 2>/dev/null)
                if [ -z "$cnt" ] || [ "$cnt" = "0" ]; then
                    alive=0
                fi
            done
            if [ $alive -eq 1 ]; then
                echo ">>> 本批评到有效! 逐个复验锁定..."
                for bk in $batch_keys; do
                    pkill -9 -f "$SO" 2>/dev/null; sleep "$CLEAN_WAIT"
                    printf "  复验: %s  " "$bk"
                    ./"$SO" -k "$bk" --record-mirror >/dev/null 2>&1 &
                    ok=0; n=0
                    while [ $n -lt "$HOLD" ]; do
                        sleep 1; n=$((n+1))
                        c=$(pgrep -c -f "$SO")
                        if [ -z "$c" ] || [ "$c" = "0" ]; then break; fi
                        if [ $n -ge "$HOLD" ]; then ok=1; fi
                    done
                    if [ "$ok" = "1" ]; then
                        echo ""
                        echo ">>> SUCCESS: $bk (验证通过进入程序)"
                        echo "$bk" > "$RESULT"
                        echo "[保留] 已找到有效卡密, 程序继续运行"
                        found_key="$bk"
                        break
                    else
                        echo "✗ 无效"
                    fi
                done
            else
                echo "批次$batch 全部无效, 快速跳过"
            fi
            if [ -n "$found_key" ]; then break; fi
            batch_keys=""
            started=0
            pos=$((pos+BATCH))
        fi
    done < "$KEYS_FILE"
    rm -f "$KEYS_FILE"
    if [ -n "$found_key" ]; then
        exit 0
    fi
    if [ $started -gt 0 ] && [ -z "$found_key" ]; then
        pkill -9 -f "$SO" 2>/dev/null; sleep "$CLEAN_WAIT"
        batch=$((batch+1))
        echo ""
        echo "=== 批次$batch (并行 $started 个, 末尾批) ==="
        for bk in $batch_keys; do
            printf "  复验: %s  " "$bk"
            ./"$SO" -k "$bk" --record-mirror >/dev/null 2>&1 &
            ok=0; n=0
            while [ $n -lt "$HOLD" ]; do
                sleep 1; n=$((n+1))
                c=$(pgrep -c -f "$SO")
                if [ -z "$c" ] || [ "$c" = "0" ]; then break; fi
                if [ $n -ge "$HOLD" ]; then ok=1; fi
            done
            if [ "$ok" = "1" ]; then
                echo ""
                echo ">>> SUCCESS: $bk (验证通过进入程序)"
                echo "$bk" > "$RESULT"
                echo "[保留] 已找到有效卡密, 程序继续运行"
                found_key="$bk"
                break
            else
                echo "✗ 无效"
            fi
        done
    fi
    rm -f "$KEYS_FILE"
}
if [ -n "$found_key" ]; then
    exit 0
fi

cleanup
echo "ALLDONE: 全部 $TOTAL 个卡密未找到常驻成功的"
exit 1