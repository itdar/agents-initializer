# ai-initializer Planning Roadmap

## Current Milestones

### v1.0 — Core Release (Complete)
- [x] HOW_TO_AGENTS.md meta-guide (6-step generation)
- [x] ai-agency.sh session launcher (single + tmux multi-agent)
- [x] setup.sh interactive setup (tool + language selection)
- [x] 10-language README support

### v1.1 — Business Context Integration (Complete)
- [x] Business/planning/operations context files (business-metrics.md, stakeholder-map.md, ops-runbook.md, planning-roadmap.md)
- [x] Expanded B-9, B-10 templates
- [x] Updated role templates (business-analyst, planner, cs-specialist)
- [x] Incremental setup mode in setup.sh

### v2.0 — Future
<!-- HUMAN INPUT NEEDED: Define v2.0 scope, target dates, owners -->

## Dependencies
- HOW_TO_AGENTS.md template changes affect all generated projects
- README changes require synchronization across 10 languages
- Shell script changes require testing across claude/codex/gemini

## Decision Log
| Date | Decision | Rationale |
|---|---|---|
| 2026-03 | Vendor-neutral AGENTS.md standard | Avoid lock-in to any single AI tool |
| 2026-03 | JSON DSL for api-spec/event-spec | 3x token savings vs natural language |
| 2026-03 | ETH Zurich principle: non-inferable only | Inferable content reduces success rate +20% cost |
