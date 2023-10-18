import "@stdlib/deploy";

message AdminWithdrawalProfit {
  queryId: Int as uint64;
}

message AdminWithdrawalAllNFTs {
  queryId: Int as uint64;
}

message AdminFetchProfit {
  queryId: Int as uint64;
}

message(0x05138d91) OwnershipAssigned {
    queryId: Int as uint64;
    prevOwner: Address;
    forwardPayload: Slice as remaining; 
}

message(0x5fcc3d14) Transfer { 
    queryId: Int as uint64;            
    newOwner: Address; 
    responseDestination: Address; 
    customPayload: Cell?; 
    forwardAmount: Int as coins; 
    forwardPayload: Slice as remaining; 
}

contract Task5 with Deployable {
  owner: Address;
  nfts: map<Int as uint16, Address>;
  seed: Int as uint16;
  
  init(seed: Int, owner: Address) {
    self.owner = owner;
    self.seed = 0;
  }

  receive(msg: OwnershipAssigned) {
    if(msg.prevOwner == self.owner){
      self.nfts.set(self.seed, sender());
      self.seed = self.seed + 1;
      return;
    }

    if(context().value < ton("2.1")){
      nativeSendMessage(beginCell().storeInt(1, 2).storeBool(false)
                      .storeInt(0, 3).storeAddress(sender())
                      .storeCoins(0).storeInt(0, 105).storeBool(false)
                      .storeBool(true).storeRef(
                          beginCell().storeUint(0x5fcc3d14, 32)
                        .storeUint(msg.queryId, 64).storeAddress(msg.prevOwner)
                        .storeAddress(msg.prevOwner).storeBool(false).storeCoins(0)
                        .storeSlice(emptySlice()).endCell())
                      .endCell(), 66);
      return;
    }

    let num: Int = nativeRandomInterval(self.seed);

    if(num != 0){
      num = num - 1;
      nativeSendMessage(beginCell().storeInt(1, 2).storeBool(false)
                      .storeInt(0, 3).storeAddress(self.nfts.get(num)!!)
                      .storeCoins(context().value - ton("2")).storeInt(0, 105).storeBool(false)
                      .storeBool(true).storeRef(
                          beginCell().storeUint(0x5fcc3d14, 32)
                        .storeUint(msg.queryId, 64).storeAddress(msg.prevOwner)
                        .storeAddress(msg.prevOwner).storeBool(false).storeCoins(0)
                        .storeSlice(emptySlice()).endCell())
                      .endCell(), 0);
      self.nfts.set(num, sender());
      return;
    }

    nativeSendMessage(beginCell().storeInt(1, 2).storeBool(false)
                      .storeInt(0, 3).storeAddress(sender())
                      .storeCoins(context().value - ton("2")).storeInt(0, 105).storeBool(false)
                      .storeBool(true).storeRef(
                          beginCell().storeUint(0x5fcc3d14, 32)
                        .storeUint(msg.queryId, 64).storeAddress(msg.prevOwner)
                        .storeAddress(msg.prevOwner).storeBool(false).storeCoins(0)
                        .storeSlice(emptySlice()).endCell())
                      .endCell(), 0);
  }

  receive(msg: AdminWithdrawalProfit) {
    nativeThrowUnless(1000, sender() == self.owner);

    nativeSendMessage(beginCell().storeInt(1, 2).storeBool(false)
                      .storeInt(0, 3).storeAddress(sender())
                      .storeCoins(myBalance() - ton("0.1")).storeInt(0, 105).storeBool(false)
                      .storeBool(true).storeRef(beginCell().storeUint(msg.queryId, 64).endCell()).endCell(), 0);
  }

  receive(msg: AdminWithdrawalAllNFTs) {
    nativeThrowUnless(1001, (sender() == self.owner || sender() == myAddress()) && context().value >= self.seed * ton("0.08") + ton("1"));

    repeat(min(110, self.seed)){
      self.seed = self.seed - 1;
      send(SendParameters{
        to: self.nfts.get(self.seed)!!,
        value: ton("0.08"),
        mode: 0,
        bounce: false,
        body: Transfer{
          queryId: msg.queryId,
          newOwner: self.owner,
          responseDestination: self.owner,
          customPayload: null,
          forwardAmount: 0,
          forwardPayload: emptySlice()
        }.toCell()
      });
    }
    if(self.seed <= 0){
      self.nfts = emptyMap();
      return;
    }
    send(SendParameters{
      to: myAddress(),
      value: ton("1") + ton("0.08") * self.seed,
      mode: 1,
      bounce: false,
      body: AdminWithdrawalAllNFTs{ queryId: msg.queryId }.toCell()
    });
  }

  get fun profit(): Int { 
    return max(0, myBalance() - ton("0.1"));
  }

  get fun nfts(): map<Int as uint16, Address> { 
    return self.nfts;
  }
}