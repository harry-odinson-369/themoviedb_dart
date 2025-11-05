// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<bool?> requestLoginSheet(BuildContext context, String url) async {
  bool? logged = await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: false,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(12),
        topLeft: Radius.circular(12),
      ),
    ),
    builder: (context) {
      return WebViewSheet(url: url);
    },
  );
  return logged;
}

class WebViewSheet extends StatefulWidget {
  final String url;
  const WebViewSheet({super.key, required this.url});

  @override
  State<WebViewSheet> createState() => _WebViewSheetState();
}

class _WebViewSheetState extends State<WebViewSheet> {
  late WebViewController controller;

  String url = "";

  int progress = 0;

  bool isSuccess = false;

  final Set<Factory<OneSequenceGestureRecognizer>> gestureRecognizers = {
    Factory(() => EagerGestureRecognizer())
  };

  Future<NavigationDecision> onUrlRequest(NavigationRequest request) async {
    if (request.url.toLowerCase().trim().startsWith("https://www.themoviedb.org/settings/account")) {
      isSuccess = true;
      Navigator.of(context).pop(true);
    }
    return NavigationDecision.navigate;
  }

  void onUrlChanged(UrlChange change) {
    if (change.url != null) {
      url = change.url!;
      update();
    }
  }

  void update() => mounted ? setState(() {}) : () {};

  Future initialize() async {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onNavigationRequest: onUrlRequest,
        onUrlChange: onUrlChanged,
        onProgress: (progress) => setState(() => this.progress = progress),
      ))
      ..loadRequest(Uri.parse(widget.url));
    url = widget.url;
    update();
  }

  @override
  void initState() {
    initialize();
    super.initState();
  }

  @override
  void dispose() {
    controller.setNavigationDelegate(NavigationDelegate());
    controller.loadRequest(Uri.parse("about:blank"));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return WillPopScope(
      onWillPop: () async {
        if (await controller.canGoBack()) {
          await controller.goBack();
          return false;
        } else {
          return true;
        }
      },
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          topLeft: Radius.circular(12),
        ),
        child: Scaffold(
          backgroundColor: Colors.grey.shade200,
          appBar: AppBar(
            backgroundColor: Colors.grey.shade200,
            leading: const SizedBox(),
            leadingWidth: 12,
            titleSpacing: 12,
            actions: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(isSuccess),
                icon: const Icon(
                  Icons.close,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 12),
            ],
            title: Text(
              url.replaceAll("https://", ""),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            bottom: progress == 100
                ? null
                : PreferredSize(
                    preferredSize: const Size.fromHeight(4),
                    child: LinearProgressIndicator(
                      value: progress / 100 * 1,
                      backgroundColor: Colors.grey.shade400,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.redAccent,
                      ),
                      color: Colors.red,
                    ),
                  ),
          ),
          body: SizedBox(
              height: media.size.height,
              width: media.size.width,
              child: WebViewWidget(
                controller: controller,
                gestureRecognizers: gestureRecognizers,
              )),
        ),
      ),
    );
  }
}
