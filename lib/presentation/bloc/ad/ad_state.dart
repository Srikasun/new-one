part of 'ad_bloc.dart';

/// Base state for AdBloc
abstract class AdState extends Equatable {
  const AdState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AdInitial extends AdState {
  const AdInitial();
}

/// Ads are initialized and ready
class AdsInitialized extends AdState {
  const AdsInitialized();
}

/// Ads are being loaded
class AdLoading extends AdState {
  const AdLoading();
}

/// Ads are hidden (premium user)
class AdsHidden extends AdState {
  const AdsHidden();
}

/// Banner ad is ready
class BannerAdReady extends AdState {
  final dynamic bannerAd;

  const BannerAdReady(this.bannerAd);

  @override
  List<Object?> get props => [bannerAd];
}

/// Banner ad is disposed
class BannerAdDisposed extends AdState {
  const BannerAdDisposed();
}

/// Interstitial ad is ready
class InterstitialAdReady extends AdState {
  const InterstitialAdReady();
}

/// Interstitial ad was closed
class InterstitialAdClosed extends AdState {
  const InterstitialAdClosed();
}

/// Rewarded ad is ready
class RewardedAdReady extends AdState {
  const RewardedAdReady();
}

/// Ad is being shown
class AdShowing extends AdState {
  final AdType type;

  const AdShowing(this.type);

  @override
  List<Object?> get props => [type];
}

/// Reward earned from watching ad
class RewardReceived extends AdState {
  final int amount;
  final String type;

  const RewardReceived({
    required this.amount,
    required this.type,
  });

  @override
  List<Object?> get props => [amount, type];
}

/// Temporary premium granted
class TemporaryPremiumGranted extends AdState {
  final DateTime expiresAt;

  const TemporaryPremiumGranted({required this.expiresAt});

  @override
  List<Object?> get props => [expiresAt];
}

/// Temporary premium is currently active
class TemporaryPremiumActive extends AdState {
  final DateTime expiresAt;

  const TemporaryPremiumActive({required this.expiresAt});

  Duration get remainingTime => expiresAt.difference(DateTime.now());

  @override
  List<Object?> get props => [expiresAt];
}

/// Temporary premium has expired
class TemporaryPremiumExpired extends AdState {
  const TemporaryPremiumExpired();
}

/// Ad failed to load
class AdError extends AdState {
  final String message;

  const AdError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Ad types
enum AdType {
  banner,
  interstitial,
  rewarded,
  native,
}
