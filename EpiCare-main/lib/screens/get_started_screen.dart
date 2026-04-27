import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size; 
    final logoSize = size.width * 0.35; 
    final buttonHeight = size.height * 0.07; 
    final titleFontSize = size.width * 0.12; 
    final subtitleFontSize = size.width * 0.05; 
    final descFontSize = size.width * 0.035;
    final featureIconSize = size.width * 0.14; 
    final featureIconInnerSize = featureIconSize * 0.5; 

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2DD4BF),
              Color(0xFF14B8A6),
              Color(0xFF0D9488),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.08,
              vertical: size.height * 0.05,
            ),
            child: Column(
              children: [
                const Spacer(flex: 1),

                // Logo Container
                Container(
                  width: logoSize,
                  height: logoSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(logoSize * 0.18),
                    child: Image.asset(
                      "assets/images/Vector.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.05),

                // App Name
                Text(
                  "app_name_short".tr(),
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    shadows: const [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: size.height * 0.015),

                // Subtitle
                Text(
                  "epilepsy_care".tr(),
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),

                SizedBox(height: size.height * 0.01),

                // Description
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  child: Text(
                    "continuous_health_monitoring".tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: descFontSize,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Features Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFeatureIcon(Icons.favorite_rounded, "health_feature".tr(), featureIconSize, featureIconInnerSize),
                    SizedBox(width: size.width * 0.08),
                    _buildFeatureIcon(Icons.notifications_active_rounded, "alerts_feature".tr(), featureIconSize, featureIconInnerSize),
                    SizedBox(width: size.width * 0.08),
                    _buildFeatureIcon(Icons.security_rounded, "security_feature".tr(), featureIconSize, featureIconInnerSize),
                  ],
                ),

                const Spacer(flex: 1),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0D9488),
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(buttonHeight / 2),
                      ),
                    ),
                    child: Text(
                      "create_account".tr(),
                      style: TextStyle(
                        fontSize: size.width * 0.045,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.02),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: buttonHeight,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(buttonHeight / 2),
                      ),
                    ),
                    child: Text(
                      "login".tr(),
                      style: TextStyle(
                        fontSize: size.width * 0.045,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.04),

                // Terms
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.05),
                  child: Text(
                    "terms_agreement".tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: size.width * 0.03,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label, double size, double innerSize) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: innerSize,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
