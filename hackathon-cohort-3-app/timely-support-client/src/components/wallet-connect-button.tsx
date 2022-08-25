import { useAuth } from '@micro-stacks/react';
import { useNetwork } from '@micro-stacks/react';

export const WalletConnectButton = () => {
  const { isMainnet, setNetwork } = useNetwork();
  const networkMode = isMainnet ? 'mainnet' : 'testnet';
  
  const { openAuthRequest, isRequestPending, signOut, isSignedIn } = useAuth();
  const label = isRequestPending ? 'Loading...' : isSignedIn ? 'Sign out' : 'Connect Stacks wallet';
  return (
    <>
    <button onClick={() => setNetwork(isMainnet ? 'testnet' : 'mainnet')}>{networkMode}</button>
    <p></p>
    <button
      onClick={() => {
        if (isSignedIn) void signOut();
        else void openAuthRequest();
      }}
    >
      {label}
    </button>
    </>
  );
};
