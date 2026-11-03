# Crypto Now

Live cryptocurrency market data in four places: a searchable market list, a detail page for each coin, a whole-market statistics page, and a personal watchlist.

Crypto Now is a frontend-only Flutter app for Android and iOS. It calls CoinGecko's free public REST API directly and keeps the watchlist on the device. There is no backend server to deploy.

---

## Features

| Area | What it offers |
|------|----------------|
| **Market** | Top 250 coins by market cap. Search, five sort orders, and filters for category, gainers/losers and market-cap tier. Refreshes every 60 seconds and on pull-down. |
| **Statistics** | Total market cap, 24h volume, active coins and markets, a BTC/ETH dominance donut, and the day's top gainers and losers. |
| **Coin detail** | Price and 24h change, an interactive chart (1D, 7D, 30D, 1Y), market stats, supply progress, all-time high and low, and a description. Star to watch. |
| **Watchlist** | Your starred coins in your own order. Drag to reorder, swipe or Edit to remove. Saved on the device and kept between launches. |

## Design goals

- **Works on a free API.** CoinGecko's keyless tier allows about 5 calls a minute. The app caches every response, waits out short limits, and falls back to older data or a second provider instead of showing errors.
- **Every state is designed.** Each screen has loading skeletons, an error state with Retry, empty states with a helpful action, and a "Showing cached data" banner.
- **Runs offline.** Mock mode swaps in built-in sample data, so the app can be demoed and developed without a network.
- **Easy to read and test.** One folder per screen, one class per file, and data logic kept out of the UI.

---

## Getting started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- Android Studio or the Android SDK for Android builds
- A Mac with Xcode for iOS builds

### Create the project

```bash
flutter create --platforms=android,ios crypto_now
cd crypto_now
```

### Install dependencies

```bash
flutter pub get
```

### Run

```bash
# Live data from CoinGecko
flutter run

# Offline demo with built-in sample data
flutter run --dart-define=USE_MOCK=true
```

### Test

```bash
flutter test
```

---

## Project structure

One folder per screen, one class per file.

```
lib/
├── main.dart
├── app.dart                  # MaterialApp, theme, bottom navigation
├── core/
│   ├── api/                  # CoinGecko client, fallback provider
│   ├── cache/                # Response cache and rate-limit handling
│   ├── config/               # Mock mode flag, constants
│   └── widgets/              # Shared UI: skeletons, error state, banner
├── data/
│   ├── models/               # Coin, MarketStats, ChartPoint
│   ├── mock/                 # Built-in sample data
│   └── repositories/         # Data logic, kept out of the UI
└── screens/
    ├── market/               # List, search, sort chips, filter sheet
    ├── coin_detail/          # Header, chart, stats, description
    ├── statistics/           # Stat cards, dominance donut, movers
    └── watchlist/            # Reorderable list, edit mode
```

---

## Using the app

The app opens on the **Market** tab. A bottom navigation bar switches between Market, Statistics and Watchlist. Each tab keeps its place when you switch away and back.

### Market tab

1. **Search:** type in the search box, or tap the search icon. Matches name or symbol, e.g. "eth" or "Solana".
2. **Sort:** tap a chip (Market cap, Price, Volume, 24h change, Name). Tap the selected chip again to flip between descending and ascending.
3. **Filter:** tap the tune icon to open the filter sheet.
   - Category: DeFi, Layer 1, Meme, AI, Stablecoins
   - 24h change: Gainers or Losers
   - Market-cap tier: Large (≥ $10B), Mid ($1–10B), Small (< $1B)

   The button shows how many coins will match. A dot on the icon means filters are active.
4. **Refresh:** pull the list down. It also refreshes by itself every minute.
5. **Open a coin:** tap any row. A star next to the symbol means the coin is on your watchlist.

### Coin detail

1. The header shows the price, the 24h change chip and when the price was last updated.
2. Touch and drag on the chart to see the price and time at any point. High and low labels mark the range.
3. Switch the range with 1D / 7D / 30D / 1Y.
4. Scroll for market cap, volume, supply figures, a "% of max supply mined" bar, all-time high and low, and the coin description (tap Read more to expand).
5. Tap the star in the top bar to add or remove the coin from your watchlist.

### Statistics tab

- Four cards: total market cap, 24h volume, number of active coins, number of markets.
- The dominance donut shows Bitcoin's and Ethereum's share of the total market cap.
- Top gainers and Top losers list three coins each. **See all** opens the full list.

### Watchlist tab

- When empty, **Browse market** jumps to the Market tab.
- Drag the handle (≡) on the right to reorder. The order is saved.
- Swipe a row to the left to remove it, or tap **Edit** and use the red minus buttons.

---

## How it handles the free API

| Situation | Behavior |
|-----------|----------|
| Repeated requests | Every response is cached and reused while fresh |
| Short rate limit (HTTP 429) | The app waits and retries |
| Longer outage or limit | Falls back to older cached data or a second provider |
| No network | Shows cached data with a "Showing cached data" banner |
| Nothing cached | Shows an error state with a Retry button |

---

## Data source

Market data is provided by the [CoinGecko API](https://www.coingecko.com/en/api). Please follow CoinGecko's terms of use and attribution requirements.

 
