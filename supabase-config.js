/* Supabase 대시보드 → Project Settings → Data API(또는 API Keys)에서 복사해 넣는다.
   url: Project URL (https://xxxx.supabase.co, 끝에 /rest/v1/ 없이)
   key: anon public 키 또는 publishable 키 (sb_publishable_...)
   이 키는 공개되어도 되는 값이다. 보안은 supabase-setup.sql의 RLS 정책이 맡는다.
   service_role / secret 키는 절대 넣지 말 것. */
window.ECO100_SUPABASE = {
  url: "https://quymtrwcdrjkuvnodmyu.supabase.co",
  key: "sb_publishable_G4hzODJHeW4Zq-u6EYpxcQ_iNCwCuiS"
};
