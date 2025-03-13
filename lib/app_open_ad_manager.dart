import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';

class AppOpenAdManager with WidgetsBindingObserver {
  static final AppOpenAdManager _instance = AppOpenAdManager._internal();
  factory AppOpenAdManager() => _instance;

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  int _adLoadTime = 0;
  static const int _maxAdAge = 60 * 60 * 1000; // 1 jam dalam milidetik

  AppOpenAdManager._internal();

  void initialize() {
    WidgetsBinding.instance.addObserver(this);
    loadAd();
  }

  void loadAd() {
    if (_isAdAvailable()) return;

    AppOpenAd.load(
      adUnitId: AdHelper.appOpenAdUnitId,
      request: AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _adLoadTime = DateTime.now().millisecondsSinceEpoch;
        },
        onAdFailedToLoad: (error) {
          debugPrint("OpenAd gagal dimuat: ${error.message}");
          _appOpenAd = null;
        },
      ),
      orientation: AppOpenAd.orientationPortrait,
    );
  }

  bool _isAdAvailable() {
    if (_appOpenAd == null) return false;
    int now = DateTime.now().millisecondsSinceEpoch;
    return (now - _adLoadTime) < _maxAdAge;
  }

  void showAdIfAvailable() {
    if (!_isAdAvailable() || _isShowingAd) {
      loadAd(); // Coba muat iklan baru jika tidak tersedia
      return;
    }

    _isShowingAd = true;
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        _appOpenAd = null;
        loadAd(); // Muat iklan baru setelah ditutup
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
      },
    );

    _appOpenAd!.show();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      showAdIfAvailable();
    }
  }
}
