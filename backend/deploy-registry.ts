import { createWalletClient, http, createPublicClient } from 'viem';
import { privateKeyToAccount } from 'viem/accounts';
import { baseSepolia } from 'viem/chains';
import fs from 'fs';

const privateKey = '0x952163c7529521e451c0eb03afa0a49e596d418a30fa926530a023b7e2f23fe8';

async function deploy() {
  const account = privateKeyToAccount(privateKey);
  console.log('Deploying from account:', account.address);

  const publicClient = createPublicClient({
    chain: baseSepolia,
    transport: http('https://sepolia.base.org')
  });

  const walletClient = createWalletClient({
    account,
    chain: baseSepolia,
    transport: http('https://sepolia.base.org')
  });

  const artifactData = fs.readFileSync('./src/abis/ClaimRegistry.json', 'utf-8');
  const artifact = JSON.parse(artifactData);
  const abi = artifact.abi;
  let bytecode = artifact.bytecode;
  if (bytecode.object) {
      bytecode = bytecode.object;
  }

  const hash = await walletClient.deployContract({
    abi,
    bytecode: bytecode as `0x${string}`,
  });

  console.log('Deployment transaction hash:', hash);

  const receipt = await publicClient.waitForTransactionReceipt({ hash });
  
  console.log('Contract deployed at address:', receipt.contractAddress);
}

deploy().catch(console.error);
