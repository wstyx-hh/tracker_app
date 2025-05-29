import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../services/isar_service.dart';
import '../widgets/theme_selector.dart';
import '../widgets/language_selector.dart';
import '../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    await IsarService().setAccountName(_nameController.text.trim());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.accountName))
    );
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    if (_loading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.background,
              theme.colorScheme.background.withOpacity(0.8),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: [
            const LanguageSelector(),
            const Divider(height: 1),
            const ThemeSelector(),
            const Divider(height: 1),
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
              title: l10n.preferences,
              icon: Icons.settings_outlined,
              children: [
                _buildSettingsTile(
                  title: l10n.currency,
                  subtitle: _currency,
                  icon: Icons.attach_money_outlined,
                  onTap: () => _showCurrencyPicker(),
                ),
                const SizedBox(height: 16),
                _buildAnimatedSwitch(
                  title: l10n.notifications,
                  subtitle: l10n.enableExpenseReminders,
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
              title: l10n.data,
              icon: Icons.storage_outlined,
              children: [
                _buildActionButton(
                  title: l10n.exportData,
                  subtitle: l10n.exportData,
                  icon: Icons.download_outlined,
                  onTap: _exportData,
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  title: l10n.importData,
                  subtitle: l10n.importData,
                  icon: Icons.upload_outlined,
                  onTap: _importData,
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  title: l10n.clearData,
                  subtitle: l10n.thisActionCannot,
                  icon: Icons.delete_outline,
                  isDestructive: true,
                  onTap: () => _showDeleteConfirmation(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: l10n.about,
              icon: Icons.info_outline,
              children: [
                _buildInfoTile(
                  title: l10n.version,
                  content: '1.0.0',
                  icon: Icons.new_releases_outlined,
                ),
                const SizedBox(height: 16),
                _buildSettingsTile(
                  title: l10n.privacyPolicy,
                  icon: Icons.privacy_tip_outlined,
                  onTap: () {
                    // TODO: Show privacy policy
                  },
                ),
                const SizedBox(height: 16),
                _buildSettingsTile(
                  title: l10n.termsOfService,
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
    final l10n = AppLocalizations.of(context);
    return _buildSection(
      title: l10n.profile,
      icon: Icons.person_outline,
      children: [
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: l10n.accountName,
            hintText: l10n.enterTitle,
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
    final l10n = AppLocalizations.of(context);
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
              l10n.selectCurrency,
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
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: Text(l10n.clearData),
        content: Text(l10n.thisActionCannot),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearAllData();
            },
            child: Text(
              l10n.delete,
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