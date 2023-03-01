import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xchatbot/auths/login/login_screen.dart';
import 'package:xchatbot/helpers/app_color.dart';
import 'package:xchatbot/helpers/constants.dart';
import 'package:xchatbot/widgets/swipeable_button_view/swipeable_button_view.dart';
import 'package:xchatbot/helpers/app_controller.dart';
import 'package:xchatbot/helpers/my_pref.dart';

class IntroPage extends StatelessWidget {
  IntroPage({super.key});

  final imageList = [1, 2, 3].obs;
  final indexImage = 0.obs;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      height: Get.height,
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Scaffold(
          body: Container(
            width: Get.width,
            height: Get.height,
            color: Colors.blue,
            child: Stack(
              children: [
                Container(
                  width: Get.width,
                  height: Get.height / 1.9,
                  padding: EdgeInsets.zero,
                  child: Stack(
                    children: [
                      CarouselSlider(
                        options: CarouselOptions(
                            height: Get.height / 1.3,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 5),
                            enlargeCenterPage: true,
                            viewportFraction: 0.8,
                            onPageChanged: (index, _) {
                              indexImage.value = index;
                            }),
                        items: imageList.map((i) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                width: Get.width,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                decoration: const BoxDecoration(
                                    color: Colors.transparent),
                                child: Image.asset("assets/chatbot-00$i.png"),
                              );
                            },
                          );
                        }).toList(),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: imageList.map((entry) {
                              final idx = imageList.indexOf(entry);
                              return GestureDetector(
                                onTap: () {},
                                child: Container(
                                  width: 12.0,
                                  height: 12.0,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 20.0,
                                    horizontal: 4.0,
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Get.theme.colorScheme.background
                                        .withOpacity(
                                            indexImage.value == idx ? 1 : 0.35),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: Get.width,
                  margin: EdgeInsets.only(top: Get.height / 1.9),
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                  alignment: Alignment.bottomCenter,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    color: Colors.white,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(() => bodySlider(
                          Constants.slideWordings[indexImage.value])),
                      slideToStart(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget bodySlider(final dynamic item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          item['title'],
          textAlign: TextAlign.center,
          style: Get.theme.textTheme.headlineSmall!
              .copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 15),
        Text(
          item['desc'],
          textAlign: TextAlign.center,
          style: Get.theme.textTheme.titleMedium!.copyWith(
            color: AppColor.greyLabel2,
          ),
        ),
      ],
    );
  }

  final isFinished = false.obs;
  Widget slideToStart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Obx(
        () => SwipeableButtonView(
          buttonText: 'Slide to Start',
          buttontextstyle: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
          buttonWidget: const Icon(
            BootstrapIcons.chevron_right,
            color: Colors.grey,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(2, 3), // changes position of shadow
            ),
          ],
          activeColor: Get.theme.primaryColor,
          isFinished: isFinished.value,
          onWaitingProcess: () {
            Future.delayed(const Duration(seconds: 2), () {
              isFinished.value = true;
            });
          },
          onFinish: () async {
            debugPrint("finish...");

            //storage local box
            Get.lazyPut<MyPref>(() => MyPref());
            Get.lazyPut<AppController>(() => AppController());

            //Get.offAll(HomePage());
            Get.off(LoginScreen(screenHeight: Get.height));
          },
        ),
      ),
    );
  }
}
