# ai-initializer

**Automatischer Projektkontext-Generator fuer KI-Coding-Tools**

> Scannt Ihr Projektverzeichnis und generiert automatisch
> `AGENTS.md` + Wissens-/Skill-/Rollenkontext, damit KI-Agenten sofort mit der Arbeit beginnen koennen.

```
Ein Befehl → Projektanalyse → AGENTS.md-Generierung → Funktioniert mit jedem KI-Tool
```

---

## Verwendung

> **Hinweis zum Token-Verbrauch** — Beim ersten Setup analysiert ein Spitzenmodell das gesamte Projekt und generiert mehrere Dateien (AGENTS.md, .ai-agents/context/, .ai-agents/skills/, .ai-agents/roles/). Dies kann je nach Projektgroesse Zehntausende von Tokens verbrauchen. Dies ist ein einmaliger Aufwand; nachfolgende Sitzungen laden den vorgenerierten Kontext und starten sofort.

```bash
# 1. Lassen Sie die KI HOW_TO_AGENTS.md lesen — sie erledigt den Rest

# Option A: Englisch (empfohlen — geringerer Token-Verbrauch, optimale KI-Leistung)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Read HOW_TO_AGENTS.md and generate AGENTS.md tailored to this project"

# Option B: Sprache des Nutzers (empfohlen, wenn Sie AGENTS.md manuell bearbeiten moechten)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "HOW_TO_AGENTS.md를 읽고 이 프로젝트에 맞게 AGENTS.md를 생성하라"

# Empfohlen: --model claude-opus-4-6 (oder neuer) fuer beste Ergebnisse
# Empfohlen: --dangerously-skip-permissions fuer ununterbrochene autonome Ausfuehrung

# 2. Mit den generierten Agenten arbeiten
./ai-agency.sh
```

---

## Warum brauchen Sie das?

KI-Coding-Tools **lernen das Projekt jede Sitzung von Grund auf neu**.

| Problem | Konsequenz |
|---|---|
| Kennt keine Teamkonventionen | Inkonsistenzen im Code-Stil |
| Kennt nicht die vollstaendige API-Uebersicht | Durchsucht jedes Mal die gesamte Codebasis (Kosten +20%) |
| Kennt keine verbotenen Aktionen | Riskante Operationen wie direkter Produktions-DB-Zugriff |
| Kennt keine Service-Abhaengigkeiten | Uebersehene Seiteneffekte |

**ai-initializer** loest dieses Problem — einmal generieren, und jedes KI-Tool versteht Ihr Projekt sofort.

---

## Grundprinzipien

> ETH Zuerich (2026.03): **Das Einbeziehen ableitbarer Inhalte senkt die Erfolgsquote und erhoeht die Kosten um +20%**

```
Einbeziehen (nicht ableitbar)    .ai-agents/context/ (teure Ableitung)    Ausschliessen (guenstige Ableitung)
─────────────────────────────    ──────────────────────────────────────    ───────────────────────────────────
Teamkonventionen                 Vollstaendige API-Uebersicht              Verzeichnisstruktur
Verbotene Aktionen               Datenmodell-Beziehungen                   Einzelne Dateiinhalte
PR-/Commit-Formate               Event-Pub/Sub-Spezifikationen             Offizielle Framework-Dokumentation
Versteckte Abhaengigkeiten       Infrastruktur-Topologie                   Import-Beziehungen
```

---

## Generierte Struktur

```
project-root/
├── AGENTS.md                          # PM-Agent (Gesamtorchestrierung)
├── .ai-agents/
│   ├── context/                       # Wissensdateien (beim Sitzungsstart geladen)
│   │   ├── domain-overview.md         #   Geschaeftsdomaene, Richtlinien, Einschraenkungen
│   │   ├── data-model.md              #   Entitaetsdefinitionen, Beziehungen, Zustandsuebergaenge
│   │   ├── api-spec.json              #   API-Uebersicht (JSON DSL, 3x Token-Einsparung)
│   │   ├── event-spec.json            #   Kafka/MQ-Event-Spezifikationen
│   │   ├── infra-spec.md              #   Helm Charts, Netzwerk, Deployment-Reihenfolge
│   │   └── external-integration.md    #   Externe APIs, Authentifizierung, Rate Limits
│   ├── skills/                        # Verhaltens-Workflows (bei Bedarf geladen)
│   │   ├── develop/SKILL.md           #   Entwicklung: analysieren → entwerfen → implementieren → testen → PR
│   │   ├── deploy/SKILL.md            #   Deployment: taggen → Deploy-Anfrage → verifizieren
│   │   ├── review/SKILL.md            #   Review: checklistenbasiert
│   │   ├── hotfix/SKILL.md            #   Notfall-Fix-Workflow
│   │   └── context-update/SKILL.md    #   Kontextdatei-Aktualisierungsverfahren
│   └── roles/                         # Rollendefinitionen (rollenspezifische Kontexttiefe)
│       ├── pm.md                      #   Projektmanager
│       ├── backend.md                 #   Backend-Entwickler
│       ├── frontend.md                #   Frontend-Entwickler
│       ├── sre.md                     #   SRE / Infrastruktur
│       └── reviewer.md                #   Code-Reviewer
│
├── apps/
│   ├── api/AGENTS.md                  # Service-spezifische Agenten
│   └── web/AGENTS.md
└── infra/
    └── helm/AGENTS.md
```

---

## Funktionsweise

### Schritt 1: Projekt-Scan und Klassifizierung

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

Generiert `.ai-agents/context/`-Wissensdateien durch **tatsaechliche Analyse des Codes** basierend auf erkannten Typen.

```
Backend-Service erkannt
  → Routen/Controller scannen → api-spec.json generieren
  → Entitaeten/Schemas scannen → data-model.md generieren
  → Kafka-Konfiguration scannen → event-spec.json generieren
```

### Schritt 3: AGENTS.md-Generierung

Generiert AGENTS.md fuer jedes Verzeichnis unter Verwendung geeigneter Vorlagen.

```
Root AGENTS.md (Globale Konventionen)
  → Commits: Conventional Commits
  → PR: Vorlage erforderlich, 1+ Genehmigungen
  → Branches: feature/{ticket}-{desc}
       │
       ▼ Automatisch vererbt (nicht in Kindknoten wiederholt)
  apps/api/AGENTS.md
    → Ueberschreibt nur: "Dieser Service verwendet Python"
```

### Schritt 4: Herstellerspezifischer Bootstrap

Fuegt Bruecken zu herstellerspezifischen Konfigurationen hinzu, damit **alle KI-Tools** die generierte AGENTS.md lesen.

```
┌──────────────┐     ┌─────────────┐     ┌─────────────┐
│ Claude Code  │     │   Cursor    │     │   Codex     │
│  CLAUDE.md   │     │  .mdc rules │     │  AGENTS.md  │
│      ↓       │     │      ↓      │     │  (nativ)    │
│ "lese        │     │ "lese       │     │      ✓      │
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

> **Prinzip:** Bootstrap-Dateien werden nur fuer bereits verwendete Anbieter generiert. Konfigurationsdateien fuer nicht genutzte Tools werden nie erstellt.

---

## Herstellerkompatibilitaet

| Tool | Liest AGENTS.md automatisch | Bootstrap |
|---|---|---|
| **OpenAI Codex** | Ja (nativ) | Nicht noetig |
| **Claude Code** | Teilweise (Fallback) | Fuegt Direktive zu `CLAUDE.md` hinzu |
| **Cursor** | Nein | Fuegt `.mdc` zu `.cursor/rules/` hinzu |
| **GitHub Copilot** | Nein | Generiert `.github/copilot-instructions.md` |
| **Windsurf** | Nein | Fuegt Direktive zu `.windsurfrules` hinzu |
| **Aider** | Ja | Fuegt Lesebefehl zu `.aider.conf.yml` hinzu |

Bootstraps automatisch generieren:
```bash
bash scripts/sync-ai-rules.sh
```

---

## Hierarchische Agentenstruktur

```
┌───────────────────────────────────────┐
│  Root-PM-Agent (AGENTS.md)            │
│  Globale Konventionen + Delegations-  │
│  regeln                               │
│  "Design-Validierung > Code-Valid."   │
└────────┬──────────┬─────────┬────────┘
         │          │         │
    ┌────▼────┐ ┌───▼────┐ ┌──▼─────┐
    │ Service-│ │ Infra- │ │ Doku-  │
    │ Experte │ │  SRE   │ │ Planer │
    └─────────┘ └────────┘ └────────┘

Delegation:    Elternknoten → Kindknoten (arbeitet im Rahmen der AGENTS.md des jeweiligen Verzeichnisses)
Berichterstattung: Kindknoten → Elternknoten (Aenderungszusammenfassung nach Aufgabenabschluss)
Koordination:  Keine direkte Peer-to-Peer — indirekte Koordination ueber den Elternknoten
```

---

## Token-Optimierung

| Format | Token-Anzahl | Anmerkungen |
|---|---|---|
| API-Beschreibung in natuerlicher Sprache | ~200 Tokens | |
| JSON DSL | ~70 Tokens | **3x Einsparung** |

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
  1. AGENTS.md lesen (die meisten KI-Tools tun dies automatisch)
  2. Kontextdateipfaden folgen, um .ai-agents/context/ zu laden
  3. .ai-agents/context/current-work.md pruefen (laufende Arbeit)
  4. git log --oneline -10 (aktuelle Aenderungen nachvollziehen)

Sitzungsende:
  1. Laufende Arbeit → In current-work.md festhalten
  2. Neu erlerntes Domaenwissen → Kontextdateien aktualisieren
  3. Unvollstaendige TODOs → Explizit festhalten
```

---

## Kontextpflege

Wenn sich Code aendert, muessen die `.ai-agents/context/`-Dateien entsprechend aktualisiert werden.

```
API hinzugefuegt/geaendert/entfernt  →  api-spec.json aktualisieren
DB-Schema geaendert                  →  data-model.md aktualisieren
Event-Spezifikation geaendert        →  event-spec.json aktualisieren
Geschaeftsrichtlinie geaendert       →  domain-overview.md aktualisieren
Externe Integration geaendert        →  external-integration.md aktualisieren
Infrastrukturkonfiguration geaendert →  infra-spec.md aktualisieren
```

> Wird die Aktualisierung versaeumt, arbeitet die naechste Sitzung **mit veraltetem Kontext**.

---

## Einfuehrungscheckliste

```
Phase 1 (Grundlagen)               Phase 2 (Kontext)                  Phase 3 (Betrieb)
────────────────────                ─────────────────                  ─────────────────
☐ AGENTS.md generieren              ☐ .ai-agents/context/ erstellen    ☐ .ai-agents/roles/ definieren
☐ Build-/Testbefehle festhalten     ☐ domain-overview.md               ☐ Multi-Agenten-Sitzungen ausfuehren
☐ Konventionen & Regeln festhalten  ☐ api-spec.json (DSL)              ☐ .ai-agents/skills/ Workflows
☐ Globale Konventionen              ☐ data-model.md                    ☐ Iterative Feedbackschleife
☐ Hersteller-Bootstraps             ☐ Wartungsregeln einrichten
```

---

## Lizenz

MIT

---

<p align="center">
  <sub>Reduzieren Sie die Zeit, die KI-Agenten brauchen, um Ihr Projekt zu verstehen, auf null.</sub>
</p>
