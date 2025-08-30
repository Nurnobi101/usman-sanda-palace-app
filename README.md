# 🏰 Usman Sanda Palace Mobile App

A professional Flutter WebView application for Android and iOS with AdMob monetization and Firebase integration.

## 📱 Features

- 🌐 **WebView Integration** - Seamless loading of https://usmansandapalace.com
- 💰 **AdMob Monetization** - Banner and interstitial ads with remote control
- 🔥 **Firebase Integration** - Analytics, Remote Config, and real-time updates
- ⚙️ **Admin Dashboard** - Remote configuration management
- 📱 **Cross-Platform** - Works on Android and iOS
- 🚀 **Auto-Build** - GitHub Actions for automatic APK generation

## 🔧 Technical Stack

- **Flutter 3.24.3** with null safety
- **Firebase Core** for backend services
- **Google Mobile Ads** for monetization
- **WebView Flutter** for web content
- **Riverpod** for state management
- **Connectivity Plus** for network detection

## 🚀 Quick Start

This app is ready to build! Choose your preferred method:

### 📱 Android APK
1. **GitHub Actions** (Recommended) - Automatic builds on every commit
2. **Local Build** - Requires Android Studio installation
3. **Online Services** - Use Codemagic.io or App Center

### 🍎 iOS App
1. **Xcode** - Requires macOS and Xcode installation
2. **Online Services** - Use Codemagic.io for cloud builds

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── core/
│   ├── config/
│   │   ├── app_config.dart     # Environment configuration
│   │   └── firebase_options.dart
│   └── services/
│       ├── ads_service.dart     # AdMob integration
│       ├── consent_service.dart # GDPR compliance
│       └── remote_config_service.dart
├── features/
│   ├── webview/
│   │   ├── pages/
│   │   │   └── webview_page.dart
│   │   └── widgets/
│   │       ├── banner_ad_widget.dart
│   │       ├── offline_page_widget.dart
│   │       └── progress_indicator_widget.dart
│   └── about/
│       └── pages/
│           └── about_page.dart
└── shared/
    ├── constants/
    │   └── app_constants.dart
    └── theme/
        └── app_theme.dart
```

## 🔧 Configuration

### Firebase Setup
1. Add your `google-services.json` to `android/app/`
2. Add your `GoogleService-Info.plist` to `ios/Runner/`
3. Configure Firebase project in console

### AdMob Setup
1. Replace `ca-app-pub-3940256099942544~3347511713` with your AdMob App ID
2. Update banner and interstitial ad unit IDs
3. Configure ad frequency via Firebase Remote Config

## 🚀 Building

### Android
```bash
flutter build apk --release --flavor production
```

### iOS
```bash
flutter build ios --release --flavor production
```

## 📊 Analytics

The app includes comprehensive analytics:
- Screen views and user interactions
- Ad performance metrics
- Crash reporting
- Custom events for business insights

## 🎯 Monetization

AdMob integration includes:
- **Banner Ads** - Non-intrusive bottom banners
- **Interstitial Ads** - Full-screen ads at natural breaks
- **Remote Control** - Enable/disable ads via Firebase
- **GDPR Compliance** - UMP consent management

## 🔒 Privacy

- GDPR compliant with UMP consent forms
- Privacy policy integration
- Data protection measures
- User consent management

## 📱 Supported Platforms

- **Android** 5.0+ (API level 21+)
- **iOS** 11.0+
- **Web** (Progressive Web App)

## 🏗️ Architecture

Built with clean architecture principles:
- **Separation of Concerns** - Clear layer separation
- **Dependency Injection** - Using Riverpod
- **State Management** - Reactive programming
- **Error Handling** - Comprehensive error management

## 🚀 Deployment

### Google Play Store
1. Build signed AAB: `flutter build appbundle --release`
2. Upload to Google Play Console
3. Configure store listing and pricing

### App Store
1. Build iOS archive in Xcode
2. Upload to App Store Connect
3. Configure app metadata and submit for review

## 📈 Performance

Optimized for performance:
- Lazy loading of web content
- Efficient memory management
- Minimal app size
- Fast startup times

## 🔧 Maintenance

The app includes:
- Remote configuration capabilities
- Over-the-air updates for web content
- Analytics for monitoring performance
- Crash reporting for quick issue resolution

## 📞 Support

For support and updates:
- Repository: https://github.com/Nurnobi101/usman-sanda-palace-app
- Website: https://usmansandapalace.com
- Issues: GitHub Issues tracker

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Built with ❤️ for Usman Sanda Palace**
