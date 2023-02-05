//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./VRFJury.sol";

/**
 * @title VRF Jury Factory
 * @author Rohan Nero
 * @notice The purpose of this contract is to deploy VRFJury contracts
 */
contract VRFJuryFactory {
    /**
     *
     * @param _vrfCoordinatorV2 is the VRFCoordinatorV2 contract address depending on which chain you wish to deploy to
     * @param _keyHash also known as the gas lane
     * @param _subId your VRF subscriptionId from vrf.chain.link
     * @param _callbackGasLimit the maximum amount of gas you wish to spend on a vrf request
     */
    function createVRFJury(
        address _vrfCoordinatorV2,
        bytes32 _keyHash,
        uint64 _subId,
        uint32 _callbackGasLimit
    ) public returns (address addr) {
        VRFJury newVRFJury = new VRFJury(
            _vrfCoordinatorV2,
            _keyHash,
            _subId,
            _callbackGasLimit
        );
        addr = address(newVRFJury);
    }
}
