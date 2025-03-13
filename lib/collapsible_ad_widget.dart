import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class CollapsibleNativeAd extends StatefulWidget {
  @override
  _CollapsibleNativeAdState createState() => _CollapsibleNativeAdState();
}

class _CollapsibleNativeAdState extends State<CollapsibleNativeAd> {
  NativeAd? _nativeAd;
  bool _isAdLoaded = false;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
  }

  void _loadNativeAd() {
    _nativeAd = NativeAd(
      adUnitId: 'ca-app-pub-5341881048632674/6174887496', // Ganti dengan ID asli
      factoryId: 'listTile', // Sesuaikan dengan template
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() => _isAdLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          print('Native Ad failed: $error');
          _isAdLoaded = false;
          ad.dispose();
        },
      ),
      request: const AdRequest(),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: _isExpanded ? 250 : 80, // Ukuran banner & iklan penuh
      child: _isAdLoaded
          ? Stack(
              children: [
                AdWidget(ad: _nativeAd!),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(_isExpanded ? Icons.close : Icons.expand_more),
                    onPressed: () {
                      setState(() => _isExpanded = !_isExpanded);
                    },
                  ),
                ),
              ],
            )
          : SizedBox.shrink(),
    );
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }
}
