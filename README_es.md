🌐 [English](README.md) | [한국어](README_ko.md) | [日本語](README_ja.md) | [中文](README_zh.md) | [Español](README_es.md) | [Français](README_fr.md) | [Deutsch](README_de.md) | [Русский](README_ru.md) | [हिन्दी](README_hi.md) | [العربية](README_ar.md)

# ai-initializer

**Generador automático de contexto de proyecto para herramientas de codificación con IA**

> Escanea el directorio de tu proyecto y genera automáticamente
> `AGENTS.md` + contexto de conocimiento/habilidades/roles para que los agentes de IA puedan comenzar a trabajar de inmediato.

```
Un comando → Análisis del proyecto → Generación de AGENTS.md → Funciona con cualquier herramienta de IA
```

---

## Uso

> **Aviso sobre el uso de tokens** — Durante la configuración inicial, un modelo de primer nivel analiza todo el proyecto y genera múltiples archivos (AGENTS.md, .ai-agents/context/, .ai-agents/skills/, .ai-agents/roles/). Esto puede consumir decenas de miles de tokens dependiendo del tamaño del proyecto. Este es un costo único; las sesiones posteriores cargan el contexto preconstruido e inician instantáneamente.

```bash
# 1. Haz que la IA lea HOW_TO_AGENTS.md y se encarga del resto

# Opción A: Inglés (recomendado — menor costo de tokens, rendimiento óptimo de la IA)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "Read HOW_TO_AGENTS.md and generate AGENTS.md tailored to this project"

# Opción B: Idioma del usuario (recomendado si planeas editar AGENTS.md manualmente)
claude --dangerously-skip-permissions --model claude-opus-4-6 \
  "HOW_TO_AGENTS.md를 읽고 이 프로젝트에 맞게 AGENTS.md를 생성하라"

# Recomendado: --model claude-opus-4-6 (o posterior) para mejores resultados
# Recomendado: --dangerously-skip-permissions para ejecución autónoma sin interrupciones

# 2. Comienza a trabajar con los agentes generados
./ai-agency.sh
```

---

## ¿Por qué necesitas esto?

Las herramientas de codificación con IA **re-aprenden el proyecto desde cero** en cada sesión.

| Problema | Consecuencia |
|---|---|
| No conoce las convenciones del equipo | Inconsistencias en el estilo de código |
| No conoce el mapa completo de APIs | Explora todo el código base cada vez (costo +20%) |
| No conoce las acciones prohibidas | Operaciones riesgosas como acceso directo a la BD de producción |
| No conoce las dependencias de servicios | Efectos secundarios no detectados |

**ai-initializer** resuelve esto — genera una vez, y cualquier herramienta de IA comprende tu proyecto al instante.

---

## Principios Fundamentales

> ETH Zurich (2026.03): **Incluir contenido inferible reduce las tasas de éxito y aumenta el costo en +20%**

```
Incluir (no inferible)            .ai-agents/context/ (inferencia costosa)  Excluir (inferencia económica)
───────────────────────           ────────────────────────────────────      ────────────────────────
Convenciones del equipo           Mapa completo de APIs                     Estructura de directorios
Acciones prohibidas               Relaciones del modelo de datos            Contenido de archivos individuales
Formatos de PR/commit             Especificaciones de eventos pub/sub       Documentación oficial del framework
Dependencias ocultas              Topología de infraestructura              Relaciones de importación
```

---

## Estructura Generada

```
project-root/
├── AGENTS.md                          # Agente PM (orquestación general)
├── .ai-agents/
│   ├── context/                       # Archivos de conocimiento (cargados al inicio de sesión)
│   │   ├── domain-overview.md         #   Dominio de negocio, políticas, restricciones
│   │   ├── data-model.md              #   Definiciones de entidades, relaciones, transiciones de estado
│   │   ├── api-spec.json              #   Mapa de APIs (JSON DSL, 3x ahorro de tokens)
│   │   ├── event-spec.json            #   Especificaciones de eventos Kafka/MQ
│   │   ├── infra-spec.md              #   Helm charts, redes, orden de despliegue
│   │   └── external-integration.md    #   APIs externas, autenticación, límites de tasa
│   ├── skills/                        # Flujos de trabajo conductuales (cargados bajo demanda)
│   │   ├── develop/SKILL.md           #   Desarrollo: analizar → diseñar → implementar → probar → PR
│   │   ├── deploy/SKILL.md            #   Despliegue: etiquetar → solicitar despliegue → verificar
│   │   ├── review/SKILL.md            #   Revisión: basada en checklist
│   │   ├── hotfix/SKILL.md            #   Flujo de corrección de emergencia
│   │   └── context-update/SKILL.md    #   Procedimiento de actualización de archivos de contexto
│   └── roles/                         # Definiciones de roles (profundidad de contexto por rol)
│       ├── pm.md                      #   Gerente de Proyecto
│       ├── backend.md                 #   Desarrollador Backend
│       ├── frontend.md                #   Desarrollador Frontend
│       ├── sre.md                     #   SRE / Infraestructura
│       └── reviewer.md                #   Revisor de Código
│
├── apps/
│   ├── api/AGENTS.md                  # Agentes por servicio
│   └── web/AGENTS.md
└── infra/
    └── helm/AGENTS.md
```

---

## Cómo Funciona

### Paso 1: Escaneo y Clasificación del Proyecto

Explora directorios hasta profundidad 3 y clasifica automáticamente por patrones de archivos.

```
deployment.yaml + service.yaml  →  k8s-workload
values.yaml (Helm)              →  infra-component
package.json + *.tsx            →  frontend
go.mod                          →  backend-go
Dockerfile + CI config          →  cicd
...19 tipos detectados automáticamente
```

### Paso 2: Generación de Contexto

Genera archivos de conocimiento en `.ai-agents/context/` **analizando realmente el código** según los tipos detectados.

```
Servicio backend detectado
  → Escanear rutas/controladores → Generar api-spec.json
  → Escanear entidades/esquemas  → Generar data-model.md
  → Escanear configuración Kafka → Generar event-spec.json
```

### Paso 3: Generación de AGENTS.md

Genera AGENTS.md para cada directorio usando las plantillas apropiadas.

```
AGENTS.md raíz (Convenciones Globales)
  → Commits: Conventional Commits
  → PR: Plantilla requerida, 1+ aprobaciones
  → Ramas: feature/{ticket}-{desc}
       │
       ▼ Heredado automáticamente (no se repite en los hijos)
  apps/api/AGENTS.md
    → Solo sobreescrituras: "Este servicio usa Python"
```

### Paso 4: Bootstrap Específico por Proveedor

Agrega puentes a configuraciones específicas de proveedores para que **todas las herramientas de IA lean** el AGENTS.md generado.

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

> **Principio:** Los archivos de bootstrap solo se generan para los proveedores que ya están en uso. Nunca se crean archivos de configuración para herramientas no utilizadas.

---

## Compatibilidad con Proveedores

| Herramienta | Lee AGENTS.md automáticamente | Bootstrap |
|---|---|---|
| **OpenAI Codex** | Sí (nativo) | No necesario |
| **Claude Code** | Parcial (respaldo) | Agrega directiva a `CLAUDE.md` |
| **Cursor** | No | Agrega `.mdc` a `.cursor/rules/` |
| **GitHub Copilot** | No | Genera `.github/copilot-instructions.md` |
| **Windsurf** | No | Agrega directiva a `.windsurfrules` |
| **Aider** | Sí | Agrega lectura a `.aider.conf.yml` |

Generar bootstraps automáticamente:
```bash
bash scripts/sync-ai-rules.sh
```

---

## Estructura Jerárquica de Agentes

```
┌───────────────────────────────────────┐
│  Agente PM Raíz (AGENTS.md)          │
│  Convenciones Globales + Reglas de   │
│  Delegación                           │
│  "Validación de diseño > Validación  │
│   de código"                          │
└────────┬──────────┬─────────┬────────┘
         │          │         │
    ┌────▼────┐ ┌───▼────┐ ┌──▼─────┐
    │Experto  │ │ Infra  │ │Planif. │
    │Servicio │ │  SRE   │ │ Docs   │
    └─────────┘ └────────┘ └────────┘

Delegación:    Padre → Hijo (opera dentro del alcance del AGENTS.md de ese directorio)
Reporte:       Hijo → Padre (resumen de cambios tras completar la tarea)
Coordinación:  Sin comunicación directa entre pares — coordinación indirecta a través del padre
```

---

## Optimización de Tokens

| Formato | Cantidad de Tokens | Notas |
|---|---|---|
| Descripción de API en lenguaje natural | ~200 tokens | |
| JSON DSL | ~70 tokens | **3x ahorro** |

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

## Protocolo de Restauración de Sesión

```
Inicio de sesión:
  1. Leer AGENTS.md (la mayoría de las herramientas de IA lo hacen automáticamente)
  2. Seguir las rutas de archivos de contexto para cargar .ai-agents/context/
  3. Verificar .ai-agents/context/current-work.md (trabajo en progreso)
  4. git log --oneline -10 (entender cambios recientes)

Fin de sesión:
  1. Trabajo en progreso → Registrar en current-work.md
  2. Conocimiento de dominio recién aprendido → Actualizar archivos de contexto
  3. TODOs incompletos → Registrar explícitamente
```

---

## Mantenimiento del Contexto

Cuando el código cambia, los archivos en `.ai-agents/context/` deben actualizarse correspondientemente.

```
API agregada/modificada/eliminada   →  Actualizar api-spec.json
Esquema de BD modificado            →  Actualizar data-model.md
Especificación de eventos modificada→  Actualizar event-spec.json
Política de negocio modificada      →  Actualizar domain-overview.md
Integración externa modificada      →  Actualizar external-integration.md
Configuración de infraestructura    →  Actualizar infra-spec.md
modificada
```

> No actualizar significa que la próxima sesión **trabajará con contexto desactualizado**.

---

## Lista de Verificación de Adopción

```
Fase 1 (Básicos)                Fase 2 (Contexto)                 Fase 3 (Operaciones)
────────────────                ─────────────────                 ────────────────────
☐ Generar AGENTS.md            ☐ Crear .ai-agents/context/       ☐ Definir .ai-agents/roles/
☐ Registrar comandos           ☐ domain-overview.md              ☐ Ejecutar sesiones multi-agente
  build/test                   ☐ api-spec.json (DSL)             ☐ Flujos .ai-agents/skills/
☐ Registrar convenciones       ☐ data-model.md                   ☐ Ciclo de retroalimentación
  y reglas                     ☐ Configurar reglas de              iterativo
☐ Convenciones Globales          mantenimiento
☐ Bootstraps de proveedores
```

---

## Licencia

MIT

---

<p align="center">
  <sub>Reduce a cero el tiempo que los agentes de IA necesitan para comprender tu proyecto.</sub>
</p>
