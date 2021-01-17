var web3 = new Web3(Web3.givenProvider);
var contractInstance;

$(document).ready(function() {
  window.ethereum.enable().then(function(accounts){
    contractInstance = new web3.eth.Contract(abi, "0xf429f112E65eF7e5981Ea0b8272B59545D76d091", {from: accounts[0]});
    console.log(contractInstance);
  });
  $("#place_a_bet").click(gamble);
  $("#settle_bet").click(settle);
});

function gamble(){

  var config = {
    value: web3.utils.toWei("1", "ether")
  }

  contractInstance.methods.createBet().send(config)
  .on("transactionHash", function(hash){
    console.log(hash);
  })
  .on("confirmation", function(confirmationNr){
    console.log(confirmationNr);
  })
  .on("reciept", function(reciept){
    console.log(reciept);
    alert("Done");
  });
}
function settle(){
  var num;

  var config = {
    value: web3.utils.toWei("2", "ether")
  }

  contractInstance.methods.update().send({value: 0, from: contractInstance.address}).then(contractInstance.methods.settleBet().call().then(function(res){
    num = res;
    console.log(num);
    if(num >= 0 && num < 1){
      contractInstance.methods.closeBet(num);
      alert("You lost");
    }
    else{
      contractInstance.methods.closeBet(num);
      contractInstance.methods.payOut().send({value: 0, from: contractInstance.address}).then(function(){
        alert("You won!");
      });
    }
  }));

}
