import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../../core/services/ads_service.dart';
import '../../../../shared/constants/app_constants.dart';

class BannerAdWidget extends ConsumerWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adsService = ref.watch(adsServiceProvider);
    final bannerAd = adsService.bannerAd;
    
    if (bannerAd == null) {
      // Return empty container if no ad is loaded
      return const SizedBox.shrink();
    }
    
    return Container(
      width: double.infinity,
      height: AppConstants.bannerAdHeight,
      color: Theme.of(context).colorScheme.surface,
      child: AdWidget(ad: bannerAd),
    );
  }
}
