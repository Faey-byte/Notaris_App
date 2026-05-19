import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:notaris_app/Controller/Splash_screen_controller.dart';


class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SplashBody();
  }
}

// ─── Body (StatefulWidget untuk animasi) ─────────────────────────────────────

class _SplashBody extends StatefulWidget {
  const _SplashBody();

  @override
  State<_SplashBody> createState() => _SplashBodyState();
}

class _SplashBodyState extends State<_SplashBody>
    with TickerProviderStateMixin {
  // Logo entrance
  late final AnimationController _logoCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  // Loading dots
  late final AnimationController _dotCtrl;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    _scaleAnim = Tween<double>(begin: 0.70, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();

    _logoCtrl.forward();
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _dotCtrl.dispose();
    super.dispose();
  }

  // ─── Loading dot ─────────────────────────────────────────────────────────────

  Widget _dot(int index) {
    return AnimatedBuilder(
      animation: _dotCtrl,
      builder: (_, __) {
        final double phase =
            math.sin((_dotCtrl.value * 2 * math.pi) - (index * 0.7));
        final double opacity = ((phase + 1) / 2).clamp(0.15, 1.0);
        final double dy = phase * 5.0;

        return Transform.translate(
          offset: Offset(0, dy),
          child: Opacity(
            opacity: opacity,
            child: Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFA63020),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Stack(
        children: [
          // Warm radial glow di belakang logo
          Center(
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFA63020).withOpacity(0.09),
                    const Color.fromARGB(0, 255, 255, 255),
                  ],
                ),
              ),
            ),
          ),

          // Logo tengah layar
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Image.asset(
                  'assets/logo_splash.gif',
                  width: 155,
                  height: 155,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Loading dots bawah
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [_dot(0), _dot(1), _dot(2)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}