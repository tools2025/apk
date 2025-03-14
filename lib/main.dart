import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebViewScreen(),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent("flutterWebView")
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {},
          onPageFinished: (_) {},
          onWebResourceError: (error) async {
            String htmlString = await rootBundle.loadString('assets/404.html');
            _controller.loadRequest(
              Uri.dataFromString(
                htmlString,
                mimeType: 'text/html',
                encoding: Encoding.getByName('utf-8'),
              ),
            );
          },
          onNavigationRequest: (request) {
            // Check if the URL is a Telegram link or a regular web link
            if (_shouldOpenInExternalBrowser(request.url)) {
              if (request.url.startsWith('tg://')) {
                // Handle Telegram deep link
                _launchTelegramApp(request.url); 
              } else {
                // Open file URL in the external browser
                _launchExternalBrowser(request.url);  
              }
              return NavigationDecision.prevent;  // Prevent WebView from loading the URL
            }
            return NavigationDecision.navigate; // Continue navigating within WebView
          },
        ),
      )
      ..loadRequest(Uri.parse('https://coder8-33-63.vercel.app/'));  // Load your website URL
  }

  // Function to decide if the URL should be opened in an external browser
  bool _shouldOpenInExternalBrowser(String url) {
    // We are simply checking if the URL points to any resource (http or https).
    // We do not filter by file extensions, just open any file URL externally.
    return url.startsWith('http://') || url.startsWith('https://') || url.startsWith('tg://');
  }

  // Function to launch the Telegram app using deep links
  Future<void> _launchTelegramApp(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching Telegram: $e');
    }
  }

  // Function to launch the URL in the system's default browser
  Future<void> _launchExternalBrowser(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WebView with File Open"),
        backgroundColor: Color(0xFF8B5CF6),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
