pragma solidity ^0.4.20;

contract ERC20 {

    function totalSupply() public view returns (uint supply);
    function balanceOf(address who) public view returns (uint value);
    function allowance(address owner, address spender) public view returns (uint _allowance);
    function transfer(address to, uint value) public returns (bool ok);
    function transferFrom(address from, address to, uint value) public returns (bool ok);
    function approve(address spender, uint value) public returns (bool ok);
    event Transfer(address indexed from, address indexed to, uint value);
}

contract Swap {

    address owner;

    mapping (bytes32 => TX) public txs;
    mapping (string => Currency) ccys;

    enum ccyType{Token, Native}

    struct TX {
        address tradingParty;
        address counterParty;
        string ccy;
        uint256 qty;
        uint expirationDate;
        uint initDate;
        bool exist;
        bool done;
    }

    struct Currency {
    string name;
    ccyType cType;
    address tokenAddress;
    bool exist;
    }

    event Initiated(address tradingParty, address counterParty, string ccy, uint256 qty,
    bytes32 hashedPassword, uint256 expirationDate);
    event Claimed(address counterParty, string ccy, uint256 qty, string secret);
    event Refunded(address tradingParty, string ccy, uint256 qty, bytes32 hashedPassword);
    event CurrencyAdded(string symbol, string name, address tokenAddress);

    function Swap(){
        owner = msg.sender;
    }

    modifier canClaim(string secret){
        bytes32 hashedPassword = sha256(secret);
        bool txCheck = txs[hashedPassword].exist && txs[hashedPassword].counterParty == msg.sender;
        bool timeCheck = now < txs[hashedPassword].expirationDate;
        require(!txs[hashedPassword].done && txCheck && timeCheck);
        _;
    }

    modifier canRefund(bytes32 hashedPassword) {
        bool txCheck = txs[hashedPassword].exist && txs[hashedPassword].tradingParty == msg.sender;
        bool timeCheck = now > txs[hashedPassword].expirationDate;
        require(!txs[hashedPassword].done && txCheck && timeCheck);
        _;
    }

    modifier isOwner {
        require(msg.sender == owner);
        _;
    }

    function addCurrency(string name, string symbol, bool isToken, address tAddress) isOwner public {
        require(!ccys[symbol].exist);
        ccys[symbol].name = name;
        ccys[symbol].cType = isToken ? ccyType.Token : ccyType.Native;
        if (isToken) {
            ccys[symbol].tokenAddress = tAddress;
        }
        ccys[symbol].exist = true;
        CurrencyAdded(symbol, name, tAddress);
    }

    function publish(string ccyName, uint256 qty, bytes32 hashedPassword, address cp, uint exp) payable public {
        Currency storage ccy = ccys[ccyName];
        uint256 quantity;
        if (!txs[hashedPassword].exist && ccy.exist) {
            if (ccy.cType == ccyType.Token) {
                ERC20 erc = ERC20(ccy.tokenAddress);
                require(erc.transferFrom(msg.sender, this, qty));
                quantity = qty;
            }
            else {
                quantity = msg.value;
            }
            createTx(ccyName, quantity, hashedPassword, cp, exp);
        }
    }

    function createTx(string ccyName, uint256 qty, bytes32 hashedPassword, address cp, uint exp) private {
        txs[hashedPassword].exist = true;
        txs[hashedPassword].ccy = ccyName;
        txs[hashedPassword].tradingParty = msg.sender;
        txs[hashedPassword].counterParty = cp;
        txs[hashedPassword].qty = qty;
        txs[hashedPassword].initDate = now;
        txs[hashedPassword].expirationDate = now + exp;
        txs[hashedPassword].done = false;
        Initiated(msg.sender, cp, ccyName, qty, hashedPassword, txs[hashedPassword].expirationDate);
    }


    function claim(string secret) canClaim(secret) public {
        bytes32 hashedPassword = sha256(secret);
        txs[hashedPassword].done = true;
        Currency storage ccy = ccys[txs[hashedPassword].ccy];
        if (ccy.cType == ccyType.Token) {
            ERC20 erc = ERC20(ccy.tokenAddress);
            require(erc.transfer(txs[hashedPassword].counterParty, txs[hashedPassword].qty));
        }
        else {
            txs[hashedPassword].counterParty.transfer(txs[hashedPassword].qty);
        }
        Claimed(txs[hashedPassword].counterParty, txs[hashedPassword].ccy, txs[hashedPassword].qty, secret);
    }


    function refund(bytes32 hashedPassword) canRefund(hashedPassword) public {
        txs[hashedPassword].done = true;
        Currency storage ccy = ccys[txs[hashedPassword].ccy];
        if (ccy.cType == ccyType.Token) {
            ERC20 erc = ERC20(ccy.tokenAddress);
            require(erc.transfer(txs[hashedPassword].tradingParty, txs[hashedPassword].qty));
        }
        else {
            txs[hashedPassword].tradingParty.transfer(txs[hashedPassword].qty);
        }
        Refunded(txs[hashedPassword].tradingParty, txs[hashedPassword].ccy, txs[hashedPassword].qty, hashedPassword);
    }
}