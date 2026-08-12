/**
 * PolygonPlus — servicio de agentes (Railway)
 *
 * Esqueleto Fase 0: un servidor HTTP mínimo con healthcheck.
 * Aquí vivirán los workers, colas y cron de los agentes (planeación, PMO, etc.).
 */
import { createServer } from "node:http";

const PORT = Number(process.env.AGENTS_PORT ?? 8080);

const server = createServer((req, res) => {
  if (req.url === "/health") {
    res.writeHead(200, { "content-type": "application/json" });
    res.end(JSON.stringify({ status: "ok", service: "polygonplus-agents" }));
    return;
  }
  res.writeHead(200, { "content-type": "application/json" });
  res.end(
    JSON.stringify({
      service: "polygonplus-agents",
      message: "Ecosistema de agentes — Fase 0 (esqueleto)",
      agents: [],
    }),
  );
});

server.listen(PORT, () => {
  console.log(`[polygonplus-agents] escuchando en :${PORT}`);
});
