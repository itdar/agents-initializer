🌐 [English](../README.md) | [한국어](README_ko.md) | [日本語](README_ja.md) | [中文](README_zh.md) | [Español](README_es.md) | [Français](README_fr.md) | [Deutsch](README_de.md) | [Русский](README_ru.md) | [हिन्दी](README_hi.md) | [العربية](README_ar.md)

# ai-initializer

**AI 코딩 도구를 위한 자동 프로젝트 컨텍스트 생성기**

> 프로젝트 디렉토리를 스캔하고
> `AGENTS.md` + 지식/스킬/역할 컨텍스트를 자동 생성하여 AI 에이전트가 즉시 작업을 시작할 수 있게 합니다.

```
한 번의 명령 → 프로젝트 분석 → AGENTS.md 생성 → 모든 AI 도구와 호환
```

---

## 사용법

> **토큰 사용 안내** — 초기 설정 시 최상위 모델이 전체 프로젝트를 분석하고 여러 파일(AGENTS.md, .ai-agents/context/, .ai-agents/skills/, .ai-agents/roles/)을 생성합니다. 프로젝트 크기에 따라 수만 토큰이 소비될 수 있습니다. 이는 일회성 비용이며, 이후 세션에서는 미리 구축된 컨텍스트를 로드하여 즉시 시작합니다.

```bash
# 1. AI에게 HOW_TO_AGENTS.md를 읽게 하면 나머지는 자동으로 처리됩니다

# 옵션 A: 영어 (권장 — 토큰 비용이 낮고 AI 성능이 최적화됨)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Read HOW_TO_AGENTS.md and generate AGENTS.md tailored to this project"

# 옵션 B: 사용자 언어 (AGENTS.md를 직접 편집할 계획이라면 권장)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "HOW_TO_AGENTS.md를 읽고 이 프로젝트에 맞게 AGENTS.md를 생성하라"

# 권장: --model claude-opus-4-6 (또는 이후 버전)으로 최상의 결과
# 권장: --dangerously-skip-permissions로 중단 없는 자율 실행

# 2. 생성된 에이전트로 작업 시작
./ai-agency.sh
```

---

## 왜 이것이 필요한가?

### 문제: AI는 매 세션마다 기억을 잃는다

```
 세션 1                    세션 2                    세션 3
┌──────────┐             ┌──────────┐             ┌──────────┐
│ AI가     │             │ AI가      │             │ 다시      │
│ 전체      │  세션        │ 전체      │  세션        │ 처음부터   │
│ 코드를    │  종료        │ 코드를     │  종료        │ 시작      │
│ 읽기      │ ──────→     │ 읽기      │ ──────→     │ (30분)   │
│ (30분)   │ 기억         │ (30분)    │ 기억         │ 작업      │
│ 작업      │ 소실!        │ 작업      │ 소실!        │ 시작      │
│ 시작      │             │ 시작      │             │          │
└──────────┘             └──────────┘             └──────────┘
```

AI 에이전트는 세션이 끝나면 모든 것을 잊어버립니다. 매번 프로젝트 구조를 파악하고, API를 분석하고, 컨벤션을 학습하는 데 시간을 소비합니다.

| 문제 | 결과 |
|---|---|
| 팀 컨벤션을 모름 | 코드 스타일 불일치 |
| 전체 API 맵을 모름 | 매번 전체 코드베이스 탐색 (비용 +20%) |
| 금지 행위를 모름 | 프로덕션 DB 직접 접근 같은 위험한 작업 |
| 서비스 의존성을 모름 | 부작용 누락 |

### 해결책: AI를 위한 "두뇌"를 미리 구축하라

```
 세션 시작
┌──────────────────────────────────────────────────┐
│                                                  │
│  AGENTS.md 읽기 (자동)                             │
│       │                                          │
│       ▼                                          │
│  "나는 이 서비스의 백엔드 전문가이다"                    │
│  "컨벤션: Conventional Commits, TypeScript        │
│   strict"                                        │
│  "금지: 다른 서비스 수정,                             │
│   시크릿 하드코딩"                                   │
│       │                                          │
│       ▼                                          │
│  .ai-agents/context/ 파일 로드 (5초)                │
│  "20개 API, 15개 엔티티, 8개 이벤트 파악 완료"          │
│       │                                          │
│       ▼                                          │
│  즉시 작업 시작!                                    │
│                                                  │
└──────────────────────────────────────────────────┘
```

**ai-initializer**가 이 문제를 해결합니다 — 한 번 생성하면 어떤 AI 도구든 프로젝트를 즉시 이해합니다.

---

## 핵심 원리: 3계층 아키텍처

```
                    프로젝트
                         │
            ┌────────────┼────────────┐
            ▼            ▼            ▼
     ┌──────────┐  ┌──────────┐  ┌──────────┐
     │ AGENTS.md│  │.ai-agents│  │.ai-agents│
     │          │  │ /context/│  │ /skills/ │
     │  정체성    │  │   지식    │  │   행동    │
     │ "나는     │  │ "내가     │  │ "어떻게    │
     │  누구?"   │  │  아는     │  │  일하나?"  │
     │          │  │  것은?"   │  │          │
     │ + 규칙    │  │          │  │          │
     │ + 권한    │  │ + 도메인   │  │ + 배포    │
     │ + 경로    │  │ + 모델    │  │ + 리뷰    │
     └──────────┘  └──────────┘  └──────────┘
      진입점        기억 저장소    워크플로 표준
```

### 1. AGENTS.md — "나는 누구인가?"

각 디렉토리에 배치된 에이전트의 **정체성 파일**입니다.

```
project/
├── AGENTS.md                  ← PM: 모든 것을 조율하는 리더
├── apps/
│   └── api/
│       └── AGENTS.md          ← API 전문가: 이 서비스만 담당
├── infra/
│   ├── AGENTS.md              ← SRE: 모든 인프라 관리
│   └── monitoring/
│       └── AGENTS.md          ← 모니터링 전문가
└── configs/
    └── AGENTS.md              ← 설정 관리자
```

이것은 **팀 조직도**와 같은 방식으로 작동합니다:
- PM은 전체를 총괄하고 업무를 분배합니다
- 각 팀원은 자신의 영역만 깊이 이해합니다
- 다른 팀의 업무를 직접 처리하지 않고 요청합니다

### 2. `.ai-agents/context/` — "내가 아는 것은?"

AI가 매번 코드를 읽지 않아도 되도록 **필수 지식을 미리 정리**해 둔 폴더입니다.

```
.ai-agents/context/
├── domain-overview.md     ← "이 서비스는 주문 관리를 담당..."
├── data-model.md          ← "Order, Payment, Delivery 엔티티가 있음..."
├── api-spec.json          ← "POST /orders, GET /orders/{id}, ..."
└── event-spec.json        ← "order-created 이벤트를 발행..."
```

**비유:** 신입 직원을 위한 온보딩 문서. 한 번 문서화하면 더 이상 아무도 설명할 필요가 없습니다.

### 3. `.ai-agents/skills/` — "어떻게 일하는가?"

반복 작업을 위한 **표준화된 워크플로 매뉴얼**입니다.

```
.ai-agents/skills/
├── develop/SKILL.md       ← "기능 개발: 분석 → 설계 → 구현 → 테스트 → PR"
├── deploy/SKILL.md        ← "배포: 태그 → 요청 → 검증"
└── review/SKILL.md        ← "리뷰: 보안, 성능, 테스트 체크리스트"
```

**비유:** 팀 운영 매뉴얼 — "PR 제출 전 이 체크리스트를 확인하라"와 같은 규칙을 AI가 따르게 합니다.

---

## 무엇을 쓰고 무엇을 쓰지 말아야 하는가

> ETH Zurich (2026.03): **추론 가능한 내용을 포함하면 성공률이 떨어지고 비용이 +20% 증가함**

```
         이것을 쓰세요                      이것은 쓰지 마세요
  ┌─────────────────────────┐     ┌─────────────────────────┐
  │                         │     │                         │
  │  "커밋에 feat: 형식을      │     │  "소스 코드는 src/         │
  │   사용하라"               │     │   폴더에 있다"             │
  │  AI가 추론할 수 없음        │     │  AI가 ls로 확인 가능       │
  │                         │     │                         │
  │  "main에 직접 push        │     │  "React는 컴포넌트        │
  │   금지"                  │     │   기반이다"               │
  │  팀 규칙, 코드에 없음        │     │  이미 공식 문서에 있음      │
  │                         │     │                         │
  │  "배포 전 QA 팀           │     │  "이 파일은 100줄이다"      │
  │   승인 필요"              │     │                         │
  │  프로세스, 추론 불가         │     │  AI가 직접 읽을 수 있음     │
  │                         │     │                         │
  └─────────────────────────┘     └─────────────────────────┘
       AGENTS.md에 작성              쓰지 마세요!
```

**예외:** "추론할 수 있지만 매번 하기에는 비용이 너무 큰 것"

```
  예: 전체 API 목록 (파악하려면 20개 파일을 읽어야 함)
  예: 데이터 모델 관계 (10개 파일에 분산되어 있음)
  예: 서비스 간 호출 관계 (코드 + 인프라 모두 확인 필요)

  → 이것들은 .ai-agents/context/에 미리 정리하세요!
  → AGENTS.md에는 경로만 작성: "여기서 찾을 수 있다"
```

```
포함 (추론 불가)                 .ai-agents/context/ (추론 비용 큼)      제외 (추론 비용 낮음)
───────────────────────        ────────────────────────────────────      ────────────────────────
팀 컨벤션                       전체 API 맵                              디렉토리 구조
금지 행위                       데이터 모델 관계                          단일 파일 내용
PR/커밋 형식                    이벤트 발행/구독 스펙                     공식 프레임워크 문서
숨겨진 의존성                   인프라 토폴로지                           임포트 관계
```

---

## 작동 방식

### 1단계: 프로젝트 스캔 및 분류

디렉토리를 깊이 3까지 탐색하고 파일 패턴으로 자동 분류합니다.

```
deployment.yaml + service.yaml  →  k8s-workload
values.yaml (Helm)              →  infra-component
package.json + *.tsx            →  frontend
go.mod                          →  backend-go
Dockerfile + CI config          →  cicd
...19가지 유형 자동 감지
```

### 2단계: 컨텍스트 생성

감지된 유형에 따라 **실제로 코드를 분석하여** `.ai-agents/context/` 지식 파일을 생성합니다.

```
백엔드 서비스 감지됨
  → 라우트/컨트롤러 스캔 → api-spec.json 생성
  → 엔티티/스키마 스캔   → data-model.md 생성
  → Kafka 설정 스캔      → event-spec.json 생성
```

### 3단계: AGENTS.md 생성

적절한 템플릿을 사용하여 각 디렉토리에 AGENTS.md를 생성합니다.

```
루트 AGENTS.md (전역 컨벤션)
  → 커밋: Conventional Commits
  → PR: 템플릿 필수, 1명 이상 승인
  → 브랜치: feature/{ticket}-{desc}
       │
       ▼ 자동 상속 (하위에서 반복하지 않음)
  apps/api/AGENTS.md
    → 오버라이드만: "이 서비스는 Python을 사용한다"
```

전역 규칙은 **상속 패턴**을 사용합니다 — 한 곳에 작성하면 하위에 자동으로 적용됩니다.

```
루트 AGENTS.md ──────────────────────────────────────────
│ 전역 컨벤션:
│  - 커밋: Conventional Commits (feat:, fix:, chore:)
│  - PR: 템플릿 필수, 최소 1명 리뷰어
│  - 브랜치: feature/{ticket}-{desc}
│
│     자동 상속                   자동 상속
│     ┌──────────────────┐       ┌──────────────────┐
│     ▼                  │       ▼                  │
│  apps/api/AGENTS.md    │    infra/AGENTS.md       │
│  (추가 규칙만             │    (추가 규칙만            │
│   명시)                 │     명시)                 │
│  "이 서비스는             │    "Helm values 변경 시   │
│   Python 사용"           │     먼저 확인 요청"        │
└─────────────────────────┴──────────────────────────
```

**장점:**
- 커밋 규칙을 변경하고 싶다면? → 루트만 수정
- 새 서비스를 추가한다면? → 전역 규칙이 자동 적용
- 특정 서비스에 다른 규칙이 필요하다면? → 해당 서비스의 AGENTS.md에서 오버라이드

### 4단계: 벤더별 부트스트랩

벤더별 설정에 브릿지를 추가하여 **모든 AI 도구가** 생성된 AGENTS.md를 읽을 수 있게 합니다.

```
┌──────────────┐     ┌─────────────┐     ┌─────────────┐
│ Claude Code  │     │   Cursor    │     │   Codex     │
│  CLAUDE.md   │     │  .mdc rules │     │  AGENTS.md  │
│      ↓       │     │      ↓      │     │  (네이티브)   │
│ "read        │     │ "read       │     │      ✓      │
│  AGENTS.md"  │     │  AGENTS.md" │     │             │
└──────┬───────┘     └──────┬──────┘     └─────────────┘
       └──────────┬─────────┘
                  ▼
           AGENTS.md (단일 진실 원천)
                   │
         ┌─────────┼─────────┐
         ▼         ▼         ▼
  .ai-agents/  .ai-agents/  .ai-agents/
   context/     skills/      roles/
```

> **원칙:** 부트스트랩 파일은 이미 사용 중인 벤더에 대해서만 생성됩니다. 사용하지 않는 도구의 설정 파일은 절대 생성하지 않습니다.

---

## 벤더 호환성

| 도구 | AGENTS.md 자동 읽기 | 부트스트랩 |
|---|---|---|
| **OpenAI Codex** | 예 (네이티브) | 불필요 |
| **Claude Code** | 부분적 (폴백) | `CLAUDE.md`에 지시어 추가 |
| **Cursor** | 아니오 | `.cursor/rules/`에 `.mdc` 추가 |
| **GitHub Copilot** | 아니오 | `.github/copilot-instructions.md` 생성 |
| **Windsurf** | 아니오 | `.windsurfrules`에 지시어 추가 |
| **Aider** | 예 | `.aider.conf.yml`에 읽기 추가 |

부트스트랩 자동 생성:
```bash
bash scripts/sync-ai-rules.sh
```

---

## 생성되는 구조

```
project-root/
├── AGENTS.md                          # PM 에이전트 (전체 오케스트레이션)
├── .ai-agents/
│   ├── context/                       # 지식 파일 (세션 시작 시 로드)
│   │   ├── domain-overview.md         #   비즈니스 도메인, 정책, 제약사항
│   │   ├── data-model.md             #   엔티티 정의, 관계, 상태 전이
│   │   ├── api-spec.json              #   API 맵 (JSON DSL, 토큰 3배 절약)
│   │   ├── event-spec.json            #   Kafka/MQ 이벤트 스펙
│   │   ├── infra-spec.md              #   Helm 차트, 네트워킹, 배포 순서
│   │   └── external-integration.md    #   외부 API, 인증, 속도 제한
│   ├── skills/                        # 행동 워크플로 (필요 시 로드)
│   │   ├── develop/SKILL.md           #   개발: 분석 → 설계 → 구현 → 테스트 → PR
│   │   ├── deploy/SKILL.md            #   배포: 태그 → 배포 요청 → 검증
│   │   ├── review/SKILL.md            #   리뷰: 체크리스트 기반
│   │   ├── hotfix/SKILL.md            #   긴급 수정 워크플로
│   │   └── context-update/SKILL.md    #   컨텍스트 파일 업데이트 절차
│   └── roles/                         # 역할 정의 (역할별 컨텍스트 깊이)
│       ├── pm.md                      #   프로젝트 매니저
│       ├── backend.md                 #   백엔드 개발자
│       ├── frontend.md                #   프론트엔드 개발자
│       ├── sre.md                     #   SRE / 인프라
│       └── reviewer.md               #   코드 리뷰어
│
├── apps/
│   ├── api/AGENTS.md                  # 서비스별 에이전트
│   └── web/AGENTS.md
└── infra/
    └── helm/AGENTS.md
```

---

## 세션 런처

모든 에이전트가 설정되면, 원하는 에이전트를 선택하고 바로 세션을 시작하세요.

```bash
$ ./ai-agency.sh

=== AI 에이전트 세션 ===
발견: 8개 에이전트

  1) [PM] project-root
  2) api-service
  3) monitoring
  ...

에이전트 선택 (번호): 2

=== AI 도구 ===
  1) claude
  2) codex
  3) print

도구 선택: 1

→ api-service 디렉토리에서 세션 시작
→ 에이전트가 자동으로 AGENTS.md와 .ai-agents/context/ 로드
→ 즉시 작업 가능!
```

**병렬 실행 (tmux):**

```bash
$ ./ai-agency.sh --multi

에이전트 선택: 1,2,3   # PM + API + Monitoring 동시 실행

→ 3개의 tmux 세션 열림
→ 각 패널에서 다른 에이전트가 독립적으로 작업
→ Ctrl+B N으로 패널 전환
```

---

## 토큰 최적화

| 형식 | 토큰 수 | 비고 |
|---|---|---|
| 자연어 API 설명 | ~200 토큰 | |
| JSON DSL | ~70 토큰 | **3배 절약** |

**api-spec.json 예시:**
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

**AGENTS.md 목표:** 치환 후 **300 토큰** 이하

---

## 세션 복원 프로토콜

```
세션 시작:
  1. AGENTS.md 읽기 (대부분의 AI 도구가 자동으로 수행)
  2. 컨텍스트 파일 경로를 따라 .ai-agents/context/ 로드
  3. .ai-agents/context/current-work.md 확인 (진행 중인 작업)
  4. git log --oneline -10 (최근 변경사항 파악)

세션 종료:
  1. 진행 중인 작업 → current-work.md에 기록
  2. 새로 알게 된 도메인 지식 → 컨텍스트 파일 업데이트
  3. 미완료 TODO → 명시적으로 기록
```

---

## 컨텍스트 유지보수

코드가 변경되면 `.ai-agents/context/` 파일도 그에 맞게 업데이트해야 합니다.

```
API 추가/변경/삭제           →  api-spec.json 업데이트
DB 스키마 변경               →  data-model.md 업데이트
이벤트 스펙 변경             →  event-spec.json 업데이트
비즈니스 정책 변경           →  domain-overview.md 업데이트
외부 연동 변경               →  external-integration.md 업데이트
인프라 설정 변경             →  infra-spec.md 업데이트
```

> 업데이트하지 않으면 다음 세션에서 **오래된 컨텍스트로 작업**하게 됩니다.

---

## 전체 흐름 요약

```
┌──────────────────────────────────────────────────────────────────┐
│  1. 초기 설정 (일회성)                                               │
│                                                                  │
│  AI에게 HOW_TO_AGENTS.md를 읽게 하기                                 │
│       │                                                          │
│       ▼                                                          │
│  AI가 프로젝트 구조를 분석                                            │
│       │                                                          │
│       ▼                                                          │
│  각 디렉토리에 AGENTS.md      .ai-agents/context/에 지식             │
│  생성                         정리                               │
│  (에이전트 정체성 + 규칙       (API, 모델, 이벤트 스펙)                  │
│   + 권한)                                                        │
│                                                                  │
│  .ai-agents/skills/에          .ai-agents/roles/에               │
│  워크플로 정의                  역할 정의                            │
│  (개발, 배포, 리뷰              (Backend, Frontend, SRE)           │
│   절차)                                                          │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  2. 일상 사용                                                      │
│                                                                  │
│  ./ai-agency.sh 실행                                              │
│       │                                                          │
│       ▼                                                          │
│  에이전트 선택 (PM? Backend? SRE?)                                  │
│       │                                                          │
│       ▼                                                          │
│  AI 도구 선택 (Claude? Codex? Cursor?)                             │
│       │                                                          │
│       ▼                                                          │
│  세션 시작 → AGENTS.md 자동 로드 → .ai-agents/context/               │
│  로드 → 작업!                                                      │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  3. 지속적 유지보수                                                  │
│                                                                  │
│  코드 변경 시:                                                      │
│    - AI가 자동으로 .ai-agents/context/ 업데이트                       │
│    - 또는 사람이 "이건 중요하니 기록해라" 지시                            │
│                                                                  │
│  새 서비스 추가 시:                                                 │
│    - HOW_TO_AGENTS.md를 다시 실행 → 새 AGENTS.md 자동 생성            │
│    - 전역 규칙이 자동 상속                                            │
│                                                                  │
│  AI가 실수할 때:                                                   │
│    - "이거 다시 분석해" → 힌트 제공 → 이해하면                           │
│      .ai-agents/context/ 업데이트                                  │
│    - 이 피드백 루프가 컨텍스트 품질을 향상시킴                             │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## 비유: 기존 팀 vs AI 에이전트 팀

```
              기존 개발 팀               AI 에이전트 팀
              ────────────────────       ──────────────────
 리더         PM (사람)                  루트 AGENTS.md (PM 에이전트)
 구성원       N명의 개발자              각 디렉토리의 AGENTS.md
 온보딩       Confluence/Notion         .ai-agents/context/
 매뉴얼       팀 위키                   .ai-agents/skills/
 역할 정의    직함/R&R 문서             .ai-agents/roles/
 팀 규칙      팀 컨벤션 문서            전역 컨벤션 (상속)
 출근         사무실 도착               세션 시작 → AGENTS.md 로드
 퇴근         퇴근 (기억 유지)          세션 종료 (기억 소실!)
 다음 날      기억 유지                 .ai-agents/context/ 로드 (기억 복원)
```

**핵심 차이:** 사람은 퇴근 후에도 기억을 유지하지만, AI는 매번 모든 것을 잊어버립니다.
그래서 `.ai-agents/context/`가 존재합니다 — AI의 **장기 기억** 역할을 합니다.

---

## 도입 체크리스트

```
1단계 (기본)                    2단계 (컨텍스트)                    3단계 (운영)
────────────────           ─────────────────                ────────────────────
☐ AGENTS.md 생성              ☐ .ai-agents/context/ 생성        ☐ .ai-agents/roles/ 정의
☐ 빌드/테스트 명령어 기록         ☐ domain-overview.md             ☐ 멀티 에이전트 세션 실행
☐ 컨벤션 및 규칙 기록            ☐ api-spec.json (DSL)            ☐ .ai-agents/skills/ 워크플로
☐ 전역 컨벤션                  ☐ data-model.md                  ☐ 반복 피드백 루프
☐ 벤더 부트스트랩                ☐ 유지보수 규칙 설정
```

---

## 산출물

| 파일 | 대상 | 목적 |
|---|---|---|
| `HOW_TO_AGENTS.md` | AI | 에이전트가 읽고 실행하는 메타 지시 매뉴얼 |
| `README.md` | 사람 | 이 문서 — 사람이 이해하기 위한 가이드 |
| `ai-agency.sh` | 사람 | 에이전트 선택 → AI 세션 런처 |
| `AGENTS.md` (각 디렉토리) | AI | 디렉토리별 에이전트 정체성 + 규칙 |
| `.ai-agents/context/*.md/json` | AI | 미리 정리된 도메인 지식 |
| `.ai-agents/skills/*/SKILL.md` | AI | 표준화된 작업 워크플로 |
| `.ai-agents/roles/*.md` | AI/사람 | 역할별 컨텍스트 로딩 전략 |

---

## 참고 자료

- [Kurly OMS 팀 AI 워크플로](https://helloworld.kurly.com/blog/oms-claude-ai-workflow/) — 이 시스템의 컨텍스트 설계에 영감을 준 사례
- [AGENTS.md 표준](https://agents.md/) — 벤더 중립적 에이전트 지시 표준
- [ETH Zurich 연구](https://www.infoq.com/news/2026/03/agents-context-file-value-review/) — "추론할 수 없는 것만 문서화하라"

---

## 라이선스

MIT

---

<p align="center">
  <sub>AI 에이전트가 프로젝트를 이해하는 데 걸리는 시간을 제로로 줄이세요.</sub>
</p>
