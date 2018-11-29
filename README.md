# Cross-chain Transactions

This repo contains possible implementations for cross chain transactions platforms, that need support for multiple cryptocurrencies. Due to this fact several ways can be used to implement cross chain transactions. Some of the methods are described bellow, with PoC code in the folders of this repo.

## Token solution

A first solution for cross chain transaction, can exploit atomic swaps and smart contracts in order to perform transactions between different erc20 based currencies and even Ether and other similar cryptocurrencies.

##### Atomic Swaps

Atomic swaps are transactions between parties from different cryptocurrency networks, without the need of trust in a third party (much like what happens in most crypto exchanges). Let's consider an example where Bob wants to trade Token1 for Token2 and Alice the exact opposite. In this situation users have to create HTLCs(Hashed Timelock Contract) in order to ensure that both parties will hold up their ends of the agreement. 

- Alice and Bob create two payment channels to swap Token1 and Token2.
- Alice creates a transaction on Token1 with receiver being Bob which states with a HTLC that Bob can clain this transaction only if he completes his side of the deal. The amount of token1 is sent to a contract address with a time limit for Bob to complete his part. If bob fails to complete the transaction in this time limit the amount of Token1 will get back to Alice.
- Bob makes an exact same transaction as the one stated in the HTLC by Alice (the one that is needed by Bob in order to complete the aggreement) and sents it to the contracts address.
- Now, for the parties to unlock the receiving currencies, they need to use the key that has beed received in each transaction, and the atomic swap has been successful. 

Basically what happened, is that Alice created a transaction and deposited the money that Bob wants, and send the hash of the transaction that contains the currency that Alice needs from Bob. In order for Bob to receive the transaction that he needs, he has to reproduce the hash that Alice states, and contains the currency units that Alice needs. Bob creates this transaction and keeps the key to himself until Alice unlocks her transaction. After that the key to Bobs transaction gets unlocked too and Alice receives her currency units. 

In the Contracts folder, two files are included; a standard ERC20 Token and a Swap contract that manages the atomic swap between different ERC20 currencies. The swap contract supports new token submission and swap between tokens and ether. This happens because in order to achieve on-chain atomic swaps, user keys have to be of the same type, in order for the parties to transact.

## On-chain vs Off-chain Atomic Swap Solutions

##### On-Chain Swaps

On-chain swaps are swaps happening on either currency's blockchain. In order for this kind of swap to work, the hashing algorithm of the two blockcians have to be the same and HTLC has to be supported.

##### Off-Chain Swaps

In off-chain swaps a second layer is used, which manages the transactions. A good example of off-chain swaps is the Lighening network which recently started generating swaps between Bitcoin and Lightcoin in their testnets, because this network uses HTLCs by default.

## Three way swap

Three way swap is an alternative proposal to the Token atomic swap that I presented earlier. Here, a third party is proposed(Tom) in order to transact coins if one of the two previous parties does not have coins that the other party needs, and makes use of HTLCs and Timelocks. In the following example, Alice wants to give Ethereum for Bitcoin, but Bob who needs Ethereum, owns only Litecoin. And here comes Tom, who wants to transact Bitcoin for Litecoin(most of the times this applies in goods trading). The process goes as follows:

- Tom creates a secret(the way for Alice to unlock the currency units he needs) and publishes a contract to the Bitcoin with a hashlock (as earlier) and a timelock of 6 time units (TMs) in the future, as an expiration time for the transaction to happen or not (depending on the prerequisites of the transaction).
- When Bob has the ability to confirm that Tom has generated the contract, he publishes a contract to the Litecoin blockchain with the same hashlock but a timelock of 5 TMs in the future to transfer the litecoins to Tom.
- When Alice has the ability to confirm that Bob has generated the contract in the Litecoin blockchain, she publishes a contract on the Ethereum blockchain with the same hashlock but a timelock of 4 TMs in the future to transfer the Ethereum to Bob.
- Tom then sends his secret to Bob's contract, aquiring the Litecoins and revealing the secret to Bob.
- Bob sends his secret to Alice's contract, aquiring the Ether he wants and that way the swap is complete

TODO : Pros and cons of three way swap, and fix for three way swap logic
Lightning swap example can be found in the lighning folder.
