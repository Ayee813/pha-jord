import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

// import your pages
import 'pages/home_page.dart';
import 'pages/map_page.dart';
import 'pages/history_page.dart';
import 'pages/profile_page.dart';

// import your theme style
import 'app_color.dart';

//app header
import 'header.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<String> _titles = const ["Home", "Map", "History", "Profile"];

  final List<Widget> _pages = const [
    HomePage(),
    MapPage(),
    HistoryPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56.0),
        child: AppHeader(title: _titles[_currentIndex]),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.backgroundColor,
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: FBottomNavigationBar(
        style: FTheme.of(context).bottomNavigationBarStyle,
        index: _currentIndex,
        onChange: (index) {
          setState(() => _currentIndex = index);
        },
        children: const [
          FBottomNavigationBarItem(
            icon: Icon(FIcons.house),
            label: Text("Home"),
          ),
          FBottomNavigationBarItem(icon: Icon(FIcons.map), label: Text("Map")),
          FBottomNavigationBarItem(
            icon: Icon(FIcons.clock),
            label: Text("History"),
          ),
          FBottomNavigationBarItem(
            icon: Icon(FIcons.user),
            label: Text("Profile"),
          ),
        ],
      ),
    );
  }
}
