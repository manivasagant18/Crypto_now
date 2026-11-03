import 'package:flutter/material.dart';

import 'package:coinlens/core/theme.dart';
import 'package:coinlens/widgets/common/surface_card.dart';

/// "About Bitcoin" with a description that expands from three lines.
class AboutCard extends StatefulWidget {
  const AboutCard({
    super.key,
    required this.coinName,
    required this.description,
    required this.failed,
    required this.onRetry,
  });

  final String coinName;

  /// Null while it is still loading.
  final String? description;

  /// True when loading the description failed.
  final bool failed;
  final VoidCallback onRetry;

  @override
  State<AboutCard> createState() => _AboutCardState();
}

class _AboutCardState extends State<AboutCard> {
  bool _expanded = false;

  void _toggle() => setState(() => _expanded = !_expanded);

  @override
  Widget build(BuildContext context) {
    final muted = mutedText(context);
    final text = widget.description;
    final body = text == null ? 'Loading description…' : (text.isEmpty ? 'No description available.' : text);

    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'About ${widget.coinName}',
                  style: TextStyle(color: strongText(context), fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: _expanded ? 'Collapse' : 'Expand',
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: _toggle,
              ),
            ],
          ),
          if (widget.failed && text == null)
            Row(
              children: [
                Expanded(child: Text("Couldn't load description", style: TextStyle(color: muted))),
                TextButton(onPressed: widget.onRetry, child: const Text('Retry')),
              ],
            )
          else ...[
            Text(
              body,
              maxLines: _expanded ? null : 3,
              overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: TextStyle(color: muted, fontSize: 14, height: 1.45),
            ),
            TextButton(
              onPressed: _toggle,
              child: Text(_expanded ? 'Show less' : 'Read more'),
            ),
          ],
        ],
      ),
    );
  }
}
