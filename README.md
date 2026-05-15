# Digital Worker (GitHub Copilot Skills)

GitHub Copilot の Skill / Agent / Prompt / Instructions を組み合わせて、
業務自動化「Digital Worker」を構築するためのワークスペーステンプレートです。

## クイックスタート

1. このリポジトリを VS Code で開く
2. Copilot Chat を開く
3. `/new-digital-worker` を実行して新しい Skill を生成

## フォルダ構成

```
.
├── README.md
├── .github/
│   ├── copilot-instructions.md           # プロジェクト全体ガイド (常時適用)
│   ├── instructions/
│   │   └── digital-worker.instructions.md  # Skill 編集時の自動ルール
│   ├── prompts/
│   │   └── new-digital-worker.prompt.md    # /new-digital-worker
│   ├── agents/
│   │   └── digital-worker-orchestrator.agent.md
│   ├── hooks/
│   │   └── block-secrets.json
│   └── skills/
│       └── sample-digital-worker/        # スキルのテンプレート
│           ├── SKILL.md
│           ├── scripts/run.ps1
│           ├── references/spec.md
│           └── assets/report-template.md
├── docs/
│   └── skills-guide.md
└── output/                               # 実行成果物の出力先
```

## 新しい Digital Worker を作る

```
.github/skills/sample-digital-worker/ をコピー
        ↓
フォルダ名を <業務名> に変更
        ↓
SKILL.md の name / description / 本文を編集
        ↓
scripts / references / assets を実装
```

詳細は [docs/skills-guide.md](docs/skills-guide.md) を参照してください。
# DEGITAL_WORKER
