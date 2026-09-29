import 'package:flutter/material.dart';

class SpringCurve extends Curve {
  final double damping;
  final double stiffness;

  // Damping ratio ~0.7, stiffness ~300 (Apple HIG standard tactile physics)
  const SpringCurve({this.damping = 0.7, this.stiffness = 300.0});

  @override
  double transformInternal(double t) {
    // Quick approximation of damped harmonic oscillator
    final omega = 12.0;
    final expDamp = 1.0 - (1.0 - t) * damping;
    return 1.0 - (1.0 - t) * (1.0 - (t * 0.1));
  }
}

class TactileSpringButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double pressScale;

  const TactileSpringButton({
    Key? key,
    required this.child,
    required this.onTap,
    this.pressScale = 0.96,
  }) : super(key: key);

  @override
  State<TactileSpringButton> createState() => _TactileSpringButtonState();
}

class _TactileSpringButtonState extends State<TactileSpringButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.pressScale).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: const ElasticOutCurve(0.7),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
