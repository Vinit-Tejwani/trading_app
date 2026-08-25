// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => '021 Trading';

  @override
  String get watchlist => 'Watchlist';

  @override
  String get markets => 'Markets';

  @override
  String get trade => 'Trade';

  @override
  String get portfolio => 'Portfolio';

  @override
  String get live => 'LIVE';

  @override
  String get orderHistory => 'Order History';

  @override
  String get close => 'Close';

  @override
  String get marketSettings => 'Market settings';

  @override
  String get marketOverviewTitle => '021 Trading';

  @override
  String get marketOverviewSubtitle => 'MARKET OVERVIEW · NSE · EQUITIES';

  @override
  String get searchSymbolOrCompany => 'Search symbol or company…';

  @override
  String get searchStockToTrade => 'Search a stock to trade…';

  @override
  String get symbol => 'SYMBOL';

  @override
  String get trend => 'TREND';

  @override
  String get ltpChange => 'LTP / CHANGE';

  @override
  String get all => 'ALL';

  @override
  String get gainers => 'GAINERS';

  @override
  String get losers => 'LOSERS';

  @override
  String get marketPulse => 'MARKET PULSE';

  @override
  String get liveMarket => 'LIVE MARKET';

  @override
  String get topMover => 'TOP MOVER';

  @override
  String get instruments => 'INSTRUMENTS';

  @override
  String get marketSettingsTitle => 'MARKET SETTINGS';

  @override
  String get marketSettingsDescription =>
      'Tune the mock feed to demonstrate normal and stress conditions.';

  @override
  String get tickRate => 'TICK RATE';

  @override
  String get theme => 'THEME';

  @override
  String get dark => 'Dark';

  @override
  String get light => 'Light';

  @override
  String get resetDemoAccount => 'RESET DEMO ACCOUNT';

  @override
  String get resetDemoAccountTitle => 'Reset demo account?';

  @override
  String get resetDemoAccountDescription =>
      'This clears wallet balance, holdings and order history. Watchlists are kept.';

  @override
  String get cancel => 'Cancel';

  @override
  String get reset => 'Reset';

  @override
  String get tradeDesk => 'TRADE DESK';

  @override
  String get marketOrdersLiveLtp => 'Market orders · execution at live LTP';

  @override
  String get tradeAction => 'TRADE';

  @override
  String get orderTicket => 'ORDER TICKET';

  @override
  String get marketOrderNseEquities => 'MARKET ORDER · NSE EQUITIES';

  @override
  String get market => 'MARKET';

  @override
  String get buy => 'BUY';

  @override
  String get sell => 'SELL';

  @override
  String get quantity => 'QUANTITY';

  @override
  String get quantityHint => '0.0000';

  @override
  String get defaultOrderQuantity => '1';

  @override
  String get availableMargin => 'AVAILABLE MARGIN';

  @override
  String get zeroQuantity => '0';

  @override
  String get nseEquity => 'NSE EQ';

  @override
  String nseEquityNamed(Object name) {
    return '$name · NSE EQ';
  }

  @override
  String availableMarginAmount(Object amount) {
    return 'AVAILABLE MARGIN  $amount';
  }

  @override
  String availableHolding(Object quantity) {
    return 'AVAILABLE HOLDING  $quantity SHARES';
  }

  @override
  String get ltp => 'LTP';

  @override
  String get orderValue => 'ORDER VALUE';

  @override
  String get orderExecutesAtLatestPrice =>
      'Order executes at the latest available mock-market LTP when submitted.';

  @override
  String buySymbol(Object symbol) {
    return 'BUY $symbol';
  }

  @override
  String sellSymbol(Object symbol) {
    return 'SELL $symbol';
  }

  @override
  String get orderConfirmed => 'Order confirmed';

  @override
  String get buyOrderPlaced => 'Buy order placed';

  @override
  String get sellOrderPlaced => 'Sell order placed';

  @override
  String sharesOfAt(Object price, Object quantity, Object symbol) {
    return '$quantity shares of $symbol at $price';
  }

  @override
  String get orderId => 'Order ID';

  @override
  String get side => 'Side';

  @override
  String get symbolLabel => 'Symbol';

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get price => 'Price';

  @override
  String get orderValueLabel => 'Order value';

  @override
  String get done => 'Done';

  @override
  String get placeAnotherOrder => 'Place another order';

  @override
  String get persistedDemoWallet => 'Persisted demo wallet';

  @override
  String get noOrders => 'NO ORDERS';

  @override
  String get executedMarketOrdersAppearHere =>
      'Executed market orders will appear here.';

  @override
  String sharesAtPrice(Object quantity, Object time) {
    return '$quantity shares · $time';
  }

  @override
  String atPrice(Object price) {
    return '@ $price';
  }

  @override
  String get noOpenPositions => 'NO OPEN POSITIONS';

  @override
  String get noHoldings => 'NO HOLDINGS';

  @override
  String get noHoldingsMessage =>
      'Place a buy order from Trade or a watchlist to start building your portfolio.';

  @override
  String openPosition(Object count) {
    return '$count OPEN POSITION';
  }

  @override
  String openPositions(Object count) {
    return '$count OPEN POSITIONS';
  }

  @override
  String get portfolioValue => 'PORTFOLIO VALUE';

  @override
  String get invested => 'INVESTED';

  @override
  String get positions => 'POSITIONS';

  @override
  String get pAndL => 'P&L';

  @override
  String get currentValue => 'CURRENT VALUE';

  @override
  String get value => 'VALUE';

  @override
  String pnlSummary(Object percent, Object pnl) {
    return '$pnl  $percent';
  }

  @override
  String quoteChangeSummary(Object change, Object percent) {
    return '$change  $percent';
  }

  @override
  String holdingQuantityAverage(Object price, Object quantity) {
    return '$quantity QTY · AVG $price';
  }

  @override
  String get watchlists => 'Watchlists';

  @override
  String get trackFavouriteInstruments => 'TRACK YOUR FAVOURITE INSTRUMENTS';

  @override
  String get noWatchlists => 'NO WATCHLISTS';

  @override
  String get createListMessage =>
      'Create a list to start tracking your favourite instruments.';

  @override
  String get createWatchlist => 'CREATE WATCHLIST';

  @override
  String get newWatchlist => 'New watchlist';

  @override
  String get name => 'Name';

  @override
  String get create => 'Create';

  @override
  String get defaultWatchlistName => 'My Watchlist';

  @override
  String get newWatchlistFallbackName => 'New Watchlist';

  @override
  String get watchlistNotFound => 'Watchlist not found';

  @override
  String instrumentCount(Object count) {
    return '$count INSTRUMENTS · DRAG TO REORDER';
  }

  @override
  String get instrumentCountSingular => '1 INSTRUMENT · DRAG TO REORDER';

  @override
  String get rename => 'Rename';

  @override
  String get deleteWatchlist => 'Delete watchlist';

  @override
  String get noStocks => 'NO STOCKS';

  @override
  String get noStocksMessage =>
      'Add instruments from the available market list.';

  @override
  String get addStocks => 'ADD STOCKS';

  @override
  String get addInstrument => 'ADD INSTRUMENT';

  @override
  String deleteWatchlistTitle(Object name) {
    return 'Delete \"$name\"?';
  }

  @override
  String get deleteWatchlistMessage =>
      'This watchlist will be permanently removed.';

  @override
  String get delete => 'Delete';

  @override
  String get renameWatchlist => 'Rename watchlist';

  @override
  String get save => 'Save';

  @override
  String get pickAStock => 'Pick a stock';

  @override
  String instrumentSummary(
      Object count, Object gainerPlural, Object gainers, Object plural) {
    return '$count INSTRUMENT$plural · $gainers GAINER$gainerPlural';
  }

  @override
  String quotePreview(Object percent, Object symbol) {
    return '$symbol $percent';
  }

  @override
  String unknownSymbol(Object symbol) {
    return 'Unknown symbol $symbol';
  }

  @override
  String get quantityMustBeGreaterThanZero =>
      'Quantity must be greater than zero';

  @override
  String get quantityMaxDecimals => 'Quantity supports up to 4 decimal places';

  @override
  String get livePriceUnavailable =>
      'Live price unavailable. Please try again.';

  @override
  String insufficientBalance(Object available, Object needed) {
    return 'Insufficient balance. Available $available but order needs $needed';
  }

  @override
  String insufficientQuantity(Object quantity, Object symbol) {
    return 'Insufficient quantity. You hold $quantity shares of $symbol';
  }

  @override
  String get localStorageNotInitialized =>
      'Local storage is not initialized. Call LocalStorage.init().';

  @override
  String seconds(Object seconds) {
    return '${seconds}s';
  }

  @override
  String milliseconds(Object milliseconds) {
    return '${milliseconds}ms';
  }

  @override
  String executedOrder(Object count) {
    return '$count EXECUTED ORDER';
  }

  @override
  String executedOrders(Object count) {
    return '$count EXECUTED ORDERS';
  }
}
