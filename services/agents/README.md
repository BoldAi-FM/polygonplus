# @polygonplus/agents

Servicio de agentes → desplegado en **Railway**. Aquí corren los workers, colas y cron del ecosistema (planeación, PMO, cuentas, insights…).

```bash
pnpm --filter @polygonplus/agents dev     # http://localhost:8080/health
```

Fase 0: esqueleto con healthcheck. Cada agente se agrega con su spec en [`docs/agents/`](../../docs/agents/).
