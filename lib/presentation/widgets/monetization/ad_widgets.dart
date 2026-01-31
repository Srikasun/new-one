import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/themes/app_colors.dart';
import '../../bloc/ad/ad_bloc.dart';

/// Widget that displays a banner ad at the bottom of the screen
/// Automatically hides for premium users
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  @override
  void initState() {
    super.initState();
    // Load banner ad when widget is created
    context.read<AdBloc>().add(const LoadBannerAd());
  }

  @override
  void dispose() {
    // Dispose banner when widget is removed
    context.read<AdBloc>().add(const DisposeBannerAd());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdBloc, AdState>(
      builder: (context, state) {
        // Hide for premium users
        if (state is AdsHidden) {
          return const SizedBox.shrink();
        }

        // Show banner when ready
        if (state is BannerAdReady && state.bannerAd != null) {
          final bannerAd = state.bannerAd as BannerAd;
          return Container(
            alignment: Alignment.center,
            width: bannerAd.size.width.toDouble(),
            height: bannerAd.size.height.toDouble(),
            child: AdWidget(ad: bannerAd),
          );
        }

        // Loading placeholder
        if (state is AdLoading) {
          return Container(
            height: 50,
            color: AppColors.neutral100,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        // Error or not loaded - show nothing
        return const SizedBox.shrink();
      },
    );
  }
}

/// Wrapper widget that conditionally shows content with a banner ad
class AdSupportedScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool showBannerAd;

  const AdSupportedScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.floatingActionButtonLocation,
    this.showBannerAd = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      body: Column(
        children: [
          Expanded(child: body),
          if (showBannerAd) const BannerAdWidget(),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

/// Premium badge widget to indicate premium-only features
class PremiumBadge extends StatelessWidget {
  final double size;

  const PremiumBadge({super.key, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(size * 0.25),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Icon(
        Icons.star,
        color: Colors.white,
        size: size,
      ),
    );
  }
}

/// Widget that shows a lock icon for premium features
class PremiumLockOverlay extends StatelessWidget {
  final Widget child;
  final bool isPremium;
  final VoidCallback? onTap;

  const PremiumLockOverlay({
    super.key,
    required this.child,
    required this.isPremium,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isPremium) {
      return child;
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Opacity(
            opacity: 0.5,
            child: child,
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.1),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock,
                      color: AppColors.accent,
                      size: 32,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Premium',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Temporary premium indicator widget
class TemporaryPremiumBanner extends StatelessWidget {
  final DateTime expiresAt;

  const TemporaryPremiumBanner({super.key, required this.expiresAt});

  @override
  Widget build(BuildContext context) {
    final remaining = expiresAt.difference(DateTime.now());
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accent, AppColors.accentDark],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Icon(Icons.star, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Premium access active for ${hours}h ${minutes}m',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
