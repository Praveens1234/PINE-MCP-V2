import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'scripts.dart';

enum AutomationStatus {
  idle,
  initializing,
  checkingLogin,
  openingEditor,
  injectingCode,
  compiling,
  success,
  error,
}

class AutomationController extends ChangeNotifier {
  HeadlessInAppWebView? _headlessWebView;
  AutomationStatus _status = AutomationStatus.idle;
  String _log = "";
  String _resultMessage = "";
  bool _isLoggedIn = false;

  AutomationStatus get status => _status;
  String get log => _log;
  String get resultMessage => _resultMessage;
  bool get isLoggedIn => _isLoggedIn;

  // IMPORTANT: Use Desktop User Agent to match selectors
  final String _userAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";
  final String _url = "https://www.tradingview.com/chart/";

  Future<void> init() async {
    _setStatus(AutomationStatus.initializing);
    _appendLog("Initializing Headless Browser...");

    _headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(_url)),
      initialSettings: InAppWebViewSettings(
        userAgent: _userAgent,
        isInspectable: true,
        javaScriptEnabled: true,
        domStorageEnabled: true,
        useWideViewPort: true, 
      ),
      onWebViewCreated: (controller) {
        _appendLog("WebView Created.");
      },
      onLoadStop: (controller, url) async {
        _appendLog("Page Loaded: $url");
        checkLoginStatus(controller);
      },
    );

    await _headlessWebView?.run();
    _setStatus(AutomationStatus.idle);
  }

  Future<void> checkLoginStatus(InAppWebViewController controller) async {
    try {
      final result = await controller.evaluateJavascript(source: jsCheckLogin);
      _isLoggedIn = result == true;
      notifyListeners();
      _appendLog("Login Status: $_isLoggedIn");
    } catch (e) {
      _appendLog("Error checking login: $e");
    }
  }

  Future<void> validateScript(String code) async {
    if (_headlessWebView == null) await init();
    
    final controller = _headlessWebView?.webViewController;
    if (controller == null) {
      _setError("Browser not ready.");
      return;
    }

    _setStatus(AutomationStatus.openingEditor);
    _appendLog("Opening Pine Editor...");

    try {
      // 1. Open Editor
      String openRes = await _evaluate(controller, jsOpenEditor);
      if (openRes == "NOT_FOUND") {
        // Try reloading
        _appendLog("Editor button not found. Reloading...");
        controller.reload();
        await Future.delayed(Duration(seconds: 5));
        openRes = await _evaluate(controller, jsOpenEditor);
      }
      
      if (openRes == "NOT_FOUND") throw "Could not open Pine Editor. Are you logged in?";
      await Future.delayed(Duration(seconds: 2));

      // 2. Inject Code
      _setStatus(AutomationStatus.injectingCode);
      // Escape the code for JS string
      final safeCode = code.replaceAll('`', '\\`').replaceAll('\$', '\\\$');
      final injectScript = "($jsInjectCode)(`$safeCode`)";
      
      String injectRes = await _evaluate(controller, injectScript);
      if (injectRes == "EDITOR_NOT_FOUND") throw "Editor content area not found.";
      await Future.delayed(Duration(seconds: 1));

      // 3. Click Add to Chart
      _setStatus(AutomationStatus.compiling);
      String clickRes = await _evaluate(controller, jsClickAddToChart);
      if (clickRes == "NOT_FOUND") throw "Add to Chart button not found.";

      // 4. Poll for Results
      int retries = 0;
      while (retries < 20) { // 10 seconds timeout
        await Future.delayed(Duration(milliseconds: 500));
        String resultJson = await _evaluate(controller, jsCheckResults);
        
        if (resultJson != "WAITING") {
          final res = jsonDecode(resultJson);
          if (res['status'] == 'success') {
            _setSuccess(res['message']);
          } else {
            _setError(res['message']);
          }
          return;
        }
        retries++;
      }
      
      _setError("Timeout waiting for compiler results.");

    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<String> _evaluate(InAppWebViewController controller, String script) async {
    final result = await controller.evaluateJavascript(source: script);
    return result?.toString() ?? "";
  }

  void _setStatus(AutomationStatus s) {
    _status = s;
    notifyListeners();
  }

  void _appendLog(String msg) {
    _log += "${DateTime.now().toIso8601String().substring(11, 19)}: $msg\n";
    notifyListeners();
  }

  void _setError(String msg) {
    _status = AutomationStatus.error;
    _resultMessage = msg;
    _appendLog("ERROR: $msg");
    notifyListeners();
  }

  void _setSuccess(String msg) {
    _status = AutomationStatus.success;
    _resultMessage = msg;
    _appendLog("SUCCESS: $msg");
    notifyListeners();
  }
  
  @override
  void dispose() {
    _headlessWebView?.dispose();
    super.dispose();
  }
}
