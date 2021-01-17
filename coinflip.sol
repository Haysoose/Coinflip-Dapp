import "./provableAPI.sol";
pragma solidity 0.5.16;

contract Coinflip is usingProvable{

      uint256 NUM_RANDOM_BYTES_REQUESTED = 1;
      uint256 latestNumber;

      struct Bet {
        uint id;
        uint amount;
        bytes32 queryId;
        bool won;
      }

      event logNewProvableQuery(string description);
      event generatedRandomNumber(uint256 randomNumber);
      event betCreated(uint id, uint amount);
      event betSettled(uint id, uint amount, bool won);

      constructor()
      public
      {
        update();
      }

      uint public balance;

      modifier costs(uint cost){
          require(msg.value >= cost);
          _;
      }

      mapping (address => Bet) private bets;
      address[] private creators;

      function __callback(bytes32 _queryId, string memory _result, bytes memory _proof) public {
        //require(msg.sender == provable_cbAddress());
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(_result))) % 2;
        latestNumber = randomNumber;
        emit generatedRandomNumber(randomNumber);
      }

      function update() public payable {
        uint256 query_execution_delay = 0;
        uint256 gas_for_callback = 200000;
        bets[msg.sender].queryId = testRandom();
        bets[msg.sender].queryId = provable_newRandomDSQuery(query_execution_delay, NUM_RANDOM_BYTES_REQUESTED, gas_for_callback);
        emit logNewProvableQuery("Provable query was sent, standing by for the answer.");
      }

      function testRandom() public returns(bytes32){
        bytes32 queryId = bytes32(keccak256(abi.encodePacked(msg.sender)));
        __callback(queryId, "1", bytes("test"));
        return queryId;
      }

      function createBet() public payable costs(1 ether){
        //require(balance >= 2 ether);
        require(msg.value >= 1 ether);
        balance += msg.value;

          //This creates a bet
          Bet memory newBet;
          newBet.amount = 1000000000000000000;

          insertBet(newBet);
          creators.push(msg.sender);

          newBet.id = creators.length;

          emit betCreated(newBet.id, newBet.amount);
      }

      function getBalance() public view returns (uint bal){
        return balance;
      }

      function deposit() public payable{
        balance += msg.value;
      }

      function insertBet(Bet memory newBet) private {
          address creator = msg.sender;
          bets[creator] = newBet;
      }

      function settleBet() public view returns(uint256 num){
        return latestNumber;
      }

      function payOut() public payable{
        require(balance >= 2 ether);
        msg.sender.transfer(2 ether);
      }

      function closeBet(uint256 num) public{
        if(num == 0){
          bets[msg.sender].won = true;
        }
        else{
          bets[msg.sender].won = false;
        }
        emit betSettled(bets[msg.sender].id, bets[msg.sender].amount, bets[msg.sender].won);
      }
}
