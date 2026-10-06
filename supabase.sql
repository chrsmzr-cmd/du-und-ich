-- Chris & Juana – Datenbank für die Fernbeziehungs-Karte
-- Einmal komplett im Supabase SQL Editor ausführen.
-- Am Ende erscheint eine Tabelle mit euren zwei persönlichen Codes.

create extension if not exists pgcrypto;

-- Standorte: eine Zeile pro Person
create table if not exists public.cj_people (
  who        text primary key check (who in ('chris', 'juana')),
  token      uuid not null unique default gen_random_uuid(),
  lat        double precision,
  lng        double precision,
  place      text,
  cc         text,
  updated_at timestamptz
);

-- Nächstes Wiedersehen: genau eine Zeile
create table if not exists public.cj_plan (
  id         int primary key default 1 check (id = 1),
  at         timestamptz,
  place      text,
  by_who     text,
  updated_at timestamptz
);

-- Kein direkter Zugriff auf die Tabellen von außen.
-- Lesen und Schreiben geht nur über die Funktionen unten, und nur mit gültigem Code.
alter table public.cj_people enable row level security;
alter table public.cj_plan   enable row level security;
revoke all on public.cj_people, public.cj_plan from anon, authenticated;

insert into public.cj_people (who) values ('chris'), ('juana') on conflict do nothing;
insert into public.cj_plan (id) values (1) on conflict do nothing;

-- Wer gehört zu diesem Code?
create or replace function public.cj_who(p_token text)
returns text language plpgsql stable security definer set search_path = public as $$
declare v text;
begin
  begin
    select who into v from cj_people where token = p_token::uuid;
  exception when others then
    return null;
  end;
  return v;
end $$;

-- Gesamter Stand für die Karte
create or replace function public.cj_state(p_token text)
returns json language plpgsql stable security definer set search_path = public as $$
declare me text := cj_who(p_token);
begin
  if me is null then
    raise exception 'Ungültiger Code' using errcode = '28000';
  end if;
  return json_build_object(
    'me', me,
    'people', (select json_object_agg(who, json_build_object(
                  'lat', lat, 'lng', lng, 'place', place, 'cc', cc,
                  'updatedAt', (extract(epoch from updated_at) * 1000)::bigint))
               from cj_people),
    'plan', (select case when at is null then null else json_build_object(
                  'at', (extract(epoch from at) * 1000)::bigint,
                  'place', place, 'by', by_who,
                  'updatedAt', (extract(epoch from updated_at) * 1000)::bigint) end
             from cj_plan where id = 1)
  );
end $$;

-- Standort senden (Web-App und Kurzbefehl).
-- Koordinaten als Text, damit auch "52,1305" mit Komma funktioniert.
-- Gespeichert wird auf 2 Nachkommastellen gerundet (etwa 1 km genau).
create or replace function public.cj_update_location(
  p_token text, p_lat text, p_lng text, p_place text default null, p_cc text default null)
returns json language plpgsql security definer set search_path = public as $$
declare
  me text := cj_who(p_token);
  v_lat double precision;
  v_lng double precision;
begin
  if me is null then
    raise exception 'Ungültiger Code' using errcode = '28000';
  end if;
  v_lat := replace(trim(p_lat), ',', '.')::double precision;
  v_lng := replace(trim(p_lng), ',', '.')::double precision;
  if v_lat not between -90 and 90 or v_lng not between -180 and 180 then
    raise exception 'Koordinaten außerhalb des gültigen Bereichs';
  end if;
  update cj_people set
    lat = round(v_lat::numeric, 2),
    lng = round(v_lng::numeric, 2),
    place = left(nullif(trim(coalesce(p_place, '')), ''), 80),
    cc = left(nullif(upper(trim(coalesce(p_cc, ''))), ''), 3),
    updated_at = now()
  where who = me;
  return cj_state(p_token);
end $$;

-- Wiedersehen eintragen oder ändern
create or replace function public.cj_set_plan(p_token text, p_at timestamptz, p_place text default null)
returns json language plpgsql security definer set search_path = public as $$
declare me text := cj_who(p_token);
begin
  if me is null then
    raise exception 'Ungültiger Code' using errcode = '28000';
  end if;
  update cj_plan set at = p_at, place = left(nullif(trim(coalesce(p_place, '')), ''), 80),
                     by_who = me, updated_at = now()
  where id = 1;
  return cj_state(p_token);
end $$;

-- Wiedersehen löschen
create or replace function public.cj_clear_plan(p_token text)
returns json language plpgsql security definer set search_path = public as $$
declare me text := cj_who(p_token);
begin
  if me is null then
    raise exception 'Ungültiger Code' using errcode = '28000';
  end if;
  update cj_plan set at = null, place = null, by_who = me, updated_at = now() where id = 1;
  return cj_state(p_token);
end $$;

-- Nur die vier Funktionen für die App freigeben
revoke all on function public.cj_who(text) from public, anon, authenticated;
revoke all on function public.cj_state(text), public.cj_update_location(text, text, text, text, text),
                       public.cj_set_plan(text, timestamptz, text), public.cj_clear_plan(text) from public;
grant execute on function public.cj_state(text), public.cj_update_location(text, text, text, text, text),
                          public.cj_set_plan(text, timestamptz, text), public.cj_clear_plan(text) to anon, authenticated;

-- Eure persönlichen Codes (geheim halten!)
select who as person, token as code from public.cj_people order by who;
