import 'package:flutter/material.dart';

import '../config/app_config.dart';

class DemoModeBanner extends StatelessWidget {
  const DemoModeBanner({super.key, this.visible});

  final bool? visible;

  @override
  Widget build(BuildContext context) {
    if (!(visible ?? AppConfig.demoMode)) {
      return const SizedBox.shrink();
    }
    return Semantics(
      label: 'Mode démonstration actif',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.science_outlined, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: Text('Mode démonstration · données et analyses simulées'),
            ),
          ],
        ),
      ),
    );
  }
}
