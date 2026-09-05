import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/di/di.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/utils/local_storage_keys.dart';
import '../../../../core/utils/shared_preferences_helper.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../../generated/l10n.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

/// Student settings: account info (with grade), app preferences, support, and
/// the danger zone (logout / delete account).
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const String _supportEmail = 'edu285932@gmail.com';
  static const String _appVersion = '1.0.1';

  // AuthCubit is an app-wide @lazySingleton (see di.config.dart) — read
  // directly rather than closed on dispose, since closing it here would
  // break every other screen that shares the same instance afterwards.
  final AuthCubit _authCubit = getIt<AuthCubit>();

  User? _user;
  bool _notifications = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final User? user = await getIt<AuthRepository>().currentUser();
    final bool notifications = SharedPreferencesHelper.getBool(LocalStorageKeys.notificationsEnabled, defaultValue: true);
    if (!mounted) return;
    setState(() {
      _user = user;
      _notifications = notifications;
      _loading = false;
    });
  }

  Future<void> _setNotifications(bool value) async {
    setState(() => _notifications = value);
    await SharedPreferencesHelper.setData(LocalStorageKeys.notificationsEnabled, value);
  }

  String _initials(String name) {
    final Iterable<String> parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '؟';
    return parts.take(2).map((p) => p.substring(0, 1)).join();
  }

  List<Widget> _languageOptions(BuildContext ctx) => [
    ListTile(
      leading: const Icon(Icons.check_rounded, color: AppColors.primary),
      title: Text(S.of(context).arabic),
      onTap: () => Navigator.of(ctx).pop(),
    ),
    ListTile(
      enabled: false,
      leading: const Icon(Icons.language_rounded),
      title: Text(S.of(context).english),
      trailing: Text(S.of(context).comingSoon, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
    ),
  ];

  /// Bottom sheets read as a mobile pattern; on tablet/desktop width this
  /// shows the same options as a centered dialog instead.
  Future<void> _showLanguagePicker() async {
    if (Breakpoints.of_(context).isTabletOrLarger) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(S.of(context).language),
          content: SizedBox(width: 360, child: Column(mainAxisSize: MainAxisSize.min, children: _languageOptions(ctx))),
        ),
      );
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTokens.s16),
              child: Text(S.of(context).language, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ..._languageOptions(ctx),
            const SizedBox(height: AppTokens.s8),
          ],
        ),
      ),
    );
  }

  Future<void> _contactSupport() async {
    // The student app doesn't bundle url_launcher, so we surface the support
    // email in a dialog and let the student copy it to the clipboard.
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).contactUs),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(S.of(context).contactUsMessage),
            const SizedBox(height: AppTokens.s8),
            const SelectableText(_supportEmail, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(S.of(context).back)),
          ElevatedButton.icon(
            onPressed: () async {
              final String emailCopiedMessage = S.of(context).emailCopied;
              await Clipboard.setData(const ClipboardData(text: _supportEmail));
              if (ctx.mounted) Navigator.of(ctx).pop();
              showToastMessage(emailCopiedMessage);
            },
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: Text(S.of(context).copy),
          ),
        ],
      ),
    );
  }

  Future<bool> _confirm({required String title, required String message, required String confirmText, Color? confirmColor}) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(S.of(context).back)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(confirmText, style: TextStyle(color: confirmColor ?? AppColors.error))),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _logout() async {
    final bool confirmed = await _confirm(
      title: S.of(context).logout,
      message: S.of(context).logoutConfirm,
      confirmText: S.of(context).logout,
      confirmColor: AppColors.primary,
    );
    if (!confirmed || !mounted) return;
    await _authCubit.logout();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (route) => false);
  }

  Future<void> _deleteAccount() async {
    final bool proceed = await _confirm(title: S.of(context).deleteAccount, message: S.of(context).deleteAccountConfirm, confirmText: S.of(context).delete);
    if (!proceed || !mounted) return;

    final bool ok = await _authCubit.deleteAccount();
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (route) => false);
    } else {
      showToastMessage(S.of(context).deleteAccountFailed, isError: true);
    }
  }

  String _gradeLabel(String? grade) {
    final String v = (grade ?? '').trim().toLowerCase();
    if (v.isEmpty) return S.of(context).gradeGeneral;
    if (v.contains('bac') || v.contains('بكالوريا')) return S.of(context).gradeBac;
    // tase3 / grade9 / grade_9 … all map to the 9th grade.
    return S.of(context).gradeNine;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(S.of(context).settings)),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : LayoutBuilder(
              builder: (context, constraints) {
                final Breakpoints bp = Breakpoints.of(constraints.maxWidth);
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: ListView(
                      padding: EdgeInsets.all(bp.horizontalPadding),
                      children: [
                        FadeSlideIn(child: _SectionHeader(title: S.of(context).settingsAccountSection)),
                        FadeSlideIn(child: _accountCard()),
                        const SizedBox(height: AppTokens.s24),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 40),
                          child: _SectionHeader(title: S.of(context).settingsAppSection),
                        ),
                        FadeSlideIn(delay: const Duration(milliseconds: 40), child: _appCard()),
                        const SizedBox(height: AppTokens.s24),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 80),
                          child: _SectionHeader(title: S.of(context).settingsSupportSection),
                        ),
                        FadeSlideIn(delay: const Duration(milliseconds: 80), child: _supportCard()),
                        const SizedBox(height: AppTokens.s24),
                        FadeSlideIn(
                          delay: const Duration(milliseconds: 120),
                          child: _SectionHeader(title: S.of(context).settingsDangerSection),
                        ),
                        FadeSlideIn(delay: const Duration(milliseconds: 120), child: _dangerCard()),
                        const SizedBox(height: AppTokens.s24),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppTokens.radiusLG, boxShadow: AppTokens.shadowSM),
      child: child,
    );
  }

  Widget _accountCard() {
    final User? user = _user;
    final String name = (user?.fullName.isNotEmpty ?? false) ? user!.fullName : S.of(context).studentLabel;
    return _card(
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.s16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(gradient: AppTokens.brandGradient, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(_initials(name), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
            ),
            const SizedBox(width: AppTokens.s16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: AppTokens.s4),
                  Wrap(
                    spacing: AppTokens.s8,
                    runSpacing: AppTokens.s4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _Chip(label: S.of(context).studentLabel, color: AppColors.primary),
                      _Chip(label: _gradeLabel(user?.grade), color: AppColors.accent),
                      if (user != null && user.username.isNotEmpty)
                        Text('@${user.username}', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _appCard() {
    return _card(
      child: Column(
        children: [
          SwitchListTile(
            value: _notifications,
            onChanged: _setNotifications,
            secondary: const Icon(Icons.notifications_outlined),
            title: Text(S.of(context).notifications, style: const TextStyle(fontSize: 15)),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.language_outlined),
            title: Text(S.of(context).language, style: const TextStyle(fontSize: 15)),
            trailing: _Chip(label: S.of(context).arabic, color: AppColors.primary),
            onTap: _showLanguagePicker,
          ),
          const Divider(height: 1),
          // The offline screen lists downloads too, but it only appears when
          // there's no connection - this is the only way a connected student
          // can review or clear what's taking up space on their device.
          ListTile(
            leading: const Icon(Icons.download_for_offline_outlined),
            title: Text(S.of(context).manageDownloads, style: const TextStyle(fontSize: 15)),
            trailing: const Icon(Icons.chevron_left_rounded),
            onTap: () => Navigator.of(context).pushNamed(Routes.downloads),
          ),
        ],
      ),
    );
  }

  Widget _supportCard() {
    return _card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.email_outlined),
            title: Text(S.of(context).contactUs, style: const TextStyle(fontSize: 15)),
            trailing: const Icon(Icons.chevron_left_rounded),
            onTap: _contactSupport,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(S.of(context).appVersion, style: const TextStyle(fontSize: 15)),
            trailing: const Text(_appVersion, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _dangerCard() {
    return _card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.accent),
            title: Text(S.of(context).logout, style: const TextStyle(fontSize: 15)),
            onTap: _logout,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.delete_forever_rounded, color: AppColors.error),
            title: Text(S.of(context).deleteAccount, style: const TextStyle(fontSize: 15, color: AppColors.error)),
            onTap: _deleteAccount,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.s8, right: AppTokens.s4),
      child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5)),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AppTokens.rSM)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
