import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:xchatbot/helpers/constants.dart';

class MyPref {
  static MyPref get to => Get.find<MyPref>();

  static String tAG = "MyPref";
  static GetStorage _boxStorage() {
    return GetStorage(Constants.appStorage);
  }

  final GetStorage boxStorage = _boxStorage();

  static String keyFirst = 'p_first';
  static String keyModelChat = 'p_modelchat';
  static String keyMaxToken = 'p_maxtoken';

  //first time install
  final pFirst = ReadWriteValue(keyFirst, true, _boxStorage);

  //model, token
  final pModelChat =
      ReadWriteValue(keyModelChat, kTranslateModelV3, _boxStorage);
  final pMaxToken = ReadWriteValue(keyMaxToken, 1000, _boxStorage);
}
