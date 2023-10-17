import "@stdlib/deploy";

message(0x44) Refund {
  queryId: Int as uint64;
  sender: Address;
}

contract Task2 with Deployable {
  admin: Address;

  init(admin: Address) {
    self.admin = admin;
  }

  fun sendNft(to: Address, body: Cell){
    send(SendParameters{
      to: to,
      bounce: false,
      value: 0,
      mode: 64,
      body: body
    });
  }
  
  receive(msg: Refund) {
    nativeThrowUnless(1000, sender() == self.admin);
    self.sendNft(msg.sender, emptyCell());
  }

  receive(msg: Slice) {
    self.sendNft(self.admin, beginCell().storeAddress(sender()).storeRef(msg.asCell()).endCell());
  }
}
