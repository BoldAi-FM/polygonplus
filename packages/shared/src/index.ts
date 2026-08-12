/**
 * Tipos y utilidades compartidas entre web y agentes.
 * Reflejan el modelo de datos de Supabase (ver docs/data-model.md).
 */

export type ClientStatus = "active" | "paused" | "lost";
export type ClientModel = "iguala" | "project";
export type TaskStatus =
  | "backlog"
  | "planned"
  | "in_progress"
  | "review"
  | "done"
  | "blocked";
export type TaskPriority = "low" | "medium" | "high" | "urgent";
export type TaskOrigin = "planned" | "urgent";
export type AgentLayer =
  | "knowledge"
  | "operations"
  | "intelligence"
  | "tactical"
  | "backoffice";

export interface Client {
  id: string;
  name: string;
  slug: string;
  status: ClientStatus;
  model: ClientModel;
  monthlyFee: number | null;
  notes: string | null;
  createdAt: string;
}

export interface Task {
  id: string;
  clientId: string | null;
  title: string;
  description: string | null;
  status: TaskStatus;
  priority: TaskPriority;
  origin: TaskOrigin;
  assigneeId: string | null;
  requestedBy: string | null;
  dueDate: string | null;
  createdAt: string;
}

export const APP_NAME = "PolygonPlus";
