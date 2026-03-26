🌐 [English](README.md) | [한국어](README_ko.md) | [日本語](README_ja.md) | [中文](README_zh.md) | [Español](README_es.md) | [Français](README_fr.md) | [Deutsch](README_de.md) | [Русский](README_ru.md) | [हिन्दी](README_hi.md) | [العربية](README_ar.md)

# ai-initializer

**Automatic project context generator for AI coding tools**

> Scans your project directory and auto-generates
> `AGENTS.md` + knowledge/skill/role context so AI agents can start working immediately.

```
One command → Project analysis → AGENTS.md generation → Works with any AI tool
```

---

## Usage

> **Token usage notice** — During initial setup, a top-tier model analyzes the entire project and generates multiple files (AGENTS.md, .ai-agents/context/, .ai-agents/skills/, .ai-agents/roles/). This may consume tens of thousands of tokens depending on project size. This is a one-time cost; subsequent sessions load the pre-built context and start instantly.

```bash
# 1. Have the AI read HOW_TO_AGENTS.md and it handles the rest

# Option A: English (recommended — lower token cost, optimal AI performance)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Read HOW_TO_AGENTS.md and generate AGENTS.md tailored to this project"

# Option B: User's language (recommended if you plan to manually edit AGENTS.md)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "HOW_TO_AGENTS.md를 읽고 이 프로젝트에 맞게 AGENTS.md를 생성하라"

# Recommended: --model claude-opus-4-6 (or later) for best results
# Recommended: --dangerously-skip-permissions for uninterrupted autonomous execution

# 2. Start working with the generated agents
./ai-agency.sh
```

---

## Why do you need this?

AI coding tools **re-learn the project from scratch** every session.

| Problem | Consequence |
|---|---|
| Doesn't know team conventions | Code style inconsistencies |
| Doesn't know the full API map | Explores entire codebase each time (cost +20%) |
| Doesn't know prohibited actions | Risky operations like direct production DB access |
| Doesn't know service dependencies | Missed side effects |

**ai-initializer** solves this — generate once, and any AI tool understands your project instantly.

---

## Core Principles

> ETH Zurich (2026.03): **Including inferable content reduces success rates and increases cost by +20%**

```
Include (non-inferable)        .ai-agents/context/ (costly inference)    Exclude (cheap inference)
───────────────────────        ────────────────────────────────────      ────────────────────────
Team conventions               Full API map                              Directory structure
Prohibited actions             Data model relationships                  Single file contents
PR/commit formats              Event pub/sub specs                       Official framework docs
Hidden dependencies            Infrastructure topology                   Import relationships
```

---

## Generated Structure

```
project-root/
├── AGENTS.md                          # PM Agent (overall orchestration)
├── .ai-agents/
│   ├── context/                       # Knowledge files (loaded at session start)
│   │   ├── domain-overview.md         #   Business domain, policies, constraints
│   │   ├── data-model.md              #   Entity definitions, relationships, state transitions
│   │   ├── api-spec.json              #   API map (JSON DSL, 3x token savings)
│   │   ├── event-spec.json            #   Kafka/MQ event specs
│   │   ├── infra-spec.md              #   Helm charts, networking, deployment order
│   │   └── external-integration.md    #   External APIs, auth, rate limits
│   ├── skills/                        # Behavioral workflows (loaded on demand)
│   │   ├── develop/SKILL.md           #   Dev: analyze → design → implement → test → PR
│   │   ├── deploy/SKILL.md            #   Deploy: tag → deploy request → verify
│   │   ├── review/SKILL.md            #   Review: checklist-based
│   │   ├── hotfix/SKILL.md            #   Emergency fix workflow
│   │   └── context-update/SKILL.md    #   Context file update procedure
│   └── roles/                         # Role definitions (role-specific context depth)
│       ├── pm.md                      #   Project Manager
│       ├── backend.md                 #   Backend Developer
│       ├── frontend.md                #   Frontend Developer
│       ├── sre.md                     #   SRE / Infrastructure
│       └── reviewer.md                #   Code Reviewer
│
├── apps/
│   ├── api/AGENTS.md                  # Per-service agents
│   └── web/AGENTS.md
└── infra/
    └── helm/AGENTS.md
```

---

## How It Works

### Step 1: Project Scan & Classification

Explores directories up to depth 3 and auto-classifies by file patterns.

```
deployment.yaml + service.yaml  →  k8s-workload
values.yaml (Helm)              →  infra-component
package.json + *.tsx            →  frontend
go.mod                          →  backend-go
Dockerfile + CI config          →  cicd
...19 types auto-detected
```

### Step 2: Context Generation

Generates `.ai-agents/context/` knowledge files by **actually analyzing the code** based on detected types.

```
Backend service detected
  → Scan routes/controllers → Generate api-spec.json
  → Scan entities/schemas   → Generate data-model.md
  → Scan Kafka config       → Generate event-spec.json
```

### Step 3: AGENTS.md Generation

Generates AGENTS.md for each directory using appropriate templates.

```
Root AGENTS.md (Global Conventions)
  → Commits: Conventional Commits
  → PR: Template required, 1+ approvals
  → Branches: feature/{ticket}-{desc}
       │
       ▼ Auto-inherited (not repeated in children)
  apps/api/AGENTS.md
    → Overrides only: "This service uses Python"
```

### Step 4: Vendor-Specific Bootstrap

Adds bridges to vendor-specific configs so **all AI tools read** the generated AGENTS.md.

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
           AGENTS.md (single source of truth)
                  │
        ┌─────────┼─────────┐
        ▼         ▼         ▼
  .ai-agents/  .ai-agents/  .ai-agents/
   context/     skills/      roles/
```

> **Principle:** Bootstrap files are only generated for vendors already in use. Config files for unused tools are never created.

---

## Vendor Compatibility

| Tool | Auto-reads AGENTS.md | Bootstrap |
|---|---|---|
| **OpenAI Codex** | Yes (native) | Not needed |
| **Claude Code** | Partial (fallback) | Adds directive to `CLAUDE.md` |
| **Cursor** | No | Adds `.mdc` to `.cursor/rules/` |
| **GitHub Copilot** | No | Generates `.github/copilot-instructions.md` |
| **Windsurf** | No | Adds directive to `.windsurfrules` |
| **Aider** | Yes | Adds read to `.aider.conf.yml` |

Auto-generate bootstraps:
```bash
bash scripts/sync-ai-rules.sh
```

---

## Hierarchical Agent Structure

```
┌───────────────────────────────────────┐
│  Root PM Agent (AGENTS.md)            │
│  Global Conventions + Delegation Rules│
│  "Design validation > Code validation"│
└────────┬──────────┬─────────┬────────┘
         │          │         │
    ┌────▼────┐ ┌───▼────┐ ┌──▼─────┐
    │ Service │ │ Infra  │ │  Docs  │
    │ Expert  │ │  SRE   │ │Planner │
    └─────────┘ └────────┘ └────────┘

Delegation: Parent → Child (operates within that directory's AGENTS.md scope)
Reporting:  Child → Parent (change summary after task completion)
Coordination: No direct peer-to-peer — indirect coordination through parent
```

---

## Token Optimization

| Format | Token Count | Notes |
|---|---|---|
| Natural language API description | ~200 tokens | |
| JSON DSL | ~70 tokens | **3x savings** |

**api-spec.json example:**
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

**AGENTS.md target:** Under **300 tokens** after substitution

---

## Session Restore Protocol

```
Session start:
  1. Read AGENTS.md (most AI tools do this automatically)
  2. Follow context file paths to load .ai-agents/context/
  3. Check .ai-agents/context/current-work.md (in-progress work)
  4. git log --oneline -10 (understand recent changes)

Session end:
  1. In-progress work → Record in current-work.md
  2. Newly learned domain knowledge → Update context files
  3. Incomplete TODOs → Record explicitly
```

---

## Context Maintenance

When code changes, `.ai-agents/context/` files must be updated accordingly.

```
API added/changed/removed     →  Update api-spec.json
DB schema changed             →  Update data-model.md
Event spec changed            →  Update event-spec.json
Business policy changed       →  Update domain-overview.md
External integration changed  →  Update external-integration.md
Infrastructure config changed →  Update infra-spec.md
```

> Failing to update means the next session will **work with stale context**.

---

## Adoption Checklist

```
Phase 1 (Basics)               Phase 2 (Context)                Phase 3 (Operations)
────────────────               ─────────────────                ────────────────────
☐ Generate AGENTS.md           ☐ Create .ai-agents/context/     ☐ Define .ai-agents/roles/
☐ Record build/test commands   ☐ domain-overview.md             ☐ Run multi-agent sessions
☐ Record conventions & rules   ☐ api-spec.json (DSL)            ☐ .ai-agents/skills/ workflows
☐ Global Conventions           ☐ data-model.md                  ☐ Iterative feedback loop
☐ Vendor bootstraps            ☐ Set up maintenance rules
```

---

## License

MIT

---

<p align="center">
  <sub>Reduce the time it takes for AI agents to understand your project to zero.</sub>
</p>
