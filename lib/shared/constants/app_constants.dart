class AppConstants {
  // App Info
  static const String appName = 'Usman Sanda Palace';
  static const String appVersion = '1.0.0';
  static const String legalNotice = '© Usman Sanda Palace. All Rights Reserved. Developed by Compilemama.';
  
  // URLs
  static const String primaryUrl = 'https://usmansandapalace.com/';
  static const String privacyPolicyUrl = 'https://usmansandapalace.com/privacy-policy';
  static const String termsOfServiceUrl = 'https://usmansandapalace.com/terms-of-service';
  
  // Timeouts and Delays
  static const Duration networkTimeout = Duration(seconds: 30);
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration retryDelay = Duration(seconds: 3);
  static const Duration configCacheExpiry = Duration(hours: 1);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const double bannerAdHeight = 50.0;
  
  // Error Messages
  static const String networkErrorMessage = 'Please check your internet connection and try again.';
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String pageLoadErrorMessage = 'Failed to load page. Please check your connection.';
  
  // Offline Content
  static const String offlineHtml = '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>You're Offline</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
            background-color: #f8fafc;
            color: #334155;
            text-align: center;
            padding: 20px;
        }
        .offline-icon {
            font-size: 64px;
            margin-bottom: 20px;
            opacity: 0.6;
        }
        h1 {
            font-size: 24px;
            margin-bottom: 10px;
            color: #1e293b;
        }
        p {
            font-size: 16px;
            margin-bottom: 30px;
            opacity: 0.8;
            max-width: 400px;
            line-height: 1.5;
        }
        .retry-button {
            background-color: #3b82f6;
            color: white;
            border: none;
            padding: 12px 24px;
            border-radius: 8px;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.2s;
        }
        .retry-button:hover {
            background-color: #2563eb;
        }
        .app-name {
            margin-top: 40px;
            font-size: 14px;
            opacity: 0.6;
        }
    </style>
</head>
<body>
    <div class="offline-icon">📡</div>
    <h1>You're Offline</h1>
    <p>Please check your internet connection and try again. We'll automatically retry when your connection is restored.</p>
    <button class="retry-button" onclick="window.location.reload()">Try Again</button>
    <div class="app-name">Usman Sanda Palace</div>
</body>
</html>
  ''';
}
