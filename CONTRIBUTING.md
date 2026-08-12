# Cómo trabajamos en PolygonPlus

1. **Toda tarea es un Issue.** Se abre con la plantilla de Tarea, con dueño humano y fase.
2. **Un hilo por tarea.** Cada tarea se trabaja en su propia sesión, ligada al número de Issue. La discusión durable vive en el Issue, no en un chat.
3. **Ramas.** `main` protegida. Trabajo en ramas `feat/…`, `fix/…`, `docs/…`. PR hacia `main`.
4. **"Terminado" incluye documentar.** Ningún Issue se cierra sin dejar rastro en `docs/`.
5. **Decisiones de arquitectura → ADR.** Usa `docs/adr/template.md`.
6. **Nada de secretos en el repo.** Solo `.env.example`; las claves reales van en Vercel/Railway/Supabase.

## Setup

```bash
pnpm install
cp .env.example .env.local   # llena las claves
pnpm dev
```
