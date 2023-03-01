import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:xchatbot/auths/login/widgets/fade_slide_transition.dart';
import 'package:xchatbot/pages/packages/package_page.dart';

import 'widgets/custom_clippers/index.dart';
import 'widgets/header.dart';
import 'package:xchatbot/helpers/constants.dart';
import 'package:xchatbot/widgets/typewriter/type_text.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  final double screenHeight;

  const LoginScreen({
    super.key,
    required this.screenHeight,
  });

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _headerTextAnimation;
  late final Animation<double> _formElementAnimation;
  late final Animation<double> _whiteTopClipperAnimation;
  late final Animation<double> _blueTopClipperAnimation;
  late final Animation<double> _greyTopClipperAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: kLoginAnimationDuration,
    );

    final fadeSlideTween = Tween<double>(begin: 0.0, end: 1.0);
    _headerTextAnimation = fadeSlideTween.animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.0,
        0.6,
        curve: Curves.easeInOut,
      ),
    ));
    _formElementAnimation = fadeSlideTween.animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.7,
        1.0,
        curve: Curves.easeInOut,
      ),
    ));

    final clipperOffsetTween = Tween<double>(
      begin: widget.screenHeight,
      end: 0.0,
    );
    _blueTopClipperAnimation = clipperOffsetTween.animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.2,
          0.7,
          curve: Curves.easeInOut,
        ),
      ),
    );
    _greyTopClipperAnimation = clipperOffsetTween.animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.35,
          0.7,
          curve: Curves.easeInOut,
        ),
      ),
    );
    _whiteTopClipperAnimation = clipperOffsetTween.animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(
          0.5,
          0.7,
          curve: Curves.easeInOut,
        ),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: kWhite,
      body: Stack(
        children: <Widget>[
          AnimatedBuilder(
            animation: _whiteTopClipperAnimation,
            builder: (_, Widget? child) {
              return ClipPath(
                clipper: WhiteTopClipper(
                  yOffset: _whiteTopClipperAnimation.value,
                ),
                child: child,
              );
            },
            child: Container(color: kGrey),
          ),
          AnimatedBuilder(
            animation: _greyTopClipperAnimation,
            builder: (_, Widget? child) {
              return ClipPath(
                clipper: GreyTopClipper(
                  yOffset: _greyTopClipperAnimation.value,
                ),
                child: child,
              );
            },
            child: Container(color: kBlue),
          ),
          AnimatedBuilder(
            animation: _blueTopClipperAnimation,
            builder: (_, Widget? child) {
              return ClipPath(
                clipper: BlueTopClipper(
                  yOffset: _blueTopClipperAnimation.value,
                ),
                child: child,
              );
            },
            child: Container(color: kWhite),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Header(animation: _headerTextAnimation),
                  const Spacer(),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10, left: 25),
                    child: TypeText(
                      "Enter your email address",
                      duration: Duration(milliseconds: 4000),
                    ),
                  ),
                  FadeSlideTransition(
                    animation: _formElementAnimation,
                    additionalOffset: 0.0,
                    child: inputEmail(),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Get.theme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          )),
                      child: const Text("Continue"),
                      onPressed: () {
                        gotoNextPage();
                      },
                    ),
                  ),
                  const Spacer(),
                  FadeSlideTransition(
                    animation: _formElementAnimation,
                    additionalOffset: 0.0,
                    child: optionAuth(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  final TextEditingController inpEmail = TextEditingController();
  Widget inputEmail() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Get.theme.primaryColor),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: TextField(
          onSubmitted: (val) {},
          keyboardType: TextInputType.emailAddress,
          controller: inpEmail,
          cursorRadius: const Radius.circular(25),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 5),
            hintText: 'Type your email address',
            prefixIcon: Container(
              margin: const EdgeInsets.only(right: 10, left: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                //color: Get.theme.primaryColor,
              ),
              child: Icon(BootstrapIcons.inbox,
                  color: Get.theme.primaryColor, size: 20),
            ),
            fillColor: Colors.white,
            filled: true,
          ),
        ),
      ),
    );
  }

  Widget optionAuth() {
    return Container(
      width: Get.width,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.secondary.withOpacity(.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  debugPrint("print...");
                  gotoNextPage();
                },
                icon: const Icon(BootstrapIcons.google, color: Colors.red),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.secondary.withOpacity(.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  gotoNextPage();
                },
                icon: const Icon(BootstrapIcons.apple, color: Colors.black),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.secondary.withOpacity(.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  gotoNextPage();
                },
                icon: const Icon(BootstrapIcons.facebook, color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }

  gotoNextPage() {
    Get.off(PackagePage());
  }
}
