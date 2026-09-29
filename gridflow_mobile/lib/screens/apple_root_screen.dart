import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/apple_liquid_theme.dart';
import '../models/user_profile.dart';
import '../models/station.dart';
import 'screen1_ai_grid_matcher.dart';
import 'screen2_v2v_hub.dart';
import 'screen3_live_map_reservation.dart';

class AppleRootScreen extends StatefulWidget {
  const AppleRootScreen({Key? key}) : super(key: key);

  @override
  State<AppleRootScreen> createState() => _AppleRootScreenState();
}

class _AppleRootScreenState extends State<AppleRootScreen> {
  int _currentIndex = 0;
  final UserProfile _userProfile = UserProfile();
  bool _demoMode = true; // Default ready for presentation demo!
  Station? _preselectedStation;

  void _toggleDemoMode() {
    setState(() {
      _demoMode = !_demoMode;
      if (_demoMode) {
        // Strict Requirement 3: Hyundai Ioniq 5 (92%) to Tata Nexon EV (28%) within 0.4km
        _userProfile.vehicleModel = "Tata Nexon EV Max";
        _userProfile.batteryPct = 28.0;
        _userProfile.vehicleType = "Sedan";
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xE60E131F),
        content: Text(
          _demoMode ? "⚡ DEMO MODE: Matched Ioniq 5 (92%) to Nexon EV (28%) @ 0.4km" : "LIVE SENSOR MODE",
          style: const TextStyle(color: AppleLiquidColors.forestPrimary, fontWeight: FontWeight.bold, fontSize: 12),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
              children: [
                const Icon(Icons.bolt, color: AppleLiquidColors.forestPrimary, size: 20),
                const SizedBox(width: 6),
                const Text(
                  "GridFlow AI",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.4),
                ),
              ],
            ),
            Text(
              "${_userProfile.vehicleModel.toUpperCase()} (${_userProfile.batteryPct.toInt()}%)",
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppleLiquidColors.forestEmerald, letterSpacing: 0.5),
            ),
          ],
        ),
        actions: [
          // DEDICATED DEMO MODE SHORTCUT BUTTON (Strict Requirement 3)
          GestureDetector(
            onTap: _toggleDemoMode,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _demoMode
                    ? AppleLiquidColors.forestEmerald.withOpacity(0.2)
                    : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _demoMode ? AppleLiquidColors.forestPrimary : Colors.white24,
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.speed,
                    size: 14,
                    color: _demoMode ? AppleLiquidColors.forestPrimary : Colors.white70,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _demoMode ? "DEMO MODE" : "LIVE MODE",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: _demoMode ? AppleLiquidColors.forestPrimary : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      // APPLE LIQUID GLASS BOTTOM NAVIGATION BAR
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            height: 74,
            decoration: BoxDecoration(
              color: const Color(0xCC0C1018), // 80% frosted obsidian
              border: const Border(top: BorderSide(color: Color(0x1AFFFFFF), width: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _tabItem(0, Icons.auto_awesome, "AI Match"),
                _tabItem(1, Icons.swap_horiz, "V2V Hub"),
                _tabItem(2, Icons.map_outlined, "Live Map"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tabItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppleLiquidColors.forestPrimary : AppleLiquidColors.silver400,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppleLiquidColors.forestPrimary : AppleLiquidColors.silver400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
