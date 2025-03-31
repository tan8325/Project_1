import 'package:flutter/material.dart';
import 'package:project1/services/auth_service.dart';
import 'package:project1/welcome_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: SettingsPage(toggleTheme: () => setState(() => isDarkMode = !isDarkMode)),
    );
  }
}

class SettingsPage extends StatelessWidget {
  final VoidCallback toggleTheme;
  const SettingsPage({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _buildTile(context, Icons.person, 'Account', const AccountPage()),
          _buildTile(context, Icons.remove_red_eye, 'Appearance', AppearancePage(toggleTheme: toggleTheme)),
          _buildTile(context, Icons.lock, 'Privacy', const PrivacyPage()),
          _buildTile(context, Icons.info_outline, 'About', const AboutPage()),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await AuthService().logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  ListTile _buildTile(BuildContext context, IconData icon, String title, Widget page) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
    );
  }
}

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: Column(
        children: [
          _buildTile(context, 'Edit Profile', const EditProfilePage()),
          _buildTile(context, 'Change Email', const ChangeEmailPage()),
          _buildTile(context, 'Update Password', const UpdatePasswordPage()),
        ],
      ),
    );
  }

  ListTile _buildTile(BuildContext context, String title, Widget page) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
    );
  }
}

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return _buildInputPage(context, 'Edit Profile', 'Name');
  }
}

class ChangeEmailPage extends StatelessWidget {
  const ChangeEmailPage({super.key});
  @override
  Widget build(BuildContext context) {
    return _buildInputPage(context, 'Change Email', 'New Email');
  }
}

class UpdatePasswordPage extends StatelessWidget {
  const UpdatePasswordPage({super.key});
  @override
  Widget build(BuildContext context) {
    return _buildInputPage(context, 'Update Password', 'New Password', obscureText: true);
  }
}

class AppearancePage extends StatelessWidget {
  final VoidCallback toggleTheme;
  const AppearancePage({super.key, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ListTile(
        title: const Text('Dark Mode'),
        trailing: Switch(
          value: Theme.of(context).brightness == Brightness.dark,
          onChanged: (value) => toggleTheme(),
        ),
      ),
    );
  }
}

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  _PrivacyPageState createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  bool _twoFactorEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy')),
      body: ListTile(
        title: const Text('Two-Factor Authentication'),
        trailing: Switch(
          value: _twoFactorEnabled,
          onChanged: (value) {
            setState(() => _twoFactorEnabled = value);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Two-Factor Authentication ${value ? "Enabled" : "Disabled"}')));
          },
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListTile(
        title: const Text('View Licenses'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => showLicensePage(context: context),
      ),
    );
  }
}

Widget _buildInputPage(BuildContext context, String title, String hint, {bool obscureText = false}) {
  final TextEditingController controller = TextEditingController();
  return Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(controller: controller, obscureText: obscureText, decoration: InputDecoration(labelText: hint)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title updated!')));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}
