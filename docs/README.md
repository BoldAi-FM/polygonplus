# Documentación de PolygonPlus

Toda decisión y todo proceso deja rastro aquí. Regla de oro: **ninguna tarea se cierra sin actualizar la documentación.**

## Índice

- [`plan-maestro.md`](plan-maestro.md) — documento fundacional (v3, vigente): north star, diagnóstico, arquitectura, roadmap. **Fuente de verdad de la estrategia.**
- [`modelo-operativo.md`](modelo-operativo.md) — modelo operativo objetivo: cómo debe operar Polygon, el modelo que la plataforma va a imponer.
- [`studio-diagnostico.md`](studio-diagnostico.md) — diagnóstico del "PolygonPlus Studio" (trabajo previo): qué se reutiliza y cómo se integra.
- [`studio-audit.md`](studio-audit.md) — auditoría técnica de los repos del Studio (backend + frontend).
- [`studio-security-hardening.md`](studio-security-hardening.md) — spec as-built del hardening de seguridad del Studio.
- [`roadmap.md`](roadmap.md) — fases y estado de avance.
- [`data-model.md`](data-model.md) — modelo de datos (esquema de Supabase).
- [`adr/`](adr/) — Architecture Decision Records: cada decisión técnica importante, versionada.
- [`agents/`](agents/) — spec de cada agente del ecosistema (input, output, dueño humano, fuentes).
- [`processes/`](processes/) — SOPs de la operación (el Núcleo de Conocimiento, Capa 0).

## Cómo contribuir a la documentación

1. Toda decisión de arquitectura → un ADR nuevo en `adr/` (usa `adr/template.md`).
2. Todo agente nuevo → un spec en `agents/` (usa `agents/_template.md`).
3. Todo proceso operativo → un SOP en `processes/`.
4. El Plan Maestro se versiona cuando cambia la estrategia (no para cambios menores).
