import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';

class InterstitialAdManager {
  static InterstitialAd? _interstitialAd;

  static void loadAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  static void showAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          loadAd();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }
}
