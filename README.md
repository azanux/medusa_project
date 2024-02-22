# Medusa tutorial

## Introduction

Medusa enters this domain as a specialized fuzzing tool designed to elevate the security of smart contracts, the bedrock upon which decentralized applications (DApps) and blockchain technologies are built. By rigorously testing smart contracts for vulnerabilities, Medusa aims to preemptively identify and mitigate potential security flaws that could lead to significant losses and breaches of trust.

This README serves as your guide to integrating Medusa into your smart contract development and security testing workflow. From installation and configuration to conducting your first fuzzing campaign, we'll walk you through every step necessary to harness the power of Medusa for securing your smart contracts.

[Medusa](https://github.com/crytic/medusa)

## Installation 

### Prerequisites

Before you begin the installation process, ensure you have the following prerequisites met:
- macOS operating system
- Terminal access
- Homebrew installed (if not, you can install Homebrew by running /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" in your terminal)

### Update Homebrew
Open your terminal and update Homebrew to ensure you have the latest version and the latest packages. Run the following command:

```shell
brew update
```
###  Install Node.js (Optional)
If Medusa requires Node.js, install it via Homebrew.

```shell
brew install node
```

### Install Medusa
Assuming Medusa can be installed directly via Homebrew or requires downloading from a repository, run the appropriate command.
```shell
brew install medusa
```
###  Verify Installation
To ensure Medusa has been installed correctly, you can run the following command,
These commands should return the version of Medusa you have installed
```shell
medusa --version
```

## Usage 

### Initialization of the project with medusa

Run this command
```shell
medusa init
```

### File configuration

configure medusa with the target and Contract name in medusa.json

```json
		"deploymentOrder": ["TestTokenPause"],
 	"compilation": {
		"platform": "crytic-compile",
		"platformConfig": {
			"target": "./test/TestToken.sol",
			"solcVersion": "0.7.6",       
```

### Contract to test
In this section, we will provide an example of using Medusa with the **Token.sol** contract.


Create your test Contract 
```javascript
//SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

contract Ownership {
    address owner = msg.sender;

    function Owner() public {
        owner = msg.sender;
    }

    modifier isOwner() {
        require(owner == msg.sender);
        _;
    }
}

contract Pausable is Ownership {
    bool is_paused;

    modifier ifNotPaused() {
        require(!is_paused);
        _;
    }

    function paused() public isOwner {
        is_paused = true;
    }

    function resume() public isOwner {
        is_paused = false;
    }
}

contract Token is Pausable {
    mapping(address => uint256) public balances;

    function transfer(address to, uint256 value) public ifNotPaused {
        balances[msg.sender] -= value;
        balances[to] += value;
    }
}
```

### Medusa Invariant test Contract

Let's now write the test class along with our invariant that will test when the contract is paused and the owner is set to 0x0000, how Medusa can invalidate this invariant
```javascript
//SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import {Token} from "../src/token.sol";

contract TestTokenPause is Token {

    address echidna_caller = msg.sender;

    constructor() {
        balances[echidna_caller] = 10000;
        paused();
        owner = address(0);
    }
    // add the property

    function fuzz_test_upause() public view returns (bool) {
        return is_paused == true;
    }
}
```

### Run the test
Once everything is ok , you can run the command
```shell
medusa fuzz
```
If medusa break teh invariant you should see the call senquence
```shell
⇾ Reading the configuration file at: /Users/azanux/Desktop/hacking/code/testing/medusa_project/medusa.json
⇾ Compiling targets with crytic-compile
⇾ fuzz: elapsed: 0s, calls: 0 (0/sec), seq/s: 0, coverage: 0
⇾ Creating 10 workers...
⇾ Fuzzer stopped, test results follow below ...
⇾ [FAILED] Property Test: TestTokenPause.fuzz_test_upause()
Test for method "TestTokenPause.fuzz_test_upause()" failed after the following call sequence:
[Call Sequence]
1) TestTokenPause.Owner() (block=13886, time=360625, gas=12500000, gasprice=1, value=0, sender=0x0000000000000000000000000000000000030000)
2) TestTokenPause.resume() (block=27772, time=564562, gas=12500000, gasprice=1, value=0, sender=0x0000000000000000000000000000000000030000)
[Execution Trace]
 => [call] TestTokenPause.resume() (addr=0xA647ff3c36cFab592509E13860ab8c4F28781a66, value=0, sender=0x0000000000000000000000000000000000030000)
         => [return ()]

[Property Test Execution Trace]
[Execution Trace]
 => [call] TestTokenPause.fuzz_test_upause() (addr=0xA647ff3c36cFab592509E13860ab8c4F28781a66, value=0, sender=0x0000000000000000000000000000000000010000)
         => [return (false)]

⇾ Test summary: 0 test(s) passed, 1 test(s) failed
````




**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

Foundry consists of:

-   **Forge**: Ethereum testing framework (like Truffle, Hardhat and DappTools).
-   **Cast**: Swiss army knife for interacting with EVM smart contracts, sending transactions and getting chain data.
-   **Anvil**: Local Ethereum node, akin to Ganache, Hardhat Network.
-   **Chisel**: Fast, utilitarian, and verbose solidity REPL.

## Documentation

https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
