🌐 [English](../README.md) | [한국어](README_ko.md) | [日本語](README_ja.md) | [中文](README_zh.md) | [Español](README_es.md) | [Français](README_fr.md) | [Deutsch](README_de.md) | [Русский](README_ru.md) | [हिन्दी](README_hi.md) | [العربية](README_ar.md)

<div align="center">

# ai-initializer

**Ein Befehl, um jedem KI-Agenten sofortiges Projektverständnis zu geben.**

Scannt Ihr Projekt → generiert `AGENTS.md` + Wissens-/Fähigkeits-/Rollenkontexte
→ jedes KI-Werkzeug beginnt sofort zu arbeiten, in jeder Sitzung.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)

</div>

---

## Jetzt Ausprobieren

Dieses Repository enthält vorgefertigte `AGENTS.md` und `.ai-agents/`-Dateien als funktionierendes Beispiel.
Klonen Sie es und führen Sie `ai-agency.sh` sofort aus, um es in Aktion zu sehen:

```bash
git clone <this-repo>
cd agents-initializer
./ai-agency.sh
```

```
=== AI Agent Sessions ===
Project: /home/user/agents-initializer
Found: 2 agent(s)

  1) [PM] ai-initializer                (bg: Warm Brown)
     Path: ./AGENTS.md
     Project orchestrator managing all sub-agents

  2) docs                                (bg: Navy)
     Path: docs/AGENTS.md
     Documentation specialist

Select agent (number, or 'q' to quit): 1

=== AI Tool ===
  1) claude  (Claude Code CLI)
  2) codex   (OpenAI Codex CLI)
  3) print   (Prompt nur ausgeben — zum manuellen Kopieren)

Select tool (1-3): 1

→ Agent liest AGENTS.md + lädt .ai-agents/context/ automatisch
→ Sofort einsatzbereit!
```

---

## Auf Ihr Projekt Anwenden

> **Wichtig:** Kopieren Sie `setup.sh` und `HOW_TO_AGENTS.md` in **Ihr eigenes Projektverzeichnis** und führen Sie sie von dort aus.
> Diese Dateien analysieren die Struktur des Zielprojekts — sie müssen sich darin befinden.

```bash
# 1. Dateien in Ihr Projekt kopieren
cp setup.sh HOW_TO_AGENTS.md /pfad/zu/ihrem-projekt/
cd /pfad/zu/ihrem-projekt

# 2. Interaktives Setup ausführen (wählt KI-Werkzeug und Sprache, generiert dann alles automatisch)
./setup.sh

# 3. Eine Agentensitzung starten
./ai-agency.sh
```

Das ist alles. `setup.sh` übernimmt die Werkzeugerkennung, Sprachauswahl und führt die vollständige Generierung automatisch durch.

<details>
<summary><b>Manuelle Einrichtung (ohne setup.sh)</b></summary>

```bash
cd /pfad/zu/ihrem-projekt

# Option A: Englisch (empfohlen — geringere Token-Kosten, optimale KI-Leistung)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Read HOW_TO_AGENTS.md and generate AGENTS.md tailored to this project"

# Option B: Deutsch
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Lies HOW_TO_AGENTS.md und erstelle eine auf dieses Projekt zugeschnittene AGENTS.md"

# Agentensitzungen starten
./ai-agency.sh
```

</details>

> **Hinweis zur Token-Nutzung:** Die Ersteinrichtung analysiert das gesamte Projekt und kann Zehntausende von Tokens verbrauchen. Dies ist eine einmalige Kosten — nachfolgende Sitzungen laden den vorgefertigten Kontext sofort.

---

## Warum Brauchen Sie Das?

### Das Problem: KI Verliert Jede Sitzung Ihr Gedächtnis

```
 Sitzung 1                Sitzung 2                Sitzung 3
┌───────────┐             ┌───────────┐             ┌───────────┐
│ KI liest  │             │ KI liest  │             │ Von vorne │
│ gesamte   │  Sitzung    │ gesamte   │  Sitzung    │ anfangen  │
│ Codebasis │  endet      │ Codebasis │  endet      │           │
│ (30 Min.) │ ──────→     │ (30 Min.) │ ──────→     │ (30 Min.) │
│ Beginnt   │ Gedächtnis  │ Beginnt   │ Gedächtnis  │ Beginnt   │
│ zu ar-    │ verloren!   │ zu ar-    │ verloren!   │ zu ar-    │
│ beiten    │             │ beiten    │             │ beiten    │
└───────────┘             └───────────┘             └───────────┘
```

KI-Agenten vergessen alles, wenn eine Sitzung endet. Jedes Mal verbringen sie Zeit damit, die Projektstruktur zu verstehen, APIs zu analysieren und Konventionen zu erlernen.

| Problem | Folge |
|---|---|
| Kennt Team-Konventionen nicht | Inkonsistenter Code-Stil |
| Kennt die vollständige API-Karte nicht | Durchsucht jedes Mal die gesamte Codebasis (Kosten +20%) |
| Kennt verbotene Aktionen nicht | Riskante Operationen wie direkter Produktions-DB-Zugriff |
| Kennt Service-Abhängigkeiten nicht | Übersehene Nebeneffekte |

### Die Lösung: Ein „Gehirn" für die KI Vorausbauen

```
 Sitzungsstart
┌──────────────────────────────────────────────────┐
│                                                  │
│  Liest AGENTS.md (automatisch)                   │
│       │                                          │
│       ▼                                          │
│  „Ich bin der Backend-Experte für diesen Dienst" │
│  „Konventionen: Conventional Commits, TypeScript │
│   strict"                                        │
│  „Verboten: andere Dienste ändern,               │
│   Geheimnisse hardcoden"                         │
│       │                                          │
│       ▼                                          │
│  Lädt .ai-agents/context/ Dateien (5 Sekunden)   │
│  „20 APIs, 15 Entitäten, 8 Ereignisse verstanden"│
│       │                                          │
│       ▼                                          │
│  Beginnt sofort zu arbeiten!                     │
│                                                  │
└──────────────────────────────────────────────────┘
```

**ai-initializer** löst dieses Problem — einmal generieren, und jedes KI-Werkzeug versteht Ihr Projekt sofort.

---

## Grundprinzip: 3-Schichten-Architektur

```
                    Ihr Projekt
                         │
            ┌────────────┼────────────┐
            ▼            ▼            ▼

     ┌──────────┐  ┌──────────┐  ┌──────────┐
     │ AGENTS.md│  │.ai-agents│  │.ai-agents│
     │          │  │ /context/│  │ /skills/ │
     │ Identität│  │ Wissen   │  │ Verhalten│
     │ „Wer     │  │ „Was     │  │ „Wie     │
     │  bin     │  │  weiß    │  │  arbeite │
     │  ich?"   │  │  ich?"   │  │  ich?"   │
     │          │  │          │  │          │
     │ + Regeln │  │ + Domain │  │ + Deploy │
     │ + Rechte │  │ + Modelle│  │ + Review │
     │ + Pfade  │  │          │  │          │
     └──────────┘  └──────────┘  └──────────┘
      Einstiegspkt  Wissensspeich. Workflow-Standards
```

### 1. AGENTS.md — „Wer Bin Ich?"

Die **Identitätsdatei** für den in jedem Verzeichnis eingesetzten Agenten.

```
project/
├── AGENTS.md                  ← PM: Der Leiter, der alles koordiniert
├── apps/
│   └── api/
│       └── AGENTS.md          ← API-Experte: Verantwortlich nur für diesen Dienst
├── infra/
│   ├── AGENTS.md              ← SRE: Verwaltet die gesamte Infrastruktur
│   └── monitoring/
│       └── AGENTS.md          ← Monitoring-Spezialist
└── configs/
    └── AGENTS.md              ← Konfigurationsmanager
```

Es funktioniert genau wie ein **Team-Organigramm**:
- Der PM überwacht alles und verteilt Aufgaben
- Jedes Teammitglied versteht nur seinen Bereich tiefgreifend
- Sie bearbeiten die Arbeit anderer Teams nicht direkt — sie stellen Anfragen

### 2. `.ai-agents/context/` — „Was Weiß Ich?"

Ein Ordner, in dem **wesentliches Wissen vororganisiert** ist, damit die KI den Code nicht jedes Mal lesen muss.

```
.ai-agents/context/
├── domain-overview.md     ← „Dieser Dienst verwaltet Bestellungen..."
├── data-model.md          ← „Es gibt Order-, Payment-, Delivery-Entitäten..."
├── api-spec.json          ← „POST /orders, GET /orders/{id}, ..."
└── event-spec.json        ← „Veröffentlicht das order-created-Ereignis..."
```

**Analogie:** Einarbeitungsdokumentation für einen neuen Mitarbeiter. Einmal dokumentiert, und niemand muss es wieder erklären.

### 3. `.ai-agents/skills/` — „Wie Arbeite Ich?"

**Standardisierte Workflow-Handbücher** für wiederkehrende Aufgaben.

```
.ai-agents/skills/
├── develop/SKILL.md       ← „Feature-Entwicklung: Analysieren → Entwerfen → Umsetzen → Testen → PR"
├── deploy/SKILL.md        ← „Deployment: Tag → Anfrage → Verifizieren"
└── review/SKILL.md        ← „Review: Sicherheit, Leistung, Test-Checkliste"
```

**Analogie:** Das Betriebshandbuch des Teams — lässt die KI Regeln befolgen wie „diese Checkliste prüfen, bevor eine PR eingereicht wird."

---

## Was Man Schreiben Soll und Was Nicht

> ETH Zürich (2026.03): **Inferierbare Inhalte einzuschließen senkt die Erfolgsrate und erhöht die Kosten um +20%**

```
         Das Schreiben                   Das Nicht-Schreiben
  ┌─────────────────────────┐     ┌─────────────────────────┐
  │                         │     │                         │
  │  „feat:-Format für      │     │  „Quellcode ist im      │
  │   Commits verwenden"    │     │   src/-Ordner"          │
  │  KI kann das nicht      │     │  KI kann das mit ls     │
  │  erschließen            │     │  sehen                  │
  │                         │     │                         │
  │  „Kein direkter Push    │     │  „React ist kompo-      │
  │   nach main"            │     │   nentenbasiert"        │
  │  Team-Regel, nicht      │     │  Bereits in offiz.      │
  │  im Code                │     │   Dokumentation         │
  │                         │     │                         │
  │  „QA-Team-Genehmigung   │     │  „Diese Datei ist 100   │
  │   vor dem Deployment    │     │   Zeilen lang"          │
  │   erforderlich"         │     │  KI kann sie direkt     │
  │  Prozess, nicht         │     │   lesen                 │
  │  erschließbar           │     │                         │
  │                         │     │                         │
  └─────────────────────────┘     └─────────────────────────┘
       In AGENTS.md schreiben         NICHT schreiben!
```

**Ausnahme:** „Dinge, die erschlossen werden können, aber jedes Mal zu teuer sind"

```
  z.B.: Vollständige API-Liste (müsste 20 Dateien lesen)
  z.B.: Datenmodell-Beziehungen (auf 10 Dateien verteilt)
  z.B.: Inter-Service-Aufrufbeziehungen (Code + Infra prüfen)

  → Diese in .ai-agents/context/ vororganisieren!
  → In AGENTS.md nur den Pfad schreiben: „hier nachschlagen"
```

```
Einschließen (nicht erschließbar)   .ai-agents/context/ (kostspiel. Inferenz)   Ausschließen (billige Inferenz)
─────────────────────────────────   ─────────────────────────────────────────   ───────────────────────────────
Team-Konventionen                   Vollständige API-Karte                       Verzeichnisstruktur
Verbotene Aktionen                  Datenmodell-Beziehungen                      Einzelne Dateiinhalte
PR-/Commit-Formate                  Event-Pub/Sub-Spezifikationen                Offizielle Framework-Docs
Versteckte Abhängigkeiten           Infrastruktur-Topologie                      Import-Beziehungen
                                    KPI-Ziele & Geschäftskennzahlen
                                    Stakeholder-Karte & Genehmigungsabläufe
                                    Ops-Runbooks & Eskalationspfade
                                    Roadmap & Meilenstein-Tracking
```

---

## Wie Es Funktioniert

### Schritt 1: Projektscan & Klassifizierung

Erkundet Verzeichnisse bis Tiefe 3 und klassifiziert automatisch anhand von Dateimustern.

```
deployment.yaml + service.yaml  →  k8s-workload
values.yaml (Helm)              →  infra-component
package.json + *.tsx            →  frontend
go.mod                          →  backend-go
Dockerfile + CI config          →  cicd
...19 Typen automatisch erkannt
```

### Schritt 2: Kontextgenerierung

Generiert `.ai-agents/context/` Wissensdateien, indem der Code **tatsächlich analysiert** wird, basierend auf den erkannten Typen.

```
Backend-Dienst erkannt
  → Routes/Controller scannen → api-spec.json generieren
  → Entitäten/Schemata scannen → data-model.md generieren
  → Kafka-Konfiguration scannen → event-spec.json generieren
```

### Schritt 3: AGENTS.md-Generierung

Generiert AGENTS.md für jedes Verzeichnis mithilfe passender Vorlagen.

```
Root AGENTS.md (Globale Konventionen)
  → Commits: Conventional Commits
  → PR: Vorlage erforderlich, 1+ Genehmigungen
  → Branches: feature/{ticket}-{desc}
       │
       ▼ Automatisch geerbt (in Kindknoten nicht wiederholt)
  apps/api/AGENTS.md
    → Nur Überschreibungen: „Dieser Dienst verwendet Python"
```

Globale Regeln verwenden ein **Vererbungsmuster** — einmal schreiben, und es gilt automatisch nachgelagert.

```
Root AGENTS.md ──────────────────────────────────────────
│ Globale Konventionen:
│  - Commits: Conventional Commits (feat:, fix:, chore:)
│  - PR: Vorlage erforderlich, mindestens 1 Reviewer
│  - Branch: feature/{ticket}-{desc}
│
│     Automatisch geerbt              Automatisch geerbt
│     ┌──────────────────┐       ┌──────────────────┐
│     ▼                  │       ▼                  │
│  apps/api/AGENTS.md    │    infra/AGENTS.md       │
│  (Nur zusätzliche      │    (Nur zusätzliche      │
│   Regeln angegeben)    │     Regeln angegeben)    │
│  „Dieser Dienst        │    „Bei Helm-values-     │
│   verwendet Python"    │     Änderungen: Erst     │
│                        │     fragen"              │
└────────────────────────┴──────────────────────────
```

**Vorteile:**
- Commit-Regeln ändern? → Nur die Root-Datei anpassen
- Neuen Dienst hinzufügen? → Globale Regeln gelten automatisch
- Andere Regeln für einen bestimmten Dienst? → In der AGENTS.md dieses Dienstes überschreiben

### Schritt 4: Anbieterspezifisches Bootstrap

Fügt Brücken zu anbieterspezifischen Konfigurationen hinzu, damit **alle KI-Werkzeuge** die generierte AGENTS.md lesen.

```
┌──────────────┐     ┌─────────────┐     ┌─────────────┐
│ Claude Code  │     │   Cursor    │     │   Codex     │
│  CLAUDE.md   │     │  .mdc rules │     │  AGENTS.md  │
│      ↓       │     │      ↓      │     │  (nativ)    │
│ „AGENTS.md   │     │ „AGENTS.md  │     │      ✓      │
│  lesen"      │     │  lesen"     │     │             │
└──────┬───────┘     └──────┬──────┘     └─────────────┘
       └──────────┬─────────┘
                  ▼
           AGENTS.md (einzige Wahrheitsquelle)
                  │
        ┌─────────┼─────────┐
        ▼         ▼         ▼
  .ai-agents/  .ai-agents/  .ai-agents/
   context/     skills/      roles/
```

> **Grundsatz:** Bootstrap-Dateien werden nur für bereits verwendete Anbieter generiert. Konfigurationsdateien für nicht verwendete Werkzeuge werden niemals erstellt.

---

## Anbieterkompatibilität

| Werkzeug | Liest AGENTS.md automatisch | Bootstrap |
|---|---|---|
| **OpenAI Codex** | Ja (nativ) | Nicht benötigt |
| **Claude Code** | Teilweise (Fallback) | Fügt Direktive zu `CLAUDE.md` hinzu |
| **Cursor** | Nein | Fügt `.mdc` zu `.cursor/rules/` hinzu |
| **GitHub Copilot** | Nein | Generiert `.github/copilot-instructions.md` |
| **Windsurf** | Nein | Fügt Direktive zu `.windsurfrules` hinzu |
| **Aider** | Ja | Fügt read zu `.aider.conf.yml` hinzu |

Bootstraps automatisch generieren:
```bash
bash scripts/sync-ai-rules.sh
```

---

## Generierte Struktur

```
project-root/
├── AGENTS.md                          # PM-Agent (Gesamtorchestrierung)
├── .ai-agents/
│   ├── context/                       # Wissensdateien (beim Sitzungsstart geladen)
│   │   ├── domain-overview.md         #   Geschäftsdomäne, Richtlinien, Einschränkungen
│   │   ├── data-model.md             #   Entitätsdefinitionen, Beziehungen, Zustandsübergänge
│   │   ├── api-spec.json              #   API-Karte (JSON-DSL, 3-fache Token-Einsparung)
│   │   ├── event-spec.json            #   Kafka/MQ-Ereignisspezifikationen
│   │   ├── infra-spec.md              #   Helm-Charts, Netzwerk, Deployment-Reihenfolge
│   │   ├── external-integration.md    #   Externe APIs, Auth, Rate-Limits
│   │   ├── business-metrics.md        #   KPIs, OKRs, Umsatzmodell, Erfolgskriterien
│   │   ├── stakeholder-map.md         #   Entscheidungsträger, Genehmigungsabläufe, RACI
│   │   ├── ops-runbook.md             #   Betriebsprozeduren, Eskalation, SLA
│   │   └── planning-roadmap.md        #   Meilensteine, Abhängigkeiten, Zeitplan
│   ├── skills/                        # Verhaltens-Workflows (bei Bedarf geladen)
│   │   ├── develop/SKILL.md           #   Entwicklung: analysieren → entwerfen → umsetzen → testen → PR
│   │   ├── deploy/SKILL.md            #   Deployment: Tag → Deploy-Anfrage → Verifizieren
│   │   ├── review/SKILL.md            #   Review: Checklisten-basiert
│   │   ├── hotfix/SKILL.md            #   Notfall-Fix-Workflow
│   │   └── context-update/SKILL.md    #   Prozedur zur Kontextdatei-Aktualisierung
│   └── roles/                         # Rollendefinitionen (rollenspezifische Kontexttiefe)
│       ├── pm.md                      #   Projektmanager
│       ├── backend.md                 #   Backend-Entwickler
│       ├── frontend.md                #   Frontend-Entwickler
│       ├── sre.md                     #   SRE / Infrastruktur
│       └── reviewer.md               #   Code-Reviewer
│
├── apps/
│   ├── api/AGENTS.md                  # Dienstspezifische Agenten
│   └── web/AGENTS.md
└── infra/
    └── helm/AGENTS.md
```

---

## Sitzungsstarter

```bash
./ai-agency.sh                  # Interaktive Agentenauswahl
./ai-agency.sh --multi          # Mehrere Agenten parallel in tmux starten
./ai-agency.sh --list           # Alle verfügbaren Agenten anzeigen
```

---

## Token-Optimierung

| Format | Token-Anzahl | Hinweise |
|---|---|---|
| Natürlichsprachige API-Beschreibung | ~200 Tokens | |
| JSON-DSL | ~70 Tokens | **3-fache Einsparung** |

**api-spec.json Beispiel:**
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

**AGENTS.md Ziel:** Unter **300 Tokens** nach Substitution

---

## Sitzungswiederherstellungsprotokoll

```
Sitzungsstart:
  1. AGENTS.md lesen (die meisten KI-Werkzeuge tun das automatisch)
  2. Kontextdateipfaden folgen und .ai-agents/context/ laden
  3. .ai-agents/context/current-work.md prüfen (laufende Arbeiten)
  4. git log --oneline -10 (aktuelle Änderungen verstehen)

Sitzungsende:
  1. Laufende Arbeiten → In current-work.md dokumentieren
  2. Neu erlerntes Domänenwissen → Kontextdateien aktualisieren
  3. Unvollständige TODOs → Explizit festhalten
```

---

## Kontextpflege

Wenn sich der Code ändert, müssen die `.ai-agents/context/`-Dateien entsprechend aktualisiert werden.

```
API hinzugefügt/geändert/entfernt     →  api-spec.json aktualisieren
DB-Schema geändert                    →  data-model.md aktualisieren
Ereignisspezifikation geändert        →  event-spec.json aktualisieren
Geschäftsrichtlinie geändert          →  domain-overview.md aktualisieren
Externe Integration geändert          →  external-integration.md aktualisieren
Infrastrukturkonfiguration geändert   →  infra-spec.md aktualisieren
KPI/OKR-Ziele geändert               →  business-metrics.md aktualisieren
Teamstruktur geändert                 →  stakeholder-map.md aktualisieren
Betriebsprozedur geändert             →  ops-runbook.md aktualisieren
Meilenstein/Roadmap geändert          →  planning-roadmap.md aktualisieren
```

> Wird die Aktualisierung versäumt, arbeitet die nächste Sitzung mit **veraltetem Kontext**.

---

## Gesamtablauf-Zusammenfassung

```
┌──────────────────────────────────────────────────────────────────┐
│  1. Ersteinrichtung (einmalig)                                   │
│                                                                  │
│  ./setup.sh ausführen                                            │
│       │                                                          │
│       ▼                                                          │
│  KI analysiert die Projektstruktur                               │
│       │                                                          │
│       ▼                                                          │
│  Erstellt AGENTS.md in jedem         Organisiert Wissen in       │
│  Verzeichnis                         .ai-agents/context/         │
│  (Agenten-Identität + Regeln         (API-, Modell-,             │
│   + Berechtigungen)                   Ereignisspezifikationen)   │
│                                                                  │
│  Definiert Workflows in              Definiert Rollen in         │
│  .ai-agents/skills/                  .ai-agents/roles/           │
│  (Entwicklungs-, Deploy-,            (Backend, Frontend, SRE)    │
│   Review-Prozeduren)                                             │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  2. Tägliche Nutzung                                             │
│                                                                  │
│  ./ai-agency.sh ausführen                                        │
│       │                                                          │
│       ▼                                                          │
│  Agenten auswählen (PM? Backend? SRE?)                           │
│       │                                                          │
│       ▼                                                          │
│  KI-Werkzeug auswählen (Claude? Codex? Cursor?)                  │
│       │                                                          │
│       ▼                                                          │
│  Sitzung startet → AGENTS.md auto-geladen → .ai-agents/context/  │
│  geladen → Arbeiten!                                             │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  3. Laufende Wartung                                             │
│                                                                  │
│  Bei Code-Änderungen:                                            │
│    - KI aktualisiert .ai-agents/context/ automatisch             │
│    - Oder ein Mensch weist an: „Das ist wichtig, dokumentiere es"│
│                                                                  │
│  Beim Hinzufügen eines neuen Dienstes:                           │
│    - HOW_TO_AGENTS.md erneut ausführen → Neue AGENTS.md wird     │
│      automatisch generiert                                       │
│    - Globale Regeln werden automatisch geerbt                    │
│                                                                  │
│  Wenn die KI Fehler macht:                                       │
│    - „Das nochmal analysieren" → Hinweise geben → Wenn verstanden│
│      .ai-agents/context/ aktualisieren                           │
│    - Diese Feedback-Schleife verbessert die Kontextqualität      │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## Analogie: Traditionelles Team vs. KI-Agenten-Team

```
              Traditionelles Dev-Team    KI-Agenten-Team
              ──────────────────────     ──────────────────────
 Leiter       PM (Mensch)                Root AGENTS.md (PM-Agent)
 Mitglieder   N Entwickler              AGENTS.md in jedem Verzeichnis
 Einarbeitung Confluence/Notion         .ai-agents/context/
 Handbücher   Team-Wiki                 .ai-agents/skills/
 Rollendefs.  Stellenbeschreibungen     .ai-agents/roles/
 Teamregeln   Team-Konventionsdoks.     Globale Konventionen (geerbt)
 Arbeitsanfang Im Büro ankommen         Sitzung startet → AGENTS.md geladen
 Arbeitsende  Gehen (Gedächtnis bleibt) Sitzung endet (Gedächtnis verloren!)
 Nächster Tag Gedächtnis intakt         .ai-agents/context/ geladen (Gedächtnis wiederhergestellt)
```

**Wesentlicher Unterschied:** Menschen behalten ihr Gedächtnis nach der Arbeit, aber KI vergisst jedes Mal alles.
Deshalb existiert `.ai-agents/context/` — es dient als **Langzeitgedächtnis** der KI.

---

## Einführungs-Checkliste

```
Phase 1 (Grundlagen)              Phase 2 (Kontext)                  Phase 3 (Betrieb)
────────────────────              ─────────────────                  ─────────────────
☐ AGENTS.md generieren            ☐ .ai-agents/context/ erstellen    ☐ .ai-agents/roles/ definieren
☐ Build-/Test-Befehle festhalten  ☐ domain-overview.md               ☐ Multi-Agenten-Sitzungen starten
☐ Konventionen & Regeln festhalten☐ api-spec.json (DSL)              ☐ .ai-agents/skills/ Workflows
☐ Globale Konventionen            ☐ data-model.md                    ☐ Iterative Feedback-Schleife
☐ Anbieter-Bootstraps             ☐ Wartungsregeln einrichten
```

---

## Ergebnisse

| Datei | Zielgruppe | Zweck |
|---|---|---|
| `HOW_TO_AGENTS.md` | KI | Meta-Instruktionshandbuch, das Agenten lesen und ausführen |
| `setup.sh` | Mensch | Interaktives Setup: erkennt Werkzeug, wählt Sprache, führt Generierung durch |
| `README.md` | Mensch | Dieses Dokument — ein Leitfaden für das menschliche Verständnis |
| `ai-agency.sh` | Mensch | Agentenauswahl → KI-Sitzungsstarter |
| `AGENTS.md` (jedes Verzeichnis) | KI | Verzeichnisspezifische Agenten-Identität + Regeln |
| `.ai-agents/context/*.md/json` | KI | Vororganisiertes Domänenwissen |
| `.ai-agents/skills/*/SKILL.md` | KI | Standardisierte Arbeits-Workflows |
| `.ai-agents/roles/*.md` | KI/Mensch | Rollenspezifische Kontextlade-Strategien |

---

## Referenzen

- [Kurly OMS Team AI Workflow](https://helloworld.kurly.com/blog/oms-claude-ai-workflow/) — Inspiration für das Kontextdesign dieses Systems
- [AGENTS.md Standard](https://agents.md/) — Anbieter-neutraler Agenten-Instruktionsstandard
- [ETH Zürich Forschung](https://www.infoq.com/news/2026/03/agents-context-file-value-review/) — „Nur dokumentieren, was nicht erschlossen werden kann"

---

## Lizenz

MIT

---

<p align="center">
  <sub>Reduzieren Sie die Zeit, die KI-Agenten zum Verstehen Ihres Projekts benötigen, auf null.</sub>
</p>
