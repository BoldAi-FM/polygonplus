# PolygonPlus

**Ecosistema operativo automatizado para Polygon.**

PolygonPlus es la columna vertebral operativa de la agencia: planea, coordina, ejecuta, documenta y mide — para que **las personas dirijan y creen, y los agentes sostengan la operación.**

> Principio rector: **no robotizamos la agencia; liberamos a las mentes creativas para que creen y decidan.** Cada agente se juzga con una pregunta: *¿esto libera cerebro creativo, o lo reemplaza?* Solo construimos lo primero.

## North Star

Elevar la utilidad sobre el revenue, dejar todos los procesos documentados y automatizados, eliminar la dependencia de personas clave y dejar a la compañía en condiciones de ser vendida a un valor muy superior.

Documento fundacional: [`docs/plan-maestro.md`](docs/plan-maestro.md).

## Stack

| Capa | Servicio | Rol |
|------|----------|-----|
| Código + PM + verdad | **GitHub** | Repo monorepo, Issues/Projects, CI/CD, documentación |
| Datos | **Supabase** | Postgres + Auth + Storage · Núcleo de conocimiento |
| Frontend | **Vercel** | Dashboard por marca (Next.js) |
| Agentes | **Railway** | Workers, colas y cron de agentes |

## Estructura del monorepo

```
polygonplus/
├── docs/          # Documentación viva (plan maestro, ADRs, specs de agentes, SOPs)
├── apps/web/      # Next.js → Vercel (dashboard)
├── services/agents/  # Workers de agentes → Railway
├── packages/shared/  # Código y tipos compartidos
├── supabase/      # Esquema, migraciones, políticas
└── .github/       # CI/CD y plantillas de Issues/PR
```

## Cómo empezar (local)

```bash
pnpm install
pnpm dev          # levanta apps/web y services/agents
```

Requisitos: Node 20+, pnpm 9+. Copia `.env.example` a `.env.local` y llena las claves.

## Gestión del proyecto

GitHub es la fuente de verdad. **GitHub Projects** es el tablero maestro y **cada Issue es una tarea** con su dueño, su fase y su hilo. Cada tarea se trabaja en su propia sesión, ligada al número de Issue. Ninguna tarea se cierra sin dejar su rastro en `docs/`.

---
*Proyecto privado de Polygon. Documentado desde el commit #1.*
