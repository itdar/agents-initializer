# ai-initializer

**AIコーディングツール向けプロジェクトコンテキスト自動生成ツール**

> プロジェクトディレクトリをスキャンし、
> `AGENTS.md` + ナレッジ/スキル/ロールのコンテキストを自動生成することで、AIエージェントが即座に作業を開始できるようにします。

```
1コマンド → プロジェクト解析 → AGENTS.md生成 → あらゆるAIツールで動作
```

---

## 使い方

> **トークン使用量に関する注意** — 初回セットアップ時、最上位モデルがプロジェクト全体を解析し、複数のファイル（AGENTS.md、.ai-agents/context/、.ai-agents/skills/、.ai-agents/roles/）を生成します。プロジェクトの規模によっては数万トークンを消費する場合があります。これは一度きりのコストであり、以降のセッションでは事前生成されたコンテキストを読み込むだけで即座に開始できます。

```bash
# 1. AIにHOW_TO_AGENTS.mdを読ませれば、あとは自動で処理されます

# オプションA: 英語（推奨 — トークンコストが低く、AI性能が最適化されます）
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Read HOW_TO_AGENTS.md and generate AGENTS.md tailored to this project"

# オプションB: ユーザーの言語（AGENTS.mdを手動で編集する予定がある場合に推奨）
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "HOW_TO_AGENTS.md를 읽고 이 프로젝트에 맞게 AGENTS.md를 생성하라"

# 推奨: --model claude-opus-4-6（またはそれ以降）で最良の結果が得られます
# 推奨: --dangerously-skip-permissions で中断なく自律実行が可能です

# 2. 生成されたエージェントで作業を開始
./ai-agency.sh
```

---

## なぜ必要なのか？

AIコーディングツールはセッションごとに**プロジェクトをゼロから学習し直します**。

| 問題 | 結果 |
|---|---|
| チームの規約を知らない | コードスタイルの不一致 |
| API全体像を知らない | 毎回コードベース全体を探索（コスト+20%） |
| 禁止事項を知らない | 本番DBへの直接アクセスなどの危険な操作 |
| サービス間の依存関係を知らない | 副作用の見落とし |

**ai-initializer**がこれを解決します — 一度生成すれば、あらゆるAIツールがプロジェクトを即座に理解します。

---

## 基本原則

> ETH Zurich (2026.03): **推論可能な内容を含めると成功率が低下し、コストが+20%増加する**

```
含めるべき（推論不可能）         .ai-agents/context/（推論コスト高）       除外すべき（推論コスト低）
───────────────────────        ────────────────────────────────────      ────────────────────────
チーム規約                     API全体マップ                              ディレクトリ構造
禁止事項                       データモデルの関係性                        単一ファイルの内容
PR/コミットの形式              イベントのpub/sub仕様                      公式フレームワークドキュメント
隠れた依存関係                 インフラトポロジー                          import関係
```

---

## 生成される構造

```
project-root/
├── AGENTS.md                          # PMエージェント（全体オーケストレーション）
├── .ai-agents/
│   ├── context/                       # ナレッジファイル（セッション開始時に読み込み）
│   │   ├── domain-overview.md         #   ビジネスドメイン、ポリシー、制約
│   │   ├── data-model.md              #   エンティティ定義、関係性、状態遷移
│   │   ├── api-spec.json              #   APIマップ（JSON DSL、トークン3倍節約）
│   │   ├── event-spec.json            #   Kafka/MQイベント仕様
│   │   ├── infra-spec.md              #   Helmチャート、ネットワーク、デプロイ順序
│   │   └── external-integration.md    #   外部API、認証、レート制限
│   ├── skills/                        # 行動ワークフロー（オンデマンドで読み込み）
│   │   ├── develop/SKILL.md           #   開発: 分析 → 設計 → 実装 → テスト → PR
│   │   ├── deploy/SKILL.md            #   デプロイ: タグ → デプロイ要求 → 検証
│   │   ├── review/SKILL.md            #   レビュー: チェックリストベース
│   │   ├── hotfix/SKILL.md            #   緊急修正ワークフロー
│   │   └── context-update/SKILL.md    #   コンテキストファイル更新手順
│   └── roles/                         # ロール定義（ロール別コンテキスト深度）
│       ├── pm.md                      #   プロジェクトマネージャー
│       ├── backend.md                 #   バックエンド開発者
│       ├── frontend.md                #   フロントエンド開発者
│       ├── sre.md                     #   SRE / インフラ
│       └── reviewer.md                #   コードレビュアー
│
├── apps/
│   ├── api/AGENTS.md                  # サービスごとのエージェント
│   └── web/AGENTS.md
└── infra/
    └── helm/AGENTS.md
```

---

## 仕組み

### ステップ1: プロジェクトスキャンと分類

ディレクトリを深さ3まで探索し、ファイルパターンに基づいて自動分類します。

```
deployment.yaml + service.yaml  →  k8s-workload
values.yaml (Helm)              →  infra-component
package.json + *.tsx            →  frontend
go.mod                          →  backend-go
Dockerfile + CI config          →  cicd
...19種類を自動検出
```

### ステップ2: コンテキスト生成

検出された種類に基づいて**実際にコードを解析し**、`.ai-agents/context/`のナレッジファイルを生成します。

```
バックエンドサービスを検出
  → ルート/コントローラーをスキャン → api-spec.jsonを生成
  → エンティティ/スキーマをスキャン → data-model.mdを生成
  → Kafka設定をスキャン            → event-spec.jsonを生成
```

### ステップ3: AGENTS.md生成

適切なテンプレートを使用して、各ディレクトリのAGENTS.mdを生成します。

```
ルートAGENTS.md（グローバル規約）
  → コミット: Conventional Commits
  → PR: テンプレート必須、1件以上の承認
  → ブランチ: feature/{ticket}-{desc}
       │
       ▼ 自動継承（子では繰り返さない）
  apps/api/AGENTS.md
    → オーバーライドのみ: "このサービスはPythonを使用"
```

### ステップ4: ベンダー固有のブートストラップ

ベンダー固有の設定にブリッジを追加し、**すべてのAIツールが**生成されたAGENTS.mdを読めるようにします。

```
┌──────────────┐     ┌─────────────┐     ┌─────────────┐
│ Claude Code  │     │   Cursor    │     │   Codex     │
│  CLAUDE.md   │     │  .mdc rules │     │  AGENTS.md  │
│      ↓       │     │      ↓      │     │  (native)   │
│ "read        │     │ "read       │     │      ✓      │
│  AGENTS.md"  │     │  AGENTS.md" │     │             │
└──────┬───────┘     └──────┬──────┘     └─────────────┘
       └──────────┬─────────┘
                  ▼
           AGENTS.md（単一の信頼できる情報源）
                  │
        ┌─────────┼─────────┐
        ▼         ▼         ▼
  .ai-agents/  .ai-agents/  .ai-agents/
   context/     skills/      roles/
```

> **原則:** ブートストラップファイルは既に使用中のベンダーに対してのみ生成されます。未使用ツールの設定ファイルは作成されません。

---

## ベンダー互換性

| ツール | AGENTS.mdの自動読み込み | ブートストラップ |
|---|---|---|
| **OpenAI Codex** | 対応（ネイティブ） | 不要 |
| **Claude Code** | 部分対応（フォールバック） | `CLAUDE.md`にディレクティブを追加 |
| **Cursor** | 非対応 | `.cursor/rules/`に`.mdc`を追加 |
| **GitHub Copilot** | 非対応 | `.github/copilot-instructions.md`を生成 |
| **Windsurf** | 非対応 | `.windsurfrules`にディレクティブを追加 |
| **Aider** | 対応 | `.aider.conf.yml`に読み込み設定を追加 |

ブートストラップの自動生成:
```bash
bash scripts/sync-ai-rules.sh
```

---

## 階層型エージェント構造

```
┌───────────────────────────────────────┐
│  ルートPMエージェント (AGENTS.md)      │
│  グローバル規約 + 委任ルール           │
│  "設計検証 > コード検証"               │
└────────┬──────────┬─────────┬────────┘
         │          │         │
    ┌────▼────┐ ┌───▼────┐ ┌──▼─────┐
    │サービス │ │ インフラ│ │ ドキュメ│
    │エキスパ │ │  SRE   │ │ントプラ │
    │  ート   │ │        │ │  ナー   │
    └─────────┘ └────────┘ └────────┘

委任:     親 → 子（そのディレクトリのAGENTS.mdスコープ内で動作）
報告:     子 → 親（タスク完了後に変更サマリーを報告）
連携:     直接のピアツーピアなし — 親を介した間接的な連携
```

---

## トークン最適化

| 形式 | トークン数 | 備考 |
|---|---|---|
| 自然言語によるAPI説明 | 約200トークン | |
| JSON DSL | 約70トークン | **3倍の節約** |

**api-spec.jsonの例:**
```json
{
  "service": "order-api",
  "apis": [{
    "method": "POST",
    "path": "/api/v1/orders",
    "domains": ["Order", "Payment"],
    "sideEffects": ["kafka:order-created", "db:orders.insert"]
  }]
}
```

**AGENTS.mdの目標:** 置換後**300トークン**以下

---

## セッション復元プロトコル

```
セッション開始時:
  1. AGENTS.mdを読み込む（ほとんどのAIツールは自動で実行）
  2. コンテキストファイルのパスに従い.ai-agents/context/を読み込む
  3. .ai-agents/context/current-work.md を確認（進行中の作業）
  4. git log --oneline -10（最近の変更を把握）

セッション終了時:
  1. 進行中の作業 → current-work.mdに記録
  2. 新たに学習したドメイン知識 → コンテキストファイルを更新
  3. 未完了のTODO → 明示的に記録
```

---

## コンテキストのメンテナンス

コードが変更された場合、`.ai-agents/context/`のファイルもそれに応じて更新する必要があります。

```
APIの追加/変更/削除           →  api-spec.jsonを更新
DBスキーマの変更              →  data-model.mdを更新
イベント仕様の変更            →  event-spec.jsonを更新
ビジネスポリシーの変更        →  domain-overview.mdを更新
外部連携の変更                →  external-integration.mdを更新
インフラ設定の変更            →  infra-spec.mdを更新
```

> 更新を怠ると、次のセッションでは**古いコンテキストで作業する**ことになります。

---

## 導入チェックリスト

```
フェーズ1（基礎）              フェーズ2（コンテキスト）          フェーズ3（運用）
────────────────               ─────────────────                ────────────────────
☐ AGENTS.mdを生成              ☐ .ai-agents/context/を作成       ☐ .ai-agents/roles/を定義
☐ ビルド/テストコマンドを記録  ☐ domain-overview.md              ☐ マルチエージェントセッションを実行
☐ 規約とルールを記録           ☐ api-spec.json (DSL)             ☐ .ai-agents/skills/ワークフロー
☐ グローバル規約               ☐ data-model.md                   ☐ 反復フィードバックループ
☐ ベンダーブートストラップ     ☐ メンテナンスルールを設定
```

---

## ライセンス

MIT

---

<p align="center">
  <sub>AIエージェントがプロジェクトを理解するまでの時間をゼロにする。</sub>
</p>
