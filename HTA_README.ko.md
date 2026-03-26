# AI 에이전트 관리 시스템 — 사람을 위한 가이드

## 시작하려면?

> **토큰 사용량 주의** — 초기 설정 시 상위 모델로 전체 프로젝트를 분석하고 여러 파일(AGENTS.md, .ai-agents/context/, .ai-agents/skills/, .ai-agents/roles/)을 생성합니다. 프로젝트 규모에 따라 수만 토큰 이상 소모될 수 있습니다. 이는 1회성 비용이며, 이후 세션부터는 미리 구축된 컨텍스트를 로드하여 즉시 시작됩니다.

```bash
# 1. AI에게 HOW_TO_AGENTS.md를 읽히면 알아서 설정

# 옵션 A: 영어 (추천 — 토큰 비용 절감, AI 성능 최적)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Read HOW_TO_AGENTS.md and generate AGENTS.md tailored to this project"

# 옵션 B: 사용자 언어 (AGENTS.md를 사람이 직접 수정하는 경우 추천)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "HOW_TO_AGENTS.md를 읽고 이 프로젝트에 맞게 AGENTS.md를 생성하라"

# 추천: --dangerously-skip-permissions 로 중단 없이 자율 설정
# 추천: --model claude-opus-4-6 (또는 이후 버전) 사용 시 최상의 결과

# 2. 생성된 에이전트로 작업 시작
./ai-agency.sh
```

> 이 문서는 **사람이 읽고 이해하기 위한** 문서입니다.
> AI가 실행하는 지침서(HOW_TO_AGENTS.md)가 왜 존재하고, 어떤 원리로 작동하며,
> 당신의 개발 워크플로에서 어떤 역할을 하는지 설명합니다.

---

## 왜 이런 시스템이 필요한가?

### 문제: AI는 매번 기억을 잃는다

```
 세션 1                    세션 2                    세션 3
┌──────────┐             ┌──────────┐             ┌──────────┐
│ AI가 코드 │             │ AI가 다시  │             │ 또 처음부터 │
│ 전체를 읽음 │  세션 종료   │ 전체를 읽음 │  세션 종료   │ 전체를 읽음 │
│ (30분)    │ ──────→    │ (30분)    │ ──────→    │ (30분)    │
│ 작업 시작  │ 기억 소멸!   │ 작업 시작  │ 기억 소멸!   │ 작업 시작  │
└──────────┘             └──────────┘             └──────────┘
```

AI 에이전트는 세션이 끝나면 모든 것을 잊습니다.
매번 프로젝트 구조를 파악하고, API를 분석하고, 컨벤션을 이해하는 데 시간을 소비합니다.

### 해결: AI에게 "뇌"를 미리 만들어 준다

```
 세션 시작
┌──────────────────────────────────────────────────┐
│                                                  │
│  AGENTS.md를 읽음 (자동)                           │
│       │                                          │
│       ▼                                          │
│  "나는 doppel-api의 백엔드 전문가"                    │
│  "컨벤션: Conventional Commits, TypeScript strict" │
│  "금지: 다른 서비스 수정, 시크릿 하드코딩"               │
│       │                                          │
│       ▼                                          │
│  .ai-agents/context/ 파일 로드 (5초)                      │
│  "API 20개, 엔티티 15개, 이벤트 8개 파악 완료"         │
│       │                                          │
│       ▼                                          │
│  즉시 작업 시작!                                    │
│                                                  │
└──────────────────────────────────────────────────┘
```

---

## 핵심 원리: 3계층 구조

```
                    당신의 프로젝트
                         │
            ┌────────────┼────────────┐
            ▼            ▼            ▼

     ┌──────────┐  ┌──────────┐  ┌──────────┐
     │ AGENTS.md│  │.ai-agents/context│  │.ai-agents/skills│
     │          │  │          │  │          │
     │ 인격     │  │ 지식     │  │ 행동     │
     │ "나는    │  │ "이 서비스│  │ "개발할  │
     │  누구인가"│  │  의 API는 │  │  때는    │
     │          │  │  이렇다"  │  │  이렇게" │
     │ + 규칙   │  │          │  │          │
     │ + 권한   │  │ + 도메인  │  │ + 배포   │
     │ + 경로   │  │ + 모델   │  │ + 리뷰   │
     └──────────┘  └──────────┘  └──────────┘
         진입점        기억 저장소     워크플로 표준
```

### 1. AGENTS.md — "나는 누구인가"

각 디렉토리에 배치되는 에이전트의 **정체성 파일**입니다.

```
프로젝트/
├── AGENTS.md                  ← PM: 전체를 조율하는 리더
├── apps/
│   └── doppel-api/
│       └── AGENTS.md          ← API 전문가: 이 서비스만 담당
├── infra/
│   ├── AGENTS.md              ← SRE: 인프라 전체 관리
│   └── monitoring/
│       └── AGENTS.md          ← 모니터링 전문가
└── configs/
    └── AGENTS.md              ← 설정 관리자
```

마치 **팀 조직도**와 같습니다:
- PM이 전체를 보고 작업을 분배
- 각 팀원은 자기 영역만 깊게 이해
- 다른 팀의 일은 직접 하지 않고 요청

### 2. `.ai-agents/context/` — "무엇을 알고 있는가"

AI가 매번 코드를 읽지 않아도 되도록 **핵심 지식을 사전 정리**해 둔 폴더입니다.

```
.ai-agents/context/
├── domain-overview.md     ← "이 서비스는 주문 관리를 담당하고..."
├── data-model.md          ← "Order, Payment, Delivery 엔티티가 있고..."
├── api-spec.json          ← "POST /orders, GET /orders/{id}, ..."
└── event-spec.json        ← "order-created 이벤트를 발행하고..."
```

**비유:** 신입 사원에게 주는 온보딩 문서와 같습니다.
"우리 팀이 뭘 하는지, DB 구조가 어떤지, API가 뭐가 있는지" 한 번 정리해두면
매번 설명하지 않아도 됩니다.

### 3. `.ai-agents/skills/` — "어떻게 일하는가"

반복되는 작업을 표준화한 **워크플로 매뉴얼**입니다.

```
.ai-agents/skills/
├── develop/SKILL.md       ← "기능 개발: 분석 → 설계 → 구현 → 테스트 → PR"
├── deploy/SKILL.md        ← "배포: 태그 → 요청서 → 검증"
└── review/SKILL.md        ← "리뷰: 보안·성능·테스트 체크리스트"
```

**비유:** 팀의 작업 매뉴얼입니다.
"PR 올릴 때는 이 체크리스트를 확인해" 같은 것을 AI도 따르게 합니다.

---

## 글로벌 규칙은 어떻게 관리하나?

**상속 패턴**을 사용합니다. 한 곳에 쓰고, 아래로 자동 적용됩니다.

```
루트 AGENTS.md ──────────────────────────────────────────
│ Global Conventions:
│  - 커밋: Conventional Commits (feat:, fix:, chore:)
│  - PR: 템플릿 필수, 1명 이상 리뷰
│  - 브랜치: feature/{ticket}-{desc}
│  - 코드: TypeScript strict, single quotes
│
│     자동 상속                    자동 상속
│     ┌──────────────────┐       ┌──────────────────┐
│     ▼                  │       ▼                  │
│  apps/api/AGENTS.md    │    infra/AGENTS.md       │
│  (추가 규칙만 기재)       │    (추가 규칙만 기재)       │
│  "이 서비스는            │    "Helm values 변경 시    │
│   Python 사용"          │     Ask First"           │
│     (TypeScript 대신)   │                          │
└─────────────────────────┴──────────────────────────
```

**장점:**
- 커밋 규칙 바꾸고 싶으면? → 루트 한 곳만 수정
- 새 서비스 추가하면? → 자동으로 글로벌 규칙 적용
- 특정 서비스만 다르게? → 그 서비스의 AGENTS.md에서 오버라이드

---

## 무엇을 쓰고, 무엇을 쓰지 말아야 하나?

ETH Zurich 연구(2026)에 따르면, AI가 이미 추론할 수 있는 내용을 문서에 쓰면
오히려 **성공률이 떨어지고 비용이 20% 증가**합니다.

```
                쓰는 것                          쓰지 않는 것
     ┌─────────────────────────┐     ┌─────────────────────────┐
     │                         │     │                         │
     │  "커밋은 feat: 형식으로"    │     │  "src/ 폴더에 소스가 있다"  │
     │  AI가 추론할 수 없는 것     │     │  AI가 ls로 바로 볼 수 있음  │
     │                         │     │                         │
     │  "main 직접 push 금지"    │     │  "React는 컴포넌트 기반"    │
     │  팀 규칙이라 코드에 없음     │     │  공식 문서에 이미 있음       │
     │                         │     │                         │
     │  "배포 전 QA 팀 승인 필수"  │     │  "이 파일은 100줄이다"      │
     │  프로세스라 추론 불가       │     │  AI가 직접 읽으면 됨        │
     │                         │     │                         │
     └─────────────────────────┘     └─────────────────────────┘
             AGENTS.md에 기재                    기재 금지!
```

**그런데 예외가 있습니다:** "추론은 가능하지만 매번 하면 너무 비싼 것"

```
  예: 전체 API 목록 (20개 파일을 다 읽어야 파악 가능)
  예: 데이터 모델 관계도 (10개 파일에 흩어져 있음)
  예: 서비스 간 호출 관계 (코드 + 인프라 양쪽 확인 필요)

  → 이런 건 .ai-agents/context/에 미리 정리해 둔다!
  → AGENTS.md에는 "여기 가면 있어" 경로만 적는다
```

---

## 세션 런처 스크립트

모든 에이전트가 설정되면, 원하는 에이전트를 골라서 바로 세션을 시작할 수 있습니다.

```bash
$ ./ai-agency.sh

=== AI Agent Sessions ===
Project: /Users/nhn/src/doppel-deploy
Found: 8 agent(s)

  1) [PM] doppel-deploy
     Path: ./AGENTS.md
     이 프로젝트의 PM 에이전트. 전체 구조를 파악하고 작업을 위임한다.

  2) doppel-api
     Path: apps/dev/doppel-api/AGENTS.md
     doppel-api 서비스의 K8s 매니페스트 관리 전문가.

  3) monitoring
     Path: infra/monitoring/AGENTS.md
     Prometheus + Grafana 모니터링 스택의 SRE 전문가.

  ...

Select agent (number): 2

=== AI Tool ===
  1) claude
  2) codex
  3) print

Select tool: 1

→ claude 세션이 doppel-api 디렉토리에서 시작됨
→ 에이전트가 자동으로 AGENTS.md와 .ai-agents/context/ 를 로드
→ 즉시 작업 가능!
```

**병렬 실행 (tmux):**

```bash
$ ./ai-agency.sh --multi

Select agents: 1,2,3   # PM + API + 모니터링 동시 실행

→ tmux 세션 3개가 열림
→ 각 창에서 서로 다른 에이전트가 독립적으로 작업
→ Ctrl+B N으로 창 전환
```

---

## 전체 흐름 요약

```
┌──────────────────────────────────────────────────────────────────┐
│  1. 초기 설정 (1회)                                                │
│                                                                  │
│  HOW_TO_AGENTS.md를 AI에게 읽힘                                     │
│       │                                                          │
│       ▼                                                          │
│  AI가 프로젝트 구조를 분석                                            │
│       │                                                          │
│       ▼                                                          │
│  각 디렉토리에 AGENTS.md 생성     .ai-agents/context/ 지식 정리              │
│  (에이전트 인격 + 규칙 + 권한)     (API, 모델, 이벤트 스펙)            │
│                                                                  │
│  .ai-agents/skills/ 워크플로 정의         .ai-agents/roles/ 역할 정의              │
│  (개발, 배포, 리뷰 절차)          (Backend, Frontend, SRE)          │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  2. 일상 사용                                                      │
│                                                                  │
│  ./ai-agency.sh 실행                                       │
│       │                                                          │
│       ▼                                                          │
│  에이전트 선택 (PM? Backend? SRE?)                                  │
│       │                                                          │
│       ▼                                                          │
│  AI 도구 선택 (Claude? Codex? Cursor?)                             │
│       │                                                          │
│       ▼                                                          │
│  세션 시작 → AGENTS.md 자동 로드 → .ai-agents/context/ 로드 → 작업!         │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  3. 지속적 관리                                                    │
│                                                                  │
│  코드 변경 시:                                                     │
│    - AI가 자동으로 .ai-agents/context/ 업데이트 (AGENTS.md에 규칙으로 명시)   │
│    - 또는 사람이 "이거 중요해, 기록해둬" 지시                           │
│                                                                  │
│  새 서비스 추가 시:                                                  │
│    - HOW_TO_AGENTS.md 다시 실행 → 새 AGENTS.md 자동 생성             │
│    - 글로벌 규칙 자동 상속                                           │
│                                                                  │
│  AI가 틀릴 때:                                                     │
│    - "다시 분석해봐" → 힌트 제공 → 깨달으면 .ai-agents/context/ 업데이트       │
│    - 이 피드백 루프가 컨텍스트 품질을 올림                              │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## 산출물 목록

이 시스템에서 만들어진 파일들과 각각의 용도:

| 파일 | 대상 | 용도 |
|---|---|---|
| `HOW_TO_AGENTS.md` | AI | 에이전트가 읽고 실행하는 메타 지침서 |
| `HOW_TO_AGENTS_PLAN.md` | 사람/AI | 설계 계획서 (왜 이런 구조인지 배경) |
| `README.md` | 사람 | 이 문서. 사람이 이해하기 위한 가이드 |
| `ai-agency.sh` | 사람 | 에이전트 선택 → AI 세션 시작 런처 |
| `AGENTS.md` (각 디렉토리) | AI | 디렉토리별 에이전트 정체성 + 규칙 |
| `.ai-agents/context/*.md/json` | AI | 사전 정리된 도메인 지식 |
| `.ai-agents/skills/*/SKILL.md` | AI | 표준화된 작업 워크플로 |
| `.ai-agents/roles/*.md` | AI/사람 | 역할별 컨텍스트 로딩 전략 |

---

## 핵심 비유

```
              전통적 개발팀              AI 에이전트 팀
              ────────────             ────────────────
 리더        PM (사람)                 루트 AGENTS.md (PM 에이전트)
 팀원        개발자 N명                각 디렉토리의 AGENTS.md
 온보딩 문서   Confluence/Notion       .ai-agents/context/
 작업 매뉴얼   팀 위키                  .ai-agents/skills/
 역할 정의    직급/R&R 문서            .ai-agents/roles/
 팀 규칙     팀 컨벤션 문서            Global Conventions (상속)
 출근        사무실 도착               세션 시작 → AGENTS.md 로드
 퇴근        퇴근 (기억 유지)          세션 종료 (기억 소멸!)
 다음날 출근  기억 있음                .ai-agents/context/ 로드 (기억 복원)
```

**핵심 차이:** 사람은 퇴근해도 기억을 갖고 있지만, AI는 매번 잊습니다.
그래서 `.ai-agents/context/`가 있는 것입니다 — AI의 **장기 기억** 역할을 합니다.

---

## 참고

- [Kurly OMS 팀 AI 워크플로](https://helloworld.kurly.com/blog/oms-claude-ai-workflow/) — 이 시스템의 컨텍스트 설계 영감
- [AGENTS.md 표준](https://agents.md/) — 벤더 중립 에이전트 지침 표준
- [ETH Zurich 연구](https://www.infoq.com/news/2026/03/agents-context-file-value-review/) — "추론 불가능한 것만 기재하라"
