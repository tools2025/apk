import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set warna status bar dan bar navigasi
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF8B5CF6), // Warna #8B5CF6
      statusBarIconBrightness: Brightness.light, // Ikon status bar putih
      systemNavigationBarColor: Colors.white, // Warna bar navigasi bawah putih
      systemNavigationBarIconBrightness: Brightness.dark, // Ikon bar navigasi bawah gelap
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
    _initializeWebViewController();
  }

  void _initializeWebViewController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent("enzoXzodix")
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            // Anda bisa menambahkan logika di sini jika diperlukan
          },
          onPageFinished: (_) {
            // Logika setelah halaman selesai dimuat
          },
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
            if (request.url.startsWith('https://panelsystem.netlify.app/')) {
              return NavigationDecision.navigate;
            } else {
              _launchExternalBrowser(request.url);
              return NavigationDecision.prevent;
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('https://panelsystem.netlify.app/'));
  }

  Future<void> _launchExternalBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: _controller),
    );
  }
}
