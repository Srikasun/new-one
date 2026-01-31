import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/themes/app_colors.dart';
import '../../bloc/ad/ad_bloc.dart';
import '../../bloc/purchase/purchase_bloc.dart';

/// Full-screen paywall widget
class PaywallScreen extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final bool showCloseButton;

  const PaywallScreen({
    super.key,
    this.title,
    this.subtitle,
    this.showCloseButton = true,
  });

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
        builder: (context, state) {
          final isLoading = state is PurchaseLoading ||
              state is PurchaseInProgress ||
              state is RestoreInProgress;

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  // Header
                  SliverAppBar(
                    expandedHeight: 220,
                    pinned: true,
                    automaticallyImplyLeading: false,
                    backgroundColor: AppColors.accent,
                    actions: showCloseButton
                        ? [
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => context.go(RouteNames.home),
                            ),
                          ]
                        : null,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [AppColors.accent, AppColors.accentDark],
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            const Icon(
                              Icons.auto_awesome,
                              size: 64,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              title ?? 'Upgrade to Premium',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            if (subtitle != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                subtitle!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Feature comparison
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
                          const SizedBox(height: 16),

                          // Terms
                          Text(
                            'One-time purchase. No subscription. Unlock all features forever.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.neutral500,
                                ),
                            textAlign: TextAlign.center,
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
                              state is RestoreInProgress
                                  ? 'Restoring purchases...'
                                  : 'Processing...',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFeatureComparison(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What You Get',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            _FeatureRow(
              feature: 'Book Library',
              freeValue: '${PurchaseConstants.freeUserBookLimit} books',
              premiumValue: 'Unlimited',
              isPremiumHighlighted: true,
            ),
            const Divider(),
            const _FeatureRow(
              feature: 'Advertisements',
              freeValue: 'With ads',
              premiumValue: 'No ads',
              isPremiumHighlighted: true,
            ),
            const Divider(),
            const _FeatureRow(
              feature: 'Export Data',
              freeValue: '✗',
              premiumValue: '✓',
              isPremiumHighlighted: true,
            ),
            const Divider(),
            const _FeatureRow(
              feature: 'Custom Themes',
              freeValue: '✗',
              premiumValue: '✓',
              isPremiumHighlighted: true,
            ),
            const Divider(),
            const _FeatureRow(
              feature: 'Reading Statistics',
              freeValue: 'Basic',
              premiumValue: 'Advanced',
              isPremiumHighlighted: true,
            ),
            const Divider(),
            const _FeatureRow(
              feature: 'Cloud Backup',
              freeValue: '✗',
              premiumValue: '✓',
              isPremiumHighlighted: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseButton(BuildContext context, bool isLoading) {
    return ElevatedButton(
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
            'Unlock Premium',
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
    );
  }

  Widget _buildWatchAdButton(BuildContext context) {
    return BlocBuilder<AdBloc, AdState>(
      builder: (context, adState) {
        final isAdReady = adState is RewardedAdReady;

        return OutlinedButton.icon(
          onPressed: isAdReady
              ? () {
                  context.read<AdBloc>().add(const ShowRewardedAd());
                }
              : null,
          icon: const Icon(Icons.play_circle_outline),
          label: Text(
            isAdReady
                ? 'Watch Ad for 24h Free Premium'
                : 'Loading Ad...',
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}

/// Feature comparison row widget
class _FeatureRow extends StatelessWidget {
  final String feature;
  final String freeValue;
  final String premiumValue;
  final bool isPremiumHighlighted;

  const _FeatureRow({
    required this.feature,
    required this.freeValue,
    required this.premiumValue,
    this.isPremiumHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              freeValue,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.neutral500,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              premiumValue,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isPremiumHighlighted ? AppColors.accent : null,
                    fontWeight:
                        isPremiumHighlighted ? FontWeight.bold : null,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Book limit reached dialog
class BookLimitDialog extends StatelessWidget {
  final int currentCount;
  final int maxBooks;

  const BookLimitDialog({
    super.key,
    required this.currentCount,
    required this.maxBooks,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_amber, color: AppColors.accent),
          SizedBox(width: 8),
          Text('Book Limit Reached'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You\'ve reached the free tier limit of $maxBooks books.',
          ),
          const SizedBox(height: 16),
          Text(
            'Upgrade to Premium to add unlimited books and unlock all features.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Maybe Later'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            context.go(RouteNames.premium);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
          ),
          child: const Text('Upgrade'),
        ),
      ],
    );
  }
}

/// Small upgrade prompt banner
class UpgradePromptBanner extends StatelessWidget {
  const UpgradePromptBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accent.withOpacity(0.8), AppColors.accentDark],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upgrade to Premium',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Text(
                  'Remove ads & unlock all features',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => context.go(RouteNames.premium),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }
}
