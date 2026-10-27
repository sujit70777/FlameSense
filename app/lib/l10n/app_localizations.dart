import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('bn'),
    Locale('en'),
  ];

  /// Product name
  ///
  /// In en, this message translates to:
  /// **'FlameSense'**
  String get appName;

  /// Tagline §2.1
  ///
  /// In en, this message translates to:
  /// **'See how fire behaves where \"up\" doesn\'t exist.'**
  String get tagline;

  /// Nav
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Nav
  ///
  /// In en, this message translates to:
  /// **'Missions'**
  String get navMissions;

  /// Nav
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get navExplore;

  /// Nav
  ///
  /// In en, this message translates to:
  /// **'Fire Lab'**
  String get navLab;

  /// Nav
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// Nav
  ///
  /// In en, this message translates to:
  /// **'Ask'**
  String get navAsk;

  /// Nav
  ///
  /// In en, this message translates to:
  /// **'Earth lessons'**
  String get navEarth;

  /// Nav
  ///
  /// In en, this message translates to:
  /// **'Methods'**
  String get navMethods;

  /// Nav
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get navAbout;

  /// Nav
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// Top bar button
  ///
  /// In en, this message translates to:
  /// **'Take the tour'**
  String get takeTour;

  /// Theme
  ///
  /// In en, this message translates to:
  /// **'Use system theme'**
  String get themeSystem;

  /// Theme
  ///
  /// In en, this message translates to:
  /// **'Light theme'**
  String get themeLight;

  /// Theme
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get themeDark;

  /// Theme toggle tooltip
  ///
  /// In en, this message translates to:
  /// **'Switch to {mode}'**
  String themeSwitchTo(String mode);

  /// Language toggle
  ///
  /// In en, this message translates to:
  /// **'EN'**
  String get langEnglish;

  /// Language toggle
  ///
  /// In en, this message translates to:
  /// **'বাং'**
  String get langBangla;

  /// Language menu label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get langLabel;

  /// Compact top bar menu tooltip
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get menuOptions;

  /// Disclaimer §12
  ///
  /// In en, this message translates to:
  /// **'FlameSense is a research and education tool. It is not a certified fire-safety system and must not be used for operational safety decisions.'**
  String get disclaimer;

  /// Footer
  ///
  /// In en, this message translates to:
  /// **'Not affiliated with or endorsed by NASA. Uses NASA open data.'**
  String get notAffiliated;

  /// Footer
  ///
  /// In en, this message translates to:
  /// **'Data: NASA open data. Code: Apache-2.0. Built for NASA Space Apps Challenge 2026, Rajshahi.'**
  String get credits;

  /// Loading
  ///
  /// In en, this message translates to:
  /// **'Loading NASA experiment data'**
  String get loadingData;

  /// Global error
  ///
  /// In en, this message translates to:
  /// **'FlameSense couldn\'t load its data'**
  String get loadErrorTitle;

  /// Global error
  ///
  /// In en, this message translates to:
  /// **'The file {file} is missing or damaged. Reload the page. If this keeps happening, the deployment is incomplete.'**
  String loadErrorBody(String file);

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// Tooltip
  ///
  /// In en, this message translates to:
  /// **'Exit tour'**
  String get exitTour;

  /// Toast
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get linkCopied;

  /// Toast
  ///
  /// In en, this message translates to:
  /// **'CSV downloaded'**
  String get csvDownloaded;

  /// Toast
  ///
  /// In en, this message translates to:
  /// **'Answer copied'**
  String get answerCopied;

  /// Browser tab title
  ///
  /// In en, this message translates to:
  /// **'{page} | FlameSense'**
  String pageTitle(String page);

  /// Home document title §15
  ///
  /// In en, this message translates to:
  /// **'FlameSense: fire safety insights from NASA\'s space-station fire experiments'**
  String get homePageTitle;

  /// Boolean
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get valueYes;

  /// Boolean
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get valueNo;

  /// Missing value
  ///
  /// In en, this message translates to:
  /// **'—'**
  String get notAvailable;

  /// Link semantics
  ///
  /// In en, this message translates to:
  /// **'Opens in a new tab'**
  String get openInNewTab;

  /// Toast action
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// Info button tooltip
  ///
  /// In en, this message translates to:
  /// **'More information'**
  String get info;

  /// Gravity label
  ///
  /// In en, this message translates to:
  /// **'Earth'**
  String get gEarth;

  /// Gravity label
  ///
  /// In en, this message translates to:
  /// **'Mars'**
  String get gMars;

  /// Gravity label
  ///
  /// In en, this message translates to:
  /// **'Moon'**
  String get gMoon;

  /// Gravity label
  ///
  /// In en, this message translates to:
  /// **'ISS orbit'**
  String get gIss;

  /// Gravity label
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get gCustom;

  /// Gravity chip
  ///
  /// In en, this message translates to:
  /// **'{label} ({value} g)'**
  String gravityValue(String label, String value);

  /// Gravity class
  ///
  /// In en, this message translates to:
  /// **'Microgravity'**
  String get gravityClassMicro;

  /// Gravity class
  ///
  /// In en, this message translates to:
  /// **'Moon or Mars'**
  String get gravityClassPartial;

  /// Gravity class
  ///
  /// In en, this message translates to:
  /// **'Earth'**
  String get gravityClassEarth;

  /// Unit
  ///
  /// In en, this message translates to:
  /// **'mm/s'**
  String get unitMmS;

  /// Unit
  ///
  /// In en, this message translates to:
  /// **'kPa'**
  String get unitKpa;

  /// Unit
  ///
  /// In en, this message translates to:
  /// **'%'**
  String get unitPercent;

  /// Unit
  ///
  /// In en, this message translates to:
  /// **'mm'**
  String get unitMm;

  /// Unit
  ///
  /// In en, this message translates to:
  /// **'kg/m³'**
  String get unitKgM3;

  /// Unit
  ///
  /// In en, this message translates to:
  /// **'kg/m²'**
  String get unitKgM2;

  /// Unit
  ///
  /// In en, this message translates to:
  /// **'mm²/s'**
  String get unitMm2S;

  /// Unit
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get unitG;

  /// Unit
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get unitSeconds;

  /// Feature
  ///
  /// In en, this message translates to:
  /// **'Oxygen'**
  String get featO2;

  /// Feature
  ///
  /// In en, this message translates to:
  /// **'Pressure'**
  String get featPressure;

  /// Feature
  ///
  /// In en, this message translates to:
  /// **'Airflow'**
  String get featFlow;

  /// Feature
  ///
  /// In en, this message translates to:
  /// **'Gravity'**
  String get featGravity;

  /// Feature
  ///
  /// In en, this message translates to:
  /// **'Thickness'**
  String get featThickness;

  /// Feature
  ///
  /// In en, this message translates to:
  /// **'Density'**
  String get featDensity;

  /// Feature
  ///
  /// In en, this message translates to:
  /// **'Material type'**
  String get featFuelClass;

  /// Feature
  ///
  /// In en, this message translates to:
  /// **'Airflow direction'**
  String get featFlowDir;

  /// Feature
  ///
  /// In en, this message translates to:
  /// **'Diluent gas'**
  String get featDiluent;

  /// Derived feature
  ///
  /// In en, this message translates to:
  /// **'Oxygen partial pressure'**
  String get featO2Partial;

  /// Derived feature
  ///
  /// In en, this message translates to:
  /// **'Airflow (log scale)'**
  String get featLogFlow;

  /// Derived feature
  ///
  /// In en, this message translates to:
  /// **'Gravity (log scale)'**
  String get featLogGravity;

  /// Derived feature
  ///
  /// In en, this message translates to:
  /// **'Areal density'**
  String get featArealDensity;

  /// Fuel class
  ///
  /// In en, this message translates to:
  /// **'Thin solid'**
  String get fuelThinSolid;

  /// Fuel class
  ///
  /// In en, this message translates to:
  /// **'Thick solid'**
  String get fuelThickSolid;

  /// Fuel class
  ///
  /// In en, this message translates to:
  /// **'Fuel droplet'**
  String get fuelDroplet;

  /// Fuel class
  ///
  /// In en, this message translates to:
  /// **'Gas jet'**
  String get fuelGasJet;

  /// Fuel class
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get fuelOther;

  /// Flow direction
  ///
  /// In en, this message translates to:
  /// **'Opposed'**
  String get dirOpposed;

  /// Flow direction
  ///
  /// In en, this message translates to:
  /// **'Concurrent'**
  String get dirConcurrent;

  /// Flow direction
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get dirQuiescent;

  /// Flow direction
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get dirOther;

  /// Diluent
  ///
  /// In en, this message translates to:
  /// **'Nitrogen'**
  String get diluentN2;

  /// Diluent
  ///
  /// In en, this message translates to:
  /// **'Helium'**
  String get diluentHe;

  /// Diluent
  ///
  /// In en, this message translates to:
  /// **'Carbon dioxide'**
  String get diluentCo2;

  /// Diluent
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get diluentOther;

  /// Platform
  ///
  /// In en, this message translates to:
  /// **'ISS'**
  String get platformIss;

  /// Platform
  ///
  /// In en, this message translates to:
  /// **'Free flyer'**
  String get platformFreeFlyer;

  /// Platform
  ///
  /// In en, this message translates to:
  /// **'Drop tower'**
  String get platformDropTower;

  /// Platform
  ///
  /// In en, this message translates to:
  /// **'Parabolic flight'**
  String get platformParabolic;

  /// Platform
  ///
  /// In en, this message translates to:
  /// **'Ground'**
  String get platformGround;

  /// Quality flag
  ///
  /// In en, this message translates to:
  /// **'Measured'**
  String get qualityOk;

  /// Quality flag
  ///
  /// In en, this message translates to:
  /// **'Estimated'**
  String get qualityEstimated;

  /// Quality flag
  ///
  /// In en, this message translates to:
  /// **'Digitized'**
  String get qualityDigitized;

  /// Quality flag
  ///
  /// In en, this message translates to:
  /// **'Video-derived'**
  String get qualityVideoDerived;

  /// Quality flag
  ///
  /// In en, this message translates to:
  /// **'Flagged'**
  String get qualitySuspect;

  /// Badge
  ///
  /// In en, this message translates to:
  /// **'Data support: high'**
  String get supportHigh;

  /// Badge
  ///
  /// In en, this message translates to:
  /// **'Data support: medium'**
  String get supportMedium;

  /// Badge
  ///
  /// In en, this message translates to:
  /// **'Data support: low'**
  String get supportLow;

  /// Badge tooltip
  ///
  /// In en, this message translates to:
  /// **'Many NASA test runs were done near these conditions.'**
  String get supportHighTip;

  /// Badge tooltip
  ///
  /// In en, this message translates to:
  /// **'Some NASA test runs are near these conditions. Treat the prediction as approximate.'**
  String get supportMediumTip;

  /// Badge tooltip
  ///
  /// In en, this message translates to:
  /// **'Few or no NASA test runs are near these conditions. This is an extrapolation.'**
  String get supportLowTip;

  /// Compact badge
  ///
  /// In en, this message translates to:
  /// **'high'**
  String get supportShortHigh;

  /// Compact badge
  ///
  /// In en, this message translates to:
  /// **'med'**
  String get supportShortMedium;

  /// Compact badge
  ///
  /// In en, this message translates to:
  /// **'low'**
  String get supportShortLow;

  /// Ask error
  ///
  /// In en, this message translates to:
  /// **'Too many questions in a short time. Try again in {minutes} min.'**
  String askErrRate(String minutes);

  /// Ask error
  ///
  /// In en, this message translates to:
  /// **'The answer service didn\'t respond. Try again, or pick a suggested question; those answers are saved.'**
  String get askErrUpstream;

  /// Ask error
  ///
  /// In en, this message translates to:
  /// **'You\'re offline. Suggested questions still work.'**
  String get askErrOffline;

  /// Ask error
  ///
  /// In en, this message translates to:
  /// **'Write a question between 3 and 500 characters.'**
  String get askErrInvalid;

  /// Ask error
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on the server. Try again in a minute.'**
  String get askErrServer;

  /// Numeric field error
  ///
  /// In en, this message translates to:
  /// **'Enter a number between {min} and {max}.'**
  String numErrRange(String min, String max);

  /// Lab notice
  ///
  /// In en, this message translates to:
  /// **'{feature} is outside the range NASA tested ({min}–{max} {unit}). The prediction is an extrapolation.'**
  String noticeOutside(String feature, String min, String max, String unit);

  /// Lab notice
  ///
  /// In en, this message translates to:
  /// **'Few NASA test runs are near these conditions. Use this as a rough estimate.'**
  String get noticeLowSupport;

  /// Lab notice
  ///
  /// In en, this message translates to:
  /// **'NASA has little or no fire data at Moon or Mars gravity. Predictions here are extrapolations between Earth and orbit. This is a real research gap.'**
  String get noticePartialG;

  /// Lab notice
  ///
  /// In en, this message translates to:
  /// **'There isn\'t enough NASA data to predict {output} reliably, so FlameSense doesn\'t show one.'**
  String noticeUnavailable(String output);

  /// Explore notice
  ///
  /// In en, this message translates to:
  /// **'All runs come from one experiment, so comparisons across experiments aren\'t possible yet.'**
  String get noticeOneExperiment;

  /// Debug-only notice
  ///
  /// In en, this message translates to:
  /// **'The three spread-rate models crossed, so their values were put back in order.'**
  String get noticeQuantiles;

  /// Output name for noticeUnavailable
  ///
  /// In en, this message translates to:
  /// **'the chance a flame keeps burning'**
  String get outputSustain;

  /// Output name
  ///
  /// In en, this message translates to:
  /// **'the flame spread rate'**
  String get outputSpread;

  /// Map notice
  ///
  /// In en, this message translates to:
  /// **'No NASA fire tests at {body} gravity are in this dataset ({n} runs). The colors here are extrapolated, which is why most of the map is hatched. Filling this gap matters for Artemis and future Mars missions.'**
  String mapGapNotice(String body, String n);

  /// Physics card
  ///
  /// In en, this message translates to:
  /// **'The physics check covers thin materials in opposing airflow. These conditions are outside it.'**
  String get physicsNotApplicable;

  /// Physics card
  ///
  /// In en, this message translates to:
  /// **'Near extinction the simple theory over-predicts spread. Trust the data-driven prediction more here.'**
  String get physicsNearExt;

  /// Physics card
  ///
  /// In en, this message translates to:
  /// **'The physics check is switched off until its parameters are verified.'**
  String get physicsUnavailable;

  /// Home
  ///
  /// In en, this message translates to:
  /// **'Fire has no \"up\" in space.'**
  String get homeHeadline;

  /// Home
  ///
  /// In en, this message translates to:
  /// **'On Earth, rising hot air stretches a flame into a teardrop. On the space station nothing rises, so flames turn round, blue and slow. FlameSense turns NASA\'s space-station fire experiments into predictions you can explore.'**
  String get homeSubhead;

  /// Home CTA
  ///
  /// In en, this message translates to:
  /// **'Open the Fire Lab'**
  String get homeCtaLab;

  /// Home
  ///
  /// In en, this message translates to:
  /// **'Built on {runs} test runs from {experiments} NASA experiments across {fuels} materials.'**
  String homeDataSentence(String runs, String experiments, String fuels);

  /// Home, when the dataset is empty (TODO(Q-5))
  ///
  /// In en, this message translates to:
  /// **'NASA test runs are being added to the dataset. Predictions appear once enough runs are in.'**
  String get homeDataPending;

  /// Chamber label
  ///
  /// In en, this message translates to:
  /// **'Earth'**
  String get homeEarthFlame;

  /// Chamber label
  ///
  /// In en, this message translates to:
  /// **'Your gravity'**
  String get homeYourGravity;

  /// Readout
  ///
  /// In en, this message translates to:
  /// **'Buoyant airflow'**
  String get homeBuoyantFlow;

  /// Readout
  ///
  /// In en, this message translates to:
  /// **'Predicted spread'**
  String get homePredictedSpread;

  /// Home
  ///
  /// In en, this message translates to:
  /// **'Where to go next'**
  String get homeNextTitle;

  /// Home row
  ///
  /// In en, this message translates to:
  /// **'Plan for a mission'**
  String get homeNextMissions;

  /// Home row
  ///
  /// In en, this message translates to:
  /// **'Which materials could burn in a Moon habitat'**
  String get homeNextMissionsDesc;

  /// Home row
  ///
  /// In en, this message translates to:
  /// **'Explore the experiments'**
  String get homeNextExplore;

  /// Home row
  ///
  /// In en, this message translates to:
  /// **'Every run, filterable, with its NASA source'**
  String get homeNextExploreDesc;

  /// Home row
  ///
  /// In en, this message translates to:
  /// **'See the flammability map'**
  String get homeNextMap;

  /// Home row
  ///
  /// In en, this message translates to:
  /// **'Where flames survive, by oxygen and airflow'**
  String get homeNextMapDesc;

  /// Home row
  ///
  /// In en, this message translates to:
  /// **'Ask the NASA papers'**
  String get homeNextAsk;

  /// Home row
  ///
  /// In en, this message translates to:
  /// **'Answers with citations'**
  String get homeNextAskDesc;

  /// Home row
  ///
  /// In en, this message translates to:
  /// **'Lessons for Earth'**
  String get homeNextEarth;

  /// Home row
  ///
  /// In en, this message translates to:
  /// **'What space fires teach us about safety here'**
  String get homeNextEarthDesc;

  /// Flame a11y
  ///
  /// In en, this message translates to:
  /// **'Flame at {label}. {shape}'**
  String flameSemantics(String label, String shape);

  /// Flame a11y
  ///
  /// In en, this message translates to:
  /// **'An orange teardrop stretched upward by rising hot air.'**
  String get flameShapeEarth;

  /// Flame a11y
  ///
  /// In en, this message translates to:
  /// **'A dim blue sphere: nothing rises without gravity.'**
  String get flameShapeSpace;

  /// Flame a11y
  ///
  /// In en, this message translates to:
  /// **'Rounder and bluer than on Earth, with weaker buoyancy.'**
  String get flameShapeMid;

  /// Explore
  ///
  /// In en, this message translates to:
  /// **'Explore the experiments'**
  String get exploreTitle;

  /// Explore
  ///
  /// In en, this message translates to:
  /// **'Every NASA test run FlameSense uses, in one table. Each row links to its source.'**
  String get exploreDesc;

  /// Filter
  ///
  /// In en, this message translates to:
  /// **'Experiment'**
  String get filterExperiment;

  /// Filter
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get filterPlatform;

  /// Filter
  ///
  /// In en, this message translates to:
  /// **'Material type'**
  String get filterFuelClass;

  /// Filter
  ///
  /// In en, this message translates to:
  /// **'Gravity'**
  String get filterGravity;

  /// Filter
  ///
  /// In en, this message translates to:
  /// **'Oxygen range'**
  String get filterO2;

  /// Filter
  ///
  /// In en, this message translates to:
  /// **'Pressure range'**
  String get filterPressure;

  /// Filter
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get filterQuality;

  /// Filter
  ///
  /// In en, this message translates to:
  /// **'Include estimated'**
  String get qualityIncEstimated;

  /// Filter
  ///
  /// In en, this message translates to:
  /// **'Include digitized'**
  String get qualityIncDigitized;

  /// Filter
  ///
  /// In en, this message translates to:
  /// **'Include video-derived'**
  String get qualityIncVideo;

  /// Filter
  ///
  /// In en, this message translates to:
  /// **'Include flagged'**
  String get qualityIncFlagged;

  /// Filter
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Compact filter button
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersButton;

  /// Range dialog
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get filterApply;

  /// Range chip
  ///
  /// In en, this message translates to:
  /// **'{min}–{max} {unit}'**
  String filterRangeValue(String min, String max, String unit);

  /// Explore count
  ///
  /// In en, this message translates to:
  /// **'Showing {shown} of {total} runs'**
  String exploreShowing(String shown, String total);

  /// Explore
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get exploreClear;

  /// Explore
  ///
  /// In en, this message translates to:
  /// **'Download CSV'**
  String get exploreDownload;

  /// Chart tab
  ///
  /// In en, this message translates to:
  /// **'Spread vs oxygen'**
  String get exploreTabSpread;

  /// Chart tab
  ///
  /// In en, this message translates to:
  /// **'Burning vs airflow'**
  String get exploreTabBurning;

  /// Chart tab
  ///
  /// In en, this message translates to:
  /// **'Runs per experiment'**
  String get exploreTabRuns;

  /// Empty
  ///
  /// In en, this message translates to:
  /// **'No runs match these filters'**
  String get exploreEmptyTitle;

  /// Empty
  ///
  /// In en, this message translates to:
  /// **'Widen the oxygen or pressure range, or include more experiments.'**
  String get exploreEmptyBody;

  /// Empty dataset (TODO(Q-5))
  ///
  /// In en, this message translates to:
  /// **'No NASA runs loaded yet'**
  String get exploreNoDataTitle;

  /// Empty dataset
  ///
  /// In en, this message translates to:
  /// **'Runs appear here once their NASA source files are added to the dataset.'**
  String get exploreNoDataBody;

  /// Empty chart
  ///
  /// In en, this message translates to:
  /// **'No runs with these values to plot.'**
  String get chartNoPoints;

  /// Table
  ///
  /// In en, this message translates to:
  /// **'Run'**
  String get colRun;

  /// Table
  ///
  /// In en, this message translates to:
  /// **'Experiment'**
  String get colExperiment;

  /// Table
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get colFuel;

  /// Table
  ///
  /// In en, this message translates to:
  /// **'O₂ (%)'**
  String get colO2;

  /// Table
  ///
  /// In en, this message translates to:
  /// **'Pressure (kPa)'**
  String get colPressure;

  /// Table
  ///
  /// In en, this message translates to:
  /// **'Airflow (mm/s)'**
  String get colFlow;

  /// Table
  ///
  /// In en, this message translates to:
  /// **'Gravity (g)'**
  String get colGravity;

  /// Table
  ///
  /// In en, this message translates to:
  /// **'Outcome'**
  String get colOutcome;

  /// Table
  ///
  /// In en, this message translates to:
  /// **'Spread (mm/s)'**
  String get colSpread;

  /// Table
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get colQuality;

  /// Table header semantics
  ///
  /// In en, this message translates to:
  /// **'Sort by {column}'**
  String sortBy(String column);

  /// Chart axis
  ///
  /// In en, this message translates to:
  /// **'Oxygen (%)'**
  String get axisO2;

  /// Chart axis
  ///
  /// In en, this message translates to:
  /// **'Spread rate (mm/s, log scale)'**
  String get axisSpread;

  /// Chart axis
  ///
  /// In en, this message translates to:
  /// **'Airflow (mm/s, log scale)'**
  String get axisFlow;

  /// Chart axis
  ///
  /// In en, this message translates to:
  /// **'Runs'**
  String get axisRuns;

  /// Chart semantics
  ///
  /// In en, this message translates to:
  /// **'Scatter of {n} runs: flame spread rate against oxygen, colored by gravity class.'**
  String chartSpreadSummary(String n);

  /// Chart semantics
  ///
  /// In en, this message translates to:
  /// **'Strip chart of {n} runs against airflow: {kept} kept burning, {out} went out.'**
  String chartBurningSummary(String n, String kept, String out);

  /// Chart semantics
  ///
  /// In en, this message translates to:
  /// **'Bar chart of {n} runs across {experiments} experiments.'**
  String chartRunsSummary(String n, String experiments);

  /// Run detail
  ///
  /// In en, this message translates to:
  /// **'Run {id}'**
  String runTitle(String id);

  /// Outcome
  ///
  /// In en, this message translates to:
  /// **'Kept burning'**
  String get runKeptBurning;

  /// Outcome
  ///
  /// In en, this message translates to:
  /// **'Went out'**
  String get runWentOut;

  /// Outcome
  ///
  /// In en, this message translates to:
  /// **'Did not ignite'**
  String get runNoIgnition;

  /// Outcome
  ///
  /// In en, this message translates to:
  /// **'Outcome not recorded'**
  String get runUnknownOutcome;

  /// Run detail
  ///
  /// In en, this message translates to:
  /// **'Open source'**
  String get runOpenSource;

  /// Run detail
  ///
  /// In en, this message translates to:
  /// **'Load these conditions in the Fire Lab'**
  String get runLoadLab;

  /// Run detail
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get runSource;

  /// Field
  ///
  /// In en, this message translates to:
  /// **'Test series'**
  String get fieldGroup;

  /// Field
  ///
  /// In en, this message translates to:
  /// **'Experiment'**
  String get fieldExperiment;

  /// Field
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get fieldPlatform;

  /// Field
  ///
  /// In en, this message translates to:
  /// **'Gravity'**
  String get fieldGravity;

  /// Field
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get fieldFuelName;

  /// Field
  ///
  /// In en, this message translates to:
  /// **'Material type'**
  String get fieldFuelClass;

  /// Field
  ///
  /// In en, this message translates to:
  /// **'Thickness'**
  String get fieldThickness;

  /// Field
  ///
  /// In en, this message translates to:
  /// **'Density'**
  String get fieldDensity;

  /// Field
  ///
  /// In en, this message translates to:
  /// **'Oxygen'**
  String get fieldO2;

  /// Field
  ///
  /// In en, this message translates to:
  /// **'Pressure'**
  String get fieldPressure;

  /// Field
  ///
  /// In en, this message translates to:
  /// **'Diluent gas'**
  String get fieldDiluent;

  /// Field
  ///
  /// In en, this message translates to:
  /// **'Airflow'**
  String get fieldFlow;

  /// Field
  ///
  /// In en, this message translates to:
  /// **'Airflow direction'**
  String get fieldFlowDir;

  /// Field
  ///
  /// In en, this message translates to:
  /// **'Ignited'**
  String get fieldIgnited;

  /// Field
  ///
  /// In en, this message translates to:
  /// **'Kept burning'**
  String get fieldSustained;

  /// Field
  ///
  /// In en, this message translates to:
  /// **'Flame spread rate'**
  String get fieldSpread;

  /// Field
  ///
  /// In en, this message translates to:
  /// **'Burning-rate constant'**
  String get fieldBurningRate;

  /// Field
  ///
  /// In en, this message translates to:
  /// **'Extinction reason'**
  String get fieldExtinction;

  /// Field
  ///
  /// In en, this message translates to:
  /// **'Source file'**
  String get fieldSourceFile;

  /// Field
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get fieldQuality;

  /// Field
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get fieldNotes;

  /// Lab
  ///
  /// In en, this message translates to:
  /// **'Fire Lab'**
  String get labTitle;

  /// Lab
  ///
  /// In en, this message translates to:
  /// **'Set the conditions of a fire test and see what NASA\'s data predicts.'**
  String get labDesc;

  /// Panel
  ///
  /// In en, this message translates to:
  /// **'Conditions'**
  String get labConditions;

  /// Panel
  ///
  /// In en, this message translates to:
  /// **'Prediction'**
  String get labPrediction;

  /// Dropdown
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get labMaterial;

  /// Dropdown
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get labMaterialCustom;

  /// Dropdown
  ///
  /// In en, this message translates to:
  /// **'{fuelClass}, {thickness} mm'**
  String labMaterialSummary(String fuelClass, String thickness);

  /// Slider marker
  ///
  /// In en, this message translates to:
  /// **'Sea level 101.3 kPa'**
  String get labMarkerSeaLevel;

  /// Slider marker
  ///
  /// In en, this message translates to:
  /// **'Earth air 21%'**
  String get labMarkerEarthAir;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Reset to defaults'**
  String get labReset;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Copy link to this setup'**
  String get labCopyLink;

  /// Toggle
  ///
  /// In en, this message translates to:
  /// **'Compare with Earth'**
  String get labCompare;

  /// Gauge
  ///
  /// In en, this message translates to:
  /// **'chance the flame keeps burning'**
  String get labGaugeCaption;

  /// Gauge end
  ///
  /// In en, this message translates to:
  /// **'Goes out'**
  String get labGoesOut;

  /// Gauge end
  ///
  /// In en, this message translates to:
  /// **'Keeps burning'**
  String get labKeepsBurning;

  /// Gauge
  ///
  /// In en, this message translates to:
  /// **'Not enough data to predict this'**
  String get labGaugeUnavailable;

  /// Gauge a11y
  ///
  /// In en, this message translates to:
  /// **'Chance the flame keeps burning: {pct} percent.'**
  String labGaugeSemantics(String pct);

  /// Readout label
  ///
  /// In en, this message translates to:
  /// **'Chance it keeps burning'**
  String get labChanceLabel;

  /// Spread band
  ///
  /// In en, this message translates to:
  /// **'Flame spread rate'**
  String get labSpreadTitle;

  /// Spread
  ///
  /// In en, this message translates to:
  /// **'80% range: {low} to {high} mm/s'**
  String labRange80(String low, String high);

  /// Spread a11y
  ///
  /// In en, this message translates to:
  /// **'Flame spread rate {mid} millimetres per second, 80% range {low} to {high}.'**
  String labSpreadSemantics(String mid, String low, String high);

  /// Readout
  ///
  /// In en, this message translates to:
  /// **'Effective airflow'**
  String get labEffectiveFlow;

  /// Readout
  ///
  /// In en, this message translates to:
  /// **'(forced {forced} + buoyant {buoyant})'**
  String labEffectiveFlowCaption(String forced, String buoyant);

  /// Readout
  ///
  /// In en, this message translates to:
  /// **'(forced airflow only; the buoyant part needs the physics check)'**
  String get labEffectiveFlowForcedOnly;

  /// Sensitivity
  ///
  /// In en, this message translates to:
  /// **'What moves the risk'**
  String get labSensTitle;

  /// Sensitivity
  ///
  /// In en, this message translates to:
  /// **'Each row nudges one setting by 10% of its range and keeps the rest fixed.'**
  String get labSensCaption;

  /// Sensitivity row
  ///
  /// In en, this message translates to:
  /// **'Raising {feature} by {delta}: {change}'**
  String labSensRow(String feature, String delta, String change);

  /// Sensitivity change
  ///
  /// In en, this message translates to:
  /// **'{value} points'**
  String labSensPoints(String value);

  /// Sensitivity change
  ///
  /// In en, this message translates to:
  /// **'{value} mm/s'**
  String labSensMmS(String value);

  /// Sensitivity
  ///
  /// In en, this message translates to:
  /// **'Sensitivity appears once a prediction is available.'**
  String get labSensEmpty;

  /// Physics card
  ///
  /// In en, this message translates to:
  /// **'Physics check'**
  String get labPhysicsTitle;

  /// Physics
  ///
  /// In en, this message translates to:
  /// **'Thin-fuel theory predicts'**
  String get labPhysicsPredicts;

  /// Physics
  ///
  /// In en, this message translates to:
  /// **'ML prediction is {pct}% lower, as expected near extinction, where the simple theory over-predicts.'**
  String labPhysicsLower(String pct);

  /// Physics
  ///
  /// In en, this message translates to:
  /// **'ML prediction is {pct}% higher than the simple theory.'**
  String labPhysicsHigher(String pct);

  /// Physics
  ///
  /// In en, this message translates to:
  /// **'See the equation'**
  String get labPhysicsSeeEquation;

  /// Compare
  ///
  /// In en, this message translates to:
  /// **'At your gravity'**
  String get labCompareYourG;

  /// Compare
  ///
  /// In en, this message translates to:
  /// **'On Earth (1 g)'**
  String get labCompareEarth;

  /// Compare
  ///
  /// In en, this message translates to:
  /// **'{n} points more likely to keep burning on Earth'**
  String labDeltaMore(String n);

  /// Compare
  ///
  /// In en, this message translates to:
  /// **'{n} points less likely to keep burning on Earth'**
  String labDeltaLess(String n);

  /// Compare
  ///
  /// In en, this message translates to:
  /// **'Equally likely to keep burning on Earth'**
  String get labDeltaSame;

  /// Compare
  ///
  /// In en, this message translates to:
  /// **'×{ratio} faster on Earth'**
  String labDeltaFaster(String ratio);

  /// Compare (TODO(Q-5))
  ///
  /// In en, this message translates to:
  /// **'×{ratio} slower on Earth'**
  String labDeltaSlower(String ratio);

  /// Compact sticky bar
  ///
  /// In en, this message translates to:
  /// **'{pct}% keeps burning, {spread} mm/s'**
  String labSticky(String pct, String spread);

  /// Compact sticky bar
  ///
  /// In en, this message translates to:
  /// **'{pct}% keeps burning'**
  String labStickyNoSpread(String pct);

  /// Slider a11y value
  ///
  /// In en, this message translates to:
  /// **'{value} {unit}'**
  String sliderSemantics(String value, String unit);

  /// Slider a11y value
  ///
  /// In en, this message translates to:
  /// **'{value} percent'**
  String sliderPercentSemantics(String value);

  /// Number field a11y
  ///
  /// In en, this message translates to:
  /// **'{feature} value'**
  String numberFieldLabel(String feature);

  /// Map
  ///
  /// In en, this message translates to:
  /// **'Flammability map'**
  String get mapTitle;

  /// Map
  ///
  /// In en, this message translates to:
  /// **'How likely a flame is to keep burning across oxygen levels and airflow speeds.'**
  String get mapDesc;

  /// Legend
  ///
  /// In en, this message translates to:
  /// **'Likely to go out'**
  String get mapLegendLow;

  /// Legend
  ///
  /// In en, this message translates to:
  /// **'Likely to keep burning'**
  String get mapLegendHigh;

  /// Legend
  ///
  /// In en, this message translates to:
  /// **'Little or no NASA data here'**
  String get mapHatch;

  /// Inspector
  ///
  /// In en, this message translates to:
  /// **'Open in Fire Lab'**
  String get mapOpenLab;

  /// Controls
  ///
  /// In en, this message translates to:
  /// **'Overlays'**
  String get mapOverlays;

  /// Overlay chip
  ///
  /// In en, this message translates to:
  /// **'NASA runs'**
  String get mapOverlayRuns;

  /// Overlay chip
  ///
  /// In en, this message translates to:
  /// **'50% line'**
  String get mapOverlayContour;

  /// Contour label
  ///
  /// In en, this message translates to:
  /// **'50%'**
  String get mapContourLabel;

  /// Inspector
  ///
  /// In en, this message translates to:
  /// **'Hover a cell'**
  String get mapInspectorHint;

  /// Inspector
  ///
  /// In en, this message translates to:
  /// **'Tap a cell'**
  String get mapInspectorTapHint;

  /// Inspector
  ///
  /// In en, this message translates to:
  /// **'{pct}% keeps burning'**
  String mapCellProb(String pct);

  /// Inspector
  ///
  /// In en, this message translates to:
  /// **'Pinned'**
  String get mapPinned;

  /// Legend
  ///
  /// In en, this message translates to:
  /// **'kept burning'**
  String get mapKeptBurning;

  /// Legend
  ///
  /// In en, this message translates to:
  /// **'went out'**
  String get mapWentOut;

  /// Compact sheet
  ///
  /// In en, this message translates to:
  /// **'Map settings'**
  String get mapSettings;

  /// Control
  ///
  /// In en, this message translates to:
  /// **'Pressure {value} kPa'**
  String mapPressureValue(String value);

  /// Control
  ///
  /// In en, this message translates to:
  /// **'Gravity: {label}'**
  String mapGravityValue(String label);

  /// Empty
  ///
  /// In en, this message translates to:
  /// **'Not enough data to draw the map'**
  String get mapEmptyTitle;

  /// Empty
  ///
  /// In en, this message translates to:
  /// **'FlameSense needs at least 40 NASA runs with a known outcome. You can still see every run that exists.'**
  String get mapEmptyBody;

  /// Empty
  ///
  /// In en, this message translates to:
  /// **'Show the runs in Explore'**
  String get mapEmptyCta;

  /// Map a11y
  ///
  /// In en, this message translates to:
  /// **'Heatmap of the chance a flame keeps burning, oxygen {o2min} to {o2max} percent against airflow {fmin} to {fmax} mm/s. {low} of {total} cells have little NASA data.'**
  String mapSemantics(
    String o2min,
    String o2max,
    String fmin,
    String fmax,
    String low,
    String total,
  );

  /// Ask
  ///
  /// In en, this message translates to:
  /// **'Ask the NASA papers'**
  String get askTitle;

  /// Ask
  ///
  /// In en, this message translates to:
  /// **'Answers come only from the NASA documents FlameSense has read. Every sentence cites its source.'**
  String get askDesc;

  /// Ask
  ///
  /// In en, this message translates to:
  /// **'Suggested questions'**
  String get askSuggested;

  /// Q
  ///
  /// In en, this message translates to:
  /// **'Why are flames round in microgravity?'**
  String get askQ1;

  /// Q
  ///
  /// In en, this message translates to:
  /// **'Can a material burn in space but not on Earth?'**
  String get askQ2;

  /// Q
  ///
  /// In en, this message translates to:
  /// **'What did NASA\'s Saffire experiments test?'**
  String get askQ3;

  /// Q
  ///
  /// In en, this message translates to:
  /// **'How does airflow affect flame spread in microgravity?'**
  String get askQ4;

  /// Q
  ///
  /// In en, this message translates to:
  /// **'Why are flames in space blue?'**
  String get askQ5;

  /// Q
  ///
  /// In en, this message translates to:
  /// **'How is spacecraft material flammability tested?'**
  String get askQ6;

  /// Ask
  ///
  /// In en, this message translates to:
  /// **'Ask about fire in microgravity'**
  String get askPlaceholder;

  /// Ask a11y
  ///
  /// In en, this message translates to:
  /// **'Your question'**
  String get askInputLabel;

  /// Ask
  ///
  /// In en, this message translates to:
  /// **'Ask'**
  String get askButton;

  /// Ask
  ///
  /// In en, this message translates to:
  /// **'{n} / 500'**
  String askCounter(String n);

  /// Ask status
  ///
  /// In en, this message translates to:
  /// **'Answered from NASA sources'**
  String get askGrounded;

  /// Ask status
  ///
  /// In en, this message translates to:
  /// **'Not found in FlameSense\'s NASA sources'**
  String get askNotGrounded;

  /// Ask tag
  ///
  /// In en, this message translates to:
  /// **'Saved answer'**
  String get askSaved;

  /// Ask
  ///
  /// In en, this message translates to:
  /// **'Searching NASA documents'**
  String get askSearching;

  /// Ask
  ///
  /// In en, this message translates to:
  /// **'Copy answer'**
  String get askCopy;

  /// Ask
  ///
  /// In en, this message translates to:
  /// **'Open document'**
  String get askOpenDoc;

  /// Ask
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get askSources;

  /// Ask
  ///
  /// In en, this message translates to:
  /// **'Page {n}'**
  String askPage(String n);

  /// Ask
  ///
  /// In en, this message translates to:
  /// **'Earlier questions'**
  String get askEarlier;

  /// Ask
  ///
  /// In en, this message translates to:
  /// **'Try a related question'**
  String get askRelated;

  /// Citation tooltip
  ///
  /// In en, this message translates to:
  /// **'{title}, page {page}'**
  String askCitationTip(String title, String page);

  /// Citation a11y
  ///
  /// In en, this message translates to:
  /// **'Source {n}'**
  String askCitationSemantics(String n);

  /// Ask
  ///
  /// In en, this message translates to:
  /// **'Answers are generated by an AI model from the cited documents and can contain mistakes. Check the source before relying on it.'**
  String get askFootnote;

  /// Earth
  ///
  /// In en, this message translates to:
  /// **'Lessons for Earth'**
  String get earthTitle;

  /// Earth
  ///
  /// In en, this message translates to:
  /// **'What fire experiments in orbit teach us about fire safety in rooms, vehicles and workplaces here.'**
  String get earthDesc;

  /// Earth
  ///
  /// In en, this message translates to:
  /// **'In orbit'**
  String get earthInOrbit;

  /// Earth
  ///
  /// In en, this message translates to:
  /// **'On Earth'**
  String get earthOnEarth;

  /// Earth
  ///
  /// In en, this message translates to:
  /// **'What this means in practice'**
  String get earthPractice;

  /// Earth
  ///
  /// In en, this message translates to:
  /// **'These are general findings from research, not safety rules for a specific building. Follow your local fire service\'s guidance.'**
  String get earthFooter;

  /// Earth
  ///
  /// In en, this message translates to:
  /// **'Lessons are being reviewed'**
  String get earthEmptyTitle;

  /// Earth
  ///
  /// In en, this message translates to:
  /// **'Each lesson is checked against its sources before it appears here.'**
  String get earthEmptyBody;

  /// Methods
  ///
  /// In en, this message translates to:
  /// **'Methods'**
  String get methodsTitle;

  /// Methods (TODO(Q-5): no description in DESIGN.md)
  ///
  /// In en, this message translates to:
  /// **'Where the data comes from, how predictions are made, how well they work, and where they stop.'**
  String get methodsDesc;

  /// ToC
  ///
  /// In en, this message translates to:
  /// **'On this page'**
  String get methodsToc;

  /// Section
  ///
  /// In en, this message translates to:
  /// **'Where the data comes from'**
  String get methodsDataTitle;

  /// Section
  ///
  /// In en, this message translates to:
  /// **'How predictions work'**
  String get methodsPredTitle;

  /// Section
  ///
  /// In en, this message translates to:
  /// **'How well it works'**
  String get methodsValTitle;

  /// Section
  ///
  /// In en, this message translates to:
  /// **'Physics check'**
  String get methodsPhysTitle;

  /// Section
  ///
  /// In en, this message translates to:
  /// **'Data support and extrapolation'**
  String get methodsSupportTitle;

  /// Section
  ///
  /// In en, this message translates to:
  /// **'Limitations'**
  String get methodsLimitsTitle;

  /// Section
  ///
  /// In en, this message translates to:
  /// **'Tested with people'**
  String get methodsUsabilityTitle;

  /// Section
  ///
  /// In en, this message translates to:
  /// **'What FlameSense will never do'**
  String get methodsHonestyTitle;

  /// Methods data
  ///
  /// In en, this message translates to:
  /// **'FlameSense uses {runs} test runs from {experiments} experiments. Every run keeps its source file and citation.'**
  String methodsDataBody(String runs, String experiments);

  /// Methods data
  ///
  /// In en, this message translates to:
  /// **'Data version {version}, built {date}.'**
  String methodsBuild(String version, String date);

  /// Table
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get colSource;

  /// Table
  ///
  /// In en, this message translates to:
  /// **'Runs'**
  String get colRuns;

  /// Table
  ///
  /// In en, this message translates to:
  /// **'Link'**
  String get colLink;

  /// Table
  ///
  /// In en, this message translates to:
  /// **'Quality flag'**
  String get colFlag;

  /// Table
  ///
  /// In en, this message translates to:
  /// **'Meaning'**
  String get colMeaning;

  /// Methods data
  ///
  /// In en, this message translates to:
  /// **'No sources are loaded yet.'**
  String get methodsNoSources;

  /// Quality
  ///
  /// In en, this message translates to:
  /// **'Taken directly from a NASA data file.'**
  String get qualityOkDesc;

  /// Quality
  ///
  /// In en, this message translates to:
  /// **'Read or converted from a source that gives an approximate value.'**
  String get qualityEstimatedDesc;

  /// Quality
  ///
  /// In en, this message translates to:
  /// **'Copied by hand from a table or chart in a published report.'**
  String get qualityDigitizedDesc;

  /// Quality
  ///
  /// In en, this message translates to:
  /// **'Spread rate measured from experiment video by FlameSense\'s tracker.'**
  String get qualityVideoDesc;

  /// Quality
  ///
  /// In en, this message translates to:
  /// **'An outlier. Shown in Explore but not used to train the models.'**
  String get qualitySuspectDesc;

  /// Methods
  ///
  /// In en, this message translates to:
  /// **'FlameSense learns from NASA test runs which conditions let a flame keep burning and how fast it spreads. It uses gradient-boosted decision trees, which run entirely in your browser. Every prediction comes with a data-support level and warnings when it leaves the tested range.'**
  String get methodsPredBody;

  /// Methods
  ///
  /// In en, this message translates to:
  /// **'Two models: one estimates the chance a flame keeps burning; three estimate the slow, typical and fast spread rate (10th, 50th and 90th percentiles).'**
  String get methodsTwoModels;

  /// Methods (only when the constraint is on)
  ///
  /// In en, this message translates to:
  /// **'Oxygen is constrained so that more oxygen can never lower the risk, matching combustion science.'**
  String get methodsOxygenConstraint;

  /// Methods (constraint off, Q-2)
  ///
  /// In en, this message translates to:
  /// **'The oxygen constraint is switched off until the lead confirms its sign.'**
  String get methodsOxygenPending;

  /// Methods
  ///
  /// In en, this message translates to:
  /// **'Inputs the models use'**
  String get methodsFeatures;

  /// Methods
  ///
  /// In en, this message translates to:
  /// **'Not trained: {reason}'**
  String methodsTaskUnavailable(String reason);

  /// Methods
  ///
  /// In en, this message translates to:
  /// **'Chance a flame keeps burning'**
  String get methodsSustainModel;

  /// Methods
  ///
  /// In en, this message translates to:
  /// **'Flame spread rate'**
  String get methodsSpreadModel;

  /// Table
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get colMetric;

  /// Table
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get colValue;

  /// Table
  ///
  /// In en, this message translates to:
  /// **'In plain words'**
  String get colPlain;

  /// Metric
  ///
  /// In en, this message translates to:
  /// **'Runs used'**
  String get metricRows;

  /// Metric
  ///
  /// In en, this message translates to:
  /// **'Independent test series'**
  String get metricGroups;

  /// Metric
  ///
  /// In en, this message translates to:
  /// **'Cross-validation'**
  String get metricCv;

  /// Metric
  ///
  /// In en, this message translates to:
  /// **'ROC-AUC'**
  String get metricRocAuc;

  /// Metric
  ///
  /// In en, this message translates to:
  /// **'How well it ranks burning above going out. 0.5 is a coin flip, 1 is perfect.'**
  String get metricRocAucPlain;

  /// Metric
  ///
  /// In en, this message translates to:
  /// **'Brier score'**
  String get metricBrier;

  /// Metric
  ///
  /// In en, this message translates to:
  /// **'Average squared error of the probability. Lower is better.'**
  String get metricBrierPlain;

  /// Metric
  ///
  /// In en, this message translates to:
  /// **'Baseline Brier score'**
  String get metricBaselineBrier;

  /// Metric
  ///
  /// In en, this message translates to:
  /// **'The score from always guessing the average outcome.'**
  String get metricBaselineBrierPlain;

  /// Metric
  ///
  /// In en, this message translates to:
  /// **'Accuracy at 50%'**
  String get metricAccuracy;

  /// Metric
  ///
  /// In en, this message translates to:
  /// **'Share of runs classified correctly when the cut-off is 50%.'**
  String get metricAccuracyPlain;

  /// Metric
  ///
  /// In en, this message translates to:
  /// **'Mean absolute error'**
  String get metricMae;

  /// Metric
  ///
  /// In en, this message translates to:
  /// **'Typical difference between predicted and measured spread rate.'**
  String get metricMaePlain;

  /// Metric
  ///
  /// In en, this message translates to:
  /// **'Baseline error'**
  String get metricBaselineMae;

  /// Metric
  ///
  /// In en, this message translates to:
  /// **'The error from always predicting the typical training value.'**
  String get metricBaselineMaePlain;

  /// Metric
  ///
  /// In en, this message translates to:
  /// **'Median percentage error'**
  String get metricMedianApe;

  /// Metric
  ///
  /// In en, this message translates to:
  /// **'Half of the predictions are closer than this.'**
  String get metricMedianApePlain;

  /// Metric
  ///
  /// In en, this message translates to:
  /// **'R² (log scale)'**
  String get metricR2;

  /// Metric
  ///
  /// In en, this message translates to:
  /// **'Share of the variation explained. 1 is perfect, 0 is no better than the average.'**
  String get metricR2Plain;

  /// Metric
  ///
  /// In en, this message translates to:
  /// **'80% range coverage'**
  String get metricCoverage;

  /// Metric
  ///
  /// In en, this message translates to:
  /// **'Share of measured rates inside the predicted 80% range. Near 80% is honest.'**
  String get metricCoveragePlain;

  /// Metric
  ///
  /// In en, this message translates to:
  /// **'Physics check error'**
  String get metricPhysicsMae;

  /// Metric
  ///
  /// In en, this message translates to:
  /// **'Error of the thin-fuel theory on the runs it covers.'**
  String get metricPhysicsMaePlain;

  /// Chart title
  ///
  /// In en, this message translates to:
  /// **'Predicted chance against the observed share that kept burning'**
  String get methodsCalibration;

  /// Chart a11y
  ///
  /// In en, this message translates to:
  /// **'Calibration chart with {n} bins. Points near the diagonal mean the probabilities are honest.'**
  String methodsCalibrationSemantics(String n);

  /// Chart axis
  ///
  /// In en, this message translates to:
  /// **'Predicted probability'**
  String get axisPredicted;

  /// Chart axis
  ///
  /// In en, this message translates to:
  /// **'Observed share'**
  String get axisObserved;

  /// Methods
  ///
  /// In en, this message translates to:
  /// **'Tested on whole test series the model never saw, so results aren\'t inflated by near-duplicate runs.'**
  String get methodsCvNote;

  /// Methods
  ///
  /// In en, this message translates to:
  /// **'Each metric is shown next to a no-model baseline so you can see the gain.'**
  String get methodsBaselineNote;

  /// Equation title
  ///
  /// In en, this message translates to:
  /// **'Thin-fuel opposed-flow spread (de Ris, 1969)'**
  String get methodsEq1;

  /// Equation title
  ///
  /// In en, this message translates to:
  /// **'Characteristic buoyant velocity'**
  String get methodsEq2;

  /// Equation
  ///
  /// In en, this message translates to:
  /// **'Effective airflow shown in the Lab'**
  String get methodsEq3;

  /// Table
  ///
  /// In en, this message translates to:
  /// **'Symbol'**
  String get colSymbol;

  /// Table
  ///
  /// In en, this message translates to:
  /// **'Parameter'**
  String get colParameter;

  /// Symbol
  ///
  /// In en, this message translates to:
  /// **'Flame spread rate'**
  String get symVf;

  /// Symbol
  ///
  /// In en, this message translates to:
  /// **'Gas thermal conductivity'**
  String get symLambda;

  /// Symbol
  ///
  /// In en, this message translates to:
  /// **'Flame temperature (from oxygen)'**
  String get symTf;

  /// Symbol
  ///
  /// In en, this message translates to:
  /// **'Pyrolysis temperature of the fuel'**
  String get symTv;

  /// Symbol
  ///
  /// In en, this message translates to:
  /// **'Ambient temperature'**
  String get symTinf;

  /// Symbol
  ///
  /// In en, this message translates to:
  /// **'Fuel density'**
  String get symRho;

  /// Symbol
  ///
  /// In en, this message translates to:
  /// **'Fuel specific heat'**
  String get symCs;

  /// Symbol
  ///
  /// In en, this message translates to:
  /// **'Fuel half-thickness'**
  String get symTau;

  /// Symbol
  ///
  /// In en, this message translates to:
  /// **'Buoyant velocity'**
  String get symUb;

  /// Symbol
  ///
  /// In en, this message translates to:
  /// **'Gravitational acceleration'**
  String get symG;

  /// Symbol
  ///
  /// In en, this message translates to:
  /// **'Gas thermal diffusivity'**
  String get symAlpha;

  /// Symbol
  ///
  /// In en, this message translates to:
  /// **'Effective airflow'**
  String get symUeff;

  /// Methods
  ///
  /// In en, this message translates to:
  /// **'The check applies only to thin materials in opposing airflow (or still air in orbit). It does not cover thick materials, airflow in the same direction as the spread, or droplets.'**
  String get methodsApplicability;

  /// Methods
  ///
  /// In en, this message translates to:
  /// **'The thin-fuel formula ignores finite-rate chemistry and radiation, so it over-predicts spread near extinction (very low airflow in microgravity, or low oxygen). The data-driven model learns that region from data.'**
  String get methodsPhysLimit;

  /// Sign-off
  ///
  /// In en, this message translates to:
  /// **'Checked against the cited sources on {date}'**
  String methodsSignedOff(String date);

  /// Sign-off
  ///
  /// In en, this message translates to:
  /// **'Pending verification'**
  String get methodsPending;

  /// Methods
  ///
  /// In en, this message translates to:
  /// **'Parameter values are added once they are sourced and verified.'**
  String get methodsParamsPending;

  /// Methods
  ///
  /// In en, this message translates to:
  /// **'The data-support badge measures how close your settings are to real NASA runs. High means many runs nearby; medium means some; low means few or none, so the prediction is an extrapolation. On the map, hatched cells have low support. Settings outside the tested range always show a warning.'**
  String get methodsSupportBody;

  /// Limitation
  ///
  /// In en, this message translates to:
  /// **'Small dataset: {runs} runs. Results can change as data is added.'**
  String limit1(String runs);

  /// Limitation
  ///
  /// In en, this message translates to:
  /// **'Runs from one test series share hardware and procedures, so they are not fully independent.'**
  String get limit2;

  /// Limitation
  ///
  /// In en, this message translates to:
  /// **'Outside the tested ranges, and at Moon or Mars gravity, predictions are extrapolations.'**
  String get limit3;

  /// Limitation
  ///
  /// In en, this message translates to:
  /// **'The physics check is a simplified theory and does not hold near extinction.'**
  String get limit4;

  /// Limitation
  ///
  /// In en, this message translates to:
  /// **'Not for operational use: FlameSense does not replace fire safety engineering.'**
  String get limit5;

  /// Methods
  ///
  /// In en, this message translates to:
  /// **'Results appear here after the usability test sessions with non-developers.'**
  String get methodsUsabilityPending;

  /// Methods
  ///
  /// In en, this message translates to:
  /// **'{n} people who don\'t build software tried these tasks.'**
  String methodsUsabilityIntro(String n);

  /// Table
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get colTask;

  /// Table
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get colCompleted;

  /// Table
  ///
  /// In en, this message translates to:
  /// **'Median time'**
  String get colMedianTime;

  /// Table
  ///
  /// In en, this message translates to:
  /// **'{n} of {total}'**
  String usabilityCompleted(String n, String total);

  /// Table
  ///
  /// In en, this message translates to:
  /// **'{s} s'**
  String usabilityTime(String s);

  /// Honesty
  ///
  /// In en, this message translates to:
  /// **'No synthetic data: every run comes from a cited NASA or published source.'**
  String get honesty1;

  /// Honesty
  ///
  /// In en, this message translates to:
  /// **'No hidden extrapolation: predictions outside NASA\'s tested range are flagged.'**
  String get honesty2;

  /// Honesty
  ///
  /// In en, this message translates to:
  /// **'No safety certification claims: FlameSense is a research and education tool.'**
  String get honesty3;

  /// About
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// About (TODO(Q-5))
  ///
  /// In en, this message translates to:
  /// **'What FlameSense is, who built it, and how.'**
  String get aboutDesc;

  /// About
  ///
  /// In en, this message translates to:
  /// **'What FlameSense is'**
  String get aboutWhatTitle;

  /// About
  ///
  /// In en, this message translates to:
  /// **'FlameSense turns NASA\'s microgravity combustion experiments into an explorer, honest predictions and lessons for safety on Earth. It shows how fire behaves in orbit, on the Moon and on Mars, and where NASA has no data yet.'**
  String get aboutWhatBody;

  /// About
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get aboutTeamTitle;

  /// About (TODO(Q-6): names)
  ///
  /// In en, this message translates to:
  /// **'Team FlameSense from Rajshahi. Ehsanur leads code, data and science checks; two team members lead registrations, videos and usability testing.'**
  String get aboutTeamBody;

  /// About
  ///
  /// In en, this message translates to:
  /// **'Challenge'**
  String get aboutChallengeTitle;

  /// About
  ///
  /// In en, this message translates to:
  /// **'NASA Space Apps Challenge 2026: Flame in Freefall'**
  String get aboutChallengeBody;

  /// About
  ///
  /// In en, this message translates to:
  /// **'Open source'**
  String get aboutOpenSourceTitle;

  /// About
  ///
  /// In en, this message translates to:
  /// **'All code is public under the Apache-2.0 license.'**
  String get aboutOpenSourceBody;

  /// About
  ///
  /// In en, this message translates to:
  /// **'View the code on GitHub'**
  String get aboutGithub;

  /// About
  ///
  /// In en, this message translates to:
  /// **'AI use'**
  String get aboutAiTitle;

  /// About (updated in Phase 17)
  ///
  /// In en, this message translates to:
  /// **'A coding agent (Claude Code) wrote the code under the lead\'s review; every prompt is listed in AI_USAGE.md. The Ask page uses the Claude API only over retrieved NASA documents. Predictions come from LightGBM models trained on NASA data.'**
  String get aboutAiBody;

  /// About
  ///
  /// In en, this message translates to:
  /// **'Licenses and credits'**
  String get aboutLicensesTitle;

  /// About
  ///
  /// In en, this message translates to:
  /// **'Code: Apache-2.0.'**
  String get aboutLicenseCode;

  /// About
  ///
  /// In en, this message translates to:
  /// **'Fonts: Archivo and Noto Sans Bengali, SIL Open Font License 1.1.'**
  String get aboutLicenseFonts;

  /// About
  ///
  /// In en, this message translates to:
  /// **'Data credits: {sources}'**
  String aboutDataCredits(String sources);

  /// About
  ///
  /// In en, this message translates to:
  /// **'Data credits are listed per source once data is added.'**
  String get aboutDataCreditsPending;

  /// About
  ///
  /// In en, this message translates to:
  /// **'View all licenses'**
  String get aboutViewLicenses;

  /// About
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get aboutContactTitle;

  /// About (TODO(Q-6): email)
  ///
  /// In en, this message translates to:
  /// **'Report a data error or ask a question on GitHub.'**
  String get aboutContactBody;

  /// About
  ///
  /// In en, this message translates to:
  /// **'Open an issue on GitHub'**
  String get aboutContactButton;

  /// About
  ///
  /// In en, this message translates to:
  /// **'Version {version}, data {data}, built {date}.'**
  String aboutVersion(String version, String data, String date);

  /// About
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get aboutPrivacyTitle;

  /// About
  ///
  /// In en, this message translates to:
  /// **'FlameSense collects no personal data and sets no cookies. Questions you type in Ask are sent to the AI provider only to generate the answer.'**
  String get aboutPrivacy;

  /// 404
  ///
  /// In en, this message translates to:
  /// **'This page drifted off'**
  String get notFoundTitle;

  /// 404
  ///
  /// In en, this message translates to:
  /// **'The address may be mistyped, or the page has moved.'**
  String get notFoundBody;

  /// 404
  ///
  /// In en, this message translates to:
  /// **'Go to Home'**
  String get notFoundCta;

  /// Tour
  ///
  /// In en, this message translates to:
  /// **'Step {n} of {total}'**
  String tourStep(String n, String total);

  /// Tour
  ///
  /// In en, this message translates to:
  /// **'Fire changes shape without gravity'**
  String get tour1Title;

  /// Tour
  ///
  /// In en, this message translates to:
  /// **'Drag gravity from Earth to orbit. The flame turns from an orange teardrop into a slow blue sphere.'**
  String get tour1Body;

  /// Tour
  ///
  /// In en, this message translates to:
  /// **'Set up a fire test'**
  String get tour2Title;

  /// Tour
  ///
  /// In en, this message translates to:
  /// **'Pick a material and set oxygen, pressure, airflow and gravity, like NASA\'s space-station experiments.'**
  String get tour2Body;

  /// Tour
  ///
  /// In en, this message translates to:
  /// **'An honest prediction'**
  String get tour3Title;

  /// Tour
  ///
  /// In en, this message translates to:
  /// **'The model is trained only on NASA test runs. The badge shows how much real data supports this answer.'**
  String get tour3Body;

  /// Tour
  ///
  /// In en, this message translates to:
  /// **'Where flames survive'**
  String get tour4Title;

  /// Tour
  ///
  /// In en, this message translates to:
  /// **'Hot colors keep burning. Hatched areas have little NASA data, including Moon and Mars gravity.'**
  String get tour4Body;

  /// Tour
  ///
  /// In en, this message translates to:
  /// **'Fire safety for a Moon habitat'**
  String get tour5Title;

  /// Tour
  ///
  /// In en, this message translates to:
  /// **'NASA plans habitats with 34% oxygen. See which materials are likely to burn there, and the five experiments that would teach NASA the most.'**
  String get tour5Body;

  /// Tour
  ///
  /// In en, this message translates to:
  /// **'Every number has a source'**
  String get tour6Title;

  /// Tour
  ///
  /// In en, this message translates to:
  /// **'Open any run to see the NASA dataset or report it came from.'**
  String get tour6Body;

  /// Tour
  ///
  /// In en, this message translates to:
  /// **'Ask the NASA papers'**
  String get tour7Title;

  /// Tour
  ///
  /// In en, this message translates to:
  /// **'Answers cite the exact document and page.'**
  String get tour7Body;

  /// Tour
  ///
  /// In en, this message translates to:
  /// **'Lessons for Earth'**
  String get tour8Title;

  /// Tour
  ///
  /// In en, this message translates to:
  /// **'What space fire research means for fire safety in rooms, vehicles and workplaces.'**
  String get tour8Body;

  /// Missions
  ///
  /// In en, this message translates to:
  /// **'Plan for a mission'**
  String get missionsTitle;

  /// Missions
  ///
  /// In en, this message translates to:
  /// **'NASA\'s next habitats may use less pressure and more oxygen than the ISS. Pick a mission to see which materials are likely to burn there, and where NASA has no data yet.'**
  String get missionsDesc;

  /// Mission
  ///
  /// In en, this message translates to:
  /// **'International Space Station'**
  String get missionIss;

  /// Mission
  ///
  /// In en, this message translates to:
  /// **'Artemis lunar habitat'**
  String get missionLunar;

  /// Mission
  ///
  /// In en, this message translates to:
  /// **'Mars transit'**
  String get missionMarsTransit;

  /// Mission
  ///
  /// In en, this message translates to:
  /// **'Mars surface habitat'**
  String get missionMars;

  /// Mission
  ///
  /// In en, this message translates to:
  /// **'Earth (reference)'**
  String get missionEarth;

  /// Mission note
  ///
  /// In en, this message translates to:
  /// **'Cabin atmosphere of the space station today.'**
  String get missionIssNote;

  /// Mission note
  ///
  /// In en, this message translates to:
  /// **'Exploration atmosphere at Moon gravity.'**
  String get missionLunarNote;

  /// Mission note
  ///
  /// In en, this message translates to:
  /// **'Exploration atmosphere in weightless cruise.'**
  String get missionMarsTransitNote;

  /// Mission note
  ///
  /// In en, this message translates to:
  /// **'Exploration atmosphere at Mars gravity.'**
  String get missionMarsNote;

  /// Mission note
  ///
  /// In en, this message translates to:
  /// **'Sea-level air, for comparison.'**
  String get missionEarthNote;

  /// Mission row
  ///
  /// In en, this message translates to:
  /// **'{pressure} kPa, {o2}% oxygen, {gravity}'**
  String missionAtmosphere(String pressure, String o2, String gravity);

  /// Mission row
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get missionSource;

  /// Mission count
  ///
  /// In en, this message translates to:
  /// **'likely to burn'**
  String get missionCountBurn;

  /// Mission count
  ///
  /// In en, this message translates to:
  /// **'likely to go out'**
  String get missionCountOut;

  /// Mission count
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get missionCountUnknown;

  /// Verdict
  ///
  /// In en, this message translates to:
  /// **'Likely to keep burning'**
  String get verdictBurns;

  /// Verdict
  ///
  /// In en, this message translates to:
  /// **'Likely to go out'**
  String get verdictOut;

  /// Verdict
  ///
  /// In en, this message translates to:
  /// **'Unknown, not enough data'**
  String get verdictUnknown;

  /// Verdict
  ///
  /// In en, this message translates to:
  /// **'Uncertain'**
  String get verdictUncertain;

  /// Table
  ///
  /// In en, this message translates to:
  /// **'Material'**
  String get missionMaterial;

  /// Table
  ///
  /// In en, this message translates to:
  /// **'Verdict'**
  String get missionVerdict;

  /// Table
  ///
  /// In en, this message translates to:
  /// **'Worst case'**
  String get missionWorstCase;

  /// Table
  ///
  /// In en, this message translates to:
  /// **'Airflow at worst case'**
  String get missionWorstFlow;

  /// Table
  ///
  /// In en, this message translates to:
  /// **'Data support'**
  String get missionSupport;

  /// Panel
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get missionMaterials;

  /// Tooltip
  ///
  /// In en, this message translates to:
  /// **'The highest chance of burning across every airflow speed in the data, at this mission\'s gravity, pressure and oxygen.'**
  String get missionWorstCaseTip;

  /// Empty table
  ///
  /// In en, this message translates to:
  /// **'No materials are in the dataset yet.'**
  String get missionNoMaterials;

  /// Mission gap
  ///
  /// In en, this message translates to:
  /// **'{n} NASA runs at {gravity} gravity in this dataset. Verdicts here are extrapolations from orbit and Earth data.'**
  String missionGap(String n, String gravity);

  /// Wishlist
  ///
  /// In en, this message translates to:
  /// **'Where NASA should test next'**
  String get wishlistTitle;

  /// Wishlist
  ///
  /// In en, this message translates to:
  /// **'A ranking aid: conditions where the model is least sure and no NASA run is nearby. Scientists still design the experiments.'**
  String get wishlistCaption;

  /// Reason
  ///
  /// In en, this message translates to:
  /// **'The model is unsure here (p ≈ {p}).'**
  String wishlistReasonUnsure(String p);

  /// Reason
  ///
  /// In en, this message translates to:
  /// **'No NASA run is close to these conditions.'**
  String get wishlistReasonFar;

  /// Reason
  ///
  /// In en, this message translates to:
  /// **'The spread-rate range is wide.'**
  String get wishlistReasonWide;

  /// Wishlist row
  ///
  /// In en, this message translates to:
  /// **'{o2}% O₂, {pressure} kPa, {flow} mm/s, {fuel}'**
  String wishlistConditions(
    String o2,
    String pressure,
    String flow,
    String fuel,
  );

  /// Wishlist
  ///
  /// In en, this message translates to:
  /// **'Planned NASA tests ({label}) rank in the top {pct}% of FlameSense\'s list.'**
  String wishlistPlanned(String label, String pct);

  /// Legend
  ///
  /// In en, this message translates to:
  /// **'Planned NASA test ({label})'**
  String wishlistPlannedLegend(String label);

  /// Pin a11y
  ///
  /// In en, this message translates to:
  /// **'Suggested test {n}'**
  String wishlistPin(String n);

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Download test matrix (CSV)'**
  String get wishlistCsv;

  /// Toast
  ///
  /// In en, this message translates to:
  /// **'Test matrix downloaded'**
  String get wishlistCsvDone;

  /// Wishlist
  ///
  /// In en, this message translates to:
  /// **'The wishlist needs the burning model, which doesn\'t have enough data yet.'**
  String get wishlistEmpty;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Download Mission Fire Brief (PDF)'**
  String get briefButton;

  /// Toast
  ///
  /// In en, this message translates to:
  /// **'Brief downloaded'**
  String get briefDone;

  /// Missions
  ///
  /// In en, this message translates to:
  /// **'Mission atmospheres come from NASA documents. FlameSense checks each material at the worst airflow it tested, because cabin airflow varies.'**
  String get missionsNotice;

  /// Empty
  ///
  /// In en, this message translates to:
  /// **'Mission presets are being verified'**
  String get missionsEmptyTitle;

  /// Empty
  ///
  /// In en, this message translates to:
  /// **'Each mission\'s atmosphere is checked against its NASA source before it appears here.'**
  String get missionsEmptyBody;

  /// Debug-only notice
  ///
  /// In en, this message translates to:
  /// **'Debug build: this mission has no source and is hidden in release.'**
  String get missionUnsourcedDebug;

  /// Planned experiment label
  ///
  /// In en, this message translates to:
  /// **'FM2'**
  String get plannedFm2;
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
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
