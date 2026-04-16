import fp from 'fastify-plugin';
import { createClient, SupabaseClient } from '@supabase/supabase-js';
import { FastifyInstance } from 'fastify';
import { config } from '../config/environment.js';

declare module 'fastify' {
  interface FastifyInstance {
    supabase: SupabaseClient;
  }
}

export default fp(async function supabasePlugin(fastify: FastifyInstance) {
  const supabase = createClient(config.supabaseUrl, config.supabaseServiceRoleKey);
  fastify.decorate('supabase', supabase);
}, {
  name: 'supabase',
});
