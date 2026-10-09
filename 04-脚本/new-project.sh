#!/usr/bin/env bash
# ============================================================
# 新建标准项目目录：01-项目/<项目名>/
#
# 用法:
#   bash 04-脚本/new-project.sh <项目名>
#   bash 04-脚本/new-project.sh          # 不带参数会提示输入
#
# 文件名为 ASCII 是被迫的：04-脚本/新建项目.bat 要调用它，
# 而 .bat 内容一旦含中文就会被 cmd 按 GBK 误解析（已实测）。
# 脚本内部的中文没问题——bash 处理 UTF-8 是可靠的。
# ============================================================
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME="${1:-}"

if [ -z "$NAME" ]; then
  printf '请输入项目名（如 桥梁监测）: '
  read -r NAME
fi

if [ -z "$NAME" ]; then
  echo "错误: 项目名不能为空。" >&2
  exit 1
fi

DIR="$ROOT/01-项目/$NAME"
if [ -e "$DIR" ]; then
  echo "已存在，未改动: $DIR" >&2
  exit 1
fi

mkdir -p "$DIR"/{src,data,docs,out}
touch "$DIR"/src/.gitkeep "$DIR"/data/.gitkeep "$DIR"/docs/.gitkeep "$DIR"/out/.gitkeep

TODAY="$(date +%Y-%m-%d)"
cat > "$DIR/README.md" <<EOF
# $NAME

- 建立日期：$TODAY
- 状态：进行中

## 目标

（一句话说明这个项目要解决什么问题）

## 当前进展

- [ ] 第一步

## 关键结论

（做完了把结论写在这里，方便日后回看）

## 目录说明

- \`src/\` 代码
- \`data/\` 本项目私有数据（跨项目数据放 \`02-数据/\`）
- \`docs/\` 过程文档
- \`out/\` 中间产物，可删除
EOF

echo "已创建: $DIR"
echo ""
echo "下一步:"
echo "  1. 编辑 \"01-项目/$NAME/README.md\" 写下目标"
echo "  2. 原始数据放 02-数据/原始/，本项目私有数据放 01-项目/$NAME/data/"
echo "  3. 完成后提交: git add -A && git commit -m \"...\" && git push"
