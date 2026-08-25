# Trading App — Flutter

A feature-complete Flutter trading app with **Watchlists**, **Live Prices**, **Buy/Sell Ticket**, **Holdings**, and generated **localization** — built on a custom mock market-data feed.

## UI direction

The app uses a dark, institutional trading-terminal visual system inspired by modern brokerage interfaces: deep slate surfaces, electric green buy/positive states, red sell/negative states, tabular price typography, compact data rows, live badges, and price flash feedback. The design is intentionally dense but touch-friendly.

## Features

### Extra polish
- Fast stock search on the market screen
- Live market breadth card (live instruments / gainers / losers)
- Fractional quantity support up to 4 decimal places
- Theme + configurable stress tick-rate controls
- Executed order-history screen with persisted balance and trades
- Centralized enum definitions in `lib/core/constants/enum.dart`
- Localized UI strings and validation messages through Flutter gen_l10n

### 5. Localization
- English translations are maintained in `lib/l10n/app_en.arb`
- Generated accessors are written to `lib/l10n/app_localizations.dart`
- Flutter localization delegates and supported locales are registered in `MaterialApp`
- Add another locale by creating a translated ARB file such as `app_hi.arb`, then run:

```bash
flutter gen-l10n
```

- Keep user-facing text in ARB resources rather than hardcoding it in widgets, dialogs, or validation logic.

### 6. Code organization
- Shared enum types live in `lib/core/constants/enum.dart`.
- Feature-specific data, domain entities, blocs, pages, and widgets remain grouped under `lib/features/`.
- Generated localization files should not be edited manually; update the ARB files and regenerate them.

### 1. Watchlists
- Create, rename, and delete multiple watchlists
- Add stocks from a 10-stock picker
- Reorder stocks via drag-handle
- Swipe a row to remove it
- All watchlists and their order persist across restarts (`SharedPreferences`)
- Tap a row to open the Buy/Sell ticket pre-filled with that stock

### 2. Live Prices (Mock Feed)
- Continuously updating market overview for 10 NSE-style stocks
- Configurable tick rate (1s default, stress-test up to 100 ms = 100 ticks/sec)
- Single source of truth: one `MockMarketFeed` singleton with a broadcast stream
- Brief flash highlight on every tick (green up / red down)
- Smooth scrolling under load — `RepaintBoundary` per row, `BlocSelector` to scope rebuilds

### 3. Buy / Sell Ticket
- Pre-fills stock when opened from a watchlist or holding
- Live LTP shown at the top and refreshed from the same feed used by the rest of the app
- Buy/Sell side toggle, quantity input with stepper buttons
- Order value = qty × the latest feed LTP at the exact moment of submission
- Inline validation: zero/negative quantity, >4 decimals, insufficient balance, oversell
- Successful order → confirmation screen with order details
- Wallet balance and order history persist across restarts

### 4. Holdings
- Live P&L per holding as ticks arrive (no re-fetch of full list)
- Aggregate summary: total invested, current value, total P&L (₹ and %)
- Sort by P&L (default), symbol, or current value
- Sort order updates as prices move (rows re-rank live)
- Tap a holding to open the Buy/Sell ticket
- Empty state when no holdings exist

## The 10 stocks

| Symbol | Company | Seed price |
|---|---|---|
| RELIANCE | Reliance Industries | ₹2,945.50 |
| TCS | Tata Consultancy Services | ₹4,120.75 |
| INFY | Infosys | ₹1,845.20 |
| HDFCBANK | HDFC Bank | ₹1,672.40 |
| ICICIBANK | ICICI Bank | ₹1,258.90 |
| SBIN | State Bank of India | ₹824.15 |
| ITC | ITC Limited | ₹478.60 |
| LT | Larsen & Toubro | ₹3,621.85 |
| BHARTIARTL | Bharti Airtel | ₹1,547.25 |
| AXISBANK | Axis Bank | ₹1,189.50 |

## Architecture

```
lib/
├── core/
│   ├── constants/    AppConstants, centralized enums
│   ├── theme/        AppTheme, AppColors, AppTextStyles
│   ├── utils/        DecimalUtils, Formatters (₹, en_IN), Responsive
│   └── storage/      LocalStorage (SharedPreferences wrapper, JSON)
├── l10n/             English ARB resources and generated localization accessors
├── shared/
│   └── widgets/      AnimatedPriceText, FlashHighlight, EmptyState
└── features/
    ├── market_data/        domain/{Stock,PriceTick,Quote}  data/MockMarketFeed  presentation/{MarketBloc, MarketOverviewPage, QuoteRow}
    ├── watchlist/          domain/Watchlist                data/WatchlistRepository  presentation/{WatchlistBloc, WatchlistsPage, WatchlistDetailPage}
    ├── holdings/           domain/{Holding,Order,HoldingRow} data/PortfolioRepository presentation/{PortfolioBloc, HoldingsPage, HoldingRow, PortfolioSummaryCard}
    ├── order/              presentation/{OrderBloc, BuySellTicketPage, OrderConfirmationPage, OrderHistoryPage}
    ├── stock_picker/       presentation/widgets/StockPickerSheet
    └── home/               presentation/{SettingsBloc, HomeShellPage (bottom nav + side rail)}
```

### Patterns
- **State management:** `flutter_bloc` with `BlocBuilder` and `BlocSelector`. Fine-grained `buildWhen` to avoid rebuilding unchanged rows.
- **Money:** `Decimal` package for exact arithmetic — no `double` drift visible to user. `intl` with `en_IN` for ₹ formatting.
- **Localization:** Flutter's generated `AppLocalizations` API backed by ARB resources. User-facing labels, dialogs, empty states, and validation messages are localized.
- **Persistence:** JSON-encoded `SharedPreferences`. Watchlists, holdings, orders, wallet balance, settings.
- **Mock feed:** Singleton `MockMarketFeed` emits `PriceTick` events from one `Timer.periodic`. Random walk with mean reversion to keep prices bounded.
- **Reactive UI:** `MarketBloc` subscribes once to the feed stream; downstream blocs/pages listen via `context.watch` or `BlocBuilder`.

### Performance choices
- `RepaintBoundary` per row to isolate flash animations
- `ListView.builder` / `ReorderableListView.builder` for viewport recycling
- `AnimatedSwitcher` on price text — only the changing cell animates
- `buildWhen` filters market updates to only relevant symbols on the watchlist screen
- Stress-test mode (100 ms ticks) is available from the in-app market settings

## Run it

```bash
flutter pub get
flutter run
```

That's it — no backend, no API keys. The mock feed starts automatically when the app boots.

### Run on a specific platform
```bash
flutter run -d ios
flutter run -d android
flutter run -d macos
flutter run -d chrome
```

### Run tests
```bash
flutter test
```

### Generate localization files
Localization code is generated from the ARB resources configured in `l10n.yaml`:

```bash
flutter gen-l10n
```

Run this command after adding or changing translations in `lib/l10n/app_en.arb`.

## Walkthrough checklist
For a short submission video, demonstrate this flow:
1. Open **Markets** and show live prices changing.
2. Open **Market Settings** and switch to `200ms` or `100ms` stress mode.
3. Create a second watchlist, add stocks, reorder one, then swipe to remove one.
4. Tap a stock and place a fractional **BUY** order.
5. Show the confirmation, then open **Portfolio** and sort by P&L.
6. Open the holding, switch to **SELL**, and sell the full quantity so it disappears.
7. Open **Order History** and show the persisted balance and executed orders.
8. Restart the app and demonstrate that watchlists, holdings, orders, wallet, and settings are restored.

## In-app stress test
The market settings sheet supports `1s`, `500ms`, `200ms`, and `100ms` intervals. At `100ms`, the feed emits 10 stocks × 10 ticks/sec = 100 ticks/sec overall. The UI uses row-level selectors and repaint boundaries to keep unrelated cells isolated.

## License
MIT
