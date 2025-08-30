import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/config/app_config.dart';
import 'core/config/firebase_options.dart';
import 'core/services/remote_config_service.dart';
import 'core/services/ads_service.dart';
import 'core/services/consent_service.dart';
import 'shared/constants/app_constants.dart';
import 'shared/theme/app_theme.dart';
import 'features/webview/presentation/pages/webview_page.dart';

void main() async {
  await _initializeApp();
  runApp(
    ProviderScope(
      child: UsmanSandaPalaceApp(),
    ),
  );
}

Future<void> _initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: AppConfig.envFileName);
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Mobile Ads SDK
  await MobileAds.instance.initialize();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Configure system UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
}

class UsmanSandaPalaceApp extends ConsumerStatefulWidget {
  @override
  ConsumerState<UsmanSandaPalaceApp> createState() => _UsmanSandaPalaceAppState();
}

class _UsmanSandaPalaceAppState extends ConsumerState<UsmanSandaPalaceApp> {
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize consent management
      await ref.read(consentServiceProvider).initialize();
      
      // Initialize remote config
      await ref.read(remoteConfigServiceProvider).initialize();
      
      // Initialize ads service
      await ref.read(adsServiceProvider).initialize();
    } catch (e) {
      debugPrint('Error initializing services: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const WebViewPage(),
    );
  }
}
