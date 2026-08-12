# ADR-0001 — Stack y estructura monorepo

- **Estado:** aceptado
- **Fecha:** 2026-08-12
- **Decisores:** Felipe Madero, Claude (asesoría técnica)

## Contexto

PolygonPlus necesita una base técnica moderna, mantenible y desplegable rápido, aprovechando los servicios ya contratados por Polygon (Vercel, Supabase, Railway, GitHub). Debe soportar un dashboard web y un conjunto de servicios de agentes que crecerá con el tiempo.

## Decisión

- **Monorepo** gestionado con **pnpm workspaces + Turborepo**.
- **Next.js + TypeScript** para el frontend (`apps/web`), desplegado en **Vercel**.
- **Servicios de agentes** en Node/TypeScript (`services/agents`), desplegados en **Railway**.
- **Supabase** (Postgres + Auth + Storage) como base de datos y Núcleo de Conocimiento.
- **GitHub** como fuente de verdad: código, documentación, gestión (Issues/Projects) y CI/CD.

## Alternativas consideradas

- **Multi-repo** — descartado: fragmenta documentación y dificulta cambios transversales en etapa temprana.
- **Vercel también para los agentes (serverless)** — se prefiere Railway para procesos largos, colas y cron que no encajan bien en el edge; Vercel queda para el frontend.

## Consecuencias

Un solo lugar para todo el proyecto; onboarding y CI más simples. Requiere disciplina de workspaces. Fácil de dividir en multi-repo más adelante si escala lo exige.
