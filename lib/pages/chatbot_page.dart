import 'dart:async';
import 'dart:math';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xchatbot/helpers/ads_helper.dart';
import 'package:xchatbot/helpers/app_color.dart';
import 'package:xchatbot/helpers/app_controller.dart';
import 'package:xchatbot/helpers/constants.dart';
import 'package:xchatbot/helpers/my_pref.dart';
import 'package:xchatbot/helpers/utility.dart';
import 'package:xchatbot/helpers/extention.dart';
import 'package:xchatbot/models/message_stream.dart';
import 'package:xchatbot/widgets/url_text/custom_url_text.dart';
import 'package:xchatbot/widgets/typewriter/type_text.dart';

class ChatbotPage extends StatelessWidget {
  final AppController appController;

  ChatbotPage({super.key, required this.appController}) {
    Future.delayed(const Duration(milliseconds: 2200), () {
      try {
        final AdsHelper adsHelper = appController.adsHelper;
        if (adsHelper.interstitialAd != null) {
          adsHelper.interstitialAd!.show();
        }
      } catch (_) {}
    });

    Future.microtask(() {
      final apiKeyToken = Constants.apiKeyToken;
      debugPrint(
          "chatbot page constructor mainChatGPT apiKeyToken $apiKeyToken");

      final ChatGPT mainChatGPT = openAI.builder(
        apiKeyToken,
        baseOption: HttpSetup(receiveTimeout: Constants.maxTimeoutStream),
      );

      chatGPTObject.update((val) {
        val!.mainChatGPT = mainChatGPT;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        onCloseSubscription();
        return Future.value(true);
      },
      child: Container(
        width: Get.width,
        height: Get.height,
        color: Colors.white,
        child: Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      topHeader(),
                      const SizedBox(height: 10),
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
                                        "${Constants.appName} Question, Answer Interactive Bot",
                                        textAlign: TextAlign.center,
                                        style:
                                            Get.theme.textTheme.headlineSmall,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                          "Try to type something your corious about, to get smart, genius answer from Bot, using ChatGPT OpenAI",
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
                bottomEntryField(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  onCloseSubscription() {
    debugPrint("chatbot page onCloseSubscription");

    try {
      if (chatGPTObject.value.mainChatGPT != null) {
        chatGPTObject.update((val) {
          val!.mainChatGPT = null;
        });
      }
    } catch (_) {}
  }

  final TextEditingController messageController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  Widget bottomEntryField(final BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Container(
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
            onSubmitted: (val) {
              submitMessage();
            },
            keyboardType: TextInputType.multiline,
            minLines: 1,
            maxLines: 3,
            controller: messageController,
            focusNode: focusNode,
            cursorRadius: const Radius.circular(30),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 13),
              alignLabelWithHint: true,
              hintText: 'Type your question here..',
              suffixIcon: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => submitMessage(),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Get.theme.primaryColor,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: const Icon(
                        BootstrapIcons.send_fill,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
        ),
      ),
    );
  }

  submitMessage() {
    final String getText = messageController.text.trim();
    if (getText == '') return;

    final MessageStream msg = MessageStream("${Random().nextInt(100) + 1000}",
        getText, DateTime.now().toUtc().toString(), true);
    responseBot.add(msg);
    generateListMessage(responseBot, true);

    Future.delayed(const Duration(seconds: 2), () {
      scrollToIndex();
    });

    messageController.text = '';
    focusNode.unfocus();

    Future.microtask(() => inputText.value = getText);
  }

  final inputText = ''.obs;
  final openAI = ChatGPT.instance;
  final responseBot = <MessageStream>[].obs;
  final chatGPTObject = ChatGPTObject().obs;
  final MyPref myPref = MyPref.to;

  Widget createStreamBuilder(final String input, final ChatGPT mainChatGPT) {
    debugPrint("chatbot page createStreamBuilder input $input");

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

    //chatGPTObject.value.controller!.sink.add(streamChatGPT.listen((event) { }));

    return StreamBuilder<CompleteRes?>(
      stream: streamChatGPT,
      //builder screen
      builder: (context, AsyncSnapshot<CompleteRes?> snapshot) {
        if (snapshot.hasError) {
          debugPrint("snapshot. hasError... ");
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
          final String getText = choice.text.trim();
          if (getText.isEmpty) {
            final MessageStream msg = MessageStream(
                "97",
                "No response, try another question Error ${snapshot.error.toString()}",
                DateTime.now().toUtc().toString(),
                false);
            responseBot.add(msg);
            return generateListMessage(responseBot, true);
          }

          final MessageStream msg = MessageStream("${choice.index}", getText,
              DateTime.now().toUtc().toString(), false);

          bool isExist = false;
          try {
            final List<MessageStream> lastList = responseBot;
            isExist = lastList.any((MessageStream element) =>
                element.message.toString().trim() == getText);
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
    debugPrint("generateListMessage lists size ${temps.length}");

    final List<MessageStream> lists =
        temps.length < 2 ? temps : temps.reversed.toList();
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
                  child: messageWidget(message.message!,
                      message.isMine ?? false, message.createdAt, index == 0),
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

  Widget messageWidget(final String response, final bool myQuestion,
      final String? createdAt, final bool lastOne) {
    return _message(response, myQuestion, createdAt, lastOne);
  }

  Widget _message(final String text, final bool isMine, final String? createdAt,
      final bool lastOne) {
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
                      child: !isMine && lastOne
                          ? TypeText(
                              text.trim(),
                              duration: const Duration(milliseconds: 2000),
                            )
                          : UrlText(
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
                        onCloseSubscription();
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
                        "Text Based (Model : ${Constants.findModelChatByTitle(myPref.pModelChat.val)})",
                        style: Get.theme.textTheme.labelMedium!
                            .copyWith(color: Colors.grey[500])),
                    Text(Constants.questionAnswer,
                        style: Get.theme.textTheme.titleLarge),
                  ],
                ),
              ],
            ),
            createIconRight(Constants.iconTops[0], 12),
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
          Text("${e['title']}", style: Get.theme.textTheme.labelMedium),
          const SizedBox(height: 2),
        ],
      ),
    );
  }
}
