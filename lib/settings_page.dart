// lib/settings_page.dart
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true; // Reflects the app's current theme
  double _fontSizeScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // Notifications setting
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Enable Notifications',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Switch(
                    value: _notificationsEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Notifications ${value ? "enabled" : "disabled"}'),
                          backgroundColor: Colors.grey[800],
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          margin: const EdgeInsets.all(16.0),
                        ),
                      );
                    },
                    activeColor: Colors.greenAccent,
                  ),
                ],
              ),
            ),
          ),
          // Dark Mode setting (already implemented by theme, but for user control)
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Dark Mode',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Switch(
                    value: _darkModeEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _darkModeEnabled = value;
                        // In a real app, this would trigger a theme change.
                        // For now, it's a visual toggle.
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Dark Mode ${value ? "enabled" : "disabled"} (Theme change not implemented yet)'),
                          backgroundColor: Colors.grey[800],
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          margin: const EdgeInsets.all(16.0),
                        ),
                      );
                    },
                    activeColor: Colors.blueAccent,
                  ),
                ],
              ),
            ),
          ),
          // Font Size Scale
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Font Size Scale',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Slider(
                    value: _fontSizeScale,
                    min: 0.8,
                    max: 1.2,
                    divisions: 4, // 0.8, 0.9, 1.0, 1.1, 1.2
                    label: _fontSizeScale.toStringAsFixed(1),
                    onChanged: (double value) {
                      setState(() {
                        _fontSizeScale = value;
                      });
                      // TODO: Implement actual font size scaling for the app
                    },
                    activeColor: Colors.white,
                    inactiveColor: Colors.white38,
                  ),
                  Center(
                    child: Text(
                      'This is a sample text to show font size.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize! * _fontSizeScale,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Placeholder for other settings
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Management',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Implement account logout logic
                      print('Logout button pressed');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Logging out...'),
                          backgroundColor: Colors.grey[800],
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          margin: const EdgeInsets.all(16.0),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
