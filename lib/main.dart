import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:pinput/pinput.dart';
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
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [

  Image.asset(
  'images/image.png',
  width: 200,
  height: 180,
  fit: BoxFit.contain,
  ),
                const SizedBox(height: 24),
                const Text(
                  'MΛZID',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5F4EC2),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'ADHD Parent Support',
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0x89001244),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 45),
                const Text(
                  'A Brighter journey for your child',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your journey starts with one small step.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                appButton(
                  text: 'Get Started',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateAccountScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    foregroundColor: primaryColor,
                    side: const BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      
                    ),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SignInScreen(),
                    ),
                  ),
                  child: const Text('Sign In'),
                ),
                const SizedBox(height: 24),
                const Text(
                  'A supportive space to grow together ',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- CREATE ACCOUNT ----------------

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState
    extends State<CreateAccountScreen> {
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  String role = 'Parent';
  bool hidePassword = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void continueToVerification() {
    if (!formKey.currentState!.validate()) return;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create your account',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF30285E),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your details to get started.',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 25),
                const Text('Account type'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                   initialValue: role,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'Parent',
                      child: Text('Parent'),
                    ),
                    DropdownMenuItem(
                      value: 'Child',
                      child: Text('Child'),
                    ),
                    DropdownMenuItem(
                      value: 'Shadow Teacher',
                      child: Text('Shadow Teacher'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => role = value);
                    }
                  },
                ),
                const SizedBox(height: 18),
                const Text('Full name'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your full name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) =>
                  value == null || value.trim().isEmpty
                      ? 'Please enter your name'
                      : null,
                ),
                const SizedBox(height: 18),
                const Text('Email address'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'name@example.com',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(value.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                const Text('Mobile number'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: '+20 1xxxxxxxxx',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (value.trim().length < 8) {
                      return 'Enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                const Text('Password'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: passwordController,
                  obscureText: hidePassword,
                  decoration: InputDecoration(
                    hintText: 'At least 6 characters',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                      icon: Icon(
                        hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Use at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),
                appButton(
                  text: 'Continue to Verification',
                  onPressed: continueToVerification,
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
