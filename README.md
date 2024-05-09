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
### Run the fuzzing
```shell
medusa fuzz --target-contracts "TestContract, TestOtherContract"--test-limit 10_000
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

# TestToken
This test is to break the invariants, and see how Medusa manage to break the Invariant
- assure that the balance of the caller can be llower than we he strat the transfer
- assure that the contract would never be in pause

## Foundry Fuzzer
We will use foudry invariant futter to break the 2 invariants in test Contract foundry/TestToken.sol

In the first invariant we ensure that the contract Token would never pause, we can see that the invariant break with 
 - Owner() with this sender  : sender=0x0000000000000000000000000000000000000234
 - paused() with this sender  : sender=0x0000000000000000000000000000000000000234

```shell
forge test --mt invariant_is_pause

Ran 1 test for test/foundry/TestToken.t.sol:TestToken
[FAIL. Reason: panic: assertion failed (0x01)]
        [Sequence]
                sender=0x0000000000000000000000000000000000000234 addr=[src/Token.sol:Token]0x697445470b4c7b6024d79A43ce40A9B683BF28a7 calldata=Owner() args=[]
                sender=0x0000000000000000000000000000000000000234 addr=[src/Token.sol:Token]0x697445470b4c7b6024d79A43ce40A9B683BF28a7 calldata=paused() args=[]
 invariant_is_pause() (runs: 256, calls: 3835, reverts: 2543)
Suite result: FAILED. 0 passed; 1 failed; 0 skipped; finished in 181.64ms (179.99ms CPU time)

Ran 1 test suite in 322.81ms (181.64ms CPU time): 0 tests passed, 1 failed, 0 skipped (1 total tests)
```

In the second in variant we will ensure that the balance of the user never decrease, we could see that the invariant is broken with
1- airDrop()
```shell
forge test --mt invariant_balance

Failing tests:
Encountered 1 failing test in test/foundry/TestToken.t.sol:TestToken
[FAIL. Reason: EvmError: InvalidFEOpcode]
        [Sequence]
                sender=0x0000000000000000000000000000000000ABC124 addr=[src/Token.sol:Token]0x697445470b4c7b6024d79A43ce40A9B683BF28a7 calldata=airDrop() args=[]
 invariant_balance() (runs: 256, calls: 3827, reverts: 2606)

Encountered a total of 1 failing tests, 0 tests succeeded

```

## Medusa Fuzzer
In this section we will break the invariant using Medusa in test contract medusa/TestToken.t.sol

in the first test , we will ensure that the contract could never be paused , we could see that the invariant is broken with 
1- Onwer()
2- paused()
```shell
medusa fuzz


⇾ [PASSED] Assertion Test: TestToken.test_balance() module=fuzzer
⇾ [FAILED] Assertion Test: TestToken.test_upause(uint256)
Test for method "TestToken.test_upause(uint256)" resulted in an assertion failure after the following call sequence:
[Call Sequence]
1) Token.Owner() (block=59404, time=299471, gas=12500000, gasprice=1, value=0, sender=0x0000000000000000000000000000000000030000)
2) Token.paused() (block=94009, time=450327, gas=12500000, gasprice=1, value=0, sender=0x0000000000000000000000000000000000030000)
3) TestToken.test_upause(76787165032705673776020647130283502101399084199848915639357699339010813055333) (block=147459, time=726791, gas=12500000, gasprice=1, value=0, sender=0x0000000000000000000000000000000000020000)
[Execution Trace]
 => [call] TestToken.echidna_upause(76787165032705673776020647130283502101399084199848915639357699339010813055333) (addr=0xA647ff3c36cFab592509E13860ab8c4F28781a66, value=0, sender=0x0000000000000000000000000000000000020000)
         => [call] Token.is_paused() (addr=0x54919A19522Ce7c842E25735a9cFEcef1c0a06dA, value=<nil>, sender=0xA647ff3c36cFab592509E13860ab8c4F28781a66)
                 => [return (true)]
         => [panic: assertion failed]

 module=fuzzer
⇾ Test summary: 1 test(s) passed, 1 test(s) failed module=fuzzer
⇾ Coverage report saved to file: medusa/corpus/coverage_report.html module=fuzzer
```

In the second invariant test, we will ensure that the contract the balance of the atcaker can't increase
we can see that the invariant is broken with 
1 -Owner() 
```shell
medusa fuzz

⇾ fuzz: elapsed: 0s, calls: 0 (0/sec), seq/s: 0, coverage: 6, mem: 84/110 MB, resets/s: 0 module=fuzzer
⇾ Creating 10 workers... module=fuzzer
⇾ Fuzzer stopped, test results follow below ... module=fuzzer
⇾ [FAILED] Assertion Test: TestToken.test_balance()
Test for method "TestToken.test_balance()" resulted in an assertion failure after the following call sequence:
[Call Sequence]
1) Token.Owner() (block=18514, time=424321, gas=12500000, gasprice=1, value=0, sender=0x0000000000000000000000000000000000020000)
2) Token.setBalance(0x0000000000000000000000000000000000000124, 114440900143069207452236327284280234278703230472273420653648038843176422751370) (block=42070, time=505964, gas=12500000, gasprice=1, value=0, sender=0x0000000000000000000000000000000000020000)
3) TestToken.test_balance() (block=49296, time=988088, gas=12500000, gasprice=1, value=0, sender=0x0000000000000000000000000000000000010000)
[Execution Trace]
 => [call] TestToken.echidna_balance() (addr=0xA647ff3c36cFab592509E13860ab8c4F28781a66, value=0, sender=0x0000000000000000000000000000000000010000)
         => [call] Token.balances(0x0000000000000000000000000000000000000124) (addr=0x54919A19522Ce7c842E25735a9cFEcef1c0a06dA, value=<nil>, sender=0xA647ff3c36cFab592509E13860ab8c4F28781a66)
                 => [return (114440900143069207452236327284280234278703230472273420653648038843176422751370)]
         => [panic: assertion failed]

 module=fuzzer
⇾ Test summary: 0 test(s) passed, 1 test(s) failed module=fuzzer
⇾ Coverage report saved to file: medusa/corpus/coverage_report.html module=fuzzer
```




