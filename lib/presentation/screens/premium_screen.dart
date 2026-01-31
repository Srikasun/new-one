import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/themes/app_colors.dart';
import '../bloc/ad/ad_bloc.dart';
import '../bloc/purchase/purchase_bloc.dart';

/// Premium upgrade screen with full monetization features
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  @override
  void initState() {
    super.initState();
    // Load rewarded ad
    context.read<AdBloc>().add(const LoadRewardedAd());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<PurchaseBloc, PurchaseState>(
        listener: (context, state) {
          if (state is PurchaseSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            context.go(RouteNames.home);
          } else if (state is PurchaseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is PurchaseCanceled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Purchase canceled'),
              ),
            );
          } else if (state is PurchasesRestored) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.isPremium
                      ? 'Premium restored successfully!'
                      : 'No previous purchases found.',
                ),
                backgroundColor:
                    state.isPremium ? AppColors.success : AppColors.info,
              ),
            );
            if (state.isPremium) {
              context.go(RouteNames.home);
            }
          }
        },
        builder: (context, purchaseState) {
          return BlocListener<AdBloc, AdState>(
            listener: (context, adState) {
              if (adState is TemporaryPremiumGranted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Premium unlocked for 24 hours!'),
                    backgroundColor: AppColors.success,
                  ),
                );
                context.go(RouteNames.home);
              } else if (adState is RewardReceived) {
                // Reward is handled by TemporaryPremiumGranted
              }
            },
            child: _buildContent(context, purchaseState),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, PurchaseState purchaseState) {
    final isLoading = purchaseState is PurchaseLoading ||
        purchaseState is PurchaseInProgress ||
        purchaseState is RestoreInProgress;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: AppColors.accent,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('DreamShelf Premium'),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.accent,
                        AppColors.accentDark,
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.star,
                      size: 80,
                      color: Colors.white24,
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Benefits
                    Text(
                      'Unlock Premium Features',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 24),
                    _FeatureItem(
                      icon: Icons.all_inclusive,
                      title: 'Unlimited Books',
                      description: 'Add as many books as you want (Free: ${PurchaseConstants.freeUserBookLimit})',
                    ),
                    _FeatureItem(
                      icon: Icons.block,
                      title: 'Ad-Free Experience',
                      description: 'Enjoy reading without interruptions',
                    ),
                    _FeatureItem(
                      icon: Icons.cloud_sync,
                      title: 'Cloud Backup & Sync',
                      description: 'Access your library on multiple devices',
                    ),
                    _FeatureItem(
                      icon: Icons.analytics,
                      title: 'Advanced Statistics',
                      description: 'Detailed insights into your reading habits',
                    ),
                    _FeatureItem(
                      icon: Icons.flag,
                      title: 'Unlimited Goals',
                      description: 'Set and track unlimited reading goals',
                    ),
                    _FeatureItem(
                      icon: Icons.palette,
                      title: 'Custom Themes',
                      description: 'Personalize your app appearance',
                    ),
                    _FeatureItem(
                      icon: Icons.download,
                      title: 'Export & Import',
                      description: 'Backup and restore your data anytime',
                    ),
                    const SizedBox(height: 32),

                    // Feature comparison table
                    _buildFeatureComparison(context),
                    const SizedBox(height: 32),

                    // Main purchase button
                    _buildPurchaseButton(context, isLoading),
                    const SizedBox(height: 16),

                    // Watch ad button
                    _buildWatchAdButton(context),
                    const SizedBox(height: 24),

                    // Restore purchases
                    Center(
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                context
                                    .read<PurchaseBloc>()
                                    .add(const RestorePurchases());
                              },
                        child: const Text('Restore Purchases'),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Terms
                    Text(
                      'One-time purchase. No subscription needed. '
                      'All purchases are processed securely through the app store.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.neutral500,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            // Terms of Service
                          },
                          child: const Text('Terms of Service'),
                        ),
                        const Text(' • '),
                        TextButton(
                          onPressed: () {
                            // Privacy Policy
                          },
                          child: const Text('Privacy Policy'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Loading overlay
        if (isLoading)
          Container(
            color: Colors.black54,
            child: Center(
              child: Card(
                margin: const EdgeInsets.all(32),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        purchaseState is RestoreInProgress
                            ? 'Restoring purchases...'
                            : 'Processing purchase...',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFeatureComparison(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Free vs Premium',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: AppColors.neutral100,
                  ),
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Feature', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Free', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text('Premium', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent), textAlign: TextAlign.center),
                    ),
                  ],
                ),
                _buildComparisonRow('Books', '${PurchaseConstants.freeUserBookLimit}', '∞'),
                _buildComparisonRow('Ads', '✓', '✗'),
                _buildComparisonRow('Export', '✗', '✓'),
                _buildComparisonRow('Themes', '1', 'All'),
                _buildComparisonRow('Stats', 'Basic', 'Full'),
                _buildComparisonRow('Backup', '✗', '✓'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildComparisonRow(String feature, String free, String premium) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(feature),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(free, textAlign: TextAlign.center, style: TextStyle(color: AppColors.neutral500)),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(premium, textAlign: TextAlign.center, style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildPurchaseButton(BuildContext context, bool isLoading) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                context.read<PurchaseBloc>().add(
                      const BuyProduct(PurchaseConstants.premiumOneTimeId),
                    );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          children: [
            Text(
              'Unlock Premium Forever',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${PurchaseConstants.premiumOneTimePrice} • One-time purchase',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchAdButton(BuildContext context) {
    return BlocBuilder<AdBloc, AdState>(
      builder: (context, adState) {
        final isAdReady = adState is RewardedAdReady;
        final isAdLoading = adState is AdLoading;

        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isAdReady
                ? () {
                    context.read<AdBloc>().add(const ShowRewardedAd());
                  }
                : isAdLoading
                    ? null
                    : () {
                        // Try to load ad again
                        context.read<AdBloc>().add(const LoadRewardedAd());
                      },
            icon: Icon(
              isAdReading ? Icons.play_circle_outline : Icons.refresh,
            ),
            label: Text(
              isAdReady
                  ? 'Watch Ad for 24h Free Premium'
                  : isAdLoading
                      ? 'Loading Ad...'
                      : 'Load Ad',
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }
  
  bool get isAdReading => false;
}

/// Feature item widget
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.accent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.neutral600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
