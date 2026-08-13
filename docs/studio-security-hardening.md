# Spec — Hardening de seguridad del PolygonPlus Studio

> **Estado:** implementado (as-built). PRs abiertos en los repos del Studio.
> **Origen:** hallazgos de seguridad de [`studio-audit.md`](studio-audit.md).
> **Decisión de diseño:** **Opción A** — los endpoints internos exigen JWT válido; el
> equipo interno se autentica reusando la infraestructura de login existente.
>
> Repos afectados:
> - `BoldAi-FM/polygonplus-studio-backend` — rama `fix/security-hardening` ([PR #1](https://github.com/BoldAi-FM/polygonplus-studio-backend/pull/1))
> - `BoldAi-FM/polygonplus-studio-frontend` — rama `fix/security-hardening` ([PR #1](https://github.com/BoldAi-FM/polygonplus-studio-frontend/pull/1))

---

## 1. Problema

La auditoría detectó que la operación interna del Studio estaba **abierta**:

- Los endpoints operativos (`/validate`, `/grid/generate`, `/action-plan/generate`, listados y exports) **no requerían autenticación** — cualquiera con la URL podía generar contenido y **quemar tokens de Claude**.
- `CORS` con `allow_origins=["*"]` **junto a** `allow_credentials=True` (combinación permisiva/ inválida).
- `JWT_SECRET` con un **default inseguro cableado** en el código.
- `.env.example` **no documentaba** `JWT_SECRET` ni las credenciales de Google.

## 2. Decisión: por qué Opción A

| Opción | Qué es | Veredicto |
|---|---|---|
| **A) Reusar el login JWT existente** ✅ | Las páginas internas ganan un login que pega a `/api/v1/client/login`; el equipo tiene cuentas; `require_auth` exige JWT válido | Seguridad real, cero infraestructura nueva |
| B) Token estático en el JS | Un token embebido en la PWA | ❌ El JS es **público** → el token se copia. No detiene el abuso de Claude |
| C) Login interno nuevo | Sistema de usuarios de equipo separado | Correcto pero más obra; se puede evolucionar hacia aquí |

La B parecía la más simple, pero como el frontend es **estático y público**, un secreto en el JS no protege contra la amenaza real (abuso de tokens). Se eligió **A**.

## 3. Los 4 fixes (as-built)

### Fix #1 — `require_auth` en los routers internos
`app/services/client_auth.py`: nueva dependency `require_auth` que exige `Authorization: Bearer <JWT>` y valida firma + expiración (no pega a la DB, así rechaza el tráfico anónimo antes de gastar Claude).

`app/api/router.py`: se aplica `dependencies=[Depends(require_auth)]` a los **6 routers internos**:
`validator`, `action_plan`, `grid`, `listing`, `slides_export`, `visual_references`.
Quedan **fuera**: `health` (público) y `client_portal` (conserva su `get_current_client`).

### Fix #2 — CORS desde env
`app/config.py`: nuevo campo `allowed_origins` + propiedad `cors_origins` (parsea lista coma-separada).
`app/main.py`: `allow_origins=get_settings().cors_origins` (ya no `"*"`); `allow_methods` y `allow_headers` acotados a lo necesario.

### Fix #3 — `JWT_SECRET` fail-fast
`app/services/client_auth.py`: se elimina el default. Si `JWT_SECRET` no está definido, el módulo lanza `RuntimeError` al import → **el server no arranca** (nunca firma tokens con un secreto público conocido).

### Fix #4 — `.env.example` completo
Documenta `JWT_SECRET` (obligatoria), `ALLOWED_ORIGINS`, `GOOGLE_CREDENTIALS_JSON` / `GOOGLE_CREDENTIALS_PATH` y los `CLAUDE_*`.

### Frontend — mandar el token
- `spn/login.html` (nuevo): login del equipo interno; reusa `POST /api/v1/client/login`, guarda `studio_token` en `localStorage`. Soporta `?next=` sin open-redirect.
- `spn/studio-auth.js` (nuevo): **guardia + wrapper de `fetch`**. Sin token → redirige a login. Adjunta `Authorization: Bearer` a **todas** las llamadas al backend (no solo las 3 principales — también historial, refetch por id, exports, regeneración, undo/redo; por eso no rompe prod). Ante `401` → limpia token y vuelve a login.
- Guardia incluido en las **5 páginas internas** que llaman al API: `spn/index`, `validator`, `grid`, `action-plan`, `visual-references`.
- El **portal de cliente** (`cliente-login.html` / `cliente.html`) queda intacto (usa su propio `client_token`).

## 4. Modelo de usuarios

Los usuarios internos viven en la **misma tabla `client_users`** (Opción A). Se crean con `scripts/create_client_user.py` (roles disponibles: `reviewer`, `normatividad`, `admin` — usar **`admin`** para el equipo interno). `require_auth` acepta cualquier JWT válido; el check opcional de rol (`role == "client"` → 403) queda comentado en `client_auth.py` por si se quiere separar equipo interno de clientes más adelante.

## 5. Variables de entorno (Railway — producción)

| Variable | Rol | Estado en Railway |
|---|---|---|
| `JWT_SECRET` | Firma de JWT — **obligatoria** (fail-fast) | ✅ seteada |
| `ALLOWED_ORIGINS` | Orígenes CORS (Vercel prod/preview + localhost) | ✅ seteada |
| `GOOGLE_CREDENTIALS_JSON` | Service Account para export a Slides | ✅ seteada |
| `ANTHROPIC_API_KEY`, `SUPABASE_URL`, `SUPABASE_KEY` | Ya existían | ✅ |

## 6. Verificación

**Backend** — `tests/test_auth.py` (20 casos, py3.11):
- sin token → **401** en los 6 endpoints internos
- token inválido → **401**
- token válido → **pasa auth** (ya no 401)
- `health` público; `client/login` accesible sin `require_auth`
- fail-fast: sin `JWT_SECRET` → `RuntimeError`
- CORS: `ALLOWED_ORIGINS` se parsea a lista

**Frontend** — wrapper probado (7 casos): sin token → login; con token → adjunta `Bearer` y preserva headers; no filtra token a hosts externos; `401` → limpia token y redirige.

## 7. Plan de deploy (orden obligatorio)

1. **Railway**: `JWT_SECRET`, `ALLOWED_ORIGINS`, `GOOGLE_CREDENTIALS_JSON` puestas **antes** del merge. ✅
2. **Crear ≥1 usuario interno** (`admin`) con `scripts/create_client_user.py`, **antes** del merge — si no, tras el deploy las páginas internas quedan sin nadie que pueda loguearse.
3. **Mergear los DOS PRs juntos** (backend + frontend). Nunca uno sin el otro: backend con auth + PWA vieja sin token = páginas internas caídas.
4. Verificar el arranque y el flujo (login → generar) en producción.

## 8. Rollback

Si algo falla tras el merge: revertir **ambos** merges (backend y frontend) y redeployar. Las variables de entorno pueden quedarse; no afectan al código previo. El portal de cliente no se toca en ningún momento.

---

*Documento vivo. Refleja la implementación de las ramas `fix/security-hardening` de ambos repos del Studio.*
