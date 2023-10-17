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
      if(context().value < ton("2.1")){
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
            value: context().value - ton("2"),
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
            value: context().value - ton("2"),
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
    require(sender() == self.owner, "Insufficient privelegies");

    send(SendParameters{
      to: self.owner,
      value: myBalance() - ton("0.1"),
      mode: 0,
      bounce: false,
      body: AdminFetchProfit{ queryId: msg.queryId }.toCell()
    });
  }

  receive(msg: AdminWithdrawalAllNFTs) {
    require(sender() == self.owner || sender() == myAddress(), "Invalid sender");
    require(context().value >= self.count * ton("0.08") + ton("1"), "Insufficent funds");

    repeat(10){
      if(self.count > 0){
        self.count = self.count - 1;
        send(SendParameters{
          to: self.nfts.get(self.count)!!,
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
        self.nfts.set(self.count, null);
      }
    }
    if(self.count > 0){
      send(SendParameters{
        to: myAddress(),
        value: ton("1") + ton("0.08") * self.count,
        mode: 0,
        bounce: false,
        body: AdminWithdrawalAllNFTs{ queryId: msg.queryId }.toCell()
      });
    }
  }

  get fun profit(): Int { 
    return max(0, myBalance() - ton("0.1"));
  }

  get fun nfts(): map<Int as uint16, Address> { 
    return self.nfts;
  }
}