import 'package:flutter/material.dart';
import 'dart:async';

class AnotherDelayedAnimation extends StatefulWidget {
  final Widget child;
  final int delay;
  const AnotherDelayedAnimation({required this.delay, required this.child});

  @override
  _AnotherDelayedAnimationState createState() => _AnotherDelayedAnimationState();
}

class _AnotherDelayedAnimationState extends State<AnotherDelayedAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animOffset;
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.decelerate,
    );

    _animOffset = Tween<Offset>(
      begin: Offset(0, 2.0),
      end: Offset(0, 0),
    ).animate(curve);

    Timer(Duration(milliseconds: widget.delay), () {
      _controller.forward();
    });
  }

  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: SlideTransition(
        position: _animOffset,
        child: widget.child,
      ),
    );
  }
}
