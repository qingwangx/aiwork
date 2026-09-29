#!/usr/bin/env bash
# ============================================================
# AIwork 工作区结构校验器
#
# 用法:
#   bash 04-脚本/检查结构.sh           # 检查，有问题则退出码 1
#   bash 04-脚本/检查结构.sh --fix     # 检查并自动补齐缺失的目录/README
#   bash 04-脚本/检查结构.sh --quiet   # 只报问题，不打印通过项
#
# 退出码: 0=全部通过  1=存在错误  2=用法错误
# 规范见: 03-文档/目录结构规范.md
# ============================================================
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FIX=0
QUIET=0

while [ $# -gt 0 ]; do
  case "$1" in
    --fix)   FIX=1 ;;
    --quiet) QUIET=1 ;;
    -h|--help) sed -n '3,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "未知参数: $1（可用 --fix / --quiet）" >&2; exit 2 ;;
  esac
  shift
done

ERRS=0; WARNS=0; FIXED=0
err()  { ERRS=$((ERRS+1));  printf '  \033[31m✗ 错误\033[0m %s\n' "$1"; }
warn() { WARNS=$((WARNS+1)); printf '  \033[33m! 警告\033[0m %s\n' "$1"; }
ok()   { [ "$QUIET" -eq 1 ] || printf '  \033[32m✓\033[0m %s\n' "$1"; }
did()  { FIXED=$((FIXED+1)); printf '  \033[36m+ 修复\033[0m %s\n' "$1"; }
sec()  { [ "$QUIET" -eq 1 ] || printf '\n\033[1m%s\033[0m\n' "$1"; }

# ---------- 规范定义（改规则只改这里） ----------

# 顶层必需目录
TOP_DIRS=(
  "00-收件箱" "01-项目" "02-数据" "03-文档" "04-脚本"
  "05-素材" "06-产出" "07-参考资料" "08-归档" "09-临时"
)
# 子目录要求: "父目录|子目录..."
SUB_DIRS=(
  "02-数据|原始|处理后"
  "05-素材|图片|模板"
)
# 每个项目内必需的条目（目录自动建，文件需人工填内容）
PROJ_DIRS=("src" "docs" "data" "out")
PROJ_FILES=("README.md")
# 根目录白名单（其余顶层文件仅告警）
ROOT_WHITELIST=("README.md" "AGENTS.md" ".gitignore")
# 命名词黑名单
BAD_NAMES=("最终版" "副本" "copy" "未命名" "新建文件夹")

need_dir() {  # $1=相对路径
  if [ -d "$ROOT/$1" ]; then
    ok "目录 $1"
  elif [ "$FIX" -eq 1 ]; then
    mkdir -p "$ROOT/$1" && touch "$ROOT/$1/.gitkeep" && did "补建目录 $1"
  else
    err "缺少目录: $1"
  fi
}

need_file() {  # $1=相对路径  $2=模板内容(可选)
  if [ -f "$ROOT/$1" ]; then
    ok "文件 $1"
  elif [ "$FIX" -eq 1 ]; then
    local d; d="$(dirname "$ROOT/$1")"; mkdir -p "$d"
    if [ -n "${2:-}" ]; then printf '%s\n' "$2" > "$ROOT/$1"; else touch "$ROOT/$1"; fi
    did "补建文件 $1（内容需人工补充）"
  else
    err "缺少文件: $1"
  fi
}

# ============================================================
sec "① 顶层目录"
for d in "${TOP_DIRS[@]}"; do need_dir "$d"; done

sec "② 子目录"
for rule in "${SUB_DIRS[@]}"; do
  parent="${rule%%|*}"; rest="${rule#*|}"
  IFS='|' read -ra kids <<< "$rest"
  for k in "${kids[@]}"; do need_dir "$parent/$k"; done
done

sec "③ 项目结构（01-项目/ 下每个子目录）"
shopt -s nullglob
proj_count=0
for p in "$ROOT/01-项目"/*/; do
  name="$(basename "$p")"
  # 跳过下划线开头的临时目录（如 _自检测试）
  case "$name" in _*|.*) continue ;; esac
  proj_count=$((proj_count+1))
  [ "$QUIET" -eq 1 ] || printf '\n  \033[1m项目: %s\033[0m\n' "$name"
  for sub in "${PROJ_DIRS[@]}"; do
    if [ -d "$p/$sub" ]; then ok "  $name/$sub"
    elif [ "$FIX" -eq 1 ]; then mkdir -p "$p/$sub" && touch "$p/$sub/.gitkeep" && did "补建 $name/$sub"
    else err "项目 $name 缺少目录: $sub"; fi
  done
  for f in "${PROJ_FILES[@]}"; do
    if [ -f "$p/$f" ]; then ok "  $name/$f"
    elif [ "$FIX" -eq 1 ]; then
      printf '# %s\n\n- 建立日期：%s\n- 状态：进行中\n\n## 目标\n\n（待补充）\n' \
        "$name" "$(date +%Y-%m-%d)" > "$p/$f" && did "补建 $name/$f"
    else err "项目 $name 缺少文件: $f（项目说明）"; fi
  done
done
[ "$proj_count" -eq 0 ] && ok "暂无项目（01-项目/ 为空）"

sec "④ 根目录整洁度"
for f in "$ROOT"/*; do
  [ -f "$f" ] || continue
  base="$(basename "$f")"
  hit=0
  for w in "${ROOT_WHITELIST[@]}"; do [ "$base" = "$w" ] && hit=1; done
  case "$base" in .*) hit=1 ;; esac
  [ "$hit" -eq 0 ] && warn "根目录有散落文件: $base（应移入对应目录）"
done
ok "根目录白名单: ${ROOT_WHITELIST[*]}"

sec "⑤ 命名规范"
n=0
while IFS= read -r -d '' item; do
  base="$(basename "$item")"
  case "$base" in .git|.gitkeep|node_modules) continue ;; esac
  if printf '%s' "$base" | grep -q ' '; then
    warn "名称含空格: ${item#"$ROOT"/}"; n=$((n+1))
  fi
  for bad in "${BAD_NAMES[@]}"; do
    if printf '%s' "$base" | grep -qi "$bad"; then
      warn "建议改名（含「$bad」）: ${item#"$ROOT"/}"; n=$((n+1))
    fi
  done
done < <(find "$ROOT" -mindepth 1 \( -name .git -prune \) -o -print0)
[ "$n" -eq 0 ] && ok "未发现不规范命名"

# ============================================================
printf '\n\033[1m────────────────────────────────\033[0m\n'
printf '错误: \033[31m%d\033[0m   警告: \033[33m%d\033[0m   自动修复: \033[36m%d\033[0m\n' "$ERRS" "$WARNS" "$FIXED"
if [ "$ERRS" -gt 0 ]; then
  printf '\033[31m结构校验未通过\033[0m'
  [ "$FIX" -eq 0 ] && printf '（加 --fix 可自动补齐目录）'
  printf '\n'; exit 1
fi
printf '\033[32m结构校验通过\033[0m\n'; exit 0
