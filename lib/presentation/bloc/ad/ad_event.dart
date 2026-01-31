part of 'ad_bloc.dart';

/// Base event for AdBloc
abstract class AdEvent extends Equatable {
  const AdEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize ads
class InitializeAds extends AdEvent {
  const InitializeAds();
}

/// Event to load a banner ad
class LoadBannerAd extends AdEvent {
  const LoadBannerAd();
}

/// Event to dispose banner ad
class DisposeBannerAd extends AdEvent {
  const DisposeBannerAd();
}

/// Event to load an interstitial ad
class LoadInterstitialAd extends AdEvent {
  const LoadInterstitialAd();
}

/// Event to load a rewarded ad
class LoadRewardedAd extends AdEvent {
  const LoadRewardedAd();
}

/// Event to show an interstitial ad
class ShowInterstitialAd extends AdEvent {
  const ShowInterstitialAd();
}

/// Event to show a rewarded ad
class ShowRewardedAd extends AdEvent {
  const ShowRewardedAd();
}

/// Event when a reward is earned
class RewardEarned extends AdEvent {
  final int amount;
  final String type;

  const RewardEarned({
    required this.amount,
    required this.type,
  });

  @override
  List<Object?> get props => [amount, type];
}

/// Event to hide ads (premium user)
class HideAds extends AdEvent {
  const HideAds();
}

/// Event to dispose ads
class DisposeAds extends AdEvent {
  const DisposeAds();
}

/// Event when user action occurs (for ad frequency tracking)
class UserActionOccurred extends AdEvent {
  const UserActionOccurred();
}

/// Event when a book is added
class BookAdded extends AdEvent {
  const BookAdded();
}

/// Event when a book is marked as complete
class BookCompleted extends AdEvent {
  const BookCompleted();
}

/// Event to grant temporary premium access
class GrantTemporaryPremium extends AdEvent {
  final Duration duration;

  const GrantTemporaryPremium({
    this.duration = const Duration(hours: 24),
  });

  @override
  List<Object?> get props => [duration];
}

/// Event to check if temporary premium is still active
class CheckTemporaryPremium extends AdEvent {
  const CheckTemporaryPremium();
}
