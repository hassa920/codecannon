import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:xchatbot/helpers/app_color.dart';
import 'package:xchatbot/helpers/constants.dart';
import 'package:xchatbot/helpers/utility.dart';
import 'package:xchatbot/models/message_stream.dart';
import 'package:xchatbot/pages/full_image_page.dart';
import 'package:xchatbot/widgets/cache_image.dart';

class GenerateImagePage extends StatelessWidget {
  GenerateImagePage({super.key}) {
    Future.microtask(() {
      final apiKeyToken = Constants.apiKeyToken;
      debugPrint(
          "generate_image page constructor mainChatGPT apiKeyToken $apiKeyToken");

      final ChatGPT mainChatGPT = openAI.builder(
        apiKeyToken,
        baseOption: HttpSetup(receiveTimeout: Constants.maxTimeoutStream),
      );

      chatGPTObject.update((val) {
        val!.mainChatGPT = mainChatGPT;
      });
    });
  }

  final inputText = ''.obs;
  final openAI = ChatGPT.instance;
  final responseImageBot = <ImageStream>[].obs;

  final chatGPTObject = ChatGPTObject().obs;
  //final MyPref myPref = MyPref.to;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      height: Get.height,
      color: Colors.white,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    topHeader(),
                    const SizedBox(height: 20),
                    topEntryField(context),
                    Flexible(
                      child: Obx(
                        () => inputText.value == ''
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 10),
                                    Text(
                                      "${Constants.appName} Text to Image Interactive Bot",
                                      textAlign: TextAlign.center,
                                      style: Get.theme.textTheme.headlineSmall,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                        "Try to type something to generate smart, genius images from Bot, using DALL·E 2  OpenAI",
                                        textAlign: TextAlign.center,
                                        style: Get.theme.textTheme.titleMedium!
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
    );
  }

  Widget createStreamBuilder(final String input, final ChatGPT mainChatGPT) {
    debugPrint("generate image page createStreamBuilder input $input");

    final streamChatGPT = mainChatGPT
        .generateImageStream(GenerateImage(input, 10))
        .asBroadcastStream();

    return StreamBuilder<GenerateImgRes?>(
      stream: streamChatGPT,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final ImageStream msg = ImageStream(
              "No response, try another question Error ${snapshot.error.toString()}",
              DateTime.now().toUtc().toString());
          responseImageBot.add(msg);
          return generateListImage(responseImageBot);
        }

        if (!snapshot.hasData) {
          debugPrint("no snapshot.hasData ... ");
          return Column(
            children: [
              Flexible(child: generateListImage(responseImageBot)),
              const SizedBox(height: 20),
              Center(
                child: Utility.loading,
              ),
            ],
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          debugPrint("snapshot.connectionState waiting... ");
          return Column(
            children: [
              Flexible(child: generateListImage(responseImageBot)),
              Utility.loading,
            ],
          );
        }

        final GenerateImgRes? snapshots = snapshot.requireData;
        for (var image in snapshots!.data!) {
          debugPrint("found url image ${image!.url!} ");

          final ImageStream msg =
              ImageStream(image.url!.trim(), DateTime.now().toUtc().toString());

          bool isExist = false;
          try {
            final List<ImageStream> lastList = responseImageBot;
            isExist = lastList.any((ImageStream element) =>
                element.url.toString() == image.url!.trim());
          } catch (_) {}

          if (!isExist) {
            responseImageBot.add(msg);
          }
        }

        return Obx(() => generateListImage(responseImageBot));
      },
    );
  }

  Widget generateListImage(List<ImageStream> lists) {
    var columnCount = 2;

    return Container(
      width: Get.width,
      padding: EdgeInsets.zero,
      child: Container(
        width: Get.width,
        //height: Get.height,
        padding: EdgeInsets.zero,
        child: lists.isEmpty
            ? const SizedBox()
            : AnimationLimiter(
                child: GridView.count(
                  shrinkWrap: true,
                  childAspectRatio: 1.0,
                  padding: const EdgeInsets.all(8.0),
                  physics: const BouncingScrollPhysics(),
                  crossAxisCount: columnCount,
                  children: List.generate(
                    lists.length,
                    (int index) {
                      final ImageStream img = lists[index];
                      return AnimationConfiguration.staggeredGrid(
                        columnCount: columnCount,
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: InkWell(
                          onTap: () {
                            if (img.url != null && img.url != '') {
                              Get.to(FullImagePage(urlImage: img.url!));
                            }
                          },
                          child: ScaleAnimation(
                            scale: 0.5,
                            child: FadeInAnimation(
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                width: Get.width / 3.2,
                                height: Get.height / 4,
                                child: CacheImage(
                                  path: img.url,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
      ),
    );
  }

  submitQuery() {
    final String getText = inputController.text.trim();
    if (getText == '') return;

    responseImageBot.value = [];

    //inputController.text = '';
    focusNode.unfocus();

    Future.microtask(() => inputText.value = getText);
  }

  final TextEditingController inputController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  Widget topEntryField(final BuildContext context) {
    debugPrint("topEntryField");

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
          onSubmitted: (val) {
            submitQuery();
          },
          keyboardType: TextInputType.text,
          controller: inputController,
          focusNode: focusNode,
          cursorRadius: const Radius.circular(30),
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 32, vertical: 13),
            alignLabelWithHint: true,
            hintText: 'Type your text here..',
            suffixIcon: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  submitQuery();
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Get.theme.primaryColor,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: const Icon(
                      BootstrapIcons.search,
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
                    Text("Image Generator",
                        style: Get.theme.textTheme.labelMedium!
                            .copyWith(color: Colors.grey[500])),
                    Text(Constants.textToImage,
                        style: Get.theme.textTheme.titleLarge),
                  ],
                ),
              ],
            ),
            createIconRight(Constants.iconTops[1], 12),
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

class ImageStream {
  ImageStream(this.url, this.createdAt);
  String? url;
  String? createdAt;
}
