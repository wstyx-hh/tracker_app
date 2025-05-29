import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_localizations.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.language,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.language,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: localeProvider.supportedLocales.map((locale) {
                  final isSelected = localeProvider.currentLocale == locale;
                  return InkWell(
                    onTap: () => localeProvider.setLocale(locale),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).dividerColor.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            localeProvider.languageNames[locale.languageCode] ?? locale.languageCode,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected 
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
} 