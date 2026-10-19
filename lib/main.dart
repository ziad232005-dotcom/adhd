import 'package:flutter/material.dart';

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
                    fontSize: 29,
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
                  text: 'Create Account',
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
                  'A supportive space to grow together 💜',
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
                  value: role,
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

// ---------------- CHOOSE VERIFICATION ----------------

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
              'Verification is not connected yet. No message will be sent.',
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

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  void showNotConnectedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'OTP is not connected yet. No code has been sent or verified.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            TextFormField(
              controller: codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                hintText: 'Enter 6-digit OTP',
                prefixIcon: Icon(Icons.password_outlined),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Demo screen only: no OTP has been sent.',
              style: TextStyle(
                color: Colors.deepOrange,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),
            appButton(
              text: 'Verify Code',
              onPressed: showNotConnectedMessage,
            ),
            TextButton(
              onPressed: showNotConnectedMessage,
              child: const Text('Resend Code'),
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

class EmailSignInScreen extends StatefulWidget {
  const EmailSignInScreen({super.key});

  @override
  State<EmailSignInScreen> createState() =>
      _EmailSignInScreenState();
}

class _EmailSignInScreenState extends State<EmailSignInScreen> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void notConnected() {
    if (!formKey.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Sign in is not connected to Firebase yet.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Email Sign In')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                validator: (value) {
                  if (value == null ||
                      !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                          .hasMatch(value.trim())) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) =>
                value == null || value.isEmpty
                    ? 'Enter your password'
                    : null,
              ),
              const SizedBox(height: 24),
              appButton(
                text: 'Sign In',
                onPressed: notConnected,
              ),
              const SizedBox(height: 12),
              const Text(
                'Authentication will be connected to Firebase.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
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
