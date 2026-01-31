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

/// Interstitial ad is ready
class InterstitialAdReady extends AdState {
  const InterstitialAdReady();
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
