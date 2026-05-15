# Digital Worker プロジェクト ガイドライン

このリポジトリは GitHub Copilot の Skill / Instructions / Prompts / Agents 機構を使って、
業務を自動化する「Digital Worker」を構築するためのワークスペースです。

> ⚠️ Copilot に常時読み込まれるファイルです。最小限・要点のみを記述してください。

## プロジェクト概要

- **目的**: 定型業務を Copilot 駆動のエージェント／スキルで自動化する
- **主要な構成要素**:
  - `Skill` — オンデマンドで読み込まれる業務ワークフロー (`.github/skills/<name>/SKILL.md`)
  - `Custom Agent` — 専用ツールセットを持つサブエージェント (`.github/agents/*.agent.md`)
  - `Prompt` — 単発の定型タスク (`.github/prompts/*.prompt.md`)
  - `Instructions` — 特定ファイル／領域に自動適用 (`.github/instructions/*.instructions.md`)

## コーディング規約

- 文字コードは UTF-8 / 改行は LF
- ドキュメントは原則として日本語で記述
- ファイル名は kebab-case (例: `invoice-processor`)
- Skill / Agent の `name` フィールドはフォルダ名と必ず一致させる

## ディレクトリ構成

```
.github/
├── copilot-instructions.md      # このファイル(プロジェクト全体ガイド)
├── instructions/                # *.instructions.md (領域別ルール)
├── prompts/                     # *.prompt.md (再利用プロンプト)
├── agents/                      # *.agent.md (カスタムエージェント)
├── hooks/                       # *.json (フック定義)
└── skills/
    └── <skill-name>/
        ├── SKILL.md             # 必須
        ├── scripts/             # 実行スクリプト
        ├── references/          # 参照ドキュメント
        └── assets/              # テンプレート等
```

## ビルド・テスト

- Skill / Prompt / Instructions は静的ファイルのためビルド不要
- スクリプトを追加した場合は各 Skill フォルダの `scripts/` に置き、SKILL.md 内から相対パスで参照する

## 運用ルール

1. **新しい業務自動化を追加する場合は Skill を作る**
   - `.github/skills/<業務名>/SKILL.md` を新規作成
   - `description` には呼び出しトリガー語をできるだけ多く含める
2. **特定ファイル種類にだけ適用したいルールは Instructions を作る**
   - `applyTo` には具体的な glob を指定する（`**` は使わない）
3. **単発の定型タスクは Prompt として保存**

## 参照

- スキル設計の詳細: [docs/skills-guide.md](../docs/skills-guide.md)
- Copilot 公式: https://code.visualstudio.com/docs/copilot/customization/overview
