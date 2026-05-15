# QA パイプライン 実行手順

このドキュメントは Digital Worker (`qa-research-responder` / `qa-answer-reviewer` /
`QA Pipeline Orchestrator`) を VS Code Copilot Chat および Copilot CLI から実行するための手順書です。

## 目次

- [共通の前提](#共通の前提)
- [1. VS Code Copilot Chat での実行](#1-vs-code-copilot-chat-での実行)
  - [1-1. 起動](#1-1-起動)
  - [1-2. パターン A: オーケストレーター経由（推奨）](#1-2-パターン-a-オーケストレーター経由推奨)
  - [1-3. パターン B: スキルを個別に呼ぶ](#1-3-パターン-b-スキルを個別に呼ぶ)
  - [1-4. パターン C: 複数質問の一括処理](#1-4-パターン-c-複数質問の一括処理)
  - [1-5. 機密モード](#1-5-機密モード)
  - [1-6. ファイル承認のコツ](#1-6-ファイル承認のコツ)
- [2. Copilot CLI での実行](#2-copilot-cli-での実行)
  - [2-1. インストール（初回のみ）](#2-1-インストール初回のみ)
  - [2-2. ワークスペース移動](#2-2-ワークスペース移動)
  - [2-3. パターン A: 対話モードで実行](#2-3-パターン-a-対話モードで実行)
  - [2-4. パターン B: ワンショット実行](#2-4-パターン-b-ワンショット実行)
  - [2-5. パターン C: 自動承認モード（CI / バッチ向け）](#2-5-パターン-c-自動承認モードci--バッチ向け)
  - [2-6. パターン D: スクリプトを直接実行（CLI 単独）](#2-6-パターン-d-スクリプトを直接実行cli-単独)
- [3. CI/CD で定期実行する例](#3-cicd-で定期実行する例)
- [4. 結果の確認](#4-結果の確認)
- [5. トラブルシューティング](#5-トラブルシューティング)
- [6. クイックスタート](#6-クイックスタート)
- [参照](#参照)

## 共通の前提

| 項目 | 内容 |
|------|------|
| ワークスペース | `c:\Degital_Worker` |
| PowerShell | `pwsh` (PowerShell 7+) 推奨 |
| 出力先 | `./output/answers/`、`./output/reviews/` (自動生成) |
| 認証 | GitHub Copilot の有効ライセンス |

---

## 1. VS Code Copilot Chat での実行

### 1-1. 起動

1. VS Code で `c:\Degital_Worker` を開きます。
2. サイドバーの **Copilot Chat** アイコン、または `Ctrl+Alt+I` でチャットを開きます。
3. チャットウィンドウ右上のモードセレクタで **Agent** モードを選択します（**Ask** ではありません）。

> Agent モードでないとファイル作成・スクリプト実行ができません。

### 1-2. パターン A: オーケストレーター経由（推奨）

直列パイプライン（調査 → レビュー）を一気に流します。

```text
@QA Pipeline Orchestrator
Azure Functions のコールドスタートを抑える方法を教えてください
```

または `@` を使わず自然言語で:

```text
質問の調査からレビューまで一気通貫で実行してください:
「Managed Identity と Service Principal の使い分けは？」
```

進行状況がチャット上に表示されます:

```
[Step 1/3] qa-research-responder を実行します
[Step 1/3] ✅ 回答ドラフト生成完了
[Step 2/3] qa-answer-reviewer を実行します
[Step 2/3] ✅ レビュー完了 (評定: Pass / スコア: 92)
```

### 1-3. パターン B: スキルを個別に呼ぶ

チャット入力欄で `/` を入力するとスキル一覧が出ます。

```text
/qa-research-responder Application Insights のサンプリング率の推奨値は？
```

```text
/qa-answer-reviewer ./output/answers/20260515-1030-Q001-...md
```

### 1-4. パターン C: 複数質問の一括処理

```text
@QA Pipeline Orchestrator
.github/skills/qa-research-responder/assets/sample-questions.csv の質問をすべて処理してください
```

### 1-5. 機密モード

社内情報・個人情報を含む場合:

```text
@QA Pipeline Orchestrator --internal-only
顧客情報を含むこの質問を処理してください: ...
```

外部 Web 検索が抑止され、ワークスペース + 公式 Doc のみを参照します。

### 1-6. ファイル承認のコツ

Agent モードはファイル作成・コマンド実行時に **確認ダイアログ** を出します。

- **Allow**: 1 回だけ許可
- **Always Allow**: このワークスペースで常に許可（推奨）

毎回確認が煩雑な場合は VS Code の `settings.json` で:

```json
{
  "chat.tools.autoApprove": false,
  "github.copilot.chat.agent.autoFix": true
}
```

---

## 2. Copilot CLI での実行

### 2-1. インストール（初回のみ）

```powershell
# Node.js 20+ が必要です
node --version

# Copilot CLI のインストール
npm install -g @github/copilot

# ログイン (ブラウザが開きます)
copilot auth login
```

### 2-2. ワークスペース移動

```powershell
cd c:\Degital_Worker
```

Copilot CLI はカレントディレクトリ配下の `.github/skills/`、`.github/agents/` を自動認識します。

### 2-3. パターン A: 対話モードで実行

```powershell
copilot
```

> ⚠️ **CLI と VS Code Chat の記法の違い**
>
> | 記号 | VS Code Chat | Copilot CLI |
> |------|--------------|-------------|
> | `@`  | カスタムエージェント呼び出し | **ファイル参照** (補完で files が出る) |
> | `#`  | コンテキスト参照 | **issue 参照** |
> | `/`  | スキル / スラッシュコマンド | スキル / スラッシュコマンド (共通) |
>
> CLI で `@QA...` と打っても **エージェントは起動しません**。下記のいずれかで起動してください。

#### A-1. `/agents` でエージェントを選択（推奨）

```text
> /agents
```

ロード済みエージェント一覧が表示されます。`QA Pipeline Orchestrator` を選択するとアクティブになります。
そのあとは普通に質問するだけでオーケストレーターが動きます。

```text
> Azure Functions のコールドスタートを抑える方法を教えてください
```

#### A-2. 自然言語で起動（description のトリガー語が反応）

エージェント名を打たなくても、description の WHEN フレーズを含む文章を投げれば自動で起動します。

```text
> 質問の調査からレビューまで一気通貫で実行してください: Application Insights のサンプリング率の推奨値は？
```

```text
> QA フルパイプラインを実行してください: Managed Identity と Service Principal の使い分けは？
```

#### A-3. スキルは `/` で呼ぶ

スキル（`SKILL.md`）はチャットと同じく `/` で補完されます。

```text
> /qa-research-responder Azure Container Apps の最小インスタンス数の推奨は？
```

#### A-4. 起動時にデフォルトエージェントを指定

```powershell
copilot --agent "QA Pipeline Orchestrator"
```

（CLI バージョンによってはこのフラグが利用可能。詳細は `copilot --help` を確認してください）

終了は `Ctrl+D` または `/exit`。

> 💡 対話モードでも `--allow-all` / `--allow-all-tools` フラグを併用できます。
> 確認ダイアログを毎回スキップしたい場合に便利です。
>
> ```powershell
> copilot --allow-all
> copilot --allow-all-tools
> ```

### 2-4. パターン B: ワンショット実行

```powershell
# オーケストレーター経由 (自然言語のトリガー語で自動起動)
copilot -p "質問の調査からレビューまで一気通貫で実行してください: Application Insights のサンプリング率の推奨値は？"

# エージェント指定 (フラグ対応版の場合)
copilot --agent "QA Pipeline Orchestrator" -p "Application Insights のサンプリング率の推奨値は？"

# スキル単独
copilot -p "/qa-research-responder Azure Container Apps の最小インスタンス数の推奨は？"
```

> ⚠️ CLI では `-p "@QA Pipeline ..."` の `@` はファイル参照として解釈されるため、
> エージェントは起動しません。description のトリガー語を含むプロンプトを使ってください。

`-p` (prompt) でワンショット実行できます。スクリプト連携に向いています。

### 2-5. パターン C: 自動承認モード（CI / バッチ向け）

```powershell
# 推奨: すべてのツール実行を確認なしで許可
# オーケストレーターは description のトリガー語で自動起動させる
copilot --allow-all-tools -p "QA フルパイプラインで sample-questions.csv の質問を全件処理してください"

# 別名フラグ (短縮形)
copilot --allow-all -p "調査からレビューまで一気通貫で: sample-questions.csv の全件"
```

両フラグの違い:

| フラグ | 効果 |
|--------|------|
| `--allow-all-tools` | 全ツール (read/edit/execute/web/...) の実行を自動許可 |
| `--allow-all` | 上記に加えてファイル変更・追加プロンプト確認も自動許可 |

> ⚠️ どちらも確認ダイアログをスキップします。
> CI / 信頼済みワークスペースのみで使用してください。
> 実行前に必ず `git status` で意図しない変更がないか確認することを推奨します。

> 💡 ありがちなミス: `--all-allow` は **誤り** です（`copilot --all-allow` → exit code 1）。
> 正しくは `--allow-all` または `--allow-all-tools` の順です。

### 2-6. パターン D: スクリプトを直接実行（CLI 単独）

Copilot を使わず PowerShell から直接呼ぶこともできます（テンプレ雛形の生成のみ）。

```powershell
# 回答ドラフトのスケルトン生成
pwsh -File .github/skills/qa-research-responder/scripts/generate-answer.ps1 `
    -QuestionId "Q001" `
    -Question "Azure Functions のコールドスタートを抑える方法は？" `
    -Category  "performance"

# レビューレポートのスケルトン生成
pwsh -File .github/skills/qa-answer-reviewer/scripts/run-review.ps1 `
    -Target "./output/answers/20260515-1030-Q001-...md"

# ディレクトリ一括レビュー
pwsh -File .github/skills/qa-answer-reviewer/scripts/run-review.ps1 `
    -Target "./output/answers" -Batch
```

スクリプトはテンプレ穴埋めまでしか行いません。本格的な調査・出典チェックは Copilot Chat/CLI から呼んでください。

---

## 3. CI/CD で定期実行する例

GitHub Actions で nightly に走らせる例:

```yaml
# .github/workflows/qa-nightly.yml
name: QA Pipeline Nightly
on:
  schedule:
    - cron: '0 18 * * *'   # 毎日 18:00 UTC
  workflow_dispatch:

jobs:
  qa:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: '20' }
      - run: npm install -g @github/copilot
      - run: |
          copilot --allow-all \
            -p "QA フルパイプラインで .github/skills/qa-research-responder/assets/sample-questions.csv の全件を処理してください"
        env:
          GH_TOKEN: ${{ secrets.GH_COPILOT_TOKEN }}
      - uses: actions/upload-artifact@v4
        with:
          name: qa-output
          path: output/
```

---

## 4. 結果の確認

実行が終わると次のファイルが生成されます。

```
output/
├── answers/
│   ├── 20260515-1030-Q001-azure-functions-cold-start.md
│   └── 20260515-1030-Q002-app-insights-sampling.md
└── reviews/
    ├── 20260515-1031-Q001-review.md
    ├── 20260515-1031-Q002-review.md
    └── 20260515-1031-batch-review.md          # 複数質問時のサマリ
```

VS Code で開いて確認するか、CLI で:

```powershell
# 最新のサマリを開く
code (Get-ChildItem ./output/reviews -Filter "*batch-review.md" | Sort-Object LastWriteTime -Descending)[0]
```

---

## 5. トラブルシューティング

| 症状 | 対処 |
|------|------|
| `/qa-*` が一覧に出ない | VS Code を `Developer: Reload Window` で再読み込み |
| VS Code Chat で `@QA Pipeline Orchestrator` が出ない | Agent モードか確認、または [qa-pipeline-orchestrator.agent.md](.github/agents/qa-pipeline-orchestrator.agent.md) の YAML 構文を確認 |
| CLI で `@QA...` を打っても補完されず起動しない | CLI の `@` はファイル参照。`/agents` で選択か、description のトリガー語を含む自然言語で起動させる |
| CLI で `copilot: command not found` | `npm bin -g` のパスを `PATH` に追加 |
| 「ツール実行に許可が必要」 | Agent モードで Allow / Always Allow を選択、CLI なら `--allow-all` または `--allow-all-tools` |
| `copilot --all-allow` で exit code 1 | フラグ名の誤り。正しくは `--allow-all` または `--allow-all-tools` |
| 出力ファイルが空 | スクリプト単独実行はテンプレ生成のみ。本処理は Copilot 経由で実行する |
| 機密情報を外に出したくない | `--internal-only` フラグまたは「機密モードで」と指示 |

---

## 6. クイックスタート

### VS Code Copilot Chat

```text
@QA Pipeline Orchestrator Azure Functions のコールドスタートを抑える方法を教えてください
```

### Copilot CLI

```powershell
# 自然言語のトリガー語でオーケストレーターを起動
copilot -p "QA フルパイプラインで Azure Functions のコールドスタートを抑える方法を教えてください"

# または対話モードで /agents を選択してから質問
copilot
> /agents
> Azure Functions のコールドスタートを抑える方法を教えてください
```

## 参照

- [README.md](README.md) — プロジェクト概要
- [docs/skills-guide.md](docs/skills-guide.md) — スキル設計ガイド
- [.github/agents/qa-pipeline-orchestrator.agent.md](.github/agents/qa-pipeline-orchestrator.agent.md) — オーケストレーター定義
- [.github/skills/qa-research-responder/SKILL.md](.github/skills/qa-research-responder/SKILL.md) — 調査スキル
- [.github/skills/qa-answer-reviewer/SKILL.md](.github/skills/qa-answer-reviewer/SKILL.md) — レビュースキル
