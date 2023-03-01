import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Constants {
  static String appName = "XChatBot";
  static String appVersion = "v. 0.9.6";
  static String appSubName = "XChatBot AI";
  static String appStorage = "chatbot_storage";

  //API Key Token ChatGPT OpenAI
  static String apiKeyToken =
      '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';
  // update api token key refers to your account openAI

  // homepage
  static String helloGuest = "Hello Guest";

  // intropge
  static String wording0 =
      'XChatBot AI is Fun & Interactive ChatBot powered by OpenAI';
  static String wording1 =
      'ChatGPT is model OpenAI interacts in a conversational way.';
  static String wording2 =
      'This $appName artificial intelligence chatbot, powered by GPT-3 technology, is designed to entertain and engage users in conversation. search anything with AI';
  static String wording3 =
      'Fun and interatives conversational with ChatBot ChatGPT-3 OpenAI';

  static List<dynamic> slideWordings = [
    {"title": wording0, "desc": wording2},
    {
      "title": 'ChatGPT & DALL·E 2 Text & Image Model',
      "desc":
          'Fun and interatives conversational with ChatBot. Image generation DALL·E 2 Model powered by OpenAI. TypeWriter Text Ready!'
    },
    {
      "title": "Membership Plan support Paypal, Google Pay, Apple Pay",
      "desc":
          "Template Module. Three packages available Trial, Limited, Unlimited Membership Package Subscription. Cancellation anytime!"
    },
  ];

  static dynamic packageInfo = {
    "title": "Membership Plan support Paypal, Google Pay, Apple Pay",
    "desc":
        "Template Module. Three packages available Trial, Limited, Unlimited Membership Package Subscription. Cancellation anytime!"
  };

  // chatbot text
  static String questionAnswer = "Question, Answer";
  static String textToImage = "Text to Image";
  static String speechToText = "Speech To Text";
  static String imageToText = "Image To Text - OCR";

  static int maxTimeoutStream = 1000 * 120;

  static String urlDummy = 'https://erhacorp.id/logorh256.png';
  static String labelSetting = "Setting";
  static String labelAbout = "About";

  static String methodChannel = 'com.erhacorpdotcom.xchatbot/app_retain';

  static List<dynamic> objectModels = [
    {
      "title": "text-davinci-003",
      "code": "kTranslateModelV3",
      "source": kTranslateModelV3
    },
    {
      "title": "text-davinci-002",
      "code": "kTranslateModelV2",
      "source": kTranslateModelV2
    },
    {
      "title": "code-davinci-002",
      "code": "kCodeTranslateModelV2",
      "source": kCodeTranslateModelV2
    }
  ];

  static String findModelChatByTitle(final title) {
    final model = objectModels
        .firstWhere((element) => element['title'].toString() == title);

    return model['code'].toString();
  }

  static List<dynamic> iconTops = [
    {
      "title": "Text",
      "icon":
          Icon(BootstrapIcons.fonts, size: 24, color: Get.theme.primaryColor)
    },
    {
      "title": "Image",
      "icon":
          Icon(BootstrapIcons.image, size: 20, color: Get.theme.primaryColor)
    },
    {
      "title": "Voice",
      "icon": Icon(BootstrapIcons.mic, size: 20, color: Get.theme.primaryColor)
    },
    {
      "title": "Scan",
      "icon":
          Icon(BootstrapIcons.camera, size: 20, color: Get.theme.primaryColor)
    }
  ];

  static String dummyAnswer =
      'Flutter is a free, open-source mobile app development framework created by Google. It uses the Dart programming language and provides a way to build natively compiled applications for mobile, web, and desktop from a single codebase. It allows developers to create high-performance, visually attractive, and fast-loading mobile applications for both Android and iOS platforms.';
}

// login auth screens
// Colors
const Color kBlue = Color(0xFF306EFF);
const Color kLightBlue = Color(0xFF4985FD);
const Color kDarkBlue = Color(0xFF1046B3);
const Color kWhite = Color(0xFFFFFFFF);
const Color kGrey = Color(0xFFF4F5F7);
const Color kBlack = Color(0xFF2D3243);

// Padding
const double kPaddingS = 8.0;
const double kPaddingM = 16.0;
const double kPaddingL = 32.0;
const double kPaddingXL = 49.0;

// Spacing
const double kSpaceS = 8.0;
const double kSpaceM = 16.0;
const double kSpace14 = 14.0;

// Animation
const Duration kButtonAnimationDuration = Duration(milliseconds: 600);
const Duration kCardAnimationDuration = Duration(milliseconds: 400);
const Duration kRippleAnimationDuration = Duration(milliseconds: 400);
const Duration kLoginAnimationDuration = Duration(milliseconds: 1500);

// Assets
const String kGoogleLogoPath = 'assets/google_logo.png';
