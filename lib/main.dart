import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:pinput/pinput.dart';
import 'parent.dart';
import 'child.dart';


void main() {
  runApp(const ADHDCompanionApp());
}

const primaryColor = Color(0xFF7566D9);
const backgroundColor = Color(0xFFF8F7FF);

class ADHDCompanionApp extends StatelessWidget {
  const ADHDCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ADHD Companion',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
        ),
        scaffoldBackgroundColor: backgroundColor,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

// ---------------- WELCOME SCREEN ----------------

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),

      body: Stack(
        children: [
          // Background decoration at the bottom of the screen.
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(
                MediaQuery.of(context).size.width,
                75,
              ),
              painter: WelcomeWavePainter(),
            ),
          ),

          // Main screen content.
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),

                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 20,
                      ),

                      child: Column(
                        children: [
                          const SizedBox(height: 75),

                          // App logo.
                          Image.asset(
                            'images/image.png',
                            width: 115,
                            height: 115,
                            fit: BoxFit.contain,
                          ),

                          const SizedBox(height: 8),

                          // App name.
                          const Text(
                            'MΛZID',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7566D9),
                            ),
                          ),

                          const SizedBox(height: 2),

                          // App subtitle.
                          const Text(
                            'ADHD Parent Support',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF30285E),
                            ),
                          ),

                          const SizedBox(height: 100),

                          // Main heading.
                          const Text(
                            'A Brighter Journey\nfor Your Child',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 27,
                              height: 1.15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF30285E),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Short app description.
                          const Text(
                            'Track progress, get helpful guidance,\n'
                            'and work together with your doctor.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.6,
                              color: Color(0xFF85809F),
                            ),
                          ),

                          const SizedBox(height: 50),

                          // Get Started navigates to account creation.
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const CreateAccountScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF7566E8),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: const StadiumBorder(),
                              ),
                              child: const Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Sign In navigates to the login screen.
                          SizedBox(
                            width: double.infinity,
                            height: 58,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const EmailSignInScreen(),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    const Color(0xFF7566D9),
                                side: const BorderSide(
                                  color: Color(0xFF7566D9),
                                  width: 1.5,
                                ),
                                shape: const StadiumBorder(),
                              ),
                              child: const Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 85),
                        ],
                      ),
                    ),
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


// ---------------- WELCOME BACKGROUND WAVE ----------------

// Draws the soft wave decoration shown at the bottom of the design.
class WelcomeWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF0ECFF)
      ..style = PaintingStyle.fill;

    final path = Path();

    path.moveTo(0, size.height * 0.35);

    path.quadraticBezierTo(
      size.width * 0.20,
      size.height * -0.10,
      size.width * 0.42,
      size.height * 0.48,
    );

    path.quadraticBezierTo(
      size.width * 0.70,
      size.height * 1.10,
      size.width,
      size.height * 0.20,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WelcomeWavePainter oldDelegate) {
    return false;
  }
}


// ---------------- CREATE ACCOUNT ----------------

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  // Used to validate all fields inside the form.
  final formKey = GlobalKey<FormState>();

  // Controllers read the values entered by the user.
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // Account settings.
  String role = 'Parent';
  DateTime? selectedDateOfBirth;

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool acceptedTerms = false;

  // Releases controllers when the screen is removed.
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Opens the date picker and saves the selected birth date.
  Future<void> selectDateOfBirth() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select your date of birth',
    );

    if (pickedDate != null && mounted) {
      setState(() {
        selectedDateOfBirth = pickedDate;
      });
    }
  }

  // Checks the form and moves to the existing verification screen.
  void continueToVerification() {
    // Validate the text fields first.
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Date of birth is required.
    if (selectedDateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your date of birth.'),
        ),
      );
      return;
    }

    // The user must accept the terms before continuing.
    if (!acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please accept the Terms of Service and Privacy Policy.',
          ),
        ),
      );
      return;
    }

    // Keep the existing verification flow and parameter names.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationChoiceScreen(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          phone: phoneController.text.trim(),
          password: passwordController.text,
          role: role,
        ),
      ),
    );
  }

  // Reusable field label.
  Widget fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF30285E),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8FF),
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Create Account',
          style: TextStyle(
            color: Color(0xFF30285E),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),

          child: Form(
            key: formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Screen heading.
                const Text(
                  'Create your account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF30285E),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Let’s get to know you and start your journey together.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 26),

                // Account type.
                fieldLabel('Account type'),

                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: const InputDecoration(
                    hintText: 'Select account type',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(14),
                      ),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Parent',
                      child: Text('Parent'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        role = value;
                      });
                    }
                  },
                ),

                const SizedBox(height: 18),

                // Full name.
                fieldLabel('Full name'),

                TextFormField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(14),
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your full name.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Email address.
                fieldLabel('Email address'),

                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    hintText: 'name@example.com',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(14),
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email.';
                    }

                    if (!RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(value.trim())) {
                      return 'Please enter a valid email address.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Mobile number.
                fieldLabel('Mobile number'),

                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: '+20 1xxxxxxxxx',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(14),
                      ),
                    ),
                  ),
                  validator: (value) {
                    final phone = value?.trim() ?? '';

                    if (phone.isEmpty) {
                      return 'Please enter your mobile number.';
                    }

                    // Allow common phone-number characters.
                    final digits = phone.replaceAll(
                      RegExp(r'[^0-9]'),
                      '',
                    );

                    if (digits.length < 8 || digits.length > 15) {
                      return 'Please enter a valid mobile number.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Date of birth.
                fieldLabel('Date of birth'),

                InkWell(
                  onTap: selectDateOfBirth,
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      hintText: 'Select your date of birth',
                      prefixIcon: Icon(Icons.calendar_month_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(14),
                        ),
                      ),
                    ),
                    child: Text(
                      selectedDateOfBirth == null
                          ? 'Select your date of birth'
                          : '${selectedDateOfBirth!.day.toString().padLeft(2, '0')}/'
                            '${selectedDateOfBirth!.month.toString().padLeft(2, '0')}/'
                            '${selectedDateOfBirth!.year}',
                      style: TextStyle(
                        color: selectedDateOfBirth == null
                            ? Colors.black54
                            : const Color(0xFF30285E),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Password.
                fieldLabel('Password'),

                TextFormField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: 'At least 8 characters',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip: hidePassword
                          ? 'Show password'
                          : 'Hide password',
                      icon: Icon(
                        hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(14),
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 8) {
                      return 'Use at least 8 characters.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Confirm password.
                fieldLabel('Confirm password'),

                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: hideConfirmPassword,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    hintText: 'Re-enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      tooltip: hideConfirmPassword
                          ? 'Show password'
                          : 'Hide password',
                      icon: Icon(
                        hideConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          hideConfirmPassword = !hideConfirmPassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(14),
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password.';
                    }

                    if (value != passwordController.text) {
                      return 'Passwords do not match.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // Terms and privacy consent.
                CheckboxListTile(
                  value: acceptedTerms,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: const Color(0xFF7566D9),
                  title: const Text(
                    'I agree to the Terms of Service and Privacy Policy.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: Color(0xFF30285E),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      acceptedTerms = value ?? false;
                    });
                  },
                ),

                const SizedBox(height: 24),

                // Continue to the existing email/SMS verification choice.
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: continueToVerification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7566D9),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: const StadiumBorder(),
                    ),
                    child: const Text(
                      'Continue to Verification',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Already have an account? Sign In',
                      style: TextStyle(
                        color: Color(0xFF7566D9),
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
}



// ---------------- VERIFICATION CHOICE SCREEN ----------------

class VerificationChoiceScreen extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String role;

  const VerificationChoiceScreen({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Your Account')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose a verification method',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Color(0xFF30285E),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Verify your email or mobile number to continue.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 28),

            verificationCard(
              icon: Icons.email_outlined,
              title: 'Verify by Email',
              subtitle: email,
onTap: () => Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => OTPVerificationScreen(
      destination: email,
      method: 'Email',
    ),
  ),
),
            ),

            const SizedBox(height: 16),

            verificationCard(
              icon: Icons.sms_outlined,
              title: 'Verify by SMS',
              subtitle: phone,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OTPVerificationScreen(
                    destination: phone,
                    method: 'SMS',
                  ),
                ),
              ),
            ),

            const Spacer(),

            const Text(
              'Email verification is connected. SMS verification is not available yet.',
              style: TextStyle(
                color: Colors.deepOrange,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- OTP SCREEN ----------------

class OTPVerificationScreen extends StatefulWidget {
  final String destination;
  final String method;

  const OTPVerificationScreen({
    super.key,
    required this.destination,
    required this.method,
  });

  @override
  State<OTPVerificationScreen> createState() =>
      _OTPVerificationScreenState();
}

class _OTPVerificationScreenState
    extends State<OTPVerificationScreen> {
  final codeController = TextEditingController();

  // Android Emulator uses this address to reach the computer hosting
  // the ASP.NET Core backend.
  static const String baseUrl = 'http://10.0.2.2:5187';

bool isSending = false;
bool isVerifying = false;
bool codeSent = false;

int resendCountdown = 0;
Timer? resendTimer;

@override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (widget.method == 'Email') {
      sendOtp();
    }
  });
}

@override
void dispose() {
  resendTimer?.cancel();
  codeController.dispose();
  super.dispose();
}

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String getErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (data is Map<String, dynamic>) {
        if (data['message'] != null) {
          return data['message'].toString();
        }

        if (data['detail'] != null) {
          return data['detail'].toString();
        }

        if (data['title'] != null) {
          return data['title'].toString();
        }
      }
    } catch (_) {
      // Use the fallback message if the response isn't JSON.
    }

    return 'Request failed (${response.statusCode}). Please try again.';
  }
void startResendCountdown() {
  resendTimer?.cancel();

  setState(() {
    resendCountdown = 60;
  });

  resendTimer = Timer.periodic(
    const Duration(seconds: 1),
    (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (resendCountdown <= 1) {
        timer.cancel();

        setState(() {
          resendCountdown = 0;
        });
      } else {
        setState(() {
          resendCountdown--;
        });
      }
    },
  );
}
  // ---------------- SEND OTP ----------------

  Future<void> sendOtp() async {
    if (widget.method != 'Email') {
      showMessage(
        'SMS verification is not connected yet.',
      );
      return;
    }

    if (isSending || isVerifying) return;

    setState(() {
      isSending = true;
    });

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/send-otp'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'email': widget.destination.trim(),
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (!mounted) return;

if (response.statusCode >= 200 &&
    response.statusCode < 300) {
  setState(() {
    codeSent = true;
  });

  startResendCountdown();

  showMessage(
    'Verification code sent to ${widget.destination}',
  );
}
       else {
        showMessage(getErrorMessage(response));
      }
    } catch (e) {
      showMessage(
        'Could not connect to the backend. '
        'Make sure the backend is running.',
      );
    } finally {
      if (mounted) {
        setState(() {
          isSending = false;
        });
      }
    }
  }

  // ---------------- VERIFY OTP ----------------

  Future<void> verifyOtp() async {
    if (widget.method != 'Email') {
      showMessage(
        'SMS verification is not connected yet.',
      );
      return;
    }

    final code = codeController.text.trim();

    if (code.length != 6 ||
        !RegExp(r'^[0-9]{6}$').hasMatch(code)) {
      showMessage('Please enter the 6-digit verification code.');
      return;
    }

    if (isSending || isVerifying) return;

    setState(() {
      isVerifying = true;
    });

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/verify-otp'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'email': widget.destination.trim(),
              'code': code,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (!mounted) return;

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        final data = jsonDecode(response.body);

        if (data is Map<String, dynamic> &&
            data['verified'] == true) {
          await showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => AlertDialog(
              icon: const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 56,
              ),
              title: const Text('Email Verified'),
              content: const Text(
                'Your email address has been verified successfully.',
              ),
              actions: [
                TextButton(
                 onPressed: () {
  Navigator.of(dialogContext).pop();

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => const ParentDashboardScreen(),
    ),
    (route) => false,
  );
},
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          showMessage('The server did not confirm verification.');
        }
      } else {
        showMessage(getErrorMessage(response));
      }
    } catch (e) {
      showMessage(
        'Could not connect to the backend. '
        'Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          isVerifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEmail = widget.method == 'Email';

    return Scaffold(
      appBar: AppBar(title: const Text('OTP Verification')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.verified_user_outlined,
                size: 75,
                color: primaryColor,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Verify your identity',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Destination: ${widget.destination}',
              style: const TextStyle(color: Colors.black54),
            ),

            const SizedBox(height: 24),

Center(
child: Pinput(
controller: codeController,
length: 6,
keyboardType: TextInputType.number,
defaultPinTheme: PinTheme(
width: 46,
height: 56,
textStyle: const TextStyle(
fontSize: 22,
fontWeight: FontWeight.w600,
color: primaryColor,
),
decoration: BoxDecoration(
color: Colors.white,
border: Border.all(color: Colors.grey.shade300),
borderRadius: BorderRadius.circular(12),
),
),
focusedPinTheme: PinTheme(
width: 46,
height: 56,
textStyle: const TextStyle(
fontSize: 22,
fontWeight: FontWeight.w600,
color: primaryColor,
),
decoration: BoxDecoration(
color: Colors.white,
border: Border.all(color: primaryColor, width: 2),
borderRadius: BorderRadius.circular(12),
),
),
submittedPinTheme: PinTheme(
width: 46,
height: 56,
textStyle: const TextStyle(
fontSize: 22,
fontWeight: FontWeight.w600,
color: primaryColor,
),
decoration: BoxDecoration(
color: const Color(0xFFF3EEFF),
border: Border.all(color: primaryColor),
borderRadius: BorderRadius.circular(12),
),
),
),
),



            const SizedBox(height: 8),

            Text(
              isEmail
                  ? (codeSent
                      ? 'Enter the code sent to your email. It expires in 5 minutes.'
                      : 'A verification code will be sent to your email.')
                  : 'SMS verification is not connected yet.',
              style: TextStyle(
                color: isEmail
                    ? Colors.black54
                    : Colors.deepOrange,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 24),

            appButton(
              text: isVerifying
                  ? 'Verifying...'
                  : 'Verify Code',
              onPressed: isVerifying || isSending
                  ? () {}
                  : verifyOtp,
            ),

Center(
  child: TextButton(
    onPressed: isSending ||
            isVerifying ||
            resendCountdown > 0
        ? null
        : sendOtp,
    child: Text(
      isSending
          ? 'Sending...'
          : resendCountdown > 0
              ? 'Resend Code (${resendCountdown}s)'
              : 'Resend Code',
    ),
  ),
),

            if (isSending)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}



// ---------------- SIGN IN ----------------

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back!',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Color(0xFF30285E),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Choose how you want to sign in.',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 30),
            verificationCard(
              icon: Icons.email_outlined,
              title: 'Email and Password',
              subtitle: 'Sign in with your existing account',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EmailSignInScreen(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            verificationCard(
              icon: Icons.phone_android,
              title: 'Phone and OTP',
              subtitle: 'Receive a code by SMS',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PhoneSignInScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- EMAIL SIGN IN ----------------

// This screen contains the email and password login form.
// StatefulWidget is used because some values change when the user interacts
// with the screen, such as Remember Me and password visibility.
class EmailSignInScreen extends StatefulWidget {
  const EmailSignInScreen({super.key});

  @override
  State<EmailSignInScreen> createState() => _EmailSignInScreenState();
}

class _EmailSignInScreenState extends State<EmailSignInScreen> {
  // Identifies the Form so we can validate its fields.
  final formKey = GlobalKey<FormState>();

  // Reads and manages the text entered into the email field.
  final emailController = TextEditingController();

  // Reads and manages the text entered into the password field.
  final passwordController = TextEditingController();

  // Stores whether Remember Me is checked.
  // This is only a UI setting for now; it is not saved permanently.
  bool rememberMe = true;

  // true hides the password; false shows it.
  bool obscurePassword = true;

  // Releases the controllers when the screen is removed.
  // This helps prevent unnecessary resource usage.
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Displays a short message at the bottom of the screen.
  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Validates the fields before attempting to sign in.
  // Real account authentication is not connected yet.
  void signIn() {
    // Stop if the email or password is invalid.
    if (!formKey.currentState!.validate()) return;

    // Temporary message until we connect the backend.
    showMessage('Sign in is not connected to the backend yet.');
  }

  // Opens the password recovery screen.
  void forgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ForgotPasswordScreen(),
      ),
    );
  }

  // Placeholder for Google and Apple authentication.
  // These buttons will not sign in until we implement the real services.
  void socialSignIn(String provider) {
    showMessage('$provider sign in is not connected yet.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
      ),

      // Allows scrolling when the keyboard opens or the screen is small.
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          // Groups the input fields so their validators can work together.
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ---------------- MAZID LOGO ----------------

// Displays the app logo at the top of the Sign In screen.
Center(
  child: Image.asset(
    'images/image.png',  
    height: 110,        
    width: 110,         
    fit: BoxFit.contain, 
  ),
),

const SizedBox(height: 20), 
                // Welcome heading.
                const Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF30285E),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Sign in to continue your journey with MAZID.',
                  style: TextStyle(color: Colors.black54),
                ),

                const SizedBox(height: 28),

                // ---------------- EMAIL FIELD ----------------

                TextFormField(
                  controller: emailController,

                  // Opens an email-friendly keyboard.
                  keyboardType: TextInputType.emailAddress,

                  // Removes unnecessary spaces around the email.
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    hintText: 'example@email.com',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),

                  // Checks whether the email looks valid.
                  validator: (value) {
                    if (value == null ||
                        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(value.trim())) {
                      return 'Enter a valid email address';
                    }

                    return null; // No error.
                  },
                ),

                const SizedBox(height: 18),

                // ---------------- PASSWORD FIELD ----------------

                TextFormField(
                  controller: passwordController,

                  // Hides or displays the password.
                  obscureText: obscurePassword,

                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),

                    // The eye button toggles password visibility.
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),

                      onPressed: () {
                        // setState tells Flutter to rebuild the UI.
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                    ),

                    border: const OutlineInputBorder(),
                  ),

                  // The password cannot be empty.
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Enter your password';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 8),

                // ---------------- REMEMBER ME + FORGOT PASSWORD ----------------

                Row(
                  children: [
                    // Checkbox for Remember Me.
                    Checkbox(
                      value: rememberMe,

                      onChanged: (value) {
                        setState(() {
                          rememberMe = value ?? false;
                        });
                      },
                    ),

                    const Expanded(
                      child: Text('Remember Me'),
                    ),

                    // Opens the password recovery screen.
                    TextButton(
                      onPressed: forgotPassword,
                      child: const Text('Forgot Password?'),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ---------------- SIGN IN BUTTON ----------------

                appButton(
                  text: 'Sign In',
                  onPressed: signIn,
                ),

                const SizedBox(height: 24),

                // Divider between email login and social login.
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'OR CONTINUE WITH',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 18),

                // ---------------- GOOGLE SIGN IN ----------------

                OutlinedButton.icon(
                  onPressed: () => socialSignIn('Google'),
                  icon: const Icon(Icons.g_mobiledata, size: 30),
                  label: const Text('Continue with Google'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),

                const SizedBox(height: 12),

                // ---------------- APPLE SIGN IN ----------------

                OutlinedButton.icon(
                  onPressed: () => socialSignIn('Apple'),
                  icon: const Icon(Icons.apple, size: 25),
                  label: const Text('Continue with Apple'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),

                const SizedBox(height: 24),

                // ---------------- CREATE ACCOUNT ----------------

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),

                    TextButton(
                      onPressed: () {
                        // Opens the existing account creation screen.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CreateAccountScreen(),
                          ),
                        );
                      },
                      child: const Text('Create Account'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- FORGOT PASSWORD ----------------

// This screen collects the email address for a password reset request.
// The actual reset process still needs to be connected to the backend.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Controller for the email field.
  final emailController = TextEditingController();

  // Form key used to validate the email.
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  // Temporary action until password recovery is implemented.
  void sendResetRequest() {
    if (!formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Password reset is not connected to the backend yet.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(24),

        child: Form(
          key: formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Reset your password',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF30285E),
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Enter your email address to request a password reset.',
                style: TextStyle(color: Colors.black54),
              ),

              const SizedBox(height: 24),

              // Email address used for the reset request.
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,

                decoration: const InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),

                validator: (value) {
                  if (value == null ||
                      !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                          .hasMatch(value.trim())) {
                    return 'Enter a valid email address';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              appButton(
                text: 'Send Reset Link',
                onPressed: sendResetRequest,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- PHONE SIGN IN ----------------

class PhoneSignInScreen extends StatefulWidget {
  const PhoneSignInScreen({super.key});

  @override
  State<PhoneSignInScreen> createState() =>
      _PhoneSignInScreenState();
}

class _PhoneSignInScreenState extends State<PhoneSignInScreen> {
  final formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Phone Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sign in with your phone',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Mobile number',
                  hintText: '+201xxxxxxxxx',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (value) =>
                value == null || value.trim().length < 8
                    ? 'Enter a valid phone number'
                    : null,
              ),
              const SizedBox(height: 24),
              appButton(
                text: 'Send OTP',
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OTPVerificationScreen(
                        destination: phoneController.text.trim(),
                        method: 'SMS',
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              const Text(
                'Demo only: an SMS will not be sent until Firebase is connected.',
                style: TextStyle(
                  color: Colors.deepOrange,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- REUSABLE WIDGETS ----------------

Widget appButton({
  required String text,
  required VoidCallback onPressed,
}) {
  return SizedBox(
    width: double.infinity,
    height: 54,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}

Widget verificationCard({
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return Card(
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
      side: BorderSide(color: Colors.grey.shade200),
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.all(14),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: primaryColor),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text(subtitle),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    ),
  );
}
