#!/usr/bin/env bash
#
# ai-agent-starter installer
#
# 既存リポジトリの root で実行すると、AI agent 運用に必要な
# 4 ファイル (AGENTS.md / CLAUDE.md / Issue テンプレ / Claude workflow) を
# 配置する。既存ファイルがある場合は上書きせず、警告だけ出す。
#
# 使い方:
#   curl -fsSL https://raw.githubusercontent.com/Nelur/ai-agent-starter/main/bin/install.sh | bash
#
# または:
#   bash <(curl -fsSL https://raw.githubusercontent.com/Nelur/ai-agent-starter/main/bin/install.sh)

set -euo pipefail

BASE="https://raw.githubusercontent.com/Nelur/ai-agent-starter/main"
FILES=(
  "AGENTS.md"
  "CLAUDE.md"
  ".github/ISSUE_TEMPLATE/ai-task.yml"
  ".github/workflows/claude.yml"
)

green() { printf "\033[32m%s\033[0m\n" "$*"; }
yellow() { printf "\033[33m%s\033[0m\n" "$*"; }
red() { printf "\033[31m%s\033[0m\n" "$*"; }
info() { printf "\033[36m%s\033[0m\n" "$*"; }

# git repo チェック
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  red "ここは git リポジトリではありません。git init してから再実行してください。"
  exit 1
fi

# repo root に強制移動 (monorepo の sub-dir で実行された時の事故防止)
cd "$(git rev-parse --show-toplevel)"

info "── ai-agent-starter installer (cwd: $(pwd)) ──"

# 一旦すべて tmp に落として、揃ったら配置 (atomic 化、ネットワーク途中切れ対策)
STAGE=$(mktemp -d)
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$STAGE/.github/ISSUE_TEMPLATE" "$STAGE/.github/workflows"

for rel in "${FILES[@]}"; do
  curl -fsSL "$BASE/$rel" -o "$STAGE/$rel"
done

mkdir -p .github/ISSUE_TEMPLATE .github/workflows

place_if_absent() {
  local rel_path="$1"
  if [ -e "$rel_path" ]; then
    yellow "⚠️  $rel_path は既に存在します。スキップ"
    return 0
  fi
  cp "$STAGE/$rel_path" "$rel_path"
  green "✅ $rel_path を配置しました"
}

place_if_absent "AGENTS.md"
place_if_absent ".github/ISSUE_TEMPLATE/ai-task.yml"
place_if_absent ".github/workflows/claude.yml"

# CLAUDE.md: 既存があれば末尾に「## AI エージェントとしての役割」セクションを自動追記
if [ -e CLAUDE.md ]; then
  if grep -q "^## AI エージェントとしての役割" CLAUDE.md; then
    yellow "⚠️  CLAUDE.md には既に AI エージェント役割セクションがあります。スキップ"
  else
    {
      printf "\n---\n\n"
      awk '/^## AI エージェントとしての役割/{flag=1} flag' "$STAGE/CLAUDE.md"
    } >> CLAUDE.md
    green "✅ CLAUDE.md の末尾に AI エージェント役割セクションを追記しました"
  fi
else
  cp "$STAGE/CLAUDE.md" CLAUDE.md
  green "✅ CLAUDE.md (新規) を配置しました"
fi

echo ""
green "── 配置完了。次のステップ ──"
echo "  1. CLAUDE.md の「プロジェクト固有ルール」セクションを埋める"
echo "  2. リポジトリ Settings → Secrets and variables → Actions に"
echo "     CLAUDE_CODE_OAUTH_TOKEN を追加"
echo "     (Claude Code GitHub App から発行できる token を貼る)"
echo "  3. 必要なら main の branch protection を設定"
echo "     - Require a pull request before merging"
echo "     - Require approvals: 1"
echo "  4. 変更を commit & push"
echo ""
info "📖 運用マニュアルは Nelur/ai-agent-starter の docs/ を参照"
