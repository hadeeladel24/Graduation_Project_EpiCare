import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'main_screen.dart';
import 'dart:math' as math;
import 'package:easy_localization/easy_localization.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _dotController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _dotController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();

    _navigateNext();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  void _navigateNext() async {
    await Future.delayed(const Duration(seconds: 5));

    final user = FirebaseAuth.instance.currentUser;
    if (!mounted) return;

    if (user == null) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final screenHeight = media.size.height;

    // نسخ حجم الأيقونات والـ padding لتكون متناسبة
    final mainIconSize = screenWidth * 0.35; // 140px تقريبا
    final cornerIconSize = screenWidth * 0.08; // 32px تقريبا
    final iconInnerSize = cornerIconSize * 0.5;
    final verticalSpacing = screenHeight * 0.02;
    final horizontalPadding = screenWidth * 0.1;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2563EB),
              Color(0xFF1E40AF),
              Color(0xFF1E3A8A),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Logo with animation
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: mainIconSize,
                        height: mainIconSize,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(mainIconSize * 0.14),
                          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.monitor_heart_outlined,
                            color: Colors.white,
                            size: mainIconSize * 0.43, // 60px تقريبًا
                          ),
                        ),
                      ),
                      // Corner icons
                      Positioned(
                        top: -cornerIconSize * 0.25,
                        left: -cornerIconSize * 0.25,
                        child: _cornerIcon(Icons.person_outline, const Color(0xFF3B82F6), cornerIconSize, iconInnerSize),
                      ),
                      Positioned(
                        top: -cornerIconSize * 0.25,
                        right: -cornerIconSize * 0.25,
                        child: _cornerIcon(Icons.check, const Color(0xFF10B981), cornerIconSize, iconInnerSize),
                      ),
                      Positioned(
                        bottom: -cornerIconSize * 0.25,
                        left: -cornerIconSize * 0.25,
                        child: _cornerIcon(Icons.favorite_outline, const Color(0xFFEC4899), cornerIconSize, iconInnerSize),
                      ),
                      Positioned(
                        bottom: -cornerIconSize * 0.25,
                        right: -cornerIconSize * 0.25,
                        child: _cornerIcon(Icons.access_time, const Color(0xFF8B5CF6), cornerIconSize, iconInnerSize),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: verticalSpacing),

                // App name
                Text(
                  "app_name".tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.07,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),

                SizedBox(height: verticalSpacing * 0.8),

                // Subtitle with lines
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: screenWidth * 0.15, height: 1.5, color: Colors.white.withOpacity(0.4)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                      child: Text(
                        'EpiGuard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Container(width: screenWidth * 0.15, height: 1.5, color: Colors.white.withOpacity(0.4)),
                  ],
                ),

                SizedBox(height: verticalSpacing * 0.6),

                // Description text
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Text(
                    "app_subtitle".tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: screenWidth * 0.035,
                      height: 1.4,
                    ),
                  ),
                ),

                const Spacer(),

                SizedBox(height: verticalSpacing * 1.5),

                // Loading dots
                AnimatedBuilder(
                  animation: _dotController,
                  builder: (context, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final delay = index * 0.33;
                        final value = (_dotController.value - delay) % 1.0;
                        final opacity = (math.sin(value * math.pi * 2) + 1) / 2;
                        final scale = 0.6 + (opacity * 0.4);

                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                          child: Transform.scale(
                            scale: scale,
                            child: Container(
                              width: screenWidth * 0.02,
                              height: screenWidth * 0.02,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5 + (opacity * 0.5)),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),

                SizedBox(height: verticalSpacing * 0.4),

                // Loading text
                Text(
                  "loading".tr(),
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: screenWidth * 0.035,
                  ),
                ),

                SizedBox(height: verticalSpacing * 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cornerIcon(IconData icon, Color color, double size, double innerSize) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Icon(icon, color: Colors.white, size: innerSize),
      ),
    );
  }
}
