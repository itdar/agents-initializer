# Sistema de Gestión de Agentes IA — Guía para Humanos

## ¿Cómo empezar?

> **Advertencia: Alto consumo de tokens** — La configuración inicial usa un modelo de nivel superior para analizar todo el proyecto y generar múltiples archivos (AGENTS.md, .ai-agents/context/, .ai-agents/skills/, .ai-agents/roles/). Espere un consumo significativo de tokens (decenas de miles o más según el tamaño del proyecto). Es un costo único — las sesiones posteriores cargan el contexto preconstruido y se inician instantáneamente.

```bash
# 1. Haz que la IA lea HOW_TO_AGENTS.md y se configurará automáticamente

# Opción A: Inglés (recomendado — menor costo de tokens, mejor rendimiento de IA)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Read HOW_TO_AGENTS.md and generate AGENTS.md tailored to this project"

# Opción B: Tu idioma (recomendado si los humanos editan AGENTS.md directamente)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Lee HOW_TO_AGENTS.md y genera AGENTS.md adaptado a este proyecto (en español)"

# Recomendado: --dangerously-skip-permissions para configuración autónoma sin interrupciones
# Recomendado: --model claude-opus-4-6 (o posterior) para mejores resultados

# 2. Comienza a trabajar con los agentes generados
./ai-agency.sh

# 3. ¡A partir de la siguiente sesión, podrás trabajar de inmediato!
```

> Este documento es **para que los humanos lo lean y comprendan**.
> Explica por qué existe la guía de instrucciones que ejecuta la IA (HOW_TO_AGENTS.md),
> cómo funciona y qué papel desempeña en tu flujo de trabajo de desarrollo.

---

## ¿Por qué se necesita este sistema?

### Problema: La IA pierde la memoria en cada sesión

```
 Sesión 1                   Sesión 2                   Sesión 3
┌──────────┐             ┌──────────┐             ┌──────────┐
│ La IA lee │             │ La IA lee │             │ Otra vez  │
│ todo el   │  Fin de     │ todo de   │  Fin de     │ desde el  │
│ código    │  sesión     │ nuevo     │  sesión     │ principio │
│ (30 min)  │ ──────→    │ (30 min)  │ ──────→    │ (30 min)  │
│ Empieza   │ ¡Memoria   │ Empieza   │ ¡Memoria   │ Empieza   │
│ a trabajar│  perdida!   │ a trabajar│  perdida!   │ a trabajar│
└──────────┘             └──────────┘             └──────────┘
```

Los agentes IA olvidan todo cuando la sesión termina.
Cada vez gastan tiempo en comprender la estructura del proyecto, analizar las APIs y entender las convenciones.

### Solución: Crear un "cerebro" previo para la IA

```
 Inicio de sesión
┌──────────────────────────────────────────────────┐
│                                                  │
│  Lee AGENTS.md (automático)                      │
│       │                                          │
│       ▼                                          │
│  "Soy el experto en backend de doppel-api"       │
│  "Convenciones: Conventional Commits, TypeScript  │
│   strict"                                        │
│  "Prohibido: modificar otros servicios,           │
│   hardcodear secretos"                           │
│       │                                          │
│       ▼                                          │
│  Carga archivos de .ai-agents/context/ (5 seg)          │
│  "20 APIs, 15 entidades, 8 eventos identificados"│
│       │                                          │
│       ▼                                          │
│  ¡Comienza a trabajar de inmediato!              │
│                                                  │
└──────────────────────────────────────────────────┘
```

---

## Principio clave: Estructura de 3 capas

```
                    Tu proyecto
                         │
            ┌────────────┼────────────┐
            ▼            ▼            ▼

     ┌──────────┐  ┌──────────┐  ┌──────────┐
     │ AGENTS.md│  │.ai-agents/context│  │.ai-agents/skills│
     │          │  │          │  │          │
     │Identidad │  │Conocimien│  │ Acciones │
     │ "¿Quién  │  │ "Las APIs│  │ "Al      │
     │  soy?"   │  │  de este │  │ desarrollar
     │          │  │  servicio │  │  se hace  │
     │ + Reglas │  │  son así" │  │  así"    │
     │ + Permi- │  │          │  │          │
     │   sos    │  │ + Dominio│  │ + Deploy │
     │ + Rutas  │  │ + Modelos│  │ + Review │
     └──────────┘  └──────────┘  └──────────┘
      Punto de     Almacén de    Estándar de
      entrada       memoria      flujo de trabajo
```

### 1. AGENTS.md — "¿Quién soy?"

Es el **archivo de identidad** del agente ubicado en cada directorio.

```
proyecto/
├── AGENTS.md                  ← PM: Líder que coordina todo
├── apps/
│   └── doppel-api/
│       └── AGENTS.md          ← Experto en API: solo se encarga de este servicio
├── infra/
│   ├── AGENTS.md              ← SRE: Gestión de toda la infraestructura
│   └── monitoring/
│       └── AGENTS.md          ← Experto en monitoreo
└── configs/
    └── AGENTS.md              ← Administrador de configuración
```

Es como un **organigrama de equipo**:
- El PM tiene la visión general y distribuye tareas
- Cada miembro del equipo comprende a fondo solo su área
- No hace directamente el trabajo de otros equipos, sino que lo solicita

### 2. `.ai-agents/context/` — "¿Qué conoce?"

Es una carpeta donde se **organiza previamente el conocimiento clave** para que la IA no tenga que leer el código cada vez.

```
.ai-agents/context/
├── domain-overview.md     ← "Este servicio se encarga de la gestión de pedidos..."
├── data-model.md          ← "Existen las entidades Order, Payment, Delivery..."
├── api-spec.json          ← "POST /orders, GET /orders/{id}, ..."
└── event-spec.json        ← "Publica el evento order-created..."
```

**Analogía:** Es como el documento de onboarding que se le da a un empleado nuevo.
Si organizas una vez "qué hace nuestro equipo, cómo es la estructura de la BD, qué APIs hay",
no necesitas explicarlo cada vez.

### 3. `.ai-agents/skills/` — "¿Cómo trabaja?"

Son **manuales de flujo de trabajo** que estandarizan tareas repetitivas.

```
.ai-agents/skills/
├── develop/SKILL.md       ← "Desarrollo: Análisis → Diseño → Implementación → Pruebas → PR"
├── deploy/SKILL.md        ← "Deploy: Tag → Solicitud → Verificación"
└── review/SKILL.md        ← "Review: Checklist de seguridad, rendimiento y pruebas"
```

**Analogía:** Es el manual de trabajo del equipo.
Hace que la IA también siga reglas como "al crear un PR, verifica esta checklist".

---

## ¿Cómo se gestionan las reglas globales?

Se utiliza un **patrón de herencia**. Se escribe en un solo lugar y se aplica automáticamente hacia abajo.

```
AGENTS.md raíz ──────────────────────────────────────────
│ Global Conventions:
│  - Commits: Conventional Commits (feat:, fix:, chore:)
│  - PR: Plantilla obligatoria, mínimo 1 revisor
│  - Ramas: feature/{ticket}-{desc}
│  - Código: TypeScript strict, single quotes
│
│     Herencia automática             Herencia automática
│     ┌──────────────────┐       ┌──────────────────┐
│     ▼                  │       ▼                  │
│  apps/api/AGENTS.md    │    infra/AGENTS.md       │
│  (solo reglas adiciona-│    (solo reglas adiciona-│
│   les)                 │     les)                 │
│  "Este servicio usa    │    "Al cambiar Helm      │
│   Python"              │     values, Ask First"   │
│     (en vez de         │                          │
│      TypeScript)       │                          │
└─────────────────────────┴──────────────────────────
```

**Ventajas:**
- ¿Quieres cambiar las reglas de commits? → Solo modificas un lugar en la raíz
- ¿Añades un nuevo servicio? → Las reglas globales se aplican automáticamente
- ¿Solo un servicio necesita ser diferente? → Se sobreescribe en el AGENTS.md de ese servicio

---

## ¿Qué escribir y qué no escribir?

Según una investigación de ETH Zurich (2026), si escribes en el documento información que la IA ya puede inferir,
la **tasa de éxito baja y el costo aumenta un 20%**.

```
              Qué escribir                       Qué NO escribir
     ┌─────────────────────────┐     ┌─────────────────────────┐
     │                         │     │                         │
     │  "Commits en formato    │     │  "El código fuente está │
     │   feat:"                │     │   en la carpeta src/"   │
     │  Lo que la IA no puede  │     │  La IA puede verlo con  │
     │  inferir                │     │  ls directamente        │
     │                         │     │                         │
     │  "Prohibido push        │     │  "React está basado en  │
     │   directo a main"       │     │   componentes"          │
     │  Es regla de equipo,    │     │  Ya está en la          │
     │  no está en el código   │     │  documentación oficial  │
     │                         │     │                         │
     │  "Aprobación del equipo │     │  "Este archivo tiene    │
     │   de QA antes del       │     │   100 líneas"           │
     │   deploy"               │     │  La IA puede leerlo     │
     │  Es un proceso, no se   │     │  directamente           │
     │  puede inferir          │     │                         │
     └─────────────────────────┘     └─────────────────────────┘
          Escribir en AGENTS.md            ¡No escribir!
```

**Sin embargo, hay excepciones:** "Lo que se puede inferir, pero es demasiado costoso hacerlo cada vez"

```
  Ej: Lista completa de APIs (hay que leer 20 archivos para obtenerla)
  Ej: Diagrama de relaciones del modelo de datos (disperso en 10 archivos)
  Ej: Relaciones de llamadas entre servicios (hay que verificar código + infraestructura)

  → ¡Esto se organiza previamente en .ai-agents/context/!
  → En AGENTS.md solo se escribe la ruta "aquí lo encontrarás"
```

---

## Script lanzador de sesiones

Una vez configurados todos los agentes, puedes elegir el agente deseado e iniciar una sesión inmediatamente.

```bash
$ ./ai-agency.sh

=== AI Agent Sessions ===
Project: /Users/nhn/src/doppel-deploy
Found: 8 agent(s)

  1) [PM] doppel-deploy
     Path: ./AGENTS.md
     Agente PM de este proyecto. Comprende la estructura general y delega tareas.

  2) doppel-api
     Path: apps/dev/doppel-api/AGENTS.md
     Experto en gestión de manifiestos K8s del servicio doppel-api.

  3) monitoring
     Path: infra/monitoring/AGENTS.md
     Experto SRE del stack de monitoreo Prometheus + Grafana.

  ...

Select agent (number): 2

=== AI Tool ===
  1) claude
  2) codex
  3) print

Select tool: 1

→ La sesión de claude se inicia en el directorio doppel-api
→ El agente carga automáticamente AGENTS.md y .ai-agents/context/
→ ¡Listo para trabajar!
```

**Ejecución en paralelo (tmux):**

```bash
$ ./ai-agency.sh --multi

Select agents: 1,2,3   # PM + API + Monitoreo ejecución simultánea

→ Se abren 3 sesiones tmux
→ En cada ventana un agente diferente trabaja de forma independiente
→ Ctrl+B N para cambiar de ventana
```

---

## Resumen del flujo completo

```
┌──────────────────────────────────────────────────────────────────┐
│  1. Configuración inicial (una sola vez)                         │
│                                                                  │
│  Se hace que la IA lea HOW_TO_AGENTS.md                          │
│       │                                                          │
│       ▼                                                          │
│  La IA analiza la estructura del proyecto                        │
│       │                                                          │
│       ▼                                                          │
│  Genera AGENTS.md en cada directorio   Organiza conocimiento en  │
│  (identidad + reglas + permisos        .ai-agents/context/              │
│   del agente)                          (specs de API, modelos,   │
│                                         eventos)                 │
│  Define flujos en .ai-agents/skills/          Define roles en           │
│  (desarrollo, deploy, review)          .ai-agents/roles/                │
│                                        (Backend, Frontend, SRE)  │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  2. Uso diario                                                   │
│                                                                  │
│  Ejecutar ./ai-agency.sh                                  │
│       │                                                          │
│       ▼                                                          │
│  Seleccionar agente (¿PM? ¿Backend? ¿SRE?)                      │
│       │                                                          │
│       ▼                                                          │
│  Seleccionar herramienta IA (¿Claude? ¿Codex? ¿Cursor?)         │
│       │                                                          │
│       ▼                                                          │
│  Inicio de sesión → Carga AGENTS.md → Carga .ai-agents/context/        │
│  → ¡A trabajar!                                                  │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  3. Mantenimiento continuo                                       │
│                                                                  │
│  Cuando cambia el código:                                        │
│    - La IA actualiza .ai-agents/context/ automáticamente                │
│      (especificado como regla en AGENTS.md)                      │
│    - O el humano indica "esto es importante, regístralo"         │
│                                                                  │
│  Al agregar un nuevo servicio:                                   │
│    - Se ejecuta HOW_TO_AGENTS.md de nuevo → genera nuevo         │
│      AGENTS.md automáticamente                                   │
│    - Las reglas globales se heredan automáticamente               │
│                                                                  │
│  Cuando la IA se equivoca:                                       │
│    - "Analízalo de nuevo" → dar pistas → al comprender,          │
│      actualiza .ai-agents/context/                                      │
│    - Este ciclo de retroalimentación mejora la calidad            │
│      del contexto                                                │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## Lista de productos generados

Archivos creados por este sistema y sus respectivos propósitos:

| Archivo | Destinatario | Propósito |
|---|---|---|
| `HOW_TO_AGENTS.md` | IA | Meta-guía de instrucciones que el agente lee y ejecuta |
| `HOW_TO_AGENTS_PLAN.md` | Humano/IA | Plan de diseño (contexto de por qué esta estructura) |
| `README.md` | Humano | Este documento. Guía para comprensión humana |
| `ai-agency.sh` | Humano | Lanzador: selección de agente → inicio de sesión IA |
| `AGENTS.md` (cada directorio) | IA | Identidad del agente + reglas por directorio |
| `.ai-agents/context/*.md/json` | IA | Conocimiento de dominio organizado previamente |
| `.ai-agents/skills/*/SKILL.md` | IA | Flujos de trabajo estandarizados |
| `.ai-agents/roles/*.md` | IA/Humano | Estrategia de carga de contexto por rol |

---

## Analogía clave

```
              Equipo de desarrollo        Equipo de agentes IA
              tradicional                 ────────────────
 Líder        PM (humano)                 AGENTS.md raíz (agente PM)
 Miembros     N desarrolladores           AGENTS.md en cada directorio
 Doc. onboard Confluence/Notion           .ai-agents/context/
 Manual trab. Wiki del equipo             .ai-agents/skills/
 Def. roles   Doc. de cargos/R&R          .ai-agents/roles/
 Reglas equipo Doc. convenciones equipo   Global Conventions (herencia)
 Llegar       Llegar a la oficina         Inicio sesión → Carga AGENTS.md
 Salir        Salir (memoria intacta)     Fin sesión (¡memoria perdida!)
 Día siguiente Tiene memoria              Carga .ai-agents/context/ (memoria restaurada)
```

**Diferencia clave:** Los humanos conservan la memoria al salir del trabajo, pero la IA olvida todo cada vez.
Por eso existe `.ai-agents/context/` -- cumple el rol de **memoria a largo plazo** de la IA.

---

## Referencias

- [Flujo de trabajo IA del equipo OMS de Kurly](https://helloworld.kurly.com/blog/oms-claude-ai-workflow/) — Inspiración para el diseño de contexto de este sistema
- [Estándar AGENTS.md](https://agents.md/) — Estándar de instrucciones de agentes, agnóstico de proveedor
- [Investigación de ETH Zurich](https://www.infoq.com/news/2026/03/agents-context-file-value-review/) — "Solo registra lo que no se puede inferir"
