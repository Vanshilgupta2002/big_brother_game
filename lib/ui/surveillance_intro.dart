import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SurveillanceIntro extends StatefulWidget {
  final VoidCallback onEnter;

  const SurveillanceIntro({super.key, required this.onEnter});

  @override
  State<SurveillanceIntro> createState() => _SurveillanceIntroState();
}

class _SurveillanceIntroState extends State<SurveillanceIntro>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _cursorTimer;

  bool _cursorVisible = true;

  @override
  void initState() {
    super.initState();

    // Button pulse animation
    _pulseController =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);

    _pulseAnimation =
        Tween(begin: 0.6, end: 1.0).animate(_pulseController);

    // Blinking cursor
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (!mounted) return;
      setState(() {
        _cursorVisible = !_cursorVisible;
      });
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [

          // 🔥 Subtle background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.2,
                colors: [
                  Color(0xFF220000),
                  Color(0xFF0A0A0A),
                ],
              ),
            ),
          ),

          // 🟢 Moving scan line
          const _ScanLine(),

          // 🧾 Center Card
          Center(
            child: Container(
              width: 520,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                border: Border.all(
                  color: Colors.greenAccent.withOpacity(0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.greenAccent.withOpacity(0.1),
                    blurRadius: 20,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  const Text(
                    "BIG BROTHER v2.4",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      letterSpacing: 3,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "SURVEILLANCE PROTOCOL ACTIVE",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 14,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Container(
                    height: 1,
                    color: Colors.greenAccent.withOpacity(0.3),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "IDENTIFY DISSIDENTS\n"
                        "MAINTAIN SYSTEM STABILITY\n"
                        "MINIMIZE CIVILIAN DISRUPTION",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.6,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🟢 Animated ENTER button
                  FadeTransition(
                    opacity: _pulseAnimation,
                    child: GestureDetector(
                      onTap: widget.onEnter,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Colors.greenAccent, width: 1.5),
                        ),
                        child: Text(
                          "ENTER SYSTEM ${_cursorVisible ? "_" : " "}",
                          style: const TextStyle(
                            color: Colors.greenAccent,
                            letterSpacing: 2,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
          ),

          // 🔐 Small classified label
          const Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "CLASSIFIED ACCESS TERMINAL",
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 12,
                  letterSpacing: 3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _ScanLine extends StatefulWidget {
  const _ScanLine();

  @override
  State<_ScanLine> createState() => _ScanLineState();
}

class _ScanLineState extends State<_ScanLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Positioned(
          top: MediaQuery.of(context).size.height *
              _controller.value,
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            color: Colors.greenAccent.withOpacity(0.15),
          ),
        );
      },
    );
  }
}
