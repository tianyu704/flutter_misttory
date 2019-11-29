import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lifecycle_state/lifecycle_state.dart';
import 'package:misstory/widgets/loading_dialog.dart';
import 'package:misstory/widgets/my_appbar.dart';
import 'package:webview_flutter/webview_flutter.dart';

///
/// Create by Hugo.Guo
/// Date: 2019-06-13
///
class WebViewPage extends StatefulWidget {
  final String _url;

  WebViewPage(this._url);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _WebViewPageState();
  }
}

class _WebViewPageState extends LifecycleState<WebViewPage> {
  String _title = "";
  LoadingDialog loading;

//  final Completer<WebViewController> _controller =
//      Completer<WebViewController>();
  WebViewController _webViewController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loading = LoadingDialog();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await _webViewController.canGoBack()) {
          await _webViewController.goBack();
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: MyAppbar(
          context,
          title: Text(_title),
          // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
        ),
        // We're using a Builder here so we have a context that is below the Scaffold
        // to allow calling Scaffold.of(context) so we can show a snackbar.
        body: Builder(builder: (BuildContext context) {
          return WebView(
            initialUrl: widget._url,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              this._webViewController = webViewController;
//              loading.show();

//              print(webViewController.currentUrl());
//              _controller.complete(webViewController);
            },
            // TODO(iskakaushik): Remove this when collection literals makes it to stable.
            // ignore: prefer_collection_literals
            javascriptChannels: <JavascriptChannel>[
              _toasterJavascriptChannel(context),
            ].toSet(),
            onPageFinished: (String url) {
//              loading.hide();
              debugPrint(url);
//              if (url.startsWith(Address.callbackUrl)) {
//                Navigator.pop(context, url);
//              }
              refreshTitle();
            },
          );
        }),
      ),
    );
  }

  void refreshTitle() async {
    _title =
        await _webViewController.evaluateJavascript("window.document.title");
    if (_title != null &&
        _title.isNotEmpty &&
        _title.startsWith("\"") &&
        _title.endsWith("\"")) {
      _title = _title.substring(1, _title.length - 1);
    }
    setState(() {});
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
