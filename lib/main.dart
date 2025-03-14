import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import services.dart
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher

import 'banner_ad_widget.dart';
import 'interstitial_ad_manager.dart';
import 'app_open_ad_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();

  // Set warna status bar dan bar navigasi
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFF8B5CF6), // Warna #8B5CF6
      statusBarIconBrightness: Brightness.light, // Ikon status bar putih
      systemNavigationBarColor: Colors.white, // Warna bar navigasi bawah putih
      systemNavigationBarIconBrightness: Brightness.dark, // Ikon bar navigasi bawah gelap
    ),
  );

  // Inisialisasi dan muat App Open Ad
  AppOpenAdManager().initialize();
  InterstitialAdManager.loadAd();

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
      ..setUserAgent("enzoXzodix")
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            // Anda bisa menambahkan logika di sini jika diperlukan
          },
          onPageFinished: (_) {
            InterstitialAdManager.showAd();
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
            // Handle navigasi ke URL lain
            if (request.url.startsWith('https://panelsystem.netlify.app/')) {
              return NavigationDecision.navigate;
            } else {
              // Buka URL di browser eksternal
              _launchExternalBrowser(request.url);
              return NavigationDecision.prevent;
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('https://panelsystem.netlify.app/'));

    // Tampilkan App Open Ad setelah 2 detik
    Future.delayed(const Duration(seconds: 2), () {
      AppOpenAdManager().showAdIfAvailable();
    });
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
        backgroundColor: Colors.purple, // Sesuaikan dengan warna status bar
      ),
      body: WebViewWidget(controller: _controller),
      bottomNavigationBar: BannerAdWidget(),
    );
  }
}
