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
  seed: Int as uint16;
  nfts: map<Int as uint16, Address>;
  
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
      nativeSendMessage(beginCell().storeUint(16, 6).storeAddress(sender())
                      .storeInt(1, 111).storeRef(
                          beginCell().storeUint(0x5fcc3d14, 32)
                        .storeUint(msg.queryId, 64).storeAddress(msg.prevOwner)
                        .storeAddress(msg.prevOwner).storeUint(0, 5)
                        .storeSlice(emptySlice()).endCell())
                      .endCell(), 66);
      return;
    }

    let num: Int = nativeRandomInterval(self.seed);

    if(num != 0){
      num = num - 1;
      nativeSendMessage(beginCell().storeUint(16, 6).storeAddress(self.nfts.get(num)!!)
                      .storeCoins(context().value - ton("2")).storeInt(1, 107).storeRef(
                          beginCell().storeUint(0x5fcc3d14, 32)
                        .storeUint(msg.queryId, 64).storeAddress(msg.prevOwner)
                        .storeAddress(msg.prevOwner).storeUint(0, 5)
                        .storeSlice(emptySlice()).endCell())
                      .endCell(), 0);
      self.nfts.set(num, sender());
      return;
    }

    nativeSendMessage(beginCell().storeUint(16, 6).storeAddress(sender())
                      .storeCoins(context().value - ton("2")).storeInt(1, 107).storeRef(
                          beginCell().storeUint(0x5fcc3d14, 32)
                        .storeUint(msg.queryId, 64).storeAddress(msg.prevOwner)
                        .storeAddress(msg.prevOwner).storeUint(0, 5)
                        .storeSlice(emptySlice()).endCell())
                      .endCell(), 0);
      self.nfts.set(num, sender());
  }

  receive(msg: AdminWithdrawalProfit) {
    nativeThrowUnless(132, sender() == self.owner);

    nativeSendMessage(beginCell().storeUint(16, 6).storeAddress(sender())
                      .storeCoins(myBalance() - ton("0.1")).storeInt(1, 107).storeRef(
                        beginCell().storeUint(0xfda48b79, 32).storeUint(msg.queryId, 64).endCell()
                      ).endCell(), 0);
  }

  receive(msg: AdminWithdrawalAllNFTs) {
    nativeThrowUnless(132, ((sender() == self.owner && context().value >= self.seed * ton("0.08") + ton("1")) || sender() == myAddress()));

    repeat(min(125, self.seed)){
      self.seed = self.seed - 1;
      nativeSendMessage(beginCell().storeUint(16, 6).storeAddress(self.nfts.get(self.seed)!!)
                      .storeUint(616870912, 36).storeInt(1, 107).storeRef(
                          beginCell().storeUint(0x5fcc3d14, 32)
                        .storeUint(msg.queryId, 64).storeAddress(self.owner)
                        .storeAddress(self.owner).storeUint(0, 5)
                        .storeSlice(emptySlice()).endCell())
                      .endCell(), 0);
    }

    if(self.seed <= 0){
      self.nfts = emptyMap();
      return;
    }

    nativeSendMessage(beginCell().storeUint(16, 6).storeAddress(myAddress())
                      .storeInt(1, 111).storeRef(
                        beginCell().storeUint(0x6339421f, 32).storeUint(msg.queryId, 64).endCell()
                      ).endCell(), 128);
  }

  get fun profit(): Int { 
    return max(0, myBalance() - ton("0.1"));
  }

  get fun nfts(): map<Int as uint16, Address> { 
    return self.nfts;
  }
}