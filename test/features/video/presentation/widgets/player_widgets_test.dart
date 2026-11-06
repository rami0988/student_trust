import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/features/video/presentation/utils/playback_snapshot.dart';
import 'package:mobile_template/features/video/presentation/utils/zoom_geometry.dart';
import 'package:mobile_template/features/video/presentation/widgets/playback_settings_sheet.dart';
import 'package:mobile_template/features/video/presentation/widgets/playback_status_views.dart';
import 'package:mobile_template/features/video/presentation/widgets/player_controls_overlay.dart';
import 'package:mobile_template/features/video/presentation/widgets/player_timeline.dart';
import 'package:mobile_template/features/video/presentation/widgets/time_saved_indicator.dart';
import 'package:mobile_template/features/video/presentation/widgets/zoom_controls.dart';
import 'package:mobile_template/generated/l10n.dart';

/// Arabic, RTL — the app's default.
Widget _app(Widget child, {Size size = const Size(400, 800)}) => MediaQuery(
  data: MediaQueryData(size: size),
  child: MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: S.delegate.supportedLocales,
    localizationsDelegates: const [S.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
    home: Scaffold(body: child),
  ),
);

const Duration _lesson = Duration(minutes: 24, seconds: 10);

/// Wraps text the way PlaybackTime.speedLabelInText does (LTR isolate).
String _iso(String s) => '${String.fromCharCode(0x2066)}$s${String.fromCharCode(0x2069)}';

void main() {
  group('Time saved', () {
    testWidgets('card states the saving at a faster speed, with the chapter line', (tester) async {
      await tester.pumpWidget(_app(const TimeSavedCard(lesson: _lesson, chapter: Duration(minutes: 134), speed: 1.25)));
      await tester.pumpAndSettle();
      expect(find.textContaining('عند المشاهدة بسرعة ${_iso('1.25×')}، ستوفّر 4 دقائق و50 ثانية من هذا الدرس!', findRichText: true), findsOneWidget);
      expect(find.textContaining('27 دقيقة'), findsOneWidget);
      // Meter: normal length and length at speed.
      expect(find.text('24:10'), findsOneWidget);
      expect(find.text('19:20'), findsOneWidget);
    });

    testWidgets('card at normal speed suggests 1.25×', (tester) async {
      await tester.pumpWidget(_app(const TimeSavedCard(lesson: _lesson, speed: 1)));
      await tester.pumpAndSettle();
      expect(find.textContaining('السرعة العادية', findRichText: true), findsOneWidget);
      expect(find.textContaining('جرّب ${_iso('1.25×')}'), findsOneWidget);
    });

    testWidgets('card at a slower speed frames it as extra time', (tester) async {
      await tester.pumpWidget(_app(const TimeSavedCard(lesson: _lesson, speed: 0.75)));
      await tester.pumpAndSettle();
      expect(find.textContaining('سرعة أبطأ لفهم أعمق: +8 دقائق و3 ثوانٍ', findRichText: true), findsOneWidget);
    });

    testWidgets('pill is tappable', (tester) async {
      int taps = 0;
      await tester.pumpWidget(_app(TimeSavedPill(lesson: _lesson, speed: 1.5, onTap: () => taps++)));
      await tester.tap(find.text('تغيير'));
      expect(taps, 1);
    });
  });

  group('Playback settings sheet', () {
    testWidgets('picking a speed and a quality reports both and updates the card', (tester) async {
      double? speed;
      String? quality;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showPlaybackSettingsSheet(
                context: context,
                speed: 1,
                onSpeedChanged: (v) => speed = v,
                lessonDuration: _lesson,
                qualities: const ['1080p', '720p', '480p'],
                defaultQuality: '480p',
                onQualityChanged: (q) => quality = q,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('إعدادات التشغيل'), findsOneWidget);
      await tester.tap(find.text('2×'));
      await tester.pumpAndSettle();
      expect(speed, 2);
      expect(find.textContaining('ستوفّر 12 دقيقة', findRichText: true), findsOneWidget);

      await tester.ensureVisible(find.text('720p'));
      await tester.tap(find.text('720p'));
      expect(quality, '720p');
      expect(find.textContaining('الافتراضي'), findsOneWidget); // 480p is marked default
    });
  });

  group('Player controls', () {
    testWidgets('skip buttons report ±10 seconds; timeline seeks', (tester) async {
      final ValueNotifier<PlaybackSnapshot> playback = ValueNotifier(
        const PlaybackSnapshot(position: Duration(seconds: 898), duration: Duration(seconds: 1450), isPlaying: true),
      );
      addTearDown(playback.dispose);
      final List<int> skips = [];
      double? seek;
      await tester.pumpWidget(
        _app(
          SizedBox(
            width: 400,
            height: 225,
            child: PlayerControlsOverlay(
              playback: playback,
              visible: true,
              isFullscreen: false,
              title: 'درس',
              speed: 1.25,
              quality: '720p',
              onBack: () {},
              onTogglePlay: () {},
              onToggleFullscreen: () {},
              onOpenSettings: () {},
              onSkip: skips.add,
              onSeek: (f) => seek = f,
              onScrubbing: (_) {},
            ),
          ),
        ),
      );
      expect(find.textContaining('14:58 / 24:10', findRichText: true), findsOneWidget);
      expect(find.text('1.25×'), findsOneWidget);
      expect(find.text('HD'), findsOneWidget);
      // Remaining at speed: (1450 − 898) / 1.25 = 441.6s → 07:21 (whole seconds).
      expect(find.text('متبقٍ 07:21 بسرعة ${_iso('1.25×')}'), findsOneWidget);

      await tester.tap(find.text('−10'));
      await tester.tap(find.text('+10'));
      expect(skips, [-10, 10]);

      final Rect bar = tester.getRect(find.byType(PlayerTimeline));
      await tester.tapAt(Offset(bar.left + bar.width * 0.5, bar.center.dy));
      expect(seek, closeTo(0.5, 0.02));
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('timeline runs left-to-right even in RTL', (tester) async {
      double? seek;
      await tester.pumpWidget(_app(SizedBox(width: 300, child: PlayerTimeline(played: 0, buffered: 0, onSeek: (f) => seek = f))));
      final Rect bar = tester.getRect(find.byType(PlayerTimeline));
      await tester.tapAt(Offset(bar.left + 30, bar.center.dy));
      expect(seek, closeTo(0.1, 0.02));
    });
  });

  group('Zoom', () {
    testWidgets('panel presets and readouts', (tester) async {
      double? scale;
      await tester.pumpWidget(
        _app(
          SingleChildScrollView(
            child: ZoomPanel(geometry: ZoomGeometry(scale: 2, center: const Offset(0.7, 0.7)), onScale: (v) => scale = v),
          ),
        ),
      );
      expect(find.text('25%'), findsOneWidget); // visible area at 2×
      expect(find.text('يمين · أسفل'), findsOneWidget);
      await tester.tap(find.text('3×').first);
      expect(scale, 3);
    });

    testWidgets('mini-map tap moves the view centre', (tester) async {
      Offset? centre;
      await tester.pumpWidget(
        _app(
          Center(
            child: ZoomMiniMap(geometry: ZoomGeometry(scale: 2), onCenter: (c) => centre = c, preview: const ColoredBox(color: Colors.blue)),
          ),
        ),
      );
      final Rect frame = tester.getRect(find.byType(ColoredBox).last);
      await tester.tapAt(frame.topLeft + Offset(frame.width * 0.25, frame.height * 0.75));
      expect(centre!.dx, closeTo(0.25, 0.05));
      expect(centre!.dy, closeTo(0.75, 0.05));
    });

    testWidgets('region label covers the whole-frame case', (tester) async {
      final S s = await S.load(const Locale('ar'));
      expect(zoomRegionLabel(s, ZoomGeometry(scale: 1)), 'الإطار كاملًا');
      expect(zoomRegionLabel(s, ZoomGeometry(scale: 3)), 'المنتصف');
    });
  });

  group('Status views', () {
    testWidgets('retry overlay shows attempt, countdown and resume point', (tester) async {
      await tester.pumpWidget(
        _app(const SizedBox(width: 400, height: 225, child: RetryOverlay(attempt: 2, maxAttempts: 4, secondsLeft: 3, resumeAt: '14:58'))),
      );
      expect(find.text(S.current.weakConnectionRetrying), findsOneWidget);
      expect(find.text('المحاولة 2 من 4 · خلال 3 ث · سيُستأنف من 14:58'), findsOneWidget);
    });

    testWidgets('error view retries', (tester) async {
      int retries = 0;
      await tester.pumpWidget(
        _app(
          PlaybackMessageView(
            icon: Icons.error_outline_rounded,
            title: 'تعذّر تشغيل الفيديو',
            primaryLabel: 'إعادة',
            onPrimary: () => retries++,
          ),
        ),
      );
      await tester.tap(find.text('إعادة'));
      expect(retries, 1);
    });
  });
}
