import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

final consentServiceProvider = Provider<ConsentService>((ref) {
  return ConsentService();
});

enum ConsentStatus {
  unknown,
  required,
  notRequired,
  obtained,
}

class ConsentService {
  static final Logger _logger = Logger();
  
  ConsentStatus _consentStatus = ConsentStatus.unknown;
  bool _isInitialized = false;
  bool _canRequestAds = false;
  
  ConsentStatus get consentStatus => _consentStatus;
  bool get canRequestAds => _canRequestAds;
  bool get isInitialized => _isInitialized;
  
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // For now, we'll assume consent is obtained
      // In a real implementation, you would integrate UMP SDK
      _consentStatus = ConsentStatus.obtained;
      _canRequestAds = true;
      
      _isInitialized = true;
      _logger.i('Consent service initialized. Can request ads: $_canRequestAds');
    } catch (e) {
      _logger.e('Failed to initialize consent service: $e');
      // Fallback: allow ads but without personalization
      _canRequestAds = true;
      _isInitialized = true;
    }
  }
  
  Future<void> resetConsent() async {
    try {
      _consentStatus = ConsentStatus.unknown;
      _canRequestAds = false;
      _isInitialized = false;
      
      // Re-initialize
      await initialize();
      
      _logger.i('Consent reset and re-initialized');
    } catch (e) {
      _logger.e('Failed to reset consent: $e');
    }
  }
  
  Future<void> showPrivacyOptionsForm() async {
    try {
      _logger.i('Privacy options form would be shown here');
      // In a real implementation, show UMP consent form
    } catch (e) {
      _logger.e('Error showing privacy options form: $e');
    }
  }
  
  bool get isPersonalizedAdsAllowed {
    // Check if user has consented to personalized ads
    return _consentStatus == ConsentStatus.obtained || 
           _consentStatus == ConsentStatus.notRequired;
  }
  
  Map<String, String> getAdRequestExtras() {
    final extras = <String, String>{};
    
    // For non-personalized ads when consent is not obtained
    if (!isPersonalizedAdsAllowed) {
      extras['npa'] = '1'; // Non-personalized ads
    }
    
    return extras;
  }
}
