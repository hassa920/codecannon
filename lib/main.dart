import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:page_transition/page_transition.dart';
import 'package:xchatbot/app/home_page.dart';
import 'package:xchatbot/helpers/constants.dart';
import 'package:xchatbot/helpers/app_controller.dart';
import 'package:xchatbot/helpers/my_pref.dart';
import 'package:xchatbot/pages/intro_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  //storage local box
  Get.lazyPut<MyPref>(() => MyPref());
  Get.lazyPut<AppController>(() => AppController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final MyPref myPref = MyPref.to;
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: Constants.appName,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
        fontFamily: GoogleFonts.roboto().fontFamily,
        textTheme: GoogleFonts.robotoTextTheme(
          Theme.of(context).textTheme,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AnimatedSplashScreen(
        duration: 3200,
        splash: 'assets/chatbot.png',
        splashIconSize: Get.width / 1.6,
        nextScreen: myPref.pFirst.val ? IntroPage() : HomePage(),
        splashTransition: SplashTransition.rotationTransition,
        pageTransitionType: PageTransitionType.fade,
        backgroundColor: Colors.white,
      ),
    );
  }
}
