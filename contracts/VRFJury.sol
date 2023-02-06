//SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

error VRFJury__AddressAlreadyAdded(address addr);
error VRFJury__InvalidIndex(uint index);
error VRFJURY__AddressIsntPotentialJuror(address addr);

/**
 * @title VRF Jury
 * @author Rohan Nero
 * @notice this contract showcases a trustless alternative for the traditional jury selection process
 */
contract VRFJury is Ownable, VRFConsumerBaseV2 {
    /**
     * @dev this array would in theory be filled with addresses associated with different eligible jurors
     * in a specific jurisdiction.
     * Keeping track of who the addresses correspond with can be handled by a private database (SQL or mongoDB perhaps?)
     */
    address[] private potentialJurors;
    /**
     * @notice mapping to easily see if an address is included in the potentialJurors array
     * @dev if jurorIndices[address x] == 0 && potentialJurors[0] != address x, we can conclude they are not a potentialJuror.
     */
    mapping(address => uint) private jurorIndices;

    /**@dev Chainlink VRF variables */
    VRFCoordinatorV2Interface private immutable i_VrfCoordinatorV2; // address to the vrfCoordinatorV2 address
    bytes32 private immutable i_keyHash; // aka gasLane
    uint64 private _subId; // originally was immutable, but I added a function to update value: `updateSubId()`
    uint16 private constant BLOCK_CONFIRMATIONS = 5; // amount of blocks that need to be created before
    uint32 private immutable i_callbackGasLimit; // limit on amount of gas a VRF request will cost

    /**@notice keeps track of how many times fulfillRandomWords has been called */
    uint24 private _counter;

    event JurorsSelected(
        address[] indexed selectedJurors,
        uint indexed counter,
        uint indexed requestId
    );
    event RandomWordsRequested(uint requestId);
    event JurorAdded(address indexed addr, uint indexed index);
    event JurorRemoved(address indexed addr);
    event UpdatedSubId(uint64 indexed oldId, uint64 indexed newId);

    /**
     * @notice constructor sets all of our VRF variables
     * @param _vrfCoordinatorV2 address of chainlink's VRFCoordinatorV2
     * @param _keyHash chainlink gasLane to be used
     * @param subId your chainlink VRF subscription ID
     * @param _callbackGasLimit the max amount of gas you are willing to spend on VRF requests
     */
    constructor(
        address _vrfCoordinatorV2,
        bytes32 _keyHash,
        uint64 subId,
        uint32 _callbackGasLimit
    ) VRFConsumerBaseV2(_vrfCoordinatorV2) {
        i_VrfCoordinatorV2 = VRFCoordinatorV2Interface(_vrfCoordinatorV2);
        i_keyHash = _keyHash;
        _subId = subId;
        i_callbackGasLimit = _callbackGasLimit;
    }

    /**@dev This function allows the owner to add potential jurors to the potentialJurors array */
    function addCandidate(address addr) public onlyOwner {
        if (viewPotentialJurorsLength() == 0) {
            jurorIndices[addr] = potentialJurors.length;
            potentialJurors.push(addr);
        } else if (jurorIndices[addr] > 0 || potentialJurors[0] == addr) {
            revert VRFJury__AddressAlreadyAdded(addr);
        } else {
            jurorIndices[addr] = potentialJurors.length;
            potentialJurors.push(addr);
        }
    }

    /**@notice This function removes the address a the inputted index from the array.
     * @dev after check to ensure `index` is within range, we set the address at
     * the `index` equal to 0, and the last address in the potentialJurors array
     * is set to the inputted index. Finally, we set the last address to the index
     * and delete final array element with .pop()
     */
    function removeCandidate(uint index) public onlyOwner {
        if (potentialJurors.length <= index) {
            revert VRFJury__InvalidIndex(index);
        }
        jurorIndices[potentialJurors[index]] = 0;
        jurorIndices[potentialJurors[potentialJurors.length - 1]] = index;
        potentialJurors[index] = potentialJurors[potentialJurors.length - 1];
        potentialJurors.pop();
    }

    /**@notice this function uses VRF to select `amount` number of jurors.
     * @dev this calls vrfCoordinatorV2
     * @param amount - the amount of jurors (addresses) you would like to select */
    function selectJurors(uint32 amount) public onlyOwner {
        /**@dev custom error here to prevent accidentlly choosing wrong number of jurors? (more than 12/16)
         * I decided for now you have the freedom to make mistakes. Could build in a `safetyCap` that can be initialized inside constructor.
         * Then value check `amount` to ensure it's less than the `safetyCap`. */
        uint requestId = i_VrfCoordinatorV2.requestRandomWords(
            i_keyHash,
            _subId,
            BLOCK_CONFIRMATIONS,
            i_callbackGasLimit,
            amount
        );
        emit RandomWordsRequested(requestId);
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

    /**@notice this function allows the owner to change the value of _subId
     * @dev emits the old and new _subId */
    function updateSubId(uint64 newSubId) public onlyOwner {
        uint64 oldId = _subId;
        _subId = newSubId;
        emit UpdatedSubId(oldId, newSubId);
    }

    /**----------------------------------------------------------------------------
     * @notice below are view/pure functions
     * @dev used primarily for testing
     * ----------------------------------------------------------------------------
     **/

    /**@notice returns the value of `i_VrfCoordinatorV2` */
    function viewCoordinatorAddress() public view returns (address) {
        return address(i_VrfCoordinatorV2);
    }

    /**@notice returns the value of `i_keyHash` */
    function viewKeyHash() public view returns (bytes32) {
        return i_keyHash;
    }

    /**@notice returns the value of `_subId` */
    function viewSubId() public view returns (uint64) {
        return _subId;
    }

    /**@notice returns the value of `i_callbackGasLimit` */
    function viewCallbackGasLimit() public view returns (uint32) {
        return i_callbackGasLimit;
    }

    /**@notice returns value of `_counter` variable */
    function viewCounter() public view returns (uint24) {
        return _counter;
    }

    /**@notice returns the address at the `index` in potentialJurors array
     * @param index is the potentialJuror array index you wish to view */
    function viewJurorAddress(uint index) public view returns (address) {
        return potentialJurors[index];
    }

    /**@notice returns length of potentialJurors array */
    function viewPotentialJurorsLength() public view returns (uint) {
        return potentialJurors.length;
    }

    /**@notice this function returns true if addr is inside potentialJuror[]
     * @param addr is the address you want to check */
    function viewJurorStatus(address addr) public view returns (bool) {
        if (viewPotentialJurorsLength() == 0) {
            return false;
        } else if (jurorIndices[addr] > 0 || potentialJurors[0] == addr) {
            return true;
        } else {
            return false;
        }
    }

    /**@notice this function returns the potentialJuror index that the addr is at
     * @param addr is the address you want to check */
    function viewJurorIndex(address addr) public view returns (uint) {
        if (jurorIndices[addr] > 0 || potentialJurors[0] == addr) {
            return jurorIndices[addr];
        } else {
            revert VRFJURY__AddressIsntPotentialJuror(addr);
        }
    }
}
