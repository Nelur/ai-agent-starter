# AI エージェント運用マニュアル

Codex (主実装) + Claude (補助) で GitHub Issue → PR → merge を回す日常運用のリファレンス。

このマニュアルは ai-agent-starter から install したリポジトリで共通に使える内容。リポジトリ固有のセットアップ手順は本ファイル末尾と CLAUDE.md を参照。

---

## 1. 構成図

```text
スマホ
  │ GitHub Issue 作成 (AI Task テンプレ)
  ▼
GitHub
  │ Issue URL を Codex に渡す
  ▼
Codex Cloud
  │ branch 作成 / 実装 / PR 作成
  ▼
GitHub PR
  │ 必要なら PR コメントに「@claude レビュー」
  ▼
Claude (GitHub Actions)
  │ レビューコメント / 小修正
  ▼
人間が PC で確認 → merge
```

役割固定:

- **Codex** — 通常実装。明確な acceptance criteria がある Issue。
- **@claude** — 調査 / レビュー / 小修正 / 設計比較。
- **人間** — merge 判断。default branch への直接 push は人間だけ。

---

## 2. リポジトリ単位のセットアップチェックリスト

### 自動配置されるもの (install.sh が入れる)

- `AGENTS.md` — Codex 向け作業ルール
- `CLAUDE.md` — Claude 向けルール + プロジェクト固有ルール (要追記)
- `.github/ISSUE_TEMPLATE/ai-task.yml` — Issue 起票テンプレ
- `.github/workflows/claude.yml` — `@claude` 起動 workflow

### 手動で必要なもの

| ステップ | 場所 | 内容 |
|---|---|---|
| 1 | `CLAUDE.md` | 「プロジェクト固有ルール」セクションを埋める |
| 2 | `Settings → Secrets → Actions` | `CLAUDE_CODE_OAUTH_TOKEN` を追加 |
| 3 | `Settings → Branches` (推奨) | main の branch protection を設定 |
| 4 | GitHub Apps 設定 | ChatGPT Codex Connector / Claude が All repositories で許可されてること確認 (アカウント単位、一度だけ) |

---

## 3. 日常運用フロー

### 3-A. 標準ケース (Codex に丸投げ)

1. **スマホで Issue 作成**
   - GitHub mobile → 対象 repo → Issues → New Issue → **AI タスク** テンプレを選択
   - 必須項目を埋める (依頼先 / リスク / ゴール / 理想の挙動 / 受け入れ条件 / 制約)
   - タイトルは `[AI] 〜` の prefix そのまま
2. **Codex に渡す**
   - ChatGPT mobile / Codex Cloud を開く
   - Issue URL を貼り、テンプレ内の「エージェント向け指示文」セクションをコピペ
   - 補足: `AGENTS.md に従い、merge せず PR を作って` だけで OK
3. **Codex が PR を作る**
   - branch 名は Codex 任せ (例: `codex/ai-smoke-test`)
   - PR タイトルは `[AI] 〜`
   - PR 本文に Summary / Files changed / Tests run / Limitations が入る
4. **GitHub mobile で確認**
   - PR の Files Changed タブで差分を流し読み
   - 受け入れ条件を満たしてるか
   - 余計なファイルを触ってないか
5. **PC で最終確認 → merge**
   - `gh pr checkout <number>` でローカルに落として動作確認
   - 問題なければ Squash merge

### 3-B. Claude にレビューさせる

Codex の PR が出た後、不安な点があるとき:

```text
@claude
このPR を AGENTS.md と CLAUDE.md に照らしてレビューしてほしい。
特に [気になるポイント] を見てほしい。
コードは変更しないで、コメントだけ返して。
```

を **PR の Conversation タブ (Issue コメント)** に投稿する。

- workflow が起動 → Actions タブに run が出る
- 数分待つと Claude がレビューコメントを返す

`@claude` 起動条件:

- コメント本文に `@claude` の文字列が含まれる
- 投稿者の author_association が `OWNER` / `MEMBER` / `COLLABORATOR` のいずれか

### 3-C. Claude に小修正させる

Codex の PR で「あと 1 行直してほしい」程度なら、PR コメントで:

```text
@claude
このPRに以下の修正を追加して、同じ branch にコミットしてください。

- [具体的な修正内容]

merge はしないでください。
```

Claude が PR の branch に追加 commit を入れる。

---

## 4. Issue 起票テンプレの使い方 (スマホ詳細)

GitHub mobile から:

1. 対象 repo を開く
2. Issues タブ
3. 右上「+」または「New Issue」
4. **AI タスク** を選択
5. 各フィールドを入力:
   - **依頼先エージェント**: Codex (通常) / Claude (調査) / ローカル限定
   - **リスクレベル**: Low / Medium / High
     - High はそもそも AI に投げない (auth / payment / DB / security / deploy)
   - **ゴール**: 一文で。「設定ページの layout バグを直す」など
   - **現状 / 理想の挙動**: 現状と理想を分けて書く
   - **受け入れ条件**: チェックリスト形式。3-5 個。これが Codex の合否判定基準
   - **制約**: 「変更は最小限」「PR を merge しない」はデフォで入る
   - **テストコマンド**: `npm test` など
   - **エージェント向け指示文**: そのままコピペ用文章。テンプレに最初から入ってる

### 良い Issue / 悪い Issue

**良い例 (Codex 向け)**:

```text
タイトル: [AI] PDF 出力で締切マーカーの色を赤系から橙系に変更
ゴール: 締切マーカーの塗りを #dc2626 → #ea580c に
受け入れ条件:
- [ ] src/lib/exportPdf.ts の deadline-marker 色定義が #ea580c に
- [ ] PDF 出力後、マーカーが橙で表示されることを確認
- [ ] 他の色定義 (status バー色など) は変更しない
制約:
- 変更は最小限
- exportPdf.ts のみ触る
- merge しない
```

**悪い例 (Codex に投げない方がいい)**:

```text
タイトル: PDF をもうちょっと見やすくして
```

→ 受け入れ条件が無いので Codex が範囲を取れない。仕様を固めてから Issue 化する。

---

## 5. Branch protection の推奨設定

`Settings → Branches → Branch protection rules → Add rule`

| 項目 | 推奨値 | 理由 |
|---|---|---|
| Branch name pattern | `main` | default branch を保護 |
| Require a pull request before merging | ✅ | AI に直 push させない |
| └ Require approvals | 1 | 自分で approve する運用 |
| └ Dismiss stale approvals when new commits are pushed | 任意 | 追加 commit したら approval リセット |
| Require status checks to pass | 任意 (CI があれば) | CI が無いなら OFF でも可 |
| Do not allow bypassing the above settings | 任意 | Admin も対象にするなら ON |

---

## 6. トラブルシュート

### Codex が PR を作らない

- 指示が「変更して」だけで「PR を作って」と書いてない → 指示文に明示
- 変更対象が曖昧 → 受け入れ条件を具体化
- AGENTS.md が無い → install.sh で配置されてるはず、確認
- GitHub Connection で repo が選ばれていない → Codex 側の設定確認
- branch protection と衝突 → AI に branch 作成権限はあるはず、protection 設定を見直す

### `@claude` の Actions run が出ない

- `@claude` を **Issue 本文** に書いている → コメントに書くこと
- workflow が default branch (`main`) に入っていない → `git log --oneline -- .github/workflows/claude.yml` で確認
- author_association が OWNER/MEMBER/COLLABORATOR でない → fork PR からのコメントは弾かれる
- typo: `@claide` `@calude` など

### Actions run は出るが失敗する

- `CLAUDE_CODE_OAUTH_TOKEN` が無い / 失効
  → Settings → Secrets → Actions で確認、無ければ Claude Code GitHub App から再発行
- permissions 不足 → workflow の `permissions:` ブロック確認
- `anthropics/claude-code-action` のバージョンが古い → `@v1` のままで概ね OK、壊れたら `@latest` も検討

### Codex が余計なファイルを触る

- AGENTS.md の "Keep changes minimal" / "Do not modify unrelated files" を再強調
- Issue の制約で対象ファイルを明示する
- それでも止まらないなら PR を close → 再依頼

---

## 7. クイックリファレンス

### Codex に投げる指示文 (固定文)

```text
この GitHub Issue を実装して Pull Request を作ってください。

ルール:
- AGENTS.md のルールに従ってください。
- 変更は最小限に。
- 関係ないファイルは触らないでください。
- merge はしないでください。
- PR 本文に Summary / 変更ファイル / 実行したテスト / 既知の制限 を含めてください。
- Issue の内容が曖昧な場合は推測せず質問してください。

Issue: <URL>
```

### `@claude` レビュー定型

```text
@claude
この PR を AGENTS.md と CLAUDE.md に照らしてレビューしてほしい。
特に [気になる点] を見てほしい。
コードは変更しないで、コメントだけ返して。
```

### `@claude` 小修正定型

```text
@claude
この PR の branch に以下の変更を追加してください:
- [変更内容]
merge はしないでください。
```

### 使い分け早見表

| ケース | 投げ先 |
|---|---|
| docs / README 修正 | Codex |
| 明確な小バグ修正 | Codex |
| UI 文言修正 | Codex |
| lint / typecheck エラー修正 | Codex |
| 「どこを直すべきか」が曖昧 | Claude (調査) |
| Codex の PR が不安 | Claude (レビュー) |
| ローカル DB / 環境が必要 | ローカル (人間が PC で) |
| auth / payment / DB / security / deploy | **AI に投げない** |

---

## 8. ai-agent-starter リポジトリ自体について

このマニュアルおよび配布される 4 ファイルは https://github.com/Nelur/ai-agent-starter で管理されている。

- **新規リポジトリ**: GitHub UI で「Use this template」
- **既存リポジトリ**: root で `curl -fsSL https://raw.githubusercontent.com/Nelur/ai-agent-starter/main/bin/install.sh | bash`

雛形やルールを改善したい場合は ai-agent-starter 側に PR / commit する。
