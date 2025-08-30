import 'package:flutter/material.dart';

class ProgressIndicatorWidget extends StatelessWidget {
  final double progress;
  
  const ProgressIndicatorWidget({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.transparent,
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
