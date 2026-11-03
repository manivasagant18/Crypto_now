import 'package:flutter/material.dart';

import 'package:coinlens/core/config.dart';
import 'package:coinlens/core/theme.dart';

/// Required attribution for CoinGecko data. In mock mode it says the data is sample data.
class AttributionFooter extends StatelessWidget {
  const AttributionFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          kUseMock ? 'Sample data · offline mode' : 'Data provided by CoinGecko',
          style: TextStyle(color: mutedText(context), fontSize: 12),
        ),
      ),
    );
  }
}
