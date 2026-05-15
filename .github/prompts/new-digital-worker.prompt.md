---
description: '新しい Digital Worker (Skill) を sample-digital-worker テンプレートから作成する'
mode: agent
---

# 新しい Digital Worker を作成

以下の手順で新規 Skill を生成してください。

## ヒアリング

ユーザーから次の情報を取得します（不足していれば質問する）:

1. **業務名 (skill name)** — kebab-case (例: `invoice-processor`)
2. **目的** — 1-2 文で
3. **入力データ** — 何を受け取るか
4. **出力成果物** — 何を返すか
5. **トリガー語** — ユーザーがどう発話したら起動するか（3-5 個）

## 生成

1. `.github/skills/<業務名>/` フォルダを作成
2. `sample-digital-worker` 配下のファイルをコピー
3. 次の項目を実値に置き換え:
   - `SKILL.md` の `name`, `description`, 本文の `{{...}}` プレースホルダー
   - `scripts/run.ps1` の TODO ブロック（必要に応じて）
   - `references/spec.md` のビジネスルール
   - `assets/report-template.md` の見出し
4. 作成完了後にディレクトリ構造を出力する

## 注意

- 既存スキルと `name` が重複しないか確認
- `description` には WHEN / DO NOT USE FOR を必ず含める
