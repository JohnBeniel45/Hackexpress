import 'package:flutter/material.dart';
import '../theme/apple_liquid_theme.dart';

class LiquidMorphingSlider extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final Color? activeColor;
  final Color? glowColor;

  const LiquidMorphingSlider({
    Key? key,
    required this.value,
    this.min = 0.0,
    this.max = 100.0,
    required this.onChanged,
    this.activeColor,
    this.glowColor,
  }) : super(key: key);

  @override
  State<LiquidMorphingSlider> createState() => _LiquidMorphingSliderState();
}

class _LiquidMorphingSliderState extends State<LiquidMorphingSlider> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final double normalized = ((widget.value - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);
    final activeCol = widget.activeColor ?? AppleLiquidColors.forestPrimary;
    final glowCol = widget.glowColor ?? AppleLiquidColors.forestGlow;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final thumbLeft = normalized * (totalWidth - 26);

        return GestureDetector(
          onHorizontalDragStart: (details) {
            setState(() => _isDragging = true);
            _updateFromPosition(details.localPosition.dx, totalWidth);
          },
          onHorizontalDragUpdate: (details) {
            _updateFromPosition(details.localPosition.dx, totalWidth);
          },
          onHorizontalDragEnd: (details) {
            setState(() => _isDragging = false);
          },
          child: Container(
            height: 38,
            color: Colors.transparent, // expand hit test
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // 1. Frosted Inset Track
                Container(
                  height: 12,
                  width: totalWidth,
                  decoration: BoxDecoration(
                    color: const Color(0x14FFFFFF),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0x1AFFFFFF), width: 0.5),
                  ),
                ),
                // 2. Liquid Glowing Active Fill
                Container(
                  height: 12,
                  width: (normalized * totalWidth).clamp(12.0, totalWidth),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppleLiquidColors.forestDark, activeCol],
                    ),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: glowCol,
                        blurRadius: _isDragging ? 18 : 10,
                        spreadRadius: _isDragging ? 2 : 0,
                      )
                    ],
                  ),
                ),
                // 3. Liquid-Morphing Reactive Thumb Handle
                Positioned(
                  left: thumbLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeOutBack,
                    width: _isDragging ? 28 : 22,
                    height: _isDragging ? 28 : 22,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: activeCol.withOpacity(0.8),
                          blurRadius: _isDragging ? 24 : 12,
                          spreadRadius: _isDragging ? 3 : 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateFromPosition(double localX, double totalWidth) {
    final double ratio = (localX / totalWidth).clamp(0.0, 1.0);
    final double newVal = widget.min + ratio * (widget.max - widget.min);
    widget.onChanged(newVal);
  }
}
