import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:pinput/pinput.dart';
import 'parent.dart';
import 'child.dart';
import 'link/child_device.dart';
import 'link/linked_child_home.dart';
import 'link/scan_child_qr_screen.dart';
import 'core/api_config.dart';
import 'core/app_features.dart';
import 'core/mazid_theme.dart';
import 'core/widgets/mazid_widgets.dart';
import 'parent/parent_store.dart';
import 'shadows/shadow_draft_store.dart';
import 'shadows/verification_form_screen.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ParentStore.instance.load();
  await ChildDevice.instance.load();
  await ShadowDraftStore.instance.load();
  await ChildAppState.instance.loadData(
    childId: ChildDevice.instance.childId ??
        ParentStore.instance.selectedChild?.id,
  );

  runApp(const ADHDCompanionApp());
}


const primaryColor = MazidColors.primary;
const backgroundColor = MazidColors.background;

class ADHDCompanionApp extends StatelessWidget {
  const ADHDCompanionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: MazidBrand.name,
      theme: MazidTheme.light(),
      home: _firstScreen(),
    );
  }

  /// A phone linked to a child opens on that child's screen only.
  Widget _firstScreen() {
    final linkedId = ChildDevice.instance.childId;
    if (linkedId != null) {
      final linked = ParentStore.instance.children
          .where((c) => c.id == linkedId)
          .firstOrNull;
      if (linked != null) return LinkedChildHome(child: linked);
    }
    return const WelcomeScreen();
  }
}

// ---------------- WELCOME SCREEN ----------------

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MazidAuthScaffold(
      showBack: false,
      child: Column(
        children: [
          const SizedBox(height: 48),
          const MazidMascot(size: 120),
          const SizedBox(height: 8),
          const Text(
            MazidBrand.name,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: MazidColors.primary,
            ),
          ),
          const Text(
            MazidBrand.tagline,
            style: TextStyle(fontSize: 16, color: MazidColors.textDark),
          ),
          const SizedBox(height: 72),
          const Text(
            'A Brighter Journey\nfor Your Child',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 27,
              height: 1.2,
              fontWeight: FontWeight.bold,
              color: MazidColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Track progress, get helpful guidance,\n'
            'and work together with your doctor.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: MazidColors.textMuted,
            ),
          ),
          const SizedBox(height: 40),
          MazidPrimaryButton(
            label: 'Get Started',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CreateAccountScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          MazidOutlineButton(
            label: 'Sign In',
            borderColor: MazidColors.primary,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EmailSignInScreen(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScanChildQrScreen()),
            ),
            child: const Text('I am a child - scan my code'),
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const VerificationFormScreen()),
            ),
            child: const Text('I am a Shadow Teacher - join the list'),
          ),
          const SizedBox(height: 48),
        ],
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
  final String role = 'Parent';
  DateTime? selectedDateOfBirth;

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

    // Keep the parent's details so the Profile page can show them.
    ParentStore.instance.updateProfile(
      ParentProfile(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
      ),
    );

    _continueToVerification();
  }

  // Moves on to email (or SMS) verification.
  void _continueToVerification() {
    if (!AppFeatures.smsVerification) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OTPVerificationScreen(
            destination: emailController.text.trim(),
            method: 'Email',
          ),
        ),
      );
      return;
    }

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

  String get _dateOfBirthText {
    final date = selectedDateOfBirth;
    if (date == null) return 'DD / MM / YYYY';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day / $month / ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return MazidAuthScaffold(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MazidAuthHeader(
              title: 'Create Your Account',
              subtitle: 'Join ${MazidBrand.name} and start your journey to\n'
                  'better support your child.',
            ),
            const SizedBox(height: 28),
            MazidTextField(
              controller: nameController,
              label: 'Full Name',
              hint: 'Your full name',
              icon: Icons.person_outline,
              textCapitalization: TextCapitalization.words,
              inputFormatters: MazidInputFormatters.name,
              validator: (value) => MazidValidators.personName(
                value,
                'Please enter your full name.',
              ),
            ),
            const SizedBox(height: 16),
            MazidTextField(
              controller: emailController,
              label: 'Email Address',
              hint: 'you@example.com',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              validator: MazidValidators.email,
            ),
            const SizedBox(height: 16),
            MazidTextField(
              controller: phoneController,
              label: 'Phone Number (Optional)',
              hint: 'Your phone number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: MazidValidators.optionalPhone,
            ),
            const SizedBox(height: 16),
            const MazidFieldLabel('Date of Birth'),
            InkWell(
              onTap: selectDateOfBirth,
              borderRadius: BorderRadius.circular(MazidSpacing.fieldRadius),
              child: InputDecorator(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.calendar_month_outlined, size: 20),
                ),
                child: Text(
                  _dateOfBirthText,
                  style: TextStyle(
                    fontSize: 14,
                    color: selectedDateOfBirth == null
                        ? MazidColors.textMuted
                        : MazidColors.textDark,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            MazidPasswordField(
              controller: passwordController,
              label: 'Password',
              hint: 'At least 8 characters',
              validator: MazidValidators.password,
            ),
            const SizedBox(height: 4),
            MazidPasswordChecklist(controller: passwordController),
            const SizedBox(height: 16),
            MazidPasswordField(
              controller: confirmPasswordController,
              label: 'Confirm Password',
              hint: 'Re-enter password',
              textInputAction: TextInputAction.done,
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
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: acceptedTerms,
                  onChanged: (value) {
                    setState(() {
                      acceptedTerms = value ?? false;
                    });
                  },
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'I agree to the Terms of Service and Privacy Policy.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: MazidColors.textDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            MazidPrimaryButton(
              label: 'Create Account',
              onPressed: continueToVerification,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Already have an account?',
                  style: TextStyle(color: MazidColors.textMuted),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ],
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
    return MazidAuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MazidAuthHeader(
            icon: Icons.verified_user_outlined,
            title: 'Verify Your Account',
            subtitle: 'Choose how you would like to receive\n'
                'your verification code.',
          ),
          const SizedBox(height: 28),
          verificationCard(
            icon: Icons.mail_outline,
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
          if (AppFeatures.smsVerification && phone.isNotEmpty) ...[
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
          ],
          const SizedBox(height: 24),
          const Text(
            'We will send you a 6-digit code.\n'
            'It expires in 5 minutes.',
            textAlign: TextAlign.center,
            style: TextStyle(color: MazidColors.textMuted, fontSize: 12),
          ),
        ],
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

  bool get _isEmail => widget.method == 'Email';

  // The backend has separate endpoints for email and SMS codes.
  String get _sendPath =>
      _isEmail ? '/api/auth/send-otp' : '/api/auth/send-sms-otp';

  String get _verifyPath =>
      _isEmail ? '/api/auth/verify-otp' : '/api/auth/verify-sms-otp';

  String get _destinationKey => _isEmail ? 'email' : 'phone';

bool isSending = false;
bool isVerifying = false;
bool codeSent = false;

int resendCountdown = 0;
Timer? resendTimer;

@override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    sendOtp();
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

  static const _insecureServerMessage =
      'This version only connects to a secure (https) server.';

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
    if (isSending || isVerifying) return;

    if (!ApiConfig.canConnect) {
      showMessage(_insecureServerMessage);
      return;
    }

    setState(() {
      isSending = true;
    });

    try {
      final response = await http
          .post(
            ApiConfig.uri(_sendPath),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              _destinationKey: widget.destination.trim(),
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
    final code = codeController.text.trim();

    if (code.length != 6 ||
        !RegExp(r'^[0-9]{6}$').hasMatch(code)) {
      showMessage('Please enter the 6-digit verification code.');
      return;
    }

    if (isSending || isVerifying) return;

    if (!ApiConfig.canConnect) {
      showMessage(_insecureServerMessage);
      return;
    }

    setState(() {
      isVerifying = true;
    });

    try {
      final response = await http
          .post(
            ApiConfig.uri(_verifyPath),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              _destinationKey: widget.destination.trim(),
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
              title: Text(_isEmail ? 'Email Verified' : 'Phone Verified'),
              content: Text(
                _isEmail
                    ? 'Your email address has been verified successfully.'
                    : 'Your phone number has been verified successfully.',
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

  PinTheme get _basePinTheme => PinTheme(
        width: 44,
        height: 56,
        textStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: MazidColors.textDark,
        ),
        decoration: BoxDecoration(
          color: MazidColors.surface,
          border: Border.all(color: MazidColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
      );

  String get _resendLabel {
    if (isSending) return 'Sending...';
    if (resendCountdown > 0) return 'Resend code in ${resendCountdown}s';
    return 'Resend code';
  }

  @override
  Widget build(BuildContext context) {
    final isEmail = _isEmail;
    final basePin = _basePinTheme;

    return MazidAuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MazidAuthHeader(
            icon: isEmail ? Icons.mail_outline_rounded : Icons.sms_outlined,
            title: isEmail ? 'Verify Your Email' : 'Verify Your Number',
            subtitle: 'Enter the 6-digit code for\n${widget.destination}',
          ),
          const SizedBox(height: 28),
          Center(
            child: Pinput(
              controller: codeController,
              length: 6,
              keyboardType: TextInputType.number,
              defaultPinTheme: basePin,
              focusedPinTheme: basePin.copyDecorationWith(
                border: Border.all(color: MazidColors.primary, width: 2),
              ),
              submittedPinTheme: basePin.copyDecorationWith(
                color: MazidColors.softPurple,
                border: Border.all(color: MazidColors.primary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            codeSent
                ? 'Enter the code we sent you. It expires in 5 minutes.'
                : 'We will send a verification code to ${widget.destination}.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: MazidColors.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          MazidPrimaryButton(
            label: 'Verify & Continue',
            isLoading: isVerifying,
            onPressed: isSending ? null : verifyOtp,
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: isSending || isVerifying || resendCountdown > 0
                  ? null
                  : sendOtp,
              child: Text(_resendLabel),
            ),
          ),
        ],
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
    return MazidAuthScaffold(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MazidAuthHeader(
              mascot: MazidAssets.octopus,
              mascotSize: 88,
              title: 'Welcome back!',
              subtitle: 'Sign in to continue your journey.',
            ),
            const SizedBox(height: 28),
            MazidTextField(
              controller: emailController,
              label: 'Email Address',
              hint: 'you@example.com',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              validator: MazidValidators.email,
            ),
            const SizedBox(height: 16),
            MazidPasswordField(
              controller: passwordController,
              label: 'Password',
              hint: 'Enter your password',
              textInputAction: TextInputAction.done,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter your password';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: rememberMe,
                  onChanged: (value) {
                    setState(() {
                      rememberMe = value ?? false;
                    });
                  },
                ),
                const Expanded(
                  child: Text(
                    'Remember me',
                    style: TextStyle(
                      fontSize: 13,
                      color: MazidColors.textDark,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: forgotPassword,
                  child: const Text('Forgot Password?'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            MazidPrimaryButton(label: 'Sign In', onPressed: signIn),
            const SizedBox(height: 20),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'or',
                    style: TextStyle(
                      color: MazidColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 20),
            MazidOutlineButton(
              label: 'Continue with Google',
              icon: const Icon(Icons.g_mobiledata, size: 28),
              onPressed: () => socialSignIn('Google'),
            ),
            const SizedBox(height: 12),
            MazidOutlineButton(
              label: 'Continue with Apple',
              icon: const Icon(Icons.apple, size: 22),
              onPressed: () => socialSignIn('Apple'),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Don't have an account?",
                  style: TextStyle(color: MazidColors.textMuted),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateAccountScreen(),
                    ),
                  ),
                  child: const Text('Create Account'),
                ),
              ],
            ),
          ],
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
    return MazidAuthScaffold(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MazidAuthHeader(
              icon: Icons.mail_outline_rounded,
              title: 'Forgot Password?',
              subtitle: "Enter your email address and we'll send\n"
                  'you a code to reset your password.',
            ),
            const SizedBox(height: 28),
            MazidTextField(
              controller: emailController,
              label: 'Email Address',
              hint: 'you@example.com',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autocorrect: false,
              validator: MazidValidators.email,
            ),
            const SizedBox(height: 24),
            MazidPrimaryButton(
              label: 'Send Code',
              onPressed: sendResetRequest,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Remember your password?',
                  style: TextStyle(color: MazidColors.textMuted),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ],
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
  return MazidPrimaryButton(label: text, onPressed: onPressed);
}

Widget verificationCard({
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return Card(
    color: MazidColors.surface,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(MazidSpacing.cardRadius),
      side: const BorderSide(color: MazidColors.border),
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.all(14),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: MazidColors.softPurple,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: MazidColors.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: MazidColors.textDark,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Text(
          subtitle,
          style: const TextStyle(color: MazidColors.textMuted),
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: MazidColors.textMuted,
      ),
      onTap: onTap,
    ),
  );
}
