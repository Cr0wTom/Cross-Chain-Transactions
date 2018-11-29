# Cross-chain Transactions

To install Lightning network deamon and all the necessary contents, execute the installation script in a terminal on your Linux or MacOS system.

To execute a cross chain transation between a Bitcoin and a Litecoin account, we execute the following:

    lncli --rpcserver=localhost:12019 queryswaproutes --dest=RECEIVERS_ADDRESS --in_amt=100 --in_ticker=BTC --out_ticker=LTC

Here the Bitcoin user asks for 100 units of LTC and LND creates two different channels, one in the Bitcoin Network and one in Litecoin. To achieve this we had to use a custom LND implementation that can be found [here.](https://github.com/cfromknecht/lnd/tree/swapz)
 