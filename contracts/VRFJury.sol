//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

error VRFJury__AddressAlreadyAdded(address addr);

contract VRFJury is Ownable, VRFConsumerBaseV2 {
    address[] private potentialJurors;
    mapping(address => bool) private isPotentialJuror;

    /**@dev VRF variables */
    VRFCoordinatorV2Interface private immutable i_VrfCoordinatorV2;
    bytes32 private immutable i_keyHash;
    uint64 private immutable i_subId;
    uint16 private constant BLOCK_CONFIRMATIONS = 5;
    uint32 private immutable i_callbackGasLimit;

    uint24 private _counter;

    event JurorsSelected(
        address[] indexed selectedJurors,
        uint indexed counter,
        uint indexed requestId
    );

    constructor(
        address _vrfCoordinatorV2,
        bytes32 _keyHash,
        uint64 _subId,
        uint32 _callbackGasLimit
    ) VRFConsumerBaseV2(_vrfCoordinatorV2) {
        i_VrfCoordinatorV2 = VRFCoordinatorV2Interface(_vrfCoordinatorV2);
        i_keyHash = _keyHash;
        i_subId = _subId;
        i_callbackGasLimit = _callbackGasLimit;
    }

    /**@dev This function allows the owner to add potential jurors to the potentialJurors array */
    function addCandidate(address addr) public onlyOwner {
        if (isPotentialJuror[addr] == false) {
            potentialJurors.push(addr);
            isPotentialJuror[addr] = true;
        } else {
            revert VRFJury__AddressAlreadyAdded(addr);
        }
    }

    /**@dev This function removes the address a the inputted index from the array.
     *  - originally input was an `address` but its cheaper to loop through potentialJurors and find
     * index off-chain and then remove the address using the index */
    function removeCandidate(uint index) public onlyOwner {
        potentialJurors[index] = potentialJurors[potentialJurors.length - 1];
        potentialJurors.pop();
    }

    /**@dev this calls vrfCoordinatorV2
     * uint32 amount - the amount of jurors (addresses) you would like to select
     */
    function selectJurors(uint32 amount) public onlyOwner {
        /**@dev custom error here to prevent accidentlly choosing wrong number of jurors? (more than 12/16)
         * I decided for now you have the freedom to make mistakes. Could build in a `safetyCap` that can be initialized inside constructor.
         * Then value check `amount` to ensure it's less than the `safetyCap`. */
        i_VrfCoordinatorV2.requestRandomWords(
            i_keyHash,
            i_subId,
            BLOCK_CONFIRMATIONS,
            i_callbackGasLimit,
            amount
        );
    }

    /**@dev this uses the randomWords to select the addresses of the new jurors,
     * then emits the addresses along with a counter and the requestId from vrfCoordinatorV2. */
    function fulfillRandomWords(
        uint256 requestId,
        uint256[] memory randomWords
    ) internal override {
        address[] memory selectedJurors = new address[](randomWords.length);
        for (uint i; i < randomWords.length; i++) {
            uint index = randomWords[i] % potentialJurors.length;
            selectedJurors[i] = potentialJurors[index];
        }
        emit JurorsSelected(selectedJurors, _counter, requestId);
        _counter++;
    }
}
