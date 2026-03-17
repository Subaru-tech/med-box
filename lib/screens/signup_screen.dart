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
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signUp(
      email: _emailController.text,
      password: _passwordController.text,
      name: _nameController.text,
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
            child: FadeTransition(
              opacity: _animationController,
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Header
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(77), // 0.3 * 255
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_add_outlined,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Create Account',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Join the Smart Notice Board',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Form
                  GlassContainer(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                      children: [
                        CustomTextField(
                          label: AppStrings.fullName,
                          hint: 'Enter your full name',
                          controller: _nameController,
                          validator: Validators.validateName,
                          prefixIcon: Icons.person_outlined,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

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
                          hint: 'Min 6 characters',
                          controller: _passwordController,
                          validator: Validators.validatePassword,
                          obscureText: true,
                          prefixIcon: Icons.lock_outlined,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          label: AppStrings.confirmPassword,
                          hint: 'Re-enter password',
                          controller: _confirmPasswordController,
                          validator: (value) =>
                              Validators.validateConfirmPassword(
                            value,
                            _passwordController.text,
                          ),
                          obscureText: true,
                          prefixIcon: Icons.lock_outlined,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleSignup(),
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
                                      color: AppColors.error.withAlpha(77)), // 0.3 * 255
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

                        // Signup Button
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            return GradientButton(
                              text: AppStrings.signup,
                              isLoading: auth.isLoading,
                              onPressed: _handleSignup,
                              icon: Icons.person_add,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        AppStrings.alreadyHaveAccount,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(
                            context, AppRoutes.login),
                        child: const Text(
                          AppStrings.login,
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
    );
  }
}
