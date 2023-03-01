import 'package:get/get.dart';
import 'package:xchatbot/helpers/ads_helper.dart';
import 'package:xchatbot/helpers/my_pref.dart';

class AppController extends GetxController {
  static AppController get to => Get.find<AppController>();
  static String tAG = "AppController";

  // instance AdsHelper
  final AdsHelper adsHelper = AdsHelper.instance;

  final MyPref _box = MyPref.to;
  MyPref get box => _box;

  final alreadyShowBanner = false.obs;
  setAlreadyShow(final bool show) {
    alreadyShowBanner.value = show;
    update();
  }
}
