# AI Agent Management System — A Guide for Humans

## How to Get Started?

> **Warning: High Token Usage** — Initial setup uses a top-tier model to analyze the entire project and generate multiple files (AGENTS.md, .ai-agents/context/, .ai-agents/skills/, .ai-agents/roles/). Expect significant token consumption (tens of thousands or more depending on project size). This is a one-time cost — subsequent sessions load pre-built context and start instantly.

```bash
# 1. Have the AI read HOW_TO_AGENTS.md and it will configure everything automatically

# Option A: English (recommended — lower token cost, best AI performance)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Read HOW_TO_AGENTS.md and generate AGENTS.md tailored to this project"

# Option B: Your language (recommended if humans edit AGENTS.md directly)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Read HOW_TO_AGENTS.md and generate AGENTS.md tailored to this project (in Korean)"

# Recommended: --dangerously-skip-permissions for uninterrupted autonomous setup
# Recommended: --model claude-opus-4-6 (or later) for best results

# 2. Start working with the generated agents
./ai-agency.sh

# 3. From the next session onward, work can begin immediately!
```

> This document is **intended for humans to read and understand**.
> It explains why the AI instruction manual (HOW_TO_AGENTS.md) exists, how it works,
> and what role it plays in your development workflow.

---

## Why Is This System Needed?

### Problem: AI Loses Its Memory Every Time

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

AI agents forget everything when a session ends.
Every time, they spend time understanding the project structure, analyzing APIs, and learning conventions.

### Solution: Pre-build a "Brain" for the AI

```
 Session Start
┌──────────────────────────────────────────────────┐
│                                                  │
│  Reads AGENTS.md (automatic)                     │
│       │                                          │
│       ▼                                          │
│  "I am the backend expert for doppel-api"        │
│  "Conventions: Conventional Commits, TypeScript   │
│   strict"                                        │
│  "Prohibited: modifying other services,          │
│   hardcoding secrets"                            │
│       │                                          │
│       ▼                                          │
│  Loads .ai-agents/context/ files (5 seconds)            │
│  "20 APIs, 15 entities, 8 events understood"     │
│       │                                          │
│       ▼                                          │
│  Starts working immediately!                     │
│                                                  │
└──────────────────────────────────────────────────┘
```

---

## Core Principle: 3-Layer Architecture

```
                    Your Project
                         │
            ┌────────────┼────────────┐
            ▼            ▼            ▼

     ┌──────────┐  ┌──────────┐  ┌──────────┐
     │ AGENTS.md│  │.ai-agents/context│  │.ai-agents/skills│
     │          │  │          │  │          │
     │ Identity │  │ Knowledge│  │ Behavior │
     │ "Who     │  │ "This    │  │ "When    │
     │  am I?"  │  │  service's│  │  developing│
     │          │  │  APIs are │  │  do it   │
     │ + Rules  │  │  like    │  │  this    │
     │ + Perms  │  │  this"   │  │  way"    │
     │ + Paths  │  │          │  │          │
     │          │  │ + Domain │  │ + Deploy │
     │          │  │ + Models │  │ + Review │
     └──────────┘  └──────────┘  └──────────┘
      Entry Point   Memory Store  Workflow Standards
```

### 1. AGENTS.md — "Who Am I?"

This is the **identity file** for the agent deployed in each directory.

```
project/
├── AGENTS.md                  ← PM: The leader who coordinates everything
├── apps/
│   └── doppel-api/
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

**Analogy:** It's like onboarding documentation given to a new employee.
Once you document "what our team does, what the DB structure looks like, what APIs exist,"
you don't have to explain it every time.

### 3. `.ai-agents/skills/` — "How Do I Work?"

These are **standardized workflow manuals** for repetitive tasks.

```
.ai-agents/skills/
├── develop/SKILL.md       ← "Feature dev: Analyze → Design → Implement → Test → PR"
├── deploy/SKILL.md        ← "Deploy: Tag → Request → Verify"
└── review/SKILL.md        ← "Review: Security, Performance, Test checklist"
```

**Analogy:** It's the team's operations manual.
It makes the AI follow rules like "check this checklist before submitting a PR."

---

## How Are Global Rules Managed?

An **inheritance pattern** is used. Write in one place, and it automatically applies downstream.

```
Root AGENTS.md ──────────────────────────────────────────
│ Global Conventions:
│  - Commits: Conventional Commits (feat:, fix:, chore:)
│  - PR: Template required, at least 1 reviewer
│  - Branch: feature/{ticket}-{desc}
│  - Code: TypeScript strict, single quotes
│
│     Auto-inherited                Auto-inherited
│     ┌──────────────────┐       ┌──────────────────┐
│     ▼                  │       ▼                  │
│  apps/api/AGENTS.md    │    infra/AGENTS.md       │
│  (Only additional      │    (Only additional      │
│   rules specified)     │     rules specified)     │
│  "This service uses    │    "When changing Helm   │
│   Python"              │     values, Ask First"   │
│     (instead of        │                          │
│      TypeScript)       │                          │
└─────────────────────────┴──────────────────────────
```

**Benefits:**
- Want to change commit rules? → Modify only the root
- Adding a new service? → Global rules apply automatically
- Need different rules for a specific service? → Override in that service's AGENTS.md

---

## What Should You Write, and What Shouldn't You?

According to ETH Zurich research (2026), writing things in documentation that the AI can already infer
actually **decreases success rates and increases costs by 20%**.

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

**However, there are exceptions:** "Things that can be inferred but are too expensive to do every time"

```
  e.g.: Full API list (need to read 20 files to figure out)
  e.g.: Data model relationships (scattered across 10 files)
  e.g.: Inter-service call relationships (need to check both code + infra)

  → Pre-organize these in .ai-agents/context/!
  → In AGENTS.md, only write the path: "go here to find it"
```

---

## Session Launcher Script

Once all agents are set up, you can pick the desired agent and start a session right away.

```bash
$ ./ai-agency.sh

=== AI Agent Sessions ===
Project: /Users/nhn/src/doppel-deploy
Found: 8 agent(s)

  1) [PM] doppel-deploy
     Path: ./AGENTS.md
     PM agent for this project. Understands the overall structure and delegates tasks.

  2) doppel-api
     Path: apps/dev/doppel-api/AGENTS.md
     K8s manifest management expert for the doppel-api service.

  3) monitoring
     Path: infra/monitoring/AGENTS.md
     SRE expert for the Prometheus + Grafana monitoring stack.

  ...

Select agent (number): 2

=== AI Tool ===
  1) claude
  2) codex
  3) print

Select tool: 1

→ Claude session started in the doppel-api directory
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
│  directory                       .ai-agents/context/                    │
│  (agent identity + rules         (API, model, event specs)       │
│   + permissions)                                                 │
│                                                                  │
│  Defines workflows in            Defines roles in                │
│  .ai-agents/skills/                     .ai-agents/roles/                      │
│  (development, deploy, review    (Backend, Frontend, SRE)        │
│   procedures)                                                    │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  2. Daily Use                                                    │
│                                                                  │
│  Run ./ai-agency.sh                                       │
│       │                                                          │
│       ▼                                                          │
│  Select agent (PM? Backend? SRE?)                                │
│       │                                                          │
│       ▼                                                          │
│  Select AI tool (Claude? Codex? Cursor?)                         │
│       │                                                          │
│       ▼                                                          │
│  Session starts → AGENTS.md auto-loaded → .ai-agents/context/ loaded   │
│  → Work!                                                         │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  3. Ongoing Maintenance                                          │
│                                                                  │
│  When code changes:                                              │
│    - AI automatically updates .ai-agents/context/ (specified as a rule  │
│      in AGENTS.md)                                               │
│    - Or a human instructs "This is important, record it"         │
│                                                                  │
│  When adding a new service:                                      │
│    - Run HOW_TO_AGENTS.md again → New AGENTS.md auto-generated   │
│    - Global rules automatically inherited                        │
│                                                                  │
│  When the AI makes mistakes:                                     │
│    - "Re-analyze this" → Provide hints → Once it understands,    │
│      update .ai-agents/context/                                         │
│    - This feedback loop improves context quality                 │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## Deliverables List

Files produced by this system and their purposes:

| File | Audience | Purpose |
|---|---|---|
| `HOW_TO_AGENTS.md` | AI | Meta-instruction manual that agents read and execute |
| `HOW_TO_AGENTS_PLAN.md` | Human/AI | Design plan (background on why this structure exists) |
| `README.md` | Human | This document. A guide for human understanding |
| `ai-agency.sh` | Human | Agent selection → AI session launcher |
| `AGENTS.md` (each directory) | AI | Per-directory agent identity + rules |
| `.ai-agents/context/*.md/json` | AI | Pre-organized domain knowledge |
| `.ai-agents/skills/*/SKILL.md` | AI | Standardized work workflows |
| `.ai-agents/roles/*.md` | AI/Human | Per-role context loading strategies |

---

## Key Analogy

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

## References

- [Kurly OMS Team AI Workflow](https://helloworld.kurly.com/blog/oms-claude-ai-workflow/) — Inspiration for the context design of this system
- [AGENTS.md Standard](https://agents.md/) — Vendor-neutral agent instruction standard
- [ETH Zurich Research](https://www.infoq.com/news/2026/03/agents-context-file-value-review/) — "Only document what cannot be inferred"
