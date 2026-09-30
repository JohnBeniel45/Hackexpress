import 'package:flutter/material.dart';
import '../theme/apple_liquid_theme.dart';
import '../components/mac_floating_dock.dart';
import '../models/user_profile.dart';
import '../models/station.dart';
import 'screen1_ai_grid_matcher.dart';
import 'screen2_v2v_hub.dart';
import 'screen3_live_map_reservation.dart';
import 'main_navigation_screen.dart';

class AppleRootScreen extends StatefulWidget {
  const AppleRootScreen({Key? key}) : super(key: key);

  @override
  State<AppleRootScreen> createState() => _AppleRootScreenState();
}

class _AppleRootScreenState extends State<AppleRootScreen> {
  int _currentIndex = 0;
  final UserProfile _userProfile = UserProfile();
  bool _demoMode = true; // Ready for hackathon judging demo!
  Station? _preselectedStation;

  void _toggleDemoMode() {
    setState(() {
      _demoMode = !_demoMode;
      if (_demoMode) {
        _userProfile.vehicleModel = "Tata Nexon EV Max";
        _userProfile.batteryPct = 28.0;
        _userProfile.vehicleType = "Sedan";
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        content: Text(
          _demoMode ? "⚡ DEMO MODE: Matched Ioniq 5 (92%) to Nexon EV (28%) @ 0.4km" : "LIVE SENSOR MODE",
          style: const TextStyle(color: AppleLiquidColors.natureEmerald, fontWeight: FontWeight.bold, fontSize: 12),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _navigateToReservation(Station station) {
    setState(() {
      _preselectedStation = station;
      _currentIndex = 2; // Screen 3
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      Screen1AiGridMatcher(
        profile: _userProfile,
        onReserve: _navigateToReservation,
        onProfileChanged: () => setState(() {}),
      ),
      Screen2V2VHub(
        profile: _userProfile,
        onStateUpdated: () => setState(() {}),
      ),
      Screen3LiveMapReservation(
        profile: _userProfile,
        preselectedStation: _preselectedStation,
      ),
    ];

    return Scaffold(
      backgroundColor: AppleLiquidColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.bolt, color: AppleLiquidColors.natureEmerald, size: 20),
                SizedBox(width: 6),
                Text(
                  "GridFlow AI",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppleLiquidColors.textHeadline,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
            Text(
              "${_userProfile.vehicleModel.toUpperCase()} (${_userProfile.batteryPct.toInt()}%)",
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppleLiquidColors.natureEmerald,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Switch to Enterprise 5-Tab Dashboard",
            icon: const Icon(Icons.dashboard_customize_outlined, color: AppleLiquidColors.natureEmerald, size: 22),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // EV Nature Atmospheric Background Layer
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/ev_nature_backdrop.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppleLiquidColors.background,
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x52E0F2FE), // Soft Sky Blue (32%)
                        Color(0x6BF8FAFC), // Pearl Mist (42%)
                        Color(0x5CD1FAE5), // Mint Green (36%)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Screen Viewport with Mac OS scaling transition
          Positioned.fill(
            child: IndexedStack(
              index: _currentIndex,
              children: screens,
            ),
          ),

          // MAC OS / IOS FLOATING LIQUID GLASS DOCK
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MacFloatingDock(
              activeIndex: _currentIndex,
              onTabSelected: (idx) => setState(() => _currentIndex = idx),
            ),
          ),
        ],
      ),
    );
  }
}
