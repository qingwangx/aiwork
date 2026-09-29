#!/usr/bin/env bash
# 在当前工作区新建一个标准项目目录：01-项目/<项目名>/
# 用法: bash 04-脚本/新建项目.sh <项目名>
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME="${1:-}"

if [ -z "$NAME" ]; then
  echo "用法: 新建项目.sh <项目名>" >&2
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
