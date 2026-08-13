# Diagnóstico — "PolygonPlus Studio" (trabajo previo)

Auditoría del sistema que Felipe construyó antes de este proyecto. Objetivo: decidir qué se reutiliza y cómo se integra al ecosistema ordenado. Agosto 2026.

---

## 1. Veredicto

**No es trabajo desordenado a nivel técnico. Es un producto real, sofisticado y en uso activo.** Es un **agente de contenido editorial para SPN (San Pablo)** que funciona de punta a punta: propone plan de contenido, genera copies, los valida contra reglas legales de farmacia, versiona, captura feedback y contempla aprobación de cliente.

**Señal clave:** se usó **ayer** (action plans creados el 11 de agosto, etiquetados "RE / FELO"). No es un prototipo abandonado — es producción viva. Cualquier integración debe ser **no destructiva.**

---

## 2. Arquitectura

| Componente | Tecnología | Dónde | Estado |
|-----------|-----------|-------|--------|
| Backend | FastAPI (Python), `uvicorn app.main:app` | Railway · `polygonplus-studio-backend` | Sano, corriendo |
| Frontend | Custom (Node 24) | Vercel · `polygonplus-studio-frontend` | Desplegado (READY) |
| Base de datos | Postgres 39 tablas | Supabase · `PolygonPlus IA Studio BETA` | Activa, con datos |
| Integraciones | Anthropic API, Google Sheets (`GOOGLE_CREDENTIALS_JSON`) | env en Railway | Configuradas |

Repos en GitHub: `BoldAi-FM/polygonplus-studio-backend` y `BoldAi-FM/polygonplus-studio-frontend`.

---

## 3. Estado real de los datos

**Conocimiento de dominio cargado (IP valiosa, difícil de reconstruir):**
- **55 reglas duras** (versión V1.4) — el corazón del cumplimiento editorial.
- **10 pilares** de contenido · **17 categorías legales** (farmacia) · **24 términos prohibidos** · **24 feedbacks de cliente**.

**Contenido generado real:**
- **27 action plans** (varios son pruebas: "TEST Regina", "rollback", "VERSIÓN FINAL", "BUG1"…).
- **18 piezas editoriales** con copy completo, buena calidad y tono correcto de marca (hidratación, magnesio, skincare, bloqueador, formatos GRWM/POV).
- **18 corridas de validador** (13 checks definidos) · **10 feedbacks de pieza** · versiones por pieza.

**Tablas vacías (viven en código o no se cargaron):** `users`, `agent_prompts` (los prompts están en el backend, no en DB), `products`, `ephemerides`, `publishing_schedule`.

**Una sola cuenta configurada:** `account_id = 1` (SPN).

---

## 4. Dónde estaba el "desorden" real

No en la ingeniería. En tres cosas:

1. **Estratégico** — un pozo vertical profundo (un cliente, una función) sin plataforma horizontal ni plan maestro alrededor. *(Es lo que este proyecto arregla.)*
2. **Higiene de datos** — muchísimos action plans de prueba mezclados con los reales, con etiquetas inconsistentes ("Agosto V1", "JULIO 2026 V RE/FELO", "TEST BUG1"). Falta separar test de producción.
3. **Acreción de esquema** — señales de iteración rápida: campos duplicados (`legal_category_id` bigint *y* `legal_category` varchar; datos de validador tanto en `editorial_pieces` como en `validator_runs`). Normal, pero conviene consolidar.

---

## 5. Qué se reutiliza (salvage list)

**Alto valor — no se toca, se aprovecha:**
- El **conocimiento de dominio de SPN** (55 reglas, 17 categorías legales, 24 términos prohibidos, 10 pilares). Oro.
- El **validador legal** con sus 13 checks — diferenciador real frente a otras agencias.
- El **pipeline completo** action plan → parrilla → pieza → validación → feedback → versión.
- Las **integraciones** ya resueltas (Anthropic, Google Sheets).
- El **andamiaje multi-cliente y de auditoría** (`accounts`, `roles`, `audit_log`, portal de cliente) — base de Capa 0/1.

**A ordenar (no reconstruir):**
- Separar datos de prueba vs producción.
- Consolidar los campos duplicados del esquema.
- Cargar a DB lo que hoy vive suelto (prompts de agente → `agent_prompts`).

---

## 6. Riesgos a atender

- 🔴 **Seguridad (RLS):** 5 tablas con Row Level Security apagado (`piece_feedbacks`, `piece_versions`, `manual_edits`, `validator_runs`, `legal_rules`) — expuestas con la anon key. Requiere políticas antes de exponer nada.
- 🟠 **Es producción en uso:** integrar sin interrumpir a Regina/al equipo. Nada destructivo sin respaldo.
- 🟡 **Deuda de esquema:** duplicidades a consolidar en una migración cuidada.

---

## 7. Recomendación de integración

1. **Reusar la infraestructura existente** (Supabase, Railway, Vercel) — nada de duplicar ni pagar doble.
2. **El Studio = primer módulo táctico** (Capa 3, contenido) bajo el paraguas PolygonPlus.
3. **Promover la fundación compartida:** `accounts`/`users`/`roles`/`audit_log` se vuelven base común del ecosistema (no se reconstruyen en el cascarón — se reconcilian).
4. **La capa operativa nueva se construye reusando esa fundación**, en un esquema separado y limpio, sin ensuciar las 39 tablas del Studio.
5. **Vocabulario único:** unificar "accounts" (Studio) con "clients" (cascarón) para no tener dos nombres para lo mismo.

---

## 8. Pendiente: auditoría de código

Falta la mitad que la MCP no me deja ver: el **código de los dos repos** (lógica del backend FastAPI, dónde viven los prompts, cómo corre el validador, el frontend). Se delega a **Claude Code** (que sí tiene acceso a los repos en tu máquina). Sus hallazgos se integran al **Plan Maestro v3**.

---

*Diagnóstico read-only. No se modificó ningún dato del Studio. Última edición: Agosto 2026.*
