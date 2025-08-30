import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/services/remote_config_service.dart';
import '../../../../core/services/ads_service.dart';
import '../../../../core/services/consent_service.dart';
import '../../../../shared/constants/app_constants.dart';

class AboutPage extends ConsumerStatefulWidget {
  const AboutPage({super.key});

  @override
  ConsumerState<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends ConsumerState<AboutPage> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = packageInfo;
    });
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo and Name
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: colorScheme.primary,
                    ),
                    child: Icon(
                      Icons.web,
                      size: 60,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppConstants.appName,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version ${_packageInfo?.version ?? 'Unknown'}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Legal Notice
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Legal Notice',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppConstants.legalNotice,
                      style: textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Links Section
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.privacy_tip, color: colorScheme.primary),
                    title: const Text('Privacy Policy'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _launchUrl(AppConstants.privacyPolicyUrl),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.description, color: colorScheme.primary),
                    title: const Text('Terms of Service'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _launchUrl(AppConstants.termsOfServiceUrl),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.language, color: colorScheme.primary),
                    title: const Text('Visit Website'),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () => _launchUrl(AppConfig.primaryUrl),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Privacy Controls
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.ads_click, color: colorScheme.primary),
                    title: const Text('Ad Preferences'),
                    subtitle: const Text('Manage your ad consent'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      ref.read(consentServiceProvider).showPrivacyOptionsForm();
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.refresh, color: colorScheme.primary),
                    title: const Text('Refresh Settings'),
                    subtitle: const Text('Update app configuration'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () async {
                      await ref.read(remoteConfigServiceProvider).refresh();
                      await ref.read(adsServiceProvider).refreshAds();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Settings refreshed'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Debug Information (only in development)
            if (AppConfig.isDevelopment) ...[
              Card(
                child: ExpansionTile(
                  leading: Icon(Icons.bug_report, color: colorScheme.primary),
                  title: const Text('Debug Information'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDebugInfo(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Footer
            Center(
              child: Text(
                'Made with ❤️ for Usman Sanda Palace',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDebugInfo() {
    final remoteConfig = ref.read(remoteConfigServiceProvider);
    final adsService = ref.read(adsServiceProvider);
    final consentService = ref.read(consentServiceProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Environment: ${AppConfig.isDevelopment ? 'Development' : 'Production'}'),
        Text('Package: ${_packageInfo?.packageName ?? 'Unknown'}'),
        Text('Build: ${_packageInfo?.buildNumber ?? 'Unknown'}'),
        const SizedBox(height: 8),
        const Text('Remote Config:', style: TextStyle(fontWeight: FontWeight.bold)),
        ...remoteConfig.getAllConfig().entries.map(
          (entry) => Text('${entry.key}: ${entry.value}'),
        ),
        const SizedBox(height: 8),
        const Text('Ads Service:', style: TextStyle(fontWeight: FontWeight.bold)),
        ...adsService.getDebugInfo().entries.map(
          (entry) => Text('${entry.key}: ${entry.value}'),
        ),
        const SizedBox(height: 8),
        const Text('Consent:', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('Status: ${consentService.consentStatus}'),
        Text('Can Request Ads: ${consentService.canRequestAds}'),
        Text('Personalized Ads: ${consentService.isPersonalizedAdsAllowed}'),
      ],
    );
  }
}
