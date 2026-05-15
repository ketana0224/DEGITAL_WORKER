---
name: qa-answer-reviewer
description: 'qa-research-responder が生成した回答ドラフトをレビュー＆ファクトチェックする Digital Worker。出典の妥当性・最新性・引用一致・推測の有無を検証し、レビュー結果と修正提案を出力する。WHEN: "回答をレビューして", "ファクトチェックして", "Q&A を検証して", "出典を確認して", "review answers", "fact check", "verify citations", "回答の品質チェック", "QA レビュー"。DO NOT USE FOR: 新規回答の生成(qa-research-responder を使う)、コードレビュー(別スキル/通常チャット)、機密データの外部検証。'
argument-hint: 'レビュー対象の回答ファイル or ディレクトリ (例: ./output/answers/Q001.md)'
user-invocable: true
---

# Q&A Answer Reviewer / Fact-Checker

## このスキルの目的

`qa-research-responder` が生成した回答ドラフトに対して **第三者目線でレビュー** を行い、
事実誤認・出典不備・推測混入・古い情報などを検出し、修正提案付きの **レビューレポート** を出力する。

- 入力: 単一回答ファイル or `./output/answers/` ディレクトリ
- 出力: `./output/reviews/<YYYYMMDD-HHmm>-<target>-review.md`

## 使用するタイミング (WHEN)

- 回答ドラフトを公開・送付する前の検証
- 信頼度 `Medium` / `Low` の回答を High に引き上げたい
- 出典 URL のリンク切れや内容変更を確認したい
- 「ファクトチェックして」「レビューして」と依頼された

## 使用しないケース (DO NOT USE FOR)

- 新規回答の生成 → [qa-research-responder](../qa-research-responder/SKILL.md) を使う
- 通常のコードレビュー
- Web アクセスが禁止された機密回答（その場合は `--internal-only` モードで起動）

## 前提

- 対象ファイルは [qa-research-responder の回答テンプレート](../qa-research-responder/assets/answer-template.md) 形式
  （`TL;DR` / `詳細` / `根拠` / `信頼度` セクションを持つ）

## 手順 (Procedure)

### Step 1. 対象の特定

1. ユーザーから対象パスを取得（引数 or `vscode_askQuestions`）
2. ファイル or ディレクトリを判定し、対象ファイル一覧を作成
3. 各ファイルから 質問 / TL;DR / 詳細 / 出典 / 信頼度 を抽出

### Step 2. レビュー項目の実行

各回答に対して **5 つの検査** を実施する。詳細は [レビュー基準](./references/review-criteria.md) を参照。

| # | 検査項目 | 検出方法 |
|---|----------|----------|
| 1 | **出典の存在** | 「根拠」セクションが空 / `[要出典]` を含むか |
| 2 | **リンク到達性** | URL を `fetch_webpage` で取得、404/タイムアウトを検出 |
| 3 | **引用一致** | 出典本文と回答内の引用が一致するか（意味的） |
| 4 | **最新性** | 出典の更新日時が 2 年以上前か / バージョン番号の乖離 |
| 5 | **推測混入** | `[推測]` マーク / 断定的だが出典がない記述の検出 |

加えて任意で:

- **論理整合性**: TL;DR と詳細・結論が矛盾していないか
- **網羅性**: 質問のサブクエリが回答に網羅されているか
- **トーン**: 過度な断定・主観表現の検出

### Step 3. スコアリングと信頼度の再判定

各検査の結果から **総合スコア** を算出し、信頼度を再判定する。
ロジックは [スコアリングガイド](./references/scoring.md) 参照。

| 評定 | 条件 |
|------|------|
| **Pass** | すべての必須検査をクリア / 推測なし / 出典最新 |
| **NeedsRevision** | 軽微な不備（リンク 1 件失効 等）あり |
| **Fail** | 致命的な不備（事実誤認 / 出典なし / リンク切れ多数）あり |

### Step 4. 修正提案の生成

検出した問題ごとに **具体的な修正案** を提示する:

- 「ここに出典を追加: <推奨 URL>」
- 「この記述は推測のため `[推測]` マークを付与」
- 「バージョン X の前提が古い → 最新版 Y に更新」

### Step 5. レビューレポートの出力

[レビューレポートテンプレート](./assets/review-report-template.md) を使い、
[生成スクリプト](./scripts/run-review.ps1) で出力する。

- 単一ファイルレビュー: `./output/reviews/<時刻>-<QID>-review.md`
- ディレクトリ一括: `./output/reviews/<時刻>-batch-review.md` + 個別ファイル

## 入力例

### 単一ファイル

```text
./output/answers/20260515-1030-Q001-azure-functions-cold-start.md をレビューして
```

### ディレクトリ一括

```text
./output/answers/ 配下の回答すべてをファクトチェックして
```

## 出力例

```markdown
# Review: Q001 (Azure Functions コールドスタート)

**評定**: NeedsRevision
**元信頼度**: High → **推奨信頼度**: Medium

## 検出された問題

### 🔴 出典の最新性 (Major)
- 出典 [Azure Functions hosting options](...) が 2023 年版
- **修正案**: 最新版 (https://learn.microsoft.com/.../functions-scale) に差し替え

### 🟡 引用一致 (Minor)
- 「Always Ready Instance を 1 以上」と記載があるが、出典には「2 以上推奨」と書かれている
- **修正案**: 「1 以上（推奨は 2 以上）」に修正

## 良かった点
- TL;DR が簡潔
- ワークスペース内コードへの参照あり
```

## 注意事項

- **外部 URL の取得** は 1 リクエスト 5 秒以内のタイムアウトに設定する
- **機密回答** をレビューする場合は外部 fetch を行わず構文・引用整合性のみチェック
- レビュアの推測も `[レビュア推測]` とマークする
- 元ファイルは **直接書き換えない**。修正は提案ベースで、適用は別アクションで行う
