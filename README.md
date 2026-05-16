# ai-agent-starter

GitHub Issue → Codex で PR 作成 → `@claude` でレビュー → 人間が merge、という AI 駆動の Issue 解決運用を、**新規 / 既存どちらのリポジトリにも数十秒で導入する** ためのテンプレ。

スマホから Issue を切って外出先で Codex に投げ、帰宅後に PC で merge 判断、という運用を想定。

## 何が入るか

| ファイル | 役割 |
|---|---|
| `AGENTS.md` | Codex 向け作業ルール |
| `CLAUDE.md` | Claude (補助) ルール + プロジェクト固有ルールの placeholder |
| `.github/ISSUE_TEMPLATE/ai-task.yml` | 「AI タスク」Issue テンプレ (日本語) |
| `.github/workflows/claude.yml` | `@claude` 起動 workflow (author_association 制限あり) |

## 新規リポジトリで使う

GitHub 上で「**Use this template**」ボタン → 新規 repo 名を入れる。
または:

```bash
gh repo create my-new-project --template Nelur/ai-agent-starter --private --clone
```

## 既存リポジトリで使う

対象 repo の root で:

```bash
curl -fsSL https://raw.githubusercontent.com/Nelur/ai-agent-starter/main/bin/install.sh | bash
```

install.sh は内部で `cd $(git rev-parse --show-toplevel)` するので、repo 内のサブディレクトリで実行しても安全。既存 `AGENTS.md` / Issue テンプレ / workflow があれば上書きせず警告のみ。既存 `CLAUDE.md` は末尾に「AI エージェントとしての役割」セクションを自動追記する (見出し重複ガード付き)。

中身を先に確認したい時:

```bash
curl -fsSL https://raw.githubusercontent.com/Nelur/ai-agent-starter/main/bin/install.sh -o /tmp/install.sh
less /tmp/install.sh
bash /tmp/install.sh
```

特定の commit に固定したい時 (`<sha>` を任意のコミット SHA に):

```bash
curl -fsSL https://raw.githubusercontent.com/Nelur/ai-agent-starter/<sha>/bin/install.sh | bash
```

## セットアップ後にやること

1. `CLAUDE.md` の「プロジェクト固有ルール」を埋める
2. Repo `Settings → Secrets and variables → Actions` に `CLAUDE_CODE_OAUTH_TOKEN` を追加
   - Claude Code GitHub App から発行
3. (推奨) `Settings → Branches` で main の branch protection を設定
4. commit & push

## 運用マニュアル

- [docs/AI_AGENT_WORKFLOW.md](docs/AI_AGENT_WORKFLOW.md) — Issue 起票から merge まで日常運用の手順
- [AGENTS.md](AGENTS.md) — Codex 向けルール本体
- [CLAUDE.md](CLAUDE.md) — Claude 向けルール本体

## 前提

アカウント単位 (= 1 度だけやれば全 repo に効く):

- GitHub Apps に「**ChatGPT Codex Connector**」がインストール済み (All repositories 推奨)
- GitHub Apps に「**Claude**」がインストール済み (All repositories 推奨)
- Codex Cloud (chatgpt.com/codex) と GitHub の接続済み

確認場所: https://github.com/settings/installations

## このリポジトリ自体の改善

Issue や PR で雛形・ルール・マニュアルをブラッシュアップしていく。`Nelur/ai-agent-starter` 自体も AI agent 運用の対象。

## ライセンス

個人用 (Nelur)。流用したい人がいれば fork OK。
