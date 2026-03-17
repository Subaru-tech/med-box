import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/constants/app_strings.dart';
import '../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/common/custom_textfield.dart';
import '../widgets/ambient_background.dart';
import '../widgets/glass_container.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final authProvider = context.read<AuthProvider>();
    final savedEmail = await authProvider.getSavedEmail();
    if (savedEmail != null) {
      _emailController.text = savedEmail;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _animationController,
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // App Logo
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(77), // 0.3 * 255
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.developer_board,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // App Name
                    const Text(
                      AppStrings.appName,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      AppStrings.appTagline,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Form
                    GlassContainer(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                        children: [
                          CustomTextField(
                            label: AppStrings.email,
                            hint: 'Enter your email',
                            controller: _emailController,
                            validator: Validators.validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 16),

                          CustomTextField(
                            label: AppStrings.password,
                            hint: 'Enter your password',
                            controller: _passwordController,
                            validator: Validators.validatePassword,
                            obscureText: true,
                            prefixIcon: Icons.lock_outlined,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleLogin(),
                          ),
                          const SizedBox(height: 12),

                          // Remember me & Forgot Password
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Checkbox(
                                          value: auth.rememberMe,
                                          onChanged: (v) =>
                                              auth.toggleRememberMe(
                                                  v ?? false),
                                          activeColor: AppColors.primary,
                                          side: const BorderSide(
                                              color: AppColors.textSecondary),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        AppStrings.rememberMe,
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // TODO: Forgot password
                                    },
                                    child: const Text(
                                      AppStrings.forgotPassword,
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // Error message
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) {
                              if (auth.error != null) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withAlpha(26), // 0.1 * 255
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color:
                                            AppColors.error.withAlpha(77)), // 0.3 * 255
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline,
                                          color: AppColors.error, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          auth.error!,
                                          style: const TextStyle(
                                            color: AppColors.error,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),

                          // Login Button
                          Consumer<AuthProvider>(
                            builder: (context, auth, _) {
                              return GradientButton(
                                text: AppStrings.login,
                                isLoading: auth.isLoading,
                                onPressed: _handleLogin,
                                icon: Icons.login,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          AppStrings.dontHaveAccount,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacementNamed(
                              context, AppRoutes.signup),
                          child: const Text(
                            AppStrings.signup,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
