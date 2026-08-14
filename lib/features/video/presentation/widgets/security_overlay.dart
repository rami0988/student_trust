import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';

/// Full-screen red overlay shown when screen recording is detected; playback
/// is paused behind it until the recording app is stopped.
class SecurityOverlay extends StatelessWidget {
  const SecurityOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xCCFF0000),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.block, size: 72, color: Colors.white),
            const SizedBox(height: 16),
            Text(
              S.of(context).videoPaused,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              S.of(context).recordingDetected,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
