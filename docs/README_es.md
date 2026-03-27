🌐 [English](../README.md) | [한국어](README_ko.md) | [日本語](README_ja.md) | [中文](README_zh.md) | [Español](README_es.md) | [Français](README_fr.md) | [Deutsch](README_de.md) | [Русский](README_ru.md) | [हिन्दी](README_hi.md) | [العربية](README_ar.md)

# ai-initializer

**Generador automático de contexto de proyecto para herramientas de codificación con IA**

> Escanea el directorio de tu proyecto y genera automáticamente
> `AGENTS.md` + contexto de conocimiento/habilidades/roles para que los agentes de IA puedan empezar a trabajar de inmediato.

```
Un comando → Análisis del proyecto → Generación de AGENTS.md → Funciona con cualquier herramienta de IA
```

---

## Uso

> **Aviso sobre consumo de tokens** — Durante la configuración inicial, un modelo de primer nivel analiza todo el proyecto y genera múltiples archivos (AGENTS.md, .ai-agents/context/, .ai-agents/skills/, .ai-agents/roles/). Esto puede consumir decenas de miles de tokens dependiendo del tamaño del proyecto. Este es un costo único; las sesiones posteriores cargan el contexto preconstruido e inician instantáneamente.

```bash
# 1. Haz que la IA lea HOW_TO_AGENTS.md y se encargará del resto

# Opción A: Inglés (recomendado — menor costo de tokens, rendimiento óptimo de la IA)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Read HOW_TO_AGENTS.md and generate AGENTS.md tailored to this project"

# Opción B: Idioma del usuario (recomendado si planeas editar AGENTS.md manualmente)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Lee HOW_TO_AGENTS.md y genera AGENTS.md adaptado a este proyecto"

# Recomendado: --model claude-opus-4-6 (o posterior) para mejores resultados
# Recomendado: --dangerously-skip-permissions para ejecución autónoma sin interrupciones

# 2. Comienza a trabajar con los agentes generados
./ai-agency.sh
```

---

## ¿Por qué necesitas esto?

### El problema: La IA pierde su memoria en cada sesión

```
 Sesión 1                   Sesión 2                   Sesión 3
┌────────────┐             ┌────────────┐             ┌────────────┐
│ La IA lee  │             │ La IA lee  │             │ Empezando  │
│ todo el    │  La sesión  │ todo el    │  La sesión  │ desde      │
│ código     │  termina    │ código     │  termina    │ cero       │
│ (30 min)   │ ──────→     │ (30 min)   │ ──────→     │ otra vez   │
│ Empieza    │ ¡Memoria    │ Empieza    │ ¡Memoria    │ (30 min)   │
│ a          │ perdida!    │ a          │ perdida!    │ Empieza    │
│ trabajar   │             │ trabajar   │             │ a trabajar │
└────────────┘             └────────────┘             └────────────┘
```

Los agentes de IA olvidan todo cuando termina una sesión. Cada vez, gastan tiempo entendiendo la estructura del proyecto, analizando APIs y aprendiendo convenciones.

| Problema | Consecuencia |
|---|---|
| No conoce las convenciones del equipo | Inconsistencias en el estilo del código |
| No conoce el mapa completo de APIs | Explora todo el código cada vez (costo +20%) |
| No conoce las acciones prohibidas | Operaciones riesgosas como acceso directo a la BD de producción |
| No conoce las dependencias de servicios | Efectos secundarios no detectados |

### La solución: Preconstruir un "cerebro" para la IA

```
 Inicio de sesión
┌──────────────────────────────────────────────────┐
│                                                  │
│  Lee AGENTS.md (automático)                      │
│       │                                          │
│       ▼                                          │
│  "Soy el experto en backend de este servicio"    │
│  "Convenciones: Conventional Commits, TypeScript │
│   strict"                                        │
│  "Prohibido: modificar otros servicios,          │
│   hardcodear secretos"                           │
│       │                                          │
│       ▼                                          │
│  Carga archivos de .ai-agents/context/ (5 seg)   │
│  "20 APIs, 15 entidades, 8 eventos comprendidos" │
│       │                                          │
│       ▼                                          │
│  ¡Empieza a trabajar de inmediato!               │
│                                                  │
└──────────────────────────────────────────────────┘
```

**ai-initializer** resuelve esto — genera una vez, y cualquier herramienta de IA comprende tu proyecto instantáneamente.

---

## Principio fundamental: Arquitectura de 3 capas

```
                    Tu Proyecto
                         │
            ┌────────────┼────────────┐
            ▼            ▼            ▼

     ┌──────────┐  ┌──────────┐  ┌──────────┐
     │ AGENTS.md│  │.ai-agents│  │.ai-agents│
     │          │  │ /context/│  │ /skills/ │
     │ Identidad│  │Conocimien│  │Comporta- │
     │ "¿Quién  │  │ "¿Qué    │  │ "¿Cómo   │
     │  soy?"   │  │  sé?"    │  │ trabajo?"│
     │          │  │          │  │          │
     │ + Reglas │  │ + Dominio│  │ + Deploy │
     │ + Perms  │  │ + Modelos│  │ + Review │
     └──────────┘  └──────────┘  └──────────┘
      Punto de      Almacén de   Estándares de
      Entrada       Memoria      Flujo de Trabajo
```

### 1. AGENTS.md — "¿Quién soy?"

El **archivo de identidad** para el agente desplegado en cada directorio.

```
project/
├── AGENTS.md                  ← PM: El líder que coordina todo
├── apps/
│   └── api/
│       └── AGENTS.md          ← Experto en API: Responsable solo de este servicio
├── infra/
│   ├── AGENTS.md              ← SRE: Gestiona toda la infraestructura
│   └── monitoring/
│       └── AGENTS.md          ← Especialista en monitoreo
└── configs/
    └── AGENTS.md              ← Gestor de configuración
```

Funciona como un **organigrama de equipo**:
- El PM supervisa todo y distribuye tareas
- Cada miembro del equipo conoce profundamente solo su área
- No manejan directamente el trabajo de otros equipos — lo solicitan

### 2. `.ai-agents/context/` — "¿Qué sé?"

Una carpeta donde **el conocimiento esencial está preorganizado** para que la IA no tenga que leer el código cada vez.

```
.ai-agents/context/
├── domain-overview.md     ← "Este servicio gestiona pedidos..."
├── data-model.md          ← "Existen las entidades Order, Payment, Delivery..."
├── api-spec.json          ← "POST /orders, GET /orders/{id}, ..."
└── event-spec.json        ← "Publica el evento order-created..."
```

**Analogía:** Documentación de incorporación para un nuevo empleado. Documéntalo una vez, y nadie tiene que explicarlo de nuevo.

### 3. `.ai-agents/skills/` — "¿Cómo trabajo?"

**Manuales de flujo de trabajo estandarizados** para tareas repetitivas.

```
.ai-agents/skills/
├── develop/SKILL.md       ← "Desarrollo: Analizar → Diseñar → Implementar → Probar → PR"
├── deploy/SKILL.md        ← "Despliegue: Tag → Solicitar → Verificar"
└── review/SKILL.md        ← "Revisión: Checklist de seguridad, rendimiento y pruebas"
```

**Analogía:** El manual de operaciones del equipo — hace que la IA siga reglas como "revisar este checklist antes de enviar un PR."

---

## Qué escribir y qué no escribir

> ETH Zurich (2026.03): **Incluir contenido inferible reduce las tasas de éxito y aumenta el costo en +20%**

```
       Escribe esto                      No escribas esto
  ┌─────────────────────────┐     ┌─────────────────────────┐
  │                         │     │                         │
  │  "Usa formato feat:     │     │  "El código fuente está │
  │   para commits"         │     │   en la carpeta src/"   │
  │  La IA no puede         │     │  La IA puede verlo      │
  │  inferir esto           │     │  con ls                 │
  │                         │     │                         │
  │  "No hacer push directo │     │  "React está basado en  │
  │   a main"               │     │   componentes"          │
  │  Regla de equipo, no    │     │  Ya está en la          │
  │  está en el código      │     │   documentación oficial │
  │                         │     │                         │
  │  "Se requiere           │     │  "Este archivo tiene    │
  │   aprobación del equipo │     │   100 líneas"           │
  │   de QA antes del       │     │  La IA puede leerlo     │
  │   despliegue"           │     │   directamente          │
  │  Proceso, no inferible  │     │                         │
  │                         │     │                         │
  └─────────────────────────┘     └─────────────────────────┘
       Escríbelo en AGENTS.md          ¡NO lo escribas!
```

**Excepción:** "Cosas que se pueden inferir pero que son demasiado costosas de hacer cada vez"

```
  ej.: Lista completa de APIs (necesitas leer 20 archivos para averiguarlo)
  ej.: Relaciones del modelo de datos (dispersas en 10 archivos)
  ej.: Relaciones de llamadas entre servicios (necesitas revisar código + infraestructura)

  → ¡Preorganiza esto en .ai-agents/context/!
  → En AGENTS.md, solo escribe la ruta: "ve aquí para encontrarlo"
```

```
Incluir (no inferible)            .ai-agents/context/ (inferencia costosa)    Excluir (inferencia barata)
──────────────────────            ────────────────────────────────────        ────────────────────────
Convenciones del equipo           Mapa completo de APIs                       Estructura de directorios
Acciones prohibidas               Relaciones del modelo de datos              Contenido de archivos individuales
Formatos de PR/commits            Especificaciones de eventos pub/sub         Documentación oficial del framework
Dependencias ocultas              Topología de infraestructura                Relaciones de importación
```

---

## Cómo funciona

### Paso 1: Escaneo y clasificación del proyecto

Explora directorios hasta profundidad 3 y clasifica automáticamente por patrones de archivos.

```
deployment.yaml + service.yaml  →  k8s-workload
values.yaml (Helm)              →  infra-component
package.json + *.tsx            →  frontend
go.mod                          →  backend-go
Dockerfile + CI config          →  cicd
...19 tipos detectados automáticamente
```

### Paso 2: Generación de contexto

Genera archivos de conocimiento en `.ai-agents/context/` **analizando realmente el código** según los tipos detectados.

```
Servicio backend detectado
  → Escanear routes/controllers → Generar api-spec.json
  → Escanear entities/schemas   → Generar data-model.md
  → Escanear configuración Kafka → Generar event-spec.json
```

### Paso 3: Generación de AGENTS.md

Genera AGENTS.md para cada directorio usando plantillas apropiadas.

```
AGENTS.md raíz (Convenciones globales)
  → Commits: Conventional Commits
  → PR: Plantilla requerida, 1+ aprobaciones
  → Ramas: feature/{ticket}-{desc}
       │
       ▼ Auto-heredado (no se repite en los hijos)
  apps/api/AGENTS.md
    → Solo sobreescribe: "Este servicio usa Python"
```

Las reglas globales usan un **patrón de herencia** — escribe en un solo lugar, y se aplica automáticamente hacia abajo.

```
AGENTS.md raíz ──────────────────────────────────────────
│ Convenciones globales:
│  - Commits: Conventional Commits (feat:, fix:, chore:)
│  - PR: Plantilla requerida, al menos 1 revisor
│  - Rama: feature/{ticket}-{desc}
│
│     Auto-heredado                Auto-heredado
│     ┌──────────────────┐       ┌──────────────────┐
│     ▼                  │       ▼                  │
│  apps/api/AGENTS.md    │    infra/AGENTS.md       │
│  (Solo reglas          │    (Solo reglas          │
│   adicionales)         │     adicionales)         │
│  "Este servicio usa    │    "Al cambiar valores   │
│   Python"              │     de Helm, preguntar   │
│                        │     primero"             │
└─────────────────────────┴──────────────────────────
```

**Beneficios:**
- ¿Quieres cambiar las reglas de commits? → Modifica solo la raíz
- ¿Agregar un nuevo servicio? → Las reglas globales se aplican automáticamente
- ¿Necesitas reglas diferentes para un servicio específico? → Sobreescríbelas en el AGENTS.md de ese servicio

### Paso 4: Bootstrap específico por herramienta

Agrega puentes a configuraciones específicas de cada herramienta para que **todas las herramientas de IA lean** el AGENTS.md generado.

```
┌──────────────┐     ┌─────────────┐     ┌─────────────┐
│ Claude Code  │     │   Cursor    │     │   Codex     │
│  CLAUDE.md   │     │  .mdc rules │     │  AGENTS.md  │
│      ↓       │     │      ↓      │     │  (nativo)   │
│ "leer        │     │ "leer       │     │      ✓      │
│  AGENTS.md"  │     │  AGENTS.md" │     │             │
└──────┬───────┘     └──────┬──────┘     └─────────────┘
       └──────────┬─────────┘
                  ▼
           AGENTS.md (fuente única de verdad)
                  │
        ┌─────────┼─────────┐
        ▼         ▼         ▼
  .ai-agents/  .ai-agents/  .ai-agents/
   context/     skills/      roles/
```

> **Principio:** Los archivos de bootstrap solo se generan para las herramientas que ya están en uso. Nunca se crean archivos de configuración para herramientas no utilizadas.

---

## Compatibilidad con herramientas

| Herramienta | Lee AGENTS.md automáticamente | Bootstrap |
|---|---|---|
| **OpenAI Codex** | Sí (nativo) | No necesario |
| **Claude Code** | Parcial (fallback) | Agrega directiva a `CLAUDE.md` |
| **Cursor** | No | Agrega `.mdc` a `.cursor/rules/` |
| **GitHub Copilot** | No | Genera `.github/copilot-instructions.md` |
| **Windsurf** | No | Agrega directiva a `.windsurfrules` |
| **Aider** | Sí | Agrega lectura a `.aider.conf.yml` |

Generar bootstraps automáticamente:
```bash
bash scripts/sync-ai-rules.sh
```

---

## Estructura generada

```
project-root/
├── AGENTS.md                          # Agente PM (orquestación general)
├── .ai-agents/
│   ├── context/                       # Archivos de conocimiento (se cargan al inicio de sesión)
│   │   ├── domain-overview.md         #   Dominio de negocio, políticas, restricciones
│   │   ├── data-model.md             #   Definiciones de entidades, relaciones, transiciones de estado
│   │   ├── api-spec.json              #   Mapa de APIs (JSON DSL, 3x ahorro de tokens)
│   │   ├── event-spec.json            #   Especificaciones de eventos Kafka/MQ
│   │   ├── infra-spec.md              #   Charts de Helm, redes, orden de despliegue
│   │   └── external-integration.md    #   APIs externas, autenticación, límites de tasa
│   ├── skills/                        # Flujos de trabajo de comportamiento (se cargan bajo demanda)
│   │   ├── develop/SKILL.md           #   Desarrollo: analizar → diseñar → implementar → probar → PR
│   │   ├── deploy/SKILL.md            #   Despliegue: tag → solicitud de despliegue → verificar
│   │   ├── review/SKILL.md            #   Revisión: basada en checklist
│   │   ├── hotfix/SKILL.md            #   Flujo de corrección de emergencia
│   │   └── context-update/SKILL.md    #   Procedimiento de actualización de contexto
│   └── roles/                         # Definiciones de roles (profundidad de contexto por rol)
│       ├── pm.md                      #   Project Manager
│       ├── backend.md                 #   Desarrollador Backend
│       ├── frontend.md                #   Desarrollador Frontend
│       ├── sre.md                     #   SRE / Infraestructura
│       └── reviewer.md               #   Revisor de Código
│
├── apps/
│   ├── api/AGENTS.md                  # Agentes por servicio
│   └── web/AGENTS.md
└── infra/
    └── helm/AGENTS.md
```

---

## Lanzador de sesiones

Una vez que todos los agentes están configurados, elige el agente deseado e inicia una sesión de inmediato.

```bash
$ ./ai-agency.sh

=== Sesiones de Agentes IA ===
Encontrados: 8 agente(s)

  1) [PM] project-root
  2) api-service
  3) monitoring
  ...

Seleccionar agente (número): 2

=== Herramienta de IA ===
  1) claude
  2) codex
  3) print

Seleccionar herramienta: 1

→ Sesión iniciada en el directorio api-service
→ El agente carga automáticamente AGENTS.md y .ai-agents/context/
→ ¡Listo para trabajar de inmediato!
```

**Ejecución en paralelo (tmux):**

```bash
$ ./ai-agency.sh --multi

Seleccionar agentes: 1,2,3   # Ejecutar PM + API + Monitoring simultáneamente

→ 3 sesiones tmux abiertas
→ Diferentes agentes trabajan independientemente en cada panel
→ Cambiar de panel con Ctrl+B N
```

---

## Optimización de tokens

| Formato | Cantidad de tokens | Notas |
|---|---|---|
| Descripción de API en lenguaje natural | ~200 tokens | |
| JSON DSL | ~70 tokens | **3x de ahorro** |

**Ejemplo de api-spec.json:**
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

**Objetivo de AGENTS.md:** Menos de **300 tokens** después de la sustitución

---

## Protocolo de restauración de sesión

```
Inicio de sesión:
  1. Leer AGENTS.md (la mayoría de herramientas de IA lo hacen automáticamente)
  2. Seguir las rutas de archivos de contexto para cargar .ai-agents/context/
  3. Verificar .ai-agents/context/current-work.md (trabajo en progreso)
  4. git log --oneline -10 (entender cambios recientes)

Fin de sesión:
  1. Trabajo en progreso → Registrar en current-work.md
  2. Conocimiento de dominio recién aprendido → Actualizar archivos de contexto
  3. TODOs incompletos → Registrar explícitamente
```

---

## Mantenimiento del contexto

Cuando el código cambia, los archivos de `.ai-agents/context/` deben actualizarse correspondientemente.

```
API agregada/cambiada/eliminada   →  Actualizar api-spec.json
Esquema de BD cambiado            →  Actualizar data-model.md
Especificación de eventos cambiada →  Actualizar event-spec.json
Política de negocio cambiada      →  Actualizar domain-overview.md
Integración externa cambiada      →  Actualizar external-integration.md
Configuración de infra cambiada   →  Actualizar infra-spec.md
```

> No actualizar significa que la próxima sesión **trabajará con contexto desactualizado**.

---

## Resumen del flujo general

```
┌──────────────────────────────────────────────────────────────────┐
│  1. Configuración inicial (una sola vez)                         │
│                                                                  │
│  Haz que la IA lea HOW_TO_AGENTS.md                              │
│       │                                                          │
│       ▼                                                          │
│  La IA analiza la estructura del proyecto                        │
│       │                                                          │
│       ▼                                                          │
│  Crea AGENTS.md en cada            Organiza conocimiento en      │
│  directorio                        .ai-agents/context/           │
│  (identidad del agente + reglas    (especificaciones de API,     │
│   + permisos)                       modelo, eventos)             │
│                                                                  │
│  Define flujos de trabajo en       Define roles en               │
│  .ai-agents/skills/               .ai-agents/roles/              │
│  (procedimientos de desarrollo,    (Backend, Frontend, SRE)      │
│   despliegue, revisión)                                          │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  2. Uso diario                                                   │
│                                                                  │
│  Ejecutar ./ai-agency.sh                                         │
│       │                                                          │
│       ▼                                                          │
│  Seleccionar agente (¿PM? ¿Backend? ¿SRE?)                       │
│       │                                                          │
│       ▼                                                          │
│  Seleccionar herramienta de IA (¿Claude? ¿Codex? ¿Cursor?)       │
│       │                                                          │
│       ▼                                                          │
│  Sesión inicia → AGENTS.md cargado automáticamente →             │
│  .ai-agents/context/ cargado → ¡A trabajar!                      │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────┐
│  3. Mantenimiento continuo                                       │
│                                                                  │
│  Cuando el código cambia:                                        │
│    - La IA actualiza automáticamente .ai-agents/context/         │
│    - O un humano instruye "Esto es importante, regístralo"       │
│                                                                  │
│  Al agregar un nuevo servicio:                                   │
│    - Ejecutar HOW_TO_AGENTS.md de nuevo → Nuevo AGENTS.md        │
│      generado automáticamente                                    │
│    - Las reglas globales se heredan automáticamente              │
│                                                                  │
│  Cuando la IA comete errores:                                    │
│    - "Reanaliza esto" → Dar pistas → Una vez que entienda,       │
│      actualizar .ai-agents/context/                              │
│    - Este ciclo de retroalimentación mejora la calidad del       │
│      contexto                                                    │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

---

## Analogía: Equipo tradicional vs equipo de agentes IA

```
              Equipo de desarrollo         Equipo de agentes IA
              tradicional
              ────────────────────         ──────────────────
 Líder        PM (humano)                  AGENTS.md raíz (agente PM)
 Miembros     N desarrolladores            AGENTS.md en cada directorio
 Incorporación Confluence/Notion           .ai-agents/context/
 Manuales     Wiki del equipo              .ai-agents/skills/
 Def. roles   Títulos/docs de R&R          .ai-agents/roles/
 Reglas       Docs de convenciones         Convenciones globales (heredadas)
 Entrada      Llegar a la oficina          Sesión inicia → AGENTS.md cargado
 Salida       Irse (memoria retenida)      Sesión termina (¡memoria perdida!)
 Día sig.     Memoria intacta              .ai-agents/context/ cargado (memoria restaurada)
```

**Diferencia clave:** Los humanos retienen su memoria después de salir del trabajo, pero la IA olvida todo cada vez.
Por eso existe `.ai-agents/context/` — sirve como la **memoria a largo plazo** de la IA.

---

## Lista de verificación de adopción

```
Fase 1 (Básicos)               Fase 2 (Contexto)                Fase 3 (Operaciones)
────────────────               ─────────────────                ────────────────────
☐ Generar AGENTS.md            ☐ Crear .ai-agents/context/      ☐ Definir .ai-agents/roles/
☐ Registrar comandos de        ☐ domain-overview.md             ☐ Ejecutar sesiones multi-agente
  build/test                   ☐ api-spec.json (DSL)            ☐ Flujos de .ai-agents/skills/
☐ Registrar convenciones       ☐ data-model.md                  ☐ Ciclo de retroalimentación
  y reglas                     ☐ Configurar reglas de             iterativa
☐ Convenciones globales          mantenimiento
☐ Bootstraps de herramientas
```

---

## Entregables

| Archivo | Audiencia | Propósito |
|---|---|---|
| `HOW_TO_AGENTS.md` | IA | Manual de meta-instrucciones que los agentes leen y ejecutan |
| `README.md` | Humano | Este documento — una guía para comprensión humana |
| `ai-agency.sh` | Humano | Selección de agente → Lanzador de sesiones de IA |
| `AGENTS.md` (cada directorio) | IA | Identidad del agente + reglas por directorio |
| `.ai-agents/context/*.md/json` | IA | Conocimiento de dominio preorganizado |
| `.ai-agents/skills/*/SKILL.md` | IA | Flujos de trabajo estandarizados |
| `.ai-agents/roles/*.md` | IA/Humano | Estrategias de carga de contexto por rol |

---

## Referencias

- [Flujo de trabajo de IA del equipo OMS de Kurly](https://helloworld.kurly.com/blog/oms-claude-ai-workflow/) — Inspiración para el diseño de contexto de este sistema
- [Estándar AGENTS.md](https://agents.md/) — Estándar de instrucciones de agentes agnóstico de herramientas
- [Investigación de ETH Zurich](https://www.infoq.com/news/2026/03/agents-context-file-value-review/) — "Solo documenta lo que no se puede inferir"

---

## Licencia

MIT

---

<p align="center">
  <sub>Reduce a cero el tiempo que los agentes de IA necesitan para comprender tu proyecto.</sub>
</p>
