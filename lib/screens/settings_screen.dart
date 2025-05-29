import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/theme_provider.dart';
import '../services/isar_service.dart';
import '../widgets/theme_selector.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currency = '\$';
  bool _notificationsEnabled = true;
  final _nameController = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadName();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currency = prefs.getString('currency') ?? '\$';
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currency', _currency);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
  }

  Future<void> _loadName() async {
    final name = await IsarService().getAccountName();
    _nameController.text = name;
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() async {
    await IsarService().setAccountName(_nameController.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account name updated')));
  }

  Future<void> _exportData() async {
    final json = await IsarService().exportData();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/expense_export.json');
    await file.writeAsString(json);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data exported to ${file.path}')));
  }

  Future<void> _importData() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final json = await file.readAsString();
      await IsarService().importData(json);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data imported successfully')));
    }
  }

  Future<void> _clearAllData() async {
    await IsarService().clearAllData();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All data cleared')));
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    if (_loading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.background.withOpacity(0.8),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: [
            _buildProfileSection(),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: const ThemeSelector(),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Preferences',
              icon: Icons.settings_outlined,
              children: [
                _buildSettingsTile(
                  title: 'Currency',
                  subtitle: _currency,
                  icon: Icons.attach_money_outlined,
                  onTap: () => _showCurrencyPicker(),
                ),
                const SizedBox(height: 16),
                _buildAnimatedSwitch(
                  title: 'Notifications',
                  subtitle: 'Enable expense reminders',
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                    _saveSettings();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'Data Management',
              icon: Icons.storage_outlined,
              children: [
                _buildActionButton(
                  title: 'Export Data',
                  subtitle: 'Backup your expense data',
                  icon: Icons.download_outlined,
                  onTap: _exportData,
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  title: 'Import Data',
                  subtitle: 'Restore from backup',
                  icon: Icons.upload_outlined,
                  onTap: _importData,
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  title: 'Clear All Data',
                  subtitle: 'Delete all your expense data',
                  icon: Icons.delete_outline,
                  isDestructive: true,
                  onTap: () => _showDeleteConfirmation(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: 'About',
              icon: Icons.info_outline,
              children: [
                _buildInfoTile(
                  title: 'Version',
                  content: '1.0.0',
                  icon: Icons.new_releases_outlined,
                ),
                const SizedBox(height: 16),
                _buildSettingsTile(
                  title: 'Privacy Policy',
                  icon: Icons.privacy_tip_outlined,
                  onTap: () {
                    // TODO: Show privacy policy
                  },
                ),
                const SizedBox(height: 16),
                _buildSettingsTile(
                  title: 'Terms of Service',
                  icon: Icons.description_outlined,
                  onTap: () {
                    // TODO: Show terms of service
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return _buildSection(
      title: 'Profile',
      icon: Icons.person_outline,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Account Name',
            hintText: 'Enter your name',
          ),
          onEditingComplete: _save,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required String title,
    String? subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isDestructive ? color : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCurrencyPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Select Currency',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...['\$', '€', '£', '¥'].map((currency) => ListTile(
              title: Text(
                currency,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              onTap: () {
                setState(() => _currency = currency);
                _saveSettings();
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text('Clear All Data'),
        content: const Text(
          'Are you sure you want to delete all your expense data? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearAllData();
            },
            child: Text(
              'Delete',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 