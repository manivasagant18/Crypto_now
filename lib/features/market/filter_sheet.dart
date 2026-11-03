import 'package:flutter/material.dart';

import 'package:coinlens/core/theme.dart';
import 'package:coinlens/features/market/market_filters.dart';
import 'package:coinlens/widgets/common/pill_chip.dart';

/// Bottom sheet with category, 24h change and market cap tier filters.
/// Pops with the chosen MarketFilters, or null when dismissed.
class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key, required this.initial, required this.countFor});

  final MarketFilters initial;

  /// How many coins a draft would show, for the "Show N results" button.
  final int Function(MarketFilters) countFor;

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late MarketFilters _draft;

  static const _changeLabels = {
    ChangeFilter.all: 'All',
    ChangeFilter.gainers: 'Gainers',
    ChangeFilter.losers: 'Losers',
  };

  static const _tierLabels = {
    CapTier.all: 'All',
    CapTier.large: 'Large',
    CapTier.mid: 'Mid',
    CapTier.small: 'Small',
  };

  @override
  void initState() {
    super.initState();
    _draft = widget.initial;
  }

  Widget _section(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: strongText(context), fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.countFor(_draft);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Filters',
                    style: TextStyle(color: strongText(context), fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _draft = const MarketFilters()),
                  child: const Text('Reset'),
                ),
              ],
            ),
            _section(
              'Category',
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in kCategories)
                    PillChip(
                      label: c.label,
                      selected: _draft.category == c.slug,
                      showCheck: true,
                      onTap: () => setState(() => _draft = _draft.copyWith(category: c.slug)),
                    ),
                ],
              ),
            ),
            _section(
              '24h change',
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final e in _changeLabels.entries)
                    PillChip(
                      label: e.value,
                      selected: _draft.change == e.key,
                      showCheck: true,
                      onTap: () => setState(() => _draft = _draft.copyWith(change: e.key)),
                    ),
                ],
              ),
            ),
            _section(
              'Market cap tier',
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final e in _tierLabels.entries)
                    PillChip(
                      label: e.value,
                      selected: _draft.tier == e.key,
                      showCheck: true,
                      onTap: () => setState(() => _draft = _draft.copyWith(tier: e.key)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(_draft),
                child: Text('Show $count results'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
