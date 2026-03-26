🌐 [English](../README.md) | [한국어](README_ko.md) | [日本語](README_ja.md) | [中文](README_zh.md) | [Español](README_es.md) | [Français](README_fr.md) | [Deutsch](README_de.md) | [Русский](README_ru.md) | [हिन्दी](README_hi.md) | [العربية](README_ar.md)

# ai-initializer

**Automatischer Projektkontext-Generator für KI-Coding-Tools**

> Scannt Ihr Projektverzeichnis und generiert automatisch
> `AGENTS.md` + Wissens-/Fähigkeiten-/Rollenkontext, damit KI-Agenten sofort mit der Arbeit beginnen können.

```
Ein Befehl → Projektanalyse → AGENTS.md-Generierung → Funktioniert mit jedem KI-Tool
```

---

## Verwendung

> **Hinweis zum Token-Verbrauch** — Bei der Ersteinrichtung analysiert ein Top-Modell das gesamte Projekt und generiert mehrere Dateien (AGENTS.md, .ai-agents/context/, .ai-agents/skills/, .ai-agents/roles/). Dies kann je nach Projektgröße Zehntausende von Tokens verbrauchen. Dies ist ein einmaliger Aufwand; nachfolgende Sitzungen laden den vorgefertigten Kontext und starten sofort.

```bash
# 1. Lassen Sie die KI HOW_TO_AGENTS.md lesen und sie erledigt den Rest

# Option A: Englisch (empfohlen — geringerer Token-Verbrauch, optimale KI-Leistung)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Read HOW_TO_AGENTS.md and generate AGENTS.md tailored to this project"

# Option B: Sprache des Benutzers (empfohlen, wenn Sie AGENTS.md manuell bearbeiten möchten)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "HOW_TO_AGENTS.md를 읽고 이 프로젝트에 맞게 AGENTS.md를 생성하라"

# Empfohlen: --model claude-opus-4-6 (oder neuer) für beste Ergebnisse
# Empfohlen: --dangerously-skip-permissions für ununterbrochene autonome Ausführung

# 2. Beginnen Sie mit den generierten Agenten zu arbeiten
./ai-agency.sh
```

---

## Warum brauchen Sie das?

### Das Problem: KI verliert bei jeder Sitzung ihr Gedächtnis

```
 Sitzung 1                 Sitzung 2                 Sitzung 3
┌──────────┐             ┌──────────┐             ┌──────────┐
│ KI liest  │             │ KI liest  │             │ Wieder    │
│ gesamte   │  Sitzung    │ gesamte   │  Sitzung    │ von vorne │
│ Codebase  │  endet      │ Codebase  │  endet      │ anfangen  │
│ (30 Min)  │ ──────→    │ (30 Min)  │ ──────→    │ (30 Min)  │
│ Beginnt   │ Gedächtnis │ Beginnt   │ Gedächtnis │ Beginnt   │
│ zu        │ verloren!  │ zu        │ verloren!  │ zu        │
│ arbeiten  │             │ arbeiten  │             │ arbeiten  │
└──────────┘             └──────────┘             └──────────┘
```

KI-Agenten vergessen alles, wenn eine Sitzung endet. Jedes Mal verbringen sie Zeit damit, die Projektstruktur zu verstehen, APIs zu analysieren und Konventionen zu lernen.

| Problem | Konsequenz |
|---|---|
| Kennt die Team-Konventionen nicht | Inkonsistenzen im Code-Stil |
| Kennt nicht die vollständige API-Übersicht | Durchsucht jedes Mal die gesamte Codebase (Kosten +20%) |
| Kennt keine verbotenen Aktionen | Riskante Operationen wie direkter Produktions-DB-Zugriff |
| Kennt die Service-Abhängigkeiten nicht | Übersehene Seiteneffekte |

### Die Lösung: Ein "Gehirn" für die KI vorbereiten

```
 Sitzungsstart
┌──────────────────────────────────────────────────┐
│                                                  │
│  Liest AGENTS.md (automatisch)                   │
│       │                                          │
│       ▼                                          │
│  "Ich bin der Backend-Experte für diesen Service"│
│  "Konventionen: Conventional Commits, TypeScript │
│   strict"                                        │
│  "Verboten: andere Services modifizieren,        │
│   Secrets hardcoden"                             │
│       │                                          │
│       ▼                                          │
│  Lädt .ai-agents/context/-Dateien (5 Sekunden)   │
│  "20 APIs, 15 Entitäten, 8 Events verstanden"   │
│       │                                          │
│       ▼                                          │
│  Beginnt sofort mit der Arbeit!                  │
│                                                  │
└──────────────────────────────────────────────────┘
```

**ai-initializer** löst dieses Problem — einmal generieren, und jedes KI-Tool versteht Ihr Projekt sofort.

---

## Kernprinzip: 3-Schichten-Architektur

```
                    Ihr Projekt
                         │
            ┌────────────┼────────────┐
            ▼            ▼            ▼

     ┌──────────┐  ┌──────────┐  ┌──────────┐
     │ AGENTS.md│  │.ai-agents│  │.ai-agents│
     │          │  │ /context/ │  │ /skills/ │
     │ Identität│  │ Wissen   │  │ Verhalten│
     │ "Wer     │  │ "Was     │  │ "Wie     │
     │  bin     │  │  weiß    │  │  arbeite │
     │  ich?"   │  │  ich?"   │  │  ich?"   │
     │          │  │          │  │          │
     │ + Regeln │  │ + Domäne │  │ + Deploy │
     │ + Rechte │  │ + Modelle│  │ + Review │
     │ + Pfade  │  │          │  │          │
     └──────────┘  └──────────┘  └──────────┘
      Einstiegspunkt Wissensspeicher Workflow-Standards
```

### 1. AGENTS.md — "Wer bin ich?"

Die **Identitätsdatei** für den Agenten, der in jedem Verzeichnis eingesetzt wird.

```
project/
├── AGENTS.md                  ← PM: Der Leiter, der alles koordiniert
├── apps/
│   └── api/
│       └── AGENTS.md          ← API-Experte: Nur für diesen Service verantwortlich
├── infra/
│   ├── AGENTS.md              ← SRE: Verwaltet die gesamte Infrastruktur
│   └── monitoring/
│       └── AGENTS.md          ← Monitoring-Spezialist
└── configs/
    └── AGENTS.md              ← Konfigurationsmanager
```

Es funktioniert wie ein **Team-Organigramm**:
- Der PM überwacht alles und verteilt Aufgaben
- Jedes Teammitglied versteht nur seinen Bereich tiefgehend
- Sie bearbeiten nicht direkt die Arbeit anderer Teams — sie fordern sie an

### 2. `.ai-agents/context/` — "Was weiß ich?"

Ein Ordner, in dem **wesentliches Wissen vororganisiert ist**, damit die KI nicht jedes Mal den Code lesen muss.

```
.ai-agents/context/
├── domain-overview.md     ← "Dieser Service verwaltet Bestellungen..."
├── data-model.md          ← "Es gibt Order-, Payment-, Delivery-Entitäten..."
├── api-spec.json          ← "POST /orders, GET /orders/{id}, ..."
└── event-spec.json        ← "Veröffentlicht das order-created-Event..."
```

**Analogie:** Onboarding-Dokumentation für einen neuen Mitarbeiter. Einmal dokumentieren, und niemand muss es erneut erklären.

### 3. `.ai-agents/skills/` — "Wie arbeite ich?"

**Standardisierte Workflow-Handbücher** für wiederkehrende Aufgaben.

```
.ai-agents/skills/
├── develop/SKILL.md       ← "Feature-Entwicklung: Analysieren → Entwerfen → Implementieren → Testen → PR"
├── deploy/SKILL.md        ← "Deployment: Tag → Anfrage → Verifizieren"
└── review/SKILL.md        ← "Review: Sicherheits-, Performance-, Test-Checkliste"
```

**Analogie:** Das Betriebshandbuch des Teams — bringt die KI dazu, Regeln zu befolgen wie "diese Checkliste vor dem Einreichen eines PR prüfen."

---

## Was man schreiben sollte und was nicht

> ETH Zürich (2026.03): **Das Einbeziehen ableitbarer Inhalte senkt die Erfolgsrate und erhöht die Kosten um +20%**

```
         Das schreiben                    Das NICHT schreiben
  ┌─────────────────────────┐     ┌─────────────────────────┐
  │                         │     │                         │
  │  "Verwende feat:-Format │     │  "Quellcode ist im      │
  │   für Commits"          │     │   src/-Ordner"          │
  │  KI kann das nicht      │     │  KI kann das mit ls     │
  │  ableiten               │     │  sehen                  │
  │                         │     │                         │
  │  "Kein direkter Push    │     │  "React ist komponenten-│
  │   auf main"             │     │   basiert"              │
  │  Team-Regel, nicht im   │     │  Bereits in offizieller │
  │  Code                   │     │   Dokumentation         │
  │                         │     │                         │
  │  "QA-Team-Freigabe      │     │  "Diese Datei ist 100   │
  │   vor Deploy            │     │   Zeilen lang"          │
  │   erforderlich"         │     │  KI kann sie direkt     │
  │  Prozess, nicht         │     │   lesen                 │
  │  ableitbar              │     │                         │
  │                         │     │                         │
  └─────────────────────────┘     └─────────────────────────┘
       In AGENTS.md schreiben         NICHT schreiben!
```

**Ausnahme:** "Dinge, die ableitbar sind, aber jedes Mal zu aufwendig wären"

```
  z.B.: Vollständige API-Liste (20 Dateien müssen gelesen werden)
  z.B.: Datenmodell-Beziehungen (über 10 Dateien verteilt)
  z.B.: Inter-Service-Aufrufbeziehungen (Code + Infrastruktur müssen geprüft werden)

  → Diese in .ai-agents/context/ vororganisieren!
  → In AGENTS.md nur den Pfad schreiben: "hier nachschauen"
```

```
Aufnehmen (nicht ableitbar)        .ai-agents/context/ (aufwendig ableitbar)    Ausschließen (günstig ableitbar)
───────────────────────────        ────────────────────────────────────────      ────────────────────────────────
Team-Konventionen                  Vollständige API-Übersicht                    Verzeichnisstruktur
Verbotene Aktionen                 Datenmodell-Beziehungen                       Einzelne Dateiinhalte
PR-/Commit-Formate                 Event-Pub/Sub-Spezifikationen                 Offizielle Framework-Dokumentation
Versteckte Abhängigkeiten          Infrastruktur-Topologie                       Import-Beziehungen
```

---

## Wie es funktioniert

### Schritt 1: Projekt-Scan & Klassifizierung

Durchsucht Verzeichnisse bis zur Tiefe 3 und klassifiziert automatisch anhand von Dateimustern.

```
deployment.yaml + service.yaml  →  k8s-workload
values.yaml (Helm)              →  infra-component
package.json + *.tsx            →  frontend
go.mod                          →  backend-go
Dockerfile + CI config          →  cicd
...19 Typen automatisch erkannt
```

### Schritt 2: Kontext-Generierung

Generiert `.ai-agents/context/`-Wissensdateien durch **tatsächliche Code-Analyse** basierend auf erkannten Typen.

```
Backend-Service erkannt
  → Routen/Controller scannen → api-spec.json generieren
  → Entitäten/Schemas scannen → data-model.md generieren
  → Kafka-Konfiguration scannen → event-spec.json generieren
```

### Schritt 3: AGENTS.md-Generierung

Generiert AGENTS.md für jedes Verzeichnis unter Verwendung passender Vorlagen.

```
Root AGENTS.md (Globale Konventionen)
  → Commits: Conventional Commits
  → PR: Vorlage erforderlich, 1+ Genehmigungen
  → Branches: feature/{ticket}-{desc}
       │
       ▼ Automatisch vererbt (nicht in Kindknoten wiederholt)
  apps/api/AGENTS.md
    → Überschreibt nur: "Dieser Service verwendet Python"
```

Globale Regeln nutzen ein **Vererbungsmuster** — an einer Stelle schreiben, und es gilt automatisch für alle nachfolgenden Ebenen.

```
Root AGENTS.md ──────────────────────────────────────────
│ Globale Konventionen:
│  - Commits: Conventional Commits (feat:, fix:, chore:)
│  - PR: Vorlage erforderlich, mindestens 1 Reviewer
│  - Branch: feature/{ticket}-{desc}
│
│     Automatisch vererbt            Automatisch vererbt
│     ┌──────────────────┐       ┌──────────────────┐
│     ▼                  │       ▼                  │
│  apps/api/AGENTS.md    │    infra/AGENTS.md       │
│  (Nur zusätzliche      │    (Nur zusätzliche      │
│   Regeln angegeben)    │     Regeln angegeben)    │
│  "Dieser Service       │    "Bei Änderung von     │
│   verwendet Python"    │     Helm-Values,         │
│                        │     erst fragen"         │
└─────────────────────────┴──────────────────────────
```

**Vorteile:**
- Commit-Regeln ändern? → Nur das Root ändern
- Neuen Service hinzufügen? → Globale Regeln gelten automatisch
- Andere Regeln für einen bestimmten Service nötig? → In dessen AGENTS.md überschreiben

### Schritt 4: Vendor-spezifischer Bootstrap

Fügt Brücken zu vendor-spezifischen Konfigurationen hinzu, damit **alle KI-Tools** die generierte AGENTS.md lesen.

```
┌──────────────┐     ┌─────────────┐     ┌─────────────┐
│ Claude Code  │     │   Cursor    │     │   Codex     │
│  CLAUDE.md   │     │  .mdc rules │     │  AGENTS.md  │
│      ↓       │     │      ↓      │     │  (nativ)    │
│ "lies        │     │ "lies       │     │      ✓      │
│  AGENTS.md"  │     │  AGENTS.md" │     │             │
└──────┬───────┘     └──────┬──────┘     └─────────────┘
       └──────────┬─────────┘
                  ▼
           AGENTS.md (einzige Quelle der Wahrheit)
                  │
        ┌─────────┼─────────┐
        ▼         ▼         ▼
  .ai-agents/  .ai-agents/  .ai-agents/
   context/     skills/      roles/
```

> **Prinzip:** Bootstrap-Dateien werden nur für bereits genutzte Vendor-Tools generiert. Konfigurationsdateien für ungenutzte Tools werden niemals erstellt.

---

## Vendor-Kompatibilität

| Tool | Liest AGENTS.md automatisch | Bootstrap |
|---|---|---|
| **OpenAI Codex** | Ja (nativ) | Nicht erforderlich |
| **Claude Code** | Teilweise (Fallback) | Fügt Direktive zu `CLAUDE.md` hinzu |
| **Cursor** | Nein | Fügt `.mdc` zu `.cursor/rules/` hinzu |
| **GitHub Copilot** | Nein | Generiert `.github/copilot-instructions.md` |
| **Windsurf** | Nein | Fügt Direktive zu `.windsurfrules` hinzu |
| **Aider** | Ja | Fügt Read zu `.aider.conf.yml` hinzu |

Bootstraps automatisch generieren:
```bash
bash scripts/sync-ai-rules.sh
```

---

## Generierte Struktur

```
project-root/
├── AGENTS.md                          # PM-Agent (Gesamtkoordination)
├── .ai-agents/
│   ├── context/                       # Wissensdateien (bei Sitzungsstart geladen)
│   │   ├── domain-overview.md         #   Geschäftsdomäne, Richtlinien, Einschränkungen
│   │   ├── data-model.md             #   Entitätsdefinitionen, Beziehungen, Zustandsübergänge
│   │   ├── api-spec.json              #   API-Übersicht (JSON DSL, 3x Token-Ersparnis)
│   │   ├── event-spec.json            #   Kafka/MQ Event-Spezifikationen
│   │   ├── infra-spec.md              #   Helm Charts, Netzwerk, Deployment-Reihenfolge
│   │   └── external-integration.md    #   Externe APIs, Authentifizierung, Rate Limits
│   ├── skills/                        # Verhaltens-Workflows (bei Bedarf geladen)
│   │   ├── develop/SKILL.md           #   Entwicklung: Analysieren → Entwerfen → Implementieren → Testen → PR
│   │   ├── deploy/SKILL.md            #   Deployment: Tag → Deploy-Anfrage → Verifizieren
│   │   ├── review/SKILL.md            #   Review: Checklisten-basiert
│   │   ├── hotfix/SKILL.md            #   Notfall-Fix-Workflow
│   │   └── context-update/SKILL.md    #   Kontextdatei-Aktualisierungsprozedur
│   └── roles/                         # Rollendefinitionen (rollenspezifische Kontexttiefe)
│       ├── pm.md                      #   Projektmanager
│       ├── backend.md                 #   Backend-Entwickler
│       ├── frontend.md                #   Frontend-Entwickler
│       ├── sre.md                     #   SRE / Infrastruktur
│       └── reviewer.md               #   Code-Reviewer
│
├── apps/
│   ├── api/AGENTS.md                  # Service-spezifische Agenten
│   └── web/AGENTS.md
└── infra/
    └── helm/AGENTS.md
```

---

## Sitzungs-Launcher

Sobald alle Agenten eingerichtet sind, wählen Sie den gewünschten Agenten und starten Sie sofort eine Sitzung.

```bash
$ ./ai-agency.sh

=== KI-Agenten-Sitzungen ===
Gefunden: 8 Agent(en)

  1) [PM] project-root
  2) api-service
  3) monitoring
  ...

Agent auswählen (Nummer): 2

=== KI-Tool ===
  1) claude
  2) codex
  3) print

Tool auswählen: 1

→ Sitzung im api-service-Verzeichnis gestartet
→ Agent lädt automatisch AGENTS.md und .ai-agents/context/
→ Sofort arbeitsbereit!
```

**Parallele Ausführung (tmux):**

```bash
$ ./ai-agency.sh --multi

Agenten auswählen: 1,2,3   # PM + API + Monitoring gleichzeitig ausführen

→ 3 tmux-Sitzungen geöffnet
→ Verschiedene Agenten arbeiten unabhängig in jedem Fenster
→ Fenster wechseln mit Ctrl+B N
```

---

## Token-Optimierung

| Format | Token-Anzahl | Anmerkungen |
|---|---|---|
| API-Beschreibung in natürlicher Sprache | ~200 Tokens | |
| JSON DSL | ~70 Tokens | **3x Ersparnis** |

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

**AGENTS.md-Ziel:** Unter **300 Tokens** nach Substitution

---

## Sitzungswiederherstellungs-Protokoll

```
Sitzungsstart:
  1. AGENTS.md lesen (die meisten KI-Tools tun dies automatisch)
  2. Kontextdatei-Pfaden folgen, um .ai-agents/context/ zu laden
  3. .ai-agents/context/current-work.md prüfen (laufende Arbeit)
  4. git log --oneline -10 (aktuelle Änderungen verstehen)

Sitzungsende:
  1. Laufende Arbeit → In current-work.md festhalten
  2. Neu erlerntes Domänenwissen → Kontextdateien aktualisieren
  3. Unvollständige TODOs → Explizit festhalten
```

---

## Kontext-Wartung

Wenn sich der Code ändert, müssen `.ai-agents/context/`-Dateien entsprechend aktualisiert werden.

```
API hinzugefügt/geändert/entfernt  →  api-spec.json aktualisieren
DB-Schema geändert                  →  data-model.md aktualisieren
Event-Spezifikation geändert        →  event-spec.json aktualisieren
Geschäftsrichtlinie geändert        →  domain-overview.md aktualisieren
Externe Integration geändert        →  external-integration.md aktualisieren
Infrastruktur-Konfiguration geändert →  infra-spec.md aktualisieren
```

> Wird die Aktualisierung versäumt, arbeitet die nächste Sitzung **mit veraltetem Kontext**.

---

## Gesamtablauf-Zusammenfassung

```
┌──────────────────────────────────────────────────────────────────┐
│  1. Ersteinrichtung (einmalig)                                   │
│                                                                  │
│  KI HOW_TO_AGENTS.md lesen lassen                                │
│       │                                                          │
│       ▼                                                          │
│  KI analysiert die Projektstruktur                               │
│       │                                                          │
│       ▼                                                          │
│  Erstellt AGENTS.md in jedem        Organisiert Wissen in         │
│  Verzeichnis                        .ai-agents/context/           │
│  (Agenten-Identität + Regeln        (API-, Modell-, Event-Spez.) │
│   + Berechtigungen)                                              │
│                                                                  │
│  Definiert Workflows in             Definiert Rollen in           │
│  .ai-agents/skills/                 .ai-agents/roles/             │
│  (Entwicklungs-, Deploy-,           (Backend, Frontend, SRE)      │
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
│  Agent auswählen (PM? Backend? SRE?)                             │
│       │                                                          │
│       ▼                                                          │
│  KI-Tool auswählen (Claude? Codex? Cursor?)                      │
│       │                                                          │
│       ▼                                                          │
│  Sitzung startet → AGENTS.md automatisch geladen →                │
│  .ai-agents/context/ geladen → Arbeiten!                         │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  3. Laufende Wartung                                             │
│                                                                  │
│  Bei Code-Änderungen:                                            │
│    - KI aktualisiert automatisch .ai-agents/context/             │
│    - Oder ein Mensch weist an: "Das ist wichtig, festhalten"     │
│                                                                  │
│  Bei Hinzufügen eines neuen Services:                            │
│    - HOW_TO_AGENTS.md erneut ausführen → Neue AGENTS.md          │
│      automatisch generiert                                       │
│    - Globale Regeln werden automatisch vererbt                   │
│                                                                  │
│  Wenn die KI Fehler macht:                                       │
│    - "Analysiere das nochmal" → Hinweise geben → Sobald          │
│      verstanden, .ai-agents/context/ aktualisieren               │
│    - Diese Feedback-Schleife verbessert die Kontextqualität      │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## Analogie: Traditionelles Team vs. KI-Agenten-Team

```
              Traditionelles Dev-Team     KI-Agenten-Team
              ────────────────────────    ──────────────────
 Leiter       PM (Mensch)                 Root AGENTS.md (PM-Agent)
 Mitglieder   N Entwickler               AGENTS.md in jedem Verzeichnis
 Onboarding   Confluence/Notion          .ai-agents/context/
 Handbücher   Team-Wiki                  .ai-agents/skills/
 Rollen-Def.  Stellenbeschr./R&R-Doks    .ai-agents/roles/
 Team-Regeln  Team-Konventionsdokumente  Globale Konventionen (vererbt)
 Arbeitsbeg.  Im Büro ankommen           Sitzung startet → AGENTS.md geladen
 Arbeitsende  Gehen (Gedächtnis bleibt)  Sitzung endet (Gedächtnis verloren!)
 Nächster Tag Gedächtnis intakt          .ai-agents/context/ geladen (Gedächtnis wiederhergestellt)
```

**Wichtiger Unterschied:** Menschen behalten ihr Gedächtnis nach der Arbeit, aber KI vergisst jedes Mal alles.
Deshalb existiert `.ai-agents/context/` — es dient als **Langzeitgedächtnis** der KI.

---

## Einführungs-Checkliste

```
Phase 1 (Grundlagen)           Phase 2 (Kontext)                Phase 3 (Betrieb)
────────────────────           ──────────────────               ──────────────────
☐ AGENTS.md generieren         ☐ .ai-agents/context/ erstellen  ☐ .ai-agents/roles/ definieren
☐ Build/Test-Befehle erfassen  ☐ domain-overview.md             ☐ Multi-Agenten-Sitzungen starten
☐ Konventionen & Regeln        ☐ api-spec.json (DSL)            ☐ .ai-agents/skills/-Workflows
  erfassen                     ☐ data-model.md                  ☐ Iterative Feedback-Schleife
☐ Globale Konventionen         ☐ Wartungsregeln einrichten
☐ Vendor-Bootstraps
```

---

## Ergebnisdateien

| Datei | Zielgruppe | Zweck |
|---|---|---|
| `HOW_TO_AGENTS.md` | KI | Meta-Anleitung, die Agenten lesen und ausführen |
| `README.md` | Mensch | Dieses Dokument — ein Leitfaden für menschliches Verständnis |
| `ai-agency.sh` | Mensch | Agentenauswahl → KI-Sitzungs-Launcher |
| `AGENTS.md` (jedes Verzeichnis) | KI | Verzeichnisspezifische Agenten-Identität + Regeln |
| `.ai-agents/context/*.md/json` | KI | Vororganisiertes Domänenwissen |
| `.ai-agents/skills/*/SKILL.md` | KI | Standardisierte Arbeits-Workflows |
| `.ai-agents/roles/*.md` | KI/Mensch | Rollenspezifische Kontextlade-Strategien |

---

## Referenzen

- [Kurly OMS Team AI Workflow](https://helloworld.kurly.com/blog/oms-claude-ai-workflow/) — Inspiration für das Kontextdesign dieses Systems
- [AGENTS.md Standard](https://agents.md/) — Vendor-neutraler Agenten-Anweisungsstandard
- [ETH Zürich Forschung](https://www.infoq.com/news/2026/03/agents-context-file-value-review/) — "Nur dokumentieren, was nicht abgeleitet werden kann"

---

## Lizenz

MIT

---

<p align="center">
  <sub>Reduzieren Sie die Zeit, die KI-Agenten benötigen, um Ihr Projekt zu verstehen, auf null.</sub>
</p>
