-- PolygonPlus — esquema base (Fase 0)
-- Núcleo de Conocimiento (Capa 0) + Capa Operativa (Capa 1)

create extension if not exists "pgcrypto";

-- ---------- Enums ----------
create type client_status as enum ('active', 'paused', 'lost');
create type client_model  as enum ('iguala', 'project');
create type task_status    as enum ('backlog', 'planned', 'in_progress', 'review', 'done', 'blocked');
create type task_priority  as enum ('low', 'medium', 'high', 'urgent');
create type task_origin    as enum ('planned', 'urgent'); -- métrica north star: planeación vs urgencia
create type agent_layer     as enum ('knowledge', 'operations', 'intelligence', 'tactical', 'backoffice');
create type agent_status    as enum ('idea', 'design', 'building', 'active');

-- ---------- profiles ----------
create table profiles (
  id           uuid primary key references auth.users (id) on delete cascade,
  full_name    text not null,
  role         text,                       -- ej. 'CEO', 'PM Sr', 'Art Director'
  is_freelance boolean not null default false,
  active       boolean not null default true,
  created_at   timestamptz not null default now()
);

-- ---------- clients ----------
create table clients (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  slug        text not null unique,
  status      client_status not null default 'active',
  model       client_model  not null default 'iguala',
  monthly_fee numeric,
  notes       text,
  created_at  timestamptz not null default now()
);

-- ---------- brands ----------
create table brands (
  id         uuid primary key default gen_random_uuid(),
  client_id  uuid not null references clients (id) on delete cascade,
  name       text not null,
  slug       text not null,
  created_at timestamptz not null default now(),
  unique (client_id, slug)
);

-- ---------- client_assignments ----------
create table client_assignments (
  id              uuid primary key default gen_random_uuid(),
  client_id       uuid not null references clients (id) on delete cascade,
  profile_id      uuid not null references profiles (id) on delete cascade,
  role_on_account text,
  created_at      timestamptz not null default now(),
  unique (client_id, profile_id)
);

-- ---------- tasks ----------
create table tasks (
  id           uuid primary key default gen_random_uuid(),
  client_id    uuid references clients (id) on delete set null,
  brand_id     uuid references brands (id) on delete set null,
  title        text not null,
  description  text,
  status       task_status   not null default 'backlog',
  priority     task_priority not null default 'medium',
  origin       task_origin   not null default 'planned',
  assignee_id  uuid references profiles (id) on delete set null,
  requested_by uuid references profiles (id) on delete set null,
  due_date     date,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);
create index tasks_client_idx on tasks (client_id);
create index tasks_status_idx on tasks (status);

-- ---------- task_comments (el hilo por tarea) ----------
create table task_comments (
  id         uuid primary key default gen_random_uuid(),
  task_id    uuid not null references tasks (id) on delete cascade,
  author_id  uuid references profiles (id) on delete set null,
  body       text not null,
  created_at timestamptz not null default now()
);
create index task_comments_task_idx on task_comments (task_id);

-- ---------- processes (SOPs) ----------
create table processes (
  id         uuid primary key default gen_random_uuid(),
  client_id  uuid references clients (id) on delete set null,
  title      text not null,
  slug       text not null unique,
  content    text,
  owner_id   uuid references profiles (id) on delete set null,
  updated_at timestamptz not null default now()
);

-- ---------- agents (registro del ecosistema) ----------
create table agents (
  id         uuid primary key default gen_random_uuid(),
  name       text not null,
  layer      agent_layer  not null,
  status     agent_status not null default 'idea',
  owner_id   uuid references profiles (id) on delete set null,
  spec_url   text,
  created_at timestamptz not null default now()
);

-- ---------- RLS (habilitado; políticas finas después) ----------
alter table profiles           enable row level security;
alter table clients            enable row level security;
alter table brands             enable row level security;
alter table client_assignments enable row level security;
alter table tasks              enable row level security;
alter table task_comments      enable row level security;
alter table processes          enable row level security;
alter table agents             enable row level security;
