import "@stdlib/deploy";

message(0x7362d09c) TokenNotification {
    queryId: Int as uint64;
    amount: Int as coins;
    from: Address;
    forwardPayload: Slice as remaining;
}

message(0xf8a7ea5) TokenTransfer {
    queryId: Int as uint64;
    amount: Int as coins;
    destination: Address;
    responseDestination: Address?;
    customPayload: Cell?;
    forwardTonAmount: Int as coins;
    forwardPayload: Slice as remaining;
} 

contract Task3 with Deployable {
  owner: Address;
  aAmount: Int as uint128;
  bAmount: Int as uint128;
  jettonAddressA: Address;
  jettonAddressB: Address;

  init(admin: Address, newJettonAddressA: Address, newJettonAddressB: Address) {
    self.owner = admin;
    self.jettonAddressA = newJettonAddressA;
    self.jettonAddressB = newJettonAddressB;
    self.aAmount = 0;
    self.bAmount = 0;
  }

  receive(msg: TokenNotification) {
    require(sender() == self.jettonAddressA || sender() == self.jettonAddressB, "1");

    if(msg.from == self.owner){
      if(sender() == self.jettonAddressA){
        self.aAmount = self.aAmount + msg.amount;
      }
      else{
        self.bAmount = self.bAmount + msg.amount;
      }
    }

    else{
      let to_wallet: Address = sender();
      let amount: Int = msg.amount;

      if(sender() == self.jettonAddressA){
        amount = self.bAmount * 1000000000 / self.aAmount * msg.amount / 1000000000;
        if(amount > self.bAmount){
          amount = msg.amount;
        }
        else{
          to_wallet = self.jettonAddressB;
          self.aAmount = self.aAmount + msg.amount;
          self.bAmount = self.bAmount - amount;
        }
      }

      else{
        amount = self.aAmount * 1000000000 / self.bAmount * msg.amount / 1000000000;
        if(amount > self.aAmount){
          amount = msg.amount;
        }
        else{
          to_wallet = self.jettonAddressA;
          self.bAmount = self.bAmount + msg.amount;
          self.aAmount = self.aAmount - amount;
        }
      }

      send(SendParameters{
        to: to_wallet,
        value: 0,
        mode: 64,
        bounce: false,
        body: TokenTransfer{
          queryId: 0,
          amount: amount,
          destination: msg.from,
          responseDestination: myAddress(),
          customPayload: null,
          forwardTonAmount: ton("0.01"),
          forwardPayload: emptySlice()
        }.toCell()
      });
    }
  }
  
  get fun price(jetton: Address): Int {
    if(jetton == self.jettonAddressA){
      return self.bAmount * 1000000000 / self.aAmount;
    }
    return self.aAmount * 1000000000 / self.bAmount;
  }
  
  get fun balance(jetton: Address): Int {
    if(jetton == self.jettonAddressA){
      return self.aAmount;
    }
    return self.bAmount;
  }
}
