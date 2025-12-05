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
  
  // Use Desktop UA to ensure consistent cookie handling if sharing cookies
  // But for user login, mobile view is easier. 
  // IMPORTANT: Cookies set here must be accessible by the HeadlessWebView.
  // InAppWebView uses a shared CookieManager by default on Android.
  
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
              Provider.of<AutomationController>(context, listen: false).init();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: InAppWebView(
        key: webViewKey,
        initialUrlRequest: URLRequest(url: WebUri("https://www.tradingview.com/accounts/signin/")),
        initialSettings: InAppWebViewSettings(
          userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
          domStorageEnabled: true,
          javaScriptEnabled: true,
        ),
      ),
    );
  }
}
