import React, { Component } from "react";
import ItemManagerContract from "./contracts/ItemManager.json";
import ItemContract from "./contracts/Item.json";
import getWeb3 from "./getWeb3";
import "./App.css";

class App extends Component {
  state = { loaded: false, cost: 0, itemName: "Example 1" };

  componentDidMount = async () => {
    try {
      // Get network provider and web3 instance.
      this.web3 = await getWeb3();

      // Use web3 to get the user's accounts.
      this.accounts = await this.web3.eth.getAccounts();

      // Get the contract instance.
      const networkId = await this.web3.eth.net.getId();

      this.ItemManager = new this.web3.eth.Contract(
        ItemManagerContract.abi,
        ItemManagerContract.networks[networkId]
        && ItemManagerContract.networks[networkId].address,
      );

      this.Item = new this.web3.eth.Contract(
        ItemContract.abi,
        ItemContract.networks[networkId]
        && ItemContract.networks[networkId].address,
      );
      this.listenToPaymentEvent();

      this.setState({ loaded: true });
    } catch (error) {

      alert(
        `Failed to load web3, accounts, or contract. Check console for details.`,
      );
      console.error(error);
    }
  };


  listenToPaymentEvent = () => {
    let self = this;
    this.ItemManager.events.SupplyChainSteps().on("data",
      async function (evt) {
        console.log(evt);
        let itemObj = await self.ItemManager.methods
          .items(evt.returnValues._itemIndex).call();
        alert("Item " + itemObj._identifier + " was paid, deliver it!");
      });
  }

  handleInputChange = (event) => {
    const target = event.target;
    const value = target.type === "checkbox" ? target.checked : target.value;
    const name = target.name;
    this.setState({
      [name]: value
    })
  }



  handleSubmit = async () => {
    const { cost, itemName } = this.state;
    console.log(itemName, cost, this.ItemManager);
    let result = await this.ItemManager.methods.createItem(itemName, cost).send({ from: this.accounts[0] });
    console.log(result);
    alert("Send " + cost + " Wei to " + result.events.SupplyChainSteps.returnValues._itemAddress);
  }


  render() {
    if (!this.state.loaded) {
      return <div>Loading Web3, accounts, and contract...</div>;
    }
    return (
      <div className="App">
        <h1>Event Trigger/Supply Chain Example</h1>
        <h2>Items</h2>
        <h2>Add Items</h2>
        Cost in Wei: <input type="text" name="cost" value={this.state.cost} onChange={this.handleInputChange} />
        Item Identifier: <input type="text" name="itemName" value={this.state.itemName} onChange={this.handleInputChange} />
        <button type="button" onClick={this.handleSubmit}>Create new item</button>

      </div>
    );
  }
}

export default App;
