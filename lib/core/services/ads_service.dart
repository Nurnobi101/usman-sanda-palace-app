import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:logger/logger.dart';

import '../config/app_config.dart';
import 'remote_config_service.dart';
import 'consent_service.dart';

final adsServiceProvider = Provider<AdsService>((ref) {
  return AdsService(
    ref.read(remoteConfigServiceProvider),
    ref.read(consentServiceProvider),
  );
});

class AdsService {
  static final Logger _logger = Logger();
  
  final RemoteConfigService _remoteConfig;
  final ConsentService _consentService;
  
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  
  bool _isInitialized = false;
  int _pageNavigationCount = 0;
  DateTime? _lastInterstitialShown;
  
  AdsService(this._remoteConfig, this._consentService);
  
  bool get isInitialized => _isInitialized;
  BannerAd? get bannerAd => _bannerAd;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Wait for consent service to be ready
      if (!_consentService.isInitialized) {
        await _consentService.initialize();
      }
      
      // Only initialize ads if consent allows and ads are enabled
      if (_consentService.canRequestAds && _remoteConfig.adsEnabled) {
        await _loadBannerAd();
        await _loadInterstitialAd();
      }
      
      _isInitialized = true;
      _logger.i('Ads service initialized. Ads enabled: ${_remoteConfig.adsEnabled}');
    } catch (e) {
      _logger.e('Failed to initialize ads service: $e');
      _isInitialized = true; // Mark as initialized even on error
    }
  }
  
  Future<void> _loadBannerAd() async {
    if (!_remoteConfig.bannerAdsEnabled || !_consentService.canRequestAds) {
      return;
    }
    
    try {
      final adUnitId = _getBannerAdUnitId();
      if (adUnitId.isEmpty) return;
      
      _bannerAd = BannerAd(
        adUnitId: adUnitId,
        size: AdSize.banner,
        request: _buildAdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _logger.i('Banner ad loaded successfully');
          },
          onAdFailedToLoad: (ad, error) {
            _logger.w('Banner ad failed to load: $error');
            ad.dispose();
            _bannerAd = null;
          },
          onAdOpened: (ad) {
            _logger.i('Banner ad opened');
          },
          onAdClosed: (ad) {
            _logger.i('Banner ad closed');
          },
        ),
      );
      
      await _bannerAd!.load();
    } catch (e) {
      _logger.e('Error loading banner ad: $e');
      _bannerAd?.dispose();
      _bannerAd = null;
    }
  }
  
  Future<void> _loadInterstitialAd() async {
    if (!_remoteConfig.interstitialAdsEnabled || !_consentService.canRequestAds) {
      return;
    }
    
    try {
      final adUnitId = _getInterstitialAdUnitId();
      if (adUnitId.isEmpty) return;
      
      await InterstitialAd.load(
        adUnitId: adUnitId,
        request: _buildAdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _logger.i('Interstitial ad loaded successfully');
            
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                _logger.i('Interstitial ad showed full screen');
              },
              onAdDismissedFullScreenContent: (ad) {
                _logger.i('Interstitial ad dismissed');
                ad.dispose();
                _interstitialAd = null;
                // Pre-load next interstitial
                _loadInterstitialAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                _logger.w('Interstitial ad failed to show: $error');
                ad.dispose();
                _interstitialAd = null;
              },
            );
          },
          onAdFailedToLoad: (error) {
            _logger.w('Interstitial ad failed to load: $error');
            _interstitialAd = null;
          },
        ),
      );
    } catch (e) {
      _logger.e('Error loading interstitial ad: $e');
    }
  }
  
  AdRequest _buildAdRequest() {
    final extras = _consentService.getAdRequestExtras();
    return AdRequest(extras: extras);
  }
  
  String _getBannerAdUnitId() {
    if (_remoteConfig.adsTestMode || kDebugMode) {
      return Platform.isAndroid 
          ? AppConfig.testBannerAdUnitAndroid
          : AppConfig.testBannerAdUnitIOS;
    }
    
    return Platform.isAndroid 
        ? _remoteConfig.bannerAdUnitAndroid
        : _remoteConfig.bannerAdUnitIOS;
  }
  
  String _getInterstitialAdUnitId() {
    if (_remoteConfig.adsTestMode || kDebugMode) {
      return Platform.isAndroid 
          ? AppConfig.testInterstitialAdUnitAndroid
          : AppConfig.testInterstitialAdUnitIOS;
    }
    
    return Platform.isAndroid 
        ? _remoteConfig.interstitialAdUnitAndroid
        : _remoteConfig.interstitialAdUnitIOS;
  }
  
  void onPageNavigation() {
    _pageNavigationCount++;
    
    // Show interstitial based on frequency
    if (_shouldShowInterstitial()) {
      showInterstitial();
    }
  }
  
  bool _shouldShowInterstitial() {
    if (!_remoteConfig.interstitialAdsEnabled || 
        !_consentService.canRequestAds ||
        _interstitialAd == null) {
      return false;
    }
    
    final frequency = _remoteConfig.interstitialFrequency;
    if (frequency <= 0) return false;
    
    // Check frequency
    if (_pageNavigationCount % frequency != 0) return false;
    
    // Don't show too frequently (minimum 60 seconds between interstitials)
    if (_lastInterstitialShown != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastInterstitialShown!);
      if (timeSinceLastAd.inSeconds < 60) return false;
    }
    
    return true;
  }
  
  Future<void> showInterstitial() async {
    if (_interstitialAd == null) return;
    
    try {
      await _interstitialAd!.show();
      _lastInterstitialShown = DateTime.now();
      _logger.i('Interstitial ad shown');
    } catch (e) {
      _logger.e('Error showing interstitial ad: $e');
    }
  }
  
  Future<void> refreshAds() async {
    _logger.i('Refreshing ads based on new config');
    
    // Dispose existing ads
    _bannerAd?.dispose();
    _bannerAd = null;
    _interstitialAd?.dispose();
    _interstitialAd = null;
    
    // Reload if ads are enabled
    if (_remoteConfig.adsEnabled && _consentService.canRequestAds) {
      await _loadBannerAd();
      await _loadInterstitialAd();
    }
  }
  
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
  }
  
  // Debug info
  Map<String, dynamic> getDebugInfo() {
    return {
      'isInitialized': _isInitialized,
      'adsEnabled': _remoteConfig.adsEnabled,
      'bannerAdsEnabled': _remoteConfig.bannerAdsEnabled,
      'interstitialAdsEnabled': _remoteConfig.interstitialAdsEnabled,
      'testMode': _remoteConfig.adsTestMode,
      'canRequestAds': _consentService.canRequestAds,
      'bannerAdLoaded': _bannerAd != null,
      'interstitialAdLoaded': _interstitialAd != null,
      'pageNavigationCount': _pageNavigationCount,
      'lastInterstitialShown': _lastInterstitialShown?.toIso8601String(),
    };
  }
}
