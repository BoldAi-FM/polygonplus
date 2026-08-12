# ADR-0002 — GitHub como fuente de verdad y gestión por Issues

- **Estado:** aceptado
- **Fecha:** 2026-08-12
- **Decisores:** Felipe Madero, Claude (asesoría técnica)

## Contexto

El proyecto no debe vivir en conversaciones efímeras. Se requiere comunicación durable, hilos independientes por tarea y documentación desde el inicio.

## Decisión

- **GitHub Projects** es el tablero maestro del build.
- **Cada tarea = un Issue**, con dueño humano, etiqueta de fase y su propio hilo de discusión.
- Cada tarea se ejecuta en su **propia sesión de trabajo (Cowork/agente)** ligada al número de Issue.
- **"Terminado" incluye documentación:** ninguna tarea se cierra sin actualizar `docs/`.

## Alternativas consideradas

- **Notion / Linear encima de GitHub** — se pospone; añade una segunda fuente de verdad. Puede sumarse después como capa de vista si el equipo lo pide.
- **Todo en un chat de Claude** — descartado explícitamente: no es durable ni auditable.

## Consecuencias

Registro auditable y versionado de cada decisión y tarea. Este mismo andamiaje (tareas + hilos + dueños + tableros) se convierte en un prototipo del producto que operará las cuentas de Polygon.
