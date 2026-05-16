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

green() { printf "\033[32m%s\033[0m\n" "$*"; }
yellow() { printf "\033[33m%s\033[0m\n" "$*"; }
red() { printf "\033[31m%s\033[0m\n" "$*"; }
info() { printf "\033[36m%s\033[0m\n" "$*"; }

# git repo チェック
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  red "ここは git リポジトリではありません。git init してから再実行してください。"
  exit 1
fi

info "── ai-agent-starter installer ──"

mkdir -p .github/ISSUE_TEMPLATE .github/workflows

# fetch helper: 既存ファイルがあればスキップ、無ければ取得
fetch_if_absent() {
  local rel_path="$1"
  if [ -e "$rel_path" ]; then
    yellow "⚠️  $rel_path は既に存在します。スキップ (差分を確認して必要なら手動 merge してください)"
    return 0
  fi
  curl -fsSL "$BASE/$rel_path" -o "$rel_path"
  green "✅ $rel_path を配置しました"
}

fetch_if_absent "AGENTS.md"
fetch_if_absent ".github/ISSUE_TEMPLATE/ai-task.yml"
fetch_if_absent ".github/workflows/claude.yml"

# CLAUDE.md は既存があれば snippet を別ファイルで提案
if [ -e CLAUDE.md ]; then
  yellow "⚠️  CLAUDE.md は既に存在します。"
  curl -fsSL "$BASE/CLAUDE.md" -o .CLAUDE.md.ai-agent-snippet
  yellow "    .CLAUDE.md.ai-agent-snippet として agent 役割テンプレを配置しました。"
  yellow "    既存 CLAUDE.md の末尾に「## AI エージェントとしての役割」セクションを"
  yellow "    手動で追記してから .CLAUDE.md.ai-agent-snippet を削除してください。"
else
  curl -fsSL "$BASE/CLAUDE.md" -o CLAUDE.md
  green "✅ CLAUDE.md を配置しました"
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
