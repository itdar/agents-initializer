# AGENTS.md Auto-Generation Meta Guide v2

> This document is an instruction guide that AI agents read and **execute**.
> It analyzes the project directory structure to automatically generate AGENTS.md + knowledge/skill/role contexts.
>
> **Core Principles:**
> - ETH Zurich (2026.03): Including inferable content reduces success rate and adds +20% cost
> - **Only include non-inferable content in AGENTS.md**
> - **High-inference-cost items** are organized separately in `.ai-agents/context/`; AGENTS.md only points to the path
> - All path references use relative paths. Vendor-neutral — works identically with Claude, Codex, Cursor, or any AI

---

## Part A: Execution Instructions

Execute the following 7 steps in order.

### Step 1: Directory Structure Scan

```
Explore from the top-level directory down to depth 3.
Exclude hidden directories (.git, .idea, node_modules, __pycache__, .omc, etc.).
For each directory:
  - Record the list of contained files and extension patterns
  - Record the subdirectory structure
  - If meta files such as README.md, package.json exist, read their contents
```

### Step 1.5: Existing Vendor Context Absorption

Before generating AGENTS.md, scan for existing AI tool configuration files and extract their knowledge.
This ensures that conventions, rules, and domain knowledge already captured in vendor-specific files are not lost — they are merged into the vendor-neutral AGENTS.md + `.ai-agents/context/` system.

**Scan targets (read if they exist):**

| File / Directory | Tool |
|---|---|
| `CLAUDE.md` | Claude Code |
| `.claude/settings.json` | Claude Code |
| `.cursor/rules/*.mdc` | Cursor |
| `.github/copilot-instructions.md` | GitHub Copilot |
| `.windsurfrules` | Windsurf |
| `.aider.conf.yml` | Aider |
| `AGENTS.md` (pre-existing) | Codex / manual |

**Extract and classify content from each file into:**

| Category | Merge Target | Examples |
|---|---|---|
| Conventions | Root `AGENTS.md` → Global Conventions | Commit format, branch naming, PR rules, code style |
| Permissions / Prohibitions | Root `AGENTS.md` → Global Permissions | "Never push to main", "Ask before changing DB schema" |
| Domain knowledge | `.ai-agents/context/domain-overview.md` | Business rules, service descriptions, architecture notes |
| API / technical specs | `.ai-agents/context/api-spec.json` etc. | API endpoints, data models, infra details |
| Workflow procedures | `.ai-agents/skills/` | Deploy procedures, review checklists |
| Tool-specific settings | Discard (not portable) | Model preferences, IDE keybindings, plugin configs |

**Rules:**
- Do NOT blindly copy — analyze, deduplicate, and organize into the appropriate AGENTS.md sections
- If a convention appears in multiple vendor files, keep one canonical version in Global Conventions
- If domain knowledge conflicts between files, prefer the most detailed version and mark conflicts with `<!-- VENDOR MERGE CONFLICT: {details} -->`
- Tool-specific settings (model names, IDE shortcuts, plugin configs) are NOT portable — discard them
- After AGENTS.md generation is complete, vendor files will be converted to bootstrap indexes (see Step 7)

**If no vendor files exist:** Skip this step entirely.

### Step 2: Automatic Directory Type Classification

Classify each directory's file patterns using the rules below. **The first matching rule takes priority.**
Select only a single type. However, in the Context section, files matching other types may also be analyzed to include relevant information.

| Priority | Match Criteria | Type | Agent Persona | Template |
|---|---|---|---|---|
| 1 | Files: `deployment.yaml` + `service.yaml` + `ingress.yaml` | `k8s-workload` | Service Deployment Specialist | B-2 |
| 2 | Files: `values.yaml` (Helm) | `infra-component` | SRE / Platform Engineer | B-3 |
| 3 | Files: `*-appset.yaml` or `ApplicationSet` resource | `gitops-appset` | GitOps Specialist | B-4 |
| 4 | Files: `*-app.yaml` (ArgoCD Application) | `bootstrap` | Initial Setup Specialist | B-5 |
| 5 | Files: `package.json` + (`*.tsx` \| `*.vue` \| `*.svelte`) | `frontend` | Frontend Engineer | B-6 |
| 6 | Files: `package.json` + (`*.ts` \| `*.js`) (no frontend framework) | `backend-node` | Node.js Backend Engineer | B-7 |
| 7 | Files: `go.mod` \| `go.sum` | `backend-go` | Go Backend Engineer | B-7 |
| 8 | Files: `pom.xml` \| `build.gradle` \| `build.gradle.kts` | `backend-jvm` | Java/Kotlin Backend Engineer | B-7 |
| 9 | Files: `requirements.txt` \| `pyproject.toml` \| `setup.py` | `backend-python` | Python Backend Engineer | B-7 |
| 10 | Files: `Dockerfile` + CI config (`Jenkinsfile`, `.github/workflows/`, `Makefile`) | `cicd` | CI/CD Engineer | B-11 |
| 11 | Files: `.github/workflows/` only | `github-actions` | GitHub Actions Specialist | B-11 |
| 12 | Files: `*.md` + mostly (`*.pptx` \| `*.xlsx` \| `*.pdf` \| `*.docx`) | `docs-planning` | Planner / Technical Writer | B-9 |
| 13 | Files: mostly `*.md` (technical documentation) | `docs-technical` | Technical Writer | B-9 |
| 14 | Structure: has environment-specific subdirectories (`dev/`, `staging/`, `prod/`, `real/`) | `env-config` | Environment Config Manager | B-8 |
| 15 | Content: business-related files (contracts, proposals, revenue data, etc.) | `business` | Business Analyst | B-10 |
| 16 | Content: CS/customer-related documents | `customer-support` | CS Operations Specialist | B-10 |
| 17 | Structure: directory name related to `secret/`, certificates, or keys | `secrets` | Security Specialist | B-12 |
| 18 | Structure: has only subdirectories with no direct files (grouping) | `grouping` | Area Manager | B-13 |
| 19 | (Other: no rules above match) | `generic` | General-Purpose Agent | B-14 |

**When Priority 19 applies:** Sample file contents (first 30 lines of the top 3 files) to understand context, then re-select the closest type. If still unclear, use the B-14 (generic) template.

**Empty directories:** Generate a minimal AGENTS.md containing only Role and Permissions. Leave a note: "Context refresh required when files are added."

### Step 3: Create Context Hierarchy

Before generating AGENTS.md, first build the knowledge/behavior/role context for the project.

#### 3-1. Create `.ai-agents/context/` Knowledge Files

Pre-organize **high-inference-cost information** from project analysis:

| File | Target | Content | Generation Method |
|---|---|---|---|
| `domain-overview.md` | All projects | Business domain, policies, constraints, legacy quirks | Human draft → refined via AI Q&A |
| `data-model.md` | Backend services | Entity definitions, relationships, state transitions | AI code analysis → human validation |
| `api-spec.json` | API services | Inbound/Outbound APIs, involved domains, side effects (JSON DSL) | AI code analysis → DSL conversion |
| `event-spec.json` | Event-driven | Kafka/MQ publish/subscribe message specs (JSON DSL) | AI code analysis → DSL conversion |
| `infra-spec.md` | Infrastructure/DevOps | Helm chart relationships, network topology, deployment order | Written by human |
| `external-integration.md` | External integrations | Third-party API calls, authentication, rate limits | Written by human |
| `business-metrics.md` | Business/Planning | KPIs, OKRs, success criteria, revenue model, key metrics | Written by human |
| `stakeholder-map.md` | Business/Planning | Decision makers, approval flows, RACI matrix, team structure | Written by human |
| `ops-runbook.md` | Operations/CS | Operational procedures, escalation paths, incident response, SLA | Written by human |
| `planning-roadmap.md` | Planning/Docs | Current roadmap, milestones, dependencies, timeline | Written by human |

**Generation location:**
- Single-service project: `.ai-agents/context/` at root
- MSA multi-service: `.ai-agents/context/` in each service directory
- Shared knowledge: Place in root `.ai-agents/context/` and reference from subdirectories

**Do not create files that are not applicable.** Example: if Kafka is not used, `event-spec.json` is not needed.

**Analyze the codebase and populate files with actual content on initial generation.** Do not create empty scaffolds with TODO markers. The AI must read source code, configuration files, and documentation to fill each file with real, analyzed content. For items that genuinely require human input (business policies, external API credentials, SLA details), mark only those specific sections with `<!-- HUMAN INPUT NEEDED: {reason} -->`.

**Auto-generated files by type:**

| Directory Type | Files to create in .ai-agents/context/ |
|---|---|
| `backend-*`, `frontend` | `domain-overview.md`, `data-model.md`, `api-spec.json` |
| `backend-*` + event usage | above + `event-spec.json` |
| `frontend` | above + reference path to backend `api-spec.json` |
| `infra-component`, `k8s-workload` | `infra-spec.md` |
| `business` | `domain-overview.md`, `business-metrics.md`, `stakeholder-map.md` |
| `customer-support` | `domain-overview.md`, `ops-runbook.md`, `stakeholder-map.md` |
| `docs-planning` | `domain-overview.md`, `planning-roadmap.md`, `stakeholder-map.md` |
| External API integration exists | `external-integration.md` |
| Root (PM) | `domain-overview.md`, `infra-spec.md`, `stakeholder-map.md` |

**File generation instructions:**

`domain-overview.md` generation:
- Analyze README files, code comments, and module structure to infer business purpose
- Identify business rules from validation logic, error messages, and domain models
- Mark sections that require human clarification with `<!-- HUMAN INPUT NEEDED -->`
- Example output structure:
```markdown
# {service_name} Domain Overview

## Business Purpose
{Analyzed from README, package.json description, and code structure}

## Core Policies / Constraints
{Extracted from validation rules, error handling, and business logic}
<!-- HUMAN INPUT NEEDED: Confirm business rules not visible in code -->

## Legacy Quirks
<!-- HUMAN INPUT NEEDED: Historical context not inferable from code -->
```

`api-spec.json` generation:
- Scan all route/controller/handler files to discover API endpoints
- For each endpoint: extract method, path, request/response types, involved domains
- Identify side effects (DB writes, event publishing, external calls) from the handler code
- Output must be complete and accurate — not a placeholder example

`data-model.md` generation:
- Scan entity/model/schema files to discover all entities
- Extract field names, types, and relationships (foreign keys, join tables)
- Identify state transition patterns from enum fields and status update logic
- Output a complete entity catalog with relationships

`event-spec.json` generation:
- Scan for Kafka/MQ producer and consumer configurations
- Extract topic names, event types, and payload structures
- Map publish/subscribe relationships
- Output must reflect actual event specs found in code

`infra-spec.md` generation:
- Analyze Helm charts, deployment manifests, and infrastructure configuration
- Map component dependencies and deployment order
- Document network topology from service/ingress definitions
- Mark operational details that require human confirmation with `<!-- HUMAN INPUT NEEDED -->`

`external-integration.md` generation:
- Scan for HTTP client calls, SDK integrations, and external API references
- Extract service names, endpoints, and authentication methods from code
- Mark rate limits and SLA details as `<!-- HUMAN INPUT NEEDED: Rate limit/SLA details -->`

`business-metrics.md` generation:
- Scan for analytics/tracking code, dashboard configs, or metric definitions
- Extract KPI names, measurement methods, and target values if defined in code/config
- Mark business-specific metrics as `<!-- HUMAN INPUT NEEDED: Target values, OKRs -->`
- Example output structure:
```markdown
# Business Metrics

## Key Performance Indicators
<!-- HUMAN INPUT NEEDED: Define KPIs, target values, measurement frequency -->

## Revenue Model
<!-- HUMAN INPUT NEEDED: Revenue streams, pricing structure, unit economics -->

## Success Criteria
{Extracted from test assertions, monitoring alerts, or SLA configs if available}
<!-- HUMAN INPUT NEEDED: Business-level success criteria -->
```

`stakeholder-map.md` generation:
- Scan CODEOWNERS, PR review configs, and team assignment files
- Extract team structure from org-related configs if available
- Mark decision-making flows as `<!-- HUMAN INPUT NEEDED -->`
- Example output structure:
```markdown
# Stakeholder Map

## Decision Makers
<!-- HUMAN INPUT NEEDED: Who approves what (features, architecture, budget) -->

## Team Structure
{Extracted from CODEOWNERS, team configs, or directory ownership patterns}

## Approval Flows (RACI)
<!-- HUMAN INPUT NEEDED: Responsible/Accountable/Consulted/Informed matrix -->

## Communication Channels
<!-- HUMAN INPUT NEEDED: Slack channels, meeting cadence, escalation paths -->
```

`ops-runbook.md` generation:
- Scan for operational scripts, alert configs, and incident response templates
- Extract monitoring endpoints, health check paths, and alert thresholds from code
- Mark operational procedures as `<!-- HUMAN INPUT NEEDED -->`
- Example output structure:
```markdown
# Operations Runbook

## Incident Response
<!-- HUMAN INPUT NEEDED: Escalation paths, on-call rotation, severity definitions -->

## Common Issues & Resolution
{Extracted from error handling patterns, retry logic, and known-issues docs}

## SLA / SLO
<!-- HUMAN INPUT NEEDED: Service level targets, uptime commitments -->

## Operational Procedures
<!-- HUMAN INPUT NEEDED: Deployment windows, change management process -->
```

`planning-roadmap.md` generation:
- Scan for TODO files, milestone configs, project board references, or changelog
- Extract upcoming features from branch names, draft PRs, or roadmap docs
- Mark timelines as `<!-- HUMAN INPUT NEEDED -->`
- Example output structure:
```markdown
# Planning Roadmap

## Current Milestones
<!-- HUMAN INPUT NEEDED: Active milestones, target dates, owners -->

## Upcoming Features
{Extracted from TODO files, open PRs, or feature branches}

## Dependencies
<!-- HUMAN INPUT NEEDED: Cross-team dependencies, external blockers -->

## Decision Log
<!-- HUMAN INPUT NEEDED: Key architectural/business decisions and rationale -->
```

#### 3-2. Create `.ai-agents/skills/` Behavioral Workflows

Standardize recurring task patterns. **Create the directory and generate skill files with project-specific content.**

```
.ai-agents/skills/
├── develop/SKILL.md       # Development: analyze → design → implement → test → PR
├── deploy/SKILL.md        # Deployment: tag → deployment request → validation
├── review/SKILL.md        # Review: checklist-based code review
├── hotfix/SKILL.md        # Emergency fix workflow
└── context-update/SKILL.md # .ai-agents/context/ update procedure
```

**develop/SKILL.md** example (must be customized per project):
```markdown
# Skill: Development Workflow

## Trigger
When a new feature implementation or bug fix is requested

## Steps
1. Analyze requirements — refer to .ai-agents/context/domain-overview.md
2. Identify impact scope — refer to .ai-agents/context/api-spec.json, data-model.md
3. Design (if needed)
4. Implement
5. Write and run tests
6. Create PR — follow Global Conventions in root AGENTS.md

## Done Criteria
- Tests passing
- Lint passing
- PR created

## Context Dependencies
- `.ai-agents/context/domain-overview.md`
- `.ai-agents/context/api-spec.json`
```

**context-update/SKILL.md** example (must be customized per project):
```markdown
# Skill: Context Update

## Trigger
When code changes make .ai-agents/context/ files outdated

## Steps
1. Identify the changed code area
2. Identify affected .ai-agents/context/ files
3. Update those files
4. Validate: "Is this file accurate when read alone in a new session?"

## Done Criteria
- .ai-agents/context/ files match the current code
- JSON DSL files are valid parseable JSON
```

Generate files in the same format for the remaining skills (deploy, review, hotfix).

**Generation rule:** Analyze the actual project structure and customize each SKILL.md. Replace generic paths with real paths discovered during Steps 1-2. For example, if the project uses `pnpm test` instead of `npm test`, the develop skill should reference `pnpm test`.

What to include in each SKILL.md:
- **Trigger:** When to use this skill
- **Steps:** Execution order
- **Done Criteria:** Completion conditions
- **Context Deps:** .ai-agents/context/ files to reference

**Note — Why knowledge and behavior are separated:**
- Knowledge (.ai-agents/context/): Explicitly loaded at session start → token usage is predictable
- Behavior (.ai-agents/skills/): Dynamically loaded when needed → flexibility
- Mixing them makes token usage unpredictable and pollutes the context with unnecessary information

#### 3-3. Create `.ai-agents/roles/` Role Definitions

Each role requires a different context depth. **Generate role files only for types that exist in the project. Populate each role file with actual context file paths discovered during Step 3-1, not placeholder paths.**

| Role | Loading Strategy | Load Target | Creation Condition |
|---|---|---|---|
| PM | Selective deferred | Root AGENTS.md + all sub-AGENTS.md (index only) | Always |
| Backend | Full loading | Full .ai-agents/context/ for the relevant service | When backend-* type exists |
| Frontend | Full loading | Frontend .ai-agents/context/ + backend api-spec.json | When frontend type exists |
| SRE/Infra | Selective deferred | infra-spec.md + check per-service deployment as needed | When infra-component type exists |
| Business Analyst | Selective deferred | domain-overview.md + business directory documents | When business type exists |
| Planner | Selective deferred | domain-overview.md + docs-planning directory documents | When docs-planning type exists |
| CS Specialist | Selective deferred | domain-overview.md + customer-support directory documents | When customer-support type exists |
| Reviewer | Selective deferred | .ai-agents/context/ of the service under review | Always |

**pm.md** template:
```markdown
# Role: Project Manager

## Context Loading
At session start:
- Root `AGENTS.md` (understand Agent Tree)
- `.ai-agents/context/domain-overview.md`
- `.ai-agents/context/infra-spec.md` (if available)

## Responsibilities
- Understand overall architecture, distribute tasks, analyze impact
- Coordinate cross-cutting issues between sub-agents

## Constraints
- Do not directly modify code in sub-agent domains
- Design validation takes precedence over code validation
```

**backend.md** template:
```markdown
# Role: Backend Developer

## Context Loading
Must load at session start:
- `.ai-agents/context/domain-overview.md`
- `.ai-agents/context/data-model.md`
- `.ai-agents/context/api-spec.json`

Load additionally when needed:
- `.ai-agents/context/event-spec.json`
- `.ai-agents/context/external-integration.md`

## Constraints
- Do not modify frontend code
- Do not modify infrastructure configuration (request to SRE)
```

**sre.md** template:
```markdown
# Role: SRE / Infrastructure

## Context Loading
At session start:
- `.ai-agents/context/infra-spec.md`
- Root `AGENTS.md` (full service list)

Load additionally when needed:
- deployment.yaml, values.yaml for each service

## Constraints
- Do not modify service business logic
- Must Ask First before changing production configuration
```

**reviewer.md** template:
```markdown
# Role: Code Reviewer

## Context Loading
For the service under review:
- `AGENTS.md` (check conventions and permissions)
- Full `.ai-agents/context/` (domain understanding)

## Review Checklist
- Compliance with root Global Conventions
- Security: secret exposure, injection
- Performance: N+1 queries, unnecessary iteration
- Tests: coverage, edge cases
```

**business-analyst.md** template:
```markdown
# Role: Business Analyst

## Context Loading
At session start:
- Root `AGENTS.md` (understand Agent Tree)
- `.ai-agents/context/domain-overview.md`
- `.ai-agents/context/business-metrics.md` (KPIs, OKRs, revenue model)
- `.ai-agents/context/stakeholder-map.md` (decision makers, approval flows)
- Business directory documents (contracts, proposals, revenue data, etc.)

Load additionally when needed:
- `.ai-agents/context/api-spec.json` (to understand technical capabilities)
- `.ai-agents/context/data-model.md` (to understand data structure)
- `.ai-agents/context/planning-roadmap.md` (to align with timeline)

## Responsibilities
- Analyze business/planning documents and organize requirements
- Write specs to hand off to development agents
- Analyze business impact of technical changes
- Track KPIs and business metrics; flag deviations
- Coordinate with PM for cross-functional decisions

## Constraints
- Do not directly modify code (delegate to development agents)
- Do not make technical architecture decisions (delegate to SRE/Backend)
- Business document changes require stakeholder confirmation
- Pricing/contract changes require explicit stakeholder approval
```

**planner.md** template:
```markdown
# Role: Planner / Technical Writer

## Context Loading
At session start:
- Root `AGENTS.md` (understand Agent Tree)
- `.ai-agents/context/domain-overview.md`
- `.ai-agents/context/planning-roadmap.md` (milestones, timeline, dependencies)
- `.ai-agents/context/stakeholder-map.md` (approval flows, RACI)
- Planning directory documents (specs, roadmaps, architecture docs)

Load additionally when needed:
- `.ai-agents/context/api-spec.json` (to validate technical feasibility)
- `.ai-agents/context/infra-spec.md` (to understand infrastructure constraints)
- `.ai-agents/context/business-metrics.md` (to align with business goals)

## Responsibilities
- Draft and maintain project specs, roadmaps, and architecture documents
- Translate business requirements into technical specifications
- Track feature progress and update planning documents
- Maintain the planning roadmap and milestone tracking
- Bridge communication between business and development agents

## Constraints
- Do not directly modify code (delegate to development agents)
- Do not arbitrarily change approved specs (require stakeholder sign-off)
- Technical decisions must be validated by relevant development agents
- Milestone date changes must be communicated to all affected stakeholders
```

**cs-specialist.md** template:
```markdown
# Role: CS Operations Specialist

## Context Loading
At session start:
- Root `AGENTS.md` (understand Agent Tree)
- `.ai-agents/context/domain-overview.md`
- `.ai-agents/context/ops-runbook.md` (escalation paths, incident response, SLA)
- `.ai-agents/context/stakeholder-map.md` (team contacts, escalation owners)
- Customer support documents (FAQ, issue logs, SLA docs)

Load additionally when needed:
- `.ai-agents/context/api-spec.json` (to understand service behavior for issue diagnosis)
- `.ai-agents/context/external-integration.md` (to understand third-party dependencies)
- `.ai-agents/context/business-metrics.md` (to understand customer impact on KPIs)

## Responsibilities
- Analyze customer issues and identify patterns
- Coordinate with development agents for bug reports and feature requests
- Maintain CS documentation (FAQ, runbooks, escalation procedures)
- Follow and update operational runbooks for incident response
- Assess customer impact of technical changes

## Constraints
- Do not directly modify code (report issues to development agents)
- Do not send personal information externally
- Do not arbitrarily change SLA terms or contracts
```

### Step 4: Generate AGENTS.md

Use the Part B templates for each classified directory.

**Placeholder rules:** All placeholders use `{snake_case_english}`. Refer to `<!-- extraction instructions -->` comments.

**Generation rules:**
1. Replace all `{placeholder}` with actual values. Remove comments from final output.
2. Fill in context by analyzing files.
3. **Do not write inferable content** — prohibited:
    - Directory structure descriptions, general language syntax, README contents, package official docs
4. **Only write non-inferable content:**
    - Team conventions, prohibitions, protection rules, custom commands, hidden dependencies, PR/commit formats
5. **Record context file paths generated in Step 3 in the `Context Files` section.**
6. Omit sections that are not applicable.

**Global rule inheritance:** `Global Conventions` in root AGENTS.md automatically applies to all sub-agents. Sub-AGENTS.md should not repeat inherited rules — only record overrides.

```
Inheritance flow:
Root AGENTS.md (Global Conventions)
  → Commits: Conventional Commits
  → PR: template required
  → Review: minimum 1 approve
  → Language: TypeScript strict
       │
       ▼ Auto-inherited (sub-agents do not repeat)
  apps/api/AGENTS.md
    → Override only: "This service uses Python" (only language rule overridden)
```

### Step 5: Generate Root PM Agent

After generating all sub-AGENTS.md, generate the top-level `AGENTS.md` last.

**Required elements in root AGENTS.md:**
1. Project Identity (PM orchestrator)
2. Sub-agent tree
3. Delegation rules
4. **Global Conventions** (commits, PR, review, branch, coding style, etc.)
5. **Global Permissions** (global prohibitions)
6. **Context Files** (root `.ai-agents/context/` path index)
7. Protocol for cross-cutting changes

### Step 6: Set Up Context Maintenance Rules

Include a `Context Maintenance` section in each AGENTS.md so that `.ai-agents/context/` files are automatically kept up to date when code changes.

```
Maintenance triggers:
─────────────────────
API added/changed/deleted    → update api-spec.json
DB schema changed            → update data-model.md
Event spec changed           → update event-spec.json
Business policy changed      → update domain-overview.md
External integration changed → update external-integration.md
Infrastructure config changed → update infra-spec.md
KPI/OKR targets changed     → update business-metrics.md
Team structure changed       → update stakeholder-map.md
Operational procedure changed → update ops-runbook.md
Milestone/roadmap changed    → update planning-roadmap.md
```

### Step 7: Convert Vendor Files to Bootstrap Indexes

If Step 1.5 absorbed content from existing vendor files, those files now contain knowledge that has been merged into AGENTS.md + `.ai-agents/context/`. Replace the absorbed content with a lightweight bootstrap index that points to AGENTS.md.

**For each vendor file that was absorbed:**

1. **Back up** the original content as a comment or in a separate `.bak` file (so nothing is lost)
2. **Replace** the file contents with the bootstrap directive only
3. **Preserve** any tool-specific settings that are NOT portable (they stay in the vendor file)

**Example — CLAUDE.md transformation:**

Before (absorbed):
```markdown
# Project Guidelines
## Conventions
- Use Conventional Commits (feat:, fix:, chore:)
- Never push directly to main
## Domain
- This is an order management service...
## Code Style
- TypeScript strict mode
- ESLint + Prettier
```

After (bootstrap index):
```markdown
## Session Start
At the start of every session, read `AGENTS.md` (project root) and follow its instructions.
If `.ai-agents/context/` exists, load the files listed in the Context Files section of AGENTS.md.

<!-- Original content absorbed into AGENTS.md + .ai-agents/context/ -->
<!-- Backup: CLAUDE.md.pre-agents.bak -->
```

**Rules:**
- Only convert files whose content was actually absorbed in Step 1.5
- If a vendor file has NO useful content to absorb (e.g., only tool-specific settings), leave it unchanged and only append the bootstrap directive
- Create `.bak` files in the project root with the pattern `{filename}.pre-agents.bak`
- Add `.pre-agents.bak` entries to `.gitignore` if it exists (backups are local-only)

**If Step 1.5 was skipped (no vendor files existed):** Skip this step. Vendor bootstraps will be generated fresh by the bootstrap generator in Part D.

---

## Part B: Template Library

### B-1. Root PM Agent

```markdown
# {project_name} <!-- from README or directory name -->

## Role
PM agent for this project. Understands the overall structure and delegates tasks to sub-agents.

## Agent Tree
{agent_tree} <!-- tree of generated sub-AGENTS.md -->

## Context Files
- Domain: `.ai-agents/context/domain-overview.md`
- Infra: `.ai-agents/context/infra-spec.md`
{additional_context_files} <!-- root-level context file paths -->

## Session Start
At session start, read the above Context Files and Agent Tree to understand the full project.

## Delegation
- Single directory scope → refer to that directory's AGENTS.md
- Multiple directories → identify impact scope, then distribute to each agent
- Infrastructure changes → sub-agents under `infra/`
- Service changes → sub-agents under `apps/` or `services/`

## Global Conventions
{global_conventions}
<!-- Record project-wide rules here. All sub-agents automatically inherit. Example: -->
<!-- - Commits: Conventional Commits (feat:, fix:, chore:) -->
<!-- - PR: template required, minimum 1 reviewer -->
<!-- - Branch: feature/{ticket}-{desc}, hotfix/{desc} -->
<!-- - Language: TypeScript strict, single quotes -->

## Global Permissions
- Never: {global_never}
- Ask First: {global_ask_first}

## Context Maintenance
When code changes, always update the affected `.ai-agents/context/` files.
Failing to update will cause the next session to work with stale context.
```

### B-2. K8s Workload

```markdown
# {service_name} <!-- directory name -->

## Role
K8s manifest management specialist for the {service_name} service.

## Context Files
{context_file_paths} <!-- .ai-agents/context/ file paths for this service. Omit section if none -->

## Session Start
Read the above Context Files and follow the Global Conventions in root AGENTS.md.

## Context
- Image: {container_image} <!-- deployment.yaml → spec.containers[].image -->
- Port: {service_port} <!-- service.yaml → spec.ports[].port -->
- Host: {ingress_host} <!-- ingress.yaml → spec.rules[].host -->

## Conventions
- Image tag format: {image_tag_pattern}

## Permissions
- Always: read manifests, analyze configuration
- Ask First: change image tag, modify resource limits/requests
- Never: modify other service directories, hardcode secret values

## Context Maintenance
Update relevant `.ai-agents/context/` files when image tags, environment variables, or resource settings change.
```

### B-3. Infrastructure Component (Helm)

```markdown
# {component_name} <!-- directory name -->

## Role
SRE specialist for the {component_name} infrastructure component.
Manages {component_purpose} based on Helm charts.

## Context Files
{context_file_paths} <!-- .ai-agents/context/infra-spec.md, etc. -->

## Session Start
Read the above Context Files and follow the Global Conventions in root AGENTS.md.

## Context
- Chart: {chart_info} <!-- extracted from values.yaml or parent appset -->
- Namespace: {namespace}
- Key Config: {custom_config} <!-- only non-inferable custom settings -->

## Dependencies
{infra_dependencies}

## Permissions
- Always: read values.yaml, analyze configuration
- Ask First: modify values.yaml, add new resources
- Never: directly modify CRDs, delete namespaces, directly change production configuration

## Context Maintenance
Update `.ai-agents/context/infra-spec.md` when values.yaml changes.
```

### B-4. GitOps ApplicationSet

```markdown
# {appset_name} <!-- filename -->

## Role
ArgoCD ApplicationSet management specialist. Manages multi-cluster/multi-environment deployment combinations.

## Context
- Generator: {generator_type} <!-- analyzed from generators -->
- Template: {template_summary}
- Sync Policy: {sync_policy}

## Permissions
- Always: read AppSet YAML
- Ask First: change generator matrix, change sync policy
- Never: delete production AppSet
```

### B-5. Bootstrap

```markdown
# Bootstrap

## Role
Cluster initial setup specialist. Manages ArgoCD self-management and initial Application registration.

## Context
- Bootstrap Apps: {bootstrap_apps}
- Execution Order: {boot_order}

## Permissions
- Always: read bootstrap YAML
- Ask First: add new app, modify existing app
- Never: delete bootstrap apps (affects entire cluster)
```

### B-6. Frontend Service

```markdown
# {service_name} <!-- directory name or package.json name -->

## Role
{service_name} frontend engineer.

## Context Files
{context_file_paths}
<!-- frontend .ai-agents/context/ + backend api-spec.json (for API integration understanding) -->

## Session Start
Read the above Context Files and follow the Global Conventions in root AGENTS.md.

## Commands
- Install: `{install_command}`
- Dev: `{dev_command}`
- Build: `{build_command}`
- Test: `{test_command}`

## Conventions
{frontend_conventions} <!-- component naming, state management, styling approach, etc. -->

## Permissions
- Always: read/modify frontend code
- Ask First: add/remove dependencies, change build configuration
- Never: modify backend code, commit .env

## Context Maintenance
Update `.ai-agents/context/api-spec.json` when API integrations change. Update related documentation for large-scale component structure changes.
```

### B-7. Backend Service

```markdown
# {service_name} <!-- directory name or module name -->

## Role
{service_name} backend engineer. ({language})

## Context Files
- Domain: `.ai-agents/context/domain-overview.md`
- Data Model: `.ai-agents/context/data-model.md`
- API Spec: `.ai-agents/context/api-spec.json`
{additional_context} <!-- event-spec.json, external-integration.md, etc. if applicable -->

## Session Start
Read all of the above Context Files and follow the Global Conventions in root AGENTS.md.

## Commands
- Build: `{build_command}`
- Test: `{test_command}`
- Run: `{run_command}`

## Conventions
{coding_conventions}

## Permissions
- Always: read/modify this service's code, run tests
- Ask First: change DB schema, add external API integration
- Never: modify other service code, directly access production DB, hardcode secrets

## Context Maintenance
- API added/changed/deleted → update `api-spec.json`
- DB schema changed → update `data-model.md`
- Event spec changed → update `event-spec.json`
- Domain policy changed → update `domain-overview.md`
```

### B-8 ~ B-14. (Concise Versions)

The remaining templates follow the same pattern as B-1~B-7. Only key differences are noted:

**B-8. Environment Config** — Role: Environment-specific configuration manager. Context: env list, config format. Never: directly change prod.

**B-9. Docs/Planning** — Role: Planner/Technical Writer.
```markdown
# {directory_name} Agent

## Role
Planner / Technical Writer — manages project specifications, roadmaps, and documentation.

## Context Files
- `.ai-agents/context/domain-overview.md`
- `.ai-agents/context/planning-roadmap.md`
- `.ai-agents/context/stakeholder-map.md`

## Session Start
1. Read this AGENTS.md
2. Load context files listed above
3. Review recent document changes: `git log --oneline -10 -- {directory}/`

## Permissions
- Always: read/update docs and planning documents, create new specs
- Ask First: change approved specifications, modify milestone dates
- Never: directly modify code, arbitrarily change approved specs without stakeholder sign-off

## Context Maintenance
- Milestone changed → update `planning-roadmap.md`
- Team structure changed → update `stakeholder-map.md`
- Business policy changed → update `domain-overview.md`
```

**B-10. Business/CS** — Role: Business Analyst / CS Operations Specialist.
```markdown
# {directory_name} Agent

## Role
Business Analyst / CS Operations Specialist — manages business documents, customer support operations, and cross-functional coordination.

## Context Files
- `.ai-agents/context/domain-overview.md`
- `.ai-agents/context/business-metrics.md`
- `.ai-agents/context/stakeholder-map.md`
- `.ai-agents/context/ops-runbook.md` (CS only)

## Session Start
1. Read this AGENTS.md
2. Load context files listed above
3. Review recent business document changes: `git log --oneline -10 -- {directory}/`

## Permissions
- Always: read/update business documents, analyze data, draft reports
- Ask First: change contracts or SLAs, modify operational procedures
- Never: directly modify code, arbitrarily change contracts, send personal information externally, make unilateral pricing decisions

## Context Maintenance
- KPI targets changed → update `business-metrics.md`
- Stakeholder or approval flow changed → update `stakeholder-map.md`
- Operational procedure changed → update `ops-runbook.md`
- Business policy changed → update `domain-overview.md`
```

**B-11. CI/CD** — Role: CI/CD Engineer. Context: CI tool, pipeline list. Never: delete production pipelines.

**B-12. Security/Secrets** — Role: Security Specialist. Never: write secrets in plain text, commit to Git, output to logs.

**B-13. Grouping Directory** — Role: Area Manager. Sub-agent list + delegation rules. Never: directly modify sub-domains.

**B-14. Generic** — Role: Inferred from file sampling. At minimum, record only Permissions.

**Common pattern:** All templates include `Context Files`, `Session Start`, and `Context Maintenance` sections. Omit if not applicable.

---

## Part C: Context Design Guide

### C-1. `.ai-agents/context/` Knowledge File Design

**Principle:** Instead of reading the entire codebase every session, work immediately with pre-organized knowledge.

**Criteria for what to include:**

| Category | Location | Example |
|---|---|---|
| Non-inferable | AGENTS.md | Conventions, prohibitions, hidden dependencies |
| Inferable + high cost | `.ai-agents/context/` | Full API map, data model relationships, event specs |
| Inferable + low cost | Do not include | Directory structure, single file contents, framework docs |

**AI-Assisted Generation Protocol**

```
Step 1: Request AI to analyze the code
   "Analyze all APIs in the current {service_name}"

Step 2: Request DSL structure proposal
   "Propose a DSL structure to remember the analyzed APIs in a new session"

Step 3: Iterative feedback
   - If wrong: "Hint — look again at {related_domain}"
   - If correct: "Record this in .ai-agents/context/"

Step 4: Validation
   "Assume a new session. Test whether {service_name} can be accurately described
    having only read this .ai-agents/context/ file"
```

### C-2. `.ai-agents/skills/` Behavioral Workflow Design

**SKILL.md Standard Format:**

```markdown
# Skill: {skill_name}

## Trigger
{When to use this skill}

## Steps
1. {Step 1}
2. {Step 2}
...

## Done Criteria
- {Completion condition 1}
- {Completion condition 2}

## Context Dependencies
- `.ai-agents/context/{file}` — {why it is needed}
```

**Recommended skill list:**

| Skill | Trigger | Key Steps |
|---|---|---|
| develop | "implement this feature" | analyze → design → implement → test → PR |
| deploy | "deploy" | create tag → deployment request → validation |
| review | "review" | checklist-based code review |
| hotfix | "emergency fix" | root cause analysis → minimal fix → test → emergency deploy |
| context-update | "update context" | analyze changes → refresh .ai-agents/context/ files |

### C-3. Global Rule Inheritance Pattern

**Principle:** Global rules are recorded only once in root AGENTS.md. Sub-agents auto-inherit. Only overrides are recorded.

**What to include in root AGENTS.md `Global Conventions`:**

```markdown
## Global Conventions

### Commit
- Conventional Commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`
- Include Why in body, title within 50 characters

### Branch
- feature/{ticket-id}-{description}
- hotfix/{description}
- Direct push to main is prohibited

### PR
- Template use required
- Merge after minimum 1 approve
- Use squash merge

### Code Style
- {language}: {linter/formatter configuration}
- Framework: {chosen framework}

### Review
- Check security, performance, test coverage
- AI-generated code is treated as a junior developer's suggestion and reviewed accordingly
```

**Override in sub-AGENTS.md:**

```markdown
## Conventions (Override)
<!-- Inherit root Global Conventions, but apply the following differently -->
- Language: Python 3.12 (instead of root's TypeScript)
- Formatter: black + isort
```

**Sub-AGENTS.md where no override is needed:**
```markdown
## Session Start
Follow root AGENTS.md's Global Conventions.
```

### C-4. JSON DSL Design Guide

**api-spec.json standard:**

```json
{
  "service": "{service_name}",
  "apis": [
    {
      "method": "POST",
      "path": "/api/v1/orders",
      "request": "CreateOrderRequest",
      "response": "CreateOrderResponse",
      "domains": ["Order", "Payment"],
      "sideEffects": ["kafka:order-created", "db:orders.insert"],
      "externalCalls": [
        {"service": "payment-api", "endpoint": "POST /api/v1/payments"}
      ]
    }
  ]
}
```

**event-spec.json standard:**

```json
{
  "service": "{service_name}",
  "publish": [
    {"topic": "order-events", "event": "OrderCreated", "payload": "OrderCreatedEvent"}
  ],
  "subscribe": [
    {"topic": "payment-events", "event": "PaymentCompleted", "handler": "PaymentCompletedHandler"}
  ]
}
```

**Token efficiency:** Natural language ~200 tokens → JSON DSL ~70 tokens (3x savings).

### C-5. Session Restoration Protocol

```
At session start:
1. Read AGENTS.md (most AI tools do this automatically)
2. Follow Context Files paths to load .ai-agents/context/
3. Check .ai-agents/context/current-work.md (if there is work in progress)
4. Run git log --oneline -10 to understand recent changes

At session end:
1. Work in progress → record in .ai-agents/context/current-work.md
2. Newly learned domain knowledge → update relevant .ai-agents/context/ files
3. Incomplete TODOs → record explicitly
```

### C-6. Context Maintenance Rules

Record as a `Context Maintenance` section in AGENTS.md:

```markdown
## Context Maintenance
When changing code in this directory:
- API changes → update `.ai-agents/context/api-spec.json`
- Schema changes → update `.ai-agents/context/data-model.md`
- If domain-overview.md conflicts, also update that document
- Failing to update means the next session will work with outdated context
```

---

## Part D: Reference

### D-1. Inclusion Criteria Summary

| Include (non-inferable) | .ai-agents/context/ (high inference cost) | Do Not Include (low inference cost) |
|---|---|---|
| Custom build/test commands | Full API map | Directory structure |
| Team conventions, naming rules | Data model relationships | Single file contents |
| Prohibitions (Never) | Event publish/subscribe specs | README contents |
| PR/commit formats | Inter-service call relationships | Package official docs |
| Protection rules | Infrastructure topology | Import relationships |
| .ai-agents/context/ paths | Business domain policies | Standard syntax |

### D-2. Token Optimization

- Per AGENTS.md: **within 300 tokens** (after substitution)
- .ai-agents/context/ JSON DSL saves 3x compared to natural language
- Omit sections that are not applicable

### D-3. Tool Compatibility

| Tool | AGENTS.md Auto-Read | Session Start File | Bootstrap Needed |
|---|---|---|---|
| Claude Code | △ (fallback) | `CLAUDE.md` | Yes — add directive in CLAUDE.md |
| OpenAI Codex | O (primary) | `AGENTS.md` | No |
| GitHub Copilot | X | `.github/copilot-instructions.md` | Yes — sync or reference |
| Cursor | X | `.cursor/rules/*.mdc` | Yes — sync or reference |
| Windsurf | X | `.windsurfrules` | Yes — sync or reference |
| Aider | O | `.aider.conf.yml` | No |

#### Per-Vendor Bootstrap: Making Each Tool Read AGENTS.md

Each vendor auto-loads only its own config file at session start. AGENTS.md is **not universally auto-loaded**.
To ensure any AI tool reads AGENTS.md, add a bootstrap directive in that vendor's auto-loaded file.

**Claude Code** — `CLAUDE.md`:
```markdown
## Session Start
At the start of every session, read `AGENTS.md` (project root) and follow its instructions.
If `.ai-agents/context/` exists, load the files listed in the Context Files section of AGENTS.md.
```

**Cursor** — `.cursor/rules/agents-bootstrap.mdc`:
```markdown
---
description: Bootstrap AGENTS.md for every session
globs: "**/*"
alwaysApply: true
---
At the start of every session, read `AGENTS.md` (project root) and follow its instructions.
If `.ai-agents/context/` exists, load the files listed in the Context Files section of AGENTS.md.
```

**GitHub Copilot** — `.github/copilot-instructions.md`:
```markdown
At the start of every session, read `AGENTS.md` (project root) and follow its instructions.
If `.ai-agents/context/` exists, load the files listed in the Context Files section of AGENTS.md.
```

**Windsurf** — `.windsurfrules`:
```markdown
At the start of every session, read `AGENTS.md` (project root) and follow its instructions.
If `.ai-agents/context/` exists, load the files listed in the Context Files section of AGENTS.md.
```

**OpenAI Codex** — No bootstrap needed. Codex reads `AGENTS.md` as its primary instruction file.

**Aider** — `.aider.conf.yml`:
```yaml
read: ["AGENTS.md"]
```

#### Automated Bootstrap Generator

**원칙: 이미 사용 중인 벤더만 부트스트랩을 생성한다.** 벤더 설정 파일/디렉토리가 이미 존재하는 경우에만 부트스트랩 지시문을 추가한다. 사용하지 않는 벤더의 파일을 임의로 생성하지 않는다.

```bash
# scripts/sync-ai-rules.sh
AGENTS="AGENTS.md"
BOOTSTRAP_MSG="At the start of every session, read \`AGENTS.md\` (project root) and follow its instructions.
If \`.ai-agents/context/\` exists, load the files listed in the Context Files section of AGENTS.md."

GENERATED=0

# Claude Code — only if CLAUDE.md or .claude/ already exists
if [ -f "CLAUDE.md" ] || [ -d ".claude" ]; then
  if [ -f "CLAUDE.md" ]; then
    grep -q "read.*AGENTS.md" CLAUDE.md || printf '\n## Session Start\n%s\n' "$BOOTSTRAP_MSG" >> CLAUDE.md
  else
    printf '## Session Start\n%s\n' "$BOOTSTRAP_MSG" > CLAUDE.md
  fi
  echo "  ✓ Claude Code: CLAUDE.md updated"
  GENERATED=$((GENERATED + 1))
fi

# Cursor — only if .cursor/ already exists
if [ -d ".cursor" ]; then
  mkdir -p .cursor/rules
  printf -- '---\ndescription: Bootstrap AGENTS.md\nglobs: "**/*"\nalwaysApply: true\n---\n%s\n' "$BOOTSTRAP_MSG" > .cursor/rules/agents-bootstrap.mdc
  echo "  ✓ Cursor: .cursor/rules/agents-bootstrap.mdc created"
  GENERATED=$((GENERATED + 1))
fi

# GitHub Copilot — only if .github/ already exists
if [ -d ".github" ]; then
  printf '%s\n' "$BOOTSTRAP_MSG" > .github/copilot-instructions.md
  echo "  ✓ GitHub Copilot: .github/copilot-instructions.md created"
  GENERATED=$((GENERATED + 1))
fi

# Windsurf — only if .windsurfrules already exists
if [ -f ".windsurfrules" ]; then
  grep -q "read.*AGENTS.md" .windsurfrules || printf '\n%s\n' "$BOOTSTRAP_MSG" >> .windsurfrules
  echo "  ✓ Windsurf: .windsurfrules updated"
  GENERATED=$((GENERATED + 1))
fi

# Aider — only if .aider.conf.yml already exists
if [ -f ".aider.conf.yml" ]; then
  grep -q "AGENTS.md" .aider.conf.yml || printf 'read: ["AGENTS.md"]\n' >> .aider.conf.yml
  echo "  ✓ Aider: .aider.conf.yml updated"
  GENERATED=$((GENERATED + 1))
fi

if [ "$GENERATED" -eq 0 ]; then
  echo "No AI tool config files detected. Bootstrap skipped."
  echo "Manually create the config file for your tool first, then re-run this script."
else
  echo "Bootstrap complete: $GENERATED tool(s) configured to read AGENTS.md."
fi
```

**판단 기준:**

| 감지 조건 | 부트스트랩 대상 |
|---|---|
| `CLAUDE.md` 또는 `.claude/` 존재 | Claude Code |
| `.cursor/` 디렉토리 존재 | Cursor |
| `.github/` 디렉토리 존재 | GitHub Copilot |
| `.windsurfrules` 파일 존재 | Windsurf |
| `.aider.conf.yml` 파일 존재 | Aider |
| `AGENTS.md`만 존재 (위 해당 없음) | Codex (부트스트랩 불필요) |

#### Why Bootstrap Is Required

```
Problem:
  Claude Code starts → reads CLAUDE.md only → doesn't know AGENTS.md exists
  Cursor starts     → reads .cursor/rules/ only → doesn't know AGENTS.md exists

Solution:
  Claude Code starts → reads CLAUDE.md → sees "read AGENTS.md" → reads AGENTS.md ✓
  Cursor starts     → reads .mdc rules → sees "read AGENTS.md" → reads AGENTS.md ✓
  Codex starts      → reads AGENTS.md directly ✓ (no bootstrap needed)
```

The bootstrap directive is a one-line bridge: it tells each vendor's auto-loaded config
to chain-load the vendor-neutral AGENTS.md. This keeps all project knowledge in one place
while remaining compatible with every tool.

### D-4. AGENTS.md Search Priority

```
~/.codex/AGENTS.md            ← global
  └── project-root/AGENTS.md  ← project root (includes Global Conventions)
       └── src/api/AGENTS.md  ← subdirectory (closer takes priority, inherits from parent)
            └── AGENTS.override.md ← same level, highest priority
```

### D-5. Hierarchical Agent Operation Pattern

```
┌──────────────────────────────────────────┐
│  Root PM Agent (AGENTS.md)               │
│  Global Conventions + Delegation Rules   │
│  Design validation is more important     │
│  than code validation!                   │
└────────┬─────────┬─────────┬─────────────┘
         │         │         │  Task delegation
    ┌────▼───┐ ┌───▼───┐ ┌──▼────┐
    │Service │ │Infra  │ │Docs   │  Per-directory Agent
    │Expert  │ │SRE    │ │Planner│  (inherits Global Conventions)
    └────────┘ └───────┘ └───────┘
```

**Delegation Protocol:**
- Parent → Child: "Read this directory's AGENTS.md and work within that scope"
- Child → Parent: Report summary of changes after work is complete
- Same level: Coordinate indirectly through parent agent

### D-6. Practical Application Checklist

```
Phase 1 (Basic)              Phase 2 (Context)            Phase 3 (Operations)
──────────────               ──────────────────           ──────────────
☐ Create AGENTS.md           ☐ Create .ai-agents/context/        ☐ Define .ai-agents/roles/
☐ Build/test commands        ☐ domain-overview.md         ☐ ai-agent-session.sh
☐ Conventions, prohibitions  ☐ api-spec.json (DSL)        ☐ Multi-agent sessions
☐ Global Conventions         ☐ data-model.md              ☐ .ai-agents/skills/ workflows
☐ Per-tool forwarders        ☐ Set up maintenance rules   ☐ Iterative feedback loop
```
