import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/services/ads_service.dart';
import '../../../../core/services/remote_config_service.dart';
import '../../../../shared/constants/app_constants.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/progress_indicator_widget.dart';
import '../widgets/offline_page_widget.dart';
import '../../../about/presentation/pages/about_page.dart';

class WebViewPage extends ConsumerStatefulWidget {
  const WebViewPage({super.key});

  @override
  ConsumerState<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends ConsumerState<WebViewPage> {
  late final WebViewController _webViewController;
  late final StreamSubscription<ConnectivityResult> _connectivitySubscription;
  
  bool _isLoading = true;
  bool _isOffline = false;
  double _loadingProgress = 0.0;
  bool _canGoBack = false;
  
  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _setupConnectivityListener();
  }
  
  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }
  
  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(_createNavigationDelegate())
      ..addJavaScriptChannel(
        'NativeApp',
        onMessageReceived: _handleJavaScriptMessage,
      )
      ..loadRequest(Uri.parse(AppConfig.primaryUrl));
    
    // Inject JavaScript bridge
    _injectJavaScriptBridge();
  }
  
  NavigationDelegate _createNavigationDelegate() {
    return NavigationDelegate(
      onPageStarted: (url) {
        setState(() {
          _isLoading = true;
          _loadingProgress = 0.0;
        });
      },
      onProgress: (progress) {
        setState(() {
          _loadingProgress = progress / 100.0;
        });
      },
      onPageFinished: (url) async {
        setState(() {
          _isLoading = false;
          _loadingProgress = 1.0;
        });
        
        // Update back button state
        final canGoBack = await _webViewController.canGoBack();
        setState(() {
          _canGoBack = canGoBack;
        });
        
        // Notify ads service of navigation
        ref.read(adsServiceProvider).onPageNavigation();
        
        // Re-inject JavaScript bridge on page change
        _injectJavaScriptBridge();
      },
      onNavigationRequest: (request) {
        return _handleNavigationRequest(request);
      },
      onWebResourceError: (error) {
        debugPrint('WebView error: ${error.description}');
        _handleWebViewError();
      },
    );
  }
  
  NavigationDecision _handleNavigationRequest(NavigationRequest request) {
    final url = request.url.toLowerCase();
    
    // Check for external link patterns
    for (final pattern in AppConfig.externalLinkPatterns) {
      if (RegExp(pattern).hasMatch(url)) {
        _launchExternalUrl(request.url);
        return NavigationDecision.prevent;
      }
    }
    
    // Check if URL is from allowed domains
    final uri = Uri.tryParse(request.url);
    if (uri != null && !_isAllowedDomain(uri.host)) {
      _launchExternalUrl(request.url);
      return NavigationDecision.prevent;
    }
    
    return NavigationDecision.navigate;
  }
  
  bool _isAllowedDomain(String host) {
    for (final domain in AppConfig.allowedDomains) {
      if (host == domain || host.endsWith('.$domain')) {
        return true;
      }
    }
    return false;
  }
  
  Future<void> _launchExternalUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      debugPrint('Failed to launch URL: $url, Error: $e');
    }
  }
  
  void _setupConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (connectivity) {
        final isConnected = connectivity != ConnectivityResult.none;
        
        if (isConnected && _isOffline) {
          // Reconnected - reload the page
          _reloadPage();
        }
        
        setState(() {
          _isOffline = !isConnected;
        });
      },
    );
  }
  
  void _handleWebViewError() {
    setState(() {
      _isOffline = true;
    });
  }
  
  Future<void> _reloadPage() async {
    setState(() {
      _isLoading = true;
      _isOffline = false;
    });
    
    try {
      await _webViewController.reload();
    } catch (e) {
      debugPrint('Failed to reload page: $e');
      setState(() {
        _isOffline = true;
        _isLoading = false;
      });
    }
  }
  
  Future<void> _handleJavaScriptMessage(JavaScriptMessage message) async {
    try {
      // Handle messages from website's JavaScript
      final data = message.message;
      debugPrint('Received JS message: $data');
      
      // Example: Handle custom actions
      if (data.startsWith('openMaps:')) {
        final location = data.substring(9);
        _launchExternalUrl('maps:$location');
      } else if (data.startsWith('share:')) {
        // Handle share functionality
        debugPrint('Share request: ${data.substring(6)}');
      }
    } catch (e) {
      debugPrint('Error handling JS message: $e');
    }
  }
  
  void _injectJavaScriptBridge() {
    // Inject JavaScript bridge for website communication
    const jsCode = '''
      window.NativeApp = {
        openMaps: function(location) {
          NativeApp.postMessage('openMaps:' + location);
        },
        share: function(content) {
          NativeApp.postMessage('share:' + content);
        },
        call: function(number) {
          NativeApp.postMessage('call:' + number);
        }
      };
    ''';
    
    _webViewController.runJavaScript(jsCode);
  }
  
  Future<bool> _handleBackPress() async {
    if (_canGoBack) {
      await _webViewController.goBack();
      return false; // Don't exit app
    }
    
    // On Android, show exit confirmation
    if (Platform.isAndroid) {
      return await _showExitConfirmation();
    }
    
    return false; // Don't exit on iOS
  }
  
  Future<bool> _showExitConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Do you want to exit the app?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Exit'),
          ),
        ],
      ),
    ) ?? false;
  }
  
  @override
  Widget build(BuildContext context) {
    final remoteConfig = ref.watch(remoteConfigServiceProvider);
    final bannerPlacement = remoteConfig.bannerPlacement;
    final showBannerAd = remoteConfig.adsEnabled && remoteConfig.bannerAdsEnabled;
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _handleBackPress();
          if (shouldPop && context.mounted) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppConstants.appName),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reloadPage,
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'about':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutPage(),
                      ),
                    );
                    break;
                  case 'refresh_config':
                    ref.read(remoteConfigServiceProvider).refresh();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'about',
                  child: Text('About'),
                ),
                const PopupMenuItem(
                  value: 'refresh_config',
                  child: Text('Refresh Config'),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            if (_isLoading)
              ProgressIndicatorWidget(progress: _loadingProgress),
            
            if (showBannerAd && bannerPlacement == 'top')
              const BannerAdWidget(),
            
            Expanded(
              child: _isOffline
                  ? OfflinePageWidget(onRetry: _reloadPage)
                  : WebViewWidget(controller: _webViewController),
            ),
            
            if (showBannerAd && bannerPlacement == 'bottom')
              const BannerAdWidget(),
          ],
        ),
      ),
    );
  }
}
