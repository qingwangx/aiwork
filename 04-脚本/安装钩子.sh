#!/usr/bin/env bash
# ============================================================
# 安装 git 钩子到本仓库
#
# 把 core.hooksPath 指向版本化的 04-脚本/git-hooks/，
# 这样钩子本身也进版本库，换机器/重新克隆后跑一次本脚本即可。
#
# 用法: bash 04-脚本/安装钩子.sh
# ============================================================
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [ ! -d .git ]; then
  echo "错误: $ROOT 不是 git 仓库" >&2
  exit 1
fi

git config core.hooksPath "04-脚本/git-hooks"
chmod +x "04-脚本/git-hooks/"* 2>/dev/null || true

echo "✓ 已安装 git 钩子"
echo "  core.hooksPath = $(git config --get core.hooksPath)"
echo ""
echo "  钩子清单:"
for h in "04-脚本/git-hooks/"*; do
  [ -f "$h" ] && echo "    - $(basename "$h")"
done
echo ""
echo "  验证: bash 04-脚本/检查结构.sh   （提交时会自动运行）"
