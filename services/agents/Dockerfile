# PolygonPlus — servicio de agentes (Railway)
FROM node:20-slim AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

WORKDIR /app

# Copiamos el manifiesto del servicio y sus deps
COPY package.json ./
RUN pnpm install --prod=false

COPY . .
RUN pnpm build

EXPOSE 8080
CMD ["node", "dist/index.js"]
