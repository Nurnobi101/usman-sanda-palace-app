import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../shared/constants/app_constants.dart';

class OfflinePageWidget extends StatelessWidget {
  final VoidCallback onRetry;
  
  const OfflinePageWidget({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final webViewController = WebViewController()
      ..loadHtmlString(AppConstants.offlineHtml);
    
    return Stack(
      children: [
        WebViewWidget(controller: webViewController),
        Positioned(
          bottom: 80,
          left: 20,
          right: 20,
          child: ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
