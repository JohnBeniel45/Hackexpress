import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/apple_liquid_theme.dart';

class MacFloatingDock extends StatelessWidget {
  final int activeIndex;
  final Function(int) onTabSelected;

  const MacFloatingDock({
    Key? key,
    required this.activeIndex,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        width: 334,
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(29),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2E0F172A),
              blurRadius: 40,
              offset: Offset(0, 18),
              spreadRadius: -6,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(29),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.72),
                borderRadius: BorderRadius.circular(29),
                border: Border.all(color: Colors.white.withOpacity(0.95), width: 0.8),
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  // Gliding Liquid Magnification Bubble Lens (108px exact width per tab)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 420),
                    curve: const Cubic(0.175, 1.45, 0.32, 1.25), // Fluid Spring Snap
                    left: activeIndex * 108.0,
                    width: 108.0,
                    height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.98),
                            const Color(0xFFF0F9FF),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white, width: 0.8),
                        boxShadow: const [
                          // Refractive Blue Rim
                          BoxShadow(
                            color: Color(0x3800A3FF),
                            blurRadius: 18,
                            offset: Offset(0, 6),
                          ),
                          // Refractive Emerald Rim
                          BoxShadow(
                            color: Color(0x2610B981),
                            blurRadius: 10,
                            offset: Offset(0, -2),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Interactive Tab Icons (108px exact width per tab)
                  Row(
                    children: [
                      _dockTab(0, Icons.auto_awesome, "AI Match", 108.0),
                      _dockTab(1, Icons.swap_horiz, "V2V Hub", 108.0),
                      _dockTab(2, Icons.map_outlined, "Live Map", 108.0),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dockTab(int index, IconData icon, String label, double width) {
    final isSelected = activeIndex == index;

    return SizedBox(
      width: width,
      height: 48,
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: isSelected ? 1.16 : 1.0,
          duration: const Duration(milliseconds: 350),
          curve: const Cubic(0.175, 1.45, 0.32, 1.35),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppleLiquidColors.skyVibrant : AppleLiquidColors.textCaption,
              ),
              const SizedBox(height: 1),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? AppleLiquidColors.skyVibrant : AppleLiquidColors.textCaption,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
