🌐 [English](../README.md) | [한국어](README_ko.md) | [日本語](README_ja.md) | [中文](README_zh.md) | [Español](README_es.md) | [Français](README_fr.md) | [Deutsch](README_de.md) | [Русский](README_ru.md) | [हिन्दी](README_hi.md) | [العربية](README_ar.md)

<div align="center">

# ai-initializer

**Une commande pour donner à tout agent IA une compréhension instantanée du projet.**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](../LICENSE)

</div>

---

## Essayez Maintenant

Ce dépôt inclut des fichiers `AGENTS.md` et `.ai-agents/` préconstruits comme exemple fonctionnel.
Clonez et exécutez `ai-agency.sh` immédiatement pour le voir en action :

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

## Appliquer à Votre Projet

> **Important :** Copiez `setup.sh` et `HOW_TO_AGENTS.md` dans le répertoire de votre propre projet avant de commencer.

```bash
# Copier les fichiers nécessaires dans votre projet
cp /chemin/vers/agents-initializer/setup.sh votre-projet/
cp /chemin/vers/agents-initializer/HOW_TO_AGENTS.md votre-projet/

# Se rendre dans votre projet
cd votre-projet

# Lancer la configuration initiale (analyse + génération de AGENTS.md)
./setup.sh

# Démarrer une session agent
./ai-agency.sh
```

<details>
<summary>Configuration manuelle (sans setup.sh)</summary>

> **Avis sur la consommation de tokens** — Lors de la configuration initiale, un modèle de premier plan analyse l'intégralité du projet et génère plusieurs fichiers (AGENTS.md, .ai-agents/context/, .ai-agents/skills/, .ai-agents/roles/). Cela peut consommer des dizaines de milliers de tokens selon la taille du projet. Il s'agit d'un coût unique ; les sessions suivantes chargent le contexte pré-construit et démarrent instantanément.

```bash
# 1. Demandez à l'IA de lire HOW_TO_AGENTS.md et elle s'occupe du reste

# Option A : Anglais (recommandé — coût en tokens plus faible, performances IA optimales)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Read HOW_TO_AGENTS.md and generate AGENTS.md tailored to this project"

# Option B : Langue de l'utilisateur (recommandé si vous prévoyez de modifier AGENTS.md manuellement)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Lis HOW_TO_AGENTS.md et génère un AGENTS.md adapté à ce projet"

# Recommandé : --model claude-opus-4-6 (ou ultérieur) pour de meilleurs résultats
# Recommandé : --dangerously-skip-permissions pour une exécution autonome sans interruption

# 2. Commencez à travailler avec les agents générés
./ai-agency.sh
```

</details>

---

## Pourquoi en avez-vous besoin ?

### Le problème : l'IA perd sa mémoire à chaque session

```
 Session 1                    Session 2                    Session 3
┌────────────┐             ┌────────────┐             ┌────────────┐
│ L'IA lit   │             │ L'IA lit   │             │ Repart     │
│ tout le    │  Session    │ tout le    │  Session    │ de zéro    │
│ code       │  terminée   │ code       │  terminée   │            │
│ (30 min)   │ ──────→     │ (30 min)   │ ──────→     │ (30 min)   │
│ Commence   │ Mémoire     │ Commence   │ Mémoire     │ Commence   │
│ à          │ perdue !    │ à          │ perdue !    │ à          │
│ travailler │             │ travailler │             │ travailler │
└────────────┘             └────────────┘             └────────────┘
```

Les agents IA oublient tout à la fin d'une session. À chaque fois, ils passent du temps à comprendre la structure du projet, analyser les API et apprendre les conventions.

| Problème | Conséquence |
|---|---|
| Ne connaît pas les conventions de l'équipe | Incohérences dans le style de code |
| Ne connaît pas la carte complète des API | Explore toute la base de code à chaque fois (coût +20%) |
| Ne connaît pas les actions interdites | Opérations risquées comme l'accès direct à la DB de production |
| Ne connaît pas les dépendances entre services | Effets secondaires manqués |

### La solution : pré-construire un « cerveau » pour l'IA

```
 Début de session
┌──────────────────────────────────────────────────┐
│                                                  │
│  Lit AGENTS.md (automatique)                     │
│       │                                          │
│       ▼                                          │
│  « Je suis l'expert backend de ce service »      │
│  « Conventions : Conventional Commits,           │
│   TypeScript strict »                            │
│  « Interdit : modifier d'autres services,        │
│   coder des secrets en dur »                     │
│       │                                          │
│       ▼                                          │
│  Charge les fichiers .ai-agents/context/ (5 s)   │
│  « 20 API, 15 entités, 8 événements compris »    │
│       │                                          │
│       ▼                                          │
│  Commence à travailler immédiatement !           │
│                                                  │
└──────────────────────────────────────────────────┘
```

**ai-initializer** résout ce problème — générez une fois, et n'importe quel outil IA comprend instantanément votre projet.

---

## Principe fondamental : architecture à 3 couches

```
                    Votre projet
                         │
            ┌────────────┼────────────┐
            ▼            ▼            ▼

     ┌──────────┐  ┌──────────┐  ┌──────────┐
     │ AGENTS.md│  │.ai-agents│  │.ai-agents│
     │          │  │ /context/│  │ /skills/ │
     │ Identité │  │ Connais- │  │Comportem.│
     │ « Qui    │  │ sances   │  │ « Comment│
     │  suis-je?│  │ « Que    │  │  est-ce  │
     │        » │  │  sais-je?│  │  que je  │
     │ + Règles │  │        » │  │ travaille│
     │ + Perms  │  │ + Domaine│  │        » │
     │ + Chemins│  │ + Modèles│  │ + Déploie│
     └──────────┘  └──────────┘  └──────────┘
      Point d'entrée  Mémoire     Standards de travail
```

### 1. AGENTS.md — « Qui suis-je ? »

Le **fichier d'identité** de l'agent déployé dans chaque répertoire.

```
project/
├── AGENTS.md                  ← PM : le chef qui coordonne tout
├── apps/
│   └── api/
│       └── AGENTS.md          ← Expert API : responsable de ce service uniquement
├── infra/
│   ├── AGENTS.md              ← SRE : gère toute l'infrastructure
│   └── monitoring/
│       └── AGENTS.md          ← Spécialiste du monitoring
└── configs/
    └── AGENTS.md              ← Gestionnaire de configuration
```

Cela fonctionne exactement comme un **organigramme d'équipe** :
- Le PM supervise tout et distribue les tâches
- Chaque membre de l'équipe comprend profondément uniquement son domaine
- Ils ne gèrent pas directement le travail des autres équipes — ils le demandent

### 2. `.ai-agents/context/` — « Que sais-je ? »

Un dossier où les **connaissances essentielles sont pré-organisées** afin que l'IA n'ait pas à lire le code à chaque fois.

```
.ai-agents/context/
├── domain-overview.md     ← « Ce service gère la gestion des commandes... »
├── data-model.md          ← « Il y a les entités Order, Payment, Delivery... »
├── api-spec.json          ← « POST /orders, GET /orders/{id}, ... »
└── event-spec.json        ← « Publie l'événement order-created... »
```

**Analogie :** Documentation d'intégration pour un nouvel employé. Documentez-le une fois et personne n'a plus besoin de l'expliquer.

### 3. `.ai-agents/skills/` — « Comment est-ce que je travaille ? »

**Manuels de flux de travail standardisés** pour les tâches répétitives.

```
.ai-agents/skills/
├── develop/SKILL.md       ← « Dev fonctionnalité : Analyser → Concevoir → Implémenter → Tester → PR »
├── deploy/SKILL.md        ← « Déploiement : Tag → Demande → Vérification »
└── review/SKILL.md        ← « Revue : Sécurité, Performance, checklist de tests »
```

**Analogie :** Le manuel opérationnel de l'équipe — amène l'IA à respecter des règles comme « vérifier cette checklist avant de soumettre une PR ».

---

## Ce qu'il faut écrire et ce qu'il ne faut pas écrire

> ETH Zurich (2026.03) : **Inclure du contenu inférable réduit les taux de succès et augmente le coût de +20%**

```
         Écrire ceci                        Ne pas écrire ceci
  ┌─────────────────────────┐     ┌─────────────────────────┐
  │                         │     │                         │
  │  « Utiliser le format   │     │  « Le code source est   │
  │   feat: pour les        │     │   dans le dossier src/» │
  │   commits »             │     │  L'IA peut le voir avec │
  │  L'IA ne peut pas       │     │  ls                     │
  │  inférer cela           │     │                         │
  │                         │     │  « React est basé sur   │
  │  « Pas de push direct   │     │   des composants »      │
  │   sur main »            │     │  Déjà dans la           │
  │  Règle d'équipe,        │     │  documentation          │
  │  pas dans le code       │     │  officielle             │
  │                         │     │                         │
  │  « Approbation de       │     │  « Ce fichier fait      │
  │   l'équipe QA requise   │     │   100 lignes »          │
  │   avant le déploiement» │     │  L'IA peut le lire      │
  │  Processus, non         │     │  directement            │
  │  inférable              │     │                         │
  │                         │     │                         │
  └─────────────────────────┘     └─────────────────────────┘
       Écrire dans AGENTS.md           NE PAS écrire !
```

**Exception :** « Les choses qui peuvent être inférées mais qui sont trop coûteuses à faire à chaque fois »

```
  ex. : Liste complète des API (nécessite de lire 20 fichiers)
  ex. : Relations du modèle de données (éparpillées dans 10 fichiers)
  ex. : Relations d'appels inter-services (nécessite de vérifier le code + l'infra)

  → Pré-organisez cela dans .ai-agents/context/ !
  → Dans AGENTS.md, écrivez seulement le chemin : « allez ici pour le trouver »
```

```
À inclure (non inférable)       .ai-agents/context/ (inférence coûteuse)   À exclure (inférence bon marché)
─────────────────────────       ──────────────────────────────────────      ────────────────────────────────
Conventions de l'équipe         Carte complète des API                      Structure des répertoires
Actions interdites              Relations du modèle de données              Contenu d'un seul fichier
Formats PR/commit               Specs événements pub/sub                    Docs framework officielles
Dépendances cachées             Topologie de l'infrastructure               Relations d'import
                               Objectifs KPI et métriques métier
                               Carte des parties prenantes et flux d'approbation
                               Runbooks opérationnels et chemins d'escalade
                               Feuille de route et suivi des jalons
```

---

## Comment ça fonctionne

### Étape 1 : Scan et classification du projet

Explore les répertoires jusqu'à la profondeur 3 et classifie automatiquement par patterns de fichiers.

```
deployment.yaml + service.yaml  →  k8s-workload
values.yaml (Helm)              →  infra-component
package.json + *.tsx            →  frontend
go.mod                          →  backend-go
Dockerfile + CI config          →  cicd
...19 types détectés automatiquement
```

### Étape 2 : Génération du contexte

Génère les fichiers de connaissances `.ai-agents/context/` en **analysant réellement le code** selon les types détectés.

```
Service backend détecté
  → Scan routes/controllers → Génère api-spec.json
  → Scan entities/schemas   → Génère data-model.md
  → Scan config Kafka       → Génère event-spec.json
```

### Étape 3 : Génération de AGENTS.md

Génère AGENTS.md pour chaque répertoire en utilisant les templates appropriés.

```
AGENTS.md racine (Conventions globales)
  → Commits : Conventional Commits
  → PR : Template requis, 1+ approbations
  → Branches : feature/{ticket}-{desc}
       │
       ▼ Héritage automatique (non répété dans les enfants)
  apps/api/AGENTS.md
    → Remplace uniquement : « Ce service utilise Python »
```

Les règles globales utilisent un **pattern d'héritage** — écrivez à un endroit, et cela s'applique automatiquement en aval.

```
AGENTS.md racine ──────────────────────────────────────────────
│ Conventions globales :
│  - Commits : Conventional Commits (feat:, fix:, chore:)
│  - PR : Template requis, au moins 1 relecteur
│  - Branche : feature/{ticket}-{desc}
│
│     Héritage auto               Héritage auto
│     ┌──────────────────┐       ┌──────────────────┐
│     ▼                  │       ▼                  │
│  apps/api/AGENTS.md    │    infra/AGENTS.md       │
│  (Seules les règles    │    (Seules les règles    │
│   supplémentaires      │     supplémentaires      │
│   sont spécifiées)     │     sont spécifiées)     │
│  « Ce service utilise  │    « Lors de la modif.  │
│   Python »             │     des valeurs Helm,   │
│                        │     Demander d'abord »  │
└────────────────────────┴──────────────────────────
```

**Avantages :**
- Vous voulez changer les règles de commit ? → Modifiez uniquement la racine
- Vous ajoutez un nouveau service ? → Les règles globales s'appliquent automatiquement
- Vous avez besoin de règles différentes pour un service spécifique ? → Surchargez dans le AGENTS.md de ce service

### Étape 4 : Bootstrap spécifique au fournisseur

Ajoute des ponts vers les configurations spécifiques aux fournisseurs afin que **tous les outils IA lisent** le AGENTS.md généré.

```
┌──────────────┐     ┌─────────────┐     ┌─────────────┐
│ Claude Code  │     │   Cursor    │     │   Codex     │
│  CLAUDE.md   │     │  .mdc rules │     │  AGENTS.md  │
│      ↓       │     │      ↓      │     │  (natif)    │
│ « lire       │     │ « lire      │     │      ✓      │
│  AGENTS.md » │     │  AGENTS.md »│     │             │
└──────┬───────┘     └──────┬──────┘     └─────────────┘
       └──────────┬─────────┘
                  ▼
           AGENTS.md (source unique de vérité)
                  │
        ┌─────────┼─────────┐
        ▼         ▼         ▼
  .ai-agents/  .ai-agents/  .ai-agents/
   context/     skills/      roles/
```

> **Principe :** Les fichiers bootstrap ne sont générés que pour les fournisseurs déjà utilisés. Les fichiers de configuration pour les outils non utilisés ne sont jamais créés.

---

## Compatibilité avec les fournisseurs

| Outil | Lit AGENTS.md automatiquement | Bootstrap |
|---|---|---|
| **OpenAI Codex** | Oui (natif) | Non nécessaire |
| **Claude Code** | Partiel (fallback) | Ajoute une directive dans `CLAUDE.md` |
| **Cursor** | Non | Ajoute `.mdc` dans `.cursor/rules/` |
| **GitHub Copilot** | Non | Génère `.github/copilot-instructions.md` |
| **Windsurf** | Non | Ajoute une directive dans `.windsurfrules` |
| **Aider** | Oui | Ajoute une lecture dans `.aider.conf.yml` |

Générer les bootstraps automatiquement :
```bash
bash scripts/sync-ai-rules.sh
```

---

## Structure générée

```
project-root/
├── AGENTS.md                          # Agent PM (orchestration globale)
├── .ai-agents/
│   ├── context/                       # Fichiers de connaissances (chargés au démarrage de session)
│   │   ├── domain-overview.md         #   Domaine métier, politiques, contraintes
│   │   ├── data-model.md             #   Définitions d'entités, relations, transitions d'état
│   │   ├── api-spec.json              #   Carte des API (JSON DSL, économie de 3x tokens)
│   │   ├── event-spec.json            #   Specs d'événements Kafka/MQ
│   │   ├── infra-spec.md              #   Charts Helm, réseau, ordre de déploiement
│   │   ├── external-integration.md    #   API externes, auth, limites de débit
│   │   ├── business-metrics.md        #   KPIs, OKRs, modèle de revenus, critères de succès
│   │   ├── stakeholder-map.md         #   Décideurs, flux d'approbation, RACI
│   │   ├── ops-runbook.md             #   Procédures opérationnelles, escalade, SLA
│   │   └── planning-roadmap.md        #   Jalons, dépendances, calendrier
│   ├── skills/                        # Flux de travail comportementaux (chargés à la demande)
│   │   ├── develop/SKILL.md           #   Dev : analyser → concevoir → implémenter → tester → PR
│   │   ├── deploy/SKILL.md            #   Déploiement : tag → demande → vérification
│   │   ├── review/SKILL.md            #   Revue : basée sur checklist
│   │   ├── hotfix/SKILL.md            #   Flux de correction d'urgence
│   │   └── context-update/SKILL.md    #   Procédure de mise à jour des fichiers de contexte
│   └── roles/                         # Définitions de rôles (profondeur de contexte par rôle)
│       ├── pm.md                      #   Chef de projet
│       ├── backend.md                 #   Développeur backend
│       ├── frontend.md                #   Développeur frontend
│       ├── sre.md                     #   SRE / Infrastructure
│       └── reviewer.md               #   Relecteur de code
│
├── apps/
│   ├── api/AGENTS.md                  # Agents par service
│   └── web/AGENTS.md
└── infra/
    └── helm/AGENTS.md
```

---

## Lanceur de session

```bash
./ai-agency.sh              # Sélection interactive : agent → outil IA → démarrage
./ai-agency.sh --multi      # Lancer plusieurs agents en parallèle (tmux, Ctrl+B N)
./ai-agency.sh --print      # Afficher la commande sans l'exécuter
```

---

## Optimisation des tokens

| Format | Nombre de tokens | Notes |
|---|---|---|
| Description API en langage naturel | ~200 tokens | |
| JSON DSL | ~70 tokens | **Économie de 3x** |

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

**Cible AGENTS.md :** Moins de **300 tokens** après substitution

---

## Protocole de restauration de session

```
Début de session :
  1. Lire AGENTS.md (la plupart des outils IA le font automatiquement)
  2. Suivre les chemins des fichiers de contexte pour charger .ai-agents/context/
  3. Vérifier .ai-agents/context/current-work.md (travail en cours)
  4. git log --oneline -10 (comprendre les changements récents)

Fin de session :
  1. Travail en cours → Enregistrer dans current-work.md
  2. Nouvelles connaissances du domaine apprises → Mettre à jour les fichiers de contexte
  3. TODOs incomplets → Enregistrer explicitement
```

---

## Maintenance du contexte

Lorsque le code change, les fichiers `.ai-agents/context/` doivent être mis à jour en conséquence.

```
API ajoutée/modifiée/supprimée        →  Mettre à jour api-spec.json
Schéma DB modifié                     →  Mettre à jour data-model.md
Spec d'événement modifiée             →  Mettre à jour event-spec.json
Politique métier modifiée             →  Mettre à jour domain-overview.md
Intégration externe modifiée          →  Mettre à jour external-integration.md
Configuration infrastructure modifiée →  Mettre à jour infra-spec.md
Objectifs KPI/OKR modifiés           →  Mettre à jour business-metrics.md
Structure d'équipe modifiée          →  Mettre à jour stakeholder-map.md
Procédure opérationnelle modifiée    →  Mettre à jour ops-runbook.md
Jalon/feuille de route modifié       →  Mettre à jour planning-roadmap.md
```

> Ne pas mettre à jour signifie que la prochaine session **travaillera avec un contexte obsolète**.

---

## Résumé du flux global

```
┌──────────────────────────────────────────────────────────────────┐
│  1. Configuration initiale (une fois)                            │
│                                                                  │
│  Exécuter ./setup.sh                                             │
│       │                                                          │
│       ▼                                                          │
│  L'IA analyse la structure du projet                             │
│       │                                                          │
│       ▼                                                          │
│  Crée AGENTS.md dans chaque          Organise les connaissances  │
│  répertoire                          dans .ai-agents/context/    │
│  (identité agent + règles            (specs API, modèle,         │
│   + permissions)                      événements)                │
│                                                                  │
│  Définit les flux de travail dans    Définit les rôles dans      │
│  .ai-agents/skills/                  .ai-agents/roles/           │
│  (procédures de développement,       (Backend, Frontend, SRE)    │
│   déploiement, revue)                                            │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  2. Utilisation quotidienne                                      │
│                                                                  │
│  Lancer ./ai-agency.sh                                           │
│       │                                                          │
│       ▼                                                          │
│  Sélectionner l'agent (PM ? Backend ? SRE ?)                     │
│       │                                                          │
│       ▼                                                          │
│  Sélectionner l'outil IA (Claude ? Codex ? Cursor ?)             │
│       │                                                          │
│       ▼                                                          │
│  Session démarrée → AGENTS.md chargé auto → .ai-agents/context/  │
│  chargé → Au travail !                                           │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  3. Maintenance continue                                         │
│                                                                  │
│  Lorsque le code change :                                        │
│    - L'IA met automatiquement à jour .ai-agents/context/         │
│    - Ou un humain donne l'instruction « C'est important,         │
│      enregistre-le »                                             │
│                                                                  │
│  Lors de l'ajout d'un nouveau service :                          │
│    - Relancer HOW_TO_AGENTS.md → Nouveau AGENTS.md généré auto   │
│    - Les règles globales sont automatiquement héritées           │
│                                                                  │
│  Lorsque l'IA fait des erreurs :                                 │
│    - « Ré-analyse ceci » → Fournir des indices → Une fois        │
│      compris, mettre à jour .ai-agents/context/                  │
│    - Cette boucle de rétroaction améliore la qualité du contexte │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## Analogie : équipe de développement traditionnelle vs équipe d'agents IA

```
              Équipe dev traditionnelle     Équipe d'agents IA
              ─────────────────────────     ──────────────────────────
 Responsable  PM (humain)                   AGENTS.md racine (agent PM)
 Membres      N développeurs               AGENTS.md dans chaque répertoire
 Intégration  Confluence/Notion            .ai-agents/context/
 Manuels      Wiki d'équipe               .ai-agents/skills/
 Defs. rôles  Fiches de poste/R&R          .ai-agents/roles/
 Règles       Docs conventions équipe      Conventions globales (héritées)
 Arrivée      Arriver au bureau            Session démarre → AGENTS.md chargé
 Départ       Partir (mémoire conservée)   Session terminée (mémoire perdue !)
 Lendemain    Mémoire intacte              .ai-agents/context/ chargé (mémoire restaurée)
```

**Différence clé :** Les humains conservent leur mémoire après le travail, mais l'IA oublie tout à chaque fois.
C'est pourquoi `.ai-agents/context/` existe — il sert de **mémoire à long terme** de l'IA.

---

## Checklist d'adoption

```
Phase 1 (Bases)                Phase 2 (Contexte)               Phase 3 (Opérations)
───────────────                ──────────────────               ────────────────────
☐ Générer AGENTS.md            ☐ Créer .ai-agents/context/      ☐ Définir .ai-agents/roles/
☐ Enregistrer commandes        ☐ domain-overview.md             ☐ Lancer sessions multi-agents
  build/test                   ☐ api-spec.json (DSL)            ☐ Flux .ai-agents/skills/
☐ Enregistrer conventions      ☐ data-model.md                  ☐ Boucle de rétroaction itérative
  et règles                    ☐ Configurer règles de
☐ Conventions globales           maintenance
☐ Bootstraps fournisseurs
```

---

## Livrables

| Fichier | Audience | Objectif |
|---|---|---|
| `setup.sh` | Humain | Lance la configuration initiale (analyse + génération de AGENTS.md) |
| `HOW_TO_AGENTS.md` | IA | Manuel de méta-instructions que les agents lisent et exécutent |
| `README.md` | Humain | Ce document — un guide pour la compréhension humaine |
| `ai-agency.sh` | Humain | Sélection d'agent → lanceur de session IA |
| `AGENTS.md` (chaque répertoire) | IA | Identité + règles de l'agent par répertoire |
| `.ai-agents/context/*.md/json` | IA | Connaissances du domaine pré-organisées |
| `.ai-agents/skills/*/SKILL.md` | IA | Flux de travail standardisés |
| `.ai-agents/roles/*.md` | IA/Humain | Stratégies de chargement de contexte par rôle |

---

## Références

- [Kurly OMS Team AI Workflow](https://helloworld.kurly.com/blog/oms-claude-ai-workflow/) — Inspiration pour la conception du contexte de ce système
- [AGENTS.md Standard](https://agents.md/) — Standard d'instructions d'agents neutre vis-à-vis des fournisseurs
- [ETH Zurich Research](https://www.infoq.com/news/2026/03/agents-context-file-value-review/) — « Ne documenter que ce qui ne peut pas être inféré »

---

## Licence

MIT

---

<p align="center">
  <sub>Réduisez à zéro le temps nécessaire aux agents IA pour comprendre votre projet.</sub>
</p>
