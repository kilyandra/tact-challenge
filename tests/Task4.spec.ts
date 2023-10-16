import { Blockchain, SandboxContract } from '@ton-community/sandbox';
import { beginCell, toNano } from 'ton-core';
import { Task4 } from '../wrappers/Task4';
import '@ton-community/test-utils';

describe('Task4', () => {
    let blockchain: Blockchain;
    let task4: SandboxContract<Task4>;

    beforeEach(async () => {
        blockchain = await Blockchain.create();
        const deployer = await blockchain.treasury('deployer');
        task4 = blockchain.openContract(await Task4.fromInit(0n));
        const deployResult = await task4.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            }
        );
        expect(deployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: task4.address,
            deploy: true,
            success: true,
        });
    });

    it('test', async () => {
        blockchain = await Blockchain.create();
        const deployer = await blockchain.treasury('deployer');
        const nft = await blockchain.treasury('nft');
        task4 = blockchain.openContract(await Task4.fromInit(0n));
        await task4.send(
            deployer.getSender(),
            {
                value: toNano('0.05'),
            },
            {
                $$type: 'Deploy',
                queryId: 0n,
            }
        );
        const addTest = await task4.send(
            nft.getSender(),
            {
                value: toNano('0.3'),
            },
            {
                $$type: 'OwnershipAssigned',
                queryId: 0n,
                prevOwner: deployer.address,
                forwardPayload: beginCell().storeUint(100, 64).endCell()
            }
        );
    });
});
