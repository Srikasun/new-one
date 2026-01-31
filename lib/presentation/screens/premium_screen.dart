import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/themes/app_colors.dart';

/// Premium upgrade screen
class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
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

                  // Pricing
                  Text(
                    'Choose Your Plan',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _PricingCard(
                    title: 'Monthly',
                    price: '\$2.99',
                    period: '/month',
                    isPopular: false,
                    onTap: () => _subscribe(context, 'monthly'),
                  ),
                  const SizedBox(height: 12),
                  _PricingCard(
                    title: 'Yearly',
                    price: '\$19.99',
                    period: '/year',
                    savings: 'Save 44%',
                    isPopular: true,
                    onTap: () => _subscribe(context, 'yearly'),
                  ),
                  const SizedBox(height: 12),
                  _PricingCard(
                    title: 'Lifetime',
                    price: '\$49.99',
                    period: 'one-time',
                    savings: 'Best Value',
                    isPopular: false,
                    onTap: () => _subscribe(context, 'lifetime'),
                  ),
                  const SizedBox(height: 24),

                  // Terms
                  Text(
                    'Subscription will be charged to your payment method. '
                    'Subscription automatically renews unless auto-renew is turned off '
                    'at least 24-hours before the end of the current period.',
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
                  TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Restoring purchases...')),
                      );
                    },
                    child: const Text('Restore Purchases'),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _subscribe(BuildContext context, String plan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Starting $plan subscription...')),
    );
  }
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

/// Pricing card widget
class _PricingCard extends StatelessWidget {
  final String title;
  final String price;
  final String period;
  final String? savings;
  final bool isPopular;
  final VoidCallback onTap;

  const _PricingCard({
    required this.title,
    required this.price,
    required this.period,
    this.savings,
    required this.isPopular,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: isPopular ? AppColors.accent : AppColors.neutral300,
            width: isPopular ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isPopular ? AppColors.accent.withOpacity(0.05) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'POPULAR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (savings != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      savings!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
                Text(
                  period,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral500,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
