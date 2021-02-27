pragma solidity ^0.6.4;
import "./ItemManager.sol";

contract Item {
    uint256 public priceInWei;
    uint256 public index;

    uint256 public pricePaid;

    ItemManager parentContract;

    constructor(
        ItemManager _parentContract,
        uint256 _priceInWei,
        uint256 _index
    ) public {
        priceInWei = _priceInWei;
        index = _index;
        parentContract = _parentContract;
    }

    receive() external payable {
        require(pricePaid == 0, "Item is paid already");
        require(msg.value == priceInWei, "Only full payments");
        pricePaid += msg.value;
        (bool success, ) =
            address(parentContract).call{value: msg.value}(
                abi.encodeWithSignature("triggerPayment(uint256)", index)
            );
        require(success, "The transaction was not successful");
    }

    fallback() external payable {}
}
