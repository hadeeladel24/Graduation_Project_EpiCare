import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:easy_localization/easy_localization.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;
  final _dbRef = FirebaseDatabase.instance.ref("users");

  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final birthDateController = TextEditingController();
  final diagnosisDateController = TextEditingController();

  bool agreeToTerms = false;
  bool acceptPrivacy = false;
  bool enableNotifications = false;
  bool agreeToHealthInfo = false;
  bool isLoading = false;
  String? errorMessage;

  Future<int> _getNextUserNumber() async {
    final DatabaseReference counterRef = FirebaseDatabase.instance.ref('user_counter');

    try {
      final TransactionResult result = await counterRef.runTransaction((currentValue) {
        int currentNumber = 0;
        if (currentValue != null && currentValue is int) {
          currentNumber = currentValue;
        }
        return Transaction.success(currentNumber + 1);
      });

      if (result.committed && result.snapshot.value != null) {
        return result.snapshot.value as int;
      } else {
        await counterRef.set(1);
        return 1;
      }
    } catch (e) {
      final snapshot = await counterRef.get();
      if (snapshot.exists && snapshot.value != null) {
        int currentValue = snapshot.value as int;
        await counterRef.set(currentValue + 1);
        return currentValue + 1;
      } else {
        await counterRef.set(1);
        return 1;
      }
    }
  }

  Future<void> register() async {
    if (!agreeToTerms || !acceptPrivacy || !enableNotifications || !agreeToHealthInfo) {
      setState(() => errorMessage = "agree_all_terms".tr());
      return;
    }

    if (fullNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        phoneController.text.isEmpty ||
        birthDateController.text.isEmpty ||
diagnosisDateController.text.isEmpty
) {
      setState(() => errorMessage = "fill_all_fields_register".tr());
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      int userNumber = await _getNextUserNumber();

      await _dbRef.child(userCredential.user!.uid).set({
        "fullName": fullNameController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "birthDate": birthDateController.text.trim(),
        "diagnosis_date": diagnosisDateController.text.trim(),
        "user_number": userNumber,
        "createdAt": DateTime.now().toIso8601String(),
      });

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => errorMessage = e.message);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: width * 0.05),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  SizedBox(height: height * 0.02),
                  // أيقونة التطبيق
                  Container(
                    width: width * 0.15,
                    height: width * 0.15,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4C6FFF), Color(0xFF5B7CFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(width * 0.035),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Icon(
                            Icons.monitor_heart_outlined,
                            color: Colors.white,
                            size: width * 0.075,
                          ),
                        ),
                        Positioned(
                          top: width * 0.018,
                          right: width * 0.018,
                          child: Container(
                            width: width * 0.022,
                            height: width * 0.022,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E676),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.01),
                  Text(
                    'app_name'.tr(),
                    style: TextStyle(
                      fontSize: width * 0.048,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: height * 0.004),
                  Text(
                    'health_companion'.tr(),
                    style: TextStyle(
                      fontSize: width * 0.033,
                      color: const Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: height * 0.025),
                  Container(
                    padding: EdgeInsets.all(width * 0.045),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(width * 0.04),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'create_account'.tr(),
                          style: TextStyle(
                            fontSize: width * 0.045,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: height * 0.004),
                        Text(
                          'join_health_family'.tr(),
                          style: TextStyle(
                            fontSize: width * 0.03,
                            color: const Color(0xFF9CA3AF),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: height * 0.02),
                        
                        _buildTextField(fullNameController, 'full_name_en'.tr(),
                            Icons.person_outline, 'full_name_en_placeholder'.tr(), width),
                        SizedBox(height: height * 0.015),
                        _buildTextField(emailController, 'email'.tr(), Icons.email_outlined,
                            'email_hint'.tr(), width,
                            keyboardType: TextInputType.emailAddress),
                        SizedBox(height: height * 0.015),
                        _buildTextField(passwordController, 'password'.tr(), Icons.lock_outline,
                            '••••••••', width,
                            obscureText: true),
                        SizedBox(height: height * 0.015),
                        _buildTextField(phoneController, 'phone'.tr(), Icons.phone_outlined,
                            'phone_placeholder'.tr(), width,
                            keyboardType: TextInputType.phone),
                        SizedBox(height: height * 0.015),
                        _buildTextField(birthDateController, 'birth_date'.tr(),
                            Icons.calendar_today_outlined, 'birth_date_placeholder'.tr(), width),
                        SizedBox(height: height * 0.02),
                        _buildTextField(
  diagnosisDateController,
  'diagnosis_date'.tr(),
  Icons.calendar_today_outlined,
  'diagnosis_date_placeholder'.tr(),
  width,
),
SizedBox(height: height * 0.015),

                        Container(
                          padding: EdgeInsets.all(width * 0.035),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(width * 0.025),
                            border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
                          ),
                          child: Column(
                            children: [
                              _buildCheckbox(agreeToTerms, 'agree_terms'.tr(), (val) => setState(() => agreeToTerms = val!), width),
                              SizedBox(height: height * 0.003),
                              _buildCheckbox(acceptPrivacy, 'accept_privacy'.tr(), (val) => setState(() => acceptPrivacy = val!), width),
                              SizedBox(height: height * 0.003),
                              _buildCheckbox(enableNotifications, 'enable_notifications'.tr(), (val) => setState(() => enableNotifications = val!), width),
                              SizedBox(height: height * 0.003),
                              _buildCheckbox(agreeToHealthInfo, 'share_health_data'.tr(), (val) => setState(() => agreeToHealthInfo = val!), width),
                            ],
                          ),
                        ),
                        SizedBox(height: height * 0.02),
                        if (errorMessage != null)
                          Container(
                            padding: EdgeInsets.all(width * 0.025),
                            margin: EdgeInsets.only(bottom: height * 0.015),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(width * 0.02),
                              border: Border.all(color: const Color(0xFFFECACA)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline, color: const Color(0xFFDC2626), size: width * 0.04),
                                SizedBox(width: width * 0.02),
                                Expanded(
                                  child: Text(
                                    errorMessage!,
                                    style: TextStyle(color: const Color(0xFFDC2626), fontSize: width * 0.03),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(
                          width: double.infinity,
                          height: height * 0.06,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4C6FFF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(width * 0.025),
                              ),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? SizedBox(
                                    width: width * 0.055,
                                    height: width * 0.055,
                                    child: const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'create_account_button'.tr(),
                                        style: TextStyle(
                                          fontSize: width * 0.038,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: width * 0.02),
                                      Icon(Icons.arrow_forward, size: width * 0.042),
                                    ],
                                  ),
                          ),
                        ),
                        SizedBox(height: height * 0.015),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                );
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'login'.tr(),
                                style: TextStyle(
                                  color: const Color(0xFF4C6FFF),
                                  fontWeight: FontWeight.w600,
                                  fontSize: width * 0.033,
                                ),
                              ),
                            ),
                            Text(
                              'already_have_account'.tr(),
                              style: TextStyle(
                                color: const Color(0xFF6B7280),
                                fontSize: width * 0.033,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        color: const Color(0xFF9CA3AF),
                        size: width * 0.035,
                      ),
                      SizedBox(width: width * 0.015),
                      Flexible(
                        child: Text(
                          'data_protected'.tr(),
                          style: TextStyle(
                            color: const Color(0xFF9CA3AF),
                            fontSize: width * 0.028,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.02),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      String? placeholder, double width,
      {bool obscureText = false, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 5, right: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: width * 0.033,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF374151),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: width * 0.015),
              Icon(icon, size: width * 0.04, color: const Color(0xFF4C6FFF)),
            ],
          ),
        ),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: width * 0.036, color: const Color(0xFF1F2937)),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: const Color(0xFFD1D5DB), fontSize: width * 0.033),
            filled: true,
            fillColor: const Color(0xFFFAFAFA),
            contentPadding: EdgeInsets.symmetric(horizontal: width * 0.035, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(width * 0.02),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(width * 0.02),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(width * 0.02),
              borderSide: const BorderSide(color: Color(0xFF4C6FFF), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckbox(bool value, String text, Function(bool?) onChanged, double width) {
    return SizedBox(
      child: Row(
        children: [
          SizedBox(
            width: width * 0.045,
            height: width * 0.045,
            child: Checkbox(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF4C6FFF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
              side: const BorderSide(color: Color(0xFF93C5FD), width: 1.5),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          SizedBox(width: width * 0.02),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: width * 0.03, color: const Color(0xFF4B5563), height: 1.3),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
void dispose() {
  fullNameController.dispose();
  emailController.dispose();
  passwordController.dispose();
  phoneController.dispose();
  birthDateController.dispose();
  diagnosisDateController.dispose();  
  super.dispose();
}

}
