-- 사진 여러 장 올리기를 위한 추가 설정 (이미 운영 중인 프로젝트에 한 번만 실행)
-- Supabase 대시보드 → SQL Editor → New query에 붙여 넣고 Run. 여러 번 실행해도 안전하다.
alter table public.entries
  add column if not exists photo_count int not null default 1 check (photo_count between 1 and 10);

-- 표 구조가 바뀐 것을 API가 바로 알도록 새로 읽게 한다.
notify pgrst, 'reload schema';
