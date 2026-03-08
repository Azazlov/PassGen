import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'global_error_handler.dart';

/// Виджет глобального баннера ошибок
class GlobalErrorBanner extends StatelessWidget {
  const GlobalErrorBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final errorHandler = Provider.of<GlobalErrorHandler>(context, listen: true);

    if (!errorHandler.isVisible || errorHandler.error == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              errorHandler.error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close),
            color: Theme.of(context).colorScheme.onErrorContainer,
            onPressed: errorHandler.dismiss,
          ),
        ],
      ),
    );
  }
}
