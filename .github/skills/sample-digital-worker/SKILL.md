---
name: sample-digital-worker
description: 'Digital Worker スキルのテンプレート。新しい業務自動化スキルを作るときの雛形として使用する。WHEN: "新しい Digital Worker を作る", "業務自動化スキルを追加", "SKILL.md テンプレート"。DO NOT USE FOR: 実運用ワークフロー(このスキルをコピーして個別スキルを作成すること)。'
argument-hint: '対象業務名を指定 (例: invoice-processor)'
user-invocable: true
---

# Sample Digital Worker (テンプレート)

このスキルは Digital Worker を新規作成する際の雛形です。
**このスキルをそのまま使うのではなく、フォルダごとコピーして新しいスキルを作成してください。**

## このスキルの目的

- {{業務名}} に関する定型ワークフローを自動化する
- 入力: {{入力データ／トリガー条件}}
- 出力: {{成果物／レポート}}

## 使用するタイミング (WHEN)

- ユーザーが「{{トリガーフレーズ 1}}」と発言したとき
- ユーザーが「{{トリガーフレーズ 2}}」と発言したとき
- {{自動起動条件}}

## 使用しないケース (DO NOT USE)

- {{除外ケース 1}}
- {{除外ケース 2}}

## 手順 (Procedure)

1. **入力の収集**
   - {{必要な情報を列挙}}
   - 不足があれば `vscode_askQuestions` で確認

2. **処理の実行**
   - 参照: [処理仕様](./references/spec.md)
   - スクリプト: [run.ps1](./scripts/run.ps1)

3. **結果の検証**
   - {{検証手順}}

4. **レポート出力**
   - テンプレート: [report-template.md](./assets/report-template.md)
   - 出力先: `./output/`

## 入出力の例

### Input

```json
{
  "example": "value"
}
```

### Output

```text
{{期待される出力例}}
```

## 注意事項

- 個人情報・機密情報を含む場合は処理前にマスキングする
- 外部 API 呼び出しがある場合はレート制限とリトライを考慮
- エラー時は `./output/errors.log` に記録する
