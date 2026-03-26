🌐 [English](../README.md) | [한국어](README_ko.md) | [日本語](README_ja.md) | [中文](README_zh.md) | [Español](README_es.md) | [Français](README_fr.md) | [Deutsch](README_de.md) | [Русский](README_ru.md) | [हिन्दी](README_hi.md) | [العربية](README_ar.md)

# ai-initializer

**AI 编程工具的自动项目上下文生成器**

> 扫描你的项目目录，自动生成
> `AGENTS.md` + 知识/技能/角色上下文，让 AI 代理可以立即开始工作。

```
一条命令 → 项目分析 → AGENTS.md 生成 → 适用于任何 AI 工具
```

---

## 使用方法

> **Token 用量提示** — 在初始设置期间，顶级模型会分析整个项目并生成多个文件（AGENTS.md、.ai-agents/context/、.ai-agents/skills/、.ai-agents/roles/）。根据项目规模，这可能消耗数万个 token。这是一次性成本；后续会话会加载预构建的上下文并立即启动。

```bash
# 1. 让 AI 阅读 HOW_TO_AGENTS.md，剩下的它会自行处理

# 选项 A：英文（推荐 — 更低的 token 成本，最佳 AI 性能）
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Read HOW_TO_AGENTS.md and generate AGENTS.md tailored to this project"

# 选项 B：用户的语言（如果你打算手动编辑 AGENTS.md，推荐使用）
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "HOW_TO_AGENTS.md를 읽고 이 프로젝트에 맞게 AGENTS.md를 생성하라"

# 推荐：--model claude-opus-4-6（或更高版本）以获得最佳效果
# 推荐：--dangerously-skip-permissions 用于不中断的自主执行

# 2. 使用生成的代理开始工作
./ai-agency.sh
```

---

## 为什么需要这个？

### 问题：AI 每次会话都会丢失记忆

```
 会话 1                    会话 2                    会话 3
┌──────────┐             ┌──────────┐             ┌──────────┐
│ AI 阅读   │             │ AI 阅读   │             │ 再次从    │
│ 整个      │  会话       │ 整个      │  会话       │ 零开始    │
│ 代码库    │  结束       │ 代码库    │  结束       │          │
│ (30 分钟) │ ──────→    │ (30 分钟) │ ──────→    │ (30 分钟) │
│ 开始      │ 记忆       │ 开始      │ 记忆       │ 开始      │
│ 工作      │ 丢失！     │ 工作      │ 丢失！     │ 工作      │
│           │             │           │             │          │
└──────────┘             └──────────┘             └──────────┘
```

AI 代理在会话结束时会遗忘所有内容。每次它们都要花时间理解项目结构、分析 API 和学习规范。

| 问题 | 后果 |
|---|---|
| 不了解团队规范 | 代码风格不一致 |
| 不了解完整的 API 地图 | 每次都要遍历整个代码库（成本 +20%） |
| 不了解禁止的操作 | 直接访问生产数据库等危险操作 |
| 不了解服务依赖关系 | 遗漏副作用 |

### 解决方案：为 AI 预构建一个"大脑"

```
 会话开始
┌──────────────────────────────────────────────────┐
│                                                  │
│  读取 AGENTS.md（自动）                            │
│       │                                          │
│       ▼                                          │
│  "我是这个服务的后端专家"                           │
│  "规范：Conventional Commits、TypeScript           │
│   strict"                                        │
│  "禁止：修改其他服务、                              │
│   硬编码密钥"                                     │
│       │                                          │
│       ▼                                          │
│  加载 .ai-agents/context/ 文件（5 秒）             │
│  "已理解 20 个 API、15 个实体、8 个事件"            │
│       │                                          │
│       ▼                                          │
│  立即开始工作！                                    │
│                                                  │
└──────────────────────────────────────────────────┘
```

**ai-initializer** 解决了这个问题 — 生成一次，任何 AI 工具都能立即理解你的项目。

---

## 核心原则：三层架构

```
                    你的项目
                         │
            ┌────────────┼────────────┐
            ▼            ▼            ▼

     ┌──────────┐  ┌──────────┐  ┌──────────┐
     │ AGENTS.md│  │.ai-agents│  │.ai-agents│
     │          │  │ /context/ │  │ /skills/ │
     │  身份    │  │   知识   │  │   行为   │
     │ "我是    │  │ "我了解  │  │ "我如何  │
     │  谁？"  │  │  什么？" │  │  工作？" │
     │          │  │          │  │          │
     │ + 规则   │  │ + 领域   │  │ + 部署   │
     │ + 权限   │  │ + 模型   │  │ + 评审   │
     │ + 路径   │  │          │  │          │
     └──────────┘  └──────────┘  └──────────┘
      入口点       记忆存储       工作流标准
```

### 1. AGENTS.md — "我是谁？"

部署在每个目录中的代理的**身份文件**。

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

它的运作方式就像一个**团队组织架构图**：
- PM 总览全局并分配任务
- 每个团队成员只深入了解自己的领域
- 他们不直接处理其他团队的工作 — 而是发出请求

### 2. `.ai-agents/context/` — "我了解什么？"

一个**预先组织好核心知识**的文件夹，使 AI 不必每次都阅读代码。

```
.ai-agents/context/
├── domain-overview.md     ← "该服务处理订单管理..."
├── data-model.md          ← "有 Order、Payment、Delivery 实体..."
├── api-spec.json          ← "POST /orders, GET /orders/{id}, ..."
└── event-spec.json        ← "发布 order-created 事件..."
```

**类比：** 新员工入职文档。写一次，就不需要任何人再解释。

### 3. `.ai-agents/skills/` — "我如何工作？"

针对重复性任务的**标准化工作流手册**。

```
.ai-agents/skills/
├── develop/SKILL.md       ← "功能开发：分析 → 设计 → 实现 → 测试 → PR"
├── deploy/SKILL.md        ← "部署：打标签 → 请求 → 验证"
└── review/SKILL.md        ← "评审：安全性、性能、测试检查清单"
```

**类比：** 团队运营手册 — 让 AI 遵循"提交 PR 前请检查此清单"等规则。

---

## 写什么和不写什么

> 苏黎世联邦理工学院（2026.03）：**包含可推断内容会降低成功率并增加 +20% 的成本**

```
         应该写的                          不应该写的
  ┌─────────────────────────┐     ┌─────────────────────────┐
  │                         │     │                         │
  │  "提交使用 feat: 格式"   │     │  "源代码在 src/ 文件夹"  │
  │  AI 无法推断这一点       │     │  AI 用 ls 就能看到       │
  │                         │     │                         │
  │  "不能直接推送到         │     │  "React 是基于组件的"    │
  │   main"                 │     │  官方文档中已有           │
  │  团队规则，不在代码中    │     │                         │
  │                         │     │  "这个文件有 100 行"     │
  │  "部署前需要 QA 团队     │     │  AI 可以直接读取         │
  │   审批"                 │     │                         │
  │  流程，不可推断          │     │                         │
  │                         │     │                         │
  └─────────────────────────┘     └─────────────────────────┘
       写在 AGENTS.md 中                不要写！
```

**例外：** "可以推断但每次推断成本太高的内容"

```
  例如：完整 API 列表（需要读 20 个文件才能搞清楚）
  例如：数据模型关系（分散在 10 个文件中）
  例如：服务间调用关系（需要同时检查代码 + 基础设施）

  → 将这些预先整理在 .ai-agents/context/ 中！
  → 在 AGENTS.md 中只写路径："去这里找"
```

```
包含（不可推断）                .ai-agents/context/（推断成本高）       排除（推断成本低）
───────────────────────        ────────────────────────────────────  ────────────────────────
团队规范                       完整 API 地图                         目录结构
禁止的操作                     数据模型关系                          单个文件内容
PR/提交格式                    事件发布/订阅规范                      官方框架文档
隐藏的依赖关系                 基础设施拓扑                          导入关系
```

---

## 工作原理

### 步骤 1：项目扫描与分类

探索最多深度为 3 的目录，并根据文件模式自动分类。

```
deployment.yaml + service.yaml  →  k8s-workload
values.yaml (Helm)              →  infra-component
package.json + *.tsx            →  frontend
go.mod                          →  backend-go
Dockerfile + CI config          →  cicd
...自动检测 19 种类型
```

### 步骤 2：上下文生成

根据检测到的类型**实际分析代码**，生成 `.ai-agents/context/` 知识文件。

```
检测到后端服务
  → 扫描 routes/controllers → 生成 api-spec.json
  → 扫描 entities/schemas   → 生成 data-model.md
  → 扫描 Kafka 配置         → 生成 event-spec.json
```

### 步骤 3：AGENTS.md 生成

使用适当的模板为每个目录生成 AGENTS.md。

```
根目录 AGENTS.md（全局规范）
  → 提交：Conventional Commits
  → PR：需要模板，1+ 审批
  → 分支：feature/{ticket}-{desc}
       │
       ▼ 自动继承（不在子目录中重复）
  apps/api/AGENTS.md
    → 仅覆盖："此服务使用 Python"
```

全局规则使用**继承模式** — 在一处编写，自动应用到下游。

```
根目录 AGENTS.md ──────────────────────────────────────────
│ 全局规范：
│  - 提交：Conventional Commits (feat:, fix:, chore:)
│  - PR：需要模板，至少 1 个审阅者
│  - 分支：feature/{ticket}-{desc}
│
│     自动继承                    自动继承
│     ┌──────────────────┐       ┌──────────────────┐
│     ▼                  │       ▼                  │
│  apps/api/AGENTS.md    │    infra/AGENTS.md       │
│  （仅指定额外的         │    （仅指定额外的         │
│   规则）               │     规则）               │
│  "此服务使用            │    "修改 Helm            │
│   Python"              │     values 时先询问"     │
└─────────────────────────┴──────────────────────────
```

**优势：**
- 想更改提交规则？→ 只修改根目录
- 添加新服务？→ 全局规则自动应用
- 某个服务需要不同的规则？→ 在该服务的 AGENTS.md 中覆盖

### 步骤 4：厂商特定引导

添加到厂商特定配置的桥接，使**所有 AI 工具都能读取**生成的 AGENTS.md。

```
┌──────────────┐     ┌─────────────┐     ┌─────────────┐
│ Claude Code  │     │   Cursor    │     │   Codex     │
│  CLAUDE.md   │     │  .mdc rules │     │  AGENTS.md  │
│      ↓       │     │      ↓      │     │  (原生)     │
│ "读取        │     │ "读取       │     │      ✓      │
│  AGENTS.md"  │     │  AGENTS.md" │     │             │
└──────┬───────┘     └──────┬──────┘     └─────────────┘
       └──────────┬─────────┘
                  ▼
           AGENTS.md（唯一事实来源）
                  │
        ┌─────────┼─────────┐
        ▼         ▼         ▼
  .ai-agents/  .ai-agents/  .ai-agents/
   context/     skills/      roles/
```

> **原则：** 引导文件仅为已在使用的厂商生成。不会为未使用的工具创建配置文件。

---

## 厂商兼容性

| 工具 | 自动读取 AGENTS.md | 引导方式 |
|---|---|---|
| **OpenAI Codex** | 是（原生） | 不需要 |
| **Claude Code** | 部分（回退） | 向 `CLAUDE.md` 添加指令 |
| **Cursor** | 否 | 向 `.cursor/rules/` 添加 `.mdc` |
| **GitHub Copilot** | 否 | 生成 `.github/copilot-instructions.md` |
| **Windsurf** | 否 | 向 `.windsurfrules` 添加指令 |
| **Aider** | 是 | 向 `.aider.conf.yml` 添加读取指令 |

自动生成引导文件：
```bash
bash scripts/sync-ai-rules.sh
```

---

## 生成的结构

```
project-root/
├── AGENTS.md                          # PM 代理（整体协调）
├── .ai-agents/
│   ├── context/                       # 知识文件（会话开始时加载）
│   │   ├── domain-overview.md         #   业务领域、策略、约束
│   │   ├── data-model.md             #   实体定义、关系、状态转换
│   │   ├── api-spec.json              #   API 地图（JSON DSL，节省 3 倍 token）
│   │   ├── event-spec.json            #   Kafka/MQ 事件规范
│   │   ├── infra-spec.md              #   Helm chart、网络、部署顺序
│   │   └── external-integration.md    #   外部 API、认证、速率限制
│   ├── skills/                        # 行为工作流（按需加载）
│   │   ├── develop/SKILL.md           #   开发：分析 → 设计 → 实现 → 测试 → PR
│   │   ├── deploy/SKILL.md            #   部署：打标签 → 部署请求 → 验证
│   │   ├── review/SKILL.md            #   评审：基于检查清单
│   │   ├── hotfix/SKILL.md            #   紧急修复工作流
│   │   └── context-update/SKILL.md    #   上下文文件更新流程
│   └── roles/                         # 角色定义（按角色划分的上下文深度）
│       ├── pm.md                      #   项目经理
│       ├── backend.md                 #   后端开发
│       ├── frontend.md                #   前端开发
│       ├── sre.md                     #   SRE / 基础设施
│       └── reviewer.md               #   代码审阅者
│
├── apps/
│   ├── api/AGENTS.md                  # 各服务代理
│   └── web/AGENTS.md
└── infra/
    └── helm/AGENTS.md
```

---

## 会话启动器

所有代理设置完成后，选择所需的代理并立即启动会话。

```bash
$ ./ai-agency.sh

=== AI 代理会话 ===
发现：8 个代理

  1) [PM] project-root
  2) api-service
  3) monitoring
  ...

选择代理（编号）：2

=== AI 工具 ===
  1) claude
  2) codex
  3) print

选择工具：1

→ 会话已在 api-service 目录中启动
→ 代理自动加载 AGENTS.md 和 .ai-agents/context/
→ 准备好立即开始工作！
```

**并行执行（tmux）：**

```bash
$ ./ai-agency.sh --multi

选择代理：1,2,3   # 同时运行 PM + API + 监控

→ 3 个 tmux 会话已打开
→ 不同的代理在各自的面板中独立工作
→ 使用 Ctrl+B N 切换面板
```

---

## Token 优化

| 格式 | Token 数量 | 备注 |
|---|---|---|
| 自然语言 API 描述 | ~200 tokens | |
| JSON DSL | ~70 tokens | **节省 3 倍** |

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

**AGENTS.md 目标：** 替换后不超过 **300 tokens**

---

## 会话恢复协议

```
会话开始：
  1. 读取 AGENTS.md（大多数 AI 工具会自动执行此操作）
  2. 按上下文文件路径加载 .ai-agents/context/
  3. 检查 .ai-agents/context/current-work.md（正在进行的工作）
  4. git log --oneline -10（了解最近的更改）

会话结束：
  1. 正在进行的工作 → 记录到 current-work.md
  2. 新学到的领域知识 → 更新上下文文件
  3. 未完成的 TODO → 明确记录
```

---

## 上下文维护

当代码发生变化时，`.ai-agents/context/` 文件必须相应更新。

```
API 新增/变更/移除         →  更新 api-spec.json
数据库模式变更             →  更新 data-model.md
事件规范变更               →  更新 event-spec.json
业务策略变更               →  更新 domain-overview.md
外部集成变更               →  更新 external-integration.md
基础设施配置变更           →  更新 infra-spec.md
```

> 未能及时更新意味着下一次会话将**使用过时的上下文工作**。

---

## 整体流程总结

```
┌──────────────────────────────────────────────────────────────────┐
│  1. 初始设置（一次性）                                             │
│                                                                  │
│  让 AI 阅读 HOW_TO_AGENTS.md                                      │
│       │                                                          │
│       ▼                                                          │
│  AI 分析项目结构                                                   │
│       │                                                          │
│       ▼                                                          │
│  在每个目录创建              在 .ai-agents/context/                 │
│  AGENTS.md                  中组织知识                             │
│  （代理身份 + 规则            （API、模型、事件规范）                 │
│   + 权限）                                                       │
│                                                                  │
│  在 .ai-agents/skills/      在 .ai-agents/roles/                  │
│  中定义工作流                中定义角色                             │
│  （开发、部署、评审           （后端、前端、SRE）                    │
│   流程）                                                         │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  2. 日常使用                                                      │
│                                                                  │
│  运行 ./ai-agency.sh                                              │
│       │                                                          │
│       ▼                                                          │
│  选择代理（PM？后端？SRE？）                                       │
│       │                                                          │
│       ▼                                                          │
│  选择 AI 工具（Claude？Codex？Cursor？）                           │
│       │                                                          │
│       ▼                                                          │
│  会话启动 → AGENTS.md 自动加载 → .ai-agents/context/               │
│  加载完成 → 开始工作！                                             │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  3. 持续维护                                                      │
│                                                                  │
│  当代码变更时：                                                    │
│    - AI 自动更新 .ai-agents/context/                               │
│    - 或者人工指示"这很重要，记录下来"                                │
│                                                                  │
│  当添加新服务时：                                                  │
│    - 再次运行 HOW_TO_AGENTS.md → 新的 AGENTS.md 自动生成           │
│    - 全局规则自动继承                                              │
│                                                                  │
│  当 AI 犯错时：                                                    │
│    - "重新分析这个" → 提供提示 → 一旦理解，                         │
│      更新 .ai-agents/context/                                     │
│    - 此反馈循环提升上下文质量                                       │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## 类比：传统团队 vs AI 代理团队

```
              传统开发团队               AI 代理团队
              ────────────────────       ──────────────────
 领导         PM（人类）                 根目录 AGENTS.md（PM 代理）
 成员         N 个开发者                各目录中的 AGENTS.md
 入职文档     Confluence/Notion         .ai-agents/context/
 操作手册     团队 wiki                 .ai-agents/skills/
 角色定义     职位/职责文档              .ai-agents/roles/
 团队规则     团队规范文档               全局规范（继承）
 上班         到达办公室                 会话开始 → AGENTS.md 加载
 下班         离开（记忆保留）            会话结束（记忆丢失！）
 第二天       记忆完好                   .ai-agents/context/ 加载（记忆恢复）
```

**关键区别：** 人类下班后记忆仍在，但 AI 每次都会遗忘一切。
这就是 `.ai-agents/context/` 存在的意义 — 它充当 AI 的**长期记忆**。

---

## 采用清单

```
阶段 1（基础）                 阶段 2（上下文）                阶段 3（运营）
────────────────               ─────────────────              ────────────────────
☐ 生成 AGENTS.md              ☐ 创建 .ai-agents/context/     ☐ 定义 .ai-agents/roles/
☐ 记录构建/测试命令            ☐ domain-overview.md           ☐ 运行多代理会话
☐ 记录规范与规则              ☐ api-spec.json (DSL)          ☐ .ai-agents/skills/ 工作流
☐ 全局规范                    ☐ data-model.md                ☐ 迭代反馈循环
☐ 厂商引导                    ☐ 设置维护规则
```

---

## 交付物

| 文件 | 受众 | 用途 |
|---|---|---|
| `HOW_TO_AGENTS.md` | AI | 代理读取并执行的元指令手册 |
| `README.md` | 人类 | 本文档 — 供人类理解的指南 |
| `ai-agency.sh` | 人类 | 代理选择 → AI 会话启动器 |
| `AGENTS.md`（各目录） | AI | 各目录的代理身份 + 规则 |
| `.ai-agents/context/*.md/json` | AI | 预先组织的领域知识 |
| `.ai-agents/skills/*/SKILL.md` | AI | 标准化工作流 |
| `.ai-agents/roles/*.md` | AI/人类 | 各角色的上下文加载策略 |

---

## 参考资料

- [Kurly OMS 团队 AI 工作流](https://helloworld.kurly.com/blog/oms-claude-ai-workflow/) — 本系统上下文设计的灵感来源
- [AGENTS.md 标准](https://agents.md/) — 厂商中立的代理指令标准
- [苏黎世联邦理工学院研究](https://www.infoq.com/news/2026/03/agents-context-file-value-review/) — "只记录不可推断的内容"

---

## 许可证

MIT

---

<p align="center">
  <sub>将 AI 代理理解项目所需的时间减少到零。</sub>
</p>
