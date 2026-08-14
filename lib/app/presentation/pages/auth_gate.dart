import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/di.dart';
import '../../../core/routing/routes.dart';
import '../../../core/services/connectivity_service.dart';
import '../../../core/services/device_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_motion.dart';
import '../../../generated/l10n.dart';
import '../../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../../features/auth/presentation/cubit/auth_state.dart';
import '../../../features/auth/presentation/pages/login_page.dart';
import '../../../features/offline/presentation/pages/offline_page.dart';

/// Decides the app's first screen: runs a device-security check, then
/// silently restores the session if a token is cached.
///
/// NOTE(migration): OLD app also ran `FlutterJailbreakDetection.jailbroken`
/// here. That package's `android/build.gradle` predates AGP's namespace
/// requirement and fails to configure under this project's AGP 9 (see
/// pubspec.yaml NOTE) — it was dropped in the native-config merge (task
/// #14). Only the emulator check runs until a maintained alternative is
/// wired in.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final ConnectivityService _connectivity = getIt<ConnectivityService>();

  bool _isEmulator = false;
  bool _checked = false;
  bool _online = true;
  bool _navigatedToSubjects = false;

  @override
  void initState() {
    super.initState();
    _runSecurityCheck();
  }

  Future<void> _runSecurityCheck() async {
    // The app must not run on an emulator/simulator.
    final bool isPhysical = await getIt<DeviceService>().isPhysicalDevice();

    final bool online = await _connectivity.hasInternet();
    if (online) {
      // Kick off the silent auto-login check once; AuthGate reacts to it via
      // the BlocBuilder below rather than re-triggering it on every rebuild.
      getIt<AuthCubit>().checkAuth();
    }

    if (!mounted) return;
    setState(() {
      _isEmulator = !isPhysical;
      _online = online;
      _checked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked) {
      return const _LoadingView();
    }
    if (_isEmulator) {
      return const _CompromisedDeviceView();
    }
    // Offline: a single screen (OfflinePage) shows downloaded lessons if any
    // exist plus a "check connection" button. Only the *launch* case is
    // handled here — ongoing connectivity changes belong to
    // ConnectivityWatcher, which outlives this widget (see its doc comment).
    if (!_online) {
      return const OfflinePage();
    }
    return BlocProvider<AuthCubit>.value(
      // AuthCubit is an app-wide @lazySingleton — provide the existing
      // instance (never `create:`) so navigating away from this permanent
      // root widget can never close it out from under the rest of the app.
      value: getIt<AuthCubit>(),
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (!state.isAuthResolved) {
            return const _LoadingView();
          }
          if (state.user != null) {
            if (!_navigatedToSubjects) {
              _navigatedToSubjects = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) Navigator.of(context).pushNamedAndRemoveUntil(Routes.subjects, (route) => false);
              });
            }
            return const _LoadingView();
          }
          return const LoginPage();
        },
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
  }
}

class _CompromisedDeviceView extends StatelessWidget {
  const _CompromisedDeviceView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.error,
      body: Center(
        child: FadeSlideIn(
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.s32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.gpp_bad_rounded, size: 80, color: Colors.white),
                const SizedBox(height: AppTokens.s20),
                Text(
                  S.of(context).unsafeDeviceTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppTokens.s12),
                Text(
                  S.of(context).emulatorDetectedMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
