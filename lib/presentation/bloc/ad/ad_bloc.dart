import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/utils/ad_helper.dart';
import '../../../data/repositories/preferences_repository.dart';

part 'ad_event.dart';
part 'ad_state.dart';

/// BLoC for managing advertisements
class AdBloc extends Bloc<AdEvent, AdState> {
  final PreferencesRepository _preferencesRepository;

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  bool _isPremium = false;
  bool _hasTemporaryPremium = false;
  DateTime? _temporaryPremiumExpiry;
  DateTime? _lastInterstitialShown;
  int _booksAddedCount = 0;
  int _booksCompletedCount = 0;

  // Minimum time between interstitial ads (5 minutes)
  static const Duration _minInterstitialInterval = Duration(minutes: 5);
  // Books to add before showing first interstitial
  static const int _booksBeforeFirstAd = 3;

  AdBloc({required PreferencesRepository preferencesRepository})
      : _preferencesRepository = preferencesRepository,
        super(const AdInitial()) {
    on<InitializeAds>(_onInitializeAds);
    on<LoadBannerAd>(_onLoadBannerAd);
    on<LoadInterstitialAd>(_onLoadInterstitialAd);
    on<LoadRewardedAd>(_onLoadRewardedAd);
    on<ShowInterstitialAd>(_onShowInterstitialAd);
    on<ShowRewardedAd>(_onShowRewardedAd);
    on<RewardEarned>(_onRewardEarned);
    on<HideAds>(_onHideAds);
    on<DisposeAds>(_onDisposeAds);
    on<UserActionOccurred>(_onUserActionOccurred);
    on<BookAdded>(_onBookAdded);
    on<BookCompleted>(_onBookCompleted);
    on<GrantTemporaryPremium>(_onGrantTemporaryPremium);
    on<CheckTemporaryPremium>(_onCheckTemporaryPremium);
    on<DisposeBannerAd>(_onDisposeBannerAd);
  }

  /// Check if ads should be shown
  bool get shouldShowAds => !_isPremium && !_hasTemporaryPremium;

  /// Check if temporary premium is active
  bool get hasTemporaryPremium {
    if (_temporaryPremiumExpiry == null) return false;
    return DateTime.now().isBefore(_temporaryPremiumExpiry!);
  }

  /// Get banner ad if available
  BannerAd? get bannerAd => _bannerAd;

  /// Check if interstitial can be shown (respecting frequency limit)
  bool get canShowInterstitial {
    if (!shouldShowAds) return false;
    if (_interstitialAd == null) return false;
    if (_lastInterstitialShown == null) return true;
    
    return DateTime.now().difference(_lastInterstitialShown!) >= _minInterstitialInterval;
  }

  Future<void> _onInitializeAds(
    InitializeAds event,
    Emitter<AdState> emit,
  ) async {
    try {
      final preferences = await _preferencesRepository.getPreferences();
      _isPremium = preferences.isPremiumActive;
      
      // Check for temporary premium
      if (preferences.premiumExpiryDate != null) {
        _temporaryPremiumExpiry = preferences.premiumExpiryDate;
        _hasTemporaryPremium = hasTemporaryPremium;
      }

      if (_isPremium || _hasTemporaryPremium) {
        emit(const AdsHidden());
        return;
      }

      await MobileAds.instance.initialize();
      
      // Pre-load ads
      add(const LoadInterstitialAd());
      add(const LoadRewardedAd());
      
      emit(const AdsInitialized());
    } catch (e) {
      emit(AdError(e.toString()));
    }
  }

  Future<void> _onLoadBannerAd(
    LoadBannerAd event,
    Emitter<AdState> emit,
  ) async {
    if (_isPremium || _hasTemporaryPremium) {
      emit(const AdsHidden());
      return;
    }

    // Dispose existing banner if any
    _bannerAd?.dispose();
    _bannerAd = null;

    emit(const AdLoading());

    _bannerAd = AdHelper.createBannerAd(
      onAdLoaded: (ad) {
        emit(BannerAdReady(ad as BannerAd));
      },
      onAdFailedToLoad: (ad, error) {
        ad.dispose();
        _bannerAd = null;
        emit(AdError('Banner ad failed to load: ${error.message}'));
      },
    );

    try {
      await _bannerAd!.load();
    } catch (e) {
      emit(AdError(e.toString()));
    }
  }

  Future<void> _onDisposeBannerAd(
    DisposeBannerAd event,
    Emitter<AdState> emit,
  ) async {
    _bannerAd?.dispose();
    _bannerAd = null;
    emit(const BannerAdDisposed());
  }

  Future<void> _onLoadInterstitialAd(
    LoadInterstitialAd event,
    Emitter<AdState> emit,
  ) async {
    if (_isPremium || _hasTemporaryPremium) {
      emit(const AdsHidden());
      return;
    }

    try {
      await AdHelper.loadInterstitialAd(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          emit(const InterstitialAdReady());
        },
        onAdFailedToLoad: (error) {
          emit(AdError('Interstitial ad failed to load: ${error.message}'));
        },
      );
    } catch (e) {
      emit(AdError(e.toString()));
    }
  }

  Future<void> _onLoadRewardedAd(
    LoadRewardedAd event,
    Emitter<AdState> emit,
  ) async {
    // Rewarded ads should be available even for premium users
    // (they might want to watch ads for extra features)
    try {
      await AdHelper.loadRewardedAd(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          emit(const RewardedAdReady());
        },
        onAdFailedToLoad: (error) {
          emit(AdError('Rewarded ad failed to load: ${error.message}'));
        },
      );
    } catch (e) {
      emit(AdError(e.toString()));
    }
  }

  Future<void> _onShowInterstitialAd(
    ShowInterstitialAd event,
    Emitter<AdState> emit,
  ) async {
    if (_isPremium || _hasTemporaryPremium) {
      return;
    }
    
    if (_interstitialAd == null) {
      add(const LoadInterstitialAd());
      return;
    }

    // Check frequency limit
    if (!canShowInterstitial) {
      return;
    }

    try {
      emit(const AdShowing(AdType.interstitial));

      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          _lastInterstitialShown = DateTime.now();
          add(const LoadInterstitialAd());
          emit(const InterstitialAdClosed());
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          add(const LoadInterstitialAd());
          emit(AdError('Failed to show interstitial: ${error.message}'));
        },
      );

      await _interstitialAd!.show();
      await _preferencesRepository.resetAdCounter();
    } catch (e) {
      emit(AdError(e.toString()));
    }
  }

  Future<void> _onShowRewardedAd(
    ShowRewardedAd event,
    Emitter<AdState> emit,
  ) async {
    if (_rewardedAd == null) {
      emit(const AdError('Rewarded ad not ready. Please try again.'));
      add(const LoadRewardedAd());
      return;
    }

    try {
      emit(const AdShowing(AdType.rewarded));

      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _rewardedAd = null;
          add(const LoadRewardedAd());
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _rewardedAd = null;
          add(const LoadRewardedAd());
          emit(AdError('Failed to show rewarded ad: ${error.message}'));
        },
      );

      await _rewardedAd!.show(
        onUserEarnedReward: (_, reward) {
          add(RewardEarned(
            amount: reward.amount.toInt(),
            type: reward.type,
          ));
        },
      );
    } catch (e) {
      emit(AdError(e.toString()));
    }
  }

  Future<void> _onRewardEarned(
    RewardEarned event,
    Emitter<AdState> emit,
  ) async {
    // Grant 24-hour temporary premium access
    add(const GrantTemporaryPremium(duration: Duration(hours: 24)));
    
    emit(RewardReceived(
      amount: event.amount,
      type: event.type,
    ));
  }

  Future<void> _onGrantTemporaryPremium(
    GrantTemporaryPremium event,
    Emitter<AdState> emit,
  ) async {
    try {
      _temporaryPremiumExpiry = DateTime.now().add(event.duration);
      _hasTemporaryPremium = true;

      // Save to preferences
      await _preferencesRepository.updatePremiumStatus(
        isPremium: true,
        expiryDate: _temporaryPremiumExpiry,
      );

      // Hide ads
      _disposeAllAds();
      emit(TemporaryPremiumGranted(expiresAt: _temporaryPremiumExpiry!));
    } catch (e) {
      emit(AdError(e.toString()));
    }
  }

  Future<void> _onCheckTemporaryPremium(
    CheckTemporaryPremium event,
    Emitter<AdState> emit,
  ) async {
    if (_temporaryPremiumExpiry != null) {
      if (DateTime.now().isAfter(_temporaryPremiumExpiry!)) {
        // Temporary premium expired
        _hasTemporaryPremium = false;
        _temporaryPremiumExpiry = null;
        
        await _preferencesRepository.updatePremiumStatus(
          isPremium: false,
          expiryDate: null,
        );
        
        emit(const TemporaryPremiumExpired());
        
        // Reinitialize ads
        add(const InitializeAds());
      } else {
        emit(TemporaryPremiumActive(expiresAt: _temporaryPremiumExpiry!));
      }
    }
  }

  void _onHideAds(
    HideAds event,
    Emitter<AdState> emit,
  ) {
    _isPremium = true;
    _disposeAllAds();
    emit(const AdsHidden());
  }

  Future<void> _onDisposeAds(
    DisposeAds event,
    Emitter<AdState> emit,
  ) async {
    _disposeAllAds();
    emit(const AdInitial());
  }

  Future<void> _onUserActionOccurred(
    UserActionOccurred event,
    Emitter<AdState> emit,
  ) async {
    if (_isPremium || _hasTemporaryPremium) return;

    await _preferencesRepository.incrementAdCounter();
    final shouldShowAd = await _preferencesRepository.shouldShowAds();

    if (shouldShowAd && canShowInterstitial) {
      add(const ShowInterstitialAd());
    }
  }

  Future<void> _onBookAdded(
    BookAdded event,
    Emitter<AdState> emit,
  ) async {
    if (_isPremium || _hasTemporaryPremium) return;

    _booksAddedCount++;
    
    // Show interstitial after adding 3rd book
    if (_booksAddedCount >= _booksBeforeFirstAd && canShowInterstitial) {
      add(const ShowInterstitialAd());
      _booksAddedCount = 0; // Reset counter
    }
  }

  Future<void> _onBookCompleted(
    BookCompleted event,
    Emitter<AdState> emit,
  ) async {
    if (_isPremium || _hasTemporaryPremium) return;

    _booksCompletedCount++;
    
    // Show interstitial after marking book complete
    if (canShowInterstitial) {
      add(const ShowInterstitialAd());
    }
  }

  void _disposeAllAds() {
    _bannerAd?.dispose();
    _bannerAd = null;

    _interstitialAd?.dispose();
    _interstitialAd = null;

    _rewardedAd?.dispose();
    _rewardedAd = null;
  }

  @override
  Future<void> close() {
    _disposeAllAds();
    return super.close();
  }
}
