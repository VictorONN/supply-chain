pragma solidity ^0.6.4;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Item.sol";

contract ItemManager is Ownable {
    enum SupplyChainState {Created, Paid, Delivered}

    struct S_item {
        Item _item;
        string _identifier;
        uint256 _itemPrice;
        ItemManager.SupplyChainState _step;
    }

    mapping(uint256 => S_item) public items;

    uint256 itemIndex;

    event SupplyChainSteps(
        uint256 _itemIndex,
        uint256 _step,
        address _itemAddress
    );

    function createItem(string memory _identifier, uint256 _itemPrice)
        public
        onlyOwner
    {
        Item item = new Item(this, _itemPrice, itemIndex);
        items[itemIndex]._item = item;
        items[itemIndex]._identifier = _identifier;
        items[itemIndex]._itemPrice = _itemPrice;
        items[itemIndex]._step = SupplyChainState.Created;
        emit SupplyChainSteps(
            itemIndex,
            uint256(items[itemIndex]._step),
            address(item)
        );
        itemIndex++;
    }

    function triggerPayment(uint256 _itemIndex) public payable {
        Item item = items[_itemIndex]._item;
        require(
            items[_itemIndex]._itemPrice == msg.value,
            "Only full payments accepted"
        );
        require(
            items[_itemIndex]._step == SupplyChainState.Created,
            "Item is further in the chain"
        );
        items[_itemIndex]._step = SupplyChainState.Paid;
        emit SupplyChainSteps(
            _itemIndex,
            uint256(items[_itemIndex]._step),
            address(items[_itemIndex]._item)
        );
    }

    function triggerDelivery(uint256 _itemIndex) public onlyOwner {
        require(
            items[_itemIndex]._step == SupplyChainState.Paid,
            "Item is further in the chain"
        );
        items[_itemIndex]._step = SupplyChainState.Delivered;
        emit SupplyChainSteps(
            _itemIndex,
            uint256(items[_itemIndex]._step),
            address(items[_itemIndex]._item)
        );
    }
}
