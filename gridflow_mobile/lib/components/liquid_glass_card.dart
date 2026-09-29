import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/apple_liquid_theme.dart';

class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final bool hasSpecularHighlight;
  final VoidCallback? onTap;

  const LiquidGlassCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.margin = const EdgeInsets.only(bottom: 14),
    this.borderRadius = 24.0,
    this.borderColor,
    this.backgroundColor,
    this.hasSpecularHighlight = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x99000000),
            blurRadius: 36,
            offset: Offset(0, 14),
            spreadRadius: -8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? const Color(0xB310141D), // 70% opacity obsidian
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor ?? AppleLiquidColors.glassBorder,
                width: 0.5,
              ),
            ),
            child: Stack(
              children: [
                // Specular Light Sheen Reflection
                if (hasSpecularHighlight)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 100,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0x2EFFFFFF), // 18% white highlight
                            Color(0x05FFFFFF),
                            Color(0x0D10B981), // 5% emerald reflection
                          ],
                          stops: [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: padding,
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: cardContent);
    }
    return cardContent;
  }
}
