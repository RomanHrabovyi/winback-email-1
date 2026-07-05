-- Run this in the Supabase project's SQL editor (Dashboard -> SQL Editor -> New query).
-- It creates the tables and access rules the website in index.html expects.

create extension if not exists pgcrypto;

-- ─────────────────────────────────────────────
-- Listings (apartments) — read publicly, edited by you via the Table Editor
-- ─────────────────────────────────────────────
create table if not exists listings (
  id           uuid primary key default gen_random_uuid(),
  title        text not null,
  location     text not null,
  purpose      text not null check (purpose in ('sale', 'rent')),
  property_type text,                          -- studio | 1br | 2br | penthouse
  price        numeric not null,
  currency     text not null default 'EUR',
  beds         int,
  baths        int,
  area_sqm     numeric,
  image_url    text,
  badge        text,                           -- e.g. 'For Sale', 'For Rent', 'New'
  featured     boolean not null default true,
  created_at   timestamptz not null default now()
);

alter table listings enable row level security;

drop policy if exists "Public can read listings" on listings;
create policy "Public can read listings"
  on listings for select
  using (true);

-- No insert/update/delete policy for the public (anon) role on purpose:
-- add/edit/remove listings from the Supabase Dashboard -> Table Editor,
-- which connects as an admin and bypasses these policies.

-- ─────────────────────────────────────────────
-- Leads — contact form submissions
-- ─────────────────────────────────────────────
create table if not exists leads (
  id         uuid primary key default gen_random_uuid(),
  full_name  text not null,
  phone      text,
  email      text not null,
  message    text,
  created_at timestamptz not null default now()
);

alter table leads enable row level security;

drop policy if exists "Public can submit leads" on leads;
create policy "Public can submit leads"
  on leads for insert
  with check (true);

-- No select policy: leads are private, visible only to you via the Dashboard.

-- ─────────────────────────────────────────────
-- Subscribers — newsletter signups
-- ─────────────────────────────────────────────
create table if not exists subscribers (
  id         uuid primary key default gen_random_uuid(),
  email      text not null unique,
  created_at timestamptz not null default now()
);

alter table subscribers enable row level security;

drop policy if exists "Public can subscribe" on subscribers;
create policy "Public can subscribe"
  on subscribers for insert
  with check (true);

-- ─────────────────────────────────────────────
-- Sample listings so the site isn't empty on first load
-- ─────────────────────────────────────────────
insert into listings (title, location, purpose, property_type, price, currency, beds, baths, area_sqm, image_url, badge, featured)
values
  ('Sunset Residence — 2BR Apartment', 'Blloku, Tirana', 'sale', '2br', 142000, 'EUR', 2, 1, 78, 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=800&q=80', 'For Sale', true),
  ('Urban Studio Loft', 'Myslym Shyri', 'rent', 'studio', 650, 'EUR', 0, 1, 42, 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&w=800&q=80', 'For Rent', true),
  ('Skyline Penthouse', 'New Bulevard', 'sale', 'penthouse', 310000, 'EUR', 3, 2, 145, 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=800&q=80', 'For Sale', true),
  ('Lakeview 1BR Apartment', 'Liqeni i Thatë', 'rent', '1br', 480, 'EUR', 1, 1, 56, 'https://images.unsplash.com/photo-1484154218962-a197022b5858?auto=format&fit=crop&w=800&q=80', 'For Rent', true),
  ('Green Park Residences — 2BR', 'Kombinat, Tirana', 'sale', '2br', 198000, 'EUR', 2, 2, 91, 'https://images.unsplash.com/photo-1560184897-ae75f418493e?auto=format&fit=crop&w=800&q=80', 'New', true),
  ('Panorama Apartment with Balcony', 'Rruga e Kavajës', 'sale', '2br', 165500, 'EUR', 2, 1, 84, 'https://images.unsplash.com/photo-1502005229762-cf1b2da7c5d6?auto=format&fit=crop&w=800&q=80', 'For Sale', true)
on conflict do nothing;
