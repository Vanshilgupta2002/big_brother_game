import 'dart:async';
import 'package:flutter/material.dart';

class IdentificationProtocol extends StatefulWidget {
  final VoidCallback onContinue;

  const IdentificationProtocol({super.key, required this.onContinue});

  @override
  State<IdentificationProtocol> createState() =>
      _IdentificationProtocolState();
}

class _IdentificationProtocolState
    extends State<IdentificationProtocol>
    with SingleTickerProviderStateMixin {

  late AnimationController _glowController;
  late Animation<double> _glow;
  bool _cursor = true;

  @override
  void initState() {
    super.initState();

    _glowController =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);

    _glow = Tween(begin: 0.6, end: 1.0).animate(_glowController);

    Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (!mounted) return;
      setState(() => _cursor = !_cursor);
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: Stack(
        children: [

          // Subtle gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.4,
                colors: [
                  Color(0xFF220000),
                  Color(0xFF080808),
                ],
              ),
            ),
          ),

          Center(
            child: AnimatedBuilder(
              animation: _glow,
              builder: (_, __) {
                return Container(
                  width: 800,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    border: Border.all(
                        color:
                        Colors.greenAccent.withOpacity(_glow.value),
                        width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.greenAccent
                            .withOpacity(_glow.value * 0.2),
                        blurRadius: 25,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      const Text(
                        "VISUAL IDENTIFICATION PROTOCOL",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          letterSpacing: 3,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 25),

                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                        children: const [

                          Expanded(
                            child: _SignaturePanel(
                              color: Colors.redAccent,
                              title: "HOSTILE SIGNATURE",
                              description:
                              "Neutralize Immediately",
                            ),
                          ),

                          SizedBox(width: 12),

                          Expanded(
                            child: _SignaturePanel(
                              color: Colors.greenAccent,
                              title: "CIVILIAN SIGNATURE",
                              description:
                              "Do NOT Engage",
                            ),
                          ),

                          SizedBox(width: 12),

                          Expanded(
                            child: _SignaturePanel(
                              color: Colors.amber,
                              title: "PRIORITY TARGET",
                              description: "+1 Stability\nEliminates 2 Threats",
                            ),
                          ),

                        ],
                      ),

                      const SizedBox(height: 35),

                      FadeTransition(
                        opacity: _glow,
                        child: OutlinedButton(
                          onPressed: widget.onContinue,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Colors.greenAccent),
                          ),
                          child: Text(
                            "PROCEED TO QUALIFICATION ${_cursor ? "_" : " "}",
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SignaturePanel extends StatelessWidget {
  final Color color;
  final String title;
  final String description;

  const _SignaturePanel({
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(0.7)),
      ),
      child: Column(
        children: [

          Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              border: Border.all(color: color, width: 2),
            ),
          ),

          const SizedBox(height: 15),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
