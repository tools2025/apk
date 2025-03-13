import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';

class BannerAdWidget extends StatefulWidget {
  @override
  _BannerAdWidgetState createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  late BannerAd _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          _isAdLoaded = false;
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return _isAdLoaded
        ? Container(
            height: _bannerAd.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd),
          )
        : SizedBox();
  }
}
