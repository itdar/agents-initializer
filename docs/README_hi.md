🌐 [English](../README.md) | [한국어](README_ko.md) | [日本語](README_ja.md) | [中文](README_zh.md) | [Español](README_es.md) | [Français](README_fr.md) | [Deutsch](README_de.md) | [Русский](README_ru.md) | [हिन्दी](README_hi.md) | [العربية](README_ar.md)

<div align="center">

# ai-initializer

**एक कमांड से किसी भी AI एजेंट को आपके प्रोजेक्ट की तुरंत समझ दें।**

प्रोजेक्ट स्कैन करता है → `AGENTS.md` + knowledge/skill/role संदर्भ उत्पन्न करता है
→ कोई भी AI टूल हर सत्र में तुरंत काम शुरू करता है।

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)
[![Sponsor](https://img.shields.io/badge/Sponsor-%E2%9D%A4-red?logo=github)](https://github.com/sponsors/itdar)

</div>

---

## अभी आज़माएं

इस रिपॉजिटरी में कार्यशील उदाहरण के रूप में पूर्व-निर्मित `AGENTS.md` और `.ai-agents/` फ़ाइलें शामिल हैं।
इसे क्लोन करें और इसे काम में देखने के लिए तुरंत `ai-agency.sh` चलाएं:

```bash
git clone https://github.com/itdar/agents-initializer.git
cd agents-initializer
./ai-agency.sh
```

```
=== AI Agent Sessions ===
Project: /home/user/agents-initializer
Found: 4 agent(s)

  1) [PM] ai-initializer                (bg: Warm Brown)
     Path: ./AGENTS.md
     Project orchestrator managing all sub-agents

  2) business — Business Planner         (bg: Navy)
     Path: business/AGENTS.md
     Business strategy, KPI tracking, go-to-market

  3) docs — Multi-language Docs          (bg: Forest)
     Path: docs/AGENTS.md
     Documentation and translation specialist

  4) planning — Technical Writer         (bg: Plum)
     Path: planning/AGENTS.md
     Specs, roadmaps, architecture documents

Select agent (number, or 'q' to quit): 2

=== AI Tool ===
  1) claude  (Claude Code CLI)
  2) codex   (OpenAI Codex CLI)
  3) print   (print prompt only — for manual copy)

Select tool (1-3): 1

→ Agent reads AGENTS.md + loads .ai-agents/context/ automatically
→ Ready to work immediately!
```

---

## अपने प्रोजेक्ट पर लागू करें

> **महत्वपूर्ण:** `setup.sh` और `HOW_TO_AGENTS.md` को **अपनी प्रोजेक्ट डायरेक्टरी** में कॉपी करें और वहीं से चलाएं।
> ये फ़ाइलें लक्षित प्रोजेक्ट की संरचना का विश्लेषण करती हैं — इन्हें उसके अंदर होना चाहिए।

```bash
# 1. फ़ाइलें अपने प्रोजेक्ट में कॉपी करें
cp setup.sh HOW_TO_AGENTS.md /path/to/your-project/
cd /path/to/your-project

# 2. इंटरेक्टिव सेटअप चलाएं (AI टूल + भाषा चुनें, फिर सब कुछ स्वचालित रूप से उत्पन्न होता है)
./setup.sh

# 3. एजेंट सत्र शुरू करें
./ai-agency.sh
```

बस इतना ही। `setup.sh` टूल पहचान, भाषा चयन संभालता है और पूरी जनरेशन स्वचालित रूप से चलाता है।

<details>
<summary><b>मैन्युअल सेटअप (setup.sh के बिना)</b></summary>

```bash
cd /path/to/your-project

# विकल्प A: अंग्रेज़ी (अनुशंसित — कम टोकन लागत, बेहतर AI प्रदर्शन)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Read HOW_TO_AGENTS.md and generate AGENTS.md tailored to this project"

# विकल्प B: अपनी भाषा में
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "HOW_TO_AGENTS.md पढ़ें और इस प्रोजेक्ट के अनुसार AGENTS.md उत्पन्न करें"

# फिर एजेंट सत्र शुरू करें
./ai-agency.sh
```

</details>

> **टोकन सूचना:** प्रारंभिक सेटअप पूरे प्रोजेक्ट का विश्लेषण करता है और दसियों हजार टोकन उपभोग कर सकता है। यह एकमुश्त लागत है — बाद के सत्र पूर्व-निर्मित संदर्भ तुरंत लोड करते हैं।

---

## आपको इसकी आवश्यकता क्यों है?

### समस्या: AI हर सत्र में अपनी मेमोरी खो देता है

```
 सत्र 1                    सत्र 2                    सत्र 3
┌──────────┐             ┌──────────┐             ┌──────────┐
│ AI पूरा    │             │ AI पूरा    │             │ फिर से     │
│ codebase │  सत्र        │ codebase │  सत्र        │ शुरू से     │
│ पढ़ता है    │  समाप्त       │ पढ़ता है    │  समाप्त       │          │
│ (30 मिन)  │ ──────→     │ (30 मिन)  │ ──────→     │ (30 मिन)  │
│ काम       │ मेमोरी         │ काम       │ मेमोरी         │ काम       │
│ शुरू करता   │ खो गई!       │ शुरू करता   │ खो गई!       │ शुरू करता   │
│ है        │             │ है        │             │ है        │
└──────────┘             └──────────┘             └──────────┘
```

AI एजेंट सत्र समाप्त होने पर सब कुछ भूल जाते हैं। हर बार वे प्रोजेक्ट संरचना को समझने, APIs का विश्लेषण करने और परंपराओं को सीखने में समय बिताते हैं।

| समस्या | परिणाम |
|---|---|
| टीम परंपराओं का ज्ञान नहीं | कोड शैली में असंगतता |
| पूर्ण API मानचित्र का ज्ञान नहीं | हर बार पूरा codebase खोजता है (लागत +20%) |
| प्रतिबंधित क्रियाओं का ज्ञान नहीं | सीधे production DB एक्सेस जैसे जोखिम भरे ऑपरेशन |
| सेवा निर्भरताओं का ज्ञान नहीं | छूटे हुए साइड इफेक्ट्स |

### समाधान: AI के लिए एक "दिमाग" पहले से बनाएं

```
 सत्र शुरू
┌────────────────────────────────────────────────────┐
│                                                    │
│  AGENTS.md पढ़ता है (स्वचालित)                           │
│       │                                            │
│       ▼                                            │
│  "मैं इस सेवा का बैकएंड विशेषज्ञ हूं"                          │
│  "परंपराएं: Conventional Commits, TypeScript          │
│   strict"                                          │
│  "प्रतिबंधित: अन्य सेवाओं को संशोधित करना,                      │
│   secrets हार्डकोड करना"                               │
│       │                                            │
│       ▼                                            │
│  .ai-agents/context/ फ़ाइलें लोड करता है (5 सेकंड)          │
│  "20 APIs, 15 entities, 8 events समझ लिए"           │
│       │                                            │
│       ▼                                            │
│  तुरंत काम शुरू करता है!                                  │
│                                                    │
└────────────────────────────────────────────────────┘
```

**ai-initializer** इसे हल करता है — एक बार उत्पन्न करें, और कोई भी AI टूल आपके प्रोजेक्ट को तुरंत समझ लेता है।

---

## मूल सिद्धांत: 3-परत वास्तुकला

```
                    आपका प्रोजेक्ट
                         │
            ┌────────────┼────────────┐
            ▼            ▼            ▼

     ┌──────────┐  ┌──────────┐  ┌──────────┐
     │ AGENTS.md│  │.ai-agents│  │.ai-agents│
     │          │  │ /context/│  │ /skills/ │
     │ पहचान     │  │ ज्ञान      │  │ व्यवहार    │
     │ "मैं       │  │ "मुझे      │  │ "मैं       │
     │  कौन      │  │  क्या      │  │  कैसे      │
     │  हूं?"     │  │  पता है?"  │  │  काम      │
     │          │  │          │  │  करता     │
     │ + नियम    │  │ + डोमेन    │  │  हूं?"     │
     │ + अनुमतिय  │  │ + मॉडल    │  │ + Deploy │
     │ + पथ     │  │          │  │ + Review │
     └──────────┘  └──────────┘  └──────────┘
      प्रवेश बिंदु   मेमोरी स्टोर  कार्यप्रवाह मानक
```

### 1. AGENTS.md — "मैं कौन हूं?"

प्रत्येक डायरेक्टरी में तैनात एजेंट के लिए **पहचान फ़ाइल**।

```
project/
├── AGENTS.md                  ← PM: सब कुछ समन्वय करने वाला नेता
├── apps/
│   └── api/
│       └── AGENTS.md          ← API विशेषज्ञ: केवल इस सेवा के लिए जिम्मेदार
├── infra/
│   ├── AGENTS.md              ← SRE: सभी बुनियादी ढांचे का प्रबंधन
│   └── monitoring/
│       └── AGENTS.md          ← निगरानी विशेषज्ञ
└── configs/
    └── AGENTS.md              ← कॉन्फ़िगरेशन प्रबंधक
```

यह बिल्कुल **टीम संगठन चार्ट** की तरह काम करता है:
- PM सब कुछ देखता है और कार्य वितरित करता है
- प्रत्येक टीम सदस्य केवल अपने क्षेत्र को गहराई से समझता है
- वे अन्य टीमों के काम को सीधे नहीं संभालते — वे अनुरोध करते हैं

### 2. `.ai-agents/context/` — "मुझे क्या पता है?"

एक फ़ोल्डर जहां **आवश्यक ज्ञान पहले से व्यवस्थित** किया जाता है ताकि AI को हर बार कोड पढ़ना न पड़े।

```
.ai-agents/context/
├── domain-overview.md     ← "यह सेवा ऑर्डर प्रबंधन को संभालती है..."
├── data-model.md          ← "Order, Payment, Delivery entities हैं..."
├── api-spec.json          ← "POST /orders, GET /orders/{id}, ..."
└── event-spec.json        ← "order-created event प्रकाशित करता है..."
```

**उपमा:** नए कर्मचारी के लिए onboarding दस्तावेज़ीकरण। एक बार दस्तावेज़ करें, और किसी को फिर से समझाना नहीं पड़ेगा।

### 3. `.ai-agents/skills/` — "मैं कैसे काम करता हूं?"

दोहराए जाने वाले कार्यों के लिए **मानकीकृत कार्यप्रवाह मैनुअल**।

```
.ai-agents/skills/
├── develop/SKILL.md       ← "फीचर dev: विश्लेषण → डिज़ाइन → कार्यान्वयन → परीक्षण → PR"
├── deploy/SKILL.md        ← "Deploy: Tag → अनुरोध → सत्यापन"
└── review/SKILL.md        ← "Review: सुरक्षा, प्रदर्शन, परीक्षण चेकलिस्ट"
```

**उपमा:** टीम का संचालन मैनुअल — AI को "PR सबमिट करने से पहले यह चेकलिस्ट जांचें" जैसे नियमों का पालन कराता है।

---

## क्या लिखें और क्या न लिखें

> ETH Zurich (2026.03): **अनुमान योग्य सामग्री शामिल करने से सफलता दर कम होती है और लागत +20% बढ़ती है**

```
         यह लिखें                          यह न लिखें
  ┌─────────────────────────┐     ┌─────────────────────────┐
  │                         │     │                         │
  │  "commits के लिए feat:    │     │  "सोर्स कोड src/           │
  │   फॉर्मेट उपयोग करें"         │     │   फ़ोल्डर में है"             │
  │  AI इसका अनुमान नहीं         │     │  AI इसे ls से देख सकता      │
  │  लगा सकता                 │     │  है                      │
  │                         │     │                         │
  │  "main में सीधे push        │     │  "React component-      │
  │   न करें"                 │     │   आधारित है"               │
  │  टीम नियम, कोड में नहीं        │     │  पहले से आधिकारिक            │
  │                         │     │  docs में है               │
  │  "deploy से पहले QA       │     │  "यह फ़ाइल 100            │
  │   टीम की मंजूरी              │     │   लाइन लंबी है"             │
  │   आवश्यक"                │     │  AI इसे सीधे पढ़ सकता        │
  │  प्रक्रिया, अनुमान योग्य        │     │  है                      │
  │  नहीं                     │     │                         │
  └─────────────────────────┘     └─────────────────────────┘
       AGENTS.md में लिखें             बिल्कुल न लिखें!
```

**अपवाद:** "वे चीजें जिनका अनुमान लगाया जा सकता है लेकिन हर बार करना बहुत महंगा है"

```
  उदाहरण: पूर्ण API सूची (20 फ़ाइलें पढ़नी होंगी)
  उदाहरण: डेटा मॉडल संबंध (10 फ़ाइलों में बिखरे हुए)
  उदाहरण: इंटर-सेवा कॉल संबंध (कोड + infra दोनों जांचने होंगे)

  → इन्हें .ai-agents/context/ में पहले से व्यवस्थित करें!
  → AGENTS.md में केवल पथ लिखें: "इसे यहां खोजें"
```

```
शामिल करें (अनुमान योग्य नहीं)   .ai-agents/context/ (महंगा अनुमान)    बाहर रखें (सस्ता अनुमान)
──────────────────────────        ────────────────────────────────      ────────────────────────
टीम परंपराएं                      पूर्ण API मानचित्र                    डायरेक्टरी संरचना
प्रतिबंधित क्रियाएं               डेटा मॉडल संबंध                      एकल फ़ाइल सामग्री
PR/commit फॉर्मेट                 Event pub/sub specs                   आधिकारिक फ्रेमवर्क docs
छिपी निर्भरताएं                   Infrastructure topology               Import संबंध
                                  KPI लक्ष्य और व्यावसायिक मेट्रिक्स
                                  Stakeholder मानचित्र और अनुमोदन प्रवाह
                                  Ops runbooks और एस्केलेशन पथ
                                  रोडमैप और मील का पत्थर ट्रैकिंग
```

---

## यह कैसे काम करता है

### चरण 1: प्रोजेक्ट स्कैन और वर्गीकरण

depth 3 तक डायरेक्टरी की खोज करता है और फ़ाइल पैटर्न के आधार पर स्वचालित रूप से वर्गीकृत करता है।

```
deployment.yaml + service.yaml  →  k8s-workload
values.yaml (Helm)              →  infra-component
package.json + *.tsx            →  frontend
go.mod                          →  backend-go
Dockerfile + CI config          →  cicd
...19 प्रकार स्वचालित रूप से पहचाने जाते हैं
```

### चरण 2: संदर्भ निर्माण

पहचाने गए प्रकारों के आधार पर **वास्तव में कोड का विश्लेषण करके** `.ai-agents/context/` ज्ञान फ़ाइलें उत्पन्न करता है।

```
Backend service पहचाना गया
  → routes/controllers स्कैन करें → api-spec.json उत्पन्न करें
  → entities/schemas स्कैन करें   → data-model.md उत्पन्न करें
  → Kafka config स्कैन करें       → event-spec.json उत्पन्न करें
```

### चरण 3: AGENTS.md निर्माण

उपयुक्त टेम्पलेट का उपयोग करके प्रत्येक डायरेक्टरी के लिए AGENTS.md उत्पन्न करता है।

```
Root AGENTS.md (वैश्विक परंपराएं)
  → Commits: Conventional Commits
  → PR: टेम्पलेट आवश्यक, 1+ अनुमोदन
  → Branches: feature/{ticket}-{desc}
       │
       ▼ स्वचालित रूप से विरासत में मिलता है (children में दोहराया नहीं)
  apps/api/AGENTS.md
    → केवल override: "यह सेवा Python उपयोग करती है"
```

वैश्विक नियम **विरासत पैटर्न** का उपयोग करते हैं — एक स्थान पर लिखें, और यह स्वचालित रूप से नीचे की ओर लागू होता है।

```
Root AGENTS.md ──────────────────────────────────────────
│ वैश्विक परंपराएं:
│  - Commits: Conventional Commits (feat:, fix:, chore:)
│  - PR: टेम्पलेट आवश्यक, कम से कम 1 समीक्षक
│  - Branch: feature/{ticket}-{desc}
│
│     स्वचालित विरासत              स्वचालित विरासत
│     ┌──────────────────┐       ┌──────────────────┐
│     ▼                  │       ▼                  │
│  apps/api/AGENTS.md    │    infra/AGENTS.md       │
│  (केवल अतिरिक्त        │    (केवल अतिरिक्त                │
│   नियम निर्दिष्ट)      │     नियम निर्दिष्ट)                │
│  "यह सेवा              │    "Helm values बदलते       │
│   Python उपयोग         │     समय, पहले पूछें"          │
│   करती है"             │                            │
└─────────────────────────┴──────────────────────────
```

**लाभ:**
- commit नियम बदलना चाहते हैं? → केवल root को संशोधित करें
- नई सेवा जोड़ रहे हैं? → वैश्विक नियम स्वचालित रूप से लागू होते हैं
- किसी विशिष्ट सेवा के लिए अलग नियम चाहिए? → उस सेवा के AGENTS.md में override करें

### चरण 4: Vendor-विशिष्ट Bootstrap

Vendor-विशिष्ट configs में bridges जोड़ता है ताकि **सभी AI टूल** उत्पन्न AGENTS.md पढ़ें।

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
           AGENTS.md (एकल सत्य स्रोत)
                  │
        ┌─────────┼─────────┐
        ▼         ▼         ▼
  .ai-agents/  .ai-agents/  .ai-agents/
   context/     skills/      roles/
```

> **सिद्धांत:** Bootstrap फ़ाइलें केवल उन्हीं vendors के लिए उत्पन्न की जाती हैं जो पहले से उपयोग में हैं। अप्रयुक्त टूल्स के लिए config फ़ाइलें कभी नहीं बनाई जातीं।

---

## Vendor संगतता

| टूल | AGENTS.md स्वचालित पढ़ता है | Bootstrap |
|---|---|---|
| **OpenAI Codex** | हां (native) | आवश्यक नहीं |
| **Claude Code** | आंशिक (fallback) | `CLAUDE.md` में directive जोड़ता है |
| **Cursor** | नहीं | `.cursor/rules/` में `.mdc` जोड़ता है |
| **GitHub Copilot** | नहीं | `.github/copilot-instructions.md` उत्पन्न करता है |
| **Windsurf** | नहीं | `.windsurfrules` में directive जोड़ता है |
| **Aider** | हां | `.aider.conf.yml` में read जोड़ता है |

Bootstrap स्वचालित रूप से उत्पन्न करें:
```bash
bash scripts/sync-ai-rules.sh
```

---

## उत्पन्न संरचना

```
project-root/
├── AGENTS.md                          # PM Agent (समग्र समन्वय)
├── .ai-agents/
│   ├── context/                       # ज्ञान फ़ाइलें (सत्र शुरू होने पर लोड)
│   │   ├── domain-overview.md         #   व्यावसायिक डोमेन, नीतियां, बाधाएं
│   │   ├── data-model.md             #   Entity परिभाषाएं, संबंध, स्थिति परिवर्तन
│   │   ├── api-spec.json              #   API मानचित्र (JSON DSL, 3x टोकन बचत)
│   │   ├── event-spec.json            #   Kafka/MQ event specs
│   │   ├── infra-spec.md              #   Helm charts, नेटवर्किंग, deployment क्रम
│   │   ├── external-integration.md    #   बाहरी APIs, auth, rate limits
│   │   ├── business-metrics.md        #   KPIs, OKRs, राजस्व मॉडल, सफलता मानदंड
│   │   ├── stakeholder-map.md         #   निर्णय-निर्माता, अनुमोदन प्रवाह, RACI
│   │   ├── ops-runbook.md             #   परिचालन प्रक्रियाएं, एस्केलेशन, SLA
│   │   └── planning-roadmap.md        #   मील के पत्थर, निर्भरताएं, समयरेखा
│   ├── skills/                        # व्यवहारिक कार्यप्रवाह (मांग पर लोड)
│   │   ├── develop/SKILL.md           #   Dev: विश्लेषण → डिज़ाइन → कार्यान्वयन → परीक्षण → PR
│   │   ├── deploy/SKILL.md            #   Deploy: tag → deploy अनुरोध → सत्यापन
│   │   ├── review/SKILL.md            #   Review: चेकलिस्ट-आधारित
│   │   ├── hotfix/SKILL.md            #   आपातकालीन फिक्स कार्यप्रवाह
│   │   └── context-update/SKILL.md    #   Context फ़ाइल अपडेट प्रक्रिया
│   └── roles/                         # भूमिका परिभाषाएं (भूमिका-विशिष्ट context depth)
│       ├── pm.md                      #   Project Manager
│       ├── backend.md                 #   Backend Developer
│       ├── frontend.md                #   Frontend Developer
│       ├── sre.md                     #   SRE / Infrastructure
│       └── reviewer.md               #   Code Reviewer
│
├── apps/
│   ├── api/AGENTS.md                  # प्रति-सेवा एजेंट
│   └── web/AGENTS.md
└── infra/
    └── helm/AGENTS.md
```

---

## सत्र लॉन्चर

```bash
./ai-agency.sh            # इंटरेक्टिव: एजेंट और AI टूल चुनें
./ai-agency.sh --multi    # समानांतर: कई tmux sessions एक साथ खोलें
```

---

## टोकन अनुकूलन

| फॉर्मेट | टोकन संख्या | नोट्स |
|---|---|---|
| प्राकृतिक भाषा API विवरण | ~200 टोकन | |
| JSON DSL | ~70 टोकन | **3x बचत** |

**api-spec.json उदाहरण:**
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

**AGENTS.md लक्ष्य:** प्रतिस्थापन के बाद **300 टोकन** से कम

---

## सत्र पुनर्स्थापना प्रोटोकॉल

```
सत्र शुरू:
  1. AGENTS.md पढ़ें (अधिकांश AI टूल यह स्वचालित रूप से करते हैं)
  2. context फ़ाइल पथों का अनुसरण करके .ai-agents/context/ लोड करें
  3. .ai-agents/context/current-work.md जांचें (प्रगति में काम)
  4. git log --oneline -10 (हाल के परिवर्तनों को समझें)

सत्र समाप्त:
  1. प्रगति में काम → current-work.md में रिकॉर्ड करें
  2. नया सीखा डोमेन ज्ञान → context फ़ाइलें अपडेट करें
  3. अधूरे TODOs → स्पष्ट रूप से रिकॉर्ड करें
```

---

## संदर्भ रखरखाव

जब कोड बदलता है, `.ai-agents/context/` फ़ाइलों को तदनुसार अपडेट किया जाना चाहिए।

```
API जोड़ा/बदला/हटाया गया    →  api-spec.json अपडेट करें
DB schema बदला             →  data-model.md अपडेट करें
Event spec बदला            →  event-spec.json अपडेट करें
व्यावसायिक नीति बदली        →  domain-overview.md अपडेट करें
बाहरी integration बदला      →  external-integration.md अपडेट करें
Infrastructure config बदला  →  infra-spec.md अपडेट करें
KPI/OKR लक्ष्य बदले          →  business-metrics.md अपडेट करें
टीम संरचना बदली              →  stakeholder-map.md अपडेट करें
परिचालन प्रक्रिया बदली         →  ops-runbook.md अपडेट करें
मील का पत्थर/रोडमैप बदला      →  planning-roadmap.md अपडेट करें
```

> अपडेट न करने का मतलब है कि अगला सत्र **पुराने संदर्भ के साथ काम करेगा**।

---

## समग्र प्रवाह सारांश

```
┌──────────────────────────────────────────────────────────────────┐
│  1. प्रारंभिक सेटअप (एकमुश्त)                                           │
│                                                                  │
│  ./setup.sh चलाएं (HOW_TO_AGENTS.md स्वचालित रूप से उपयोग होता है)          │
│       │                                                          │
│       ▼                                                          │
│  AI प्रोजेक्ट संरचना का विश्लेषण करता है                                     │
│       │                                                          │
│       ▼                                                          │
│  प्रत्येक डायरेक्टरी में AGENTS.md       .ai-agents/context/ में            │
│  बनाता है                               ज्ञान व्यवस्थित करता है            │
│  (एजेंट पहचान + नियम                    (API, model, event specs)    │
│   + अनुमतियां)                                                       │
│                                                                  │
│  .ai-agents/skills/ में                 .ai-agents/roles/ में        │
│  कार्यप्रवाह परिभाषित करता है            भूमिकाएं परिभाषित करता ह                 │
│  (development, deploy, review            (Backend, Frontend, SRE)│
│   प्रक्रियाएं)                                                        │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  2. दैनिक उपयोग                                                     │
│                                                                  │
│  ./ai-agency.sh चलाएं                                              │
│       │                                                          │
│       ▼                                                          │
│  एजेंट चुनें (PM? Backend? SRE?)                                      │
│       │                                                          │
│       ▼                                                          │
│  AI टूल चुनें (Claude? Codex? Cursor?)                               │
│       │                                                          │
│       ▼                                                          │
│  सत्र शुरू → AGENTS.md स्वचालित लोड → .ai-agents/context/               │
│  लोड → काम!                                                        │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  3. निरंतर रखरखाव                                                   │
│                                                                  │
│  जब कोड बदलता है:                                                   │
│    - AI स्वचालित रूप से .ai-agents/context/ अपडेट करता है                │
│    - या मानव निर्देश देता है "यह महत्वपूर्ण है, इसे रिकॉर्ड करो"                  │
│                                                                  │
│  नई सेवा जोड़ते समय:                                                  │
│    - ./setup.sh फिर चलाएं → नया AGENTS.md स्वचालित उत्पन्न               │
│    - वैश्विक नियम स्वचालित रूप से विरासत में मिलते हैं                            │
│                                                                  │
│  जब AI गलतियां करे:                                                  │
│    - "इसे फिर से विश्लेषण करें" → संकेत दें → एक बार समझने के                   │
│      बाद, .ai-agents/context/ अपडेट करें                             │
│    - यह feedback loop context गुणवत्ता में सुधार करता है                  │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## उपमा: पारंपरिक टीम बनाम AI एजेंट टीम

```
              पारंपरिक Dev टीम          AI एजेंट टीम
              ────────────────────       ──────────────────
 नेता         PM (मानव)                  Root AGENTS.md (PM agent)
 सदस्य        N developers              प्रत्येक डायरेक्टरी में AGENTS.md
 Onboarding   Confluence/Notion         .ai-agents/context/
 मैनुअल       टीम wiki                  .ai-agents/skills/
 भूमिका परिभाषाएं Job titles/R&R docs   .ai-agents/roles/
 टीम नियम     टीम परंपरा docs           Global Conventions (विरासत)
 काम शुरू      ऑफिस आना                 सत्र शुरू → AGENTS.md लोड
 काम खत्म      जाना (मेमोरी बनी रहती)   सत्र समाप्त (मेमोरी खो जाती!)
 अगला दिन      मेमोरी बरकरार            .ai-agents/context/ लोड (मेमोरी बहाल)
```

**मुख्य अंतर:** मनुष्य काम छोड़ने के बाद अपनी मेमोरी बनाए रखते हैं, लेकिन AI हर बार सब कुछ भूल जाता है।
इसीलिए `.ai-agents/context/` मौजूद है — यह AI की **दीर्घकालिक मेमोरी** के रूप में काम करता है।

---

## अपनाने की चेकलिस्ट

```
चरण 1 (बुनियादी)              चरण 2 (संदर्भ)                  चरण 3 (संचालन)
────────────────               ─────────────────                ────────────────────
☐ AGENTS.md उत्पन्न करें      ☐ .ai-agents/context/ बनाएं     ☐ .ai-agents/roles/ परिभाषित करें
☐ build/test कमांड रिकॉर्ड   ☐ domain-overview.md             ☐ multi-agent sessions चलाएं
☐ परंपराएं और नियम रिकॉर्ड   ☐ api-spec.json (DSL)            ☐ .ai-agents/skills/ कार्यप्रवाह
☐ Global Conventions          ☐ data-model.md                  ☐ पुनरावृत्त feedback loop
☐ Vendor bootstraps           ☐ रखरखाव नियम सेट करें
```

---

## परिणाम

| फ़ाइल | दर्शक | उद्देश्य |
|---|---|---|
| `setup.sh` | मानव | इंटरेक्टिव सेटअप — टूल पहचान, भाषा चयन, और पूर्ण जनरेशन |
| `HOW_TO_AGENTS.md` | AI | Meta-instruction मैनुअल जिसे एजेंट पढ़ते और निष्पादित करते हैं |
| `README.md` | मानव | यह दस्तावेज़ — मानव समझ के लिए एक गाइड |
| `ai-agency.sh` | मानव | एजेंट चयन → AI सत्र लॉन्चर |
| `AGENTS.md` (प्रत्येक डायरेक्टरी) | AI | प्रति-डायरेक्टरी एजेंट पहचान + नियम |
| `.ai-agents/context/*.md/json` | AI | पूर्व-व्यवस्थित डोमेन ज्ञान |
| `.ai-agents/skills/*/SKILL.md` | AI | मानकीकृत कार्य कार्यप्रवाह |
| `.ai-agents/roles/*.md` | AI/मानव | प्रति-भूमिका context लोडिंग रणनीतियां |

---

## संदर्भ

- [Kurly OMS Team AI Workflow](https://helloworld.kurly.com/blog/oms-claude-ai-workflow/) — इस प्रणाली के context डिज़ाइन की प्रेरणा
- [AGENTS.md Standard](https://agents.md/) — Vendor-neutral एजेंट निर्देश मानक
- [ETH Zurich Research](https://www.infoq.com/news/2026/03/agents-context-file-value-review/) — "केवल वही दस्तावेज़ करें जिसका अनुमान नहीं लगाया जा सकता"

---

## लाइसेंस

MIT

---

<p align="center">
  <sub>AI एजेंटों को आपके प्रोजेक्ट को समझने में लगने वाले समय को शून्य तक कम करें।</sub>
</p>
