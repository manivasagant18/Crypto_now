// Build-time switches, set with --dart-define:
//
//   flutter run --dart-define=MOCK=true
//   flutter run --dart-define=COINGECKO_API_KEY=CG-xxxxxxxx

/// Use the built-in sample data instead of the network. Works fully offline.
const kUseMock = bool.fromEnvironment('MOCK');

/// Optional free CoinGecko Demo key. Without one, CoinGecko allows only about
/// 5 calls a minute.
const kCoinGeckoApiKey = String.fromEnvironment('COINGECKO_API_KEY');
