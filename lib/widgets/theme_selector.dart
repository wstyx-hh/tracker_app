import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.palette_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Theme',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 120,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: ThemeProvider.themeColors.length,
                itemBuilder: (context, index) {
                  final color = ThemeProvider.themeColors[index];
                  final isSelected = themeProvider.selectedThemeIndex == index;
                  final name = ThemeProvider.themeNames[index];
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () => themeProvider.setTheme(index),
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 32),
            ListTile(
              leading: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Dark Mode'),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: themeProvider.toggleTheme,
              ),
            ),
          ],
        );
      },
    );
  }
} 