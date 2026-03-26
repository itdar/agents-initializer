🌐 [English](../README.md) | [한국어](README_ko.md) | [日本語](README_ja.md) | [中文](README_zh.md) | [Español](README_es.md) | [Français](README_fr.md) | [Deutsch](README_de.md) | [Русский](README_ru.md) | [हिन्दी](README_hi.md) | [العربية](README_ar.md)

# ai-initializer

**Generateur automatique de contexte projet pour les outils de codage IA**

> Analyse votre repertoire de projet et genere automatiquement
> `AGENTS.md` + contexte de connaissances/competences/roles pour que les agents IA puissent commencer a travailler immediatement.

```
Une commande → Analyse du projet → Generation d'AGENTS.md → Fonctionne avec n'importe quel outil IA
```

---

## Utilisation

> **Avis sur la consommation de tokens** — Lors de la configuration initiale, un modele de premier rang analyse l'ensemble du projet et genere plusieurs fichiers (AGENTS.md, .ai-agents/context/, .ai-agents/skills/, .ai-agents/roles/). Cela peut consommer des dizaines de milliers de tokens selon la taille du projet. C'est un cout unique ; les sessions suivantes chargent le contexte pre-construit et demarrent instantanement.

```bash
# 1. Faites lire HOW_TO_AGENTS.md a l'IA et elle s'occupe du reste

# Option A : Anglais (recommande — cout en tokens reduit, performance IA optimale)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Read HOW_TO_AGENTS.md and generate AGENTS.md tailored to this project"

# Option B : Langue de l'utilisateur (recommande si vous prevoyez de modifier manuellement AGENTS.md)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "HOW_TO_AGENTS.md를 읽고 이 프로젝트에 맞게 AGENTS.md를 생성하라"

# Recommande : --model claude-opus-4-6 (ou ulterieur) pour de meilleurs resultats
# Recommande : --dangerously-skip-permissions pour une execution autonome sans interruption

# 2. Commencez a travailler avec les agents generes
./ai-agency.sh
```

---

## Pourquoi en avez-vous besoin ?

### Le probleme : l'IA perd sa memoire a chaque session

```
 Session 1                  Session 2                  Session 3
┌──────────┐             ┌──────────┐             ┌──────────┐
│ L'IA lit  │             │ L'IA lit  │             │ Repartir  │
│ tout le   │  Session    │ tout le   │  Session    │ de        │
│ code      │  terminee   │ code      │  terminee   │ zero      │
│ (30 min)  │ ──────→    │ (30 min)  │ ──────→    │ encore    │
│ Commence  │ Memoire    │ Commence  │ Memoire    │ (30 min)  │
│ a         │ perdue !   │ a         │ perdue !   │ Commence  │
│ travailler│             │ travailler│             │ a         │
└──────────┘             └──────────┘             │ travailler│
                                                   └──────────┘
```

Les agents IA oublient tout quand une session se termine. A chaque fois, ils passent du temps a comprendre la structure du projet, analyser les API et apprendre les conventions.

| Probleme | Consequence |
|---|---|
| Ne connait pas les conventions de l'equipe | Incoherences de style de code |
| Ne connait pas la carte complete des API | Explore tout le code a chaque fois (cout +20%) |
| Ne connait pas les actions interdites | Operations risquees comme l'acces direct a la base de production |
| Ne connait pas les dependances entre services | Effets de bord manques |

### La solution : pre-construire un « cerveau » pour l'IA

```
 Demarrage de session
┌──────────────────────────────────────────────────┐
│                                                  │
│  Lit AGENTS.md (automatiquement)                 │
│       │                                          │
│       ▼                                          │
│  "Je suis l'expert backend de ce service"        │
│  "Conventions : Conventional Commits, TypeScript  │
│   strict"                                        │
│  "Interdit : modifier d'autres services,         │
│   coder en dur les secrets"                      │
│       │                                          │
│       ▼                                          │
│  Charge les fichiers .ai-agents/context/         │
│  (5 secondes)                                    │
│  "20 API, 15 entites, 8 evenements compris"      │
│       │                                          │
│       ▼                                          │
│  Commence a travailler immediatement !           │
│                                                  │
└──────────────────────────────────────────────────┘
```

**ai-initializer** resout ce probleme — generez une seule fois, et n'importe quel outil IA comprend votre projet instantanement.

---

## Principe fondamental : architecture a 3 couches

```
                    Votre Projet
                         │
            ┌────────────┼────────────┐
            ▼            ▼            ▼

     ┌──────────┐  ┌──────────┐  ┌──────────┐
     │ AGENTS.md│  │.ai-agents│  │.ai-agents│
     │          │  │ /context/ │  │ /skills/ │
     │ Identite │  │Connais-  │  │Comporte- │
     │ "Qui     │  │ sances   │  │ ment     │
     │  suis-   │  │ "Que     │  │ "Comment │
     │  je ?"   │  │  sais-   │  │  est-ce  │
     │          │  │  je ?"   │  │  que je  │
     │ + Regles │  │          │  │  travail-│
     │ + Perms  │  │ + Domaine│  │  le ?"   │
     │ + Chemins│  │ + Modeles│  │ + Deploy │
     └──────────┘  └──────────┘  │ + Revue  │
      Point        Stockage de   └──────────┘
      d'entree     memoire       Standards de
                                  flux de travail
```

### 1. AGENTS.md — « Qui suis-je ? »

Le **fichier d'identite** de l'agent deploye dans chaque repertoire.

```
project/
├── AGENTS.md                  ← PM : Le leader qui coordonne tout
├── apps/
│   └── api/
│       └── AGENTS.md          ← Expert API : Responsable de ce service uniquement
├── infra/
│   ├── AGENTS.md              ← SRE : Gere toute l'infrastructure
│   └── monitoring/
│       └── AGENTS.md          ← Specialiste monitoring
└── configs/
    └── AGENTS.md              ← Gestionnaire de configuration
```

Cela fonctionne exactement comme un **organigramme d'equipe** :
- Le PM supervise tout et distribue les taches
- Chaque membre de l'equipe comprend en profondeur uniquement son domaine
- Ils ne traitent pas directement le travail des autres equipes — ils le demandent

### 2. `.ai-agents/context/` — « Que sais-je ? »

Un dossier ou **les connaissances essentielles sont pre-organisees** pour que l'IA n'ait pas a lire le code a chaque fois.

```
.ai-agents/context/
├── domain-overview.md     ← "Ce service gere la gestion des commandes..."
├── data-model.md          ← "Il y a les entites Order, Payment, Delivery..."
├── api-spec.json          ← "POST /orders, GET /orders/{id}, ..."
└── event-spec.json        ← "Publie l'evenement order-created..."
```

**Analogie :** Documentation d'integration pour un nouvel employe. Documentez une fois, et personne n'a besoin de reexpliquer.

### 3. `.ai-agents/skills/` — « Comment est-ce que je travaille ? »

**Manuels de flux de travail standardises** pour les taches repetitives.

```
.ai-agents/skills/
├── develop/SKILL.md       ← "Dev de fonctionnalite : Analyser → Concevoir → Implementer → Tester → PR"
├── deploy/SKILL.md        ← "Deploiement : Tag → Demande → Verification"
└── review/SKILL.md        ← "Revue : Checklist securite, performance, tests"
```

**Analogie :** Le manuel d'operations de l'equipe — fait suivre a l'IA des regles comme « verifier cette checklist avant de soumettre une PR ».

---

## Quoi ecrire et quoi ne pas ecrire

> ETH Zurich (2026.03) : **Inclure du contenu inferable reduit les taux de reussite et augmente le cout de +20%**

```
         Ecrire ceci                       Ne pas ecrire ceci
  ┌─────────────────────────┐     ┌─────────────────────────┐
  │                         │     │                         │
  │  "Utiliser le format    │     │  "Le code source est    │
  │   feat: pour les        │     │   dans le dossier src/" │
  │   commits"              │     │  L'IA peut le voir      │
  │  L'IA ne peut pas       │     │   avec ls               │
  │   le deduire            │     │                         │
  │                         │     │  "React est base sur    │
  │  "Pas de push direct    │     │   les composants"       │
  │   sur main"             │     │  Deja dans la doc       │
  │  Regle d'equipe, pas    │     │   officielle            │
  │   dans le code          │     │                         │
  │                         │     │  "Ce fichier fait 100   │
  │  "Approbation QA        │     │   lignes"               │
  │   requise avant         │     │  L'IA peut le lire      │
  │   deploiement"          │     │   directement           │
  │  Processus, non         │     │                         │
  │   inferable             │     │                         │
  └─────────────────────────┘     └─────────────────────────┘
       Ecrire dans AGENTS.md          NE PAS ecrire !
```

**Exception :** « Les choses qui peuvent etre deduites mais dont l'inference est trop couteuse a chaque fois »

```
  ex. : Liste complete des API (il faut lire 20 fichiers pour la reconstituer)
  ex. : Relations du modele de donnees (dispersees dans 10 fichiers)
  ex. : Relations d'appels inter-services (il faut verifier le code + l'infra)

  → Pre-organisez-les dans .ai-agents/context/ !
  → Dans AGENTS.md, ecrivez uniquement le chemin : "allez ici pour le trouver"
```

```
Inclure (non inferable)           .ai-agents/context/ (inference couteuse)     Exclure (inference peu couteuse)
───────────────────────           ────────────────────────────────────         ────────────────────────
Conventions d'equipe              Carte complete des API                       Structure des repertoires
Actions interdites                Relations du modele de donnees               Contenu d'un seul fichier
Formats PR/commit                 Specs evenements pub/sub                     Doc officielle du framework
Dependances cachees               Topologie d'infrastructure                   Relations d'import
```

---

## Comment ca fonctionne

### Etape 1 : Scan et classification du projet

Explore les repertoires jusqu'a une profondeur de 3 et classifie automatiquement selon les motifs de fichiers.

```
deployment.yaml + service.yaml  →  k8s-workload
values.yaml (Helm)              →  infra-component
package.json + *.tsx            →  frontend
go.mod                          →  backend-go
Dockerfile + CI config          →  cicd
...19 types detectes automatiquement
```

### Etape 2 : Generation du contexte

Genere les fichiers de connaissances `.ai-agents/context/` en **analysant reellement le code** selon les types detectes.

```
Service backend detecte
  → Scan routes/controllers → Genere api-spec.json
  → Scan entites/schemas   → Genere data-model.md
  → Scan config Kafka       → Genere event-spec.json
```

### Etape 3 : Generation d'AGENTS.md

Genere AGENTS.md pour chaque repertoire en utilisant les templates appropries.

```
AGENTS.md racine (Conventions globales)
  → Commits : Conventional Commits
  → PR : Template requis, 1+ approbation
  → Branches : feature/{ticket}-{desc}
       │
       ▼ Heritage automatique (non repete dans les enfants)
  apps/api/AGENTS.md
    → Redefinit uniquement : "Ce service utilise Python"
```

Les regles globales utilisent un **patron d'heritage** — ecrivez en un seul endroit, et cela s'applique automatiquement en aval.

```
AGENTS.md racine ──────────────────────────────────────────
│ Conventions globales :
│  - Commits : Conventional Commits (feat:, fix:, chore:)
│  - PR : Template requis, au moins 1 relecteur
│  - Branche : feature/{ticket}-{desc}
│
│     Heritage auto                  Heritage auto
│     ┌──────────────────┐       ┌──────────────────┐
│     ▼                  │       ▼                  │
│  apps/api/AGENTS.md    │    infra/AGENTS.md       │
│  (Seules les regles    │    (Seules les regles    │
│   additionnelles       │     additionnelles       │
│   specifiees)          │     specifiees)          │
│  "Ce service utilise   │    "Pour modifier les    │
│   Python"              │     values Helm,         │
│                        │     Demander d'abord"    │
└─────────────────────────┴──────────────────────────
```

**Avantages :**
- Vous voulez changer les regles de commit ? → Modifiez uniquement la racine
- Vous ajoutez un nouveau service ? → Les regles globales s'appliquent automatiquement
- Vous avez besoin de regles differentes pour un service specifique ? → Redefinissez dans l'AGENTS.md de ce service

### Etape 4 : Bootstrap specifique au fournisseur

Ajoute des ponts vers les configurations specifiques aux fournisseurs pour que **tous les outils IA lisent** l'AGENTS.md genere.

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

> **Principe :** Les fichiers de bootstrap ne sont generes que pour les fournisseurs deja utilises. Les fichiers de configuration pour les outils non utilises ne sont jamais crees.

---

## Compatibilite des fournisseurs

| Outil | Lit automatiquement AGENTS.md | Bootstrap |
|---|---|---|
| **OpenAI Codex** | Oui (natif) | Non necessaire |
| **Claude Code** | Partiel (fallback) | Ajoute une directive a `CLAUDE.md` |
| **Cursor** | Non | Ajoute `.mdc` a `.cursor/rules/` |
| **GitHub Copilot** | Non | Genere `.github/copilot-instructions.md` |
| **Windsurf** | Non | Ajoute une directive a `.windsurfrules` |
| **Aider** | Oui | Ajoute la lecture a `.aider.conf.yml` |

Generation automatique des bootstraps :
```bash
bash scripts/sync-ai-rules.sh
```

---

## Structure generee

```
project-root/
├── AGENTS.md                          # Agent PM (orchestration globale)
├── .ai-agents/
│   ├── context/                       # Fichiers de connaissances (charges au demarrage de session)
│   │   ├── domain-overview.md         #   Domaine metier, politiques, contraintes
│   │   ├── data-model.md             #   Definitions d'entites, relations, transitions d'etat
│   │   ├── api-spec.json              #   Carte des API (JSON DSL, 3x d'economie de tokens)
│   │   ├── event-spec.json            #   Specs evenements Kafka/MQ
│   │   ├── infra-spec.md              #   Charts Helm, reseau, ordre de deploiement
│   │   └── external-integration.md    #   API externes, authentification, limites de debit
│   ├── skills/                        # Flux de travail comportementaux (charges a la demande)
│   │   ├── develop/SKILL.md           #   Dev : analyser → concevoir → implementer → tester → PR
│   │   ├── deploy/SKILL.md            #   Deploy : tag → demande de deploiement → verification
│   │   ├── review/SKILL.md            #   Revue : basee sur une checklist
│   │   ├── hotfix/SKILL.md            #   Flux de correction d'urgence
│   │   └── context-update/SKILL.md    #   Procedure de mise a jour du contexte
│   └── roles/                         # Definitions de roles (profondeur de contexte par role)
│       ├── pm.md                      #   Chef de projet
│       ├── backend.md                 #   Developpeur Backend
│       ├── frontend.md                #   Developpeur Frontend
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

Une fois tous les agents configures, choisissez l'agent souhaite et demarrez une session immediatement.

```bash
$ ./ai-agency.sh

=== Sessions d'agents IA ===
Trouves : 8 agent(s)

  1) [PM] project-root
  2) api-service
  3) monitoring
  ...

Selectionnez un agent (numero) : 2

=== Outil IA ===
  1) claude
  2) codex
  3) print

Selectionnez un outil : 1

→ Session demarree dans le repertoire api-service
→ L'agent charge automatiquement AGENTS.md et .ai-agents/context/
→ Pret a travailler immediatement !
```

**Execution parallele (tmux) :**

```bash
$ ./ai-agency.sh --multi

Selectionnez les agents : 1,2,3   # Executer PM + API + Monitoring simultanement

→ 3 sessions tmux ouvertes
→ Differents agents travaillent independamment dans chaque volet
→ Changez de volet avec Ctrl+B N
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
Demarrage de session :
  1. Lire AGENTS.md (la plupart des outils IA le font automatiquement)
  2. Suivre les chemins des fichiers de contexte pour charger .ai-agents/context/
  3. Verifier .ai-agents/context/current-work.md (travail en cours)
  4. git log --oneline -10 (comprendre les changements recents)

Fin de session :
  1. Travail en cours → Enregistrer dans current-work.md
  2. Connaissances de domaine nouvellement acquises → Mettre a jour les fichiers de contexte
  3. TODOs incomplets → Enregistrer explicitement
```

---

## Maintenance du contexte

Quand le code change, les fichiers `.ai-agents/context/` doivent etre mis a jour en consequence.

```
API ajoutee/modifiee/supprimee   →  Mettre a jour api-spec.json
Schema de BDD modifie            →  Mettre a jour data-model.md
Spec d'evenement modifiee        →  Mettre a jour event-spec.json
Politique metier modifiee        →  Mettre a jour domain-overview.md
Integration externe modifiee     →  Mettre a jour external-integration.md
Config d'infrastructure modifiee →  Mettre a jour infra-spec.md
```

> Ne pas mettre a jour signifie que la prochaine session **travaillera avec un contexte obsolete**.

---

## Resume du flux global

```
┌──────────────────────────────────────────────────────────────────┐
│  1. Configuration initiale (une seule fois)                      │
│                                                                  │
│  Faire lire HOW_TO_AGENTS.md a l'IA                              │
│       │                                                          │
│       ▼                                                          │
│  L'IA analyse la structure du projet                             │
│       │                                                          │
│       ▼                                                          │
│  Cree AGENTS.md dans chaque        Organise les connaissances    │
│  repertoire                        dans .ai-agents/context/      │
│  (identite de l'agent + regles     (specs API, modele, evenem.)  │
│   + permissions)                                                 │
│                                                                  │
│  Definit les flux de travail       Definit les roles dans        │
│  dans .ai-agents/skills/           .ai-agents/roles/             │
│  (procedures de developpement,     (Backend, Frontend, SRE)      │
│   deploiement, revue)                                            │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  2. Utilisation quotidienne                                      │
│                                                                  │
│  Executer ./ai-agency.sh                                         │
│       │                                                          │
│       ▼                                                          │
│  Selectionner un agent (PM ? Backend ? SRE ?)                    │
│       │                                                          │
│       ▼                                                          │
│  Selectionner un outil IA (Claude ? Codex ? Cursor ?)            │
│       │                                                          │
│       ▼                                                          │
│  Session demarre → AGENTS.md charge auto → .ai-agents/context/   │
│  charge → Au travail !                                           │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  3. Maintenance continue                                         │
│                                                                  │
│  Quand le code change :                                          │
│    - L'IA met automatiquement a jour .ai-agents/context/         │
│    - Ou un humain indique "C'est important, enregistre-le"       │
│                                                                  │
│  Lors de l'ajout d'un nouveau service :                          │
│    - Relancer HOW_TO_AGENTS.md → Nouvel AGENTS.md auto-genere    │
│    - Les regles globales sont automatiquement heritees           │
│                                                                  │
│  Quand l'IA fait des erreurs :                                   │
│    - "Reanalyse ceci" → Fournir des indices → Une fois compris,  │
│      mettre a jour .ai-agents/context/                           │
│    - Cette boucle de retour ameliore la qualite du contexte      │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## Analogie : equipe traditionnelle vs equipe d'agents IA

```
              Equipe de dev traditionnelle  Equipe d'agents IA
              ───────────────────────────   ──────────────────
 Leader       PM (humain)                   AGENTS.md racine (agent PM)
 Membres      N developpeurs               AGENTS.md dans chaque repertoire
 Integration  Confluence/Notion             .ai-agents/context/
 Manuels      Wiki d'equipe                .ai-agents/skills/
 Def. roles   Fiches de poste/R&R          .ai-agents/roles/
 Regles       Docs de conventions           Conventions globales (heritees)
 Arrivee      Arriver au bureau             Session demarre → AGENTS.md charge
 Depart       Partir (memoire conservee)    Session termine (memoire perdue !)
 Lendemain    Memoire intacte               .ai-agents/context/ charge (memoire restauree)
```

**Difference cle :** Les humains conservent leur memoire apres avoir quitte le travail, mais l'IA oublie tout a chaque fois.
C'est pourquoi `.ai-agents/context/` existe — il sert de **memoire a long terme** pour l'IA.

---

## Checklist d'adoption

```
Phase 1 (Bases)                Phase 2 (Contexte)               Phase 3 (Operations)
────────────────               ─────────────────                ────────────────────
☐ Generer AGENTS.md            ☐ Creer .ai-agents/context/      ☐ Definir .ai-agents/roles/
☐ Enregistrer les commandes    ☐ domain-overview.md              ☐ Executer des sessions
  build/test                                                       multi-agents
☐ Enregistrer conventions      ☐ api-spec.json (DSL)             ☐ Flux .ai-agents/skills/
  et regles
☐ Conventions globales         ☐ data-model.md                   ☐ Boucle de retour iterative
☐ Bootstraps fournisseurs      ☐ Mettre en place les regles
                                 de maintenance
```

---

## Livrables

| Fichier | Public | Objectif |
|---|---|---|
| `HOW_TO_AGENTS.md` | IA | Manuel de meta-instructions que les agents lisent et executent |
| `README.md` | Humain | Ce document — un guide pour la comprehension humaine |
| `ai-agency.sh` | Humain | Selection d'agent → Lanceur de session IA |
| `AGENTS.md` (chaque repertoire) | IA | Identite de l'agent + regles par repertoire |
| `.ai-agents/context/*.md/json` | IA | Connaissances de domaine pre-organisees |
| `.ai-agents/skills/*/SKILL.md` | IA | Flux de travail standardises |
| `.ai-agents/roles/*.md` | IA/Humain | Strategies de chargement de contexte par role |

---

## References

- [Kurly OMS Team AI Workflow](https://helloworld.kurly.com/blog/oms-claude-ai-workflow/) — Inspiration pour la conception du contexte de ce systeme
- [AGENTS.md Standard](https://agents.md/) — Standard d'instructions d'agents independant du fournisseur
- [ETH Zurich Research](https://www.infoq.com/news/2026/03/agents-context-file-value-review/) — « Ne documentez que ce qui ne peut pas etre deduit »

---

## Licence

MIT

---

<p align="center">
  <sub>Reduisez a zero le temps necessaire aux agents IA pour comprendre votre projet.</sub>
</p>
