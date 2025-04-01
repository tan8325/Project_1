import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project1/services/auth_service.dart';
import 'welcome_screen.dart';
import 'home_page.dart';
import 'user_page.dart';
import 'graph_page.dart';
import 'settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final authService = AuthService();
  final currentUser = await authService.getCurrentUser();

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false; 

  runApp(MyApp(isLoggedIn: currentUser != null, isDarkMode: isDarkMode));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  final bool isDarkMode;
  
  const MyApp({super.key, required this.isLoggedIn, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Finance Manager',
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: isLoggedIn ? HomeScreen(isDarkMode: isDarkMode) : const WelcomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;

  const HomeScreen({super.key, required this.isDarkMode});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  late bool isDarkMode;

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode;
  }

  void toggleTheme() async {
    setState(() {
      isDarkMode = !isDarkMode;
    });

    // Save theme preference to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      const HomePage(),
      const UserPage(),
      const GraphPage(key: PageStorageKey('graphPage')),
      SettingsPage(toggleTheme: toggleTheme),
    ];

    return MaterialApp(
      theme: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
