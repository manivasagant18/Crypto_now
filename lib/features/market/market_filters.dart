// Market list filtering and sorting. Plain Dart, no Flutter, so it is easy to test.

import 'package:coinlens/models/coin_market.dart';

enum SortField { marketCap, price, volume, change, name }

enum ChangeFilter { all, gainers, losers }

enum CapTier { all, large, mid, small }

/// Category slugs match CoinGecko's category ids. The mock data uses the same ones.
const kCategories = [
  (label: 'All', slug: ''),
  (label: 'DeFi', slug: 'decentralized-finance-defi'),
  (label: 'Layer 1', slug: 'layer-1'),
  (label: 'Meme', slug: 'meme-token'),
  (label: 'AI', slug: 'artificial-intelligence'),
  (label: 'Stablecoins', slug: 'stablecoins'),
];

const kSortLabels = {
  SortField.marketCap: 'Market cap',
  SortField.price: 'Price',
  SortField.volume: 'Volume',
  SortField.change: '24h change',
  SortField.name: 'Name',
};

/// Orders two coins by [field], smallest first.
int compareCoins(SortField field, CoinMarket a, CoinMarket b) => switch (field) {
      SortField.marketCap => a.marketCap.compareTo(b.marketCap),
      SortField.price => a.price.compareTo(b.price),
      SortField.volume => a.volume24h.compareTo(b.volume24h),
      SortField.change => a.change24h.compareTo(b.change24h),
      SortField.name => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    };

/// Filter state. Category is sent to the data source. Change and cap tier run on the device.
class MarketFilters {
  const MarketFilters({
    this.category = '',
    this.change = ChangeFilter.all,
    this.tier = CapTier.all,
  });

  final String category;
  final ChangeFilter change;
  final CapTier tier;

  bool get isActive => category.isNotEmpty || change != ChangeFilter.all || tier != CapTier.all;

  bool matches(CoinMarket c) {
    final okChange = switch (change) {
      ChangeFilter.all => true,
      ChangeFilter.gainers => c.change24h > 0,
      ChangeFilter.losers => c.change24h < 0,
    };
    final okTier = switch (tier) {
      CapTier.all => true,
      CapTier.large => c.marketCap >= 10e9,
      CapTier.mid => c.marketCap >= 1e9 && c.marketCap < 10e9,
      CapTier.small => c.marketCap < 1e9,
    };
    return okChange && okTier;
  }

  MarketFilters copyWith({String? category, ChangeFilter? change, CapTier? tier}) {
    return MarketFilters(
      category: category ?? this.category,
      change: change ?? this.change,
      tier: tier ?? this.tier,
    );
  }
}
