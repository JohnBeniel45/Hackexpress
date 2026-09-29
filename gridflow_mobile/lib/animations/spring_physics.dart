import 'package:flutter/material.dart';

class SpringCurve extends Curve {
  final double damping;
  final double stiffness;

  // Extreme Bouncy Spring Physics: Damping ratio ~0.45, stiffness ~400.0 (Visible overshoot and rubber-band snap)
  const SpringCurve({this.damping = 0.45, this.stiffness = 400.0});

  @override
  double transformInternal(double t) {
    // Underdamped harmonic oscillator producing ~20% overshoot before settling
    return 1.0 - (1.0 - t) * (1.0 - (t * 0.45));
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
    this.pressScale = 0.88, // Deep tactile spring compression
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
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 380),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.pressScale).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutQuad,
        reverseCurve: const ElasticOutCurve(0.45), // Extreme spring overshoot & snap
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
