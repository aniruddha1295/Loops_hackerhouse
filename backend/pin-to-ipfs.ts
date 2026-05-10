import FormData from 'form-data';
import fetch from 'node-fetch';

async function main() {
// Our actual insurance claim evidence bundle
const claimBundle = {
  version: '1.0',
  platform: 'SafeGuard Insurance AI',
  generated_at: new Date().toISOString(),
  claim: {
    claim_number: 'CLM-2024-001234',
    claim_type: 'auto',
    policy_number: 'POL-2024-001234',
    status: 'submitted',
    incident_date: '2024-05-10T00:00:00.000Z',
    incident_description: 'Policyholder was driving on Main Street when they struck a large pothole. The impact caused significant damage to the front right tire, rim, and suspension components.',
    filed_at: new Date().toISOString(),
  },
  customer: {
    policy_holder: 'John Doe',
    contact: 'Verified via AI Voice Agent',
  },
  ai_agent: {
    provider: 'ElevenLabs Conversational AI',
    call_duration_seconds: 87,
    tools_used: ['lookup_policy', 'file_claim'],
    confidence_score: 0.97,
  },
  blockchain: {
    network: 'Base Sepolia',
    contract: '0xdd614aa1c5b4a40feae93f6374d46fc55a6f8c5d',
    attested: true,
  },
};

const jsonContent = JSON.stringify(claimBundle, null, 2);
console.log('Uploading claim bundle to IPFS via Lighthouse...');
console.log('Content preview:', jsonContent.substring(0, 200) + '...');

// Upload via Lighthouse public IPFS node (no auth required for small files)
const form = new FormData();
form.append('file', Buffer.from(jsonContent), {
  filename: 'insurance-claim-evidence.json',
  contentType: 'application/json',
});

try {
  const response = await fetch('https://node.lighthouse.storage/api/v0/add', {
    method: 'POST',
    body: form as any,
    headers: form.getHeaders(),
  });

  if (!response.ok) {
    const text = await response.text();
    console.error('Lighthouse failed:', response.status, text);
    
    // Fallback: try the public IPFS.io node
    console.log('\nTrying ipfs.io public node...');
    const form2 = new FormData();
    form2.append('file', Buffer.from(jsonContent), {
      filename: 'insurance-claim-evidence.json',
      contentType: 'application/json',
    });
    const r2 = await fetch('https://ipfs.io/api/v0/add?pin=true', {
      method: 'POST',
      body: form2 as any,
      headers: form2.getHeaders(),
    });
    const data2 = await r2.json() as any;
    console.log('\n✅ SUCCESS via ipfs.io!');
    console.log('CID:', data2.Hash);
    console.log('Gateway URL:', `https://${data2.Hash}.ipfs.w3s.link`);
    return;
  }

  const data = await response.json() as any;
  console.log('\n✅ SUCCESS via Lighthouse!');
  console.log('CID:', data.Hash);
  console.log('Gateway URL:', `https://${data.Hash}.ipfs.w3s.link`);
  console.log('\nPaste this SQL into Supabase to seed the demo:');
  console.log(`
UPDATE claims
SET 
  filecoin_cid = '${data.Hash}',
  attestation_tx_hash = '0x' || encode(gen_random_bytes(32), 'hex'),
  attested_at = NOW(),
  evidence_hash = '0x' || encode(gen_random_bytes(32), 'hex')
WHERE id = (
  SELECT id FROM claims ORDER BY filed_at DESC LIMIT 1
);
  `);
} catch (err) {
  console.error('Error:', err);
}
}

main();
