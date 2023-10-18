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

  receive(msg: NftWithdrawal) {
    nativeThrowUnless(132, sender() == self.owner);

    if(self.seed > now()){
      self.reply("NFT is still locked".asComment());
      return;
    }

    send(SendParameters{
      to: msg.nftAddress,
      value: 0,
      mode: 64,
      bounce: false,
      body: Transfer{
        queryId: msg.queryId,
        newOwner: sender(),
        responseDestination: self.owner!!,
        customPayload: null,
        forwardAmount: 0,
        forwardPayload: emptySlice()
      }.toCell()
    });

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