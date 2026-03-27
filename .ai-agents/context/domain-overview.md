# ai-initializer 도메인 개요

## 비즈니스 목적
AI 코딩 도구(Claude Code, Codex, Gemini CLI, Cursor 등)가 프로젝트를 즉시 이해할 수 있도록 `AGENTS.md` + 지식/스킬/역할 컨텍스트를 자동 생성하는 CLI 도구.

AI 에이전트가 매 세션마다 코드베이스 전체를 다시 분석하는 비효율을 해결한다. 한 번 생성한 컨텍스트를 이후 세션에서 즉시 로딩하여 비용과 시간을 절감.

## 핵심 산출물
1. **HOW_TO_AGENTS.md** — AI가 읽고 실행하는 메타 가이드. 6단계 절차로 프로젝트를 분석하여 AGENTS.md를 생성하는 명령서
2. **setup.sh** — 대화형 원커맨드 셋업. AI 도구 선택 → 언어 선택 → HOW_TO_AGENTS.md 자동 실행. 기존 설정 감지 시 증분 업데이트 모드 지원
3. **ai-agency.sh** — 생성된 AGENTS.md 기반으로 에이전트 세션을 시작하는 런처. tmux 멀티세션, iTerm2 배경색 지원. UI 영문

## 핵심 정책 / 제약
- **벤더 중립**: 특정 AI 도구에 종속되지 않음. AGENTS.md는 모든 도구에서 동작
- **비추론 가능 정보만 포함**: ETH Zurich 연구(2026.03) 기반 — 추론 가능한 내용을 포함하면 성공률 하락 + 비용 20% 증가
- **상대 경로**: 모든 경로 참조는 상대 경로 사용
- **300 토큰 제한**: AGENTS.md 하나당 치환 후 300 토큰 이내 권장
- **JSON DSL**: api-spec.json, event-spec.json은 자연어 대비 3배 토큰 절약

## 디렉토리 타입 분류 체계
HOW_TO_AGENTS.md는 19개 우선순위 규칙으로 디렉토리를 자동 분류:
- k8s-workload, infra-component, gitops-appset, bootstrap
- frontend, backend-node/go/jvm/python
- cicd, github-actions, docs-planning, docs-technical
- env-config, business, customer-support, secrets
- grouping, generic

## 컨텍스트 파일 목록
```
.ai-agents/context/
├── domain-overview.md          # 도메인 개요 (필수)
├── api-spec.json               # API 맵 (JSON DSL)
├── data-model.md               # 데이터 모델
├── event-spec.json             # Kafka/MQ 이벤트 스펙
├── infra-spec.md               # 인프라 토폴로지
├── external-integration.md     # 외부 API 연동
├── business-metrics.md         # KPI, OKR, 수익 모델, 성공 기준
├── stakeholder-map.md          # 의사결정자, 승인 흐름, RACI
├── ops-runbook.md              # 운영 절차, 에스컬레이션, SLA
└── planning-roadmap.md         # 마일스톤, 의존성, 타임라인
```

## 컨텍스트 계층 구조
```
.ai-agents/
├── context/    # 지식 (세션 시작 시 로딩, 토큰 예측 가능)
├── skills/     # 행동 (필요 시 동적 로딩, 유연성)
└── roles/      # 역할 (로딩 전략이 역할마다 다름)
```
지식과 행동을 분리하는 이유: 혼합하면 토큰 사용량이 불예측하고 불필요한 정보로 컨텍스트가 오염됨.

## 레거시 특이사항
<!-- HUMAN INPUT NEEDED: 프로젝트 히스토리에서 비코드적 맥락이 있다면 여기에 기록 -->
