import { useAccount, useOpenContractCall } from '@micro-stacks/react';
import { useState } from 'react';
import {
  uintCV,
  intCV,
  bufferCV,
  stringAsciiCV,
  stringUtf8CV,
  standardPrincipalCV,
  trueCV,
} from 'micro-stacks/clarity';
import { utf8ToBytes } from 'micro-stacks/common';
import { FungibleConditionCode, makeStandardSTXPostCondition } from 'micro-stacks/transactions';


export const Register = () => {
  
  const { openContractCall, isRequestPending } = useOpenContractCall();
  const { stxAddress } = useAccount();
  const [response, setResponse] = useState(null);

  const functionArgs = [
    // uintCV(1234),
    // intCV(-234),
    // bufferCV(utf8ToBytes('hello, world')),
    // stringAsciiCV('hey-ascii'),
    // stringUtf8CV('hey-utf8'),
    standardPrincipalCV('ST36MGP65JZ55MP6AND0RG80JK68AD5VYBEMHE0GC'),
    // trueCV(),
  ];

  const handleOpenContractCallStudent = async () => {
    const postConditions = [
      makeStandardSTXPostCondition(stxAddress!, FungibleConditionCode.LessEqual, '100'),
    ];
 
    await openContractCall({
      contractAddress: 'ST36MGP65JZ55MP6AND0RG80JK68AD5VYBEMHE0GC',
      contractName: 'student',
      functionName: 'register',
      functionArgs,
      postConditions,
      attachment: 'This is an attachment',
      onFinish: async data => {
        console.log('finished contract call!', data);
        setResponse(data);
      },
      onCancel: () => {
        console.log('popup closed!');
      },
    });
  };

  const handleOpenContractCallGuru = async () => {
    const postConditions = [
      makeStandardSTXPostCondition(stxAddress!, FungibleConditionCode.LessEqual, '100'),
    ];
 
    await openContractCall({
      contractAddress: 'ST36MGP65JZ55MP6AND0RG80JK68AD5VYBEMHE0GC',
      contractName: 'guru',
      functionName: 'register',
      functionArgs,
      postConditions,
      attachment: 'This is an attachment',
      onFinish: async data => {
        console.log('finished contract call!', data);
        setResponse(data);
      },
      onCancel: () => {
        console.log('popup closed!');
      },
    });
  };

  if (!stxAddress)
    return (
      <div className={'user-card'}>
        <h3>Connect to Register with Timely Support</h3>
      </div>
    );
    return (
      <div>
        <h4>Timely Support Sign Up</h4>
        {response && (
          <pre>
            <code>{JSON.stringify(response, null, 2)}</code>
          </pre>
        )}
        
        <button onClick={() => handleOpenContractCallStudent()}>
          {isRequestPending ? 'request pending...' : 'Register as Student'}
        </button>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <button onClick={() => handleOpenContractCallGuru()}>
          {isRequestPending ? 'request pending...' : 'Register as Guru'}
        </button>
      </div>
   );
};
