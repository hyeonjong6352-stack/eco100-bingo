-- ECO-100 빙고 도장판: Supabase 초기 설정
-- Supabase 대시보드 → SQL Editor → New query에 전부 붙여 넣고 Run. 여러 번 실행해도 안전하다.
--
-- 규칙
-- - 읽기: 페이지를 연 누구나 (페이지가 자동으로 익명 로그인한다)
-- - 올리기: 정해진 모양의 기록만, 자기 uid로만
-- - 삭제: 그 기록을 올린 기기(uid)만
-- - 수정: 아무도 못 함 (관리자는 대시보드 Table Editor에서 직접 수정·삭제)

-- 1. 인증 기록 표
create table if not exists public.entries (
  id          uuid primary key,
  who         text not null check (who in ('p1', 'p2', 'p3', 'p4', 'p5', 'p6', 'p7', 'p8', 'p9')),
  mission     int  not null check (mission between 1 and 9),
  note        text not null check (char_length(note) between 1 and 300),
  date        date not null,
  thumb       text not null check (char_length(thumb) <= 80000 and thumb like 'data:image/%'),
  photo_path  text not null,
  uid         uuid not null default auth.uid(),
  created_at  timestamptz not null default now(),
  check (photo_path = uid::text || '/' || id::text || '.jpg')
);

alter table public.entries enable row level security;
grant select, insert, delete on public.entries to authenticated;

drop policy if exists "entries read" on public.entries;
create policy "entries read" on public.entries
  for select to authenticated using (true);

drop policy if exists "entries insert own" on public.entries;
create policy "entries insert own" on public.entries
  for insert to authenticated with check (uid = (select auth.uid()));

drop policy if exists "entries delete own" on public.entries;
create policy "entries delete own" on public.entries
  for delete to authenticated using (uid = (select auth.uid()));

-- 2. 실시간 반영 켜기
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'entries'
  ) then
    alter publication supabase_realtime add table public.entries;
  end if;
end $$;

-- 3. 사진 저장소: 공개 읽기, 1MB 이하 JPEG만, 자기 uid 폴더에만 올리고 지울 수 있음
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('photos', 'photos', true, 1048576, array['image/jpeg'])
on conflict (id) do update
  set public = true, file_size_limit = 1048576, allowed_mime_types = array['image/jpeg'];

drop policy if exists "eco100 photos read" on storage.objects;
create policy "eco100 photos read" on storage.objects
  for select to authenticated using (bucket_id = 'photos');

drop policy if exists "eco100 photos upload own" on storage.objects;
create policy "eco100 photos upload own" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'photos' and (storage.foldername(name))[1] = (select auth.uid())::text);

drop policy if exists "eco100 photos delete own" on storage.objects;
create policy "eco100 photos delete own" on storage.objects
  for delete to authenticated
  using (bucket_id = 'photos' and (storage.foldername(name))[1] = (select auth.uid())::text);
