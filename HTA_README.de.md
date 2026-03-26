# AI-Agenten-Verwaltungssystem — Ein Leitfaden fuer Menschen

## Wie fange ich an?

> **Warnung: Hoher Token-Verbrauch** — Die Ersteinrichtung verwendet ein Top-Modell zur Analyse des gesamten Projekts und erstellt mehrere Dateien (AGENTS.md, .ai-agents/context/, .ai-agents/skills/, .ai-agents/roles/). Je nach Projektgroesse koennen Zehntausende oder mehr Tokens verbraucht werden. Dies ist ein einmaliger Aufwand — nachfolgende Sitzungen laden den vorbereiteten Kontext und starten sofort.

```bash
# 1. Lasse die AI HOW_TO_AGENTS.md lesen — sie richtet alles selbst ein

# Option A: Englisch (empfohlen — geringere Token-Kosten, beste AI-Leistung)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Read HOW_TO_AGENTS.md and generate AGENTS.md tailored to this project"

# Option B: Deine Sprache (empfohlen wenn Menschen AGENTS.md direkt bearbeiten)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Lies HOW_TO_AGENTS.md und erstelle eine passende AGENTS.md fuer dieses Projekt (auf Deutsch)"

# Empfohlen: --dangerously-skip-permissions fuer unterbrechungsfreies autonomes Setup
# Empfohlen: --model claude-opus-4-6 (oder neuer) fuer beste Ergebnisse

# 2. Starte die Arbeit mit dem erstellten Agenten
./ai-agency.sh

# 3. Ab der naechsten Sitzung kann sofort gearbeitet werden!
```

> Dieses Dokument ist **fuer Menschen zum Lesen und Verstehen** gedacht.
> Es erklaert, warum die von der AI ausgefuehrte Anleitung (HOW_TO_AGENTS.md) existiert,
> nach welchen Prinzipien sie funktioniert und welche Rolle sie in Ihrem Entwicklungsworkflow spielt.

---

## Warum wird ein solches System benoetigt?

### Problem: Die AI verliert jedes Mal ihr Gedaechtnis

```
 Sitzung 1                  Sitzung 2                  Sitzung 3
┌──────────┐             ┌──────────┐             ┌──────────┐
│ AI liest  │             │ AI liest  │             │ Wieder von│
│ gesamten  │  Sitzung    │ erneut    │  Sitzung    │ vorne den │
│ Code      │  beendet    │ gesamten  │  beendet    │ gesamten  │
│ (30 Min.) │ ──────→    │ Code      │ ──────→    │ Code      │
│ Arbeit    │ Gedaechtnis │ (30 Min.) │ Gedaechtnis │ (30 Min.) │
│ beginnt   │ geloescht!  │ Arbeit    │ geloescht!  │ Arbeit    │
│           │             │ beginnt   │             │ beginnt   │
└──────────┘             └──────────┘             └──────────┘
```

AI-Agenten vergessen alles, sobald die Sitzung endet.
Jedes Mal wird Zeit damit verbracht, die Projektstruktur zu erfassen, APIs zu analysieren und Konventionen zu verstehen.

### Loesung: Der AI vorab ein "Gehirn" bereitstellen

```
 Sitzungsstart
┌──────────────────────────────────────────────────┐
│                                                  │
│  AGENTS.md wird gelesen (automatisch)            │
│       │                                          │
│       ▼                                          │
│  "Ich bin der Backend-Experte fuer doppel-api"   │
│  "Konventionen: Conventional Commits, TypeScript strict" │
│  "Verboten: Andere Services aendern, Secrets hardcoden" │
│       │                                          │
│       ▼                                          │
│  .ai-agents/context/-Dateien laden (5 Sek.)             │
│  "20 APIs, 15 Entitaeten, 8 Events erfasst"     │
│       │                                          │
│       ▼                                          │
│  Sofort mit der Arbeit beginnen!                 │
│                                                  │
└──────────────────────────────────────────────────┘
```

---

## Kernprinzip: 3-Schichten-Architektur

```
                    Ihr Projekt
                         │
            ┌────────────┼────────────┐
            ▼            ▼            ▼

     ┌──────────┐  ┌──────────┐  ┌──────────┐
     │ AGENTS.md│  │.ai-agents/context│  │.ai-agents/skills│
     │          │  │          │  │          │
     │Identitaet│  │ Wissen   │  │Verhalten │
     │ "Wer bin │  │ "Die APIs│  │ "Bei der │
     │  ich?"   │  │  dieses  │  │  Entwick-│
     │          │  │  Services│  │  lung so  │
     │ + Regeln │  │  sind so" │  │  vorgehen"│
     │ + Rechte │  │          │  │          │
     │ + Pfade  │  │ + Domaene│  │ + Deploy │
     │          │  │ + Modelle│  │ + Review  │
     └──────────┘  └──────────┘  └──────────┘
      Einstiegs-    Wissens-      Workflow-
      punkt         speicher      Standard
```

### 1. AGENTS.md — "Wer bin ich?"

Die **Identitaetsdatei** des Agenten, der in jedem Verzeichnis platziert wird.

```
Projekt/
├── AGENTS.md                  ← PM: Der Leiter, der alles koordiniert
├── apps/
│   └── doppel-api/
│       └── AGENTS.md          ← API-Experte: Zustaendig nur fuer diesen Service
├── infra/
│   ├── AGENTS.md              ← SRE: Verwaltet die gesamte Infrastruktur
│   └── monitoring/
│       └── AGENTS.md          ← Monitoring-Experte
└── configs/
    └── AGENTS.md              ← Konfigurationsverwalter
```

Es ist wie ein **Team-Organigramm**:
- Der PM ueberblickt das Ganze und verteilt Aufgaben
- Jedes Teammitglied versteht nur seinen Bereich tiefgehend
- Aufgaben anderer Teams werden nicht selbst erledigt, sondern angefragt

### 2. `.ai-agents/context/` — "Was weiss ich?"

Ein Ordner, in dem **Kernwissen vorab aufbereitet** wird, damit die AI nicht jedes Mal den Code lesen muss.

```
.ai-agents/context/
├── domain-overview.md     ← "Dieser Service ist fuer Bestellverwaltung zustaendig..."
├── data-model.md          ← "Es gibt die Entitaeten Order, Payment, Delivery..."
├── api-spec.json          ← "POST /orders, GET /orders/{id}, ..."
└── event-spec.json        ← "Es wird ein order-created-Event veroeffentlicht..."
```

**Vergleich:** Es ist wie ein Onboarding-Dokument fuer neue Mitarbeiter.
Wenn man einmal zusammenfasst, "was unser Team macht, wie die DB-Struktur aussieht, welche APIs es gibt",
muss man es nicht jedes Mal erneut erklaeren.

### 3. `.ai-agents/skills/` — "Wie arbeite ich?"

Standardisierte **Workflow-Handbuecher** fuer wiederkehrende Aufgaben.

```
.ai-agents/skills/
├── develop/SKILL.md       ← "Feature-Entwicklung: Analyse → Design → Implementierung → Test → PR"
├── deploy/SKILL.md        ← "Deployment: Tag → Antrag → Verifizierung"
└── review/SKILL.md        ← "Review: Sicherheit·Performance·Test-Checkliste"
```

**Vergleich:** Das Arbeitshandbuch des Teams.
Dinge wie "Pruefe diese Checkliste beim Erstellen eines PRs" werden auch von der AI befolgt.

---

## Wie werden globale Regeln verwaltet?

Es wird ein **Vererbungsmuster** verwendet. An einer Stelle definiert, automatisch nach unten angewendet.

```
Root AGENTS.md ──────────────────────────────────────────
│ Global Conventions:
│  - Commits: Conventional Commits (feat:, fix:, chore:)
│  - PR: Template Pflicht, mindestens 1 Review
│  - Branch: feature/{ticket}-{desc}
│  - Code: TypeScript strict, single quotes
│
│     Automatische Vererbung          Automatische Vererbung
│     ┌──────────────────┐       ┌──────────────────┐
│     ▼                  │       ▼                  │
│  apps/api/AGENTS.md    │    infra/AGENTS.md       │
│  (Nur zusaetzliche     │    (Nur zusaetzliche     │
│   Regeln angeben)      │     Regeln angeben)      │
│  "Dieser Service       │    "Bei Helm-Values-     │
│   nutzt Python"        │     Aenderung:           │
│   (statt TypeScript)   │     Ask First"           │
└─────────────────────────┴──────────────────────────
```

**Vorteile:**
- Commit-Regeln aendern? → Nur an einer Stelle (Root) aendern
- Neuen Service hinzufuegen? → Globale Regeln werden automatisch angewendet
- Nur ein bestimmter Service anders? → In dessen AGENTS.md ueberschreiben

---

## Was sollte man schreiben und was nicht?

Laut einer ETH-Zuerich-Studie (2026) sinkt die Erfolgsquote und die Kosten steigen um 20%,
wenn man Inhalte dokumentiert, die die AI bereits selbst erschliessen kann.

```
             Schreiben                          Nicht schreiben
     ┌─────────────────────────┐     ┌─────────────────────────┐
     │                         │     │                         │
     │  "Commits im feat:-     │     │  "Quellcode liegt in    │
     │   Format"               │     │   src/"                 │
     │  AI kann das nicht      │     │  AI kann das per ls     │
     │  selbst erschliessen    │     │  sofort sehen           │
     │                         │     │                         │
     │  "Direkter Push auf     │     │  "React ist             │
     │   main verboten"        │     │   komponentenbasiert"   │
     │  Teamregel, nicht       │     │  Steht bereits in der   │
     │  im Code vorhanden      │     │  offiziellen Doku       │
     │                         │     │                         │
     │  "Vor dem Deployment    │     │  "Diese Datei hat       │
     │   QA-Team-Freigabe      │     │   100 Zeilen"           │
     │   erforderlich"         │     │  AI kann sie selbst     │
     │  Prozess, nicht         │     │  lesen                  │
     │  erschliessbar          │     │                         │
     └─────────────────────────┘     └─────────────────────────┘
          In AGENTS.md eintragen          Nicht eintragen!
```

**Es gibt jedoch Ausnahmen:** "Erschliessbar, aber jedes Mal zu teuer"

```
  Bsp: Vollstaendige API-Liste (20 Dateien muessen gelesen werden)
  Bsp: Datenmodell-Beziehungen (ueber 10 Dateien verstreut)
  Bsp: Service-Aufrufbeziehungen (Code + Infrastruktur muessen geprueft werden)

  → Solche Dinge werden vorab in .ai-agents/context/ aufbereitet!
  → In AGENTS.md wird nur der Pfad "hier findest du es" eingetragen
```

---

## Sitzungs-Launcher-Skript

Sobald alle Agenten eingerichtet sind, kann man den gewuenschten Agenten auswaehlen und sofort eine Sitzung starten.

```bash
$ ./ai-agency.sh

=== AI Agent Sessions ===
Project: /Users/nhn/src/doppel-deploy
Found: 8 agent(s)

  1) [PM] doppel-deploy
     Path: ./AGENTS.md
     PM-Agent dieses Projekts. Erfasst die Gesamtstruktur und delegiert Aufgaben.

  2) doppel-api
     Path: apps/dev/doppel-api/AGENTS.md
     Experte fuer K8s-Manifeste des doppel-api-Service.

  3) monitoring
     Path: infra/monitoring/AGENTS.md
     SRE-Experte fuer den Prometheus + Grafana Monitoring-Stack.

  ...

Select agent (number): 2

=== AI Tool ===
  1) claude
  2) codex
  3) print

Select tool: 1

→ Claude-Sitzung wird im doppel-api-Verzeichnis gestartet
→ Agent laedt automatisch AGENTS.md und .ai-agents/context/
→ Sofort einsatzbereit!
```

**Parallele Ausfuehrung (tmux):**

```bash
$ ./ai-agency.sh --multi

Select agents: 1,2,3   # PM + API + Monitoring gleichzeitig ausfuehren

→ 3 tmux-Sitzungen werden geoeffnet
→ In jedem Fenster arbeitet ein anderer Agent unabhaengig
→ Mit Ctrl+B N zwischen Fenstern wechseln
```

---

## Gesamtablauf im Ueberblick

```
┌──────────────────────────────────────────────────────────────────┐
│  1. Ersteinrichtung (einmalig)                                   │
│                                                                  │
│  HOW_TO_AGENTS.md der AI zum Lesen geben                         │
│       │                                                          │
│       ▼                                                          │
│  AI analysiert die Projektstruktur                               │
│       │                                                          │
│       ▼                                                          │
│  AGENTS.md in jedem Verzeichnis       .ai-agents/context/ Wissen        │
│  erstellen                            aufbereiten                │
│  (Agenten-Identitaet + Regeln         (API-, Modell-,            │
│   + Berechtigungen)                    Event-Spezifikationen)    │
│                                                                  │
│  .ai-agents/skills/ Workflows definieren     .ai-agents/roles/ Rollen          │
│  (Entwicklung, Deployment,            definieren                 │
│   Review-Prozesse)                    (Backend, Frontend, SRE)   │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  2. Taegliche Nutzung                                            │
│                                                                  │
│  ./ai-agency.sh ausfuehren                                │
│       │                                                          │
│       ▼                                                          │
│  Agent auswaehlen (PM? Backend? SRE?)                            │
│       │                                                          │
│       ▼                                                          │
│  AI-Tool auswaehlen (Claude? Codex? Cursor?)                     │
│       │                                                          │
│       ▼                                                          │
│  Sitzung starten → AGENTS.md automatisch laden                   │
│  → .ai-agents/context/ laden → Arbeiten!                                │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  3. Laufende Pflege                                              │
│                                                                  │
│  Bei Code-Aenderungen:                                           │
│    - AI aktualisiert automatisch .ai-agents/context/                    │
│      (als Regel in AGENTS.md festgelegt)                         │
│    - Oder der Mensch weist an: "Das ist wichtig, halte es fest"  │
│                                                                  │
│  Bei neuem Service:                                              │
│    - HOW_TO_AGENTS.md erneut ausfuehren                          │
│      → Neue AGENTS.md wird automatisch erstellt                  │
│    - Globale Regeln werden automatisch vererbt                   │
│                                                                  │
│  Wenn die AI Fehler macht:                                       │
│    - "Analysiere es nochmal" → Hinweis geben                     │
│      → Nach Erkenntnis .ai-agents/context/ aktualisieren                │
│    - Diese Feedback-Schleife verbessert die Kontext-Qualitaet    │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## Liste der Ergebnisse

Die in diesem System erstellten Dateien und ihre jeweiligen Zwecke:

| Datei | Zielgruppe | Zweck |
|---|---|---|
| `HOW_TO_AGENTS.md` | AI | Meta-Anleitung, die der Agent liest und ausfuehrt |
| `HOW_TO_AGENTS_PLAN.md` | Mensch/AI | Designplan (Hintergrund der Architekturentscheidungen) |
| `README.md` | Mensch | Dieses Dokument. Leitfaden zum Verstaendnis fuer Menschen |
| `ai-agency.sh` | Mensch | Launcher: Agent auswaehlen → AI-Sitzung starten |
| `AGENTS.md` (je Verzeichnis) | AI | Agenten-Identitaet + Regeln pro Verzeichnis |
| `.ai-agents/context/*.md/json` | AI | Vorab aufbereitetes Domaenenwissen |
| `.ai-agents/skills/*/SKILL.md` | AI | Standardisierte Arbeitsworkflows |
| `.ai-agents/roles/*.md` | AI/Mensch | Kontextladestrategie pro Rolle |

---

## Kern-Analogie

```
              Traditionelles           AI-Agenten-Team
              Entwicklungsteam
              ────────────────         ────────────────
 Leiter      PM (Mensch)              Root AGENTS.md (PM-Agent)
 Teammitgl.  N Entwickler             AGENTS.md in jedem Verzeichnis
 Onboarding  Confluence/Notion        .ai-agents/context/
 Handbuch    Team-Wiki                .ai-agents/skills/
 Rollen      Stellenbeschr./R&R       .ai-agents/roles/
 Teamregeln  Team-Konventionsdoku     Global Conventions (Vererbung)
 Arbeitsbeg. Ankunft im Buero         Sitzungsstart → AGENTS.md laden
 Feierabend  Feierabend               Sitzungsende (Gedaechtnis
             (Gedaechtnis bleibt)      geloescht!)
 Naechster   Erinnerung vorhanden     .ai-agents/context/ laden
 Tag                                  (Gedaechtnis wiederhergestellt)
```

**Kernunterschied:** Menschen behalten ihr Gedaechtnis auch nach Feierabend, aber die AI vergisst jedes Mal.
Deshalb gibt es `.ai-agents/context/` — es dient als **Langzeitgedaechtnis** der AI.

---

## Referenzen

- [Kurly OMS Team AI-Workflow](https://helloworld.kurly.com/blog/oms-claude-ai-workflow/) — Inspiration fuer das Kontextdesign dieses Systems
- [AGENTS.md Standard](https://agents.md/) — Herstellerneutraler Standard fuer Agenten-Anweisungen
- [ETH Zuerich Studie](https://www.infoq.com/news/2026/03/agents-context-file-value-review/) — "Nur das dokumentieren, was nicht erschlossen werden kann"
