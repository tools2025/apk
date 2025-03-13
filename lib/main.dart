import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services.dart
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

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

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebViewScreen(), // Langsung ke halaman utama
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
      ..setUserAgent("enzoXzodix")
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            // Anda bisa menambahkan logika di sini jika diperlukan
          },
          onPageFinished: (_) {
            // Hapus baris berikut
            // InterstitialAdManager.showAd();
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
            String url = request.url;
            
            // Jika URL adalah panelsystem.netlify.app
            if (url.startsWith('https://panelsystem.netlify.app/')) {
              return NavigationDecision.navigate;
            } 
            // Jika URL adalah Telegram (t.me atau telegram.me)
            else if (url.contains('t.me') || url.contains('telegram.me')) {
              // Buka Telegram secara langsung
              _launchExternalBrowser(url);
              return NavigationDecision.prevent;
            } else {
              // Buka URL lain di browser eksternal
              _launchExternalBrowser(url);
              return NavigationDecision.prevent;
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('https://panelsystem.netlify.app/'));

    // Hapus baris berikut
    // Future.delayed(const Duration(seconds: 2), () {
    //   AppOpenAdManager().showAdIfAvailable();
    // });
  }

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
        toolbarHeight: 0, // Sembunyikan AppBar
        elevation: 0, // Hilangkan shadow
        backgroundColor: Color(0xFF8B5CF6), // Warna #8B5CF6
      ),
      body: WebViewWidget(controller: _controller),
      // Hapus bottomNavigationBar: BannerAdWidget()
    );
  }
}
