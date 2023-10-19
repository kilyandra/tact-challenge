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

    if(sender() == self.jettonAddressA){
      let amount : Int = self.bAmount * ton("1") / self.aAmount * msg.amount / ton("1");

      if(amount <= self.bAmount){
        nativeSendMessage(beginCell().storeUint(16, 6).storeAddress(self.jettonAddressB)
                      .storeUint(1, 111).storeRef(
                          beginCell().storeUint(0xf8a7ea50000000000000000, 96)
                        .storeCoins(amount).storeAddress(msg.from)
                        .storeAddress(myAddress()).storeUint(60331648, 29).endCell())
                      .endCell(), 64);
        self.aAmount = self.aAmount + msg.amount;
        self.bAmount = self.bAmount - amount;
        return;
      }

      nativeSendMessage(beginCell().storeUint(16, 6).storeAddress(sender())
                    .storeUint(1, 111).storeRef(
                        beginCell().storeUint(0xf8a7ea50000000000000000, 96)
                      .storeCoins(msg.amount).storeAddress(msg.from)
                      .storeAddress(myAddress()).storeUint(60331648, 29).endCell())
                    .endCell(), 64);
      return;
    }

    let amount : Int = self.aAmount * ton("1") / self.bAmount * msg.amount / ton("1");

    if(amount <= self.aAmount){
      nativeSendMessage(beginCell().storeUint(16, 6).storeAddress(self.jettonAddressA)
                      .storeUint(1, 111).storeRef(
                          beginCell().storeUint(0xf8a7ea50000000000000000, 96)
                        .storeCoins(amount).storeAddress(msg.from)
                        .storeAddress(myAddress()).storeUint(60331648, 29).endCell())
                      .endCell(), 64);
      self.bAmount = self.bAmount + msg.amount;
      self.aAmount = self.aAmount - amount;
      return;
    }

    nativeSendMessage(beginCell().storeUint(16, 6).storeAddress(sender())
                    .storeUint(1, 111).storeRef(
                        beginCell().storeUint(0xf8a7ea50000000000000000, 96)
                      .storeCoins(msg.amount).storeAddress(msg.from)
                      .storeAddress(myAddress()).storeUint(60331648, 29).endCell())
                    .endCell(), 64);
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