import { createClient } from '@supabase/supabase-js'

const rawSupabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://placeholder.supabase.co'
// "/" means Supabase is proxied on the same origin (Docker setup)
const supabaseUrl = rawSupabaseUrl.startsWith('/') ? window.location.origin : rawSupabaseUrl
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'placeholder'

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
