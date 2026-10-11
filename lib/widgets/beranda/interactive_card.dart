import 'package:flutter/material.dart';

class InteractiveCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double liftDistance;
  final double scaleOnPress;
  final Duration duration;

  const InteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.liftDistance = -6.0,
    this.scaleOnPress = 0.96,
    this.duration = const Duration(milliseconds: 150),
  });

  @override
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed != value) {
      setState(() => _isPressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..translateByDouble(0.0, _isPressed ? widget.liftDistance : 0.0, 0.0, 0.0)
          ..scaleByDouble(
            _isPressed ? widget.scaleOnPress : 1.0,
            _isPressed ? widget.scaleOnPress : 1.0,
            1.0,
            1.0,
          ),
        decoration: BoxDecoration(
          color: _isPressed ? const Color(0xFFF5F8F6) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isPressed ? 0.12 : 0.04),
              blurRadius: _isPressed ? 12 : 6,
              offset: Offset(0, _isPressed ? 8 : 2),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}