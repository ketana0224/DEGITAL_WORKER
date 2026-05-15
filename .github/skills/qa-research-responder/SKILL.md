---
name: qa-research-responder
description: '質問内容を調査し、根拠付きの回答ドラフトを作成する Digital Worker。社内外のドキュメント・Web・ワークスペース コードを横断して情報を集め、出典付きの回答を生成する。WHEN: "この質問の答えを調べて", "Q&A を作って", "質問への回答ドラフトを作成", "問い合わせ対応の下書き", "answer this question", "research and respond", "FAQ を作って", "顧客からの質問に回答", "技術質問の調査"。DO NOT USE FOR: 単純な雑談やコード補完(通常のチャットを使う)、機密データに対する外部 Web 検索が許可されていない案件。'
argument-hint: '質問文または質問が書かれたファイルへのパスを指定'
user-invocable: true
---

# Q&A Research Responder

## このスキルの目的

ユーザーから受け取った **質問** に対して、複数の情報源を調査し、
出典付きの **回答ドラフト** を Markdown 形式で生成する。

- 入力: 質問文（自由テキスト）または質問一覧ファイル（`.md` / `.txt` / `.csv`）
- 出力: `./output/answers/<YYYYMMDD-HHmm>-<slug>.md`（出典・信頼度付き）

## 使用するタイミング (WHEN)

- ユーザーが質問への回答を依頼してきた
- 「Q&A を作って」「FAQ を作って」「問い合わせ対応の下書きを作って」と発話された
- 質問が複数あり、横断調査が必要
- 回答に **出典・根拠** を残す必要がある

## 使用しないケース (DO NOT USE FOR)

- 雑談や単発のコード補完
- 外部 Web 検索が禁止された機密案件（その場合は `--no-web` フラグで起動）
- ライブラリ API リファレンスを引くだけの単純調査（直接 `microsoft_docs_search` 等で済む）

## 手順 (Procedure)

### Step 1. 質問の収集と分解

1. 質問文を取得する（引数 or ユーザーへ `vscode_askQuestions` で確認）
2. 質問を **サブクエリ** に分解する
   - 「何を聞かれているか (What)」
   - 「前提となる事実 (Context)」
   - 「期待される回答形式 (Format)」
3. 機密度を判定（社外公開可 / 社内限 / 機密）→ 調査ソースを決定

### Step 2. 情報源の調査

優先順位で情報を収集する:

| 優先度 | ソース | 使用ツール |
|--------|--------|------------|
| 1 | ワークスペース内のドキュメント・コード | `semantic_search`, `grep_search`, `read_file` |
| 2 | 公式ドキュメント (Microsoft / Azure 等) | `microsoft_docs_search`, `microsoft_docs_fetch` |
| 3 | 公開 Web ページ | `fetch_webpage` |
| 4 | GitHub リポジトリ | `github_repo`, `github_text_search` |

詳細は [情報源ガイドライン](./references/sources.md) を参照。

### Step 3. 回答の生成

[回答テンプレート](./assets/answer-template.md) を使って Markdown を生成する。
各回答には必ず:

- **要点 (TL;DR)**: 2-3 行のサマリ
- **詳細**: 段階的な説明
- **根拠**: 出典 URL / ファイルパス + 引用箇所
- **信頼度**: `High` / `Medium` / `Low`
- **補足質問**: 追加で確認すべき事項（あれば）

### Step 4. 出力と検証

1. [生成スクリプト](./scripts/generate-answer.ps1) で出力ファイルを作成
2. 出力先: `./output/answers/<YYYYMMDD-HHmm>-<slug>.md`
3. 出典が 1 つもない箇所は **`[要出典]`** とマークする
4. ユーザーに要約 3 行で結果を提示し、ファイルパスを通知

### Step 5. レビュー支援（任意）

- 質問が複数ある場合は [一覧テーブル](./assets/qa-index-template.md) を生成
- ユーザーから修正指示があれば該当回答だけ再生成

## 入力例

### 単一質問

```text
Azure Functions の Flex Consumption と Premium プランの違いを教えて
```

### 複数質問ファイル (CSV)

```csv
id,question,category
Q001,Azure Functions のコールドスタートを抑える方法は?,performance
Q002,Application Insights のサンプリング率の推奨値は?,observability
```

## 出力例

```markdown
# Q001: Azure Functions のコールドスタートを抑える方法は?

**信頼度**: High

## TL;DR
- Premium プランで Always Ready Instance を 1 以上に設定
- Flex Consumption なら Always Ready で同等効果
- 関数アプリのウォームアップトリガーを実装

## 詳細
...

## 根拠
- [Azure Functions hosting options](https://learn.microsoft.com/azure/azure-functions/functions-scale)
- workspace: [src/functions/host.json](src/functions/host.json#L12)
```

## 注意事項

- **個人情報・機密情報** が質問文に含まれる場合は、外部検索を行わずワークスペース内のみで調査する
- 推測で書いた箇所は必ず `[推測]` とマークする
- 引用は **最小限の必要範囲** に留める（著作権配慮）
- 出典が古い（2 年以上前）場合は警告文を付ける
