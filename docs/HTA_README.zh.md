# AI 代理管理系统 — 写给人类的指南

## 如何开始？

> **Token 用量警告** — 初始设置使用顶级模型分析整个项目并生成多个文件（AGENTS.md、.ai-agents/context/、.ai-agents/skills/、.ai-agents/roles/）。根据项目规模，可能消耗数万甚至更多 token。这是一次性成本——后续会话通过加载预构建的上下文即可立即开始。

```bash
# 1. 让 AI 阅读 HOW_TO_AGENTS.md，它会自动完成配置

# 选项 A：英语（推荐 — 更低的 token 成本，最佳 AI 性能）
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Read HOW_TO_AGENTS.md and generate AGENTS.md tailored to this project"

# 选项 B：你的语言（如果需要人工直接编辑 AGENTS.md 推荐使用）
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "阅读 HOW_TO_AGENTS.md 并根据本项目生成 AGENTS.md（使用中文）"

# 推荐：--dangerously-skip-permissions 实现无中断自主设置
# 推荐：--model claude-opus-4-6（或更新版本）以获得最佳效果

# 2. 使用生成的代理开始工作
./ai-agency.sh

# 3. 之后的会话可以自动立即开始工作！
```

> 本文档是**供人类阅读和理解的**文档。
> 它解释了 AI 执行的指令文件（HOW_TO_AGENTS.md）为何存在、基于什么原理运作，
> 以及在您的开发工作流中扮演什么角色。

---

## 为什么需要这样的系统？

### 问题：AI 每次都会丢失记忆

```
 会话 1                    会话 2                    会话 3
┌──────────┐             ┌──────────┐             ┌──────────┐
│ AI 读取   │             │ AI 再次   │             │ 又从头开始 │
│ 全部代码  │  会话结束    │ 读取全部  │  会话结束    │ 读取全部  │
│ (30分钟)  │ ──────→    │ (30分钟)  │ ──────→    │ (30分钟)  │
│ 开始工作  │ 记忆消失!   │ 开始工作  │ 记忆消失!   │ 开始工作  │
└──────────┘             └──────────┘             └──────────┘
```

AI 代理在会话结束后会忘记一切。
每次都要花时间了解项目结构、分析 API、理解编码规范。

### 解决方案：预先为 AI 构建"大脑"

```
 会话开始
┌──────────────────────────────────────────────────┐
│                                                  │
│  读取 AGENTS.md（自动）                            │
│       │                                          │
│       ▼                                          │
│  "我是 doppel-api 的后端专家"                       │
│  "规范：Conventional Commits, TypeScript strict"  │
│  "禁止：修改其他服务、硬编码密钥"                     │
│       │                                          │
│       ▼                                          │
│  加载 .ai-agents/context/ 文件（5秒）                     │
│  "已掌握 20 个 API、15 个实体、8 个事件"             │
│       │                                          │
│       ▼                                          │
│  立即开始工作！                                    │
│                                                  │
└──────────────────────────────────────────────────┘
```

---

## 核心原理：三层架构

```
                    您的项目
                         │
            ┌────────────┼────────────┐
            ▼            ▼            ▼

     ┌──────────┐  ┌──────────┐  ┌──────────┐
     │ AGENTS.md│  │.ai-agents/context│  │.ai-agents/skills│
     │          │  │          │  │          │
     │ 人格     │  │ 知识     │  │ 行为     │
     │ "我是    │  │ "这个服务│  │ "开发时  │
     │  谁"     │  │  的 API  │  │  应该    │
     │          │  │  是这样的"│  │  这样做" │
     │ + 规则   │  │          │  │          │
     │ + 权限   │  │ + 领域   │  │ + 部署   │
     │ + 路径   │  │ + 模型   │  │ + 评审   │
     └──────────┘  └──────────┘  └──────────┘
         入口点        记忆存储       工作流标准
```

### 1. AGENTS.md — "我是谁"

这是部署在各目录中的代理的**身份文件**。

```
项目/
├── AGENTS.md                  ← PM：协调全局的领导者
├── apps/
│   └── doppel-api/
│       └── AGENTS.md          ← API 专家：只负责此服务
├── infra/
│   ├── AGENTS.md              ← SRE：管理整体基础设施
│   └── monitoring/
│       └── AGENTS.md          ← 监控专家
└── configs/
    └── AGENTS.md              ← 配置管理员
```

就像**团队组织架构图**一样：
- PM 总览全局并分配任务
- 每个成员只深入理解自己的领域
- 不直接处理其他团队的工作，而是发起请求

### 2. `.ai-agents/context/` — "知道什么"

为了让 AI 不必每次都重新阅读代码，**预先整理好核心知识**的文件夹。

```
.ai-agents/context/
├── domain-overview.md     ← "这个服务负责订单管理..."
├── data-model.md          ← "有 Order、Payment、Delivery 实体..."
├── api-spec.json          ← "POST /orders, GET /orders/{id}, ..."
└── event-spec.json        ← "发布 order-created 事件..."
```

**比喻：** 就像给新员工准备的入职文档。
"我们团队做什么、数据库结构是怎样的、有哪些 API"——整理一次，
就不需要每次都重新说明了。

### 3. `.ai-agents/skills/` — "如何工作"

将重复性任务标准化的**工作流手册**。

```
.ai-agents/skills/
├── develop/SKILL.md       ← "功能开发：分析 → 设计 → 实现 → 测试 → PR"
├── deploy/SKILL.md        ← "部署：打标签 → 提交申请 → 验证"
└── review/SKILL.md        ← "评审：安全·性能·测试检查清单"
```

**比喻：** 团队的作业手册。
"提交 PR 时请检查这个清单"——让 AI 也遵循同样的流程。

---

## 如何管理全局规则？

使用**继承模式**。在一处编写，自动向下应用。

```
根目录 AGENTS.md ──────────────────────────────────────────
│ Global Conventions:
│  - 提交：Conventional Commits (feat:, fix:, chore:)
│  - PR：必须使用模板，至少 1 人评审
│  - 分支：feature/{ticket}-{desc}
│  - 代码：TypeScript strict, single quotes
│
│     自动继承                    自动继承
│     ┌──────────────────┐       ┌──────────────────┐
│     ▼                  │       ▼                  │
│  apps/api/AGENTS.md    │    infra/AGENTS.md       │
│  (仅填写额外规则)        │    (仅填写额外规则)        │
│  "此服务使用            │    "修改 Helm values 时    │
│   Python"              │     Ask First"           │
│     (替代 TypeScript)   │                          │
└─────────────────────────┴──────────────────────────
```

**优点：**
- 想修改提交规则？ → 只需修改根目录一处
- 添加新服务？ → 自动应用全局规则
- 某个服务需要不同规则？ → 在该服务的 AGENTS.md 中覆盖

---

## 应该写什么，不应该写什么？

根据苏黎世联邦理工学院（ETH Zurich）2026 年的研究，如果在文档中写入 AI 已经能推理出的内容，
反而会**降低成功率并增加 20% 的成本**。

```
                应该写的                         不应该写的
     ┌─────────────────────────┐     ┌─────────────────────────┐
     │                         │     │                         │
     │  "提交格式用 feat:"       │     │  "源码在 src/ 文件夹里"   │
     │  AI 无法推理的内容        │     │  AI 用 ls 就能直接看到    │
     │                         │     │                         │
     │  "禁止直接 push main"    │     │  "React 是基于组件的"     │
     │  团队规则，代码中没有      │     │  官方文档中已有            │
     │                         │     │                         │
     │  "部署前必须 QA 团队审批"  │     │  "这个文件有 100 行"      │
     │  流程规则，无法推理        │     │  AI 直接读取就知道        │
     │                         │     │                         │
     └─────────────────────────┘     └─────────────────────────┘
             写入 AGENTS.md                     禁止写入！
```

**但有例外：** "理论上可以推理，但每次都推理的话成本太高"

```
  例：完整 API 列表（需要读取全部 20 个文件才能了解）
  例：数据模型关系图（分散在 10 个文件中）
  例：服务间调用关系（需要同时检查代码和基础设施）

  → 这些应预先整理到 .ai-agents/context/ 中！
  → AGENTS.md 中只写"去这里查看"的路径
```

---

## 会话启动脚本

所有代理配置完成后，可以选择所需的代理并立即启动会话。

```bash
$ ./ai-agency.sh

=== AI Agent Sessions ===
Project: /Users/nhn/src/doppel-deploy
Found: 8 agent(s)

  1) [PM] doppel-deploy
     Path: ./AGENTS.md
     本项目的 PM 代理。掌握整体结构并分配任务。

  2) doppel-api
     Path: apps/dev/doppel-api/AGENTS.md
     doppel-api 服务的 K8s 清单管理专家。

  3) monitoring
     Path: infra/monitoring/AGENTS.md
     Prometheus + Grafana 监控栈的 SRE 专家。

  ...

Select agent (number): 2

=== AI Tool ===
  1) claude
  2) codex
  3) print

Select tool: 1

→ claude 会话在 doppel-api 目录中启动
→ 代理自动加载 AGENTS.md 和 .ai-agents/context/
→ 可以立即开始工作！
```

**并行执行（tmux）：**

```bash
$ ./ai-agency.sh --multi

Select agents: 1,2,3   # PM + API + 监控同时运行

→ 打开 3 个 tmux 会话
→ 每个窗口中不同的代理独立工作
→ 使用 Ctrl+B N 切换窗口
```

---

## 整体流程概要

```
┌──────────────────────────────────────────────────────────────────┐
│  1. 初始设置（一次性）                                              │
│                                                                  │
│  让 AI 阅读 HOW_TO_AGENTS.md                                      │
│       │                                                          │
│       ▼                                                          │
│  AI 分析项目结构                                                   │
│       │                                                          │
│       ▼                                                          │
│  在各目录生成 AGENTS.md          整理 .ai-agents/context/ 知识             │
│  （代理人格 + 规则 + 权限）       （API、模型、事件规范）              │
│                                                                  │
│  定义 .ai-agents/skills/ 工作流         定义 .ai-agents/roles/ 角色               │
│  （开发、部署、评审流程）         （Backend, Frontend, SRE）          │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  2. 日常使用                                                      │
│                                                                  │
│  运行 ./ai-agency.sh                                       │
│       │                                                          │
│       ▼                                                          │
│  选择代理（PM？Backend？SRE？）                                    │
│       │                                                          │
│       ▼                                                          │
│  选择 AI 工具（Claude？Codex？Cursor？）                           │
│       │                                                          │
│       ▼                                                          │
│  启动会话 → 自动加载 AGENTS.md → 加载 .ai-agents/context/ → 开始工作！     │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  3. 持续管理                                                      │
│                                                                  │
│  代码变更时：                                                     │
│    - AI 自动更新 .ai-agents/context/（在 AGENTS.md 中以规则明确规定）      │
│    - 或者人工指示"这个很重要，记录下来"                               │
│                                                                  │
│  添加新服务时：                                                    │
│    - 重新运行 HOW_TO_AGENTS.md → 自动生成新的 AGENTS.md             │
│    - 自动继承全局规则                                               │
│                                                                  │
│  AI 出错时：                                                      │
│    - "重新分析一下" → 提供提示 → 理解后更新 .ai-agents/context/             │
│    - 这个反馈循环提升上下文质量                                      │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## 产出物列表

本系统生成的文件及各自用途：

| 文件 | 对象 | 用途 |
|---|---|---|
| `HOW_TO_AGENTS.md` | AI | 代理阅读并执行的元指令文件 |
| `HOW_TO_AGENTS_PLAN.md` | 人/AI | 设计计划书（为什么采用这种结构的背景） |
| `README.md` | 人 | 本文档。供人类理解的指南 |
| `ai-agency.sh` | 人 | 选择代理 → 启动 AI 会话的启动器 |
| `AGENTS.md`（各目录） | AI | 各目录的代理身份 + 规则 |
| `.ai-agents/context/*.md/json` | AI | 预先整理的领域知识 |
| `.ai-agents/skills/*/SKILL.md` | AI | 标准化的工作流 |
| `.ai-agents/roles/*.md` | AI/人 | 按角色的上下文加载策略 |

---

## 核心比喻

```
              传统开发团队              AI 代理团队
              ────────────             ────────────────
 领导        PM（人）                  根目录 AGENTS.md（PM 代理）
 团队成员    N 名开发者               各目录的 AGENTS.md
 入职文档    Confluence/Notion        .ai-agents/context/
 操作手册    团队 Wiki                .ai-agents/skills/
 角色定义    职级/R&R 文档            .ai-agents/roles/
 团队规则    团队规范文档             Global Conventions（继承）
 上班        到达办公室               启动会话 → 加载 AGENTS.md
 下班        下班（记忆保留）          会话结束（记忆消失！）
 第二天上班  有记忆                   加载 .ai-agents/context/（记忆恢复）
```

**核心差异：** 人下班后依然保有记忆，但 AI 每次都会遗忘。
这就是 `.ai-agents/context/` 存在的原因——它充当 AI 的**长期记忆**。

---

## 参考

- [Kurly OMS 团队 AI 工作流](https://helloworld.kurly.com/blog/oms-claude-ai-workflow/) — 本系统上下文设计的灵感来源
- [AGENTS.md 标准](https://agents.md/) — 厂商中立的代理指令标准
- [ETH Zurich 研究](https://www.infoq.com/news/2026/03/agents-context-file-value-review/) — "只记录无法推理的内容"
