// Voice agents rarely pass IDs verbatim: speech-to-text drops the dashes
// ("CLM2026000456"), adds spaces ("clm 2026 000456") or mishears the letters
// ("CLN…", "TOL…"). Each caller only ever looks up one kind of ID, so the
// digit layout (4-digit year + 6-digit sequence) is what identifies it.

function normalize(raw: string, prefix: 'CLM' | 'POL'): string {
  const compact = raw.toUpperCase().replace(/[^A-Z0-9]/g, '');
  const match = compact.match(/^[A-Z]{0,4}(\d{4})(\d{6})$/);
  if (!match) {
    return raw.trim();
  }
  return `${prefix}-${match[1]}-${match[2]}`;
}

/** "CLM2026000456", "clm 2026 000456", "CLF-2026-000456" → "CLM-2026-000456" */
export function normalizeClaimNumber(raw: string): string {
  return normalize(raw, 'CLM');
}

/** "POL2024001234", "pol 2024 001234", "TOL2024001234" → "POL-2024-001234" */
export function normalizePolicyNumber(raw: string): string {
  return normalize(raw, 'POL');
}
