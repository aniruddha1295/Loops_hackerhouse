import { SupabaseClient } from '@supabase/supabase-js';
import { CallLog, CallToolExecution } from '../types/index.js';

export async function createCallLog(
  supabase: SupabaseClient,
  data: Partial<CallLog>
): Promise<CallLog> {
  const { data: callLog, error } = await supabase
    .from('call_logs')
    .insert(data)
    .select()
    .single();
  if (error) throw error;
  return callLog;
}

export async function updateCallLog(
  supabase: SupabaseClient,
  id: string,
  data: Partial<CallLog>
): Promise<CallLog> {
  const { data: callLog, error } = await supabase
    .from('call_logs')
    .update(data)
    .eq('id', id)
    .select()
    .single();
  if (error) throw error;
  return callLog;
}

export async function logToolExecution(
  supabase: SupabaseClient,
  data: Partial<CallToolExecution>
): Promise<CallToolExecution> {
  const { data: execution, error } = await supabase
    .from('call_tool_executions')
    .insert(data)
    .select()
    .single();
  if (error) throw error;
  return execution;
}

export async function getCallWithExecutions(
  supabase: SupabaseClient,
  callId: string
): Promise<CallLog & { tool_executions: CallToolExecution[] }> {
  const { data: callLog, error: callError } = await supabase
    .from('call_logs')
    .select('*')
    .eq('id', callId)
    .single();
  if (callError) throw callError;

  const { data: executions, error: execError } = await supabase
    .from('call_tool_executions')
    .select('*')
    .eq('call_log_id', callId)
    .order('executed_at', { ascending: true });
  if (execError) throw execError;

  return { ...callLog, tool_executions: executions || [] };
}
