import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool, Locale) updateThemeAndLocale;

  const SettingsScreen({super.key, required this.updateThemeAndLocale});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  Locale _selectedLocale = const Locale('en');

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize with current app state when dependencies are available
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;
    _selectedLocale = Localizations.localeOf(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.settings)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(AppLocalizations.of(context)!.darkMode),
            value: _isDarkMode,
            onChanged: (value) {
              setState(() => _isDarkMode = value);
              widget.updateThemeAndLocale(_isDarkMode, _selectedLocale);
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.language),
            subtitle: Text(_selectedLocale.languageCode == 'en' ? 'English' : 'العربية'),
            onTap: () {
              setState(() {
                _selectedLocale = _selectedLocale.languageCode == 'en'
                    ? const Locale('ar')
                    : const Locale('en');
              });
              widget.updateThemeAndLocale(_isDarkMode, _selectedLocale);
            },
          ),
        ],
      ),
    );
  }
}