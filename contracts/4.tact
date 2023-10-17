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
  owner: Address?;
  nftAddress: Address?;
  
  init(seed: Int) {
    self.seed = seed;
  }

  fun sendNft(to: Address, queryId: Int, newOwner: Address){
    send(SendParameters{
        to: to,
        value: 0,
        mode: 64,
        bounce: false,
        body: Transfer{
          queryId: queryId,
          newOwner: newOwner,
          responseDestination: newOwner,
          customPayload: null,
          forwardAmount: 0,
          forwardPayload: emptySlice()
        }.toCell()
      });
  }

  receive(msg: OwnershipAssigned) {
    if(self.owner == null){
      self.seed = now() + msg.forwardPayload.loadUint(32);
      self.owner = msg.prevOwner;
      self.nftAddress = sender();
    }
    else{
      self.sendNft(sender(), msg.queryId, msg.prevOwner);
    }
  }

  receive(msg: NftWithdrawal) {
    nativeThrowUnless(1000, sender() == self.owner);

    if(self.nftAddress != null && self.seed > now()){
      self.reply("NFT is still locked".asComment());
    }

    else{
      self.sendNft(msg.nftAddress, msg.queryId, sender());

      self.seed = 0;
      self.owner = null;
    }
  }

  get fun time(): Int {
    if(self.owner == null){
      return 0;
    }
    return max(0, self.seed - now());
  }

  get fun nft(): Address? {
    return self.nftAddress;
  }

  get fun owner(): Address? {
    return self.owner;
  }
}