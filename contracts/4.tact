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
  seed: Int as uint128;
  time: Int as uint32;
  owner: Address?;
  nftAddress: Address?;
  
  init(seed: Int) {
    self.seed = seed;
    self.time = 0;
  }

  receive(msg: OwnershipAssigned) {
    if(self.nftAddress == null){
      self.time = now() + msg.forwardPayload.loadUint(32);
      self.owner = msg.prevOwner;
      self.nftAddress = sender();
    }

    else{
      send(SendParameters{
        to: sender(),
        value: 0,
        mode: 64,
        bounce: false,
        body: Transfer{
          queryId: msg.queryId,
          newOwner: msg.prevOwner,
          responseDestination: msg.prevOwner,
          customPayload: null,
          forwardAmount: 0,
          forwardPayload: emptySlice()
        }.toCell()
      });
    }
  }

  receive(msg: NftWithdrawal) {
    require(sender() == self.owner, "Sender is not the owner");

    if(self.time > now()){
      send(SendParameters{
        to: sender(),
        value: 0,
        mode: 64,
        bounce: false,
        body: "Nft is still locked".asComment()
      })
    }

    else{
      send(SendParameters{
        to: self.nftAddress!!,
        value: 0,
        mode: 64,
        bounce: false,
        body: Transfer{
          queryId: msg.queryId,
          newOwner: self.owner!!,
          responseDestination: self.owner!!,
          customPayload: null,
          forwardAmount: 0,
          forwardPayload: emptySlice()
        }.toCell()
      });

      self.time = 0;
      self.owner = null;
      self.nftAddress = null;
    }
  }

  get fun time(): Int {
    if(self.time <= now()){
      return 0;
    }
    return self.time - now();
  }

  get fun nft(): Address? {
    return self.nftAddress;
  }

  get fun owner(): Address? {
    return self.owner;
  }
}