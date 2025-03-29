import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = [
      {'icon': Icons.person, 'title': 'Account', 'route': AccountPage()},
      {'icon': Icons.notifications, 'title': 'Notifications', 'route': NotificationsPage()},
      {'icon': Icons.remove_red_eye, 'title': 'Appearance', 'route': AppearancePage()},
      {'icon': Icons.lock, 'title': 'Privacy and Security', 'route': PrivacyPage()},
      {'icon': Icons.headset_mic, 'title': 'Help and Support', 'route': HelpPage()},
      {'icon': Icons.info_outline, 'title': 'About', 'route': AboutPage()},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: settings.length,
        itemBuilder: (context, index) {
          final item = settings[index];
          return ListTile(
            leading: Icon(item['icon'] as IconData),
            title: Text(item['title'] as String),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => item['route'] as Widget),
              );
            },
          );
        },
        separatorBuilder: (context, index) => const Divider(),
      ),
    );
  }
}

class AccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Account')));
  }
}

class NotificationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Notifications')));
  }
}

class AppearancePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Appearance')));
  }
}

class PrivacyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Privacy and Security')));
  }
}

class HelpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Help and Support')));
  }
}

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('About')));
  }
}
