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
  
  receive(msg: Refund) {
    nativeThrowUnless(1, sender() == self.admin);
    send(SendParameters{
        to: msg.sender,
        bounce: false,
        value: 0,
        mode: 64
    });
  }

  receive(msg: Slice) {
    send(SendParameters{
        to: self.admin,
        bounce: false,
        value: 0,
        mode: 64,
        body: beginCell().storeAddress(sender()).storeRef(msg.asCell()).endCell()
    });
  }
}
