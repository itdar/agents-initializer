# Système de gestion des agents IA — Guide pour les humains

## Comment commencer ?

> **Avertissement : Consommation élevée de tokens** — La configuration initiale utilise un modèle de haut niveau pour analyser l'ensemble du projet et générer plusieurs fichiers (AGENTS.md, .ai-agents/context/, .ai-agents/skills/, .ai-agents/roles/). Prévoyez une consommation significative de tokens (des dizaines de milliers ou plus selon la taille du projet). C'est un coût unique — les sessions suivantes chargent le contexte préconstruit et démarrent instantanément.

```bash
# 1. Faites lire HOW_TO_AGENTS.md à l'IA, elle se configure automatiquement

# Option A : Anglais (recommandé — coût de tokens réduit, meilleures performances IA)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Read HOW_TO_AGENTS.md and generate AGENTS.md tailored to this project"

# Option B : Votre langue (recommandé si les humains éditent AGENTS.md directement)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Lis HOW_TO_AGENTS.md et génère un AGENTS.md adapté à ce projet (en français)"

# Recommandé : --dangerously-skip-permissions pour une configuration autonome sans interruption
# Recommandé : --model claude-opus-4-6 (ou ultérieur) pour de meilleurs résultats

# 2. Commencez à travailler avec l'agent généré
./ai-agency.sh

# 3. À partir des sessions suivantes, le travail peut commencer immédiatement !
```

> Ce document est destiné à **être lu et compris par les humains**.
> Il explique pourquoi le guide d'instructions exécuté par l'IA (HOW_TO_AGENTS.md) existe,
> comment il fonctionne et quel rôle il joue dans votre flux de travail de développement.

---

## Pourquoi un tel système est-il nécessaire ?

### Problème : l'IA perd la mémoire à chaque session

```
 Session 1                  Session 2                  Session 3
┌──────────┐             ┌──────────┐             ┌──────────┐
│ L'IA lit  │             │ L'IA relit│             │ Encore    │
│ tout le   │  Fin de     │ tout le   │  Fin de     │ depuis le │
│ code      │  session    │ code      │  session    │ début     │
│ (30 min)  │ ──────→    │ (30 min)  │ ──────→    │ (30 min)  │
│ Début du  │ Mémoire    │ Début du  │ Mémoire    │ Début du  │
│ travail   │ perdue !   │ travail   │ perdue !   │ travail   │
└──────────┘             └──────────┘             └──────────┘
```

Les agents IA oublient tout à la fin de chaque session.
Ils passent du temps à chaque fois à comprendre la structure du projet, analyser les API et assimiler les conventions.

### Solution : préparer un "cerveau" pour l'IA à l'avance

```
 Début de session
┌──────────────────────────────────────────────────┐
│                                                  │
│  Lecture de AGENTS.md (automatique)               │
│       │                                          │
│       ▼                                          │
│  "Je suis l'expert backend de doppel-api"         │
│  "Conventions : Conventional Commits, TypeScript strict" │
│  "Interdit : modifier d'autres services, coder les secrets en dur" │
│       │                                          │
│       ▼                                          │
│  Chargement des fichiers .ai-agents/context/ (5 sec)     │
│  "20 API, 15 entités, 8 événements identifiés"    │
│       │                                          │
│       ▼                                          │
│  Début immédiat du travail !                      │
│                                                  │
└──────────────────────────────────────────────────┘
```

---

## Principe fondamental : architecture à 3 couches

```
                    Votre projet
                         │
            ┌────────────┼────────────┐
            ▼            ▼            ▼

     ┌──────────┐  ┌──────────┐  ┌──────────┐
     │ AGENTS.md│  │.ai-agents/context│  │.ai-agents/skills│
     │          │  │          │  │          │
     │ Identité │  │ Savoir   │  │ Actions  │
     │ "Qui     │  │ "Les API │  │ "Pour    │
     │  suis-je"│  │  de ce   │  │  développer│
     │          │  │  service │  │  il faut  │
     │ + Règles │  │  sont    │  │  faire    │
     │ + Droits │  │  celles- │  │  ainsi"   │
     │ + Chemins│  │  ci"     │  │          │
     └──────────┘  └──────────┘  └──────────┘
     Point d'entrée  Stockage      Standards de
                     mémoire       workflow
```

### 1. AGENTS.md — "Qui suis-je"

C'est le **fichier d'identité** de l'agent placé dans chaque répertoire.

```
projet/
├── AGENTS.md                  ← PM : le leader qui coordonne l'ensemble
├── apps/
│   └── doppel-api/
│       └── AGENTS.md          ← Expert API : responsable uniquement de ce service
├── infra/
│   ├── AGENTS.md              ← SRE : gestion de toute l'infrastructure
│   └── monitoring/
│       └── AGENTS.md          ← Expert monitoring
└── configs/
    └── AGENTS.md              ← Gestionnaire de configuration
```

C'est comme un **organigramme d'équipe** :
- Le PM supervise l'ensemble et distribue les tâches
- Chaque membre comprend en profondeur uniquement son domaine
- On ne fait pas le travail d'une autre équipe, on le demande

### 2. `.ai-agents/context/` — "Ce que je sais"

Un dossier qui **pré-organise les connaissances essentielles** pour que l'IA n'ait pas à relire le code à chaque fois.

```
.ai-agents/context/
├── domain-overview.md     ← "Ce service gère les commandes..."
├── data-model.md          ← "Il y a les entités Order, Payment, Delivery..."
├── api-spec.json          ← "POST /orders, GET /orders/{id}, ..."
└── event-spec.json        ← "Publie l'événement order-created..."
```

**Analogie :** C'est comme le document d'intégration donné à un nouveau collaborateur.
"Ce que fait notre équipe, la structure de la BDD, les API disponibles" — une fois rédigé,
plus besoin de le réexpliquer à chaque fois.

### 3. `.ai-agents/skills/` — "Comment je travaille"

Des **manuels de workflow standardisés** pour les tâches répétitives.

```
.ai-agents/skills/
├── develop/SKILL.md       ← "Développement : analyse → conception → implémentation → tests → PR"
├── deploy/SKILL.md        ← "Déploiement : tag → demande → vérification"
└── review/SKILL.md        ← "Revue : checklist sécurité · performance · tests"
```

**Analogie :** C'est le manuel opérationnel de l'équipe.
"Quand tu crées une PR, vérifie cette checklist" — l'IA suit les mêmes règles.

---

## Comment gérer les règles globales ?

On utilise un **modèle d'héritage**. On écrit à un seul endroit, et cela s'applique automatiquement en cascade.

```
AGENTS.md racine ──────────────────────────────────────────
│ Global Conventions:
│  - Commits : Conventional Commits (feat:, fix:, chore:)
│  - PR : template obligatoire, au moins 1 reviewer
│  - Branches : feature/{ticket}-{desc}
│  - Code : TypeScript strict, single quotes
│
│     Héritage auto                 Héritage auto
│     ┌──────────────────┐       ┌──────────────────┐
│     ▼                  │       ▼                  │
│  apps/api/AGENTS.md    │    infra/AGENTS.md       │
│  (seules les règles    │    (seules les règles    │
│   additionnelles)      │     additionnelles)      │
│  "Ce service utilise   │    "Pour les modifs      │
│   Python"              │     Helm values :        │
│  (au lieu de TypeScript)│     Ask First"           │
└─────────────────────────┴──────────────────────────
```

**Avantages :**
- Envie de changer les règles de commit ? → Modifier un seul endroit à la racine
- Ajout d'un nouveau service ? → Les règles globales s'appliquent automatiquement
- Un service doit être différent ? → Override dans le AGENTS.md de ce service

---

## Que faut-il écrire, et que faut-il éviter ?

Selon une étude de l'ETH Zurich (2026), écrire dans la documentation ce que l'IA peut déjà déduire
**réduit le taux de réussite et augmente les coûts de 20 %**.

```
              À écrire                            À ne pas écrire
     ┌─────────────────────────┐     ┌─────────────────────────┐
     │                         │     │                         │
     │  "Commits au format     │     │  "Les sources sont      │
     │   feat:"                │     │   dans src/"            │
     │  L'IA ne peut pas       │     │  L'IA peut le voir      │
     │  le deviner             │     │  avec ls                │
     │                         │     │                         │
     │  "Push direct sur main  │     │  "React est basé sur    │
     │   interdit"             │     │   les composants"       │
     │  Règle d'équipe absente │     │  Déjà dans la doc       │
     │  du code                │     │  officielle             │
     │                         │     │                         │
     │  "Approbation QA        │     │  "Ce fichier fait       │
     │   obligatoire avant     │     │   100 lignes"           │
     │   déploiement"          │     │  L'IA peut le lire      │
     │  Processus impossible   │     │  elle-même              │
     │  à déduire              │     │                         │
     └─────────────────────────┘     └─────────────────────────┘
          À inscrire dans                    Ne pas inscrire !
            AGENTS.md
```

**Cependant, il y a des exceptions :** "Ce qui est déductible mais trop coûteux à recalculer à chaque fois"

```
  Ex : Liste complète des API (il faut lire 20 fichiers pour la reconstituer)
  Ex : Schéma des relations du modèle de données (dispersé dans 10 fichiers)
  Ex : Relations d'appels entre services (nécessite de vérifier le code + l'infra)

  → Ce type d'information se pré-organise dans .ai-agents/context/ !
  → Dans AGENTS.md, on note simplement le chemin : "c'est ici"
```

---

## Script de lancement de session

Une fois tous les agents configurés, vous pouvez choisir l'agent souhaité et démarrer une session immédiatement.

```bash
$ ./ai-agency.sh

=== AI Agent Sessions ===
Project: /Users/nhn/src/doppel-deploy
Found: 8 agent(s)

  1) [PM] doppel-deploy
     Path: ./AGENTS.md
     Agent PM de ce projet. Comprend la structure globale et délègue les tâches.

  2) doppel-api
     Path: apps/dev/doppel-api/AGENTS.md
     Expert en gestion des manifestes K8s du service doppel-api.

  3) monitoring
     Path: infra/monitoring/AGENTS.md
     Expert SRE de la stack de monitoring Prometheus + Grafana.

  ...

Select agent (number): 2

=== AI Tool ===
  1) claude
  2) codex
  3) print

Select tool: 1

→ Session claude démarrée dans le répertoire doppel-api
→ L'agent charge automatiquement AGENTS.md et .ai-agents/context/
→ Prêt à travailler immédiatement !
```

**Exécution parallèle (tmux) :**

```bash
$ ./ai-agency.sh --multi

Select agents: 1,2,3   # PM + API + Monitoring en simultané

→ 3 sessions tmux s'ouvrent
→ Dans chaque fenêtre, un agent différent travaille de manière indépendante
→ Ctrl+B N pour changer de fenêtre
```

---

## Résumé du flux complet

```
┌──────────────────────────────────────────────────────────────────┐
│  1. Configuration initiale (une seule fois)                       │
│                                                                  │
│  Faire lire HOW_TO_AGENTS.md à l'IA                               │
│       │                                                          │
│       ▼                                                          │
│  L'IA analyse la structure du projet                              │
│       │                                                          │
│       ▼                                                          │
│  Génération de AGENTS.md dans       Organisation des              │
│  chaque répertoire                  connaissances .ai-agents/context/    │
│  (identité + règles + droits)       (API, modèles, spéc. événements) │
│                                                                  │
│  Définition des workflows           Définition des rôles          │
│  .ai-agents/skills/                        .ai-agents/roles/                    │
│  (développement, déploiement, revue) (Backend, Frontend, SRE)     │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  2. Utilisation quotidienne                                       │
│                                                                  │
│  Exécuter ./ai-agency.sh                                   │
│       │                                                          │
│       ▼                                                          │
│  Sélection de l'agent (PM ? Backend ? SRE ?)                     │
│       │                                                          │
│       ▼                                                          │
│  Sélection de l'outil IA (Claude ? Codex ? Cursor ?)              │
│       │                                                          │
│       ▼                                                          │
│  Début de session → Chargement auto de AGENTS.md → Chargement    │
│  de .ai-agents/context/ → Au travail !                                   │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  3. Maintenance continue                                          │
│                                                                  │
│  Lors de modifications du code :                                  │
│    - L'IA met à jour .ai-agents/context/ automatiquement                 │
│      (règle spécifiée dans AGENTS.md)                             │
│    - Ou l'humain donne l'instruction "c'est important, note-le"   │
│                                                                  │
│  Lors de l'ajout d'un nouveau service :                           │
│    - Relancer HOW_TO_AGENTS.md → Génération auto d'un nouveau     │
│      AGENTS.md                                                    │
│    - Héritage automatique des règles globales                     │
│                                                                  │
│  Quand l'IA se trompe :                                           │
│    - "Réanalyse" → fournir des indices → une fois compris,        │
│      mise à jour de .ai-agents/context/                                  │
│    - Cette boucle de feedback améliore la qualité du contexte     │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## Liste des livrables

Les fichiers produits par ce système et leurs usages respectifs :

| Fichier | Cible | Usage |
|---|---|---|
| `HOW_TO_AGENTS.md` | IA | Méta-instructions lues et exécutées par l'agent |
| `HOW_TO_AGENTS_PLAN.md` | Humain/IA | Document de conception (contexte et justification de l'architecture) |
| `README.md` | Humain | Ce document. Guide de compréhension pour les humains |
| `ai-agency.sh` | Humain | Lanceur : sélection d'agent → démarrage de session IA |
| `AGENTS.md` (chaque répertoire) | IA | Identité de l'agent + règles par répertoire |
| `.ai-agents/context/*.md/json` | IA | Connaissances du domaine pré-organisées |
| `.ai-agents/skills/*/SKILL.md` | IA | Workflows de travail standardisés |
| `.ai-agents/roles/*.md` | IA/Humain | Stratégie de chargement de contexte par rôle |

---

## Analogie essentielle

```
              Équipe de dev               Équipe d'agents IA
              traditionnelle
              ────────────────           ────────────────────
 Leader       PM (humain)                AGENTS.md racine (agent PM)
 Membres      N développeurs             AGENTS.md de chaque répertoire
 Doc intégr.  Confluence/Notion          .ai-agents/context/
 Manuel ops   Wiki d'équipe              .ai-agents/skills/
 Déf. rôles   Fiches de poste/R&R        .ai-agents/roles/
 Règles       Conventions d'équipe       Global Conventions (héritage)
 Arrivée      Arrivée au bureau          Début de session → Chargement AGENTS.md
 Départ       Départ (mémoire conservée) Fin de session (mémoire perdue !)
 Lendemain    Mémoire intacte            Chargement .ai-agents/context/ (mémoire restaurée)
```

**Différence fondamentale :** les humains conservent leur mémoire en quittant le bureau, mais l'IA oublie tout à chaque fois.
C'est pourquoi `.ai-agents/context/` existe — il joue le rôle de **mémoire à long terme** pour l'IA.

---

## Références

- [Workflow IA de l'équipe OMS de Kurly](https://helloworld.kurly.com/blog/oms-claude-ai-workflow/) — Inspiration pour la conception du contexte de ce système
- [Standard AGENTS.md](https://agents.md/) — Standard d'instructions pour agents, indépendant du fournisseur
- [Étude de l'ETH Zurich](https://www.infoq.com/news/2026/03/agents-context-file-value-review/) — "Ne documentez que ce qui ne peut pas être déduit"
