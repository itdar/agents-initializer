🌐 [English](../README.md) | [한국어](README_ko.md) | [日本語](README_ja.md) | [中文](README_zh.md) | [Español](README_es.md) | [Français](README_fr.md) | [Deutsch](README_de.md) | [Русский](README_ru.md) | [हिन्दी](README_hi.md) | [العربية](README_ar.md)

<div align="center">

# ai-initializer

**一条命令，让任何 AI 智能体立即理解您的项目。**

（项目扫描 → 生成 AGENTS.md + 上下文 → 任何 AI 工具立即可用）

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)

</div>

---

## 立即体验

此存储库包含预构建的 `AGENTS.md` 和 `.ai-agents/` 文件，可作为示例直接使用。
克隆后立即运行 `ai-agency.sh`，即可查看实际效果：

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

## 应用到您的项目

> **重要：** 请将 `setup.sh` 和 `HOW_TO_AGENTS.md` 复制到**您自己的项目目录**中，然后在那里运行。这些文件会分析目标项目的结构——它们必须位于项目内部。

```bash
# 1. 将文件复制到您的项目中
cp setup.sh HOW_TO_AGENTS.md /path/to/your-project/

# 2. 进入您的项目目录
cd /path/to/your-project/

# 3. 运行设置（扫描项目并生成所有上下文）
./setup.sh

# 4. 启动 AI 智能体会话
./ai-agency.sh
```

<details>
<summary>手动设置（不使用 setup.sh）</summary>

> **Token 用量提示** — 在初次设置期间，顶级模型会分析整个项目并生成多个文件（AGENTS.md、.ai-agents/context/、.ai-agents/skills/、.ai-agents/roles/）。根据项目规模，这可能消耗数万个 token。这是一次性成本；后续会话将加载预构建的上下文并立即启动。

```bash
# 1. 让 AI 读取 HOW_TO_AGENTS.md，其余由它处理

# 方式 A：英文（推荐 — token 成本更低，AI 性能最佳）
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Read HOW_TO_AGENTS.md and generate AGENTS.md tailored to this project"

# 方式 B：用户语言（如果您计划手动编辑 AGENTS.md，推荐此方式）
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "阅读 HOW_TO_AGENTS.md 并为此项目生成定制的 AGENTS.md"

# 推荐：--model claude-opus-4-6（或更新版本）以获得最佳效果
# 推荐：--dangerously-skip-permissions 以实现不间断的自主执行

# 2. 使用生成的智能体开始工作
./ai-agency.sh
```

</details>

---

## 为什么需要它？

### 问题：AI 每次会话都会失忆

```
 会话 1                  会话 2                  会话 3
┌──────────┐             ┌──────────┐             ┌──────────┐
│ AI 读取  │             │ AI 读取  │             │ 重新     │
│ 整个     │  会话       │ 整个     │  会话       │ 从头     │
│ 代码库   │  结束       │ 代码库   │  结束       │ 开始     │
│ (30 分钟)│ ──────→     │ (30 分钟)│ ──────→     │ (30 分钟)│
│ 开始     │ 记忆        │ 开始     │ 记忆        │ 开始     │
│ 工作     │ 丢失！      │ 工作     │ 丢失！      │ 工作     │
│          │             │          │             │          │
└──────────┘             └──────────┘             └──────────┘
```

AI 智能体在会话结束时会忘记一切。每次都需要花时间了解项目结构、分析 API 并学习规范。

| 问题 | 后果 |
|---|---|
| 不了解团队规范 | 代码风格不一致 |
| 不了解完整的 API 地图 | 每次都要探索整个代码库（成本增加 +20%） |
| 不知道禁止的操作 | 直接访问生产数据库等危险操作 |
| 不了解服务依赖关系 | 遗漏副作用 |

### 解决方案：为 AI 预构建一个"大脑"

```
 会话开始
┌──────────────────────────────────────────────────┐
│                                                  │
│  读取 AGENTS.md（自动）                          │
│       │                                          │
│       ▼                                          │
│  "我是此服务的后端专家"                          │
│  "规范：Conventional Commits，TypeScript strict" │
│  "禁止：修改其他服务，硬编码密钥"                │
│       │                                          │
│       ▼                                          │
│  加载 .ai-agents/context/ 文件（5 秒）           │
│  "已了解 20 个 API，15 个实体，8 个事件"         │
│       │                                          │
│       ▼                                          │
│  立即开始工作！                                  │
│                                                  │
└──────────────────────────────────────────────────┘
```

**ai-initializer** 解决了这个问题 — 生成一次，任何 AI 工具都能立即理解您的项目。

---

## 核心原则：三层架构

```
                    您的项目
                         │
            ┌────────────┼────────────┐
            ▼            ▼            ▼

     ┌──────────┐  ┌──────────┐  ┌──────────┐
     │ AGENTS.md│  │.ai-agents│  │.ai-agents│
     │          │  │ /context/│  │ /skills/ │
     │   身份   │  │   知识   │  │   行为   │
     │ "我是    │  │ "我知道  │  │ "我如何  │
     │  谁？"   │  │  什么？" │  │  工作？" │
     │          │  │          │  │          │
     │ + 规则   │  │ + 领域   │  │ + 部署   │
     │ + 权限   │  │ + 模型   │  │ + 审查   │
     │ + 路径   │  │          │  │          │
     └──────────┘  └──────────┘  └──────────┘
      入口点        记忆存储       工作流程标准
```

### 1. AGENTS.md — "我是谁？"

部署在每个目录中的智能体的**身份文件**。

```
project/
├── AGENTS.md                  ← PM：协调一切的领导者
├── apps/
│   └── api/
│       └── AGENTS.md          ← API 专家：仅负责此服务
├── infra/
│   ├── AGENTS.md              ← SRE：管理所有基础设施
│   └── monitoring/
│       └── AGENTS.md          ← 监控专家
└── configs/
    └── AGENTS.md              ← 配置管理员
```

它的工作方式就像一张**团队组织架构图**：
- PM 总览全局并分配任务
- 每个团队成员只深入了解自己的领域
- 他们不直接处理其他团队的工作 — 而是提出请求

### 2. `.ai-agents/context/` — "我知道什么？"

一个**预先整理好基本知识**的文件夹，让 AI 不必每次都读取代码。

```
.ai-agents/context/
├── domain-overview.md     ← "此服务处理订单管理..."
├── data-model.md          ← "存在 Order、Payment、Delivery 实体..."
├── api-spec.json          ← "POST /orders, GET /orders/{id}, ..."
└── event-spec.json        ← "发布 order-created 事件..."
```

**类比：** 新员工的入职文档。记录一次，无需再次解释。

### 3. `.ai-agents/skills/` — "我如何工作？"

重复性任务的**标准化工作流程手册**。

```
.ai-agents/skills/
├── develop/SKILL.md       ← "功能开发：分析 → 设计 → 实现 → 测试 → PR"
├── deploy/SKILL.md        ← "部署：打标签 → 提交请求 → 验证"
└── review/SKILL.md        ← "审查：安全、性能、测试清单"
```

**类比：** 团队操作手册 — 让 AI 遵循"提交 PR 前检查此清单"等规则。

---

## 应该写什么，不应该写什么

> 苏黎世联邦理工学院（2026.03）：**包含可推断的内容会降低成功率并增加 +20% 的成本**

```
         应该写这些                        不应该写这些
  ┌─────────────────────────┐     ┌─────────────────────────┐
  │                         │     │                         │
  │  "提交使用 feat: 格式"  │     │  "源代码在 src/ 文件夹" │
  │  AI 无法推断这一点      │     │  AI 可以用 ls 看到      │
  │                         │     │                         │
  │  "禁止直接推送到 main"  │     │  "React 是基于组件的"   │
  │  团队规则，代码中没有   │     │  已在官方文档中         │
  │                         │     │                         │
  │  "部署前需要 QA 团队    │     │  "此文件有 100 行"      │
  │   批准"                 │     │  AI 可以直接读取        │
  │  流程，无法推断         │     │                         │
  │                         │     │                         │
  └─────────────────────────┘     └─────────────────────────┘
       写入 AGENTS.md                    不要写！
```

**例外：** "可以推断但每次推断成本太高的内容"

```
  例如：完整的 API 列表（需要读取 20 个文件才能搞清楚）
  例如：数据模型关系（分散在 10 个文件中）
  例如：服务间调用关系（需要同时检查代码 + 基础设施）

  → 将这些预先整理到 .ai-agents/context/ 中！
  → 在 AGENTS.md 中，只写路径："去这里查找"
```

```
包含（不可推断）            .ai-agents/context/（推断成本高）    排除（推断成本低）
────────────────            ────────────────────────────────    ────────────────
团队规范                    完整 API 地图                        目录结构
禁止的操作                  数据模型关系                         单个文件内容
PR/提交格式                 事件发布/订阅规范                     官方框架文档
隐藏的依赖关系              基础设施拓扑                          导入关系
                           KPI 目标与业务指标
                           干系人地图与审批流程
                           运营手册与升级路径
                           路线图与里程碑跟踪
```

---

## 工作原理

### 第一步：项目扫描与分类

探索深度达 3 层的目录，并按文件模式自动分类。

```
deployment.yaml + service.yaml  →  k8s-workload
values.yaml (Helm)              →  infra-component
package.json + *.tsx            →  frontend
go.mod                          →  backend-go
Dockerfile + CI config          →  cicd
...自动检测 19 种类型
```

### 第二步：上下文生成

根据检测到的类型，通过**实际分析代码**来生成 `.ai-agents/context/` 知识文件。

```
检测到后端服务
  → 扫描路由/控制器 → 生成 api-spec.json
  → 扫描实体/模式   → 生成 data-model.md
  → 扫描 Kafka 配置 → 生成 event-spec.json
```

### 第三步：AGENTS.md 生成

使用适当的模板为每个目录生成 AGENTS.md。

```
根 AGENTS.md（全局规范）
  → 提交：Conventional Commits
  → PR：需要模板，1+ 个批准
  → 分支：feature/{ticket}-{desc}
       │
       ▼ 自动继承（不在子级中重复）
  apps/api/AGENTS.md
    → 仅覆盖："此服务使用 Python"
```

全局规则使用**继承模式** — 在一处编写，自动向下游应用。

```
根 AGENTS.md ──────────────────────────────────────────
│ 全局规范：
│  - 提交：Conventional Commits (feat:, fix:, chore:)
│  - PR：需要模板，至少 1 名审查者
│  - 分支：feature/{ticket}-{desc}
│
│     自动继承                      自动继承
│     ┌──────────────────┐       ┌──────────────────┐
│     ▼                  │       ▼                  │
│  apps/api/AGENTS.md    │    infra/AGENTS.md       │
│  （仅指定附加规则）    │    （仅指定附加规则）    │
│  "此服务使用 Python"   │    "更改 Helm values 时  │
│                        │     先询问"              │
└─────────────────────────┴──────────────────────────
```

**优势：**
- 想更改提交规则？→ 只需修改根目录
- 添加新服务？→ 全局规则自动应用
- 特定服务需要不同规则？→ 在该服务的 AGENTS.md 中覆盖

### 第四步：供应商特定的引导程序

添加到供应商特定配置的桥接，使**所有 AI 工具都能读取**生成的 AGENTS.md。

```
┌──────────────┐     ┌─────────────┐     ┌─────────────┐
│ Claude Code  │     │   Cursor    │     │   Codex     │
│  CLAUDE.md   │     │  .mdc rules │     │  AGENTS.md  │
│      ↓       │     │      ↓      │     │  （原生）   │
│ "读取        │     │ "读取       │     │      ✓      │
│  AGENTS.md"  │     │  AGENTS.md" │     │             │
└──────┬───────┘     └──────┬──────┘     └─────────────┘
       └──────────┬─────────┘
                  ▼
           AGENTS.md（单一真相来源）
                  │
        ┌─────────┼─────────┐
        ▼         ▼         ▼
  .ai-agents/  .ai-agents/  .ai-agents/
   context/     skills/      roles/
```

> **原则：** 引导程序文件仅为已使用的供应商生成。从不为未使用的工具创建配置文件。

---

## 供应商兼容性

| 工具 | 自动读取 AGENTS.md | 引导程序 |
|---|---|---|
| **OpenAI Codex** | 是（原生） | 不需要 |
| **Claude Code** | 部分（回退） | 向 `CLAUDE.md` 添加指令 |
| **Cursor** | 否 | 向 `.cursor/rules/` 添加 `.mdc` |
| **GitHub Copilot** | 否 | 生成 `.github/copilot-instructions.md` |
| **Windsurf** | 否 | 向 `.windsurfrules` 添加指令 |
| **Aider** | 是 | 向 `.aider.conf.yml` 添加读取配置 |

自动生成引导程序：
```bash
bash scripts/sync-ai-rules.sh
```

---

## 生成的结构

```
project-root/
├── AGENTS.md                          # PM 智能体（整体编排）
├── .ai-agents/
│   ├── context/                       # 知识文件（会话开始时加载）
│   │   ├── domain-overview.md         #   业务领域、策略、约束
│   │   ├── data-model.md             #   实体定义、关系、状态转换
│   │   ├── api-spec.json              #   API 地图（JSON DSL，节省 3 倍 token）
│   │   ├── event-spec.json            #   Kafka/MQ 事件规范
│   │   ├── infra-spec.md              #   Helm chart、网络、部署顺序
│   │   ├── external-integration.md    #   外部 API、认证、速率限制
│   │   ├── business-metrics.md        #   KPI、OKR、收入模型、成功指标
│   │   ├── stakeholder-map.md         #   决策者、审批流程、RACI
│   │   ├── ops-runbook.md             #   运营规程、升级路径、SLA
│   │   └── planning-roadmap.md        #   里程碑、依赖关系、时间线
│   ├── skills/                        # 行为工作流程（按需加载）
│   │   ├── develop/SKILL.md           #   开发：分析 → 设计 → 实现 → 测试 → PR
│   │   ├── deploy/SKILL.md            #   部署：打标签 → 部署请求 → 验证
│   │   ├── review/SKILL.md            #   审查：基于清单
│   │   ├── hotfix/SKILL.md            #   紧急修复工作流程
│   │   └── context-update/SKILL.md    #   上下文文件更新程序
│   └── roles/                         # 角色定义（特定角色的上下文深度）
│       ├── pm.md                      #   项目经理
│       ├── backend.md                 #   后端开发者
│       ├── frontend.md                #   前端开发者
│       ├── sre.md                     #   SRE / 基础设施
│       └── reviewer.md               #   代码审查者
│
├── apps/
│   ├── api/AGENTS.md                  # 每个服务的智能体
│   └── web/AGENTS.md
└── infra/
    └── helm/AGENTS.md
```

---

## 会话启动器

所有智能体设置完成后，运行 `./ai-agency.sh` 选择智能体并启动会话。

```bash
./ai-agency.sh              # 交互式选择智能体 + AI 工具
./ai-agency.sh --multi      # 并行启动多个智能体（需要 tmux）
```

---

## Token 优化

| 格式 | Token 数量 | 备注 |
|---|---|---|
| 自然语言 API 描述 | ~200 token | |
| JSON DSL | ~70 token | **节省 3 倍** |

**api-spec.json 示例：**
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

**AGENTS.md 目标：** 替换后不超过 **300 token**

---

## 会话恢复协议

```
会话开始：
  1. 读取 AGENTS.md（大多数 AI 工具自动执行此操作）
  2. 按照上下文文件路径加载 .ai-agents/context/
  3. 检查 .ai-agents/context/current-work.md（进行中的工作）
  4. git log --oneline -10（了解最近的更改）

会话结束：
  1. 进行中的工作 → 记录在 current-work.md 中
  2. 新学到的领域知识 → 更新上下文文件
  3. 未完成的 TODO → 明确记录
```

---

## 上下文维护

当代码发生更改时，`.ai-agents/context/` 文件必须相应更新。

```
API 添加/更改/删除     →  更新 api-spec.json
数据库架构更改         →  更新 data-model.md
事件规范更改           →  更新 event-spec.json
业务策略更改           →  更新 domain-overview.md
外部集成更改           →  更新 external-integration.md
基础设施配置更改       →  更新 infra-spec.md
KPI/OKR 目标更改       →  更新 business-metrics.md
团队结构更改           →  更新 stakeholder-map.md
运营流程更改           →  更新 ops-runbook.md
里程碑/路线图更改      →  更新 planning-roadmap.md
```

> 未能更新意味着下一个会话将**使用过时的上下文工作**。

---

## 整体流程总结

```
┌──────────────────────────────────────────────────────────────────┐
│  1. 初始设置（一次性）                                           │
│                                                                  │
│  运行 ./setup.sh                                                 │
│       │                                                          │
│       ▼                                                          │
│  AI 分析项目结构                                                 │
│       │                                                          │
│       ▼                                                          │
│  在每个目录中创建 AGENTS.md        在 .ai-agents/context/ 中     │
│  （智能体身份 + 规则              整理知识                       │
│   + 权限）                        （API、模型、事件规范）        │
│                                                                  │
│  在 .ai-agents/skills/ 中         在 .ai-agents/roles/ 中        │
│  定义工作流程                      定义角色                      │
│  （开发、部署、审查流程）           （后端、前端、SRE）          │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  2. 日常使用                                                     │
│                                                                  │
│  运行 ./ai-agency.sh                                             │
│       │                                                          │
│       ▼                                                          │
│  选择智能体（PM？后端？SRE？）                                   │
│       │                                                          │
│       ▼                                                          │
│  选择 AI 工具（Claude？Codex？Cursor？）                         │
│       │                                                          │
│       ▼                                                          │
│  会话启动 → AGENTS.md 自动加载 → .ai-agents/context/             │
│  加载 → 开始工作！                                               │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  3. 持续维护                                                     │
│                                                                  │
│  当代码更改时：                                                  │
│    - AI 自动更新 .ai-agents/context/                             │
│    - 或由人工指示"这很重要，请记录下来"                          │
│                                                                  │
│  添加新服务时：                                                  │
│    - 重新运行 ./setup.sh → 自动生成新的 AGENTS.md                │
│    - 全局规则自动继承                                            │
│                                                                  │
│  当 AI 犯错时：                                                  │
│    - "重新分析这个" → 提供提示 → 一旦理解，                      │
│      更新 .ai-agents/context/                                    │
│    - 这个反馈循环可以提高上下文质量                              │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## 类比：传统团队 vs AI 智能体团队

```
              传统开发团队                AI 智能体团队
              ────────────────────       ──────────────────
 领导者       PM（人类）                  根 AGENTS.md（PM 智能体）
 成员         N 名开发者                  每个目录中的 AGENTS.md
 入职         Confluence/Notion          .ai-agents/context/
 手册         团队 Wiki                  .ai-agents/skills/
 角色定义     职位/职责文档              .ai-agents/roles/
 团队规则     团队规范文档              全局规范（继承）
 上班         到达办公室                  会话开始 → AGENTS.md 加载
 下班         离开（记忆保留）            会话结束（记忆丢失！）
 次日         记忆完整                   .ai-agents/context/ 加载（记忆恢复）
```

**关键区别：** 人类离开工作后能保留记忆，但 AI 每次都会忘记一切。
这就是 `.ai-agents/context/` 存在的原因 — 它充当 AI 的**长期记忆**。

---

## 采用清单

```
第一阶段（基础）               第二阶段（上下文）                第三阶段（运营）
────────────────               ─────────────────                ────────────────────
☐ 生成 AGENTS.md               ☐ 创建 .ai-agents/context/       ☐ 定义 .ai-agents/roles/
☐ 记录构建/测试命令            ☐ domain-overview.md             ☐ 运行多智能体会话
☐ 记录规范和规则               ☐ api-spec.json (DSL)            ☐ .ai-agents/skills/ 工作流程
☐ 全局规范                    ☐ data-model.md                  ☐ 迭代反馈循环
☐ 供应商引导程序               ☐ 设置维护规则
```

---

## 交付物

| 文件 | 受众 | 用途 |
|---|---|---|
| `setup.sh` | 人类 | 一键安装：扫描项目并生成所有上下文文件 |
| `HOW_TO_AGENTS.md` | AI | 智能体读取并执行的元指令手册 |
| `README.md` | 人类 | 本文档 — 供人类理解的指南 |
| `ai-agency.sh` | 人类 | 智能体选择 → AI 会话启动器 |
| `AGENTS.md`（每个目录） | AI | 每个目录的智能体身份 + 规则 |
| `.ai-agents/context/*.md/json` | AI | 预先整理的领域知识 |
| `.ai-agents/skills/*/SKILL.md` | AI | 标准化工作流程 |
| `.ai-agents/roles/*.md` | AI/人类 | 每个角色的上下文加载策略 |

---

## 参考资料

- [Kurly OMS 团队 AI 工作流程](https://helloworld.kurly.com/blog/oms-claude-ai-workflow/) — 本系统上下文设计的灵感来源
- [AGENTS.md 标准](https://agents.md/) — 供应商中立的智能体指令标准
- [苏黎世联邦理工学院研究](https://www.infoq.com/news/2026/03/agents-context-file-value-review/) — "只记录无法推断的内容"

---

## 许可证

MIT

---

<p align="center">
  <sub>将 AI 智能体理解您项目所需的时间缩短为零。</sub>
</p>
