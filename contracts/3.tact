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
  aAmount: Int as uint128;
  bAmount: Int as uint128;
  jettonAddressA: Int;
  jettonAddressB: Int;
  owner: Int;

  init(admin: Address, newJettonAddressA: Address, newJettonAddressB: Address) {
    let a : Slice = admin.asSlice();
    a.loadUint(11);
    self.owner = a.loadUint(256);
    a = newJettonAddressA.asSlice();
    a.loadUint(11);
    self.jettonAddressA = a.loadUint(256);
    a = newJettonAddressB.asSlice();
    a.loadUint(11);
    self.jettonAddressB = a.loadUint(256);
    self.aAmount = 0;
    self.bAmount = 0;
  }

  receive(msg: TokenNotification) {
    let a : Slice = sender().asSlice();
    a.loadUint(11);
    let b : Int = a.loadUint(256);
    nativeThrowUnless(135, b == self.jettonAddressA || b == self.jettonAddressB);

    let c : Slice = msg.from.asSlice();
    c.loadUint(11);
    let d : Int = c.loadUint(256);

    if(d == self.owner){
      if(b == self.jettonAddressA){
        self.aAmount = self.aAmount + msg.amount;
        return;
      }

      self.bAmount = self.bAmount + msg.amount;
      return;
    }

    let e : Slice = myAddress().asSlice();
    e.loadUint(11);
    let f : Int = e.loadUint(256);

    if(b == self.jettonAddressA){
      let amount : Int = self.bAmount * ton("1") / self.aAmount * msg.amount / ton("1");

      if(amount <= self.bAmount){
        nativeSendMessage(beginCell().storeUint(33792, 17).storeUint(self.jettonAddressB, 256)
                          .storeUint(1, 111).storeRef(beginCell().storeUint(0xf8a7ea50000000000000000, 96)
                          .storeCoins(amount).storeUint(1024, 11).storeUint(d, 256).storeUint(1024, 11)
                          .storeUint(f, 256).storeUint(60331648, 29).endCell()).endCell(), 64);
        self.aAmount = self.aAmount + msg.amount;
        self.bAmount = self.bAmount - amount;
        return;
      }

      nativeSendMessage(beginCell().storeUint(33792, 17).storeUint(b, 256)
                        .storeUint(1, 111).storeRef(beginCell().storeUint(0xf8a7ea50000000000000000, 96)
                        .storeCoins(msg.amount).storeUint(1024, 11).storeUint(d, 256).storeUint(1024, 11)
                        .storeUint(f, 256).storeUint(60331648, 29).endCell()).endCell(), 64);
      return;
    }

    let amount : Int = self.aAmount * ton("1") / self.bAmount * msg.amount / ton("1");

    if(amount <= self.aAmount){
      nativeSendMessage(beginCell().storeUint(33792, 17).storeUint(self.jettonAddressA, 256)
                        .storeUint(1, 111).storeRef(beginCell().storeUint(0xf8a7ea50000000000000000, 96)
                        .storeCoins(amount).storeUint(1024, 11).storeUint(d, 256).storeUint(1024, 11)
                        .storeUint(f, 256).storeUint(60331648, 29).endCell()).endCell(), 64);
      self.bAmount = self.bAmount + msg.amount;
      self.aAmount = self.aAmount - amount;
      return;
    }

    nativeSendMessage(beginCell().storeUint(33792, 17).storeUint(b, 256)
                        .storeUint(1, 111).storeRef(beginCell().storeUint(0xf8a7ea50000000000000000, 96)
                        .storeCoins(msg.amount).storeUint(1024, 11).storeUint(d, 256).storeUint(1024, 11)
                        .storeUint(f, 256).storeUint(60331648, 29).endCell()).endCell(), 64);
  }
  
  get fun price(jetton: Address): Int {
    let a : Slice = jetton.asSlice();
    a.loadUint(11);
    if(a.loadUint(256) == self.jettonAddressA){
      return self.bAmount * ton("1") / self.aAmount;
    }
    return self.aAmount * ton("1") / self.bAmount;
  }
  
  get fun balance(jetton: Address): Int {
    let a : Slice = jetton.asSlice();
    a.loadUint(11);
    if(a.loadUint(256) == self.jettonAddressA){
      return self.aAmount;
    }
    return self.bAmount;
  }
}