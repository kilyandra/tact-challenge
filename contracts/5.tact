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
  seed: Int as uint128;
  count: Int as uint16;
  nfts: map<Int as uint16, Address>;
  
  init(seed: Int, owner: Address) {
    self.owner = owner;
    self.seed = seed;
    self.count = 0;
  }

  receive(msg: OwnershipAssigned) {
    if(msg.prevOwner == self.owner){
      self.nfts.set(self.count, sender());
      self.count = self.count + 1;
    }

    else{
      if(context().value < 2100000000){
        send(SendParameters{
          to: sender(),
          value: 0,
          mode: 66,
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

      else{
        let num: Int = random(0, self.count);

        if(num == 0){
          send(SendParameters{
            to: sender(),
            value: context().value - 2000000000,
            mode: 0,
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

        else{
          num = num - 1;
          send(SendParameters{
            to: self.nfts.get(num)!!,
            value: context().value - 2000000000,
            mode: 0,
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

          self.nfts.set(num, sender());
        }
      }
    }
  }

  receive(msg: AdminWithdrawalProfit) {
    nativeThrowUnless(1000, sender() == self.owner);

    send(SendParameters{
      to: self.owner,
      value: myBalance() - 100000000,
      mode: 0,
      bounce: false,
      body: AdminFetchProfit{ queryId: msg.queryId }.toCell()
    });
  }

  receive(msg: AdminWithdrawalAllNFTs) {
    nativeThrowUnless(1001, (sender() == self.owner || sender() == myAddress()) && context().value >= self.count * 80000000 + 1000000000);

    repeat(min(110, self.count)){
        self.count = self.count - 1;
        send(SendParameters{
          to: self.nfts.get(self.count)!!,
          value: 80000000,
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
    if(self.count > 0){
      send(SendParameters{
        to: myAddress(),
        value: 1000000000 + 80000000 * self.count,
        mode: 1,
        bounce: false,
        body: AdminWithdrawalAllNFTs{ queryId: msg.queryId }.toCell()
      });
    }
    else{
      self.nfts = emptyMap();
    }
  }

  get fun profit(): Int { 
    return max(0, myBalance() - 100000000);
  }

  get fun nfts(): map<Int as uint16, Address> { 
    return self.nfts;
  }
}