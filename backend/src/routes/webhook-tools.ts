import { FastifyInstance } from 'fastify';
import { lookupClaim, checkDocuments, fileClaim } from '../services/claims-service.js';
import { createEscalation } from '../services/escalation-service.js';
import { scheduleCallback } from '../services/callback-service.js';
import { lookupPolicy } from '../services/policy-service.js';

export default async function webhookToolsRoutes(fastify: FastifyInstance) {
  // POST /tools/lookup-claim — look up a claim by claim number
  fastify.post('/tools/lookup-claim', async (request) => {
    try {
      const { claim_id } = request.body as { claim_id?: string };

      if (!claim_id) {
        return { found: false, message: 'Please provide a claim number.' };
      }

      fastify.log.info({ tool: 'lookup-claim', args: { claim_id } }, 'Tool invoked');
      const result = await lookupClaim(fastify.supabase, claim_id);
      fastify.log.info({ tool: 'lookup-claim', success: result.found }, 'Tool completed');
      return result;
    } catch (err) {
      fastify.log.error(err, 'lookup-claim tool failed');
      return { found: false, message: 'I was unable to look up that claim. Please try again.' };
    }
  });

  // POST /tools/check-policy — look up a policy by policy number
  fastify.post('/tools/check-policy', async (request) => {
    try {
      const { policy_number } = request.body as { policy_number?: string };

      if (!policy_number) {
        return { found: false, message: 'Please provide a policy number.' };
      }

      fastify.log.info({ tool: 'check-policy', args: { policy_number } }, 'Tool invoked');
      const result = await lookupPolicy(fastify.supabase, policy_number);
      fastify.log.info({ tool: 'check-policy', success: result.found }, 'Tool completed');
      return result;
    } catch (err) {
      fastify.log.error(err, 'check-policy tool failed');
      return { found: false, message: 'I was unable to look up that policy. Please try again.' };
    }
  });

  // POST /tools/check-documents — check documents for a claim by claim number
  fastify.post('/tools/check-documents', async (request) => {
    try {
      const { claim_id } = request.body as { claim_id?: string };

      if (!claim_id) {
        return { found: false, message: 'Please provide a claim number.' };
      }

      fastify.log.info({ tool: 'check-documents', args: { claim_id } }, 'Tool invoked');
      const result = await checkDocuments(fastify.supabase, claim_id);
      fastify.log.info({ tool: 'check-documents', success: result.found }, 'Tool completed');
      return result;
    } catch (err) {
      fastify.log.error(err, 'check-documents tool failed');
      return { found: false, message: 'I was unable to check the documents for that claim. Please try again.' };
    }
  });

  // POST /tools/file-claim — file a new insurance claim
  fastify.post('/tools/file-claim', async (request) => {
    try {
      const body = request.body as {
        policy_number: string;
        claim_type: string;
        incident_date: string;
        incident_description: string;
      };
      if (!body.policy_number || !body.incident_description) {
        return {
          success: false,
          message: 'I need at least a policy number and description of the incident to file a claim.',
        };
      }
      if (!body.claim_type?.trim()) {
        return {
          success: false,
          message: 'I need to know what type of claim this is, such as a collision, theft, or water damage.',
        };
      }
      fastify.log.info({ tool: 'file-claim', args: { policy_number: body.policy_number, claim_type: body.claim_type } }, 'Tool invoked');
      const result = await fileClaim(fastify.supabase, body);
      fastify.log.info({ tool: 'file-claim', success: result.success }, 'Tool completed');
      return result;
    } catch (error) {
      fastify.log.error(error, 'Error in file-claim');
      return {
        success: false,
        message: 'I was unable to file the claim right now. Please try again or I can transfer you to an agent.',
      };
    }
  });

  // POST /tools/escalate-to-human — escalate call to a human supervisor
  fastify.post('/tools/escalate-to-human', async (request) => {
    try {
      const body = request.body as { reason: string; priority?: string };
      if (!body.reason) {
        return {
          success: false,
          message: 'Could you tell me the reason you would like to speak with a supervisor?',
        };
      }
      fastify.log.info({ tool: 'escalate-to-human', args: { reason: body.reason, priority: body.priority } }, 'Tool invoked');
      const result = await createEscalation(fastify.supabase, body);
      fastify.log.info({ tool: 'escalate-to-human', success: result.success }, 'Tool completed');
      return result;
    } catch (error) {
      fastify.log.error(error, 'Error in escalate-to-human');
      return {
        success: false,
        message: 'I was unable to create the escalation. Please hold while I try again.',
      };
    }
  });

  // POST /tools/schedule-callback — schedule a callback for the customer
  fastify.post('/tools/schedule-callback', async (request) => {
    try {
      const body = request.body as {
        phone_number: string;
        preferred_time: string;
        reason?: string;
      };
      if (!body.phone_number) {
        return {
          success: false,
          message: 'I need a phone number to schedule the callback.',
        };
      }
      if (!body.preferred_time?.trim()) {
        return {
          success: false,
          message: 'When would you like us to call you back?',
        };
      }
      fastify.log.info({ tool: 'schedule-callback', args: { phone_number: body.phone_number, preferred_time: body.preferred_time } }, 'Tool invoked');
      const result = await scheduleCallback(fastify.supabase, body);
      fastify.log.info({ tool: 'schedule-callback', success: result.success }, 'Tool completed');
      return result;
    } catch (error) {
      fastify.log.error(error, 'Error in schedule-callback');
      return {
        success: false,
        message: 'I was unable to schedule the callback. Can I try a different time?',
      };
    }
  });
}
