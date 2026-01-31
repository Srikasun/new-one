import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/themes/app_colors.dart';

/// Settings screen for app configuration
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _dailyReminder = true;
  TimeOfDay _reminderTime = const TimeOfDay(hour: 20, minute: 0);
  int _defaultDailyGoal = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.home),
        ),
      ),
      body: ListView(
        children: [
          // Appearance section
          _buildSectionHeader('Appearance'),
          _buildSwitchTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: 'Use dark theme',
            value: _darkMode,
            onChanged: (value) => setState(() => _darkMode = value),
          ),

          const Divider(),

          // Notifications section
          _buildSectionHeader('Notifications'),
          _buildSwitchTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Enable push notifications',
            value: _notifications,
            onChanged: (value) => setState(() => _notifications = value),
          ),
          _buildSwitchTile(
            icon: Icons.alarm,
            title: 'Daily Reading Reminder',
            subtitle: 'Remind me to read every day',
            value: _dailyReminder,
            onChanged: (value) => setState(() => _dailyReminder = value),
          ),
          if (_dailyReminder)
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Reminder Time'),
              subtitle: Text(_reminderTime.format(context)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectReminderTime,
            ),

          const Divider(),

          // Reading Goals section
          _buildSectionHeader('Reading Goals'),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const Text('Daily Pages Goal'),
            subtitle: Text('$_defaultDailyGoal pages per day'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _editDailyGoal,
          ),
          ListTile(
            leading: const Icon(Icons.auto_stories),
            title: const Text('Yearly Books Goal'),
            subtitle: Text('${AppConstants.defaultYearlyBooksGoal} books per year'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Edit yearly goal
            },
          ),

          const Divider(),

          // Data section
          _buildSectionHeader('Data'),
          ListTile(
            leading: const Icon(Icons.cloud_upload),
            title: const Text('Export Data'),
            subtitle: const Text('Export your library as JSON'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.cloud_download),
            title: const Text('Import Data'),
            subtitle: const Text('Import library from JSON'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Import feature coming soon!')),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: AppColors.error),
            title: const Text('Clear All Data'),
            subtitle: const Text('Delete all books and reading data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _showClearDataDialog,
          ),

          const Divider(),

          // Premium section
          _buildSectionHeader('Premium'),
          Card(
            margin: const EdgeInsets.all(16),
            color: AppColors.accent.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.accent),
                      const SizedBox(width: 8),
                      Text(
                        'Upgrade to Premium',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('• Remove all ads'),
                  const Text('• Cloud backup & sync'),
                  const Text('• Advanced statistics'),
                  const Text('• Unlimited goals'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go(RouteNames.premium),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                    ),
                    child: const Text('Learn More'),
                  ),
                ],
              ),
            ),
          ),

          const Divider(),

          // About section
          _buildSectionHeader('About'),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About DreamShelf'),
            subtitle: Text('Version ${AppConstants.appVersion}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAboutDialog(),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Open privacy policy
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Open terms of service
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Send Feedback'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Open feedback form
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_rate),
            title: const Text('Rate the App'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Open app store
            },
          ),

          const SizedBox(height: 32),

          // App info
          Center(
            child: Column(
              children: [
                const Icon(
                  Icons.auto_stories,
                  size: 48,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 8),
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  'Version ${AppConstants.appVersion}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral500,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '© 2024 DreamShelf',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.neutral500,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Future<void> _selectReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (time != null) {
      setState(() => _reminderTime = time);
    }
  }

  void _editDailyGoal() {
    final controller = TextEditingController(text: _defaultDailyGoal.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daily Pages Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Pages per day',
            hintText: 'e.g., 30',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                setState(() => _defaultDailyGoal = value);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your books, reading sessions, and goals. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data cleared')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationIcon: const Icon(
        Icons.auto_stories,
        size: 48,
        color: AppColors.primary,
      ),
      children: [
        const Text(
          'DreamShelf is your personal book tracking companion. '
          'Track your reading progress, set goals, and discover your reading habits.',
        ),
      ],
    );
  }
}
