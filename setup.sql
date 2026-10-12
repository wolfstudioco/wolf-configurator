-- Shinola Finish Approvals schema
create table if not exists public.pieces (
  id text primary key,
  ord int not null default 0,
  section text not null default 'Guestrooms',
  name text not null default '',
  spec text not null default '',
  status text not null default 'pending',
  notes text not null default '',
  image_url text,
  swatches jsonb not null default '[]'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.pieces enable row level security;

drop policy if exists pieces_read on public.pieces;
drop policy if exists pieces_update on public.pieces;
create policy pieces_read on public.pieces for select using (true);
create policy pieces_update on public.pieces for update using (true) with check (true);

grant usage on schema public to anon, authenticated;
grant select, update on public.pieces to anon, authenticated;

create or replace function public.touch_updated_at() returns trigger as $$
begin new.updated_at = now(); return new; end; $$ language plpgsql;
drop trigger if exists pieces_touch on public.pieces;
create trigger pieces_touch before update on public.pieces for each row execute function public.touch_updated_at();

-- storage bucket for renderings + swatches (public read, anon upload)
insert into storage.buckets (id, name, public) values ('approvals','approvals',true)
on conflict (id) do update set public = true;

drop policy if exists approvals_read on storage.objects;
drop policy if exists approvals_insert on storage.objects;
create policy approvals_read on storage.objects for select to anon, authenticated using (bucket_id = 'approvals');
create policy approvals_insert on storage.objects for insert to anon, authenticated with check (bucket_id = 'approvals');

insert into public.pieces (id,ord,section,name,spec) values
('p01',1,'Guestrooms','Desk','Stained oak veneer top, 1x2.75" hardwood surround, stained oak trestle base - stain TBD'),
('p02',2,'Guestrooms','Desk chair','Stained oak bentwood back, vinyl cushioned seat - stain + vinyl TBD'),
('p03',3,'Guestrooms','Room Divider Screens','Wood frame, vertical asymmetric angled wood slats - stain TBD'),
('p04',4,'Guestrooms','Glass top - nightstands','1/4" bronze tempered glass, pencil-polished edge'),
('p05',5,'Guestrooms','Coffee Bar Tray (30x20")','Oak frame, high-pressure laminate bottom - stain + HPL color TBD'),
('p06',6,'Guestrooms','C-Table Desk (18x24x28")','Stained oak - stain TBD'),
('p07',7,'Guestrooms','Coffee bar doors','Wood Shaker door front - stain TBD'),
('p08',8,'Guestrooms','Coffee tables - guestrooms','Solid hardwood + Paperstone top - stain + Paperstone color TBD'),
('p09',9,'Guestrooms','Rolling desk - wood top','Solid hardwood racetrack oval, knife underside bevel - stain TBD'),
('p10',10,'Guestrooms','End / side tables','Chunky solid hardwood, X base - stain TBD'),
('p11',11,'Guestrooms','Dining chairs (with arms)','Stained oak bentwood back, vinyl cushioned seat - stain + vinyl TBD'),
('p12',12,'Guestrooms','Bedside lamps','Adjustable metal reading light - metal finish TBD'),
('p13',13,'Guestrooms','Decorative pillows','Plush fill + welting - fabric (COM) TBD'),
('p14',14,'Guestrooms','Bed pillows','Plush fill + welting - fabric TBD'),
('p15',15,'Public Spaces','Entry credenza (72x25x42)','Wood veneer, matched species + stain, integrated trash + umbrella storage - stain TBD'),
('p16',16,'Public Spaces','Coffee tables - public','Bespoke oversized statement - materials + finish TBD'),
('p17',17,'Public Spaces','Lounge chairs','Fully upholstered leather + wood feet - leather + stain TBD'),
('p18',18,'Public Spaces','Front bar','Bespoke millwork, feature lighting - materials TBD'),
('p19',19,'Public Spaces','Back bar','Bespoke display millwork, feature lighting - materials TBD'),
('p20',20,'Public Spaces','Sofas','Coil springs, Dacron-wrapped HD foam, welting - upholstery (COM) TBD'),
('p21',21,'Public Spaces','Pillows - public','Custom shape + size - fabric (COM) TBD'),
('p22',22,'Public Spaces','Bar stools','Upholstered seat - seat material + base finish TBD')
on conflict (id) do nothing;
