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
  }

  Future<void> _onInitializeAds(
    InitializeAds event,
    Emitter<AdState> emit,
  ) async {
    try {
      final preferences = await _preferencesRepository.getPreferences();
      _isPremium = preferences.isPremiumActive;

      if (_isPremium) {
        emit(const AdsHidden());
        return;
      }

      await MobileAds.instance.initialize();
      emit(const AdInitial());
    } catch (e) {
      emit(AdError(e.toString()));
    }
  }

  Future<void> _onLoadBannerAd(
    LoadBannerAd event,
    Emitter<AdState> emit,
  ) async {
    if (_isPremium) {
      emit(const AdsHidden());
      return;
    }

    emit(const AdLoading());

    _bannerAd = AdHelper.createBannerAd(
      onAdLoaded: (ad) {
        add(const LoadBannerAd());
      },
      onAdFailedToLoad: (ad, error) {
        ad.dispose();
        _bannerAd = null;
      },
    );

    try {
      await _bannerAd!.load();
      emit(BannerAdReady(_bannerAd));
    } catch (e) {
      emit(AdError(e.toString()));
    }
  }

  Future<void> _onLoadInterstitialAd(
    LoadInterstitialAd event,
    Emitter<AdState> emit,
  ) async {
    if (_isPremium) {
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
          emit(AdError(error.message));
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
    if (_isPremium) {
      emit(const AdsHidden());
      return;
    }

    try {
      await AdHelper.loadRewardedAd(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          emit(const RewardedAdReady());
        },
        onAdFailedToLoad: (error) {
          emit(AdError(error.message));
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
    if (_isPremium || _interstitialAd == null) {
      return;
    }

    try {
      emit(const AdShowing(AdType.interstitial));

      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _interstitialAd = null;
          add(const LoadInterstitialAd());
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _interstitialAd = null;
          add(const LoadInterstitialAd());
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
      emit(const AdError('Rewarded ad not ready'));
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

  void _onRewardEarned(
    RewardEarned event,
    Emitter<AdState> emit,
  ) {
    emit(RewardReceived(
      amount: event.amount,
      type: event.type,
    ));
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
    if (_isPremium) return;

    await _preferencesRepository.incrementAdCounter();
    final shouldShowAd = await _preferencesRepository.shouldShowAds();

    if (shouldShowAd && _interstitialAd != null) {
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
