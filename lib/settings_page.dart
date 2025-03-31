import 'package:flutter/material.dart';
import 'package:project1/services/auth_service.dart';
import 'package:project1/welcome_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
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
          _buildLogoutTile(
            context,
            Icons.exit_to_app,
            'Logout',
            onTap: () async {
              await AuthService().logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                (route) => false,
              );
            },
            iconColor: Colors.red,
            textColor: Colors.red,
          ),
        ],
      ),
    );
  }

  ListTile _buildTile(BuildContext context, IconData icon, String title, Widget? page, {VoidCallback? onTap, Color? iconColor, Color? textColor}) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap ?? () => Navigator.push(context, MaterialPageRoute(builder: (_) => page!)),
    );
  }

  ListTile _buildLogoutTile(
    BuildContext context,
    IconData icon,
    String title, {
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor)),
      onTap: onTap,
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
          _buildTile(context, 'Edit Profile', EditProfilePage()),
          _buildTile(context, 'Change Email', ChangeEmailPage()),
          _buildTile(context, 'Update Password', UpdatePasswordPage()),
        ],
      ),
    );
  }

  ListTile _buildTile(BuildContext context, String title, Widget page) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
    );
  }
}

class EditProfilePage extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                User? currentUser = await AuthService().getCurrentUser();
                if (currentUser != null) {
                  await AuthService().updateUser(User(id: currentUser.id, name: _nameController.text, email: currentUser.email, password: currentUser.password));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated!')));
                  _nameController.clear();
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class ChangeEmailPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Email')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'New Email')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                User? currentUser = await AuthService().getCurrentUser();
                if (currentUser != null) {
                  await AuthService().updateUserEmail(currentUser.id!, _emailController.text);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email updated!')));
                  _emailController.clear();
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class UpdatePasswordPage extends StatelessWidget {
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'New Password')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                User? currentUser = await AuthService().getCurrentUser();
                if (currentUser != null) {
                  await AuthService().updateUserPassword(currentUser.id!, _passwordController.text);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated!')));
                  _passwordController.clear();
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
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
        trailing: Switch(value: Theme.of(context).brightness == Brightness.dark, onChanged: (_) => toggleTheme()),
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
