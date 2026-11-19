-- Cole tudo isto no Supabase > SQL Editor > New query > Run

create table if not exists public.forja_dados (
  user_id uuid primary key references auth.users(id) on delete cascade,
  dados jsonb not null default '{}'::jsonb,
  atualizado_em timestamptz not null default now()
);

alter table public.forja_dados enable row level security;

-- Cada pessoa só lê e grava os próprios dados
create policy "ler os meus"     on public.forja_dados for select using (auth.uid() = user_id);
create policy "criar os meus"   on public.forja_dados for insert with check (auth.uid() = user_id);
create policy "alterar os meus" on public.forja_dados for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

create or replace function public.forja_carimbo() returns trigger language plpgsql as $$
begin new.atualizado_em = now(); return new; end $$;

drop trigger if exists forja_carimbo on public.forja_dados;
create trigger forja_carimbo before update on public.forja_dados
for each row execute function public.forja_carimbo();
