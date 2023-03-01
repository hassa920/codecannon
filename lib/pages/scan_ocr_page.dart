import 'dart:math';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xchatbot/helpers/app_color.dart';
import 'package:xchatbot/helpers/constants.dart';
import 'package:xchatbot/helpers/my_pref.dart';
import 'package:xchatbot/helpers/utility.dart';
import 'package:xchatbot/helpers/extention.dart';
import 'package:xchatbot/models/message_stream.dart';
import 'package:xchatbot/models/image_ocr_object.dart';
import 'package:xchatbot/widgets/url_text/custom_url_text.dart';
import 'package:ml_kit_ocr/ml_kit_ocr.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xchatbot/widgets/popup_menu2/popup_menu_2.dart';

class ScanOcrPage extends StatelessWidget {
  ScanOcrPage({super.key}) {
    Future.microtask(() {
      final imageOcr = MlKitOcr();
      ocrObject.update((val) {
        val!.ocr = imageOcr;
      });

      debugPrint("set object imageOcr done");
    });

    Future.microtask(() {
      final apiKeyToken = Constants.apiKeyToken;
      debugPrint(
          "scanocr page constructor mainChatGPT apiKeyToken $apiKeyToken");

      final ChatGPT mainChatGPT = openAI.builder(
        apiKeyToken,
        baseOption: HttpSetup(receiveTimeout: Constants.maxTimeoutStream),
      );

      chatGPTObject.update((val) {
        val!.mainChatGPT = mainChatGPT;
      });
    });
  }

  final GlobalKey keyPopup = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        debugPrint("close page willpopscope");
        return Future.value(true);
      },
      child: Container(
        width: Get.width,
        height: Get.height,
        color: Colors.white,
        child: Scaffold(
          floatingActionButton: Obx(
            () => FloatingActionButton(
              key: keyPopup,
              onPressed: () async {},
              backgroundColor: !imageOcrListening.value
                  ? Get.theme.primaryColor
                  : Get.theme.primaryColor.withOpacity(.5),
              child: imageOcrListening.value
                  ? const Icon(BootstrapIcons.hourglass)
                  : ContextualMenu(
                      targetWidgetKey: keyPopup,
                      ctx: context,
                      maxColumns: 1,
                      backgroundColor: Get.theme.primaryColor,
                      highlightColor: Colors.white,
                      onDismiss: () {},
                      items: [
                        CustomPopupMenuItem(
                          press: () async {
                            Get.snackbar('Information',
                                'Scan Image from your camera...');
                            final image = await ImagePicker()
                                .pickImage(source: ImageSource.camera);
                            if (image != null) {
                              await imagePickerProcess(image);
                            }
                          },
                          title: 'Camera',
                          textAlign: TextAlign.justify,
                          textStyle: const TextStyle(
                              color: Colors.white, fontSize: 11),
                          image: const Icon(BootstrapIcons.camera,
                              color: Colors.white),
                        ),
                        CustomPopupMenuItem(
                          press: () async {
                            Get.snackbar('Information',
                                'Scan Image from your Photo Gallery...');
                            final image = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            if (image != null) {
                              await imagePickerProcess(image);
                            }
                          },
                          title: 'Gallery',
                          textAlign: TextAlign.justify,
                          textStyle: const TextStyle(
                              color: Colors.white, fontSize: 11),
                          image: const Icon(BootstrapIcons.image,
                              color: Colors.white),
                        ),
                      ],
                      child: Container(
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
          body: SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      topHeader(),
                      const SizedBox(height: 20),
                      Flexible(
                        child: Obx(
                          () => inputText.value == ''
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 10),
                                      Text(
                                        "${Constants.appName} Image To Text (OCR)",
                                        textAlign: TextAlign.center,
                                        style:
                                            Get.theme.textTheme.headlineSmall,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                          "Click on Camera, and scan, image contains text to process to OCR of your quesiton, to get smart, genius answer from Bot, using ChatGPT OpenAI",
                                          textAlign: TextAlign.center,
                                          style: Get
                                              .theme.textTheme.titleMedium!
                                              .copyWith(
                                                  color: AppColor.greyLabel2)),
                                    ],
                                  ))
                              : Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: chatGPTObject.value.mainChatGPT == null
                                      ? const SizedBox()
                                      : createStreamBuilder(inputText.value,
                                          chatGPTObject.value.mainChatGPT!),
                                ),
                        ),
                      ),
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

  imagePickerProcess(final XFile? image) async {
    // once after camera or gallery Image Picker
    if (image != null) {
      Get.snackbar(
          'Information', 'Scan Image for OCR image processing to Text...');
      await Future.delayed(const Duration(milliseconds: 500));
      await startOCRProcess(image);
    }
  }

  final ocrObject = ImageOcrObject().obs;
  startOCRProcess(final XFile? image) async {
    if (image == null) return;

    final imageOcr = ocrObject.value.ocr;
    if (imageOcr == null) {
      final ocr = MlKitOcr();
      ocrObject.update((val) {
        val!.ocr = ocr;
        val.image = image;
      });
    } else {
      ocrObject.update((val) {
        val!.image = image;
      });
    }

    imageOcrListening.value = true;
    final result =
        await imageOcr!.processImage(InputImage.fromFilePath(image.path));

    String recognitions = '';
    for (var blocks in result.blocks) {
      for (var lines in blocks.lines) {
        recognitions += '\n';
        for (var words in lines.elements) {
          recognitions += '${words.text} ';
        }
      }
    }

    ocrObject.value.result = recognitions.trim();

    if (recognitions.isNotEmpty) {
      imageOcrListening.value = false;
      await Future.delayed(const Duration(milliseconds: 500));
      submitMessage();
    } else {
      debugPrint("The user has denied the use of imageOcr recognition.");
    }
    // some time later...
    //imageOcr.stop()
  }

  final imageOcrListening = false.obs;
  submitMessage() {
    final String getText = ocrObject.value.result!;
    if (getText == '') return;

    final MessageStream msg = MessageStream("${Random().nextInt(100) + 1000}",
        getText, DateTime.now().toUtc().toString(), true);
    responseBot.add(msg);
    generateListMessage(responseBot, true);

    Future.delayed(const Duration(seconds: 2), () {
      scrollToIndex();
    });

    Future.microtask(() => inputText.value = getText);
  }

  final inputText = ''.obs;
  final openAI = ChatGPT.instance;
  final responseBot = <MessageStream>[].obs;
  final chatGPTObject = ChatGPTObject().obs;
  final MyPref myPref = MyPref.to;

  Widget createStreamBuilder(final String input, final ChatGPT mainChatGPT) {
    debugPrint("scanocr page createStreamBuilder input $input");
    final String modelChat = myPref.pModelChat.val;
    final int maxToken = myPref.pMaxToken.val;

    final streamChatGPT = mainChatGPT
        .onCompleteStream(
            request: CompleteReq(
                prompt: input.trim(), model: modelChat, max_tokens: maxToken))
        .handleError(
      (onError) {
        debugPrint("CompleteReq. onError... ");
        final MessageStream msg = MessageStream(
            "98",
            "No response, Error ${onError.toString()}",
            DateTime.now().toUtc().toString(),
            false);
        responseBot.add(msg);
        return generateListMessage(responseBot, true);
      },
    ).asBroadcastStream();

    return StreamBuilder<CompleteRes?>(
      stream: streamChatGPT,
      //builder screen
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final MessageStream msg = MessageStream(
              "99",
              "No response, try another question Error ${snapshot.error.toString()}",
              DateTime.now().toUtc().toString(),
              false);
          responseBot.add(msg);
          return generateListMessage(responseBot, true);
        }

        if (!snapshot.hasData) {
          debugPrint("snapshot. no data... ");
          return Column(
            children: [
              Flexible(child: generateListMessage(responseBot, true)),
              Utility.loading,
              const SizedBox(height: 50),
            ],
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          debugPrint("snapshot.connectionState waiting... ");
          return Column(
            children: [
              Flexible(child: generateListMessage(responseBot, true)),
              Utility.loading,
              const SizedBox(height: 50),
            ],
          );
        }

        final CompleteRes? snapshots = snapshot.requireData;
        for (var choice in snapshots!.choices) {
          debugPrint("found text index ${choice.index} answer ${choice.text}");

          final answerText = choice.text.trim();
          if (answerText.isEmpty) {
            final MessageStream msg = MessageStream(
                "99",
                "No response, try another question Error ${snapshot.error.toString()}",
                DateTime.now().toUtc().toString(),
                false);
            responseBot.add(msg);
            return generateListMessage(responseBot, true);
          }

          final MessageStream msg = MessageStream("${choice.index}", answerText,
              DateTime.now().toUtc().toString(), false);

          bool isExist = false;
          try {
            final List<MessageStream> lastList = responseBot;
            isExist = lastList.any((MessageStream element) =>
                element.message.toString().trim() == answerText);
          } catch (_) {}

          if (!isExist) {
            responseBot.add(msg);
          }
        }

        return Obx(() => generateListMessage(responseBot, false));
      },
    );
  }

  final ScrollController _controller = ScrollController();
  generateListMessage(final List<MessageStream> temps, final bool isLoading) {
    final List<MessageStream> lists = temps.reversed.toList();
    scrollToIndex();

    return lists.isEmpty
        ? const SizedBox()
        : ListView.builder(
            controller: _controller,
            shrinkWrap: true,
            reverse: true,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(0),
            itemCount: lists.length,
            itemBuilder: (context, index) {
              final message = lists[index];

              debugPrint("isLoading $isLoading");

              return InkWell(
                onTap: () {
                  Utility.copyToClipBoard(
                      context: context,
                      text: message.message ?? '',
                      message: 'Copied!');
                },
                onLongPress: () {
                  Utility.share(message.message ?? '',
                      subject: '${Constants.appName} Share');
                },
                child: Container(
                  color: Colors.transparent,
                  padding: EdgeInsets.only(
                      top: index >= lists.length - 1 ? 5 : 0,
                      bottom: isLoading
                          ? 0
                          : index == 0
                              ? 50
                              : 0),
                  child: messageWidget(
                      message.message!, message.isMine!, message.createdAt),
                ),
              );
            },
          );
  }

  scrollToIndex() async {
    try {
      Future.delayed(const Duration(milliseconds: 1500), () {
        debugPrint("chat_screen_page scrollToIndex running");

        if (_controller.hasClients) {
          //final position = _controller.position.maxScrollExtent;

          _controller.animateTo(
            0.0,
            curve: Curves.easeOut,
            duration: const Duration(milliseconds: 300),
          );
        }
      });
    } catch (e) {
      debugPrint("chat_screen_page [Error] ${e.toString()}");
    }
  }

  Widget messageWidget(
      final String response, final bool myQuestion, final String? createdAt) {
    return _message(response, myQuestion, createdAt);
  }

  Widget _message(
      final String text, final bool isMine, final String? createdAt) {
    return Column(
      crossAxisAlignment:
          isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisAlignment:
          isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            const SizedBox(width: 15),
            isMine ? const SizedBox() : Utility.appIcon(6),
            Expanded(
              child: Container(
                alignment:
                    isMine ? Alignment.centerRight : Alignment.centerLeft,
                margin: EdgeInsets.only(
                  right: isMine ? 10 : (Get.width / 4),
                  top: 8,
                  left: isMine ? (Get.width / 4) : 10,
                ),
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        borderRadius: getBorder(isMine),
                        color: isMine
                            ? Get.theme.primaryColor
                            : AppColor.greyLight,
                      ),
                      child: UrlText(
                        text: text.removeSpaces,
                        onHashTagPressed: (tag) {
                          debugPrint("get hashtag $tag");

                          if (tag != '') {
                            //context.gotoPage(HashTagMentionPage(hashTag: tag));
                          }
                        },
                        style: TextStyle(
                          color: isMine ? Colors.white : Colors.black87,
                          height: isMine ? 1 : 1.5,
                        ),
                        urlStyle: const TextStyle(
                            color: Colors.blue,
                            fontSize: 14,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(
            right: 10,
            left: isMine ? 15 : 30,
            top: isMine ? 5 : 10,
          ),
          child: Text(
            Utility.getChatTime(createdAt),
            style: Get.textTheme.bodySmall!.copyWith(fontSize: 12),
          ),
        )
      ],
    );
  }

  BorderRadius getBorder(bool myMessage) {
    return BorderRadius.only(
      topLeft: const Radius.circular(20),
      topRight: const Radius.circular(20),
      bottomRight:
          myMessage ? const Radius.circular(0) : const Radius.circular(20),
      bottomLeft:
          myMessage ? const Radius.circular(20) : const Radius.circular(0),
    );
  }

  Widget topHeader() {
    return Container(
      width: Get.width,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: InkWell(
                      onTap: () {
                        debugPrint("get back topHeader");
                        Get.back();
                      },
                      child: Icon(
                        BootstrapIcons.chevron_left,
                        color: Get.theme.primaryColor,
                      )),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Text Based (Model : ${Constants.findModelChatByTitle(MyPref.to.pModelChat.val)})",
                      overflow: TextOverflow.ellipsis,
                      style: Get.theme.textTheme.labelMedium!
                          .copyWith(color: Colors.grey[500], fontSize: 11),
                    ),
                    Text(Constants.imageToText,
                        style: Get.theme.textTheme.titleLarge),
                  ],
                ),
              ],
            ),
            createIconRight(Constants.iconTops[3], 11),
          ],
        ),
      ),
    );
  }

  Widget createIconRight(final dynamic e, final double padding) {
    return Container(
      margin: const EdgeInsets.only(right: 0),
      padding: EdgeInsets.all(padding),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Get.theme.primaryColor.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(2, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            child: e['icon'],
          ),
          const SizedBox(height: 2),
          Text(
            "${e['title']}",
            style: Get.theme.textTheme.labelMedium,
          ),
          const SizedBox(height: 2),
        ],
      ),
    );
  }
}
