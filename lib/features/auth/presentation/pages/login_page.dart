import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../../core/widgets/custom_app_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/shake.dart';
import '../../../../generated/l10n.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ShakeWidgetState> _shakeKey = GlobalKey<ShakeWidgetState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(_usernameController.text, _passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status.isSuccess && state.user != null) {
            Navigator.of(context).pushNamedAndRemoveUntil(Routes.subjects, (route) => false);
          } else if (state.status.isFailure && state.failure != null) {
            showToastMessage(state.failure!.statusMessage, isError: true);
            _shakeKey.currentState?.shake();
          }
        },
        builder: (context, state) {
          final bool isLoading = state.status.isLoading;
          return DecoratedBox(
            decoration: const BoxDecoration(gradient: AppTokens.heroGradient),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    AppTokens.s24,
                    AppTokens.s24,
                    AppTokens.s24,
                    AppTokens.s24 + MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FadeSlideIn(
                          child: Semantics(
                            label: S.of(context).appName,
                            child: Container(
                              padding: const EdgeInsets.all(AppTokens.s12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
                                boxShadow: AppTokens.shadowMD,
                              ),
                              child: Image.asset('assets/branding/logo.png', width: 88, height: 88, fit: BoxFit.contain),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppTokens.s12),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 60),
                          child: Text(
                            S.of(context).appName,
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: AppTokens.s4 + 2),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 100),
                          child: Text(
                            S.of(context).loginSubtitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
                          ),
                        ),
                        const SizedBox(height: AppTokens.s32),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 140),
                          child: ShakeWidget(
                            key: _shakeKey,
                            child: Container(
                              padding: const EdgeInsets.all(AppTokens.s24),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: AppTokens.radiusXL,
                                boxShadow: AppTokens.shadowMD,
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CustomTextField(
                                      controller: _usernameController,
                                      hintText: S.of(context).username,
                                      textInputAction: TextInputAction.next,
                                      borderRadius: AppTokens.rMD,
                                      prefixIcon: const Icon(Icons.person_outline, semanticLabel: ''),
                                      validator: (v) => (v == null || v.trim().isEmpty) ? S.of(context).usernameRequired : null,
                                    ),
                                    const SizedBox(height: AppTokens.s16),
                                    CustomTextField(
                                      controller: _passwordController,
                                      hintText: S.of(context).password,
                                      obscureText: _obscure,
                                      borderRadius: AppTokens.rMD,
                                      prefixIcon: const Icon(Icons.lock_outline),
                                      suffixIcon: Semantics(
                                        button: true,
                                        label: _obscure ? S.of(context).password : '',
                                        child: IconButton(
                                          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                                          icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                                          onPressed: () => setState(() => _obscure = !_obscure),
                                        ),
                                      ),
                                      validator: (v) => (v == null || v.isEmpty) ? S.of(context).passwordRequired : null,
                                      onFieldSubmitted: (_) => _submit(),
                                    ),
                                    const SizedBox(height: AppTokens.s24 + 4),
                                    PressableScale(
                                      // CustomAppButton's own onPressed is the single
                                      // source of truth for the tap; PressableScale
                                      // only supplies the press-down/up scale feel.
                                      child: CustomAppButton(
                                        text: S.of(context).loginButton,
                                        isLoading: isLoading,
                                        onPressed: isLoading ? null : _submit,
                                        gradient: const [AppColors.primary, AppColors.gradientEnd],
                                        borderRadius: AppTokens.radiusMD,
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
            ),
          );
        },
      ),
    );
  }
}
