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
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F0F172A),
            blurRadius: 36,
            offset: Offset(0, 16),
            spreadRadius: -6,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.72),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.white.withOpacity(0.95), width: 0.5),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double tabWidth = (constraints.maxWidth) / 3.0;

                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Gliding Liquid Magnification Bubble Lens
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 380),
                      curve: const Cubic(0.34, 1.56, 0.64, 1), // Apple Spring Physics
                      left: activeIndex * tabWidth + 4,
                      width: tabWidth - 8,
                      height: 48,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.98),
                              const Color(0xFFF0FDF4),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.white, width: 0.5),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A10B981),
                              blurRadius: 18,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Interactive Tab Icons
                    Row(
                      children: [
                        _dockTab(0, Icons.auto_awesome, "AI Match", tabWidth),
                        _dockTab(1, Icons.swap_horiz, "V2V Hub", tabWidth),
                        _dockTab(2, Icons.map_outlined, "Live Map", tabWidth),
                      ],
                    ),
                  ],
                );
              },
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
      height: 64,
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: isSelected ? 1.08 : 1.0, // Mac OS Magnification
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 21,
                color: isSelected ? AppleLiquidColors.natureEmerald : AppleLiquidColors.textCaption,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? AppleLiquidColors.natureEmerald : AppleLiquidColors.textCaption,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
