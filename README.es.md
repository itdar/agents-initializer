# ai-initializer

**Generador automatico de contexto de proyecto para herramientas de codificacion con IA**

> Escanea el directorio de tu proyecto y genera automaticamente
> `AGENTS.md` + contexto de conocimiento/habilidades/roles para que los agentes de IA puedan comenzar a trabajar de inmediato.

```
Un comando → Analisis del proyecto → Generacion de AGENTS.md → Funciona con cualquier herramienta de IA
```

---

## Uso

> **Aviso sobre consumo de tokens** — Durante la configuracion inicial, un modelo de primer nivel analiza todo el proyecto y genera multiples archivos (AGENTS.md, .ai-agents/context/, .ai-agents/skills/, .ai-agents/roles/). Esto puede consumir decenas de miles de tokens dependiendo del tamano del proyecto. Es un costo unico; las sesiones posteriores cargan el contexto preconstruido e inician instantaneamente.

```bash
# 1. Haz que la IA lea HOW_TO_AGENTS.md y se encarga del resto

# Opcion A: Ingles (recomendado — menor costo de tokens, rendimiento optimo de la IA)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Read HOW_TO_AGENTS.md and generate AGENTS.md tailored to this project"

# Opcion B: Idioma del usuario (recomendado si planeas editar manualmente AGENTS.md)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "HOW_TO_AGENTS.md를 읽고 이 프로젝트에 맞게 AGENTS.md를 생성하라"

# Recomendado: --model claude-opus-4-6 (o posterior) para mejores resultados
# Recomendado: --dangerously-skip-permissions para ejecucion autonoma sin interrupciones

# 2. Comienza a trabajar con los agentes generados
./ai-agency.sh
```

---

## Por que necesitas esto?

Las herramientas de codificacion con IA **re-aprenden el proyecto desde cero** en cada sesion.

| Problema | Consecuencia |
|---|---|
| No conoce las convenciones del equipo | Inconsistencias en el estilo del codigo |
| No conoce el mapa completo de APIs | Explora todo el codigo base cada vez (costo +20%) |
| No conoce las acciones prohibidas | Operaciones riesgosas como acceso directo a la BD de produccion |
| No conoce las dependencias de servicios | Efectos secundarios no detectados |

**ai-initializer** resuelve esto — genera una vez, y cualquier herramienta de IA entiende tu proyecto al instante.

---

## Principios Fundamentales

> ETH Zurich (2026.03): **Incluir contenido inferible reduce las tasas de exito y aumenta el costo en +20%**

```
Incluir (no inferible)         .ai-agents/context/ (inferencia costosa)  Excluir (inferencia barata)
───────────────────────        ────────────────────────────────────      ────────────────────────
Convenciones del equipo        Mapa completo de APIs                     Estructura de directorios
Acciones prohibidas            Relaciones del modelo de datos            Contenido de archivos individuales
Formatos de PR/commits         Especificaciones de eventos pub/sub       Documentacion oficial del framework
Dependencias ocultas           Topologia de infraestructura              Relaciones de importacion
```

---

## Estructura Generada

```
project-root/
├── AGENTS.md                          # Agente PM (orquestacion general)
├── .ai-agents/
│   ├── context/                       # Archivos de conocimiento (cargados al inicio de sesion)
│   │   ├── domain-overview.md         #   Dominio de negocio, politicas, restricciones
│   │   ├── data-model.md              #   Definiciones de entidades, relaciones, transiciones de estado
│   │   ├── api-spec.json              #   Mapa de APIs (JSON DSL, 3x ahorro de tokens)
│   │   ├── event-spec.json            #   Especificaciones de eventos Kafka/MQ
│   │   ├── infra-spec.md              #   Helm charts, redes, orden de despliegue
│   │   └── external-integration.md    #   APIs externas, autenticacion, limites de tasa
│   ├── skills/                        # Flujos de comportamiento (cargados bajo demanda)
│   │   ├── develop/SKILL.md           #   Dev: analizar → disenar → implementar → probar → PR
│   │   ├── deploy/SKILL.md            #   Deploy: etiquetar → solicitar despliegue → verificar
│   │   ├── review/SKILL.md            #   Review: basado en checklist
│   │   ├── hotfix/SKILL.md            #   Flujo de correccion de emergencia
│   │   └── context-update/SKILL.md    #   Procedimiento de actualizacion de contexto
│   └── roles/                         # Definiciones de roles (profundidad de contexto por rol)
│       ├── pm.md                      #   Project Manager
│       ├── backend.md                 #   Desarrollador Backend
│       ├── frontend.md                #   Desarrollador Frontend
│       ├── sre.md                     #   SRE / Infraestructura
│       └── reviewer.md                #   Revisor de Codigo
│
├── apps/
│   ├── api/AGENTS.md                  # Agentes por servicio
│   └── web/AGENTS.md
└── infra/
    └── helm/AGENTS.md
```

---

## Como Funciona

### Paso 1: Escaneo y Clasificacion del Proyecto

Explora directorios hasta profundidad 3 y clasifica automaticamente por patrones de archivos.

```
deployment.yaml + service.yaml  →  k8s-workload
values.yaml (Helm)              →  infra-component
package.json + *.tsx            →  frontend
go.mod                          →  backend-go
Dockerfile + CI config          →  cicd
...19 tipos detectados automaticamente
```

### Paso 2: Generacion de Contexto

Genera archivos de conocimiento en `.ai-agents/context/` **analizando realmente el codigo** basandose en los tipos detectados.

```
Servicio backend detectado
  → Escanear rutas/controladores → Generar api-spec.json
  → Escanear entidades/esquemas  → Generar data-model.md
  → Escanear configuracion Kafka → Generar event-spec.json
```

### Paso 3: Generacion de AGENTS.md

Genera AGENTS.md para cada directorio usando las plantillas apropiadas.

```
AGENTS.md raiz (Convenciones Globales)
  → Commits: Conventional Commits
  → PR: Plantilla requerida, 1+ aprobaciones
  → Ramas: feature/{ticket}-{desc}
       │
       ▼ Heredado automaticamente (no se repite en los hijos)
  apps/api/AGENTS.md
    → Solo sobreescribe: "Este servicio usa Python"
```

### Paso 4: Bootstrap Especifico por Proveedor

Agrega puentes a configuraciones especificas de cada proveedor para que **todas las herramientas de IA lean** el AGENTS.md generado.

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
           AGENTS.md (fuente unica de verdad)
                  │
        ┌─────────┼─────────┐
        ▼         ▼         ▼
  .ai-agents/  .ai-agents/  .ai-agents/
   context/     skills/      roles/
```

> **Principio:** Los archivos de bootstrap solo se generan para los proveedores que ya estan en uso. Nunca se crean archivos de configuracion para herramientas no utilizadas.

---

## Compatibilidad con Proveedores

| Herramienta | Lee AGENTS.md automaticamente | Bootstrap |
|---|---|---|
| **OpenAI Codex** | Si (nativo) | No necesario |
| **Claude Code** | Parcial (respaldo) | Agrega directiva a `CLAUDE.md` |
| **Cursor** | No | Agrega `.mdc` a `.cursor/rules/` |
| **GitHub Copilot** | No | Genera `.github/copilot-instructions.md` |
| **Windsurf** | No | Agrega directiva a `.windsurfrules` |
| **Aider** | Si | Agrega lectura a `.aider.conf.yml` |

Generar bootstraps automaticamente:
```bash
bash scripts/sync-ai-rules.sh
```

---

## Estructura Jerarquica de Agentes

```
┌───────────────────────────────────────┐
│  Agente PM Raiz (AGENTS.md)           │
│  Convenciones Globales + Reglas de    │
│  Delegacion                           │
│  "Validacion de diseno > Validacion   │
│   de codigo"                          │
└────────┬──────────┬─────────┬────────┘
         │          │         │
    ┌────▼────┐ ┌───▼────┐ ┌──▼─────┐
    │ Experto │ │ Infra  │ │  Docs  │
    │  en     │ │  SRE   │ │Planifi-│
    │Servicio │ │        │ │ cador  │
    └─────────┘ └────────┘ └────────┘

Delegacion:    Padre → Hijo (opera dentro del alcance del AGENTS.md de ese directorio)
Reporte:       Hijo → Padre (resumen de cambios tras completar la tarea)
Coordinacion:  Sin comunicacion directa entre pares — coordinacion indirecta a traves del padre
```

---

## Optimizacion de Tokens

| Formato | Cantidad de Tokens | Notas |
|---|---|---|
| Descripcion de API en lenguaje natural | ~200 tokens | |
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

**Objetivo de AGENTS.md:** Menos de **300 tokens** despues de la sustitucion

---

## Protocolo de Restauracion de Sesion

```
Inicio de sesion:
  1. Leer AGENTS.md (la mayoria de herramientas de IA lo hacen automaticamente)
  2. Seguir las rutas de archivos de contexto para cargar .ai-agents/context/
  3. Verificar .ai-agents/context/current-work.md (trabajo en progreso)
  4. git log --oneline -10 (entender los cambios recientes)

Fin de sesion:
  1. Trabajo en progreso → Registrar en current-work.md
  2. Conocimiento de dominio recien aprendido → Actualizar archivos de contexto
  3. TODOs incompletos → Registrar explicitamente
```

---

## Mantenimiento del Contexto

Cuando el codigo cambia, los archivos en `.ai-agents/context/` deben actualizarse correspondientemente.

```
API agregada/modificada/eliminada  →  Actualizar api-spec.json
Esquema de BD modificado           →  Actualizar data-model.md
Especificacion de eventos cambiada →  Actualizar event-spec.json
Politica de negocio cambiada       →  Actualizar domain-overview.md
Integracion externa cambiada       →  Actualizar external-integration.md
Configuracion de infra cambiada    →  Actualizar infra-spec.md
```

> No actualizar significa que la proxima sesion **trabajara con contexto desactualizado**.

---

## Lista de Verificacion para Adopcion

```
Fase 1 (Basicos)                Fase 2 (Contexto)                Fase 3 (Operaciones)
────────────────                ─────────────────                ────────────────────
☐ Generar AGENTS.md             ☐ Crear .ai-agents/context/      ☐ Definir .ai-agents/roles/
☐ Registrar comandos            ☐ domain-overview.md              ☐ Ejecutar sesiones multi-agente
  de build/test                 ☐ api-spec.json (DSL)             ☐ Flujos en .ai-agents/skills/
☐ Registrar convenciones        ☐ data-model.md                   ☐ Ciclo de retroalimentacion
  y reglas                      ☐ Configurar reglas                 iterativo
☐ Convenciones Globales           de mantenimiento
☐ Bootstraps de proveedores
```

---

## Licencia

MIT

---

<p align="center">
  <sub>Reduce a cero el tiempo que los agentes de IA necesitan para entender tu proyecto.</sub>
</p>
