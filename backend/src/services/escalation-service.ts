import { SupabaseClient } from '@supabase/supabase-js';

export async function createEscalation(
  supabase: SupabaseClient,
  data: {
    reason: string;
    priority?: string;
    call_log_id?: string;
    customer_id?: string;
    claim_id?: string;
  }
) {
  // Trim reason to avoid whitespace-only strings
  data.reason = (data.reason || '').trim();

  // Handle the NOT NULL FK constraint — create a placeholder call_log if none provided
  let callLogId = data.call_log_id;
  if (!callLogId) {
    const { data: callLog, error: callLogError } = await supabase
      .from('call_logs')
      .insert({ direction: 'inbound', status: 'in_progress' })
      .select('id')
      .single();
    if (callLogError || !callLog) {
      console.error('Escalation: call_log creation failed:', callLogError);
      return { success: false, message: 'I was unable to create the escalation. Please try again.' };
    }
    callLogId = callLog.id;
  }

  // Validate priority (default to 'normal')
  const validPriorities = ['low', 'normal', 'high', 'urgent'];
  const priority = validPriorities.includes(data.priority || '') ? data.priority! : 'normal';

  // Generate reference number
  const year = new Date().getFullYear();
  const seq = String(Math.floor(Math.random() * 10000)).padStart(4, '0');
  const referenceNumber = `ESC-${year}-${seq}`;

  // SLA mapping
  const slaMap: Record<string, string> = {
    urgent: 'within 1 business hour',
    high: 'within 2 business hours',
    normal: 'within 24 hours',
    low: 'within 48 hours',
  };

  // Insert escalation
  const { error } = await supabase.from('escalations').insert({
    call_log_id: callLogId,
    reason: data.reason,
    priority,
    status: 'pending',
    customer_id: data.customer_id || null,
    claim_id: data.claim_id || null,
    notes: `Escalated during live call. Reference: ${referenceNumber}`,
  });

  if (error) {
    console.error('Escalation: insert failed:', error);
    return { success: false, message: 'I was unable to create the escalation. Please try again.' };
  }

  return {
    success: true,
    reference_number: referenceNumber,
    message: `I've escalated this to a supervisor. You can expect a response ${slaMap[priority]}. Your reference number is ${referenceNumber}.`,
  };
}
