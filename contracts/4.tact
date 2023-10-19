import "@stdlib/deploy";

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

message NftWithdrawal {
  queryId: Int as uint64;
  nftAddress: Address;
}

contract Task4 with Deployable {
  seed: Int as int32;
  owner: Address?;
  nftAddress: Address?;
  
  init(seed: Int) {
    self.seed = 0;
  }

  receive(msg: OwnershipAssigned) {
    if(self.owner == null){
      self.seed = now() + msg.forwardPayload.loadUint(32);
      self.owner = msg.prevOwner;
      self.nftAddress = sender();
      return;
    }
    
    let a : Slice = sender().asSlice();
    a.loadUint(11);
    let b : Int = a.loadUint(256);

    a = msg.prevOwner.asSlice();
    a.loadUint(11);
    let c : Int = a.loadUint(256);

    nativeSendMessage(beginCell().storeUint(33792, 17).storeUint(b, 256)
                      .storeUint(1, 111).storeRef(beginCell().storeUint(0x5fcc3d14, 32)
                      .storeUint(msg.queryId, 64).storeUint(1024, 11).storeUint(c, 256)
                      .storeUint(1024, 11).storeUint(c, 256).storeUint(0, 5).endCell())
                      .endCell(), 64);
  }

  receive(msg: NftWithdrawal) {
    nativeThrowUnless(132, sender() == self.owner);

    let a : Slice = sender().asSlice();
    a.loadUint(11);
    let b : Int = a.loadUint(256);

    if(self.seed > now()){
      nativeSendMessage(beginCell().storeUint(33792, 17).storeUint(b, 256)
                      .storeUint(1, 111).storeRef("NFT is still locked".asComment()).endCell(), 64);
      return;
    }

    a = msg.nftAddress.asSlice();
    a.loadUint(11);
    let c : Int = a.loadUint(256);

    nativeSendMessage(beginCell().storeUint(33792, 17).storeUint(c, 256)
                      .storeUint(1, 111).storeRef(beginCell().storeUint(0x5fcc3d14, 32)
                      .storeUint(msg.queryId, 64).storeUint(1024, 11).storeUint(b, 256)
                      .storeUint(1024, 11).storeUint(b, 256).storeUint(0, 5).endCell())
                      .endCell(), 64);
    
    self.owner = null;
    self.nftAddress = null;
  }

  get fun time(): Int {
    return max(0, self.seed - now());
  }

  get fun nft(): Address? {
    return self.nftAddress;
  }

  get fun owner(): Address? {
    return self.owner;
  }
}