import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:xchatbot/helpers/ads_helper.dart';
import 'package:xchatbot/helpers/app_color.dart';
import 'package:xchatbot/helpers/app_controller.dart';
import 'package:xchatbot/helpers/constants.dart';
import 'package:xchatbot/pages/about_page.dart';
import 'package:xchatbot/pages/chatbot_page.dart';
import 'package:xchatbot/pages/generate_image_page.dart';
import 'package:xchatbot/pages/intro_page.dart';
import 'package:xchatbot/pages/setting_page.dart';
import 'package:xchatbot/pages/voice_text_page.dart';
import 'package:xchatbot/widgets/popup_menu2/popup_menu_2.dart';

import '../pages/scan_ocr_page.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key}) {
    Future.delayed(const Duration(milliseconds: 1800), () {
      checkAvailitiesAPI();
    });
  }

  final AppController appController = AppController.to;

  checkAvailitiesAPI() async {
    final openAI = ChatGPT.instance.builder(Constants.apiKeyToken);

    try {
      final models = await openAI.listModel();
      if (models.data.isNotEmpty) {
        debugPrint("models data length ${models.data.length}");
        models.data.map((e) {
          debugPrint("models e ${e.toString()}");
        });
      }
    } catch (_) {
      //debugPrint("Error checkAvailitiesAPI listModel ${e.toString()}");
    }

    try {
      final engines = await openAI.listEngine();
      if (engines.data.isNotEmpty) {
        debugPrint("engines data length ${engines.data.length}");
        engines.data.map((e) {
          debugPrint("engines e ${e.toString()}");
        });
      }
    } catch (_) {
      //debugPrint("Error checkAvailitiesAPI listEngine ${e.toString()}");
    }
  }

  final GlobalKey keyPopup = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final bannerContainer = AdsHelper.bannerContainer;
    return WillPopScope(
      onWillPop: () => onBackPress(),
      child: Container(
        width: Get.width,
        height: Get.height,
        color: Colors.white,
        child: Scaffold(
          body: SafeArea(
              child: Stack(
            children: [
              Container(
                width: Get.width,
                height: Get.height,
                color: Colors.white,
                child: Column(
                  children: [
                    //row top
                    topHeader(),
                    iconShortcuts(),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),
                    Container(
                      width: Get.width / 1.11,
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        Constants.wording1,
                        style: Get.theme.textTheme.headlineSmall!.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      width: Get.width / 1.11,
                      padding: const EdgeInsets.all(5),
                      child: Text(
                          "${Constants.wording2} \r\n(${Constants.appVersion})",
                          style: TextStyle(color: AppColor.greyLabel)),
                    ),
                    Container(
                      height: GetPlatform.isAndroid
                          ? Get.height / 3
                          : Get.height / 2.5,
                      alignment: Alignment.center,
                      child: Image.asset(
                        'assets/chatbot-waving.gif',
                        width: Get.width / 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Obx(
                () => showBottomAds(appController.alreadyShowBanner.value,
                    bannerContainer.value.aContainer),
              ),
            ],
          )),
          floatingActionButton: ContextualMenu(
            targetWidgetKey: keyPopup,
            ctx: context,
            maxColumns: 1,
            backgroundColor: Get.theme.primaryColor,
            highlightColor: Colors.white,
            onDismiss: () {},
            items: [
              CustomPopupMenuItem(
                press: () {
                  Get.to(IntroPage());
                },
                title: 'History',
                textAlign: TextAlign.justify,
                textStyle: const TextStyle(color: Colors.white, fontSize: 11),
                image: const Icon(BootstrapIcons.clock_history,
                    color: Colors.white),
              ),
              CustomPopupMenuItem(
                press: () {
                  Get.to(SettingPage());
                },
                title: 'Setting',
                textAlign: TextAlign.justify,
                textStyle: const TextStyle(color: Colors.white, fontSize: 11),
                image: const Icon(BootstrapIcons.gear, color: Colors.white),
              ),
              CustomPopupMenuItem(
                press: () {
                  Get.to(AboutPage());
                },
                title: 'About',
                textAlign: TextAlign.justify,
                textStyle: const TextStyle(color: Colors.white, fontSize: 11),
                image: const Icon(BootstrapIcons.info, color: Colors.white),
              ),
            ],
            child: Container(
              key: keyPopup,
              padding: const EdgeInsets.only(top: 0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(55),
                    color: Get.theme.primaryColor),
                padding: const EdgeInsets.all(15),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(55),
                  child: const Icon(
                    BootstrapIcons.three_dots,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget showBottomAds(final bool alreadyShow, final Widget? adsWidget) {
    //debugPrint(
    //    "home_page showBottomAds showBottomAds alreadyShow $alreadyShow");

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
          width: Get.width,
          padding: EdgeInsets.zero,
          child: adsWidget ?? const SizedBox.shrink()),
    );
  }

  final _channel = MethodChannel(Constants.methodChannel);
  Future<bool> onBackPress() {
    debugPrint("onBackPress MyHomePage...");
    if (GetPlatform.isAndroid) {
      if (Navigator.of(Get.context!).canPop()) {
        return Future.value(true);
      } else {
        _channel.invokeMethod('sendToBackground');

        return Future.value(false);
      }
    } else {
      return Future.value(true);
    }
  }

  Widget iconShortcuts() {
    final List<dynamic> icons = Constants.iconTops;
    return Container(
      padding: const EdgeInsets.only(left: 15, top: 10, bottom: 10, right: 3),
      alignment: Alignment.center,
      width: Get.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: icons.map(
          (e) {
            final int indx = icons.indexOf(e);
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  debugPrint("clickedd...");
                  if (indx == 0) {
                    Get.to(ChatbotPage(appController: appController));
                  } else if (indx == 1) {
                    Get.to(GenerateImagePage());
                  } else if (indx == 2) {
                    Get.to(VoiceTextPage());
                  } else if (indx == 3) {
                    Get.to(ScanOcrPage());
                  } else {
                    //Get.snackbar('Information', 'Coming Soon..');
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 15),
                  padding: const EdgeInsets.all(17),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Get.theme.primaryColor.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset:
                            const Offset(2, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  width: Get.width / 5.26,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        child: e['icon'],
                      ),
                      const SizedBox(height: 5),
                      Text("${e['title']}",
                          style: Get.theme.textTheme.labelMedium),
                    ],
                  ),
                ),
              ),
            );
          },
        ).toList(),
      ),
    );
  }

  Widget topHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(Constants.helloGuest,
                  style: Get.theme.textTheme.labelMedium!
                      .copyWith(color: Colors.grey[500])),
              Text(Constants.appSubName, style: Get.theme.textTheme.titleLarge),
            ],
          ),

        ],
      ),
    );
  }
}
