import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../widgets/common/app_bar_with_back.dart';
import '../widgets/settings/settings_menu_item.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings state
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _dataSyncEnabled = true;
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBarWithBack(
        title: AppStrings.settings,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Settings Section
            _buildSectionHeader('ACCOUNT SETTINGS'),
            const SizedBox(height: 12),
            SettingsMenuItem(
              icon: Icons.lock_outline,
              title: 'Change Password',
              subtitle: 'Update your password',
              onTap: _showChangePasswordDialog,
            ),
            const SizedBox(height: 12),
            SettingsMenuItem(
              icon: Icons.notifications_outlined,
              title: 'Notification Preferences',
              subtitle: 'Manage alerts',
              toggleValue: _notificationsEnabled,
              onToggleChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
            const SizedBox(height: 12),
            SettingsMenuItem(
              icon: Icons.language_outlined,
              title: 'Language Selection',
              subtitle: _selectedLanguage,
              onTap: _showLanguageSelection,
            ),
            const SizedBox(height: 32),
            // App Settings Section
            _buildSectionHeader('APP SETTINGS'),
            const SizedBox(height: 12),
            SettingsMenuItem(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              subtitle: _darkModeEnabled ? 'Theme: Dark' : 'Theme: Light',
              toggleValue: _darkModeEnabled,
              onToggleChanged: (value) {
                setState(() {
                  _darkModeEnabled = value;
                });
                // TODO: Implement dark mode theme switching
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value ? 'Dark mode enabled' : 'Light mode enabled',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            SettingsMenuItem(
              icon: Icons.sync_outlined,
              title: 'Data Sync',
              subtitle: _dataSyncEnabled ? 'Auto-sync enabled' : 'Auto-sync disabled',
              toggleValue: _dataSyncEnabled,
              onToggleChanged: (value) {
                setState(() {
                  _dataSyncEnabled = value;
                });
                // TODO: Implement data sync toggle
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      value
                          ? 'Auto-sync enabled'
                          : 'Auto-sync disabled',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            // Legal Section
            _buildSectionHeader('LEGAL'),
            const SizedBox(height: 12),
            SettingsMenuItem(
              icon: Icons.description_outlined,
              title: AppStrings.termsAndConditions,
              subtitle: 'View legal terms',
              onTap: _showTermsAndConditions,
            ),
            const SizedBox(height: 32),
            // Version Info
            _buildVersionInfo(),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Center(
      child: Column(
        children: [
          Text(
            'DrLocumDr v1.0.0',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '© 2025 Locum Healthcare',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: oldPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newPasswordController.text !=
                    confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Passwords do not match'),
                    ),
                  );
                  return;
                }
                // TODO: Implement password change API call
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password changed successfully'),
                  ),
                );
              },
              child: const Text('Change Password'),
            ),
          ],
        );
      },
    );
  }

  void _showLanguageSelection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Select Language',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('English'),
              trailing: _selectedLanguage == 'English'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() {
                  _selectedLanguage = 'English';
                });
                Navigator.pop(context);
                // TODO: Implement language change
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Language changed to English')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Hindi'),
              trailing: _selectedLanguage == 'Hindi'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                setState(() {
                  _selectedLanguage = 'Hindi';
                });
                Navigator.pop(context);
                // TODO: Implement language change
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Language changed to Hindi')),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Terms & Conditions'),
          content: const SingleChildScrollView(
            child: Text(
              'Terms and Conditions content will be displayed here. '
              'This is a placeholder for the actual terms and conditions document.',
              style: TextStyle(fontSize: 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

