import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'021 Trading'**
  String get appName;

  /// No description provided for @watchlist.
  ///
  /// In en, this message translates to:
  /// **'Watchlist'**
  String get watchlist;

  /// No description provided for @markets.
  ///
  /// In en, this message translates to:
  /// **'Markets'**
  String get markets;

  /// No description provided for @trade.
  ///
  /// In en, this message translates to:
  /// **'Trade'**
  String get trade;

  /// No description provided for @portfolio.
  ///
  /// In en, this message translates to:
  /// **'Portfolio'**
  String get portfolio;

  /// No description provided for @live.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get live;

  /// No description provided for @orderHistory.
  ///
  /// In en, this message translates to:
  /// **'Order History'**
  String get orderHistory;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @marketSettings.
  ///
  /// In en, this message translates to:
  /// **'Market settings'**
  String get marketSettings;

  /// No description provided for @marketOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'021 Trading'**
  String get marketOverviewTitle;

  /// No description provided for @marketOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'MARKET OVERVIEW · NSE · EQUITIES'**
  String get marketOverviewSubtitle;

  /// No description provided for @searchSymbolOrCompany.
  ///
  /// In en, this message translates to:
  /// **'Search symbol or company…'**
  String get searchSymbolOrCompany;

  /// No description provided for @searchStockToTrade.
  ///
  /// In en, this message translates to:
  /// **'Search a stock to trade…'**
  String get searchStockToTrade;

  /// No description provided for @symbol.
  ///
  /// In en, this message translates to:
  /// **'SYMBOL'**
  String get symbol;

  /// No description provided for @trend.
  ///
  /// In en, this message translates to:
  /// **'TREND'**
  String get trend;

  /// No description provided for @ltpChange.
  ///
  /// In en, this message translates to:
  /// **'LTP / CHANGE'**
  String get ltpChange;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'ALL'**
  String get all;

  /// No description provided for @gainers.
  ///
  /// In en, this message translates to:
  /// **'GAINERS'**
  String get gainers;

  /// No description provided for @losers.
  ///
  /// In en, this message translates to:
  /// **'LOSERS'**
  String get losers;

  /// No description provided for @marketPulse.
  ///
  /// In en, this message translates to:
  /// **'MARKET PULSE'**
  String get marketPulse;

  /// No description provided for @liveMarket.
  ///
  /// In en, this message translates to:
  /// **'LIVE MARKET'**
  String get liveMarket;

  /// No description provided for @topMover.
  ///
  /// In en, this message translates to:
  /// **'TOP MOVER'**
  String get topMover;

  /// No description provided for @instruments.
  ///
  /// In en, this message translates to:
  /// **'INSTRUMENTS'**
  String get instruments;

  /// No description provided for @marketSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'MARKET SETTINGS'**
  String get marketSettingsTitle;

  /// No description provided for @marketSettingsDescription.
  ///
  /// In en, this message translates to:
  /// **'Tune the mock feed to demonstrate normal and stress conditions.'**
  String get marketSettingsDescription;

  /// No description provided for @tickRate.
  ///
  /// In en, this message translates to:
  /// **'TICK RATE'**
  String get tickRate;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'THEME'**
  String get theme;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @resetDemoAccount.
  ///
  /// In en, this message translates to:
  /// **'RESET DEMO ACCOUNT'**
  String get resetDemoAccount;

  /// No description provided for @resetDemoAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset demo account?'**
  String get resetDemoAccountTitle;

  /// No description provided for @resetDemoAccountDescription.
  ///
  /// In en, this message translates to:
  /// **'This clears wallet balance, holdings and order history. Watchlists are kept.'**
  String get resetDemoAccountDescription;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @tradeDesk.
  ///
  /// In en, this message translates to:
  /// **'TRADE DESK'**
  String get tradeDesk;

  /// No description provided for @marketOrdersLiveLtp.
  ///
  /// In en, this message translates to:
  /// **'Market orders · execution at live LTP'**
  String get marketOrdersLiveLtp;

  /// No description provided for @tradeAction.
  ///
  /// In en, this message translates to:
  /// **'TRADE'**
  String get tradeAction;

  /// No description provided for @orderTicket.
  ///
  /// In en, this message translates to:
  /// **'ORDER TICKET'**
  String get orderTicket;

  /// No description provided for @marketOrderNseEquities.
  ///
  /// In en, this message translates to:
  /// **'MARKET ORDER · NSE EQUITIES'**
  String get marketOrderNseEquities;

  /// No description provided for @market.
  ///
  /// In en, this message translates to:
  /// **'MARKET'**
  String get market;

  /// No description provided for @buy.
  ///
  /// In en, this message translates to:
  /// **'BUY'**
  String get buy;

  /// No description provided for @sell.
  ///
  /// In en, this message translates to:
  /// **'SELL'**
  String get sell;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'QUANTITY'**
  String get quantity;

  /// No description provided for @quantityHint.
  ///
  /// In en, this message translates to:
  /// **'0.0000'**
  String get quantityHint;

  /// No description provided for @defaultOrderQuantity.
  ///
  /// In en, this message translates to:
  /// **'1'**
  String get defaultOrderQuantity;

  /// No description provided for @availableMargin.
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE MARGIN'**
  String get availableMargin;

  /// No description provided for @zeroQuantity.
  ///
  /// In en, this message translates to:
  /// **'0'**
  String get zeroQuantity;

  /// No description provided for @nseEquity.
  ///
  /// In en, this message translates to:
  /// **'NSE EQ'**
  String get nseEquity;

  /// No description provided for @nseEquityNamed.
  ///
  /// In en, this message translates to:
  /// **'{name} · NSE EQ'**
  String nseEquityNamed(Object name);

  /// No description provided for @availableMarginAmount.
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE MARGIN  {amount}'**
  String availableMarginAmount(Object amount);

  /// No description provided for @availableHolding.
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE HOLDING  {quantity} SHARES'**
  String availableHolding(Object quantity);

  /// No description provided for @ltp.
  ///
  /// In en, this message translates to:
  /// **'LTP'**
  String get ltp;

  /// No description provided for @orderValue.
  ///
  /// In en, this message translates to:
  /// **'ORDER VALUE'**
  String get orderValue;

  /// No description provided for @orderExecutesAtLatestPrice.
  ///
  /// In en, this message translates to:
  /// **'Order executes at the latest available mock-market LTP when submitted.'**
  String get orderExecutesAtLatestPrice;

  /// No description provided for @buySymbol.
  ///
  /// In en, this message translates to:
  /// **'BUY {symbol}'**
  String buySymbol(Object symbol);

  /// No description provided for @sellSymbol.
  ///
  /// In en, this message translates to:
  /// **'SELL {symbol}'**
  String sellSymbol(Object symbol);

  /// No description provided for @orderConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Order confirmed'**
  String get orderConfirmed;

  /// No description provided for @buyOrderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Buy order placed'**
  String get buyOrderPlaced;

  /// No description provided for @sellOrderPlaced.
  ///
  /// In en, this message translates to:
  /// **'Sell order placed'**
  String get sellOrderPlaced;

  /// No description provided for @sharesOfAt.
  ///
  /// In en, this message translates to:
  /// **'{quantity} shares of {symbol} at {price}'**
  String sharesOfAt(Object price, Object quantity, Object symbol);

  /// No description provided for @orderId.
  ///
  /// In en, this message translates to:
  /// **'Order ID'**
  String get orderId;

  /// No description provided for @side.
  ///
  /// In en, this message translates to:
  /// **'Side'**
  String get side;

  /// No description provided for @symbolLabel.
  ///
  /// In en, this message translates to:
  /// **'Symbol'**
  String get symbolLabel;

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @orderValueLabel.
  ///
  /// In en, this message translates to:
  /// **'Order value'**
  String get orderValueLabel;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @placeAnotherOrder.
  ///
  /// In en, this message translates to:
  /// **'Place another order'**
  String get placeAnotherOrder;

  /// No description provided for @persistedDemoWallet.
  ///
  /// In en, this message translates to:
  /// **'Persisted demo wallet'**
  String get persistedDemoWallet;

  /// No description provided for @noOrders.
  ///
  /// In en, this message translates to:
  /// **'NO ORDERS'**
  String get noOrders;

  /// No description provided for @executedMarketOrdersAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Executed market orders will appear here.'**
  String get executedMarketOrdersAppearHere;

  /// No description provided for @sharesAtPrice.
  ///
  /// In en, this message translates to:
  /// **'{quantity} shares · {time}'**
  String sharesAtPrice(Object quantity, Object time);

  /// No description provided for @atPrice.
  ///
  /// In en, this message translates to:
  /// **'@ {price}'**
  String atPrice(Object price);

  /// No description provided for @noOpenPositions.
  ///
  /// In en, this message translates to:
  /// **'NO OPEN POSITIONS'**
  String get noOpenPositions;

  /// No description provided for @noHoldings.
  ///
  /// In en, this message translates to:
  /// **'NO HOLDINGS'**
  String get noHoldings;

  /// No description provided for @noHoldingsMessage.
  ///
  /// In en, this message translates to:
  /// **'Place a buy order from Trade or a watchlist to start building your portfolio.'**
  String get noHoldingsMessage;

  /// No description provided for @openPosition.
  ///
  /// In en, this message translates to:
  /// **'{count} OPEN POSITION'**
  String openPosition(Object count);

  /// No description provided for @openPositions.
  ///
  /// In en, this message translates to:
  /// **'{count} OPEN POSITIONS'**
  String openPositions(Object count);

  /// No description provided for @portfolioValue.
  ///
  /// In en, this message translates to:
  /// **'PORTFOLIO VALUE'**
  String get portfolioValue;

  /// No description provided for @invested.
  ///
  /// In en, this message translates to:
  /// **'INVESTED'**
  String get invested;

  /// No description provided for @positions.
  ///
  /// In en, this message translates to:
  /// **'POSITIONS'**
  String get positions;

  /// No description provided for @pAndL.
  ///
  /// In en, this message translates to:
  /// **'P&L'**
  String get pAndL;

  /// No description provided for @currentValue.
  ///
  /// In en, this message translates to:
  /// **'CURRENT VALUE'**
  String get currentValue;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'VALUE'**
  String get value;

  /// No description provided for @pnlSummary.
  ///
  /// In en, this message translates to:
  /// **'{pnl}  {percent}'**
  String pnlSummary(Object percent, Object pnl);

  /// No description provided for @quoteChangeSummary.
  ///
  /// In en, this message translates to:
  /// **'{change}  {percent}'**
  String quoteChangeSummary(Object change, Object percent);

  /// No description provided for @holdingQuantityAverage.
  ///
  /// In en, this message translates to:
  /// **'{quantity} QTY · AVG {price}'**
  String holdingQuantityAverage(Object price, Object quantity);

  /// No description provided for @watchlists.
  ///
  /// In en, this message translates to:
  /// **'Watchlists'**
  String get watchlists;

  /// No description provided for @trackFavouriteInstruments.
  ///
  /// In en, this message translates to:
  /// **'TRACK YOUR FAVOURITE INSTRUMENTS'**
  String get trackFavouriteInstruments;

  /// No description provided for @noWatchlists.
  ///
  /// In en, this message translates to:
  /// **'NO WATCHLISTS'**
  String get noWatchlists;

  /// No description provided for @createListMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a list to start tracking your favourite instruments.'**
  String get createListMessage;

  /// No description provided for @createWatchlist.
  ///
  /// In en, this message translates to:
  /// **'CREATE WATCHLIST'**
  String get createWatchlist;

  /// No description provided for @newWatchlist.
  ///
  /// In en, this message translates to:
  /// **'New watchlist'**
  String get newWatchlist;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @defaultWatchlistName.
  ///
  /// In en, this message translates to:
  /// **'My Watchlist'**
  String get defaultWatchlistName;

  /// No description provided for @newWatchlistFallbackName.
  ///
  /// In en, this message translates to:
  /// **'New Watchlist'**
  String get newWatchlistFallbackName;

  /// No description provided for @watchlistNotFound.
  ///
  /// In en, this message translates to:
  /// **'Watchlist not found'**
  String get watchlistNotFound;

  /// No description provided for @instrumentCount.
  ///
  /// In en, this message translates to:
  /// **'{count} INSTRUMENTS · DRAG TO REORDER'**
  String instrumentCount(Object count);

  /// No description provided for @instrumentCountSingular.
  ///
  /// In en, this message translates to:
  /// **'1 INSTRUMENT · DRAG TO REORDER'**
  String get instrumentCountSingular;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @deleteWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Delete watchlist'**
  String get deleteWatchlist;

  /// No description provided for @noStocks.
  ///
  /// In en, this message translates to:
  /// **'NO STOCKS'**
  String get noStocks;

  /// No description provided for @noStocksMessage.
  ///
  /// In en, this message translates to:
  /// **'Add instruments from the available market list.'**
  String get noStocksMessage;

  /// No description provided for @addStocks.
  ///
  /// In en, this message translates to:
  /// **'ADD STOCKS'**
  String get addStocks;

  /// No description provided for @addInstrument.
  ///
  /// In en, this message translates to:
  /// **'ADD INSTRUMENT'**
  String get addInstrument;

  /// No description provided for @deleteWatchlistTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"?'**
  String deleteWatchlistTitle(Object name);

  /// No description provided for @deleteWatchlistMessage.
  ///
  /// In en, this message translates to:
  /// **'This watchlist will be permanently removed.'**
  String get deleteWatchlistMessage;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @renameWatchlist.
  ///
  /// In en, this message translates to:
  /// **'Rename watchlist'**
  String get renameWatchlist;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @pickAStock.
  ///
  /// In en, this message translates to:
  /// **'Pick a stock'**
  String get pickAStock;

  /// No description provided for @instrumentSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} INSTRUMENT{plural} · {gainers} GAINER{gainerPlural}'**
  String instrumentSummary(
      Object count, Object gainerPlural, Object gainers, Object plural);

  /// No description provided for @quotePreview.
  ///
  /// In en, this message translates to:
  /// **'{symbol} {percent}'**
  String quotePreview(Object percent, Object symbol);

  /// No description provided for @unknownSymbol.
  ///
  /// In en, this message translates to:
  /// **'Unknown symbol {symbol}'**
  String unknownSymbol(Object symbol);

  /// No description provided for @quantityMustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Quantity must be greater than zero'**
  String get quantityMustBeGreaterThanZero;

  /// No description provided for @quantityMaxDecimals.
  ///
  /// In en, this message translates to:
  /// **'Quantity supports up to 4 decimal places'**
  String get quantityMaxDecimals;

  /// No description provided for @livePriceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Live price unavailable. Please try again.'**
  String get livePriceUnavailable;

  /// No description provided for @insufficientBalance.
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance. Available {available} but order needs {needed}'**
  String insufficientBalance(Object available, Object needed);

  /// No description provided for @insufficientQuantity.
  ///
  /// In en, this message translates to:
  /// **'Insufficient quantity. You hold {quantity} shares of {symbol}'**
  String insufficientQuantity(Object quantity, Object symbol);

  /// No description provided for @localStorageNotInitialized.
  ///
  /// In en, this message translates to:
  /// **'Local storage is not initialized. Call LocalStorage.init().'**
  String get localStorageNotInitialized;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String seconds(Object seconds);

  /// No description provided for @milliseconds.
  ///
  /// In en, this message translates to:
  /// **'{milliseconds}ms'**
  String milliseconds(Object milliseconds);

  /// No description provided for @executedOrder.
  ///
  /// In en, this message translates to:
  /// **'{count} EXECUTED ORDER'**
  String executedOrder(Object count);

  /// No description provided for @executedOrders.
  ///
  /// In en, this message translates to:
  /// **'{count} EXECUTED ORDERS'**
  String executedOrders(Object count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
