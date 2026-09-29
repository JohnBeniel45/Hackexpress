import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/station.dart';
import '../theme/app_theme.dart';
import 'home_dashboard_screen.dart';
import 'map_explorer_screen.dart';
import 'recommendation_screen.dart';
import 'v2v_sharing_screen.dart';
import 'analytics_screen.dart';
import 'reservation_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final UserProfile _userProfile = UserProfile();

  void _navigateToTab(int index) {
    setState(() => _currentIndex = index);
  }

  void _openReservation(Station station) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReservationScreen(
          station: station,
          profile: _userProfile,
          onBookingComplete: () {
            Navigator.of(context).pop();
            _navigateToTab(0);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeDashboardScreen(
        profile: _userProfile,
        onNavigateTab: _navigateToTab,
        onProfileChanged: () => setState(() {}),
      ),
      MapExplorerScreen(
        profile: _userProfile,
        onSelectStation: _openReservation,
      ),
      RecommendationScreen(
        profile: _userProfile,
        onReserveStation: _openReservation,
      ),
      V2VSharingScreen(
        profile: _userProfile,
        onStateUpdated: () => setState(() {}),
      ),
      const AnalyticsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: "Stations",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome),
            label: "AI Match",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            activeIcon: Icon(Icons.swap_horizontal_circle),
            label: "V2V Share",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights_outlined),
            activeIcon: Icon(Icons.insights),
            label: "Analytics",
          ),
        ],
      ),
    );
  }
}
