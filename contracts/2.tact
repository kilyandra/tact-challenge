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
    nativeThrowUnless(132, sender() == self.admin);
    nativeSendMessage(beginCell().storeInt(1, 2).storeUint(0, 1)
                      .storeInt(0, 3).storeAddress(msg.sender)
                      .storeCoins(0).storeInt(0, 105).storeUint(0, 1)
                      .storeUint(0, 1).endCell(), 64);
  }

  receive(msg: Slice) {
    nativeSendMessage(beginCell().storeInt(1, 2).storeUint(0, 1)
                      .storeInt(0, 3).storeAddress(self.admin)
                      .storeCoins(0).storeInt(0, 105).storeUint(0, 1)
                      .storeUint(1, 1).storeRef(beginCell().storeAddress(sender())
                      .storeRef(msg.asCell()).endCell()).endCell(), 64);
  }
}