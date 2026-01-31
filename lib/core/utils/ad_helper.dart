import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constants/app_constants.dart';

/// Helper class for managing ads
class AdHelper {
  AdHelper._();

  /// Get banner ad unit ID based on platform
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // Use test ID in debug mode
      return _isTestMode
          ? AdConstants.testBannerId
          : AdConstants.androidBannerId;
    } else if (Platform.isIOS) {
      return _isTestMode ? AdConstants.testBannerId : AdConstants.iosBannerId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// Get interstitial ad unit ID based on platform
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return _isTestMode
          ? AdConstants.testInterstitialId
          : AdConstants.androidInterstitialId;
    } else if (Platform.isIOS) {
      return _isTestMode
          ? AdConstants.testInterstitialId
          : AdConstants.iosInterstitialId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// Get rewarded ad unit ID based on platform
  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return _isTestMode
          ? AdConstants.testRewardedId
          : AdConstants.androidRewardedId;
    } else if (Platform.isIOS) {
      return _isTestMode
          ? AdConstants.testRewardedId
          : AdConstants.iosRewardedId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// Get native ad unit ID based on platform
  static String get nativeAdUnitId {
    if (Platform.isAndroid) {
      return _isTestMode
          ? AdConstants.testNativeId
          : AdConstants.androidNativeId;
    } else if (Platform.isIOS) {
      return _isTestMode ? AdConstants.testNativeId : AdConstants.iosNativeId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  /// Check if we should use test ads
  static bool get _isTestMode {
    // In production, set this to false
    return true;
  }

  /// Create a banner ad
  static BannerAd createBannerAd({
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }

  /// Load an interstitial ad
  static Future<void> loadInterstitialAd({
    required void Function(InterstitialAd) onAdLoaded,
    required void Function(LoadAdError) onAdFailedToLoad,
  }) async {
    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }

  /// Load a rewarded ad
  static Future<void> loadRewardedAd({
    required void Function(RewardedAd) onAdLoaded,
    required void Function(LoadAdError) onAdFailedToLoad,
  }) async {
    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }
}
