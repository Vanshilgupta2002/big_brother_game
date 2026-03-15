import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

enum BriefingStage { boot, test, warning, ready }

class OperatorBriefing extends StatefulWidget {
  final VoidCallback onStart;

  const OperatorBriefing({super.key, required this.onStart});

  @override
  State<OperatorBriefing> createState() => _OperatorBriefingState();
}

class _OperatorBriefingState extends State<OperatorBriefing>
    with SingleTickerProviderStateMixin {

  BriefingStage stage = BriefingStage.boot;

  String bootText = "";
  final String fullBootText =
      "INITIALIZING SURVEILLANCE GRID...\n"
      "AUTHORITY PROTOCOL ONLINE...\n"
      "OPERATOR STATUS: UNVERIFIED\n\n"
      "COMMENCING QUALIFICATION TEST.";

  bool showRebel = false;
  bool tapped = false;
  String message = "";

  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  int _dotCount = 0;
  Timer? _dotTimer;

  bool _connecting = false;
  bool _collapse = false;

  AudioSource? _briefingAudio;
  SoundHandle? _briefingHandle;
  AudioSource? _clickSound;

  @override
  void initState() {
    super.initState();

    _scanController =
    AnimationController(vsync: this, duration: const Duration(seconds: 6))
      ..repeat();

    _scanAnimation =
        Tween(begin: 0.0, end: 1.0).animate(_scanController);

    _initAudioAndType();

    _dotTimer = Timer.periodic(
      const Duration(milliseconds: 400),
          (timer) {
        if (!mounted) return;
        setState(() {
          _dotCount = (_dotCount + 1) % 4;
        });
      },
    );
  }

  Future<void> _initAudioAndType() async {
    try {
      _briefingAudio = await SoLoud.instance.loadAsset('assets/audio/briefing.mp3');
      _clickSound = await SoLoud.instance.loadAsset('assets/audio/click.mp3');
    } catch (e) {
      debugPrint("Failed to load briefing audio: $e");
    }

    _typeBootText();
  }

  void _typeBootText() async {
    if (_briefingAudio != null) {
      // You can increase or decrease the volume here. 
      // 1.0 is default max, 0.5 is half, 2.0 is double.
      _briefingHandle = await SoLoud.instance.play(
        _briefingAudio!,
        volume: 2.0,
      );
    }

    for (int i = 0; i < fullBootText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 65));
      if (!mounted) return;
      setState(() {
        bootText = fullBootText.substring(0, i + 1);
      });
    }

    if (_briefingHandle != null) {
      await SoLoud.instance.stop(_briefingHandle!);
    }

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => stage = BriefingStage.test);

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => showRebel = true);
  }

  void _handleTap(bool tappedRebel) async {
    if (tapped) return;

    if (_clickSound != null) {
      SoLoud.instance.play(_clickSound!);
    }

    if (tappedRebel) {
      tapped = true;
      message = "RESPONSE ACCEPTABLE.";
      setState(() {});

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() => stage = BriefingStage.warning);

      await Future.delayed(const Duration(seconds: 3));
      if (!mounted) return;
      setState(() => stage = BriefingStage.ready);
    } else {
      // Wrong target selected
      setState(() {
        message = "ERROR: CIVILIAN ENGAGEMENT.\nIDENTIFY HOSTILE.";
      });

      // Show error briefly then clear to allow retry
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      setState(() {
        message = "";
      });
    }
  }

  void _startConnection() async {
    if (_clickSound != null) {
      SoLoud.instance.play(_clickSound!);
    }
    
    setState(() {
      _connecting = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    setState(() {
      _collapse = true;
    });

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    widget.onStart();
  }

  @override
  void dispose() {
    _dotTimer?.cancel();
    _scanController.dispose();
    if (_briefingHandle != null) {
      SoLoud.instance.stop(_briefingHandle!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070707),
      body: Stack(
        children: [

          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.4,
                colors: [
                  Color(0xFF220000),
                  Color(0xFF070707),
                ],
              ),
            ),
          ),

          // Moving scan line
          AnimatedBuilder(
            animation: _scanAnimation,
            builder: (_, __) {
              return Positioned(
                top: MediaQuery.of(context).size.height *
                    _scanAnimation.value,
                left: 0,
                right: 0,
                child: Container(
                  height: 2,
                  color: Colors.greenAccent.withOpacity(0.1),
                ),
              );
            },
          ),

          // Main animated card
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              width: _collapse ? 0 : 760,
              padding: _collapse
                  ? EdgeInsets.zero
                  : const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                border: Border.all(
                    color: Colors.greenAccent.withOpacity(0.6)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.greenAccent.withOpacity(0.15),
                    blurRadius: 25,
                  )
                ],
              ),
              child: _collapse
                  ? null
                  : AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _buildStage(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStage() {
    switch (stage) {

      case BriefingStage.boot:
        return Text(
          bootText,
          key: const ValueKey("boot"),
          style: const TextStyle(
            color: Colors.greenAccent,
            height: 1.6,
            letterSpacing: 1.5,
          ),
        );

      case BriefingStage.test:
        return Column(
          key: const ValueKey("test"),
          mainAxisSize: MainAxisSize.min,
          children: [

            const Text(
              "IDENTIFY HOSTILE TARGET",
              style: TextStyle(
                color: Colors.white,
                letterSpacing: 3,
              ),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTarget(showRebel),
                _buildTarget(false),
              ],
            ),

            const SizedBox(height: 20),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: message == "RESPONSE ACCEPTABLE."
                    ? Colors.greenAccent
                    : Colors.redAccent,
                letterSpacing: 1.5,
              ),
            )
          ],
        );

      case BriefingStage.warning:
        return const Text(
          "NOTICE:\n\n"
              "All operator decisions are logged.\n"
              "Civilian interference reduces stability.\n"
              "Authority misuse will be recorded.",
          key: ValueKey("warning"),
          style: TextStyle(
            color: Colors.white70,
            height: 1.7,
            letterSpacing: 1.3,
          ),
        );

      case BriefingStage.ready:
        return Column(
          key: const ValueKey("ready"),
          mainAxisSize: MainAxisSize.min,
          children: [

            if (!_connecting) ...[
              const Text(
                "AUTHORIZATION GRANTED.",
                style: TextStyle(
                  color: Colors.greenAccent,
                  letterSpacing: 3,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              OutlinedButton(
                onPressed: _startConnection,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.greenAccent),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                ),
                child: Text(
                  "BEGIN MONITORING${'.' * _dotCount}",
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    letterSpacing: 2,
                    fontSize: 14,
                  ),
                ),
              ),
            ],

            if (_connecting)
              const Text(
                "LIVE FEED CONNECTING...",
                style: TextStyle(
                  color: Colors.greenAccent,
                  letterSpacing: 2,
                ),
              ),
          ],
        );
    }
  }

  Widget _buildTarget(bool rebel) {
    return GestureDetector(
      onTap: () => _handleTap(rebel),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: rebel
              ? Colors.redAccent.withOpacity(0.25)
              : Colors.greenAccent.withOpacity(0.1),
          border: Border.all(
            color: rebel ? Colors.redAccent : Colors.greenAccent,
            width: rebel ? 3 : 1.5,
          ),
          boxShadow: rebel
              ? [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.4),
              blurRadius: 15,
            )
          ]
              : [],
        ),
      ),
    );
  }
}
