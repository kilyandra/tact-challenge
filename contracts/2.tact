import "@stdlib/deploy";

message(0x44) Refund {
  queryId: Int as uint64;
  sender: Address;
}

contract Task2 with Deployable {
  admin: Int;

  init(admin: Address) {
    let a: Slice = admin.asSlice();
    a.loadUint(11);
    self.admin = a.loadUint(256);
  }

  receive(msg: Refund) {
    let a: Slice = sender().asSlice();
    a.loadUint(11);
    let b: Int = a.loadUint(256);
    nativeThrowUnless(132, b == self.admin);
    nativeSendMessage(beginCell().storeUint(16, 6).storeAddress(msg.sender)
                      .storeInt(0, 111).endCell(), 64);
  }

  receive(msg: Slice) {
    nativeSendMessage(beginCell().storeUint(16, 6).storeUint(1024, 11).storeUint(self.admin, 256)
                      .storeInt(1, 111).storeRef(beginCell().storeUint(1024, 11)
                      .storeUint(self.admin, 256).storeRef(
                        beginCell().storeSlice(msg).endCell())
                      .endCell()).endCell(), 64);
  }
}