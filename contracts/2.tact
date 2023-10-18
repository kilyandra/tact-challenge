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
    nativeThrowWhen(132, sender() != self.admin);
    nativeSendMessage(beginCell().storeInt(1, 2).storeBool(false)
                      .storeInt(0, 3).storeAddress(msg.sender)
                      .storeCoins(0).storeInt(0, 105).storeBool(false)
                      .storeBool(false).endCell(), 64);
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
