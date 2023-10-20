import "@stdlib/deploy";

message(0x44) Refund {
  queryId: Int as uint64;
  sender: Address;
}

contract Task2 with Deployable {
  admin: Int;

  init(admin: Address) {
    let a: Slice = admin.asSlice();
    a.loadInt(11);
    self.admin = a.loadInt(256);
  }

  receive(msg: Refund) {
    let a: Slice = sender().asSlice();
    a.loadInt(11);
    nativeThrowUnless(132, a.loadInt(256) == self.admin);
    a = msg.sender.asSlice();
    a.loadInt(11);
    nativeSendMessage(beginCell().storeInt(33792, 17)
                      .storeInt(a.loadInt(256), 256)
                      .storeInt(0, 111).endCell(), 64);
  }

  receive(msg: Slice) {
    let a: Slice = sender().asSlice();
    a.loadInt(11);
    nativeSendMessage(beginCell().storeInt(33792, 17).storeInt(self.admin, 256)
                      .storeInt(1, 111).storeRef(beginCell().storeUint(1024, 11).storeUint(a.loadUint(256), 256)
                      .storeRef(beginCell().storeSlice(msg).endCell()).endCell()).endCell(), 64);
  }
}