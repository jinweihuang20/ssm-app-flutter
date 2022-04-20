
import 'package:flutter_test/flutter_test.dart';
import 'package:ssmflutter/SSMModule/emulator.dart' as emulator;

main(){

  test('sin-test',()async{
    var x = emulator.sineWave(100);
    print(x);
  });

  test('intToBytes-test', ()async{
     emulator.intToBytes(16384);
  });
  test('fake-data-packet-test', ()async{
    var packet = emulator.fakeData();
    expect(3072,packet.length);
  });
}