# Supabase — PolygonPlus

Base de datos (Postgres), Auth y Storage. Aquí vive el Núcleo de Conocimiento y los datos operativos.

## Migraciones

- `migrations/0001_init.sql` — esquema base (clients, brands, tasks, comments, processes, agents, profiles).

Aplicar con la CLI de Supabase:

```bash
supabase db push        # aplica migraciones al proyecto enlazado
```

O pegar el SQL directo en el **SQL Editor** del proyecto para el primer arranque.

## Seed inicial sugerido

Cargar la cartera actual como `clients` (Cervecería Allende, City Market, San Pablo, Lalamove, Mi Consultorio, Copa, Quintazur, Polygon) y el equipo como `profiles`. Se hará en una tarea dedicada.

## Nota sobre RLS

Row Level Security está habilitado en todas las tablas desde el inicio. Hasta definir el auth del equipo, el acceso se hace con la **service role key** desde `services/agents`. Las políticas finas por rol se agregan en una migración posterior.
