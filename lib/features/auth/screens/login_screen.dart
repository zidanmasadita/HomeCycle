import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:homesikil/core/constants/app_colors.dart';
import 'package:homesikil/core/constants/app_assets.dart';
import 'package:homesikil/core/constants/app_dimens.dart';
import 'package:homesikil/core/theme/app_text_styles.dart';
import 'package:homesikil/core/utils/app_snackbar.dart';
import 'package:homesikil/core/utils/validators.dart';
import 'package:homesikil/features/auth/provider/auth_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:homesikil/routes/app_routes.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  late AuthProvider _authProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authProvider = context.read<AuthProvider>();
      _authProvider.addListener(_onAuthChanged);
    });
  }

  void _onAuthChanged() {
    if (!mounted) return;
    final provider = context.read<AuthProvider>();
    if (provider.status == AuthStatus.success && provider.currentUser != null) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.splash,
        (_) => false,
      );
    }
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AuthProvider>();

    await provider.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    final updated = context.read<AuthProvider>();
    if (updated.status == AuthStatus.success) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.splash,
        (_) => false,
      );
    } else {
      AppSnackbar.showError(updated.errorMessage ?? 'Login failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Builder(
          builder: (context) {
            final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Logo
            Padding(
              padding: const EdgeInsets.only(left: 20.0, top: 10.0),
              child: Row(
                children: [
                  Image.asset(
                    AppAssets.logo,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.eco,
                      color: AppColors.primary,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'HomeCycle',
                    style: AppTextStyles.heading.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),

            // Welcome Text and Mascot
            if (!isKeyboardOpen)
              Padding(
                padding: const EdgeInsets.only(left: 30.0, right: 0.0, top: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          "Welcome\nback, Mate!",
                          style: AppTextStyles.displayLarge,
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, 30),
                      child: Image.asset(
                        AppAssets.mascot2,
                        height: 180,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(height: 180, width: 150),
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 30.0, bottom: 20.0, top: 20.0),
                child: Text(
                  "Welcome\nback, Mate!",
                  style: AppTextStyles.displayLarge,
                ),
              ),

            // Bottom Sheet Area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppDimens.radiusXL),
                    topRight: Radius.circular(AppDimens.radiusXL),
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      child: Text(
                        'Login',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.title.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // White Form Area
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(AppDimens.radiusXL),
                            topRight: Radius.circular(AppDimens.radiusXL),
                          ),
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                            vertical: 30.0,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Social Buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _socialButton(
                                      null,
                                      null,
                                      isDiscord: true,
                                      onTap: () => context
                                          .read<AuthProvider>()
                                          .signInWithDiscord(),
                                    ),
                                    const SizedBox(width: 20),
                                    _socialButton(
                                      null,
                                      null,
                                      isGoogle: true,
                                      onTap: () => context
                                          .read<AuthProvider>()
                                          .signInWithGoogle(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Or use your email account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Email Field
                                _buildField(
                                  controller: _emailController,
                                  hint: 'Email',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.email],
                                  validator: validateEmail,
                                ),

                                // Password Field
                                _buildField(
                                  controller: _passwordController,
                                  hint: 'Password',
                                  icon: Icons.lock_outline,
                                  obscure: _obscurePassword,
                                  autofillHints: const [AutofillHints.password],
                                  validator: validateLoginPassword,
                                  bottomMargin: 0,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.grey.shade500,
                                    ),
                                    onPressed: () => setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    ),
                                  ),
                                ),

                                // Remember Me & Forgot Password
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Transform.scale(
                                          scale: 0.75,
                                          child: Switch(
                                            value: _rememberMe,
                                            onChanged: (val) => setState(
                                              () => _rememberMe = val,
                                            ),
                                            trackOutlineColor:
                                                WidgetStatePropertyAll(
                                                  AppColors.border,
                                                ),
                                            activeColor: Colors.white,
                                            activeTrackColor: AppColors.primary,
                                            inactiveThumbColor: Colors.white,
                                            inactiveTrackColor:
                                                Colors.grey.shade300,
                                          ),
                                        ),
                                        const Text(
                                          'Remember Me',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: const Text(
                                        'Forgot Password',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                // Login Button
                                Consumer<AuthProvider>(
                                  builder: (context, auth, _) {
                                    return SizedBox(
                                      width: double.infinity,
                                      height: 55,
                                      child: ElevatedButton(
                                        onPressed: auth.isLoading ? null : _submit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          disabledBackgroundColor:
                                              Colors.grey.shade400,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              AppDimens.radiusXL,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: auth.isLoading
                                            ? const SizedBox(
                                                height: 24,
                                                width: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2,
                                                    ),
                                              )
                                            : const Text(
                                                'Login',
                                                style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Register Link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Don't have an account? ",
                                      style: TextStyle(color: Colors.black87),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const RegisterScreen(),
                                        ),
                                      ),
                                      child: const Text(
                                        'Register',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
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
          ],
        );
      },
    ),
  ),
    );
  }

  Widget _socialButton(
    IconData? icon,
    Color? color, {
    bool isGoogle = false,
    bool isDiscord = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Center(
          child: isGoogle
              ? SvgPicture.asset('assets/images/icons/google.svg', width: 32, height: 32)
              : isDiscord
                  ? SvgPicture.asset('assets/images/icons/discord.svg', width: 32, height: 32)
                  : Icon(icon, color: color, size: 36),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    bool obscure = false,
    TextInputType? keyboardType,
    Iterable<String>? autofillHints,
    String? Function(String?)? validator,
    double bottomMargin = 16,
    Widget? suffixIcon,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: bottomMargin),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.shade400, width: 1),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        autofillHints: autofillHints,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: icon != null
              ? Icon(icon, color: Colors.grey.shade500)
              : null,
          suffixIcon: suffixIcon,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 16,
          ),
          errorStyle: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
