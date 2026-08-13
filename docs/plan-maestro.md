# PolygonPlus — Plan Maestro

**Ecosistema operativo automatizado para Polygon**
Versión 3.0 · Agosto 2026 · Documento vivo
*(v3 integra la auditoría completa del "Studio" existente: datos/infra + código)*

---

## 0. Principio rector

**No robotizamos la agencia. Liberamos a las mentes creativas para que creen y decidan.**
Cada agente se juzga con una pregunta: *¿esto libera cerebro creativo, o lo reemplaza?* Solo construimos lo primero.

---

## 1. North Star

Convertir a Polygon en una **agencia operada por un ecosistema de agentes** — procesos aterrizados, documentados y en su mayoría automatizados, para que **las personas dirijan y creen y los agentes sostengan la operación**. Fin último: **subir la utilidad sobre el revenue, eliminar la dependencia de personas clave, y dejar la compañía lista para venderse a un valor muy superior.**

**Novedad clave de v3:** ya no partimos de cero. Ya existe un **módulo táctico probado en producción** (el Studio, para SPN) con un activo defendible: el **validador legal/pharma**. Estamos más adelante de lo que creíamos — el trabajo es *ordenar y generalizar*, no inventar.

---

## 2. Dos realidades que v3 une

1. **El cascarón nuevo** — monorepo limpio (`BoldAi-FM/polygonplus`), documentado desde el commit #1, con GitHub Projects como tablero. Es el *paraguas ordenado*.
2. **El Studio en producción** — agente de contenido para SPN (`account_id=1`), desplegado y en uso (última actividad: 11 de agosto). Es la *primera rebanada vertical real*.

v3 mete el Studio dentro del paraguas, sin romperlo.

---

## 3. Diagnóstico

### 3.1 Dolor raíz (interno, sin cambios)
No existe planeación estratégica ni creativa anticipada → todo cae como "urgencia" al equipo táctico; cada área en su trinchera; la comunicación dirección ↔ PM ↔ cuentas ↔ cliente se cae en los handoffs; se gobierna "correteando gente".

### 3.2 Qué es el Studio (auditoría de código + datos)
Flujo creativo completo, **client-first para SPN** (no platform-first): **Action Plan → Grid editorial → validación legal/pharma (13 checks) → export a Google Slides/PDF → portal de cliente** (login, dashboard, feedback, aprobación).

**Arquitectura real:**
- **Frontend:** PWA estática (HTML + JS vanilla) en Vercel. *No es Next.js.*
- **Backend:** FastAPI (Python) en Railway.
- **DB:** Supabase (39 tablas). Conocimiento de marca en DB (`hard_rules` 55, `legal_rules`, `pillars` 10, `legal_categories` 17, `forbidden_terms` 24); **prompts hardcodeados en el código Python** (la tabla `agent_prompts` está vacía).
- **Integración Google:** Slides + Drive vía Service Account. *No Sheets.* Lo tabular sale por CSV/PDF.
- **Auth:** JWT + bcrypt sólida, **pero solo para el portal de cliente**.

### 3.3 Dónde estaba el "desorden" real
No en la ingeniería: (1) estratégico — pozo vertical sin plataforma ni plan alrededor; (2) higiene de datos — action plans de prueba mezclados con reales; (3) acreción de esquema y archivos gigantes.

---

## 4. Arquitectura por capas — con el Studio mapeado

| Capa | Qué es | Estado hoy (gracias al Studio) |
|------|--------|-------------------------------|
| **0 · Conocimiento** | Reglas, marcas, clientes, históricos | **Parcial ✅** — reglas duras, legal, pilares de SPN ya en DB |
| **1 · Operativa / Coordinación** | PM interno + planeación + dashboards + portal cliente | **Portal de cliente ✅** existe; **coordinación interna ❌** (lo nuevo a construir) |
| **2 · Inteligencia** | Tendencias, benchmarks, reputación | ❌ pendiente |
| **3 · Táctica** | Contenido, social, paid, arte… | **Contenido (SPN) ✅** — el motor del Studio |
| **4 · Back-office** | Rentabilidad, facturación, legal | ❌ pendiente |

**Lectura:** el Studio ya cubre una vertical de Capa 3 (contenido) + parte de Capa 1 (portal cliente) + parte de Capa 0 (conocimiento SPN) — todo para un cliente. **Lo que falta y es el corazón del proyecto: la Capa 1 operativa *interna*** (coordinación dirección/PM/cuentas), que hoy no existe en ningún lado.

---

## 5. Decisiones de arquitectura (actualizadas por la auditoría)

- **Monorepo políglota.** El motor de agentes probado es **Python/FastAPI** → se conserva y vive como servicio Python bajo el monorepo (reemplaza al esqueleto Node `services/agents` del cascarón, que era una suposición). Lo web nuevo va en **Next.js** (`apps/web`).
- **Portal:** la PWA vanilla **se queda corriendo** (no se reescribe ya); las superficies nuevas se hacen en Next.js y el portal converge a Next.js más adelante, si el valor lo justifica.
- **Prompts → registry versionado.** Sacar los system prompts del código a la tabla `agent_prompts` (ya existe, vacía). Prerrequisito para escalar y para el principio de "todo documentado".
- **Multi-account de verdad.** Hoy SPN (`account_id=1`) está cableado por todos lados. Generalizar a multi-cuenta es **prerrequisito de la Fase 3** (escalar a la cartera).
- **Auth unificada.** Evaluar **Supabase Auth** para unificar portal + endpoints internos + equipo, en vez de dos esquemas.
- **Vocabulario único.** Unificar `accounts` (Studio) y `clients` (cascarón) en un solo concepto. `accounts`/`users`/`audit_log` del Studio se **promueven a fundación compartida** (Capa 0/1); la capa operativa nueva se construye encima, en esquema separado y limpio.

---

## 6. Seguridad — workstream transversal URGENTE 🔴

Es producción en uso; estos huecos se atienden **antes** de escalar:

1. **Endpoints internos sin auth** (`/validate`, `/grid/generate`, `/action-plan/generate`) — cualquiera con la URL quema tokens de Claude. **#1 a resolver.**
2. **CORS `*` + `allow_credentials=True`** — configuración insegura.
3. **`JWT_SECRET` con default inseguro** cableado en código.
4. **`.env.example` incompleto** — no documenta `JWT_SECRET` ni credenciales de Google.

*(Parte de esto se puede mitigar a nivel infra desde aquí — ej. variables en Railway — pero el fondo requiere cambios de código vía Claude Code.)*

---

## 7. Roadmap (reordenado por la realidad)

**Fase 0 — Cascarón / Fundación.** ✅ Repo, docs, tablero. Falta: CI en ambos repos, reconciliación del monorepo.

**Fase 0.1 — Hardening de seguridad.** 🔴 Cerrar los 4 huecos de §6. *Nuevo y urgente.*

**Fase 0.5 — Rediseño del modelo operativo.** Definir con Felipe el nuevo org/reglas de operación.

**Fase 1 — Capa operativa interna (MVP).** Lo que NO existe: coordinación dirección↔PM↔cuentas, planeación anticipada, dashboards internos por marca. Reusa la fundación (`accounts`/`users`/`audit_log`) del Studio.

**Fase 2 — Inteligencia.** Tendencias & benchmarks alimentando la planeación.

**Fase 3 — Escalar a la cartera.** Prerrequisitos: **prompt registry + multi-account real**. Luego replicar cuenta por cuenta.

**Fase 4 — Táctica ampliada.** Partir los archivos gigantes del motor, sumar social/paid/arte sobre el motor existente.

**Fase 5 — Empaque de valor / venta.** Métricas de margen + documentación + validador como activo demostrable.

---

## 8. Plan de reconciliación (cómo se unen cascarón + Studio)

1. **Infra:** reusar Supabase/Railway/Vercel existentes. Nada de duplicar.
2. **Repos:** decidir consolidación — traer `studio-backend` y `studio-frontend` al monorepo `polygonplus` (como `services/agents` Python y `apps/portal`), o referenciarlos como submódulos. *(Decisión en su Issue.)*
3. **Esquema:** una migración cuidada que promueve la fundación compartida y limpia duplicados (`legal_category_id` vs `legal_category`; validador en dos lados). No destructiva, con respaldo.
4. **Datos:** separar action plans de prueba vs producción.
5. **Documentar** todo en `docs/` (incluye el `studio-audit.md` que generó Claude Code).

---

## 9. Métricas del north star

Horas creativas liberadas · % procesos documentados · % tareas automatizadas · **margen utilidad/revenue** · bus factor · ratio planeación vs. urgencia.

---

## 10. Sistema de seguimiento

GitHub Projects "PolygonPlus — Roadmap" (7 fases como Issues) · este documento vivo en `docs/plan-maestro.md` · cadencia semanal · regla de oro: nada se construye sin dueño humano y sin quedar documentado.

---

*Documento vivo. v3 — integra auditoría completa del Studio. Última edición: Agosto 2026.*
