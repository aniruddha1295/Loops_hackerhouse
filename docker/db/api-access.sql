-- ============================================
-- API access for the self-contained demo image
-- No RLS: single-tenant demo, every API request runs as `anon`
-- (same as the hackathon Supabase project, where the anon key was public).
-- ============================================

GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated, service_role;
