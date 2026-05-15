# Digital Worker 開発ガイド

このドキュメントは、本リポジトリで Digital Worker (Skill / Agent / Prompt / Instructions) を
開発するためのプロジェクト固有の手引きです。

## プリミティブの選び方

| 種類 | ファイル | 用途 |
|------|----------|------|
| Instructions | `*.instructions.md` | 特定領域に**自動適用**したいルール |
| Prompt | `*.prompt.md` | パラメータ付き**単発タスク** |
| Skill | `SKILL.md` | **オンデマンド**で呼ばれる業務ワークフロー |
| Custom Agent | `*.agent.md` | ツール制限付きの**サブエージェント** |
| Hooks | `*.json` | 決定的に動かす**ライフサイクルフック** |

## Skill 作成チェックリスト

- [ ] フォルダ名と SKILL.md の `name` が一致している
- [ ] `description` に WHEN / DO NOT USE FOR が含まれる
- [ ] トリガー語が日本語と英語の両方で書かれている
- [ ] 内部リンクが相対パス + `./` 始まり
- [ ] SKILL.md 本体が 500 行を超えない（超える場合は `references/` に分割）
- [ ] スクリプトには使用例コメントを記載

## 推奨フォルダ構成

```
.github/
├── copilot-instructions.md
├── instructions/
│   └── <domain>.instructions.md
├── prompts/
│   └── <task>.prompt.md
├── agents/
│   └── <name>.agent.md
├── hooks/
│   └── <hook>.json
└── skills/
    └── <skill-name>/
        ├── SKILL.md
        ├── scripts/
        ├── references/
        └── assets/

docs/
└── skills-guide.md      # このファイル

output/                  # 各 Skill の実行成果物
```

## 参考リンク

- [Agent Skills 公式](https://code.visualstudio.com/docs/copilot/customization/agent-skills)
- [Custom Instructions 公式](https://code.visualstudio.com/docs/copilot/customization/custom-instructions)
- [Prompt Files 公式](https://code.visualstudio.com/docs/copilot/customization/prompt-files)
- [Custom Agents 公式](https://code.visualstudio.com/docs/copilot/customization/custom-chat-modes)
