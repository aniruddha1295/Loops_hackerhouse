import { SupabaseClient } from '@supabase/supabase-js';

export async function lookupPolicy(
  supabase: SupabaseClient,
  policyNumber: string
) {
  policyNumber = policyNumber.trim();

  const { data, error } = await supabase
    .from('policies')
    .select('*, customers!inner(full_name)')
    .eq('policy_number', policyNumber)
    .single();

  if (error || !data) {
    return { found: false as const };
  }

  const customer_name = (data.customers as any)?.full_name || 'Unknown';

  return {
    found: true as const,
    policy: {
      policy_number: data.policy_number,
      policy_type: data.policy_type,
      provider: data.provider,
      status: data.status,
      coverage_amount: data.coverage_amount,
      deductible: data.deductible,
      premium_monthly: data.premium_monthly,
      coverage_details: data.coverage_details,
      customer_name,
    },
  };
}
