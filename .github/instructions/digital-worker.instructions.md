---
applyTo: ".github/skills/**/*.md,.github/agents/**/*.md,.github/prompts/**/*.md"
description: 'Digital Worker 関連ファイル(Skill/Agent/Prompt)を編集するときに自動適用されるルール'
---

# Digital Worker 編集ルール

このファイルは `.github/skills/`、`.github/agents/`、`.github/prompts/` 配下の Markdown を
編集するときに Copilot が自動的に読み込みます。

## YAML フロントマター

- 先頭・末尾は `---` で囲む
- `name` はフォルダ名と完全一致させる
- `description` に **コロンを含む場合は必ずダブルクォートで囲む**
- `applyTo` で `**` は使わない（コンテキストを圧迫するため）

## 記述ガイド

- `description` には呼び出しトリガー語を日本語＋英語の両方で記載する
- 「いつ使うか」「いつ使わないか」を `WHEN` / `DO NOT USE FOR` セクションで明示する
- 手順は番号付きリストで、1 ステップ 1 アクションに分解する

## 参照リンク

- Skill 内の他ファイル参照は **相対パス + `./` 始まり** で書く
  - 良: `[script](./scripts/run.ps1)`
  - 悪: `[script](scripts/run.ps1)` / `[script](/absolute/path)`
- リンク先は SKILL.md から 1 階層までを推奨
