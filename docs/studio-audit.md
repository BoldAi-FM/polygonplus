# Auditoría — PolygonPlus Studio (backend + frontend)

> **Objetivo:** evaluar los dos repos existentes del "PolygonPlus Studio" para decidir cómo se integran a la plataforma PolygonPlus.
> **Alcance:** auditoría de **solo lectura**. No se modificó nada en los repos auditados.
> **Repos auditados:**
> - `BoldAi-FM/polygonplus-studio-backend` — FastAPI/Python, corre en Railway.
> - `BoldAi-FM/polygonplus-studio-frontend` — PWA estática, corre en Vercel.
>
> Fecha: 2026-08-12 · Autor: auditoría técnica asistida.

---

## Resumen ejecutivo

El Studio **no es un experimento** — es un producto vertical que ya funciona en producción para **una** cuenta real: **San Pablo Natural (SPN, `account_id=1`)**. Cubre un flujo creativo completo: planeación (Action Plan) → generación de parrilla (Grid) → **validación legal/pharma automática (13 checks)** → exportación a Google Slides / PDF → **portal de cliente** con login, dashboard, feedback y aprobación.

Es, en la práctica, **una rebanada funcional de la Capa 3 (Ejecución táctica)** del plan maestro, más un pedazo de la **Capa 1 (Operativa)** vía el portal de cliente — pero construido *client-first* para SPN, no *platform-first*.

**Veredicto en una línea:** se **conserva el motor** (validador pharma, repositorio legal, exportador de Slides, auth JWT, patrón multi-marca por JSON), se **refactoriza el andamiaje** (prompts hardcodeados, archivos gigantes, `account_id=1` cableado, auth parcial, CORS abierto) y se **descarta** lo frágil (URL de producción cableada en el HTML, secreto JWT por defecto, backups y notas sueltas).

| Dimensión | Estado |
|---|---|
| Backend (FastAPI) | 🟢 Sólido y funcional. ~8.1k LOC Python, bien organizado por capas. |
| Validador legal (13 checks) | 🟢 Joya del proyecto. Híbrido determinístico + LLM. Reutilizar tal cual. |
| Integración Anthropic | 🟢 Limpia (SDK async, singleton). |
| Integración Google | 🟡 Es **Slides + Drive**, no Sheets. Funciona; IDs y credenciales hardcodeados/env. |
| Auth | 🟡 JWT+bcrypt correcto para el **portal cliente**; los endpoints **internos no tienen auth**. |
| Frontend | 🟡 PWA **estática vanilla JS** (no Next.js). Rápida pero con JS duplicado y URL de backend cableada. |
| Deuda técnica | 🟡 2 archivos de +1.4k LOC, prompts en código, multi-tenant simulado, sin CI. |
| Seguridad | 🔴 CORS `*` + credenciales, `JWT_SECRET` con default inseguro, endpoints internos abiertos. |

**Recomendación de integración:** absorber el backend en `services/agents/` del monorepo como el primer set real de agentes de ejecución táctica (Fase 4), y el portal en `apps/web/` (Fase 1). Antes de escalar a la cartera hay que **desacoplar de SPN** (multi-account de verdad) y **sacar los prompts del código**.

---

## 1. Stack y estructura de carpetas

### 1.1 Backend — `polygonplus-studio-backend`

**Stack:** FastAPI 0.115 · Python 3.11+ · Uvicorn (ASGI) · Supabase Python 2.10 (Postgres) · Anthropic SDK 0.42 (async) · PyJWT + bcrypt · Google API client (Slides/Drive) · reportlab (PDF) · pydantic-settings. Corre en **Railway**.

```
polygonplus-studio-backend/
├── app/
│   ├── main.py            # Entrypoint FastAPI, CORS, lifespan (check_schema no bloqueante)
│   ├── config.py          # pydantic-settings — valida env al arranque
│   ├── database.py        # Cliente Supabase (singleton lru_cache)
│   ├── llm.py             # Cliente Anthropic (singleton async)
│   ├── exceptions.py
│   ├── api/
│   │   ├── router.py      # Agrupa routers versionados bajo /api
│   │   └── v1/            # 8 módulos de endpoints (health, validator, action_plan,
│   │                      #   grid, listing, slides_export, client_portal, visual_references)
│   ├── models/            # Pydantic request/response por dominio
│   ├── services/          # ← LÓGICA DE AGENTES (ver §2)
│   └── db/
│       ├── migrate.py     # check_schema() idempotente, avisa migraciones faltantes
│       └── migrations/    # 008…013 SQL (las 001-007 NO están en el repo)
├── scripts/               # populate_legal_rules, create_client_user, audits, backfills
├── tests/                 # test_validator.py (único test)
├── requirements.txt
└── .env.example           # ⚠️ incompleto (ver §5)
```

**Observaciones:** ~8,078 LOC de Python. **Sin** `Dockerfile`, `Procfile`, `railway.json` ni `.github/` — el arranque y el comando de Railway viven fuera del repo (config del dashboard). Migraciones empiezan en `008`: las tablas base (`001-007`) se aplicaron en otro bootstrap y no están versionadas aquí.

### 1.2 Frontend — `polygonplus-studio-frontend`

**Hallazgo clave:** **no es Next.js.** Es una **PWA estática de HTML + JS vanilla** (service worker, manifest, offline-first) servida como archivos por **Vercel**. El comentario de CORS del backend ("Next.js en localhost:3000") está **desactualizado**.

```
polygonplus-studio-frontend/
├── index.html                # Hub / selector de clientes
├── clients-login.html, coming-soon.html
├── clients-config/           # 1 JSON por marca (spn, city-market, copa, quintazur,
│   ├── _index.json           #   cerveza-allende, indrive, mi-consultorio, amphitryon,
│   └── *.json                #   gabriela-artigas) — multi-marca por configuración
├── spn/                      # ← ÚNICA cuenta realmente implementada
│   ├── index.html            # Dashboard SPN
│   ├── action-plan.html      # Generar plan de acción
│   ├── grid.html (+ .backup)  # Parrilla editorial  ⚠️ archivo .backup versionado
│   ├── validator.html        # UI del validador legal
│   ├── visual-references.html
│   ├── proceso-operativo.html
│   ├── cliente-login.html    # Login del portal de cliente
│   └── cliente.html          # Portal del cliente (1268 LOC)
├── css/polygon-design-system.css
├── assets/fonts/             # Aeonik Pro (16 pesos, .otf)
├── manifest.json, service-worker.js, vercel.json
```

~6,844 líneas de HTML. Cada página trae su propio `<script>` inline (patrón repetido, no hay bundler ni módulos compartidos).

---

## 2. Backend — API, agentes, prompts, validador, integraciones

### 2.1 Endpoints expuestos

Todos bajo `/api/v1`. El portal de cliente cuelga bajo `/api/v1/client`.

**Operación interna (equipo Polygon) — sin autenticación:**

| Método | Ruta | Función |
|---|---|---|
| GET | `/health` | Health check (DB + LLM) |
| POST | `/validate` | **Validador legal/pharma** (13 checks) |
| POST | `/action-plan/generate` | Genera plan de acción del mes |
| POST | `/action-plan/piece/{id}/regenerate-with-feedback` | Regenera pieza con feedback |
| POST | `/grid/generate` | Genera parrilla editorial completa |
| POST | `/grid/piece/{id}/regenerate-with-feedback` | Regenera pieza de parrilla |
| POST | `/grid/piece/{id}/undo` · `/redo` | Versionado de piezas (deshacer/rehacer) |
| PATCH | `/grid/piece/{id}` | Edición manual + re-validación |
| POST | `/visual-references/generate` | Referencias visuales (research visual con LLM) |
| POST | `/grids/{id}/export-to-slides` | Export a Google Slides |
| GET | `/action-plans` · `/grids` (+ `/{id}`) | Listados |
| POST | `/action-plan/{id}/export-pdf` · `/grid/{id}/export-pdf` | Export a PDF |
| GET | `/grids/{id}/export-figma-buzz-csv` | Export CSV para Figma Buzz |

**Portal de cliente — protegido con JWT (`/api/v1/client`):**

| Método | Ruta | Función |
|---|---|---|
| POST | `/login` | Login (email + password) → JWT |
| GET | `/me` | Usuario actual |
| GET | `/dashboard` | Dashboard del cliente |
| GET | `/action-plans/{id}` · `/grids/{id}` | Ver entregables |
| POST | `/feedback` | Enviar feedback sobre una pieza |
| POST | `/approve-all` | Aprobar todo lo pendiente |

### 2.2 Organización de la lógica de agentes

No hay un framework de agentes: **cada "agente" es un módulo en `app/services/`** que arma un prompt, llama a Claude (`app/llm.py`) y persiste en Supabase. Los "agentes" reales:

- **`pharma_validator.py`** (550 LOC) — el validador legal/pharma. El primero y más maduro.
- **`grid_generator.py`** (1,620 LOC) — genera la parrilla editorial pieza por pieza (paralelo con semáforo). El más grande.
- **`action_plan_generator.py`** (1,397 LOC) — genera el plan de acción mensual (incluye un agente "Sandra" para regenerar piezas).
- **`legal_repository.py`** — matching de categoría legal con LLM + ensamblado del texto legal (IVA, vigencia, T&C, vacunas).
- **`slides_exporter.py`**, **`pdf_exporter.py`** — exportadores (no-LLM).
- **`piece_versioning.py`**, **`sources_repository.py`**, **`client_auth.py`** — soporte (versionado, fuentes, auth).

El contexto de dominio (reglas de marca, pilares, etiquetados) **no** vive en el prompt: se **lee de Supabase** (`hard_rules` versión `V1.4`, `pillars`, `legal_rules`) y se inyecta en el system prompt en tiempo de ejecución. Buena base para multi-tenant… pero hoy todo filtra por `account_id=1`.

### 2.3 ¿Dónde viven los system prompts?

**Respuesta: en dos capas.**

1. **El esqueleto del prompt está HARDCODEADO en el código Python** (f-strings / triple-quoted) dentro de cada servicio:
   - `pharma_validator.py:335` (validación de tono) y `:412` (reescritura).
   - `legal_repository.py:90` (clasificador de categoría legal).
   - `grid_generator.py:504`, `:1251`, `:1564` (research visual + generación de parrilla).
   - `action_plan_generator.py:553`, `:898`, `:1108` (plan + agente "Sandra").
2. **El contenido variable (reglas de marca) vive en la DB** — tablas `hard_rules`, `legal_rules`, `pillars` — y se concatena dentro del prompt al vuelo.

> **Implicación para la plataforma:** cambiar el comportamiento de un agente hoy requiere **editar código y redeployar**. Para escalar a la cartera, los esqueletos de prompt deberían moverse a **archivos versionados o a la DB** (prompt registry), igual que ya se hizo con las reglas.

### 2.4 El validador legal — los 13 checks

Vive en `app/services/pharma_validator.py`. Pipeline en `validate_copy()`:

1. Trae `forbidden_terms` de la cuenta desde Supabase.
2. Corre detección determinística (regex/lookups precompilados).
3. Llama a Claude para tono sutil (`_validate_tone_with_claude`, temperatura baja 0.3, salida JSON).
4. Computa los **13 checks** (`_build_checks`) y resume (`_summarize_checks`).
5. Si falla algún check **crítico** → status `fail` y pide **reescritura** a Claude.
6. Persiste resultado (`editorial_pieces.validator_*`) y audita (`validator_runs`).

**Los 13 checks (V2)** — `critical` bloquea publicación, `info` solo advierte:

| # | Check | Severidad | Cómo |
|---|---|---|---|
| 1 | `tono_posibilidad` — verbos determinísticos ("cura", "elimina") sin calificador de posibilidad | critical | regex + Claude |
| 2 | `sin_superlativos` — "el mejor", "ideal", "garantiza"… | critical | lookup |
| 3 | `sin_anglicismos` — berries, wellness, lifestyle… | critical | lookup |
| 4 | `sin_palabras_prohibidas` — tabla `forbidden_terms` | critical | DB |
| 5 | `sin_imperativos_inicio` — "haz", "toma", "descubre" al inicio | critical | lookup |
| 6 | `sin_te_recomiendo` | critical | regex |
| 7 | `fuentes_espanol` — fuentes citadas en español; Educación exige ≥1 | critical | heurística URL |
| 8 | `legal_categoria` — si hay producto, exige `legal_text` | critical | regla |
| 9 | `iva_si_precio` — si menciona precio, exige "Precios incluyen IVA" | info | heurística |
| 10 | `vigencia_si_aplica` — fechas de vigencia en el legal | info | regla |
| 11 | `char_limits` — título ≤30, copy ≤80, legal ≤200 | critical | conteo |
| 12 | `permiso_producto_educacion` — Educación + producto requiere permiso | info | regla |
| 13 | `urls_verificadas` — toda fuente trae URL (HEAD vivo corre en generación) | critical | estructura |

Diseño **híbrido correcto**: lo determinístico se resuelve barato con regex/DB y solo el tono sutil toca el LLM. `ready_for_publication = (todos los críticos pasan)`. **Es la pieza de IP más valiosa del repo.**

### 2.5 Integración Anthropic

`app/llm.py`: singleton `AsyncAnthropic` cacheado. Modelo y parámetros desde config (`claude_model` default `claude-opus-4-5`, `max_tokens=4096`, `temperature=0.3` — bajo, a propósito, para determinismo pharma). Cada servicio hace su propia `messages.create()` con system prompt + user message; parseo de JSON con limpieza de fences. Manejo de error por servicio (fallback a lista vacía / None). Limpio y consistente.

### 2.6 Integración Google — es **Slides + Drive**, no Sheets

`app/services/slides_exporter.py`. Autenticación por **Service Account** (`_get_credentials`), con credenciales vía `GOOGLE_CREDENTIALS_JSON` (Railway) o `GOOGLE_CREDENTIALS_PATH` (local). Estrategia: **copia el template oficial de SPN** (IG o TikTok), conserva los primeros 4 slides con branding, borra placeholders y crea un slide por pieza con el contenido real; devuelve la URL. Scopes: `drive` + `presentations`.

> ⚠️ **Cableado a SPN:** los IDs de template (`IG_TEMPLATE_ID`, `TT_TEMPLATE_ID`) y de la carpeta destino (`PARRILLAS_FOLDER_ID`) están **hardcodeados**. No hay integración con Google **Sheets** — si esperabas Sheets, no existe; el flujo tabular sale por **CSV (Figma Buzz)** y PDF (reportlab).

---

## 3. Autenticación y manejo de usuarios/cuentas

`app/services/client_auth.py`:

- **Passwords:** bcrypt (`rounds=12`), hash + verify.
- **Tokens:** PyJWT, `HS256`, expiración **7 días**. Payload: `sub` (user id), `email`, `account_id`, `role`, `exp`, `iat`.
- **Secreto:** `JWT_SECRET = os.getenv("JWT_SECRET", "polygonplus-studio-dev-secret-change-in-prod-2026")` → **default inseguro cableado** si la env falta. 🔴
- **Dependency** `get_current_client()` protege los endpoints `/client/*`: lee `Authorization: Bearer`, valida el JWT, recarga el usuario fresco de `client_users` y rechaza inactivos.
- **Usuarios:** tabla **`client_users`** (email, password_hash, name, role, account_id, is_active, last_login_at). Se crean con `scripts/create_client_user.py`. Son **usuarios del cliente** (portal), no del equipo interno.

**Puntos ciegos importantes:**
- **No existe auth para el equipo interno.** Todos los endpoints operativos (`/validate`, `/grid/generate`, `/action-plan/generate`, listados, exports) están **abiertos** — cualquiera con la URL puede generar/consumir tokens de Claude.
- **Multi-cuenta a medias:** el JWT lleva `account_id`, pero casi toda la lógica de negocio filtra `account_id=1` (SPN) de forma cableada; para SPN el validador se **fuerza** siempre (`grid_generator.py`), ignorando el flag del request.

---

## 4. Frontend — framework, estructura, conexión al backend

- **Framework:** ninguno. **HTML + JS vanilla**, PWA (service worker network-first para navegación y API, con caché offline; `manifest.json`; instalable). Sistema de diseño propio en un solo CSS + fuentes Aeonik Pro.
- **Estructura:** un hub (`index.html`) + carpeta por cliente. **Solo `spn/` está implementado**; el resto de marcas viven como `clients-config/*.json` y caen a `coming-soon.html`. Multi-marca por **configuración JSON**, no por código.
- **Conexión al backend:** `fetch()` directo contra una **URL de producción hardcodeada** en cada página y en el service worker:
  `https://polygonplus-studio-backend-production.up.railway.app`. No hay capa de config por entorno.
- **Portal de cliente:** `spn/cliente-login.html` hace `POST /api/v1/client/login`, guarda el JWT (localStorage) y `spn/cliente.html` consume `/client/*` con el `Bearer`.
- **Vercel:** `vercel.json` solo define headers de caché/tipo (sin build step — deploy estático).

---

## 5. Variables de entorno por servicio

### Backend (Railway)

| Variable | Obligatoria | En `.env.example` | Notas |
|---|---|---|---|
| `SUPABASE_URL` | ✅ | ✅ | |
| `SUPABASE_KEY` | ✅ | ✅ | usar **service_role** (no anon) |
| `ANTHROPIC_API_KEY` | ✅ | ✅ | |
| `ENVIRONMENT` | — | ✅ | default `development` |
| `LOG_LEVEL` | — | ✅ | default `INFO` |
| `DEFAULT_ACCOUNT_ID` | — | ✅ | default `1` |
| `CLAUDE_MODEL` | — | ❌ | default `claude-opus-4-5` |
| `CLAUDE_MAX_TOKENS` / `CLAUDE_TEMPERATURE` | — | ❌ | defaults 4096 / 0.3 |
| `JWT_SECRET` | ✅ (prod) | 🔴 **falta** | tiene default **inseguro** si no se define |
| `GOOGLE_CREDENTIALS_JSON` | ✅ (para Slides) | 🔴 **falta** | JSON del Service Account (o `GOOGLE_CREDENTIALS_PATH` en local) |

> **Gap:** `.env.example` **no documenta** `JWT_SECRET` ni las credenciales de Google — dos variables imprescindibles para producción.

### Frontend (Vercel)

**Ninguna variable de entorno.** Todo es estático y la URL del backend está **cableada** en el código (deuda). `vercel.json` solo define headers.

---

## 6. Calidad del código y deuda técnica

**Fortalezas:** organización por capas clara (api/models/services), docstrings en español consistentes, singletons con `lru_cache`, degradación con gracia cuando falta una tabla/migración, validador con diseño híbrido acertado, versionado de piezas (undo/redo) real.

**Deuda técnica y fragilidades:**

1. 🔴 **Seguridad — CORS abierto:** `allow_origins=["*"]` **junto con** `allow_credentials=True` (combinación inválida/permisiva) en `main.py`.
2. 🔴 **Seguridad — `JWT_SECRET` con default inseguro** cableado en `client_auth.py`.
3. 🔴 **Seguridad — endpoints internos sin auth** (generación consume tokens de Claude sin control).
4. 🟡 **Archivos monstruo:** `grid_generator.py` (1,620 LOC) y `action_plan_generator.py` (1,397 LOC) mezclan armado de prompt, orquestación, parseo y persistencia. Difíciles de testear/mantener.
5. 🟡 **Prompts en código:** los esqueletos de system prompt están hardcodeados (§2.3) → cambiar comportamiento = redeploy.
6. 🟡 **Multi-tenant simulado:** `account_id=1` y "SPN" cableados en varios lugares (validador forzado, IDs de template Google, prompts). Bloquea escalar a la cartera.
7. 🟡 **Config cableada:** URL de backend en el HTML/service worker; IDs de Google en el código.
8. 🟡 **Testing casi nulo:** un solo archivo (`tests/test_validator.py`). Sin CI (`.github/` ausente en ambos repos).
9. 🟡 **Migraciones ad-hoc:** SQL numerado 008-013 + `check_schema()` manual; las 001-007 no están versionadas. Diverge del esquema de `polygonplus` (`supabase/migrations/`).
10. 🟡 **Frontend duplicado:** `<script>` inline repetido por página, `spn/grid.html.backup` versionado, sin bundler.
11. ⚪ **Archivos de notas** (`NOTAS_*_FELIPE.md`) versionados — útiles como contexto, ruido como código.
12. ⚪ **Comentarios desactualizados:** CORS menciona "Next.js en localhost:3000" (el frontend no es Next.js).

No se encontraron marcadores `TODO/FIXME/HACK` significativos: la deuda es **estructural**, no de parches pendientes.

---

## 7. Veredicto de reutilización

### ✅ Conservar tal cual (IP de alto valor, portable)

- **Validador legal/pharma (13 checks)** — `pharma_validator.py` + `legal_repository.py`. El activo más valioso. Diseño híbrido determinístico+LLM correcto. Es un **agente de la Capa 3** listo.
- **Modelo de datos legal** — `legal_rules` (15 categorías SPN) + `forbidden_terms` + `hard_rules`. Patrón "reglas en DB, inyectadas al prompt".
- **Exportador de Google Slides** — estrategia de copiar-template. Reutilizable generalizando IDs.
- **Auth JWT + bcrypt** (`client_auth.py`) — base sólida para el portal de cliente de PolygonPlus.
- **Patrón multi-marca por JSON** (`clients-config/`) — buen andamiaje para la cartera.
- **Contenido de dominio SPN** (reglas de tono, pilares, legal) — conocimiento capturado; muévelo al Núcleo de Conocimiento (Capa 0).

### 🔧 Refactorizar antes de escalar

- **Sacar los prompts del código** → prompt registry versionado (archivos o DB), como ya se hizo con las reglas.
- **Desacoplar de SPN** → multi-account real: `account_id` en todo, IDs de Google por cuenta, validador configurable por marca.
- **Partir los archivos gigantes** (`grid_generator`, `action_plan_generator`) por responsabilidad.
- **Unificar auth** → una sola capa que cubra equipo interno **y** portal cliente; evaluar migrar a **Supabase Auth** (ya es el stack de PolygonPlus) en vez de JWT custom, o al menos proteger los endpoints internos.
- **Config por entorno** → URL de backend, secreto JWT, IDs de Google fuera del código.
- **Unificar migraciones** con `supabase/migrations/` del monorepo.
- **Frontend:** decidir — absorber el operativo interno en `apps/web` (Next.js) y conservar el portal de cliente como PWA, eliminando JS duplicado.

### 🗑️ Descartar / no traer

- URL de producción de Railway cableada en el HTML y el service worker.
- `JWT_SECRET` default inseguro.
- CORS `*` + credenciales.
- `spn/grid.html.backup` y copias duplicadas del design system.
- Comentario "Next.js en localhost:3000" (stale).

### Mapa a las fases de PolygonPlus

| Componente del Studio | Encaja en |
|---|---|
| Validador + generadores (grid, action-plan, visual refs) → `services/agents/` | **Fase 4 · Ejecución táctica** (y semilla de Capa 3) |
| Portal de cliente + dashboards → `apps/web/` | **Fase 1 · Capa operativa MVP** |
| `legal_rules` / `hard_rules` / `pillars` / configs por marca | **Capa 0 · Núcleo de Conocimiento** |
| Multi-account real + prompt registry | Prerrequisito de **Fase 3 · Escalar a la cartera** |

> **Conclusión:** el Studio es un **acelerador enorme** — ya probó el modelo en una cuenta real (SPN). La integración correcta es **absorber el motor**, **refactorizar el andamiaje** para volverlo multi-cuenta y config-driven, y **cerrar los huecos de seguridad** antes de replicarlo a la cartera.

---

*Documento generado por auditoría de solo lectura. Ningún archivo de los repos auditados fue modificado.*
