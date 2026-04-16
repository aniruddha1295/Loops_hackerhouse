import { SupabaseClient } from '@supabase/supabase-js';
import * as chrono from 'chrono-node';

export async function scheduleCallback(
  supabase: SupabaseClient,
  data: { phone_number: string; preferred_time: string; reason?: string }
) {
  // Trim inputs to avoid whitespace-only strings
  data.phone_number = (data.phone_number || '').trim();
  const preferredTimeInput = data.preferred_time?.trim() || '';

  let scheduledTime = preferredTimeInput
    ? chrono.parseDate(preferredTimeInput, new Date(), { forwardDate: true })
    : null;

  if (!scheduledTime) {
    scheduledTime = new Date();
    scheduledTime.setDate(scheduledTime.getDate() + 1);
    scheduledTime.setHours(10, 0, 0, 0);
  }

  if (scheduledTime.getTime() < Date.now()) {
    scheduledTime.setDate(scheduledTime.getDate() + 1);
  }

  const { error } = await supabase.from('scheduled_callbacks').insert({
    phone_number: data.phone_number,
    scheduled_time: scheduledTime.toISOString(),
    reason: data.reason || 'Callback requested during call',
    status: 'pending',
  });

  if (error) {
    return { success: false, message: 'I was unable to schedule the callback. Please try again.' };
  }

  const formatted = scheduledTime.toLocaleString('en-US', {
    weekday: 'long',
    month: 'long',
    day: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
  });

  return {
    success: true,
    scheduled_time: scheduledTime.toISOString(),
    message: `I've scheduled a callback for ${formatted}. An agent will call you at ${data.phone_number}.`,
  };
}
