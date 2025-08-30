import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../config/app_config.dart';

final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService();
});

class RemoteConfigService {
  static final Logger _logger = Logger();
  late final FirebaseRemoteConfig _remoteConfig;
  
  bool _isInitialized = false;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _remoteConfig = FirebaseRemoteConfig.instance;
      
      // Set config settings
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: AppConfig.isDevelopment 
              ? const Duration(seconds: 30)  // Short interval for development
              : const Duration(hours: 1),    // Longer interval for production
        ),
      );
      
      // Set default values
      await _remoteConfig.setDefaults(AppConfig.remoteConfigDefaults);
      
      // Fetch and activate
      await _fetchAndActivate();
      
      _isInitialized = true;
      _logger.i('Remote Config initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize Remote Config: $e');
      // Continue with defaults if remote config fails
      _isInitialized = true;
    }
  }
  
  Future<bool> _fetchAndActivate() async {
    try {
      final fetched = await _remoteConfig.fetchAndActivate();
      if (fetched) {
        _logger.i('Remote Config updated with new values');
      } else {
        _logger.i('Remote Config using cached values');
      }
      return fetched;
    } catch (e) {
      _logger.e('Failed to fetch Remote Config: $e');
      return false;
    }
  }
  
  Future<void> refresh() async {
    if (!_isInitialized) return;
    await _fetchAndActivate();
  }
  
  // Ad Configuration
  bool get adsEnabled => _getBool('ads.enabled');
  bool get adsTestMode => _getBool('ads.testMode');
  
  // Banner Ads
  bool get bannerAdsEnabled => _getBool('ads.banner.enabled');
  String get bannerPlacement => _getString('ads.banner.placement');
  String get bannerAdUnitAndroid => _getString('ads.banner.adUnitId.android');
  String get bannerAdUnitIOS => _getString('ads.banner.adUnitId.ios');
  
  // Interstitial Ads
  bool get interstitialAdsEnabled => _getBool('ads.interstitial.enabled');
  int get interstitialFrequency => _getInt('ads.interstitial.frequency');
  String get interstitialAdUnitAndroid => _getString('ads.interstitial.adUnitId.android');
  String get interstitialAdUnitIOS => _getString('ads.interstitial.adUnitId.ios');
  
  // Config Version
  int get configVersion => _getInt('config.version');
  
  // Helper methods
  bool _getBool(String key) {
    try {
      return _remoteConfig.getBool(key);
    } catch (e) {
      _logger.w('Failed to get bool for key $key: $e');
      return AppConfig.remoteConfigDefaults[key] as bool? ?? false;
    }
  }
  
  String _getString(String key) {
    try {
      return _remoteConfig.getString(key);
    } catch (e) {
      _logger.w('Failed to get string for key $key: $e');
      return AppConfig.remoteConfigDefaults[key] as String? ?? '';
    }
  }
  
  int _getInt(String key) {
    try {
      return _remoteConfig.getInt(key);
    } catch (e) {
      _logger.w('Failed to get int for key $key: $e');
      return AppConfig.remoteConfigDefaults[key] as int? ?? 0;
    }
  }
  
  // Get all config as Map for debugging
  Map<String, dynamic> getAllConfig() {
    if (!_isInitialized) return AppConfig.remoteConfigDefaults;
    
    final config = <String, dynamic>{};
    for (final key in _remoteConfig.getAll().keys) {
      final value = _remoteConfig.getValue(key);
      switch (value.source) {
        case ValueSource.valueStatic:
        case ValueSource.valueDefault:
        case ValueSource.valueRemote:
          config[key] = value.asString();
          break;
      }
    }
    return config;
  }
}
