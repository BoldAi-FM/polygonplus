# PolygonPlus — Plan Maestro

**Ecosistema operativo automatizado para Polygon**
Versión 2.0 · Agosto 2026 · Documento vivo
*(v2 integra el feedback de Felipe Madero sobre v1)*

---

## 0. Principio rector — leer antes que nada

**No robotizamos la agencia. Liberamos a las mentes creativas para que creen y decidan.**

Polygon tiene un equipazo atrapado en tareas mini-tácticas y operativas que apagan su capacidad de crear. El propósito de los agentes es **quitarles de encima lo repetitivo y lo administrativo** para que el talento humano se concentre en lo único que no se puede automatizar: **crear, pensar estrategia y tomar decisiones.**

Cada agente que construyamos se juzga con una sola pregunta: *¿esto libera cerebro creativo, o lo reemplaza?* Solo construimos lo primero. Este principio manda sobre cualquier decisión técnica del proyecto.

---

## 1. North Star

Convertir a Polygon en una **agencia operada por un ecosistema de agentes**, donde los procesos están aterrizados, documentados y en su mayoría automatizados — para que **las personas dirijan y creen, y los agentes sostengan la operación.**

El objetivo final es **elevar la utilidad sobre el revenue de forma considerable y eliminar la dependencia de personas clave**, dejando a la compañía en condiciones de ser **vendida a un valor muy superior al actual.**

No es "meter IA a tareas sueltas". Es construir la **columna vertebral operativa** de la empresa: el sistema que planea, coordina, ejecuta, documenta y mide.

La ventaja competitiva hoy: Polygon tiene **clientes institucionales grandes en iguala** (Cervecería Allende, City Market, San Pablo, Lalamove, Mi Consultorio, Copa, Quintazur). Eso permite **probar el modelo en el mundo real**, con presupuestos y exigencia reales — no quedarnos en teoría sobre lo que "la IA podría hacer".

### Qué significa "logrado" (los resultados del north star)

1. **Mentes creativas liberadas** — el talento pasa de operar a crear y decidir. *(Principio rector, resultado #1.)*
2. **Procesos aterrizados y documentados** — cada flujo existe por escrito, no solo en la cabeza de alguien.
3. **Mayoría automatizada** — lo repetitivo lo hacen agentes; las personas dirigen.
4. **Utilidad sobre revenue ampliada** — más margen por cliente, misma o mayor calidad, menos horas-persona quemadas en operación.
5. **Cero dependencia de personas clave** — si alguien se va, el proceso y el conocimiento se quedan.
6. **Ecosistema completo y vendible** — todo lo anterior empaquetado como un activo demostrable ante un comprador.

---

## 2. Diagnóstico actual

### 2.1 El dolor raíz

**No existe planeación estratégica ni creativa anticipada.** Todo baja al equipo táctico marcado como "urgente", sin priorización ni contexto. Cada área opera **desde su propia trinchera**, sin visibilidad del conjunto, y la comunicación **dirección ↔ project management ↔ cuentas ↔ cliente** se cae en los handoffs.

Síntomas típicos:

- El cliente pide algo y no queda claro quién lo recibe, prioriza o aprueba.
- Dirección decide algo y cuentas/PM se enteran tarde o nunca.
- El equipo creativo reacciona en vez de anticipar; no hay plan del mes antes de la urgencia.
- El conocimiento de cada cuenta vive en las personas, no en un sistema.
- **Se gobierna "correteando gente"** para que las cosas salgan, en lugar de un sistema que dé visibilidad y empuje solo.

### 2.2 Estructura organizacional actual — HERENCIA, no destino

> ⚠️ **Nota crítica de Felipe (dueño):** el organigrama vigente lo armó Mitzi y **se va a cambiar de fondo.** Se documenta aquí solo como *antecedente del estado actual*, NO como lo que vamos a construir. El **rediseño del modelo operativo y organizacional es parte del alcance de este proyecto** (ver §3.1).

**Liderazgo / soporte:** Felipe Madero (CEO, visión y liderazgo de IA) · Jose Luis Betancourt (Senior Partner — Strategy & BizDev) · Antonio Tamayo (Senior Advisor — Strategy & Brand Reputation) · Paulina Beck (Legal).

**Dirección ejecutiva:** Mitzi Rodriguez (Executive Managing Director — operación, cuentas y crecimiento; New Business directo; Daniela Ramos y Mario Alva le reportan directo).

**Dirección / gerencia:** Pablo Noguerón (Dir. Contenido, Allende) · Regina Phal (Creative Director, Allende) · Daniela Ramos (Paid Media Manager) · Omar Ramirez (Art Director, Allende) · Gaby Velazquez (PM Sr — San Pablo, Lalamove, Polygon, Mi Consultorio, Copa, Quintazur) · Fernando (Influencers & Eventos) · Liliana Moctezuma (Office Manager).

**Colaboradores individuales:** Diego Vazquez (Audiovisual Post, City Market) · Victoria Hernández (Graphic Designer — SPN, Mi Consultorio, COPA, City Market) · Ricardo Varela (Despacho contable externo).

**Freelance por horas:** Audiovisual Post · Community Manager (solo responding) · Roque Falabella (Audiovisual Director) · Mario Alva (Trafficker) · Graphic Creator (SPN, Quintazur, COPA) · Contador interno.

### 2.3 Cartera de clientes (campo de prueba)

Cervecería Allende · City Market · San Pablo (SPN) · Lalamove · Mi Consultorio · Copa (COPA) · Quintazur · Polygon (interno).

---

## 3. Alcance del proyecto

### 3.1 Rediseño del modelo operativo (nuevo — a definir con Felipe)

Además de la plataforma, este proyecto **rediseña cómo opera Polygon**: roles, responsabilidades, quién decide qué, y cómo se elimina la dependencia de personas clave. La plataforma habilita y hace cumplir ese nuevo modelo. Se trabaja en una fase dedicada, con Felipe como dueño de la decisión.

### 3.2 La plataforma PolygonPlus (el producto)

Requerimientos de producto que ya sabemos que existen:

- **Herramienta de project management con agentes** — que la operación fluya sin "corretear gente": tareas, estatus, responsables, alertas y seguimiento automático.
- **Dashboard por marca/cliente** — cada cuenta con su tablero: estado, pendientes, calendario, performance, rentabilidad.
- **Chats/hilos por tarea** — cada task con su propio contexto, no todo revuelto.
- **Núcleo de conocimiento** — memoria viva de procesos, marcas y clientes.
- **Todo documentado y versionado desde el inicio.**

---

## 4. Arquitectura de PolygonPlus (capas)

Regla de oro: **primero la capa operativa; lo táctico se cuelga encima.**

```
CAPA 0 · NÚCLEO DE CONOCIMIENTO — procesos, marcas, clientes, históricos, plantillas
CAPA 1 · OPERATIVA / COORDINACIÓN  ◀── PRIORIDAD — PM + planeación + dashboards + visibilidad a dirección
CAPA 2 · INTELIGENCIA / ESTRATEGIA — tendencias, benchmarks, reputación, estrategia creativa
CAPA 3 · EJECUCIÓN TÁCTICA — contenido, social, paid, arte, influencers, audiovisual
CAPA 4 · ADMINISTRACIÓN / BACK-OFFICE — rentabilidad, facturación, legal
```

*(Inventario de agentes por capa: el approach de v1 se mantiene; iremos más profundo agente por agente en su fase. Cada agente se define con input, output, dueño humano y fuentes de datos.)*

---

## 5. Fundación técnica — el "Cascarón" (Fase 0)

**Decisión de Felipe:** antes de tocar clientes, construimos el cascarón real del proyecto. Nada vive en "una conversación de Claude normal": todo queda en un proyecto de verdad, comunicado, con hilos por tarea y **documentado desde el commit #1.**

### 5.1 Stack (ya contratado por Felipe)

- **GitHub** — fuente de verdad: código, documentación, gestión del proyecto (Issues/Projects), CI/CD.
- **Supabase** — Postgres + Auth + Storage. Aquí vive el Núcleo de Conocimiento (Capa 0) y los datos de la plataforma.
- **Vercel** — frontend/dashboard (Next.js). La cara de PolygonPlus.
- **Railway** — servicios de agentes, workers, colas y cron que corren fuera del edge.

Veredicto del experto: **es exactamente el stack correcto y moderno para esto.** Nada que cambiar; solo ordenarlo bien.

### 5.2 Estructura del repositorio (monorepo)

```
polygonplus/
├── docs/                 # Documentación desde el día 1
│   ├── plan-maestro.md   # este documento (fuente de verdad de estrategia)
│   ├── adr/              # Architecture Decision Records (cada decisión, versionada)
│   ├── agents/           # spec de cada agente
│   ├── processes/        # SOPs de la operación (Capa 0)
│   └── data-model.md     # esquema de datos
├── apps/
│   └── web/              # Next.js → Vercel (dashboard por marca, PM)
├── services/
│   └── agents/           # workers de agentes → Railway
├── packages/             # código compartido
├── supabase/             # esquema, migraciones, políticas
└── .github/              # CI/CD, plantillas de Issues por tipo de task
```

### 5.3 Gestión del proyecto y "chats por tarea" — recomendación del experto

Estoy de acuerdo con la intención de Felipe: **nada de dejarlo en un chat suelto.** Recomiendo este backbone:

- **GitHub Projects = tablero maestro** del build. **Cada Issue = una tarea**, con dueño, etiqueta de fase y su propio hilo de discusión durable (no se pierde como un chat).
- **Un hilo de trabajo por tarea:** cada tarea se ejecuta en su propia sesión aislada de Cowork/Claude, ligada al número de Issue. Contexto limpio por tarea, registro durable en GitHub.
- **Documentación como parte de "terminado":** ninguna tarea se cierra sin dejar su rastro escrito en `/docs`.

Más adelante, esta misma lógica (tareas + hilos + dueños + dashboards) es **literalmente el producto** que le vendemos a Polygon para operar sus cuentas. Construimos el andamiaje del build de forma que se convierta en el producto.

### 5.4 Advertencia honesta del experto

El riesgo de un "cascarón" es sobre-ingenierizarlo: pasar semanas montando infraestructura perfecta sin entregar valor. **Cascarón mínimo pero real** — repo + docs + esqueleto desplegado (Vercel/Supabase/Railway conectados y "hello world" en verde) + esquema base — y de inmediato el primer flujo operativo encima. Documentado y versionado, pero sin sobre-construir.

---

## 6. Roadmap por fases (actualizado)

**Fase 0 — Cascarón / Fundación técnica (ahora).** Repo monorepo, docs desde commit #1, GitHub Projects como tablero, esqueleto desplegado en Vercel/Supabase/Railway, esquema base de datos, plantillas de tareas. *Entregable: la plataforma existe, vacía pero viva y documentada.*

**Fase 0.5 — Rediseño del modelo operativo.** Definir con Felipe el nuevo org y reglas de operación que la plataforma habilitará.

**Fase 1 — Capa operativa MVP (cliente piloto).** PM + planeación + dashboard + ficha para UNA cuenta. Probar en real que baja la "urgencia".

**Fase 2 — Inteligencia.** Tendencias & benchmarks alimentando la planeación.

**Fase 3 — Escalar a la cartera.** Replicar cuenta por cuenta.

**Fase 4 — Ejecución táctica.** Agentes de contenido, social, paid, arte, etc.

**Fase 5 — Empaque de valor / venta.** Consolidar métricas de margen, documentación y automatización como activo vendible.

---

## 7. Métricas del north star

- **Horas-persona creativas liberadas** (de operación → creación). *(Métrica #1, alineada al principio rector.)*
- % de procesos documentados.
- % de tareas automatizadas por área.
- **Margen: utilidad / revenue** por cuenta y global.
- **Bus factor** — cuántos procesos dependen de una sola persona.
- **Ratio planeación vs. urgencia** — % de trabajo planeado vs. "urgente".

---

## 8. Sistema de seguimiento

- **GitHub Projects** como tablero durable del build (además del tablero de tareas de esta sesión).
- **Este documento vivo** en `/docs/plan-maestro.md`, versionado.
- **Cadencia semanal** de revisión: avance, decisiones, siguiente paso.
- **Regla de oro:** nada se construye sin dueño humano definido y sin quedar documentado.

---

*Documento vivo — se actualiza en cada fase. Última edición: Agosto 2026 (v2).*
