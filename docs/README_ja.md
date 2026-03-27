<div align="center">

# ai-initializer

**1つのコマンドで、あらゆるAIエージェントがプロジェクトを即座に理解できるようになります。**

(プロジェクトスキャン → AGENTS.md + コンテキスト生成 → あらゆるAIツールがすぐに動作)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)

</div>

---

## すぐに試す

このリポジトリには、動作するサンプルとして `AGENTS.md` と `.ai-agents/` ファイルがあらかじめ用意されています。
クローンしてすぐに `ai-agency.sh` を実行し、動作を確認できます：

```bash
git clone <this-repo>
cd agents-initializer
./ai-agency.sh
```

```
=== AI Agent Sessions ===
Project: /home/user/agents-initializer
Found: 2 agent(s)

  1) [PM] ai-initializer                (bg: Warm Brown)
     Path: ./AGENTS.md
     Project orchestrator managing all sub-agents

  2) docs                                (bg: Navy)
     Path: docs/AGENTS.md
     Documentation specialist

Select agent (number, or 'q' to quit): 1

=== AI Tool ===
  1) claude  (Claude Code CLI)
  2) codex   (OpenAI Codex CLI)
  3) print   (print prompt only — for manual copy)

Select tool (1-3): 1

→ Agent reads AGENTS.md + loads .ai-agents/context/ automatically
→ Ready to work immediately!
```

---

## プロジェクトへの適用

> **重要：** `setup.sh` と `HOW_TO_AGENTS.md` を**あなた自身のプロジェクトディレクトリ**にコピーしてから実行してください。これらのファイルは対象プロジェクトの構造を分析するため、プロジェクトの内部に配置する必要があります。

```bash
# ファイルをあなたのプロジェクトにコピー
cp setup.sh HOW_TO_AGENTS.md /path/to/your-project/

# プロジェクトに移動してセットアップを実行
cd /path/to/your-project/

# セットアップスクリプトを実行（AGENTS.md + コンテキストを自動生成）
./setup.sh

# エージェントセッションを起動
./ai-agency.sh
```

<details>
<summary>手動セットアップ（詳細）</summary>

> **トークン使用量に関する注意** — 初回セットアップ時、最上位モデルがプロジェクト全体を分析し、複数のファイル（AGENTS.md、.ai-agents/context/、.ai-agents/skills/、.ai-agents/roles/）を生成します。プロジェクトの規模によっては数万トークンを消費する場合があります。これは一度きりのコストであり、以降のセッションでは事前構築されたコンテキストを読み込んで即座に開始できます。

```bash
# 1. AIにHOW_TO_AGENTS.mdを読ませれば、あとは自動で処理します

# オプションA: 英語（推奨 — トークンコストが低く、AIのパフォーマンスが最適）
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Read HOW_TO_AGENTS.md and generate AGENTS.md tailored to this project"

# オプションB: ユーザーの言語（AGENTS.mdを手動編集する予定がある場合に推奨）
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "HOW_TO_AGENTS.mdを読み、このプロジェクトに合わせてAGENTS.mdを生成せよ"

# 推奨: --model claude-opus-4-6（またはそれ以降）で最良の結果を得る
# 推奨: --dangerously-skip-permissions で中断なしの自律実行

# 2. 生成されたエージェントで作業を開始
./ai-agency.sh
```

</details>

---

## なぜこれが必要なのか？

### 問題：AIはセッションごとに記憶を失う

```
 セッション1                セッション2                セッション3
┌──────────┐             ┌──────────┐             ┌──────────┐
│ AIが全体 │             │ AIが全体 │             │ また最初 │
│ コード   │  セッション │ コード   │  セッション │ からやり │
│ ベースを │  終了       │ ベースを │  終了       │ 直し     │
│ 読む     │ ──────→     │ 読む     │ ──────→     │          │
│ (30分)   │ 記憶が      │ (30分)   │ 記憶が      │ (30分)   │
│ 作業開始 │ 消失！      │ 作業開始 │ 消失！      │ 作業開始 │
│          │             │          │             │          │
└──────────┘             └──────────┘             └──────────┘
```

AIエージェントはセッションが終了するとすべてを忘れます。毎回、プロジェクト構造の理解、APIの分析、規約の学習に時間を費やします。

| 問題 | 結果 |
|---|---|
| チームの規約を知らない | コードスタイルの不一致 |
| API全体のマップを知らない | 毎回コードベース全体を探索（コスト+20%） |
| 禁止事項を知らない | 本番DBへの直接アクセスなどの危険な操作 |
| サービス間の依存関係を知らない | 副作用の見落とし |

### 解決策：AIの「脳」を事前構築する

```
 セッション開始
┌──────────────────────────────────────────────────┐
│                                                  │
│  AGENTS.mdを読み込み（自動）                     │
│       │                                          │
│       ▼                                          │
│  「私はこのサービスのバックエンド担当です」      │
│  「規約：Conventional Commits、TypeScript        │
│   strict」                                       │
│  「禁止事項：他サービスの変更、                  │
│   シークレットのハードコーディング」             │
│       │                                          │
│       ▼                                          │
│  .ai-agents/context/ ファイルを読み込み（5秒）   │
│  「20個のAPI、15エンティティ、8イベントを把握」  │
│       │                                          │
│       ▼                                          │
│  すぐに作業開始！                                │
│                                                  │
└──────────────────────────────────────────────────┘
```

**ai-initializer** がこれを解決します — 一度生成すれば、あらゆるAIツールがプロジェクトを即座に理解します。

---

## 基本原則：3層アーキテクチャ

```
                    あなたのプロジェクト
                         │
            ┌────────────┼────────────┐
            ▼            ▼            ▼

     ┌──────────┐  ┌──────────┐  ┌──────────┐
     │ AGENTS.md│  │.ai-agents│  │.ai-agents│
     │          │  │ /context/│  │ /skills/ │
     │ アイデン │  │ ナレッジ │  │ 振る舞い │
     │ ティティ │  │ 「何を   │  │ 「どう   │
     │ 「私は   │  │  知って  │  │  作業    │
     │  誰？」  │  │  いる？」│  │  する？」│
     │          │  │          │  │          │
     │ + ルール │  │ +ドメイン│  │ +デプロイ│
     │ + 権限   │  │ + モデル │  │ +レビュー│
     └──────────┘  └──────────┘  └──────────┘
      エントリ      メモリ        ワークフロー
      ポイント      ストア        標準
```

### 1. AGENTS.md — 「私は誰？」

各ディレクトリに配置されたエージェントの**アイデンティティファイル**。

```
project/
├── AGENTS.md                  ← PM：全体を統括するリーダー
├── apps/
│   └── api/
│       └── AGENTS.md          ← API担当：このサービスのみ担当
├── infra/
│   ├── AGENTS.md              ← SRE：全インフラを管理
│   └── monitoring/
│       └── AGENTS.md          ← モニタリング専門家
└── configs/
    └── AGENTS.md              ← 設定管理者
```

これは**チームの組織図**と同じように機能します：
- PMが全体を見渡しタスクを分配
- 各メンバーは自分の領域のみを深く理解
- 他チームの作業は直接行わず、依頼する

### 2. `.ai-agents/context/` — 「何を知っている？」

AIが毎回コードを読まなくて済むように、**必要な知識を事前に整理した**フォルダ。

```
.ai-agents/context/
├── domain-overview.md     ← 「このサービスは注文管理を扱う...」
├── data-model.md          ← 「Order、Payment、Deliveryエンティティがある...」
├── api-spec.json          ← 「POST /orders、GET /orders/{id}、...」
└── event-spec.json        ← 「order-createdイベントを発行する...」
```

**例え：** 新入社員向けのオンボーディングドキュメント。一度文書化すれば、誰も再度説明する必要がない。

### 3. `.ai-agents/skills/` — 「どう作業する？」

繰り返し行うタスクのための**標準化されたワークフローマニュアル**。

```
.ai-agents/skills/
├── develop/SKILL.md       ← 「機能開発：分析 → 設計 → 実装 → テスト → PR」
├── deploy/SKILL.md        ← 「デプロイ：タグ → リクエスト → 検証」
└── review/SKILL.md        ← 「レビュー：セキュリティ、パフォーマンス、テストチェックリスト」
```

**例え：** チームの運用マニュアル — 「PR提出前にこのチェックリストを確認する」といったルールをAIに従わせる。

---

## 書くべきこと・書くべきでないこと

> ETH Zurich (2026.03): **推論可能な内容を含めると成功率が低下し、コストが+20%増加する**

```
         書くべきこと                    書くべきでないこと
  ┌─────────────────────────┐     ┌─────────────────────────┐
  │                         │     │                         │
  │  「コミットにはfeat:形式│     │  「ソースコードはsrc/   │
  │   を使用する」          │     │   フォルダにある」      │
  │  AIはこれを推論できない │     │  AIはlsで確認できる     │
  │                         │     │                         │
  │  「mainへの直接プッシュ │     │  「Reactはコンポーネント│
  │   禁止」                │     │   ベース」              │
  │  チームルール、コードに │     │  公式ドキュメントに     │
  │  ない                   │     │   記載済み              │
  │                         │     │                         │
  │  「デプロイ前にQAチーム │     │  「このファイルは100行  │
  │   の承認が必要」        │     │   ある」                │
  │  プロセス、推論不可能   │     │  AIは直接読める         │
  │                         │     │                         │
  └─────────────────────────┘     └─────────────────────────┘
       AGENTS.mdに書く                  書かないこと！
```

**例外：** 「推論できるが、毎回行うにはコストが高すぎるもの」

```
  例：API全リスト（把握するのに20ファイル読む必要がある）
  例：データモデルの関係（10ファイルに分散）
  例：サービス間の呼び出し関係（コード＋インフラの両方を確認する必要がある）

  → これらは.ai-agents/context/に事前整理する！
  → AGENTS.mdにはパスのみ記載：「ここを見に行くこと」
```

```
含めるもの（推論不可能）          .ai-agents/context/（コストの高い推論）    除外するもの（低コストの推論）
───────────────────────        ────────────────────────────────────      ────────────────────────
チームの規約                    API全体マップ                              ディレクトリ構造
禁止事項                        データモデルの関係                          単一ファイルの内容
PR/コミット形式                 イベントのpub/sub仕様                      公式フレームワークドキュメント
隠れた依存関係                  インフラトポロジー                          import関係
                               KPI目標とビジネス指標
                               ステークホルダーマップと承認フロー
                               運用ランブックとエスカレーションパス
                               ロードマップとマイルストーン管理
```

---

## 仕組み

### ステップ1：プロジェクトスキャン＆分類

深さ3までディレクトリを探索し、ファイルパターンから自動分類します。

```
deployment.yaml + service.yaml  →  k8s-workload
values.yaml (Helm)              →  infra-component
package.json + *.tsx            →  frontend
go.mod                          →  backend-go
Dockerfile + CI config          →  cicd
...19種類を自動検出
```

### ステップ2：コンテキスト生成

検出されたタイプに基づいて**実際にコードを分析し**、`.ai-agents/context/` ナレッジファイルを生成します。

```
バックエンドサービスを検出
  → routes/controllersをスキャン → api-spec.jsonを生成
  → entities/schemasをスキャン   → data-model.mdを生成
  → Kafka設定をスキャン          → event-spec.jsonを生成
```

### ステップ3：AGENTS.md生成

適切なテンプレートを使用して各ディレクトリにAGENTS.mdを生成します。

```
ルートAGENTS.md（グローバル規約）
  → コミット：Conventional Commits
  → PR：テンプレート必須、1名以上の承認
  → ブランチ：feature/{ticket}-{desc}
       │
       ▼ 自動継承（子には繰り返し記述しない）
  apps/api/AGENTS.md
    → 上書きのみ：「このサービスはPythonを使用」
```

グローバルルールは**継承パターン**を使用 — 一箇所に書けば、下流に自動適用されます。

```
ルートAGENTS.md ──────────────────────────────────────────
│ グローバル規約：
│  - コミット：Conventional Commits (feat:, fix:, chore:)
│  - PR：テンプレート必須、レビュアー1名以上
│  - ブランチ：feature/{ticket}-{desc}
│
│     自動継承                      自動継承
│     ┌──────────────────┐       ┌──────────────────┐
│     ▼                  │       ▼                  │
│  apps/api/AGENTS.md    │    infra/AGENTS.md       │
│  （追加ルールのみ      │    （追加ルールのみ      │
│   記載）               │     記載）               │
│  「このサービスは      │    「Helmのvaluesを変更  │
│   Pythonを使用」       │     する場合、まず確認」 │
└─────────────────────────┴──────────────────────────
```

**メリット：**
- コミットルールを変更したい？ → ルートのみ修正
- 新サービスを追加？ → グローバルルールが自動適用
- 特定のサービスに異なるルールが必要？ → そのサービスのAGENTS.mdで上書き

### ステップ4：ベンダー固有のブートストラップ

ベンダー固有の設定にブリッジを追加し、**すべてのAIツールが**生成されたAGENTS.mdを読めるようにします。

```
┌──────────────┐     ┌─────────────┐     ┌─────────────┐
│ Claude Code  │     │   Cursor    │     │   Codex     │
│  CLAUDE.md   │     │  .mdc rules │     │  AGENTS.md  │
│      ↓       │     │      ↓      │     │ (ネイティブ)│
│ "read        │     │ "read       │     │      ✓      │
│  AGENTS.md"  │     │  AGENTS.md" │     │             │
└──────┬───────┘     └──────┬──────┘     └─────────────┘
       └──────────┬─────────┘
                  ▼
           AGENTS.md（唯一の信頼できるソース）
                  │
        ┌─────────┼─────────┐
        ▼         ▼         ▼
  .ai-agents/  .ai-agents/  .ai-agents/
   context/     skills/      roles/
```

> **原則：** ブートストラップファイルは既に使用しているベンダー向けのみ生成されます。未使用ツールの設定ファイルは作成されません。

---

## ベンダー互換性

| ツール | AGENTS.mdの自動読み込み | ブートストラップ |
|---|---|---|
| **OpenAI Codex** | はい（ネイティブ） | 不要 |
| **Claude Code** | 部分的（フォールバック） | `CLAUDE.md`にディレクティブを追加 |
| **Cursor** | いいえ | `.cursor/rules/`に`.mdc`を追加 |
| **GitHub Copilot** | いいえ | `.github/copilot-instructions.md`を生成 |
| **Windsurf** | いいえ | `.windsurfrules`にディレクティブを追加 |
| **Aider** | はい | `.aider.conf.yml`にreadを追加 |

ブートストラップの自動生成：
```bash
bash scripts/sync-ai-rules.sh
```

---

## 生成される構造

```
project-root/
├── AGENTS.md                          # PMエージェント（全体統括）
├── .ai-agents/
│   ├── context/                       # ナレッジファイル（セッション開始時に読み込み）
│   │   ├── domain-overview.md         #   ビジネスドメイン、ポリシー、制約
│   │   ├── data-model.md             #   エンティティ定義、関係、状態遷移
│   │   ├── api-spec.json              #   APIマップ（JSON DSL、トークン3倍節約）
│   │   ├── event-spec.json            #   Kafka/MQイベント仕様
│   │   ├── infra-spec.md              #   Helmチャート、ネットワーク、デプロイ順序
│   │   ├── external-integration.md    #   外部API、認証、レート制限
│   │   ├── business-metrics.md        #   KPI、OKR、収益モデル、成功基準
│   │   ├── stakeholder-map.md         #   意思決定者、承認フロー、RACI
│   │   ├── ops-runbook.md             #   運用手順、エスカレーション、SLA
│   │   └── planning-roadmap.md        #   マイルストーン、依存関係、タイムライン
│   ├── skills/                        # 行動ワークフロー（オンデマンドで読み込み）
│   │   ├── develop/SKILL.md           #   開発：分析 → 設計 → 実装 → テスト → PR
│   │   ├── deploy/SKILL.md            #   デプロイ：タグ → デプロイリクエスト → 検証
│   │   ├── review/SKILL.md            #   レビュー：チェックリストベース
│   │   ├── hotfix/SKILL.md            #   緊急修正ワークフロー
│   │   └── context-update/SKILL.md    #   コンテキストファイル更新手順
│   └── roles/                         # ロール定義（ロール別コンテキスト深度）
│       ├── pm.md                      #   プロジェクトマネージャー
│       ├── backend.md                 #   バックエンド開発者
│       ├── frontend.md                #   フロントエンド開発者
│       ├── sre.md                     #   SRE / インフラ
│       └── reviewer.md               #   コードレビュアー
│
├── apps/
│   ├── api/AGENTS.md                  # サービスごとのエージェント
│   └── web/AGENTS.md
└── infra/
    └── helm/AGENTS.md
```

---

## セッションランチャー

```bash
./ai-agency.sh                    # インタラクティブ（エージェント・ツールを選択）
./ai-agency.sh --tool claude      # Claude で直接起動
./ai-agency.sh --multi            # 並列実行（tmux）
./ai-agency.sh --list             # エージェント一覧を表示
```

---

## トークン最適化

| 形式 | トークン数 | 備考 |
|---|---|---|
| 自然言語によるAPI記述 | 約200トークン | |
| JSON DSL | 約70トークン | **3倍の節約** |

**api-spec.jsonの例：**
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

**AGENTS.mdの目標：** 置換後**300トークン**以下

---

## セッション復元プロトコル

```
セッション開始時：
  1. AGENTS.mdを読む（ほとんどのAIツールは自動で行う）
  2. コンテキストファイルのパスに従い.ai-agents/context/を読み込む
  3. .ai-agents/context/current-work.md を確認（進行中の作業）
  4. git log --oneline -10（最近の変更を把握）

セッション終了時：
  1. 進行中の作業 → current-work.mdに記録
  2. 新たに学んだドメイン知識 → コンテキストファイルを更新
  3. 未完了のTODO → 明示的に記録
```

---

## コンテキストのメンテナンス

コードが変更されたら、`.ai-agents/context/` ファイルもそれに合わせて更新する必要があります。

```
APIの追加/変更/削除           →  api-spec.jsonを更新
DBスキーマの変更              →  data-model.mdを更新
イベント仕様の変更            →  event-spec.jsonを更新
ビジネスポリシーの変更        →  domain-overview.mdを更新
外部連携の変更                →  external-integration.mdを更新
インフラ設定の変更            →  infra-spec.mdを更新
KPI/OKR目標の変更             →  business-metrics.mdを更新
チーム体制の変更              →  stakeholder-map.mdを更新
運用手順の変更                →  ops-runbook.mdを更新
マイルストーン/ロードマップの変更 →  planning-roadmap.mdを更新
```

> 更新を怠ると、次のセッションは**古いコンテキストで作業する**ことになります。

---

## 全体フロー概要

```
┌──────────────────────────────────────────────────────────────────┐
│  1. 初回セットアップ（一度きり）                                 │
│                                                                  │
│  ./setup.sh を実行（プロジェクトディレクトリ内で）               │
│       │                                                          │
│       ▼                                                          │
│  AIがプロジェクト構造を分析                                      │
│       │                                                          │
│       ▼                                                          │
│  各ディレクトリに              .ai-agents/context/に             │
│  AGENTS.mdを作成              ナレッジを整理                     │
│  （エージェントのアイデン     （API、モデル、イベント仕様）      │
│   ティティ + ルール                                              │
│   + 権限）                                                       │
│                                                                  │
│  .ai-agents/skills/に         .ai-agents/roles/に                │
│  ワークフローを定義           ロールを定義                       │
│  （開発、デプロイ、レビュー   （Backend、Frontend、SRE）         │
│   手順）                                                         │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  2. 日常的な使用                                                 │
│                                                                  │
│  ./ai-agency.sh を実行                                           │
│       │                                                          │
│       ▼                                                          │
│  エージェントを選択（PM？Backend？SRE？）                        │
│       │                                                          │
│       ▼                                                          │
│  AIツールを選択（Claude？Codex？Cursor？）                       │
│       │                                                          │
│       ▼                                                          │
│  セッション開始 → AGENTS.md自動読み込み → .ai-agents/context/    │
│  読み込み → 作業開始！                                           │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  3. 継続的なメンテナンス                                         │
│                                                                  │
│  コードが変更された場合：                                        │
│    - AIが.ai-agents/context/を自動更新                           │
│    - または人間が「これは重要、記録して」と指示                  │
│                                                                  │
│  新サービスを追加する場合：                                      │
│    - ./setup.sh を再実行 → 新しいAGENTS.mdが自動生成             │
│    - グローバルルールが自動継承                                  │
│                                                                  │
│  AIが間違えた場合：                                              │
│    - 「これを再分析して」→ ヒントを与える → 理解したら           │
│      .ai-agents/context/を更新                                   │
│    - このフィードバックループがコンテキストの品質を向上させる    │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## 例え：従来のチーム vs AIエージェントチーム

```
              従来の開発チーム           AIエージェントチーム
              ────────────────────       ──────────────────
 リーダー     PM（人間）                 ルートAGENTS.md（PMエージェント）
 メンバー     N人の開発者               各ディレクトリのAGENTS.md
 オンボーディング Confluence/Notion     .ai-agents/context/
 マニュアル   チームwiki                 .ai-agents/skills/
 ロール定義   役職/R&Rドキュメント       .ai-agents/roles/
 チームルール チーム規約ドキュメント     グローバル規約（継承）
 出勤         オフィスに到着             セッション開始 → AGENTS.md読み込み
 退勤         退社（記憶は残る）         セッション終了（記憶消失！）
 翌日         記憶あり                   .ai-agents/context/読み込み（記憶復元）
```

**重要な違い：** 人間は退勤後も記憶を保持しますが、AIは毎回すべてを忘れます。
だからこそ `.ai-agents/context/` が存在します — AIの**長期記憶**として機能します。

---

## 導入チェックリスト

```
フェーズ1（基本）              フェーズ2（コンテキスト）          フェーズ3（運用）
────────────────               ─────────────────                ────────────────────
☐ AGENTS.mdを生成              ☐ .ai-agents/context/を作成       ☐ .ai-agents/roles/を定義
☐ ビルド/テストコマンドを記録  ☐ domain-overview.md              ☐ マルチエージェントセッションを実行
☐ 規約とルールを記録           ☐ api-spec.json (DSL)             ☐ .ai-agents/skills/ ワークフロー
☐ グローバル規約               ☐ data-model.md                   ☐ 反復的なフィードバックループ
☐ ベンダーブートストラップ     ☐ メンテナンスルールの設定
```

---

## 成果物

| ファイル | 対象 | 目的 |
|---|---|---|
| `setup.sh` | 人間 | プロジェクトにコピーして実行 — AGENTS.md + コンテキストを自動生成 |
| `HOW_TO_AGENTS.md` | AI | エージェントが読んで実行するメタ指示マニュアル |
| `README.md` | 人間 | このドキュメント — 人間が理解するためのガイド |
| `ai-agency.sh` | 人間 | エージェント選択 → AIセッションランチャー |
| `AGENTS.md`（各ディレクトリ） | AI | ディレクトリごとのエージェントアイデンティティ + ルール |
| `.ai-agents/context/*.md/json` | AI | 事前整理されたドメインナレッジ |
| `.ai-agents/skills/*/SKILL.md` | AI | 標準化された作業ワークフロー |
| `.ai-agents/roles/*.md` | AI/人間 | ロール別コンテキスト読み込み戦略 |

---

## 参考文献

- [Kurly OMSチーム AIワークフロー](https://helloworld.kurly.com/blog/oms-claude-ai-workflow/) — 本システムのコンテキスト設計のインスピレーション元
- [AGENTS.md標準](https://agents.md/) — ベンダー中立のエージェント指示標準
- [ETH Zurich研究](https://www.infoq.com/news/2026/03/agents-context-file-value-review/) — 「推論できないことだけを文書化する」

---

## ライセンス

MIT

---

<p align="center">
  <sub>AIエージェントがプロジェクトを理解するまでの時間をゼロにする。</sub>
</p>
