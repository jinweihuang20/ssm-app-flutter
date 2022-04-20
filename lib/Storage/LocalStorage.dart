// ignore_for_file: avoid_print, file_names
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:get_storage/get_storage.dart';

String addressHistoryKey = 'address_history';

Future<AddressHistory> getAddressHistory() async {
  Directory tempDir = await getTemporaryDirectory();

  print(tempDir);
  final box = GetStorage();
  var his = box.read(addressHistoryKey);
  if (his == null) return AddressHistory();
  print(his);
  return his;
}

void saveAddress(UserInputAddress address) async {
  print('saveaddress');

  if (await isAddressExistInStorage(address)) return;
  final box = GetStorage();
  AddressHistory his = await getAddressHistory();
  print(his.adressList);
  his.adressList.add(address);
  await box.write(addressHistoryKey, his);
  print('write');
}

void clearAddressHistory() {
  final box = GetStorage();
  box.remove(addressHistoryKey);
}

Future<bool> isAddressExistInStorage(UserInputAddress inputAddress) async {
  var existList = (await getAddressHistory()).adressList;
  for (var address in existList) {
    if (address.ip == inputAddress.ip && address.port == inputAddress.port) {
      return true;
    }
  }
  print('false');
  return false;
}

class AddressHistory {
  List<UserInputAddress> adressList = [];
}

class UserInputAddress {
  UserInputAddress(this.ip, this.port);
  final String ip;
  final int port;
}
