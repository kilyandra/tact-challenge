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

  fun sendNft(to: Address, amount: Int, destination: Address){
    send(SendParameters{
      to: to,
      value: 0,
      mode: 64,
      bounce: false,
      body: TokenTransfer{
        queryId: 0,
        amount: amount,
        destination: destination,
        responseDestination: myAddress(),
        customPayload: null,
        forwardTonAmount: ton("0.01"),
        forwardPayload: emptySlice()
      }.toCell()
    });
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

    let amount: Int = self.bAmount * ton("1") / self.aAmount * msg.amount / ton("1");

    if(sender() == self.jettonAddressA){
      if(amount <= self.bAmount){
        self.sendNft(self.jettonAddressB, amount, msg.from);
        self.aAmount = self.aAmount + msg.amount;
        self.bAmount = self.bAmount - amount;
        return;
      }

      self.sendNft(sender(), msg.amount, msg.from);
      return;
    }

    amount = ton("1000000000") / amount;

    if(amount <= self.aAmount){
      self.sendNft(self.jettonAddressA, amount, msg.from);
      self.bAmount = self.bAmount + msg.amount;
      self.aAmount = self.aAmount - amount;
      return;
    }

    self.sendNft(sender(), msg.amount, msg.from);
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