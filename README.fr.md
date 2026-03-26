# ai-initializer

**Generateur automatique de contexte projet pour les outils de codage IA**

> Analyse le repertoire de votre projet et genere automatiquement
> `AGENTS.md` + des fichiers de contexte (connaissances/competences/roles) pour que les agents IA puissent travailler immediatement.

```
Une commande → Analyse du projet → Generation d'AGENTS.md → Compatible avec tout outil IA
```

---

## Utilisation

> **Avis sur la consommation de tokens** — Lors de la configuration initiale, un modele de premier plan analyse l'ensemble du projet et genere plusieurs fichiers (AGENTS.md, .ai-agents/context/, .ai-agents/skills/, .ai-agents/roles/). Cela peut consommer des dizaines de milliers de tokens selon la taille du projet. Il s'agit d'un cout unique ; les sessions suivantes chargent le contexte pre-construit et demarrent instantanement.

```bash
# 1. Faites lire HOW_TO_AGENTS.md a l'IA et elle s'occupe du reste

# Option A : Anglais (recommande — cout en tokens reduit, performances IA optimales)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Read HOW_TO_AGENTS.md and generate AGENTS.md tailored to this project"

# Option B : Langue de l'utilisateur (recommande si vous prevoyez de modifier AGENTS.md manuellement)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Lis HOW_TO_AGENTS.md et genere un AGENTS.md adapte a ce projet"

# Recommande : --model claude-opus-4-6 (ou ulterieur) pour de meilleurs resultats
# Recommande : --dangerously-skip-permissions pour une execution autonome sans interruption

# 2. Commencez a travailler avec les agents generes
./ai-agency.sh
```

---

## Pourquoi en avez-vous besoin ?

Les outils de codage IA **reapprennent le projet de zero** a chaque session.

| Probleme | Consequence |
|---|---|
| Ne connait pas les conventions de l'equipe | Incoherences de style de code |
| Ne connait pas la carte complete des API | Explore l'ensemble du code a chaque fois (cout +20%) |
| Ne connait pas les actions interdites | Operations risquees comme l'acces direct a la base de donnees de production |
| Ne connait pas les dependances entre services | Effets de bord non detectes |

**ai-initializer** resout ce probleme — generez une seule fois, et tout outil IA comprend votre projet instantanement.

---

## Principes fondamentaux

> ETH Zurich (2026.03) : **Inclure du contenu inferable reduit les taux de reussite et augmente le cout de +20%**

```
Inclure (non inferable)            .ai-agents/context/ (inference couteuse)    Exclure (inference peu couteuse)
───────────────────────            ────────────────────────────────────         ────────────────────────────────
Conventions de l'equipe            Carte complete des API                      Structure des repertoires
Actions interdites                 Relations du modele de donnees              Contenu de fichiers individuels
Formats PR/commit                  Specs pub/sub d'evenements                  Documentation officielle du framework
Dependances cachees                Topologie de l'infrastructure               Relations d'import
```

---

## Structure generee

```
project-root/
├── AGENTS.md                          # Agent PM (orchestration globale)
├── .ai-agents/
│   ├── context/                       # Fichiers de connaissances (charges au demarrage de session)
│   │   ├── domain-overview.md         #   Domaine metier, politiques, contraintes
│   │   ├── data-model.md              #   Definitions d'entites, relations, transitions d'etat
│   │   ├── api-spec.json              #   Carte des API (JSON DSL, 3x d'economie de tokens)
│   │   ├── event-spec.json            #   Specifications d'evenements Kafka/MQ
│   │   ├── infra-spec.md              #   Charts Helm, reseau, ordre de deploiement
│   │   └── external-integration.md    #   API externes, authentification, limites de debit
│   ├── skills/                        # Workflows comportementaux (charges a la demande)
│   │   ├── develop/SKILL.md           #   Dev : analyser → concevoir → implementer → tester → PR
│   │   ├── deploy/SKILL.md            #   Deploiement : tag → demande de deploiement → verification
│   │   ├── review/SKILL.md            #   Revue : basee sur une checklist
│   │   ├── hotfix/SKILL.md            #   Workflow de correctif d'urgence
│   │   └── context-update/SKILL.md    #   Procedure de mise a jour des fichiers de contexte
│   └── roles/                         # Definitions de roles (profondeur de contexte specifique au role)
│       ├── pm.md                      #   Chef de projet
│       ├── backend.md                 #   Developpeur Backend
│       ├── frontend.md                #   Developpeur Frontend
│       ├── sre.md                     #   SRE / Infrastructure
│       └── reviewer.md                #   Relecteur de code
│
├── apps/
│   ├── api/AGENTS.md                  # Agents par service
│   └── web/AGENTS.md
└── infra/
    └── helm/AGENTS.md
```

---

## Comment ca fonctionne

### Etape 1 : Scan et classification du projet

Explore les repertoires jusqu'a une profondeur de 3 et classifie automatiquement selon les patterns de fichiers.

```
deployment.yaml + service.yaml  →  k8s-workload
values.yaml (Helm)              →  infra-component
package.json + *.tsx            →  frontend
go.mod                          →  backend-go
Dockerfile + CI config          →  cicd
...19 types detectes automatiquement
```

### Etape 2 : Generation du contexte

Genere les fichiers de connaissances `.ai-agents/context/` en **analysant reellement le code** en fonction des types detectes.

```
Service backend detecte
  → Scan routes/controllers → Generer api-spec.json
  → Scan entites/schemas   → Generer data-model.md
  → Scan config Kafka      → Generer event-spec.json
```

### Etape 3 : Generation d'AGENTS.md

Genere un AGENTS.md pour chaque repertoire en utilisant les templates appropries.

```
AGENTS.md racine (Conventions globales)
  → Commits : Conventional Commits
  → PR : Template requis, 1+ approbations
  → Branches : feature/{ticket}-{desc}
       │
       ▼ Heritage automatique (non repete dans les enfants)
  apps/api/AGENTS.md
    → Surcharges uniquement : "Ce service utilise Python"
```

### Etape 4 : Bootstrap specifique aux editeurs

Ajoute des passerelles vers les configurations specifiques aux editeurs pour que **tous les outils IA lisent** le AGENTS.md genere.

```
┌──────────────┐     ┌─────────────┐     ┌─────────────┐
│ Claude Code  │     │   Cursor    │     │   Codex     │
│  CLAUDE.md   │     │  .mdc rules │     │  AGENTS.md  │
│      ↓       │     │      ↓      │     │  (natif)    │
│ "lire        │     │ "lire       │     │      ✓      │
│  AGENTS.md"  │     │  AGENTS.md" │     │             │
└──────┬───────┘     └──────┬──────┘     └─────────────┘
       └──────────┬─────────┘
                  ▼
           AGENTS.md (source unique de verite)
                  │
        ┌─────────┼─────────┐
        ▼         ▼         ▼
  .ai-agents/  .ai-agents/  .ai-agents/
   context/     skills/      roles/
```

> **Principe :** Les fichiers de bootstrap ne sont generes que pour les editeurs deja utilises. Les fichiers de configuration pour les outils non utilises ne sont jamais crees.

---

## Compatibilite des editeurs

| Outil | Lecture automatique d'AGENTS.md | Bootstrap |
|---|---|---|
| **OpenAI Codex** | Oui (natif) | Non necessaire |
| **Claude Code** | Partiel (fallback) | Ajoute une directive dans `CLAUDE.md` |
| **Cursor** | Non | Ajoute un `.mdc` dans `.cursor/rules/` |
| **GitHub Copilot** | Non | Genere `.github/copilot-instructions.md` |
| **Windsurf** | Non | Ajoute une directive dans `.windsurfrules` |
| **Aider** | Oui | Ajoute une lecture dans `.aider.conf.yml` |

Generation automatique des bootstraps :
```bash
bash scripts/sync-ai-rules.sh
```

---

## Structure hierarchique des agents

```
┌───────────────────────────────────────┐
│  Agent PM racine (AGENTS.md)          │
│  Conventions globales + Regles de     │
│  delegation                           │
│  "Validation de conception > Code"    │
└────────┬──────────┬─────────┬────────┘
         │          │         │
    ┌────▼────┐ ┌───▼────┐ ┌──▼─────┐
    │ Expert  │ │ Infra  │ │  Docs  │
    │ Service │ │  SRE   │ │Planif. │
    └─────────┘ └────────┘ └────────┘

Delegation :    Parent → Enfant (opere dans le perimetre AGENTS.md de ce repertoire)
Rapport :       Enfant → Parent (resume des modifications apres achevement de la tache)
Coordination :  Pas de pair-a-pair direct — coordination indirecte via le parent
```

---

## Optimisation des tokens

| Format | Nombre de tokens | Notes |
|---|---|---|
| Description d'API en langage naturel | ~200 tokens | |
| JSON DSL | ~70 tokens | **3x d'economie** |

**Exemple api-spec.json :**
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

**Objectif AGENTS.md :** Moins de **300 tokens** apres substitution

---

## Protocole de restauration de session

```
Debut de session :
  1. Lire AGENTS.md (la plupart des outils IA le font automatiquement)
  2. Suivre les chemins des fichiers de contexte pour charger .ai-agents/context/
  3. Verifier .ai-agents/context/current-work.md (travail en cours)
  4. git log --oneline -10 (comprendre les changements recents)

Fin de session :
  1. Travail en cours → Enregistrer dans current-work.md
  2. Connaissances metier nouvellement acquises → Mettre a jour les fichiers de contexte
  3. TODOs incomplets → Enregistrer explicitement
```

---

## Maintenance du contexte

Lorsque le code change, les fichiers `.ai-agents/context/` doivent etre mis a jour en consequence.

```
API ajoutee/modifiee/supprimee       →  Mettre a jour api-spec.json
Schema de BDD modifie                →  Mettre a jour data-model.md
Specification d'evenement modifiee   →  Mettre a jour event-spec.json
Politique metier modifiee            →  Mettre a jour domain-overview.md
Integration externe modifiee         →  Mettre a jour external-integration.md
Configuration d'infrastructure       →  Mettre a jour infra-spec.md
modifiee
```

> Ne pas mettre a jour signifie que la prochaine session **travaillera avec un contexte obsolete**.

---

## Checklist d'adoption

```
Phase 1 (Bases)                    Phase 2 (Contexte)                   Phase 3 (Operations)
────────────────                   ─────────────────                    ────────────────────
☐ Generer AGENTS.md                ☐ Creer .ai-agents/context/          ☐ Definir .ai-agents/roles/
☐ Enregistrer les commandes        ☐ domain-overview.md                 ☐ Lancer des sessions multi-agents
  build/test                       ☐ api-spec.json (DSL)                ☐ Workflows .ai-agents/skills/
☐ Enregistrer conventions          ☐ data-model.md                      ☐ Boucle de retour iterative
  et regles                        ☐ Mettre en place les regles
☐ Conventions globales               de maintenance
☐ Bootstraps des editeurs
```

---

## Licence

MIT

---

<p align="center">
  <sub>Reduisez a zero le temps necessaire aux agents IA pour comprendre votre projet.</sub>
</p>
