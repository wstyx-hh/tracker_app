import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../providers/theme_provider.dart';
import '../services/isar_service.dart';

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
    if (_loading) return const Center(child: CircularProgressIndicator());
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
                onTap: _exportData,
              ),
              ListTile(
                title: const Text('Import Data'),
                subtitle: const Text('Import expense data from file'),
                leading: const Icon(Icons.upload),
                onTap: _importData,
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
          _buildSection(
            title: 'Account Name',
            children: [
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save'),
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