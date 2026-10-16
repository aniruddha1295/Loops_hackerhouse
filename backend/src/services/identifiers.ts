// Voice agents rarely pass IDs verbatim: speech-to-text drops the dashes
// ("CLM2026000456"), adds spaces ("clm 2026 000456") or mishears a letter ("CLN…").
// Map anything with the right digit layout back to the stored format.

function normalize(raw: string, prefix: 'CLM' | 'POL'): string {
  const compact = raw.toUpperCase().replace(/[^A-Z0-9]/g, '');
  const match = compact.match(/^([A-Z]{3})(\d{4})(\d{6})$/);
  if (!match || match[1][0] !== prefix[0]) {
    return raw.trim();
  }
  return `${prefix}-${match[2]}-${match[3]}`;
}

/** "CLM2026000456", "clm 2026 000456", "CLN-2026-000456" → "CLM-2026-000456" */
export function normalizeClaimNumber(raw: string): string {
  return normalize(raw, 'CLM');
}

/** "POL2024001234", "pol 2024 001234" → "POL-2024-001234" */
export function normalizePolicyNumber(raw: string): string {
  return normalize(raw, 'POL');
}
