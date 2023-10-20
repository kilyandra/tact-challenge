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
  nfts: map<Int as uint16, Address>;
  seed: Int as uint16;
  owner: Int;

  init(seed: Int, owner: Address) {
    let a : Slice = owner.asSlice();
    a.loadUint(11);
    self.owner = a.loadUint(256);
    self.seed = 0;
  }

  receive(msg: OwnershipAssigned) {
    let a : Slice = sender().asSlice();
    a.loadUint(11);
    let b : Int = a.loadUint(256);

    a = msg.prevOwner.asSlice();
    a.loadUint(11);
    let c : Int = a.loadUint(256);

    if(c == self.owner){
      self.nfts.set(self.seed, sender());
      self.seed = self.seed + 1;
      return;
    }
    
    if(context().value < ton("2.1")){
      nativeSendMessage(beginCell().storeUint(33792, 17).storeUint(b, 256)
                        .storeInt(1, 111).storeRef(beginCell().storeUint(0x5fcc3d14, 32)
                        .storeUint(msg.queryId, 64).storeUint(1024, 11).storeUint(c, 256)
                        .storeUint(1024, 11).storeUint(c, 256).storeUint(0, 5).endCell())
                        .endCell(), 66);
      return;
    }

    let num: Int = nativeRandomInterval(self.seed);

    if(num != 0){
      num = num - 1;
      a = (self.nfts.get(num)!!).asSlice();
      a.loadUint(11);
      nativeSendMessage(beginCell().storeUint(33792, 17).storeUint(a.loadUint(256), 256)
                        .storeCoins(context().value - ton("2")).storeInt(1, 107)
                        .storeRef(beginCell().storeUint(0x5fcc3d14, 32).storeUint(msg.queryId, 64)
                        .storeUint(1024, 11).storeUint(c, 256).storeUint(1024, 11)
                        .storeUint(c, 256).storeUint(0, 5).endCell()).endCell(), 0);
      self.nfts.set(num, sender());
      return;
    }

    nativeSendMessage(beginCell().storeUint(33792, 17).storeUint(b, 256)
                      .storeCoins(context().value - ton("2")).storeInt(1, 107)
                      .storeRef(beginCell().storeUint(0x5fcc3d14, 32).storeUint(msg.queryId, 64)
                      .storeUint(1024, 11).storeUint(c, 256).storeUint(1024, 11)
                      .storeUint(c, 256).storeUint(0, 5).endCell()).endCell(), 0);
  }

  receive(msg: AdminWithdrawalProfit) {
    let a : Slice = sender().asSlice();
    a.loadUint(11);
    let b : Int = a.loadUint(256);

    nativeThrowUnless(132, b == self.owner);

    nativeSendMessage(beginCell().storeUint(33792, 17).storeUint(b, 256)
                      .storeCoins(myBalance() - ton("0.1")).storeUint(1, 107)
                      .storeRef(beginCell().storeUint(0xfda48b79, 32).storeUint(msg.queryId, 64)
                      .endCell()).endCell(), 0);
  }

  receive(msg: AdminWithdrawalAllNFTs) {
    let a : Slice = sender().asSlice();
    a.loadUint(11);
    let b : Int = a.loadUint(256);

    let c : Slice = myAddress().asSlice();
    c.loadUint(11);
    let d : Int = c.loadUint(256);

    nativeThrowUnless(132, (b == d || (b == self.owner && context().value >= self.seed * ton("0.08") + ton("1"))));
    a = beginCell().storeUint(0x202625A00000000000000000000000000001, 143)
                   .storeRef(beginCell().storeUint(0x5fcc3d14, 32).storeUint(msg.queryId, 64)
                   .storeUint(1024, 11).storeUint(self.owner, 256).storeUint(1024, 11)
                   .storeUint(self.owner, 256).storeUint(0, 5)
                   .endCell()).endCell().asSlice();

    repeat(min(253, self.seed)){
      self.seed = self.seed - 1;
      c = (self.nfts.get(self.seed)!!).asSlice();
      c.loadUint(11);
      nativeSendMessage(beginCell().storeUint(33792, 17)
                        .storeUint(c.loadUint(256), 256)
                        .storeSlice(a).endCell(), 0);
    }

    if(self.seed == 0){
      self.nfts = emptyMap();
      return;
    }

    nativeSendMessage(beginCell().storeUint(33792, 17).storeUint(d, 256)
                      .storeUint(1, 111).storeRef(beginCell().storeUint(0x6339421f, 32)
                      .storeUint(msg.queryId, 64).endCell()).endCell(), 128);
  }

  get fun profit(): Int { 
    return max(0, myBalance() - ton("0.1"));
  }

  get fun nfts(): map<Int as uint16, Address> { 
    return self.nfts;
  }
}