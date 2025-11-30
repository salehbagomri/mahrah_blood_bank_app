import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../constants/app_colors.dart';

/// ويدجت للتحميل
class LoadingWidget extends StatelessWidget {
  final String? message;
  final double size;

  const LoadingWidget({
    super.key,
    this.message,
    this.size = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitFadingCircle(
            color: AppColors.primary,
            size: size,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// ويدجت للتحميل كصندوق حوار
class LoadingDialog extends StatelessWidget {
  final String? message;

  const LoadingDialog({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SpinKitFadingCircle(
            color: AppColors.primary,
            size: 50.0,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  /// عرض صندوق حوار التحميل
  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LoadingDialog(message: message),
    );
  }

  /// إخفاء صندوق حوار التحميل
  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}

