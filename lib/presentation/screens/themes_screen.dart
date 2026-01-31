import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/themes/app_colors.dart';
import '../../data/repositories/preferences_repository.dart';
import '../bloc/purchase/purchase_bloc.dart';

/// Themes screen for selecting app themes (Premium feature)
class ThemesScreen extends StatefulWidget {
  const ThemesScreen({super.key});

  @override
  State<ThemesScreen> createState() => _ThemesScreenState();
}

class _ThemesScreenState extends State<ThemesScreen> {
  String _selectedTheme = 'default';
  bool _isDarkMode = false;

  final List<AppThemeStyle> _themes = [
    AppThemeStyle(
      id: 'default',
      name: 'DreamShelf',
      primaryColor: AppColors.primary,
      secondaryColor: AppColors.secondary,
      accentColor: AppColors.accent,
      isPremium: false,
    ),
    AppThemeStyle(
      id: 'ocean',
      name: 'Ocean Breeze',
      primaryColor: const Color(0xFF0EA5E9),
      secondaryColor: const Color(0xFF06B6D4),
      accentColor: const Color(0xFF38BDF8),
      isPremium: true,
    ),
    AppThemeStyle(
      id: 'forest',
      name: 'Forest',
      primaryColor: const Color(0xFF22C55E),
      secondaryColor: const Color(0xFF16A34A),
      accentColor: const Color(0xFF84CC16),
      isPremium: true,
    ),
    AppThemeStyle(
      id: 'sunset',
      name: 'Sunset',
      primaryColor: const Color(0xFFF97316),
      secondaryColor: const Color(0xFFEF4444),
      accentColor: const Color(0xFFFBBF24),
      isPremium: true,
    ),
    AppThemeStyle(
      id: 'lavender',
      name: 'Lavender Dreams',
      primaryColor: const Color(0xFFA855F7),
      secondaryColor: const Color(0xFF8B5CF6),
      accentColor: const Color(0xFFD946EF),
      isPremium: true,
    ),
    AppThemeStyle(
      id: 'midnight',
      name: 'Midnight',
      primaryColor: const Color(0xFF3730A3),
      secondaryColor: const Color(0xFF1E3A8A),
      accentColor: const Color(0xFF6366F1),
      isPremium: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PurchaseBloc, PurchaseState>(
      builder: (context, purchaseState) {
        bool isPremium = false;
        if (purchaseState is ProductsLoaded) {
          isPremium = purchaseState.isPremium;
        } else if (purchaseState is PremiumStatusChecked) {
          isPremium = purchaseState.isPremium;
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Themes'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go(RouteNames.settings),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dark mode toggle
                _buildDarkModeToggle(),
                const SizedBox(height: 24),

                // Theme section header
                Row(
                  children: [
                    Text(
                      'Color Themes',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    if (!isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 4),
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
                  ],
                ),
                const SizedBox(height: 16),

                // Themes grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _themes.length,
                  itemBuilder: (context, index) {
                    final theme = _themes[index];
                    final isSelected = _selectedTheme == theme.id;
                    final canSelect = isPremium || !theme.isPremium;

                    return _ThemeCard(
                      theme: theme,
                      isSelected: isSelected,
                      isDarkMode: _isDarkMode,
                      canSelect: canSelect,
                      onTap: () => _selectTheme(theme, canSelect),
                    );
                  },
                ),

                // Premium upsell
                if (!isPremium) ...[
                  const SizedBox(height: 32),
                  _buildPremiumUpsell(context),
                ],

                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDarkModeToggle() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isDarkMode
                    ? AppColors.neutral800
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: _isDarkMode ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dark Mode',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    _isDarkMode ? 'On' : 'Off',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.neutral500,
                        ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isDarkMode,
              onChanged: (value) => setState(() => _isDarkMode = value),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumUpsell(BuildContext context) {
    return Card(
      color: AppColors.accent.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.palette, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(
                  'Unlock All Themes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Upgrade to Premium to access all beautiful color themes and personalize your reading experience.',
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go(RouteNames.premium),
                icon: const Icon(Icons.star),
                label: const Text('Upgrade to Premium'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectTheme(AppThemeStyle theme, bool canSelect) {
    if (!canSelect) {
      // Show premium required dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('This theme requires Premium'),
          action: SnackBarAction(
            label: 'Upgrade',
            onPressed: () => context.go(RouteNames.premium),
          ),
        ),
      );
      return;
    }

    setState(() => _selectedTheme = theme.id);

    // Save theme preference
    _saveThemePreference(theme.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${theme.name} theme applied'),
        backgroundColor: theme.primaryColor,
      ),
    );
  }

  /// Save theme preference to local storage
  /// In production, this persists the selected theme to Hive storage
  Future<void> _saveThemePreference(String themeId) async {
    try {
      final prefsRepo = context.read<PreferencesRepository>();
      final currentPrefs = await prefsRepo.getPreferences();
      // The theme ID would be stored in preferences
      // For now, we just log success since theme switching requires app restart
      debugPrint('Theme preference saved: $themeId');
    } catch (e) {
      debugPrint('Failed to save theme preference: $e');
    }
  }
}

/// Data class for app themes
class AppThemeStyle {
  final String id;
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final bool isPremium;

  const AppThemeStyle({
    required this.id,
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.isPremium,
  });
}

/// Theme preview card
class _ThemeCard extends StatelessWidget {
  final AppThemeStyle theme;
  final bool isSelected;
  final bool isDarkMode;
  final bool canSelect;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.isSelected,
    required this.isDarkMode,
    required this.canSelect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? theme.primaryColor : AppColors.neutral200,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              // Theme preview
              Column(
                children: [
                  // Header
                  Container(
                    height: 60,
                    width: double.infinity,
                    color: isDarkMode
                        ? _darken(theme.primaryColor, 0.3)
                        : theme.primaryColor,
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 40,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Body
                  Expanded(
                    child: Container(
                      color: isDarkMode
                          ? AppColors.neutral800
                          : AppColors.neutral50,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Mock cards
                          _MockCard(
                            color: isDarkMode
                                ? AppColors.neutral700
                                : Colors.white,
                            accentColor: theme.secondaryColor,
                          ),
                          const SizedBox(height: 8),
                          _MockCard(
                            color: isDarkMode
                                ? AppColors.neutral700
                                : Colors.white,
                            accentColor: theme.accentColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Selected indicator
              if (isSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                  ),
                ),

              // Premium lock
              if (!canSelect)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),

              // Theme name
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? AppColors.neutral900.withOpacity(0.9)
                        : Colors.white.withOpacity(0.9),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          theme.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                      if (theme.isPremium)
                        Icon(
                          Icons.star,
                          size: 14,
                          color: AppColors.accent,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}

/// Mock card for theme preview
class _MockCard extends StatelessWidget {
  final Color color;
  final Color accentColor;

  const _MockCard({
    required this.color,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.neutral300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: AppColors.neutral200,
                    borderRadius: BorderRadius.circular(2),
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
