import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:student_portal/providers/auth_provider.dart';
import 'package:student_portal/screens/otp_screen.dart';
import 'package:student_portal/screens/registration_screen.dart';
import 'package:student_portal/utils/app_colors.dart';
import 'package:student_portal/utils/app_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _mobileController = TextEditingController();

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    // Base width of 375 for scaling
    final double scaleFactor = (screenWidth / 375.0).clamp(0.8, 1.2);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.darkBg,
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            height: size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black,
                  AppColors.darkBlueGradient,
                  AppColors.deepAccent,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: Column(
              children: [
                // Top Header Section (Non-Scrollable)
                Expanded(
                  flex: 35,
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.0 * scaleFactor,
                        vertical: 20 * scaleFactor,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Sign In Steps
                          Row(
                            children: [
                              Container(
                                width: 30 * scaleFactor,
                                height: 2,
                                color: AppColors.primaryAccent,
                              ),
                              SizedBox(width: 8 * scaleFactor),
                              Text(
                                'SIGN IN',
                                style: AppFonts.main(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 11 * scaleFactor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20 * scaleFactor),
                          // Heading
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: RichText(
                              text: TextSpan(
                                style: AppFonts.main(
                                  fontSize: 42 * scaleFactor,
                                  height: 1.1,
                                  fontWeight: FontWeight.w900,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'WELCOME\n',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  TextSpan(
                                    text: 'BACK, CHAMPION',
                                    style: TextStyle(
                                      color: AppColors.primaryAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 50 * scaleFactor),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Form Section (Non-Scrollable)
                Expanded(
                  flex: 55,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 28 * scaleFactor,
                          vertical: 32 * scaleFactor,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Mobile Verification Header
                            Row(
                              children: [
                                Container(
                                  width: 32 * scaleFactor,
                                  height: 32 * scaleFactor,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black,
                                  ),
                                  child: Icon(
                                    Icons.smartphone_rounded,
                                    color: Colors.white,
                                    size: 16 * scaleFactor,
                                  ),
                                ),
                                SizedBox(width: 12 * scaleFactor),
                                Text(
                                  'MOBILE VERIFICATION',
                                  style: AppFonts.main(
                                    color: Colors.black,
                                    fontSize: 14 * scaleFactor,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const Spacer(),
                                Expanded(
                                  child: Container(
                                    height: 1.5,
                                    color: Colors.black12,
                                  ),
                                ),
                                SizedBox(width: 8 * scaleFactor),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.primaryAccent,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15 * scaleFactor),

                            // Phone Input
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16 * scaleFactor,
                                    vertical: 18 * scaleFactor,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.black12),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        'IN',
                                        style: AppFonts.main(
                                          color: Colors.black54,
                                          fontSize: 14 * scaleFactor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 8 * scaleFactor),
                                      Text(
                                        '+91',
                                        style: AppFonts.main(
                                          color: Colors.black,
                                          fontSize: 16 * scaleFactor,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12 * scaleFactor),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 20 * scaleFactor,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: Colors.black12),
                                    ),
                                    child: TextField(
                                      controller: _mobileController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      maxLength: 10,
                                      style: AppFonts.main(
                                        fontSize: 18 * scaleFactor,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black,
                                        letterSpacing: 2,
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        counterText: '',
                                        hintText: '00000 00000',
                                        hintStyle: TextStyle(
                                          color: Colors.black12,
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "WE'LL SEND A 6-DIGIT OTP FOR VERIFICATION",
                              style: AppFonts.main(
                                color: Colors.black45,
                                fontSize: 10 * scaleFactor,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                            const Spacer(),

                            // GET OTP Button
                            Consumer<AuthProvider>(
                              builder: (context, authProvider, child) {
                                return Container(
                                  width: double.infinity,
                                  height: 60 * scaleFactor,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.secondaryAccent,
                                        AppColors.primaryAccent,
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryAccent
                                            .withOpacity(0.4),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: authProvider.isLoading
                                        ? null
                                        : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: authProvider.isLoading
                                        ? const CircularProgressIndicator(
                                            color: Colors.white,
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'GET OTP',
                                                style: AppFonts.main(
                                                  color: Colors.white,
                                                  fontSize: 18 * scaleFactor,
                                                  fontWeight: FontWeight.w900,
                                                  letterSpacing: 1.5,
                                                ),
                                              ),
                                              SizedBox(width: 8 * scaleFactor),
                                              Icon(
                                                Icons.arrow_forward_rounded,
                                                color: Colors.white,
                                                size: 20 * scaleFactor,
                                              ),
                                            ],
                                          ),
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: 16 * scaleFactor),
                            // Security Info
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.verified_user_outlined,
                                  color: Colors.green,
                                  size: 16 * scaleFactor,
                                ),
                                SizedBox(width: 8 * scaleFactor),
                                Text(
                                  'ENCRYPTED · SECURE · PRIVATE',
                                  style: AppFonts.main(
                                    color: Colors.black45,
                                    fontSize: 11 * scaleFactor,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ],
                            ),

                            const Spacer(),
                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.black12,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16 * scaleFactor,
                                  ),
                                  child: Text(
                                    'OR',
                                    style: AppFonts.main(
                                      color: Colors.black26,
                                      fontSize: 12 * scaleFactor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: Colors.black12,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),

                            // Register Button
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegistrationScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                height: 60 * scaleFactor,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'NEW ATHLETE? REGISTER',
                                    style: AppFonts.main(
                                      color: Colors.black,
                                      fontSize: 14 * scaleFactor,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Future<void> _handleLogin() async {
    if (_mobileController.text.isNotEmpty) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.sendOtp(_mobileController.text);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('OTP sent to ${_mobileController.text}'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  OtpScreen(mobileNumber: _mobileController.text),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Failed to send OTP'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter your mobile number'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}
