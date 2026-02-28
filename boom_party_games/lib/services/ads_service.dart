import 'dart:math';
import 'package:applovin_max/applovin_max.dart';
import '../config/ads_config.dart';

class AdsService {
  static final AdsService _instance = AdsService._internal();
  factory AdsService() => _instance;
  AdsService._internal();

  int _roundCounter = 0;
  bool _isInitialized = false;
  int _interstitialRetryAttempt = 0;
  int _rewardedRetryAttempt = 0;
  static const int _maxRetryCount = 6;

  Future<void> init() async {
    if (_isInitialized || !AdsConfig.adsEnabled) return;
    try {
      final configuration = await AppLovinMAX.initialize(AdsConfig.sdkKey);
      if (configuration != null) {
        _isInitialized = true;
        _initInterstitialListeners();
        _initRewardedListeners();
        _loadInterstitial();
        _loadRewarded();
      }
    } catch (_) {
      // SDK not available — continue without ads
    }
  }

  void _initInterstitialListeners() {
    AppLovinMAX.setInterstitialListener(InterstitialListener(
      onAdLoadedCallback: (ad) {
        _interstitialRetryAttempt = 0;
      },
      onAdLoadFailedCallback: (adUnitId, error) {
        _interstitialRetryAttempt++;
        if (_interstitialRetryAttempt > _maxRetryCount) return;
        int retryDelay = pow(2, min(_maxRetryCount, _interstitialRetryAttempt)).toInt();
        Future.delayed(Duration(seconds: retryDelay), _loadInterstitial);
      },
      onAdDisplayedCallback: (ad) {},
      onAdDisplayFailedCallback: (ad, error) {
        _loadInterstitial();
      },
      onAdClickedCallback: (ad) {},
      onAdHiddenCallback: (ad) {
        _loadInterstitial();
      },
    ));
  }

  void _initRewardedListeners() {
    AppLovinMAX.setRewardedAdListener(RewardedAdListener(
      onAdLoadedCallback: (ad) {
        _rewardedRetryAttempt = 0;
      },
      onAdLoadFailedCallback: (adUnitId, error) {
        _rewardedRetryAttempt++;
        if (_rewardedRetryAttempt > _maxRetryCount) return;
        int retryDelay = pow(2, min(_maxRetryCount, _rewardedRetryAttempt)).toInt();
        Future.delayed(Duration(seconds: retryDelay), _loadRewarded);
      },
      onAdDisplayedCallback: (ad) {},
      onAdDisplayFailedCallback: (ad, error) {
        _loadRewarded();
      },
      onAdClickedCallback: (ad) {},
      onAdHiddenCallback: (ad) {
        _loadRewarded();
      },
      onAdReceivedRewardCallback: (ad, reward) {
        // Reward handled via showRewarded callback
      },
    ));
  }

  void _loadInterstitial() {
    if (!_isInitialized) return;
    AppLovinMAX.loadInterstitial(AdsConfig.interstitialAdUnitId);
  }

  void _loadRewarded() {
    if (!_isInitialized) return;
    AppLovinMAX.loadRewardedAd(AdsConfig.rewardedAdUnitId);
  }

  /// Llamar después de cada ronda. Muestra interstitial si corresponde.
  Future<void> onRoundComplete() async {
    _roundCounter++;
    if (_roundCounter <= AdsConfig.initialFreeRounds) return;

    if ((_roundCounter - AdsConfig.initialFreeRounds) % AdsConfig.roundsBetweenAds == 0) {
      await showInterstitial();
    }
  }

  Future<void> showInterstitial() async {
    if (!_isInitialized) return;
    try {
      final isReady = await AppLovinMAX.isInterstitialReady(AdsConfig.interstitialAdUnitId) ?? false;
      if (isReady) {
        AppLovinMAX.showInterstitial(AdsConfig.interstitialAdUnitId);
      }
    } catch (_) {
      // Ad failed — continue without ad
    }
  }

  Future<void> showRewarded({required Function onComplete}) async {
    if (!_isInitialized) {
      onComplete();
      return;
    }
    try {
      final isReady = await AppLovinMAX.isRewardedAdReady(AdsConfig.rewardedAdUnitId) ?? false;
      if (isReady) {
        // Temporarily override the reward callback
        AppLovinMAX.setRewardedAdListener(RewardedAdListener(
          onAdLoadedCallback: (ad) {
            _rewardedRetryAttempt = 0;
          },
          onAdLoadFailedCallback: (adUnitId, error) {
            _rewardedRetryAttempt++;
            if (_rewardedRetryAttempt > _maxRetryCount) return;
            int retryDelay = pow(2, min(_maxRetryCount, _rewardedRetryAttempt)).toInt();
            Future.delayed(Duration(seconds: retryDelay), _loadRewarded);
          },
          onAdDisplayedCallback: (ad) {},
          onAdDisplayFailedCallback: (ad, error) {
            _loadRewarded();
          },
          onAdClickedCallback: (ad) {},
          onAdHiddenCallback: (ad) {
            _loadRewarded();
          },
          onAdReceivedRewardCallback: (ad, reward) {
            onComplete();
          },
        ));
        AppLovinMAX.showRewardedAd(AdsConfig.rewardedAdUnitId);
      } else {
        onComplete();
      }
    } catch (_) {
      onComplete();
    }
  }
}
