import 'package:flutter/material.dart';

import '../error/failures.dart';
import 'network_error_container.dart';
import 'server_error_container.dart';

class ErrorView extends StatelessWidget {
  final Failure? failure;
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.failure, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: failure is NetworkFailure
            ? NetworkErrorContainer(onRetry: onRetry)
            : ServerErrorContainer(
                onRetry: onRetry,
                errorMessage: failure?.statusMessage,
              ),
      ),
    );
  }
}
