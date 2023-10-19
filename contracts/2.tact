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
    nativeThrowUnless(132, a.loadUint(256) == self.admin);
    a = msg.sender.asSlice();
    a.loadUint(11);
    nativeSendMessage(beginCell().storeUint(33792, 17)
                      .storeUint(a.loadUint(256), 256)
                      .storeInt(0, 111).endCell(), 64);
  }

  receive(msg: Slice) {
    nativeSendMessage(beginCell().storeUint(33792, 17).storeUint(self.admin, 256)
                      .storeInt(1, 111).storeRef(beginCell().storeAddress(sender())
                      .storeRef(beginCell().storeSlice(msg).endCell()).endCell()).endCell(), 64);
  }
}