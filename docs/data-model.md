# Modelo de datos (Supabase / Postgres)

Esquema base del Núcleo de Conocimiento (Capa 0) y la Capa Operativa (Capa 1). Es un punto de partida — evoluciona por migración, nunca a mano en producción.

## Entidades

- **profiles** — miembros del equipo (planta y freelance). Extiende `auth.users`.
- **clients** — cuentas de la agencia (Cervecería Allende, City Market, …). Guarda el modelo (iguala/proyecto).
- **brands** — marcas dentro de un cliente (un cliente puede tener varias).
- **client_assignments** — quién trabaja en qué cuenta y con qué rol.
- **tasks** — la unidad operativa. Campo clave **`origin`** (`planned` vs `urgent`) para medir el ratio planeación/urgencia del north star.
- **task_comments** — el hilo de discusión por tarea.
- **processes** — SOPs (el conocimiento operativo documentado).
- **agents** — registro del ecosistema de agentes y su estado.

## Diagrama de relaciones

```
auth.users ──1:1── profiles ──< client_assignments >── clients ──< brands
                        │                                  │
                        │                                  └──< tasks ──< task_comments
                        └──< tasks (assignee / requested_by)
clients ──< processes        agents (registro global)
```

## Notas

- **RLS** queda habilitado en todas las tablas desde el inicio; las políticas finas se definen cuando exista auth de equipo. Mientras tanto el acceso es vía service role desde los servicios.
- Todo cambio de esquema entra como una nueva migración en `supabase/migrations/`.
- La métrica de "planeación vs urgencia" sale de `tasks.origin`; la de "bus factor" se aproxima con `client_assignments` (cuántas cuentas dependen de una sola persona).
