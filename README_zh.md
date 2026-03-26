🌐 [English](README.md) | [한국어](README_ko.md) | [日本語](README_ja.md) | [中文](README_zh.md) | [Español](README_es.md) | [Français](README_fr.md) | [Deutsch](README_de.md) | [Русский](README_ru.md) | [हिन्दी](README_hi.md) | [العربية](README_ar.md)

# ai-initializer

**AI 编程工具的自动项目上下文生成器**

> 扫描您的项目目录并自动生成
> `AGENTS.md` + 知识/技能/角色上下文，让 AI 代理能够立即开始工作。

```
一条命令 → 项目分析 → AGENTS.md 生成 → 适用于任何 AI 工具
```

---

## 使用方法

> **Token 用量提示** — 初始设置时，顶级模型会分析整个项目并生成多个文件（AGENTS.md、.ai-agents/context/、.ai-agents/skills/、.ai-agents/roles/）。根据项目规模，可能消耗数万个 token。这是一次性成本；后续会话加载预构建的上下文并立即启动。

```bash
# 1. 让 AI 读取 HOW_TO_AGENTS.md，其余工作由它完成

# 选项 A：英文（推荐 — 更低的 token 成本，最佳 AI 性能）
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Read HOW_TO_AGENTS.md and generate AGENTS.md tailored to this project"

# 选项 B：用户语言（如果您打算手动编辑 AGENTS.md，推荐此选项）
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "HOW_TO_AGENTS.md를 읽고 이 프로젝트에 맞게 AGENTS.md를 생성하라"

# 推荐：--model claude-opus-4-6（或更新版本）以获得最佳效果
# 推荐：--dangerously-skip-permissions 以实现不间断的自主执行

# 2. 使用生成的代理开始工作
./ai-agency.sh
```

---

## 为什么需要它？

AI 编程工具**每次会话都从头重新学习项目**。

| 问题 | 后果 |
|---|---|
| 不了解团队规范 | 代码风格不一致 |
| 不了解完整的 API 映射 | 每次都探索整个代码库（成本 +20%） |
| 不了解禁止操作 | 直接访问生产数据库等高风险操作 |
| 不了解服务依赖 | 遗漏副作用 |

**ai-initializer** 解决了这个问题 — 生成一次，任何 AI 工具都能立即理解您的项目。

---

## 核心原则

> ETH Zurich (2026.03)：**包含可推断的内容会降低成功率并增加 +20% 的成本**

```
包含（不可推断）               .ai-agents/context/（推断成本高）      排除（推断成本低）
───────────────────────        ────────────────────────────────────      ────────────────────────
团队规范                       完整 API 映射                           目录结构
禁止操作                       数据模型关系                            单个文件内容
PR/提交格式                    事件发布/订阅规范                       官方框架文档
隐式依赖                       基础设施拓扑                            导入关系
```

---

## 生成的结构

```
project-root/
├── AGENTS.md                          # PM 代理（整体编排）
├── .ai-agents/
│   ├── context/                       # 知识文件（会话启动时加载）
│   │   ├── domain-overview.md         #   业务领域、策略、约束
│   │   ├── data-model.md              #   实体定义、关系、状态转换
│   │   ├── api-spec.json              #   API 映射（JSON DSL，节省 3 倍 token）
│   │   ├── event-spec.json            #   Kafka/MQ 事件规范
│   │   ├── infra-spec.md              #   Helm charts、网络、部署顺序
│   │   └── external-integration.md    #   外部 API、认证、速率限制
│   ├── skills/                        # 行为工作流（按需加载）
│   │   ├── develop/SKILL.md           #   开发：分析 → 设计 → 实现 → 测试 → PR
│   │   ├── deploy/SKILL.md            #   部署：打标签 → 部署请求 → 验证
│   │   ├── review/SKILL.md            #   评审：基于检查清单
│   │   ├── hotfix/SKILL.md            #   紧急修复工作流
│   │   └── context-update/SKILL.md    #   上下文文件更新流程
│   └── roles/                         # 角色定义（角色特定的上下文深度）
│       ├── pm.md                      #   项目经理
│       ├── backend.md                 #   后端开发者
│       ├── frontend.md                #   前端开发者
│       ├── sre.md                     #   SRE / 基础设施
│       └── reviewer.md                #   代码评审员
│
├── apps/
│   ├── api/AGENTS.md                  # 每个服务的代理
│   └── web/AGENTS.md
└── infra/
    └── helm/AGENTS.md
```

---

## 工作原理

### 步骤 1：项目扫描与分类

探索目录深度最多 3 层，并根据文件模式自动分类。

```
deployment.yaml + service.yaml  →  k8s-workload
values.yaml (Helm)              →  infra-component
package.json + *.tsx            →  frontend
go.mod                          →  backend-go
Dockerfile + CI config          →  cicd
...自动检测 19 种类型
```

### 步骤 2：上下文生成

根据检测到的类型，通过**实际分析代码**生成 `.ai-agents/context/` 知识文件。

```
检测到后端服务
  → 扫描路由/控制器 → 生成 api-spec.json
  → 扫描实体/模式   → 生成 data-model.md
  → 扫描 Kafka 配置 → 生成 event-spec.json
```

### 步骤 3：AGENTS.md 生成

使用适当的模板为每个目录生成 AGENTS.md。

```
根目录 AGENTS.md（全局规范）
  → 提交：Conventional Commits
  → PR：需要模板，至少 1 个审批
  → 分支：feature/{ticket}-{desc}
       │
       ▼ 自动继承（不在子级中重复）
  apps/api/AGENTS.md
    → 仅覆盖："此服务使用 Python"
```

### 步骤 4：供应商特定引导

为供应商特定配置添加桥接，使**所有 AI 工具都能读取**生成的 AGENTS.md。

```
┌──────────────┐     ┌─────────────┐     ┌─────────────┐
│ Claude Code  │     │   Cursor    │     │   Codex     │
│  CLAUDE.md   │     │  .mdc rules │     │  AGENTS.md  │
│      ↓       │     │      ↓      │     │  (原生)     │
│ "read        │     │ "read       │     │      ✓      │
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

> **原则：** 引导文件仅为已在使用的供应商生成。永远不会为未使用的工具创建配置文件。

---

## 供应商兼容性

| 工具 | 自动读取 AGENTS.md | 引导方式 |
|---|---|---|
| **OpenAI Codex** | 是（原生） | 不需要 |
| **Claude Code** | 部分（回退） | 在 `CLAUDE.md` 中添加指令 |
| **Cursor** | 否 | 在 `.cursor/rules/` 中添加 `.mdc` |
| **GitHub Copilot** | 否 | 生成 `.github/copilot-instructions.md` |
| **Windsurf** | 否 | 在 `.windsurfrules` 中添加指令 |
| **Aider** | 是 | 在 `.aider.conf.yml` 中添加读取配置 |

自动生成引导文件：
```bash
bash scripts/sync-ai-rules.sh
```

---

## 层级代理结构

```
┌───────────────────────────────────────┐
│  根 PM 代理 (AGENTS.md)               │
│  全局规范 + 委派规则                    │
│  "设计验证 > 代码验证"                  │
└────────┬──────────┬─────────┬────────┘
         │          │         │
    ┌────▼────┐ ┌───▼────┐ ┌──▼─────┐
    │ 服务   │ │ 基础   │ │  文档  │
    │ 专家   │ │ 设施   │ │ 规划师 │
    │        │ │  SRE   │ │       │
    └─────────┘ └────────┘ └────────┘

委派：父级 → 子级（在该目录的 AGENTS.md 范围内运行）
报告：子级 → 父级（任务完成后的变更摘要）
协调：没有直接的对等通信 — 通过父级间接协调
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
  3. 检查 .ai-agents/context/current-work.md（进行中的工作）
  4. git log --oneline -10（了解最近的变更）

会话结束：
  1. 进行中的工作 → 记录到 current-work.md
  2. 新学到的领域知识 → 更新上下文文件
  3. 未完成的 TODO → 明确记录
```

---

## 上下文维护

当代码变更时，`.ai-agents/context/` 文件必须相应更新。

```
API 新增/变更/删除          →  更新 api-spec.json
数据库模式变更              →  更新 data-model.md
事件规范变更                →  更新 event-spec.json
业务策略变更                →  更新 domain-overview.md
外部集成变更                →  更新 external-integration.md
基础设施配置变更            →  更新 infra-spec.md
```

> 未及时更新意味着下一次会话将**使用过时的上下文**。

---

## 采用清单

```
阶段 1（基础）                阶段 2（上下文）                  阶段 3（运营）
────────────────               ─────────────────                ────────────────────
☐ 生成 AGENTS.md              ☐ 创建 .ai-agents/context/       ☐ 定义 .ai-agents/roles/
☐ 记录构建/测试命令           ☐ domain-overview.md              ☐ 运行多代理会话
☐ 记录规范和规则              ☐ api-spec.json (DSL)             ☐ .ai-agents/skills/ 工作流
☐ 全局规范                    ☐ data-model.md                   ☐ 迭代反馈循环
☐ 供应商引导                  ☐ 设置维护规则
```

---

## 许可证

MIT

---

<p align="center">
  <sub>将 AI 代理理解您项目所需的时间缩短为零。</sub>
</p>
