import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _currency = '\$';
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection(
            title: 'Appearance',
            children: [
              SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Enable dark theme'),
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                },
              ),
            ],
          ),
          _buildSection(
            title: 'Preferences',
            children: [
              ListTile(
                title: const Text('Currency'),
                subtitle: Text(_currency),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Select Currency'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildCurrencyOption('\$'),
                          _buildCurrencyOption('€'),
                          _buildCurrencyOption('£'),
                          _buildCurrencyOption('¥'),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SwitchListTile(
                title: const Text('Notifications'),
                subtitle: const Text('Enable expense reminders'),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  _saveSettings();
                },
              ),
            ],
          ),
          _buildSection(
            title: 'Data',
            children: [
              ListTile(
                title: const Text('Export Data'),
                subtitle: const Text('Export your expense data'),
                leading: const Icon(Icons.download),
                onTap: () {
                  // TODO: Implement data export
                },
              ),
              ListTile(
                title: const Text('Import Data'),
                subtitle: const Text('Import expense data from file'),
                leading: const Icon(Icons.upload),
                onTap: () {
                  // TODO: Implement data import
                },
              ),
              ListTile(
                title: const Text('Clear All Data'),
                subtitle: const Text('Delete all your expense data'),
                leading: const Icon(Icons.delete_forever),
                textColor: Theme.of(context).colorScheme.error,
                iconColor: Theme.of(context).colorScheme.error,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
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
                          onPressed: () {
                            // TODO: Implement data clearing
                            Navigator.pop(context);
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
                },
              ),
            ],
          ),
          _buildSection(
            title: 'About',
            children: [
              const ListTile(
                title: Text('Version'),
                subtitle: Text('1.0.0'),
              ),
              ListTile(
                title: const Text('Privacy Policy'),
                onTap: () {
                  // TODO: Show privacy policy
                },
              ),
              ListTile(
                title: const Text('Terms of Service'),
                onTap: () {
                  // TODO: Show terms of service
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }

  Widget _buildCurrencyOption(String currency) {
    return ListTile(
      title: Text(currency),
      onTap: () {
        setState(() {
          _currency = currency;
        });
        _saveSettings();
        Navigator.pop(context);
      },
    );
  }
} 