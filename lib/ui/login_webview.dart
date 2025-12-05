import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import '../logic/automation_controller.dart';

class LoginWebView extends StatefulWidget {
  const LoginWebView({Key? key}) : super(key: key);

  @override
  _LoginWebViewState createState() => _LoginWebViewState();
}

class _LoginWebViewState extends State<LoginWebView> {
  final GlobalKey webViewKey = GlobalKey();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login to TradingView"),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              // Trigger a check in the controller
              // The controller will detect existing headless view and reload it
              Provider.of<AutomationController>(context, listen: false).init();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: InAppWebView(
        key: webViewKey,
        // Go to homepage to avoid rate limits
        initialUrlRequest: URLRequest(url: WebUri("https://www.tradingview.com/")),
        initialSettings: InAppWebViewSettings(
          // Use default Android UA to avoid "Locked out" error
          domStorageEnabled: true,
          javaScriptEnabled: true,
        ),
      ),
    );
  }
}
