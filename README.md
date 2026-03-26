🌐 [English](README.md) | [한국어](docs/README_ko.md) | [日本語](docs/README_ja.md) | [中文](docs/README_zh.md) | [Español](docs/README_es.md) | [Français](docs/README_fr.md) | [Deutsch](docs/README_de.md) | [Русский](docs/README_ru.md) | [हिन्दी](docs/README_hi.md) | [العربية](docs/README_ar.md)

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

## Why Do You Need This?

### The Problem: AI Loses Its Memory Every Session

```
 Session 1                  Session 2                  Session 3
┌──────────┐             ┌──────────┐             ┌──────────┐
│ AI reads  │             │ AI reads  │             │ Starting  │
│ entire    │  Session    │ entire    │  Session    │ from      │
│ codebase  │  ends       │ codebase  │  ends       │ scratch   │
│ (30 min)  │ ──────→    │ (30 min)  │ ──────→    │ again     │
│ Starts    │ Memory     │ Starts    │ Memory     │ (30 min)  │
│ working   │ lost!      │ working   │ lost!      │ Starts    │
│           │             │           │             │ working   │
└──────────┘             └──────────┘             └──────────┘
```

AI agents forget everything when a session ends. Every time, they spend time understanding the project structure, analyzing APIs, and learning conventions.

| Problem | Consequence |
|---|---|
| Doesn't know team conventions | Code style inconsistencies |
| Doesn't know the full API map | Explores entire codebase each time (cost +20%) |
| Doesn't know prohibited actions | Risky operations like direct production DB access |
| Doesn't know service dependencies | Missed side effects |

### The Solution: Pre-build a "Brain" for the AI

```
 Session Start
┌──────────────────────────────────────────────────┐
│                                                  │
│  Reads AGENTS.md (automatic)                     │
│       │                                          │
│       ▼                                          │
│  "I am the backend expert for this service"      │
│  "Conventions: Conventional Commits, TypeScript   │
│   strict"                                        │
│  "Prohibited: modifying other services,          │
│   hardcoding secrets"                            │
│       │                                          │
│       ▼                                          │
│  Loads .ai-agents/context/ files (5 seconds)     │
│  "20 APIs, 15 entities, 8 events understood"     │
│       │                                          │
│       ▼                                          │
│  Starts working immediately!                     │
│                                                  │
└──────────────────────────────────────────────────┘
```

**ai-initializer** solves this — generate once, and any AI tool understands your project instantly.

---

## Core Principle: 3-Layer Architecture

```
                    Your Project
                         │
            ┌────────────┼────────────┐
            ▼            ▼            ▼

     ┌──────────┐  ┌──────────┐  ┌──────────┐
     │ AGENTS.md│  │.ai-agents│  │.ai-agents│
     │          │  │ /context/ │  │ /skills/ │
     │ Identity │  │ Knowledge│  │ Behavior │
     │ "Who     │  │ "What    │  │ "How     │
     │  am I?"  │  │  do I    │  │  do I    │
     │          │  │  know?"  │  │  work?"  │
     │ + Rules  │  │          │  │          │
     │ + Perms  │  │ + Domain │  │ + Deploy │
     │ + Paths  │  │ + Models │  │ + Review │
     └──────────┘  └──────────┘  └──────────┘
      Entry Point   Memory Store  Workflow Standards
```

### 1. AGENTS.md — "Who Am I?"

The **identity file** for the agent deployed in each directory.

```
project/
├── AGENTS.md                  ← PM: The leader who coordinates everything
├── apps/
│   └── api/
│       └── AGENTS.md          ← API Expert: Responsible for this service only
├── infra/
│   ├── AGENTS.md              ← SRE: Manages all infrastructure
│   └── monitoring/
│       └── AGENTS.md          ← Monitoring specialist
└── configs/
    └── AGENTS.md              ← Configuration manager
```

It works just like a **team org chart**:
- The PM oversees everything and distributes tasks
- Each team member deeply understands only their area
- They don't directly handle other teams' work — they request it

### 2. `.ai-agents/context/` — "What Do I Know?"

A folder where **essential knowledge is pre-organized** so the AI doesn't have to read the code every time.

```
.ai-agents/context/
├── domain-overview.md     ← "This service handles order management..."
├── data-model.md          ← "There are Order, Payment, Delivery entities..."
├── api-spec.json          ← "POST /orders, GET /orders/{id}, ..."
└── event-spec.json        ← "Publishes the order-created event..."
```

**Analogy:** Onboarding documentation for a new employee. Document it once, and no one has to explain it again.

### 3. `.ai-agents/skills/` — "How Do I Work?"

**Standardized workflow manuals** for repetitive tasks.

```
.ai-agents/skills/
├── develop/SKILL.md       ← "Feature dev: Analyze → Design → Implement → Test → PR"
├── deploy/SKILL.md        ← "Deploy: Tag → Request → Verify"
└── review/SKILL.md        ← "Review: Security, Performance, Test checklist"
```

**Analogy:** The team's operations manual — makes the AI follow rules like "check this checklist before submitting a PR."

---

## What to Write and What Not to Write

> ETH Zurich (2026.03): **Including inferable content reduces success rates and increases cost by +20%**

```
         Write This                        Don't Write This
  ┌─────────────────────────┐     ┌─────────────────────────┐
  │                         │     │                         │
  │  "Use feat: format for  │     │  "Source code is in     │
  │   commits"              │     │   the src/ folder"      │
  │  AI cannot infer this   │     │  AI can see this with ls│
  │                         │     │                         │
  │  "No direct push to     │     │  "React is component-   │
  │   main"                 │     │   based"                │
  │  Team rule, not in code │     │  Already in official    │
  │                         │     │   docs                  │
  │  "QA team approval      │     │  "This file is 100      │
  │   required before       │     │   lines long"           │
  │   deploy"               │     │  AI can read it         │
  │  Process, not inferable │     │   directly              │
  │                         │     │                         │
  └─────────────────────────┘     └─────────────────────────┘
       Write in AGENTS.md              Do NOT write!
```

**Exception:** "Things that can be inferred but are too expensive to do every time"

```
  e.g.: Full API list (need to read 20 files to figure out)
  e.g.: Data model relationships (scattered across 10 files)
  e.g.: Inter-service call relationships (need to check both code + infra)

  → Pre-organize these in .ai-agents/context/!
  → In AGENTS.md, only write the path: "go here to find it"
```

```
Include (non-inferable)        .ai-agents/context/ (costly inference)    Exclude (cheap inference)
───────────────────────        ────────────────────────────────────      ────────────────────────
Team conventions               Full API map                              Directory structure
Prohibited actions             Data model relationships                  Single file contents
PR/commit formats              Event pub/sub specs                       Official framework docs
Hidden dependencies            Infrastructure topology                   Import relationships
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

Global rules use an **inheritance pattern** — write in one place, and it automatically applies downstream.

```
Root AGENTS.md ──────────────────────────────────────────
│ Global Conventions:
│  - Commits: Conventional Commits (feat:, fix:, chore:)
│  - PR: Template required, at least 1 reviewer
│  - Branch: feature/{ticket}-{desc}
│
│     Auto-inherited                Auto-inherited
│     ┌──────────────────┐       ┌──────────────────┐
│     ▼                  │       ▼                  │
│  apps/api/AGENTS.md    │    infra/AGENTS.md       │
│  (Only additional      │    (Only additional      │
│   rules specified)     │     rules specified)     │
│  "This service uses    │    "When changing Helm   │
│   Python"              │     values, Ask First"   │
└─────────────────────────┴──────────────────────────
```

**Benefits:**
- Want to change commit rules? → Modify only the root
- Adding a new service? → Global rules apply automatically
- Need different rules for a specific service? → Override in that service's AGENTS.md

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

## Generated Structure

```
project-root/
├── AGENTS.md                          # PM Agent (overall orchestration)
├── .ai-agents/
│   ├── context/                       # Knowledge files (loaded at session start)
│   │   ├── domain-overview.md         #   Business domain, policies, constraints
│   │   ├── data-model.md             #   Entity definitions, relationships, state transitions
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
│       └── reviewer.md               #   Code Reviewer
│
├── apps/
│   ├── api/AGENTS.md                  # Per-service agents
│   └── web/AGENTS.md
└── infra/
    └── helm/AGENTS.md
```

---

## Session Launcher

Once all agents are set up, pick the desired agent and start a session right away.

```bash
$ ./ai-agency.sh

=== AI Agent Sessions ===
Found: 8 agent(s)

  1) [PM] project-root
  2) api-service
  3) monitoring
  ...

Select agent (number): 2

=== AI Tool ===
  1) claude
  2) codex
  3) print

Select tool: 1

→ Session started in the api-service directory
→ Agent automatically loads AGENTS.md and .ai-agents/context/
→ Ready to work immediately!
```

**Parallel Execution (tmux):**

```bash
$ ./ai-agency.sh --multi

Select agents: 1,2,3   # Run PM + API + Monitoring simultaneously

→ 3 tmux sessions open
→ Different agents work independently in each pane
→ Switch panes with Ctrl+B N
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

## Overall Flow Summary

```
┌──────────────────────────────────────────────────────────────────┐
│  1. Initial Setup (one-time)                                     │
│                                                                  │
│  Have the AI read HOW_TO_AGENTS.md                               │
│       │                                                          │
│       ▼                                                          │
│  AI analyzes the project structure                               │
│       │                                                          │
│       ▼                                                          │
│  Creates AGENTS.md in each       Organizes knowledge in          │
│  directory                       .ai-agents/context/             │
│  (agent identity + rules         (API, model, event specs)       │
│   + permissions)                                                 │
│                                                                  │
│  Defines workflows in            Defines roles in                │
│  .ai-agents/skills/              .ai-agents/roles/               │
│  (development, deploy, review    (Backend, Frontend, SRE)        │
│   procedures)                                                    │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  2. Daily Use                                                    │
│                                                                  │
│  Run ./ai-agency.sh                                              │
│       │                                                          │
│       ▼                                                          │
│  Select agent (PM? Backend? SRE?)                                │
│       │                                                          │
│       ▼                                                          │
│  Select AI tool (Claude? Codex? Cursor?)                         │
│       │                                                          │
│       ▼                                                          │
│  Session starts → AGENTS.md auto-loaded → .ai-agents/context/    │
│  loaded → Work!                                                  │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  3. Ongoing Maintenance                                          │
│                                                                  │
│  When code changes:                                              │
│    - AI automatically updates .ai-agents/context/                │
│    - Or a human instructs "This is important, record it"         │
│                                                                  │
│  When adding a new service:                                      │
│    - Run HOW_TO_AGENTS.md again → New AGENTS.md auto-generated   │
│    - Global rules automatically inherited                        │
│                                                                  │
│  When the AI makes mistakes:                                     │
│    - "Re-analyze this" → Provide hints → Once it understands,    │
│      update .ai-agents/context/                                  │
│    - This feedback loop improves context quality                 │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## Analogy: Traditional Team vs AI Agent Team

```
              Traditional Dev Team       AI Agent Team
              ────────────────────       ──────────────────
 Leader       PM (human)                 Root AGENTS.md (PM agent)
 Members      N developers              AGENTS.md in each directory
 Onboarding   Confluence/Notion         .ai-agents/context/
 Manuals      Team wiki                 .ai-agents/skills/
 Role Defs    Job titles/R&R docs       .ai-agents/roles/
 Team Rules   Team convention docs      Global Conventions (inherited)
 Clock In     Arrive at office          Session starts → AGENTS.md loaded
 Clock Out    Leave (memory retained)   Session ends (memory lost!)
 Next Day     Memory intact             .ai-agents/context/ loaded (memory restored)
```

**Key difference:** Humans retain their memory after leaving work, but AI forgets everything each time.
That's why `.ai-agents/context/` exists — it serves as the AI's **long-term memory**.

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

## Deliverables

| File | Audience | Purpose |
|---|---|---|
| `HOW_TO_AGENTS.md` | AI | Meta-instruction manual that agents read and execute |
| `README.md` | Human | This document — a guide for human understanding |
| `ai-agency.sh` | Human | Agent selection → AI session launcher |
| `AGENTS.md` (each directory) | AI | Per-directory agent identity + rules |
| `.ai-agents/context/*.md/json` | AI | Pre-organized domain knowledge |
| `.ai-agents/skills/*/SKILL.md` | AI | Standardized work workflows |
| `.ai-agents/roles/*.md` | AI/Human | Per-role context loading strategies |

---

## References

- [Kurly OMS Team AI Workflow](https://helloworld.kurly.com/blog/oms-claude-ai-workflow/) — Inspiration for the context design of this system
- [AGENTS.md Standard](https://agents.md/) — Vendor-neutral agent instruction standard
- [ETH Zurich Research](https://www.infoq.com/news/2026/03/agents-context-file-value-review/) — "Only document what cannot be inferred"

---

## License

MIT

---

<p align="center">
  <sub>Reduce the time it takes for AI agents to understand your project to zero.</sub>
</p>
