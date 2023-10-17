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
    nativeThrowUnless(135, sender() == self.jettonAddressA || sender() == self.jettonAddressB);

    if(msg.from == self.owner){
      if(sender() == self.jettonAddressA){
        self.aAmount = self.aAmount + msg.amount;
        return;
      }

      self.bAmount = self.bAmount + msg.amount;
      return;
    }

    let amount: Int = 0;

    if(sender() == self.jettonAddressA){
      amount = self.bAmount * ton("1") / self.aAmount * msg.amount / ton("1");

      if(amount <= self.bAmount){
        send(SendParameters{
          to: self.jettonAddressB,
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
        self.aAmount = self.aAmount + msg.amount;
        self.bAmount = self.bAmount - amount;
        return;
      }

      self.reply(TokenTransfer{
          queryId: 0,
          amount: msg.amount,
          destination: msg.from,
          responseDestination: myAddress(),
          customPayload: null,
          forwardTonAmount: ton("0.01"),
          forwardPayload: emptySlice()
        }.toCell());
      return;
    }

    amount = self.aAmount * ton("1") / self.bAmount * msg.amount / ton("1");

    if(amount <= self.aAmount){
      send(SendParameters{
          to: self.jettonAddressA,
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
      self.bAmount = self.bAmount + msg.amount;
      self.aAmount = self.aAmount - amount;
      return;
    }

    self.reply(TokenTransfer{
        queryId: 0,
        amount: msg.amount,
        destination: msg.from,
        responseDestination: myAddress(),
        customPayload: null,
        forwardTonAmount: ton("0.01"),
        forwardPayload: emptySlice()
      }.toCell());
  }
  
  get fun price(jetton: Address): Int {
    if(jetton == self.jettonAddressA){
      return self.bAmount * ton("1") / self.aAmount;
    }
    return self.aAmount * ton("1") / self.bAmount;
  }
  
  get fun balance(jetton: Address): Int {
    if(jetton == self.jettonAddressA){
      return self.aAmount;
    }
    return self.bAmount;
  }
}