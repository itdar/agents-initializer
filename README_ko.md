🌐 [English](README.md) | [한국어](README_ko.md) | [日本語](README_ja.md) | [中文](README_zh.md) | [Español](README_es.md) | [Français](README_fr.md) | [Deutsch](README_de.md) | [Русский](README_ru.md) | [हिन्दी](README_hi.md) | [العربية](README_ar.md)

# ai-initializer

**AI 코딩 도구를 위한 자동 프로젝트 컨텍스트 생성기**

> 프로젝트 디렉토리를 스캔하고
> `AGENTS.md` + 지식/스킬/역할 컨텍스트를 자동 생성하여 AI 에이전트가 즉시 작업을 시작할 수 있게 합니다.

```
한 줄 명령 → 프로젝트 분석 → AGENTS.md 생성 → 모든 AI 도구에서 작동
```

---

## 사용법

> **토큰 사용량 안내** — 초기 설정 시 최상위 모델이 전체 프로젝트를 분석하고 여러 파일(AGENTS.md, .ai-agents/context/, .ai-agents/skills/, .ai-agents/roles/)을 생성합니다. 프로젝트 규모에 따라 수만 토큰이 소비될 수 있습니다. 이는 일회성 비용이며, 이후 세션에서는 사전 구축된 컨텍스트를 로드하여 즉시 시작됩니다.

```bash
# 1. AI에게 HOW_TO_AGENTS.md를 읽히면 나머지는 자동으로 처리됩니다

# 옵션 A: 영어 (권장 — 토큰 비용 절감, 최적의 AI 성능)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Read HOW_TO_AGENTS.md and generate AGENTS.md tailored to this project"

# 옵션 B: 사용자 언어 (AGENTS.md를 직접 편집할 예정이라면 권장)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "HOW_TO_AGENTS.md를 읽고 이 프로젝트에 맞게 AGENTS.md를 생성하라"

# 권장: --model claude-opus-4-6 (또는 이후 버전) 최적의 결과를 위해
# 권장: --dangerously-skip-permissions 중단 없는 자율 실행을 위해

# 2. 생성된 에이전트로 작업 시작
./ai-agency.sh
```

---

## 왜 필요한가?

AI 코딩 도구는 **매 세션마다 프로젝트를 처음부터 다시 학습**합니다.

| 문제 | 결과 |
|---|---|
| 팀 컨벤션을 모름 | 코드 스타일 불일치 |
| 전체 API 맵을 모름 | 매번 전체 코드베이스 탐색 (비용 +20%) |
| 금지된 작업을 모름 | 프로덕션 DB 직접 접근 같은 위험한 작업 |
| 서비스 의존성을 모름 | 사이드 이펙트 누락 |

**ai-initializer**가 이를 해결합니다 — 한 번 생성하면 모든 AI 도구가 프로젝트를 즉시 이해합니다.

---

## 핵심 원칙

> ETH Zurich (2026.03): **추론 가능한 내용을 포함하면 성공률이 떨어지고 비용이 +20% 증가합니다**

```
포함 (추론 불가능)              .ai-agents/context/ (고비용 추론)     제외 (저비용 추론)
───────────────────────        ────────────────────────────────────  ────────────────────────
팀 컨벤션                      전체 API 맵                           디렉토리 구조
금지된 작업                    데이터 모델 관계                      단일 파일 내용
PR/커밋 형식                   이벤트 pub/sub 스펙                   공식 프레임워크 문서
숨겨진 의존성                  인프라 토폴로지                       임포트 관계
```

---

## 생성 구조

```
project-root/
├── AGENTS.md                          # PM 에이전트 (전체 오케스트레이션)
├── .ai-agents/
│   ├── context/                       # 지식 파일 (세션 시작 시 로드)
│   │   ├── domain-overview.md         #   비즈니스 도메인, 정책, 제약조건
│   │   ├── data-model.md              #   엔티티 정의, 관계, 상태 전이
│   │   ├── api-spec.json              #   API 맵 (JSON DSL, 토큰 3배 절감)
│   │   ├── event-spec.json            #   Kafka/MQ 이벤트 스펙
│   │   ├── infra-spec.md              #   Helm 차트, 네트워킹, 배포 순서
│   │   └── external-integration.md    #   외부 API, 인증, 레이트 리밋
│   ├── skills/                        # 행동 워크플로우 (온디맨드 로드)
│   │   ├── develop/SKILL.md           #   개발: 분석 → 설계 → 구현 → 테스트 → PR
│   │   ├── deploy/SKILL.md            #   배포: 태그 → 배포 요청 → 검증
│   │   ├── review/SKILL.md            #   리뷰: 체크리스트 기반
│   │   ├── hotfix/SKILL.md            #   긴급 수정 워크플로우
│   │   └── context-update/SKILL.md    #   컨텍스트 파일 업데이트 절차
│   └── roles/                         # 역할 정의 (역할별 컨텍스트 깊이)
│       ├── pm.md                      #   프로젝트 매니저
│       ├── backend.md                 #   백엔드 개발자
│       ├── frontend.md                #   프론트엔드 개발자
│       ├── sre.md                     #   SRE / 인프라
│       └── reviewer.md                #   코드 리뷰어
│
├── apps/
│   ├── api/AGENTS.md                  # 서비스별 에이전트
│   └── web/AGENTS.md
└── infra/
    └── helm/AGENTS.md
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

감지된 유형을 기반으로 **코드를 실제 분석하여** `.ai-agents/context/` 지식 파일을 생성합니다.

```
백엔드 서비스 감지됨
  → 라우트/컨트롤러 스캔 → api-spec.json 생성
  → 엔티티/스키마 스캔   → data-model.md 생성
  → Kafka 설정 스캔      → event-spec.json 생성
```

### 3단계: AGENTS.md 생성

적절한 템플릿을 사용하여 각 디렉토리에 AGENTS.md를 생성합니다.

```
루트 AGENTS.md (글로벌 컨벤션)
  → 커밋: Conventional Commits
  → PR: 템플릿 필수, 1명 이상 승인
  → 브랜치: feature/{ticket}-{desc}
       │
       ▼ 자동 상속 (하위에서 반복하지 않음)
  apps/api/AGENTS.md
    → 오버라이드만: "이 서비스는 Python 사용"
```

### 4단계: 벤더별 부트스트랩

벤더별 설정에 브릿지를 추가하여 **모든 AI 도구가** 생성된 AGENTS.md를 읽도록 합니다.

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
           AGENTS.md (단일 진실의 원천)
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
| **Claude Code** | 부분적 (폴백) | `CLAUDE.md`에 지시문 추가 |
| **Cursor** | 아니오 | `.cursor/rules/`에 `.mdc` 추가 |
| **GitHub Copilot** | 아니오 | `.github/copilot-instructions.md` 생성 |
| **Windsurf** | 아니오 | `.windsurfrules`에 지시문 추가 |
| **Aider** | 예 | `.aider.conf.yml`에 read 추가 |

부트스트랩 자동 생성:
```bash
bash scripts/sync-ai-rules.sh
```

---

## 계층적 에이전트 구조

```
┌───────────────────────────────────────┐
│  루트 PM 에이전트 (AGENTS.md)          │
│  글로벌 컨벤션 + 위임 규칙             │
│  "설계 검증 > 코드 검증"               │
└────────┬──────────┬─────────┬────────┘
         │          │         │
    ┌────▼────┐ ┌───▼────┐ ┌──▼─────┐
    │ 서비스  │ │ 인프라  │ │  문서  │
    │ 전문가  │ │  SRE   │ │기획자  │
    └─────────┘ └────────┘ └────────┘

위임: 부모 → 자식 (해당 디렉토리의 AGENTS.md 범위 내에서 작동)
보고: 자식 → 부모 (작업 완료 후 변경 요약)
조정: 직접적인 피어 간 통신 없음 — 부모를 통한 간접 조정
```

---

## 토큰 최적화

| 형식 | 토큰 수 | 비고 |
|---|---|---|
| 자연어 API 설명 | ~200 토큰 | |
| JSON DSL | ~70 토큰 | **3배 절감** |

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
  2. 새로 학습한 도메인 지식 → 컨텍스트 파일 업데이트
  3. 미완료 TODO → 명시적으로 기록
```

---

## 컨텍스트 유지보수

코드가 변경되면 `.ai-agents/context/` 파일도 함께 업데이트해야 합니다.

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

## 도입 체크리스트

```
1단계 (기본)                   2단계 (컨텍스트)                 3단계 (운영)
────────────────               ─────────────────                ────────────────────
☐ AGENTS.md 생성               ☐ .ai-agents/context/ 생성       ☐ .ai-agents/roles/ 정의
☐ 빌드/테스트 명령 기록        ☐ domain-overview.md             ☐ 멀티 에이전트 세션 실행
☐ 컨벤션 및 규칙 기록          ☐ api-spec.json (DSL)            ☐ .ai-agents/skills/ 워크플로우
☐ 글로벌 컨벤션                ☐ data-model.md                  ☐ 반복 피드백 루프
☐ 벤더 부트스트랩              ☐ 유지보수 규칙 설정
```

---

## 라이선스

MIT

---

<p align="center">
  <sub>AI 에이전트가 프로젝트를 이해하는 데 걸리는 시간을 제로로 줄이세요.</sub>
</p>
