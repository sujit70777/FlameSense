// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'FlameSense';

  @override
  String get tagline =>
      'যেখানে \"উপর\" বলে কিছু নেই, সেখানে আগুন কেমন আচরণ করে, দেখুন।';

  @override
  String get navHome => 'হোম';

  @override
  String get navMissions => 'মিশন';

  @override
  String get navExplore => 'এক্সপ্লোর';

  @override
  String get navLab => 'ফায়ার ল্যাব';

  @override
  String get navMap => 'মানচিত্র';

  @override
  String get navAsk => 'প্রশ্ন';

  @override
  String get navEarth => 'পৃথিবীর শিক্ষা';

  @override
  String get navMethods => 'পদ্ধতি';

  @override
  String get navAbout => 'পরিচিতি';

  @override
  String get navMore => 'আরও';

  @override
  String get takeTour => 'ট্যুর দেখুন';

  @override
  String get themeSystem => 'সিস্টেম থিম ব্যবহার করুন';

  @override
  String get themeLight => 'লাইট থিম';

  @override
  String get themeDark => 'ডার্ক থিম';

  @override
  String themeSwitchTo(String mode) {
    return '$mode এ বদলান';
  }

  @override
  String get langEnglish => 'EN';

  @override
  String get langBangla => 'বাং';

  @override
  String get langLabel => 'ভাষা';

  @override
  String get menuOptions => 'আরও বিকল্প';

  @override
  String get disclaimer =>
      'FlameSense একটি গবেষণা ও শিক্ষামূলক টুল। এটি কোনো সনদপ্রাপ্ত অগ্নি-নিরাপত্তা ব্যবস্থা নয় এবং বাস্তব নিরাপত্তা সিদ্ধান্তের জন্য ব্যবহার করা যাবে না।';

  @override
  String get notAffiliated =>
      'NASA-এর সঙ্গে যুক্ত বা NASA দ্বারা অনুমোদিত নয়। NASA-এর উন্মুক্ত ডেটা ব্যবহার করে।';

  @override
  String get credits =>
      'ডেটা: NASA উন্মুক্ত ডেটা। কোড: Apache-2.0। NASA Space Apps Challenge 2026, রাজশাহীর জন্য তৈরি।';

  @override
  String get loadingData => 'NASA পরীক্ষার ডেটা লোড হচ্ছে';

  @override
  String get loadErrorTitle => 'FlameSense তার ডেটা লোড করতে পারেনি';

  @override
  String loadErrorBody(String file) {
    return '$file ফাইলটি নেই বা নষ্ট। পেজটি আবার লোড করুন। বারবার এমন হলে ডিপ্লয়মেন্ট অসম্পূর্ণ।';
  }

  @override
  String get reload => 'আবার লোড করুন';

  @override
  String get tryAgain => 'আবার চেষ্টা করুন';

  @override
  String get close => 'বন্ধ করুন';

  @override
  String get back => 'পেছনে';

  @override
  String get next => 'পরবর্তী';

  @override
  String get finish => 'শেষ';

  @override
  String get exitTour => 'ট্যুর থেকে বের হন';

  @override
  String get linkCopied => 'লিংক কপি হয়েছে';

  @override
  String get csvDownloaded => 'CSV ডাউনলোড হয়েছে';

  @override
  String get answerCopied => 'উত্তর কপি হয়েছে';

  @override
  String pageTitle(String page) {
    return '$page | FlameSense';
  }

  @override
  String get homePageTitle =>
      'FlameSense: NASA-র মহাকাশ স্টেশনের আগুন পরীক্ষা থেকে অগ্নি-নিরাপত্তার অন্তর্দৃষ্টি';

  @override
  String get valueYes => 'হ্যাঁ';

  @override
  String get valueNo => 'না';

  @override
  String get notAvailable => '—';

  @override
  String get openInNewTab => 'নতুন ট্যাবে খোলে';

  @override
  String get dismiss => 'সরিয়ে দিন';

  @override
  String get info => 'আরও তথ্য';

  @override
  String get gEarth => 'পৃথিবী';

  @override
  String get gMars => 'মঙ্গল';

  @override
  String get gMoon => 'চাঁদ';

  @override
  String get gIss => 'আইএসএস কক্ষপথ';

  @override
  String get gCustom => 'কাস্টম';

  @override
  String gravityValue(String label, String value) {
    return '$label ($value g)';
  }

  @override
  String get gravityClassMicro => 'মাইক্রোগ্র্যাভিটি (microgravity)';

  @override
  String get gravityClassPartial => 'চাঁদ বা মঙ্গল';

  @override
  String get gravityClassEarth => 'পৃথিবী';

  @override
  String get unitMmS => 'mm/s';

  @override
  String get unitKpa => 'kPa';

  @override
  String get unitPercent => '%';

  @override
  String get unitMm => 'mm';

  @override
  String get unitKgM3 => 'kg/m³';

  @override
  String get unitKgM2 => 'kg/m²';

  @override
  String get unitMm2S => 'mm²/s';

  @override
  String get unitG => 'g';

  @override
  String get unitSeconds => 'সে.';

  @override
  String get featO2 => 'অক্সিজেন';

  @override
  String get featPressure => 'চাপ';

  @override
  String get featFlow => 'বায়ুপ্রবাহ';

  @override
  String get featGravity => 'মাধ্যাকর্ষণ';

  @override
  String get featThickness => 'পুরুত্ব';

  @override
  String get featDensity => 'ঘনত্ব';

  @override
  String get featFuelClass => 'উপাদানের ধরন';

  @override
  String get featFlowDir => 'বায়ুপ্রবাহের দিক';

  @override
  String get featDiluent => 'মিশ্রক গ্যাস (diluent)';

  @override
  String get featO2Partial => 'অক্সিজেনের আংশিক চাপ';

  @override
  String get featLogFlow => 'বায়ুপ্রবাহ (লগ স্কেল)';

  @override
  String get featLogGravity => 'মাধ্যাকর্ষণ (লগ স্কেল)';

  @override
  String get featArealDensity => 'ক্ষেত্রফলভিত্তিক ঘনত্ব';

  @override
  String get fuelThinSolid => 'পাতলা কঠিন';

  @override
  String get fuelThickSolid => 'পুরু কঠিন';

  @override
  String get fuelDroplet => 'জ্বালানির ফোঁটা';

  @override
  String get fuelGasJet => 'গ্যাস জেট';

  @override
  String get fuelOther => 'অন্যান্য';

  @override
  String get dirOpposed => 'বিপরীতমুখী';

  @override
  String get dirConcurrent => 'একমুখী';

  @override
  String get dirQuiescent => 'নেই';

  @override
  String get dirOther => 'অন্যান্য';

  @override
  String get diluentN2 => 'নাইট্রোজেন';

  @override
  String get diluentHe => 'হিলিয়াম';

  @override
  String get diluentCo2 => 'কার্বন ডাই-অক্সাইড';

  @override
  String get diluentOther => 'অন্যান্য';

  @override
  String get platformIss => 'আইএসএস';

  @override
  String get platformFreeFlyer => 'ফ্রি-ফ্লায়ার মহাকাশযান';

  @override
  String get platformDropTower => 'ড্রপ টাওয়ার';

  @override
  String get platformParabolic => 'প্যারাবোলিক ফ্লাইট';

  @override
  String get platformGround => 'ভূমি';

  @override
  String get qualityOk => 'পরিমাপকৃত';

  @override
  String get qualityEstimated => 'আনুমানিক';

  @override
  String get qualityDigitized => 'ডিজিটাইজ করা';

  @override
  String get qualityVideoDerived => 'ভিডিও থেকে নেওয়া';

  @override
  String get qualitySuspect => 'চিহ্নিত';

  @override
  String get supportHigh => 'ডেটা সমর্থন: বেশি';

  @override
  String get supportMedium => 'ডেটা সমর্থন: মাঝারি';

  @override
  String get supportLow => 'ডেটা সমর্থন: কম';

  @override
  String get supportHighTip =>
      'এই অবস্থার কাছাকাছি NASA অনেকগুলো পরীক্ষা চালিয়েছে।';

  @override
  String get supportMediumTip =>
      'এই অবস্থার কাছাকাছি NASA-র কিছু পরীক্ষা আছে। পূর্বাভাসটিকে আনুমানিক ধরুন।';

  @override
  String get supportLowTip =>
      'এই অবস্থার কাছাকাছি NASA-র পরীক্ষা খুব কম বা নেই। এটি একটি বহির্বেশন (extrapolation)।';

  @override
  String get supportShortHigh => 'বেশি';

  @override
  String get supportShortMedium => 'মাঝারি';

  @override
  String get supportShortLow => 'কম';

  @override
  String askErrRate(String minutes) {
    return 'অল্প সময়ে অনেক প্রশ্ন হয়েছে। $minutes মিনিট পরে আবার চেষ্টা করুন।';
  }

  @override
  String get askErrUpstream =>
      'উত্তর সেবা সাড়া দেয়নি। আবার চেষ্টা করুন, অথবা একটি প্রস্তাবিত প্রশ্ন বেছে নিন; সেগুলোর উত্তর সংরক্ষিত আছে।';

  @override
  String get askErrOffline =>
      'আপনি অফলাইনে আছেন। প্রস্তাবিত প্রশ্নগুলো এখনো কাজ করে।';

  @override
  String get askErrInvalid => '৩ থেকে ৫০০ অক্ষরের মধ্যে একটি প্রশ্ন লিখুন।';

  @override
  String get askErrServer =>
      'সার্ভারে সমস্যা হয়েছে। এক মিনিট পরে আবার চেষ্টা করুন।';

  @override
  String numErrRange(String min, String max) {
    return '$min থেকে $max এর মধ্যে একটি সংখ্যা লিখুন।';
  }

  @override
  String noticeOutside(String feature, String min, String max, String unit) {
    return '$feature NASA-র পরীক্ষিত সীমার বাইরে ($min–$max $unit)। পূর্বাভাসটি একটি বহির্বেশন।';
  }

  @override
  String get noticeLowSupport =>
      'এই অবস্থার কাছাকাছি NASA-র পরীক্ষা খুব কম। এটিকে মোটামুটি অনুমান হিসেবে নিন।';

  @override
  String get noticePartialG =>
      'চাঁদ বা মঙ্গলের মাধ্যাকর্ষণে NASA-র আগুনের ডেটা খুব কম বা নেই। এখানের পূর্বাভাস পৃথিবী ও কক্ষপথের মাঝের বহির্বেশন। এটি একটি বাস্তব গবেষণার ঘাটতি।';

  @override
  String noticeUnavailable(String output) {
    return '$output নির্ভরযোগ্যভাবে পূর্বাভাস দেওয়ার মতো যথেষ্ট NASA ডেটা নেই, তাই FlameSense কোনো পূর্বাভাস দেখায় না।';
  }

  @override
  String get noticeOneExperiment =>
      'সব পরীক্ষা একটি মাত্র এক্সপেরিমেন্ট থেকে, তাই এক্সপেরিমেন্টগুলোর মধ্যে তুলনা এখনো সম্ভব নয়।';

  @override
  String get noticeQuantiles =>
      'তিনটি বিস্তার-হার মডেলের মান উল্টে গিয়েছিল, তাই সেগুলো আবার ক্রমে সাজানো হয়েছে।';

  @override
  String get outputSustain => 'আগুন জ্বলতে থাকার সম্ভাবনা';

  @override
  String get outputSpread => 'আগুন ছড়ানোর হার';

  @override
  String mapGapNotice(String body, String n) {
    return 'এই ডেটাসেটে $body-এর মাধ্যাকর্ষণে NASA-র কোনো আগুন পরীক্ষা নেই ($nটি পরীক্ষা)। এখানের রং বহির্বেশিত, তাই মানচিত্রের বেশিরভাগ অংশ দাগকাটা। Artemis ও ভবিষ্যতের মঙ্গল মিশনের জন্য এই ঘাটতি পূরণ জরুরি।';
  }

  @override
  String get physicsNotApplicable =>
      'পদার্থবিজ্ঞান যাচাই কেবল বিপরীতমুখী বায়ুপ্রবাহে পাতলা উপাদানের জন্য। এই অবস্থা তার বাইরে।';

  @override
  String get physicsNearExt =>
      'নিভে যাওয়ার কাছাকাছি সহজ তত্ত্বটি বিস্তার বেশি দেখায়। এখানে ডেটাভিত্তিক পূর্বাভাসে বেশি ভরসা রাখুন।';

  @override
  String get physicsUnavailable =>
      'প্যারামিটারগুলো যাচাই না হওয়া পর্যন্ত পদার্থবিজ্ঞান যাচাই বন্ধ আছে।';

  @override
  String get homeHeadline => 'মহাকাশে আগুনের কোনো \"উপর\" নেই।';

  @override
  String get homeSubhead =>
      'পৃথিবীতে উঠে যাওয়া গরম বাতাস শিখাকে অশ্রুবিন্দুর মতো লম্বা করে। মহাকাশ স্টেশনে কিছুই ওপরে ওঠে না, তাই শিখা হয় গোল, নীল আর ধীর। FlameSense NASA-র মহাকাশ স্টেশনের আগুন পরীক্ষাগুলোকে এমন পূর্বাভাসে বদলে দেয় যা আপনি নিজে ঘুরে দেখতে পারেন।';

  @override
  String get homeCtaLab => 'ফায়ার ল্যাব খুলুন';

  @override
  String homeDataSentence(String runs, String experiments, String fuels) {
    return '$experimentsটি NASA এক্সপেরিমেন্টের $fuelsটি উপাদানের $runsটি পরীক্ষার ওপর তৈরি।';
  }

  @override
  String get homeDataPending =>
      'ডেটাসেটে NASA-র পরীক্ষাগুলো যোগ করা হচ্ছে। যথেষ্ট পরীক্ষা যোগ হলে পূর্বাভাস দেখা যাবে।';

  @override
  String get homeEarthFlame => 'পৃথিবী';

  @override
  String get homeYourGravity => 'আপনার মাধ্যাকর্ষণ';

  @override
  String get homeBuoyantFlow => 'প্লবতাজনিত বায়ুপ্রবাহ';

  @override
  String get homePredictedSpread => 'পূর্বাভাসিত বিস্তার';

  @override
  String get homeNextTitle => 'এরপর কোথায় যাবেন';

  @override
  String get homeNextMissions => 'একটি মিশনের পরিকল্পনা করুন';

  @override
  String get homeNextMissionsDesc => 'চাঁদের আবাসে কোন উপাদান জ্বলতে পারে';

  @override
  String get homeNextExplore => 'পরীক্ষাগুলো ঘুরে দেখুন';

  @override
  String get homeNextExploreDesc => 'প্রতিটি পরীক্ষা, ফিল্টারযোগ্য, NASA উৎসসহ';

  @override
  String get homeNextMap => 'দাহ্যতার মানচিত্র দেখুন';

  @override
  String get homeNextMapDesc =>
      'অক্সিজেন ও বায়ুপ্রবাহ অনুযায়ী কোথায় শিখা টিকে থাকে';

  @override
  String get homeNextAsk => 'NASA-র নথিকে প্রশ্ন করুন';

  @override
  String get homeNextAskDesc => 'উৎসসহ উত্তর';

  @override
  String get homeNextEarth => 'পৃথিবীর জন্য শিক্ষা';

  @override
  String get homeNextEarthDesc =>
      'মহাকাশের আগুন এখানকার নিরাপত্তা নিয়ে কী শেখায়';

  @override
  String flameSemantics(String label, String shape) {
    return '$label-এ শিখা। $shape';
  }

  @override
  String get flameShapeEarth =>
      'উঠে যাওয়া গরম বাতাসে ওপরের দিকে লম্বা হওয়া কমলা অশ্রুবিন্দু।';

  @override
  String get flameShapeSpace =>
      'ম্লান নীল গোলক: মাধ্যাকর্ষণ ছাড়া কিছুই ওপরে ওঠে না।';

  @override
  String get flameShapeMid => 'পৃথিবীর চেয়ে গোল ও নীল, প্লবতা দুর্বল।';

  @override
  String get exploreTitle => 'পরীক্ষাগুলো ঘুরে দেখুন';

  @override
  String get exploreDesc =>
      'FlameSense যে সব NASA পরীক্ষা ব্যবহার করে, এক টেবিলে। প্রতিটি সারি তার উৎসের সঙ্গে যুক্ত।';

  @override
  String get filterExperiment => 'এক্সপেরিমেন্ট';

  @override
  String get filterPlatform => 'প্ল্যাটফর্ম';

  @override
  String get filterFuelClass => 'উপাদানের ধরন';

  @override
  String get filterGravity => 'মাধ্যাকর্ষণ';

  @override
  String get filterO2 => 'অক্সিজেনের পরিসর';

  @override
  String get filterPressure => 'চাপের পরিসর';

  @override
  String get filterQuality => 'মান';

  @override
  String get qualityIncEstimated => 'আনুমানিক অন্তর্ভুক্ত করুন';

  @override
  String get qualityIncDigitized => 'ডিজিটাইজ করা অন্তর্ভুক্ত করুন';

  @override
  String get qualityIncVideo => 'ভিডিও থেকে নেওয়া অন্তর্ভুক্ত করুন';

  @override
  String get qualityIncFlagged => 'চিহ্নিত অন্তর্ভুক্ত করুন';

  @override
  String get filterAll => 'সব';

  @override
  String get filtersButton => 'ফিল্টার';

  @override
  String get filterApply => 'প্রয়োগ করুন';

  @override
  String filterRangeValue(String min, String max, String unit) {
    return '$min–$max $unit';
  }

  @override
  String exploreShowing(String shown, String total) {
    return '$totalটির মধ্যে $shownটি পরীক্ষা দেখানো হচ্ছে';
  }

  @override
  String get exploreClear => 'ফিল্টার মুছুন';

  @override
  String get exploreDownload => 'CSV ডাউনলোড করুন';

  @override
  String get exploreTabSpread => 'বিস্তার বনাম অক্সিজেন';

  @override
  String get exploreTabBurning => 'জ্বলা বনাম বায়ুপ্রবাহ';

  @override
  String get exploreTabRuns => 'এক্সপেরিমেন্টপ্রতি পরীক্ষা';

  @override
  String get exploreEmptyTitle => 'এই ফিল্টারে কোনো পরীক্ষা মেলেনি';

  @override
  String get exploreEmptyBody =>
      'অক্সিজেন বা চাপের পরিসর বাড়ান, অথবা আরও এক্সপেরিমেন্ট অন্তর্ভুক্ত করুন।';

  @override
  String get exploreNoDataTitle => 'এখনো কোনো NASA পরীক্ষা লোড হয়নি';

  @override
  String get exploreNoDataBody =>
      'NASA উৎস ফাইলগুলো ডেটাসেটে যোগ হলে পরীক্ষাগুলো এখানে দেখা যাবে।';

  @override
  String get chartNoPoints => 'এই মানসহ আঁকার মতো কোনো পরীক্ষা নেই।';

  @override
  String get colRun => 'পরীক্ষা';

  @override
  String get colExperiment => 'এক্সপেরিমেন্ট';

  @override
  String get colFuel => 'জ্বালানি';

  @override
  String get colO2 => 'O₂ (%)';

  @override
  String get colPressure => 'চাপ (kPa)';

  @override
  String get colFlow => 'বায়ুপ্রবাহ (mm/s)';

  @override
  String get colGravity => 'মাধ্যাকর্ষণ (g)';

  @override
  String get colOutcome => 'ফলাফল';

  @override
  String get colSpread => 'বিস্তার (mm/s)';

  @override
  String get colQuality => 'মান';

  @override
  String sortBy(String column) {
    return '$column অনুযায়ী সাজান';
  }

  @override
  String get axisO2 => 'অক্সিজেন (%)';

  @override
  String get axisSpread => 'বিস্তারের হার (mm/s, লগ স্কেল)';

  @override
  String get axisFlow => 'বায়ুপ্রবাহ (mm/s, লগ স্কেল)';

  @override
  String get axisRuns => 'পরীক্ষা';

  @override
  String chartSpreadSummary(String n) {
    return '$nটি পরীক্ষার বিন্দুচিত্র: অক্সিজেনের বিপরীতে আগুন ছড়ানোর হার, মাধ্যাকর্ষণ শ্রেণি অনুযায়ী রঙিন।';
  }

  @override
  String chartBurningSummary(String n, String kept, String out) {
    return 'বায়ুপ্রবাহের বিপরীতে $nটি পরীক্ষা: $keptটি জ্বলতে থাকে, $outটি নিভে যায়।';
  }

  @override
  String chartRunsSummary(String n, String experiments) {
    return '$experimentsটি এক্সপেরিমেন্ট জুড়ে $nটি পরীক্ষার বার চার্ট।';
  }

  @override
  String runTitle(String id) {
    return 'পরীক্ষা $id';
  }

  @override
  String get runKeptBurning => 'জ্বলতে থাকে';

  @override
  String get runWentOut => 'নিভে যায়';

  @override
  String get runNoIgnition => 'জ্বলেনি';

  @override
  String get runUnknownOutcome => 'ফলাফল লেখা নেই';

  @override
  String get runOpenSource => 'উৎস খুলুন';

  @override
  String get runLoadLab => 'এই অবস্থা ফায়ার ল্যাবে লোড করুন';

  @override
  String get runSource => 'উৎস';

  @override
  String get fieldGroup => 'পরীক্ষার সিরিজ';

  @override
  String get fieldExperiment => 'এক্সপেরিমেন্ট';

  @override
  String get fieldPlatform => 'প্ল্যাটফর্ম';

  @override
  String get fieldGravity => 'মাধ্যাকর্ষণ';

  @override
  String get fieldFuelName => 'উপাদান';

  @override
  String get fieldFuelClass => 'উপাদানের ধরন';

  @override
  String get fieldThickness => 'পুরুত্ব';

  @override
  String get fieldDensity => 'ঘনত্ব';

  @override
  String get fieldO2 => 'অক্সিজেন';

  @override
  String get fieldPressure => 'চাপ';

  @override
  String get fieldDiluent => 'মিশ্রক গ্যাস';

  @override
  String get fieldFlow => 'বায়ুপ্রবাহ';

  @override
  String get fieldFlowDir => 'বায়ুপ্রবাহের দিক';

  @override
  String get fieldIgnited => 'জ্বলেছে';

  @override
  String get fieldSustained => 'জ্বলতে থাকে';

  @override
  String get fieldSpread => 'আগুন ছড়ানোর হার';

  @override
  String get fieldBurningRate => 'দহন-হার ধ্রুবক';

  @override
  String get fieldExtinction => 'নিভে যাওয়ার কারণ';

  @override
  String get fieldSourceFile => 'উৎস ফাইল';

  @override
  String get fieldQuality => 'মান';

  @override
  String get fieldNotes => 'টীকা';

  @override
  String get labTitle => 'ফায়ার ল্যাব';

  @override
  String get labDesc =>
      'একটি আগুন পরীক্ষার অবস্থা ঠিক করুন এবং দেখুন NASA-র ডেটা কী পূর্বাভাস দেয়।';

  @override
  String get labConditions => 'অবস্থা';

  @override
  String get labPrediction => 'পূর্বাভাস';

  @override
  String get labMaterial => 'উপাদান';

  @override
  String get labMaterialCustom => 'কাস্টম';

  @override
  String labMaterialSummary(String fuelClass, String thickness) {
    return '$fuelClass, $thickness mm';
  }

  @override
  String get labMarkerSeaLevel => 'সমুদ্রপৃষ্ঠ 101.3 kPa';

  @override
  String get labMarkerEarthAir => 'পৃথিবীর বাতাস 21%';

  @override
  String get labReset => 'ডিফল্টে ফিরিয়ে নিন';

  @override
  String get labCopyLink => 'এই সেটআপের লিংক কপি করুন';

  @override
  String get labCompare => 'পৃথিবীর সঙ্গে তুলনা করুন';

  @override
  String get labGaugeCaption => 'শিখা জ্বলতে থাকার সম্ভাবনা';

  @override
  String get labGoesOut => 'নিভে যায়';

  @override
  String get labKeepsBurning => 'জ্বলতে থাকে';

  @override
  String get labGaugeUnavailable => 'এটি পূর্বাভাস দেওয়ার মতো যথেষ্ট ডেটা নেই';

  @override
  String labGaugeSemantics(String pct) {
    return 'শিখা জ্বলতে থাকার সম্ভাবনা: $pct শতাংশ।';
  }

  @override
  String get labChanceLabel => 'জ্বলতে থাকার সম্ভাবনা';

  @override
  String get labSpreadTitle => 'আগুন ছড়ানোর হার';

  @override
  String labRange80(String low, String high) {
    return '80% পরিসর: $low থেকে $high mm/s';
  }

  @override
  String labSpreadSemantics(String mid, String low, String high) {
    return 'আগুন ছড়ানোর হার প্রতি সেকেন্ডে $mid মিলিমিটার, 80% পরিসর $low থেকে $high।';
  }

  @override
  String get labEffectiveFlow => 'কার্যকর বায়ুপ্রবাহ';

  @override
  String labEffectiveFlowCaption(String forced, String buoyant) {
    return '(চালিত $forced + প্লবতাজনিত $buoyant)';
  }

  @override
  String get labEffectiveFlowForcedOnly =>
      '(শুধু চালিত বায়ুপ্রবাহ; প্লবতাজনিত অংশের জন্য পদার্থবিজ্ঞান যাচাই দরকার)';

  @override
  String get labSensTitle => 'ঝুঁকি কীসে বদলায়';

  @override
  String get labSensCaption =>
      'প্রতিটি সারি একটি সেটিং তার পরিসরের 10% সরায় এবং বাকিগুলো স্থির রাখে।';

  @override
  String labSensRow(String feature, String delta, String change) {
    return '$feature $delta বাড়ালে: $change';
  }

  @override
  String labSensPoints(String value) {
    return '$value পয়েন্ট';
  }

  @override
  String labSensMmS(String value) {
    return '$value mm/s';
  }

  @override
  String get labSensEmpty => 'পূর্বাভাস পাওয়া গেলে সংবেদনশীলতা দেখা যাবে।';

  @override
  String get labPhysicsTitle => 'পদার্থবিজ্ঞান যাচাই';

  @override
  String get labPhysicsPredicts => 'পাতলা-জ্বালানি তত্ত্বের পূর্বাভাস';

  @override
  String labPhysicsLower(String pct) {
    return 'ML পূর্বাভাস $pct% কম, যা নিভে যাওয়ার কাছাকাছি প্রত্যাশিত, যেখানে সহজ তত্ত্ব বেশি দেখায়।';
  }

  @override
  String labPhysicsHigher(String pct) {
    return 'ML পূর্বাভাস সহজ তত্ত্বের চেয়ে $pct% বেশি।';
  }

  @override
  String get labPhysicsSeeEquation => 'সমীকরণটি দেখুন';

  @override
  String get labCompareYourG => 'আপনার মাধ্যাকর্ষণে';

  @override
  String get labCompareEarth => 'পৃথিবীতে (1 g)';

  @override
  String labDeltaMore(String n) {
    return 'পৃথিবীতে জ্বলতে থাকার সম্ভাবনা $n পয়েন্ট বেশি';
  }

  @override
  String labDeltaLess(String n) {
    return 'পৃথিবীতে জ্বলতে থাকার সম্ভাবনা $n পয়েন্ট কম';
  }

  @override
  String get labDeltaSame => 'পৃথিবীতে জ্বলতে থাকার সম্ভাবনা একই';

  @override
  String labDeltaFaster(String ratio) {
    return 'পৃথিবীতে ×$ratio দ্রুত';
  }

  @override
  String labDeltaSlower(String ratio) {
    return 'পৃথিবীতে ×$ratio ধীর';
  }

  @override
  String labSticky(String pct, String spread) {
    return '$pct% জ্বলতে থাকে, $spread mm/s';
  }

  @override
  String labStickyNoSpread(String pct) {
    return '$pct% জ্বলতে থাকে';
  }

  @override
  String sliderSemantics(String value, String unit) {
    return '$value $unit';
  }

  @override
  String sliderPercentSemantics(String value) {
    return '$value শতাংশ';
  }

  @override
  String numberFieldLabel(String feature) {
    return '$feature এর মান';
  }

  @override
  String get mapTitle => 'দাহ্যতার মানচিত্র';

  @override
  String get mapDesc =>
      'বিভিন্ন অক্সিজেন মাত্রা ও বায়ুপ্রবাহের গতিতে একটি শিখার জ্বলতে থাকার সম্ভাবনা কতটা।';

  @override
  String get mapLegendLow => 'নিভে যাওয়ার সম্ভাবনা';

  @override
  String get mapLegendHigh => 'জ্বলতে থাকার সম্ভাবনা';

  @override
  String get mapHatch => 'এখানে NASA-র ডেটা খুব কম বা নেই';

  @override
  String get mapOpenLab => 'ফায়ার ল্যাবে খুলুন';

  @override
  String get mapOverlays => 'ওভারলে';

  @override
  String get mapOverlayRuns => 'NASA পরীক্ষা';

  @override
  String get mapOverlayContour => '50% রেখা';

  @override
  String get mapContourLabel => '50%';

  @override
  String get mapInspectorHint => 'একটি ঘরের ওপর কার্সর রাখুন';

  @override
  String get mapInspectorTapHint => 'একটি ঘরে ট্যাপ করুন';

  @override
  String mapCellProb(String pct) {
    return '$pct% জ্বলতে থাকে';
  }

  @override
  String get mapPinned => 'পিন করা';

  @override
  String get mapKeptBurning => 'জ্বলতে থাকে';

  @override
  String get mapWentOut => 'নিভে যায়';

  @override
  String get mapSettings => 'মানচিত্রের সেটিং';

  @override
  String mapPressureValue(String value) {
    return 'চাপ $value kPa';
  }

  @override
  String mapGravityValue(String label) {
    return 'মাধ্যাকর্ষণ: $label';
  }

  @override
  String get mapEmptyTitle => 'মানচিত্র আঁকার মতো যথেষ্ট ডেটা নেই';

  @override
  String get mapEmptyBody =>
      'FlameSense-এর জানা ফলাফলসহ অন্তত ৪০টি NASA পরীক্ষা দরকার। যা আছে সব পরীক্ষা আপনি দেখতে পারেন।';

  @override
  String get mapEmptyCta => 'এক্সপ্লোরে পরীক্ষাগুলো দেখুন';

  @override
  String mapSemantics(
    String o2min,
    String o2max,
    String fmin,
    String fmax,
    String low,
    String total,
  ) {
    return 'শিখা জ্বলতে থাকার সম্ভাবনার তাপচিত্র, অক্সিজেন $o2min থেকে $o2max শতাংশ, বায়ুপ্রবাহ $fmin থেকে $fmax mm/s। $totalটি ঘরের $lowটিতে NASA-র ডেটা কম।';
  }

  @override
  String get askTitle => 'NASA-র নথিকে প্রশ্ন করুন';

  @override
  String get askDesc =>
      'উত্তর আসে শুধু FlameSense-এর পড়া NASA নথি থেকে। প্রতিটি বাক্য তার উৎস উল্লেখ করে।';

  @override
  String get askSuggested => 'প্রস্তাবিত প্রশ্ন';

  @override
  String get askQ1 => 'মাইক্রোগ্র্যাভিটিতে শিখা গোল হয় কেন?';

  @override
  String get askQ2 => 'কোনো উপাদান কি মহাকাশে জ্বলে কিন্তু পৃথিবীতে জ্বলে না?';

  @override
  String get askQ3 => 'NASA-র Saffire পরীক্ষাগুলো কী পরীক্ষা করেছে?';

  @override
  String get askQ4 =>
      'মাইক্রোগ্র্যাভিটিতে বায়ুপ্রবাহ কীভাবে আগুন ছড়ানোকে প্রভাবিত করে?';

  @override
  String get askQ5 => 'মহাকাশে শিখা নীল হয় কেন?';

  @override
  String get askQ6 => 'মহাকাশযানের উপাদানের দাহ্যতা কীভাবে পরীক্ষা করা হয়?';

  @override
  String get askPlaceholder => 'মাইক্রোগ্র্যাভিটিতে আগুন নিয়ে প্রশ্ন করুন';

  @override
  String get askInputLabel => 'আপনার প্রশ্ন';

  @override
  String get askButton => 'প্রশ্ন করুন';

  @override
  String askCounter(String n) {
    return '$n / ৫০০';
  }

  @override
  String get askGrounded => 'NASA-র উৎস থেকে উত্তর';

  @override
  String get askNotGrounded => 'FlameSense-এর NASA উৎসে পাওয়া যায়নি';

  @override
  String get askSaved => 'সংরক্ষিত উত্তর';

  @override
  String get askSearching => 'NASA নথি খোঁজা হচ্ছে';

  @override
  String get askCopy => 'উত্তর কপি করুন';

  @override
  String get askOpenDoc => 'নথি খুলুন';

  @override
  String get askSources => 'উৎস';

  @override
  String askPage(String n) {
    return 'পৃষ্ঠা $n';
  }

  @override
  String get askEarlier => 'আগের প্রশ্ন';

  @override
  String get askRelated => 'একটি সম্পর্কিত প্রশ্ন দেখুন';

  @override
  String askCitationTip(String title, String page) {
    return '$title, পৃষ্ঠা $page';
  }

  @override
  String askCitationSemantics(String n) {
    return 'উৎস $n';
  }

  @override
  String get askFootnote =>
      'উত্তরগুলো উল্লিখিত নথি থেকে একটি AI মডেল তৈরি করে এবং ভুল থাকতে পারে। ভরসা করার আগে উৎস যাচাই করুন।';

  @override
  String get earthTitle => 'পৃথিবীর জন্য শিক্ষা';

  @override
  String get earthDesc =>
      'কক্ষপথে আগুনের পরীক্ষা এখানকার ঘর, যানবাহন ও কর্মস্থলের অগ্নি-নিরাপত্তা নিয়ে কী শেখায়।';

  @override
  String get earthInOrbit => 'কক্ষপথে';

  @override
  String get earthOnEarth => 'পৃথিবীতে';

  @override
  String get earthPractice => 'বাস্তবে এর অর্থ কী';

  @override
  String get earthFooter =>
      'এগুলো গবেষণার সাধারণ ফলাফল, কোনো নির্দিষ্ট ভবনের নিরাপত্তা নিয়ম নয়। আপনার স্থানীয় ফায়ার সার্ভিসের নির্দেশনা মেনে চলুন।';

  @override
  String get earthEmptyTitle => 'শিক্ষাগুলো যাচাই করা হচ্ছে';

  @override
  String get earthEmptyBody =>
      'প্রতিটি শিক্ষা এখানে আসার আগে তার উৎসের সঙ্গে মিলিয়ে দেখা হয়।';

  @override
  String get methodsTitle => 'পদ্ধতি';

  @override
  String get methodsDesc =>
      'ডেটা কোথা থেকে আসে, পূর্বাভাস কীভাবে তৈরি হয়, কতটা ভালো কাজ করে, আর কোথায় থামে।';

  @override
  String get methodsToc => 'এই পেজে';

  @override
  String get methodsDataTitle => 'ডেটা কোথা থেকে আসে';

  @override
  String get methodsPredTitle => 'পূর্বাভাস কীভাবে কাজ করে';

  @override
  String get methodsValTitle => 'এটি কতটা ভালো কাজ করে';

  @override
  String get methodsPhysTitle => 'পদার্থবিজ্ঞান যাচাই';

  @override
  String get methodsSupportTitle => 'ডেটা সমর্থন ও বহির্বেশন';

  @override
  String get methodsLimitsTitle => 'সীমাবদ্ধতা';

  @override
  String get methodsUsabilityTitle => 'মানুষের সঙ্গে পরীক্ষিত';

  @override
  String get methodsHonestyTitle => 'FlameSense যা কখনো করবে না';

  @override
  String methodsDataBody(String runs, String experiments) {
    return 'FlameSense $experimentsটি এক্সপেরিমেন্টের $runsটি পরীক্ষা ব্যবহার করে। প্রতিটি পরীক্ষার উৎস ফাইল ও উল্লেখ সংরক্ষিত থাকে।';
  }

  @override
  String methodsBuild(String version, String date) {
    return 'ডেটা সংস্করণ $version, তৈরি $date।';
  }

  @override
  String get colSource => 'উৎস';

  @override
  String get colRuns => 'পরীক্ষা';

  @override
  String get colLink => 'লিংক';

  @override
  String get colFlag => 'মানের চিহ্ন';

  @override
  String get colMeaning => 'অর্থ';

  @override
  String get methodsNoSources => 'এখনো কোনো উৎস লোড হয়নি।';

  @override
  String get qualityOkDesc => 'সরাসরি NASA-র ডেটা ফাইল থেকে নেওয়া।';

  @override
  String get qualityEstimatedDesc =>
      'আনুমানিক মান দেওয়া উৎস থেকে পড়া বা রূপান্তর করা।';

  @override
  String get qualityDigitizedDesc =>
      'প্রকাশিত প্রতিবেদনের টেবিল বা চার্ট থেকে হাতে কপি করা।';

  @override
  String get qualityVideoDesc =>
      'FlameSense-এর ট্র্যাকার দিয়ে পরীক্ষার ভিডিও থেকে মাপা বিস্তারের হার।';

  @override
  String get qualitySuspectDesc =>
      'একটি ব্যতিক্রমী মান। এক্সপ্লোরে দেখানো হয় কিন্তু মডেল প্রশিক্ষণে ব্যবহার হয় না।';

  @override
  String get methodsPredBody =>
      'FlameSense NASA-র পরীক্ষা থেকে শেখে কোন অবস্থায় শিখা জ্বলতে থাকে এবং কত দ্রুত ছড়ায়। এটি গ্রেডিয়েন্ট-বুস্টেড ডিসিশন ট্রি (decision trees) ব্যবহার করে, যা পুরোপুরি আপনার ব্রাউজারে চলে। প্রতিটি পূর্বাভাসের সঙ্গে ডেটা সমর্থনের মাত্রা থাকে এবং পরীক্ষিত সীমার বাইরে গেলে সতর্কবার্তা।';

  @override
  String get methodsTwoModels =>
      'দুই ধরনের মডেল: একটি শিখা জ্বলতে থাকার সম্ভাবনা অনুমান করে; তিনটি ধীর, স্বাভাবিক ও দ্রুত বিস্তারের হার অনুমান করে (10ম, 50তম ও 90তম পার্সেন্টাইল)।';

  @override
  String get methodsOxygenConstraint =>
      'অক্সিজেনকে এমনভাবে সীমাবদ্ধ করা হয়েছে যাতে বেশি অক্সিজেন কখনো ঝুঁকি কমাতে না পারে, যা দহন বিজ্ঞানের সঙ্গে মেলে।';

  @override
  String get methodsOxygenPending =>
      'লিড চিহ্নটি নিশ্চিত না করা পর্যন্ত অক্সিজেনের সীমাবদ্ধতা বন্ধ আছে।';

  @override
  String get methodsFeatures => 'মডেল যে ইনপুট ব্যবহার করে';

  @override
  String methodsTaskUnavailable(String reason) {
    return 'প্রশিক্ষিত নয়: $reason';
  }

  @override
  String get methodsSustainModel => 'শিখা জ্বলতে থাকার সম্ভাবনা';

  @override
  String get methodsSpreadModel => 'আগুন ছড়ানোর হার';

  @override
  String get colMetric => 'পরিমাপ';

  @override
  String get colValue => 'মান';

  @override
  String get colPlain => 'সহজ ভাষায়';

  @override
  String get metricRows => 'ব্যবহৃত পরীক্ষা';

  @override
  String get metricGroups => 'স্বাধীন পরীক্ষার সিরিজ';

  @override
  String get metricCv => 'ক্রস-ভ্যালিডেশন';

  @override
  String get metricRocAuc => 'ROC-AUC';

  @override
  String get metricRocAucPlain =>
      'জ্বলাকে নিভে যাওয়ার ওপরে কতটা ঠিকভাবে সাজায়। 0.5 মানে টস, 1 মানে নিখুঁত।';

  @override
  String get metricBrier => 'ব্রায়ার স্কোর';

  @override
  String get metricBrierPlain => 'সম্ভাবনার গড় বর্গ ত্রুটি। কম হলে ভালো।';

  @override
  String get metricBaselineBrier => 'ভিত্তি ব্রায়ার স্কোর';

  @override
  String get metricBaselineBrierPlain =>
      'সবসময় গড় ফলাফল অনুমান করলে যে স্কোর হয়।';

  @override
  String get metricAccuracy => '50%-এ নির্ভুলতা';

  @override
  String get metricAccuracyPlain =>
      '50% সীমায় সঠিকভাবে শ্রেণিবদ্ধ পরীক্ষার অংশ।';

  @override
  String get metricMae => 'গড় পরম ত্রুটি';

  @override
  String get metricMaePlain =>
      'পূর্বাভাসিত ও মাপা বিস্তার হারের সাধারণ পার্থক্য।';

  @override
  String get metricBaselineMae => 'ভিত্তি ত্রুটি';

  @override
  String get metricBaselineMaePlain =>
      'সবসময় প্রশিক্ষণের সাধারণ মান অনুমান করলে যে ত্রুটি হয়।';

  @override
  String get metricMedianApe => 'মধ্যমা শতাংশ ত্রুটি';

  @override
  String get metricMedianApePlain => 'অর্ধেক পূর্বাভাস এর চেয়ে কাছাকাছি।';

  @override
  String get metricR2 => 'R² (লগ স্কেল)';

  @override
  String get metricR2Plain =>
      'ব্যাখ্যা করা পরিবর্তনের অংশ। 1 মানে নিখুঁত, 0 মানে গড়ের চেয়ে ভালো নয়।';

  @override
  String get metricCoverage => '80% পরিসরের আওতা';

  @override
  String get metricCoveragePlain =>
      'পূর্বাভাসিত 80% পরিসরের মধ্যে পড়া মাপা হারের অংশ। 80%-এর কাছাকাছি হলে সৎ।';

  @override
  String get metricPhysicsMae => 'পদার্থবিজ্ঞান যাচাইয়ের ত্রুটি';

  @override
  String get metricPhysicsMaePlain =>
      'যে পরীক্ষাগুলো এটি কভার করে সেগুলোতে পাতলা-জ্বালানি তত্ত্বের ত্রুটি।';

  @override
  String get methodsCalibration =>
      'পূর্বাভাসিত সম্ভাবনা বনাম আসলে জ্বলতে থাকার অংশ';

  @override
  String methodsCalibrationSemantics(String n) {
    return '$nটি ভাগসহ ক্যালিব্রেশন চার্ট। কর্ণের কাছে বিন্দু মানে সম্ভাবনাগুলো সৎ।';
  }

  @override
  String get axisPredicted => 'পূর্বাভাসিত সম্ভাবনা';

  @override
  String get axisObserved => 'পর্যবেক্ষিত অংশ';

  @override
  String get methodsCvNote =>
      'মডেল কখনো দেখেনি এমন পুরো পরীক্ষার সিরিজে যাচাই করা, তাই প্রায়-একই পরীক্ষার কারণে ফলাফল ফুলে ওঠে না।';

  @override
  String get methodsBaselineNote =>
      'প্রতিটি পরিমাপ মডেলহীন ভিত্তির পাশে দেখানো হয়েছে যাতে লাভটা বোঝা যায়।';

  @override
  String get methodsEq1 =>
      'পাতলা-জ্বালানির বিপরীতমুখী প্রবাহে বিস্তার (de Ris, 1969)';

  @override
  String get methodsEq2 => 'বৈশিষ্ট্যসূচক প্লবতাজনিত বেগ';

  @override
  String get methodsEq3 => 'ল্যাবে দেখানো কার্যকর বায়ুপ্রবাহ';

  @override
  String get colSymbol => 'প্রতীক';

  @override
  String get colParameter => 'প্যারামিটার';

  @override
  String get symVf => 'আগুন ছড়ানোর হার';

  @override
  String get symLambda => 'গ্যাসের তাপ পরিবাহিতা';

  @override
  String get symTf => 'শিখার তাপমাত্রা (অক্সিজেন থেকে)';

  @override
  String get symTv => 'জ্বালানির পাইরোলাইসিস তাপমাত্রা';

  @override
  String get symTinf => 'পারিপার্শ্বিক তাপমাত্রা';

  @override
  String get symRho => 'জ্বালানির ঘনত্ব';

  @override
  String get symCs => 'জ্বালানির আপেক্ষিক তাপ';

  @override
  String get symTau => 'জ্বালানির অর্ধ-পুরুত্ব';

  @override
  String get symUb => 'প্লবতাজনিত বেগ';

  @override
  String get symG => 'মাধ্যাকর্ষণ ত্বরণ';

  @override
  String get symAlpha => 'গ্যাসের তাপ বিস্তারণশীলতা';

  @override
  String get symUeff => 'কার্যকর বায়ুপ্রবাহ';

  @override
  String get methodsApplicability =>
      'যাচাইটি শুধু বিপরীতমুখী বায়ুপ্রবাহে (বা কক্ষপথে স্থির বাতাসে) পাতলা উপাদানের জন্য। এটি পুরু উপাদান, বিস্তারের একই দিকে বায়ুপ্রবাহ বা ফোঁটা কভার করে না।';

  @override
  String get methodsPhysLimit =>
      'পাতলা-জ্বালানির সূত্রটি সসীম-হারের রসায়ন ও বিকিরণ উপেক্ষা করে, তাই নিভে যাওয়ার কাছাকাছি (মাইক্রোগ্র্যাভিটিতে খুব কম বায়ুপ্রবাহ, বা কম অক্সিজেন) বিস্তার বেশি দেখায়। ডেটাভিত্তিক মডেল ওই অঞ্চল ডেটা থেকে শেখে।';

  @override
  String methodsSignedOff(String date) {
    return '$date তারিখে উল্লিখিত উৎসের সঙ্গে মিলিয়ে দেখা হয়েছে';
  }

  @override
  String get methodsPending => 'যাচাই বাকি';

  @override
  String get methodsParamsPending =>
      'উৎস ও যাচাই হলে প্যারামিটারের মান যোগ করা হবে।';

  @override
  String get methodsSupportBody =>
      'ডেটা সমর্থন ব্যাজ মাপে আপনার সেটিং বাস্তব NASA পরীক্ষার কতটা কাছে। বেশি মানে কাছাকাছি অনেক পরীক্ষা; মাঝারি মানে কিছু; কম মানে খুব কম বা নেই, তাই পূর্বাভাসটি বহির্বেশন। মানচিত্রে দাগকাটা ঘরে সমর্থন কম। পরীক্ষিত সীমার বাইরের সেটিংয়ে সবসময় সতর্কবার্তা দেখায়।';

  @override
  String limit1(String runs) {
    return 'ছোট ডেটাসেট: $runsটি পরীক্ষা। ডেটা যোগ হলে ফলাফল বদলাতে পারে।';
  }

  @override
  String get limit2 =>
      'একই সিরিজের পরীক্ষাগুলো একই যন্ত্র ও পদ্ধতি ব্যবহার করে, তাই পুরোপুরি স্বাধীন নয়।';

  @override
  String get limit3 =>
      'পরীক্ষিত সীমার বাইরে, এবং চাঁদ বা মঙ্গলের মাধ্যাকর্ষণে, পূর্বাভাসগুলো বহির্বেশন।';

  @override
  String get limit4 =>
      'পদার্থবিজ্ঞান যাচাই একটি সরলীকৃত তত্ত্ব এবং নিভে যাওয়ার কাছাকাছি খাটে না।';

  @override
  String get limit5 =>
      'বাস্তব ব্যবহারের জন্য নয়: FlameSense অগ্নি-নিরাপত্তা প্রকৌশলের বিকল্প নয়।';

  @override
  String get methodsUsabilityPending =>
      'ডেভেলপার নন এমন মানুষের সঙ্গে ব্যবহারযোগ্যতা পরীক্ষার পরে ফলাফল এখানে দেখা যাবে।';

  @override
  String methodsUsabilityIntro(String n) {
    return 'সফটওয়্যার তৈরি করেন না এমন $n জন এই কাজগুলো চেষ্টা করেছেন।';
  }

  @override
  String get colTask => 'কাজ';

  @override
  String get colCompleted => 'সম্পন্ন';

  @override
  String get colMedianTime => 'মধ্যমা সময়';

  @override
  String usabilityCompleted(String n, String total) {
    return '$total জনের মধ্যে $n জন';
  }

  @override
  String usabilityTime(String s) {
    return '$s সে.';
  }

  @override
  String get honesty1 =>
      'কৃত্রিম ডেটা নেই: প্রতিটি পরীক্ষা উল্লিখিত NASA বা প্রকাশিত উৎস থেকে।';

  @override
  String get honesty2 =>
      'লুকানো বহির্বেশন নেই: NASA-র পরীক্ষিত সীমার বাইরের পূর্বাভাস চিহ্নিত করা হয়।';

  @override
  String get honesty3 =>
      'নিরাপত্তা সনদের দাবি নেই: FlameSense একটি গবেষণা ও শিক্ষামূলক টুল।';

  @override
  String get aboutTitle => 'পরিচিতি';

  @override
  String get aboutDesc => 'FlameSense কী, কে তৈরি করেছে, এবং কীভাবে।';

  @override
  String get aboutWhatTitle => 'FlameSense কী';

  @override
  String get aboutWhatBody =>
      'FlameSense NASA-র মাইক্রোগ্র্যাভিটি দহন পরীক্ষাগুলোকে একটি এক্সপ্লোরার, সৎ পূর্বাভাস এবং পৃথিবীর নিরাপত্তার শিক্ষায় রূপ দেয়। এটি দেখায় কক্ষপথে, চাঁদে ও মঙ্গলে আগুন কেমন আচরণ করে, এবং কোথায় NASA-র এখনো ডেটা নেই।';

  @override
  String get aboutTeamTitle => 'দল';

  @override
  String get aboutTeamBody =>
      'রাজশাহীর দল FlameSense। এহসানুর কোড, ডেটা ও বিজ্ঞান যাচাইয়ের নেতৃত্ব দেন; দুইজন সদস্য নিবন্ধন, ভিডিও ও ব্যবহারযোগ্যতা পরীক্ষার নেতৃত্ব দেন।';

  @override
  String get aboutChallengeTitle => 'চ্যালেঞ্জ';

  @override
  String get aboutChallengeBody =>
      'NASA Space Apps Challenge 2026: Flame in Freefall';

  @override
  String get aboutOpenSourceTitle => 'ওপেন সোর্স';

  @override
  String get aboutOpenSourceBody => 'সব কোড Apache-2.0 লাইসেন্সে উন্মুক্ত।';

  @override
  String get aboutGithub => 'GitHub-এ কোড দেখুন';

  @override
  String get aboutAiTitle => 'AI ব্যবহার';

  @override
  String get aboutAiBody =>
      'একটি কোডিং এজেন্ট (Claude Code) লিডের পর্যালোচনায় কোড লিখেছে; প্রতিটি প্রম্পট AI_USAGE.md-তে তালিকাভুক্ত। প্রশ্ন পেজ শুধু খুঁজে পাওয়া NASA নথির ওপর Claude API ব্যবহার করে। পূর্বাভাস আসে NASA ডেটায় প্রশিক্ষিত LightGBM মডেল থেকে।';

  @override
  String get aboutLicensesTitle => 'লাইসেন্স ও কৃতজ্ঞতা';

  @override
  String get aboutLicenseCode => 'কোড: Apache-2.0।';

  @override
  String get aboutLicenseFonts =>
      'ফন্ট: Archivo ও Noto Sans Bengali, SIL Open Font License 1.1।';

  @override
  String aboutDataCredits(String sources) {
    return 'ডেটার কৃতজ্ঞতা: $sources';
  }

  @override
  String get aboutDataCreditsPending =>
      'ডেটা যোগ হলে প্রতিটি উৎসের কৃতজ্ঞতা দেখানো হবে।';

  @override
  String get aboutViewLicenses => 'সব লাইসেন্স দেখুন';

  @override
  String get aboutContactTitle => 'যোগাযোগ';

  @override
  String get aboutContactBody =>
      'ডেটার ভুল জানাতে বা প্রশ্ন করতে GitHub ব্যবহার করুন।';

  @override
  String get aboutContactButton => 'GitHub-এ একটি ইস্যু খুলুন';

  @override
  String aboutVersion(String version, String data, String date) {
    return 'সংস্করণ $version, ডেটা $data, তৈরি $date।';
  }

  @override
  String get aboutPrivacyTitle => 'গোপনীয়তা';

  @override
  String get aboutPrivacy =>
      'FlameSense কোনো ব্যক্তিগত তথ্য সংগ্রহ করে না এবং কোনো কুকি রাখে না। প্রশ্ন পেজে লেখা প্রশ্ন শুধু উত্তর তৈরির জন্য AI প্রদানকারীর কাছে পাঠানো হয়।';

  @override
  String get notFoundTitle => 'এই পেজটি ভেসে গেছে';

  @override
  String get notFoundBody => 'ঠিকানাটি ভুল লেখা হতে পারে, অথবা পেজটি সরে গেছে।';

  @override
  String get notFoundCta => 'হোমে যান';

  @override
  String tourStep(String n, String total) {
    return 'ধাপ $n/$total';
  }

  @override
  String get tour1Title => 'মাধ্যাকর্ষণ ছাড়া আগুনের আকার বদলায়';

  @override
  String get tour1Body =>
      'মাধ্যাকর্ষণ পৃথিবী থেকে কক্ষপথে টেনে আনুন। শিখা কমলা অশ্রুবিন্দু থেকে ধীর নীল গোলকে বদলে যায়।';

  @override
  String get tour2Title => 'একটি আগুন পরীক্ষা সাজান';

  @override
  String get tour2Body =>
      'NASA-র মহাকাশ স্টেশনের পরীক্ষার মতো একটি উপাদান বেছে নিন এবং অক্সিজেন, চাপ, বায়ুপ্রবাহ ও মাধ্যাকর্ষণ ঠিক করুন।';

  @override
  String get tour3Title => 'একটি সৎ পূর্বাভাস';

  @override
  String get tour3Body =>
      'মডেলটি শুধু NASA-র পরীক্ষায় প্রশিক্ষিত। ব্যাজটি দেখায় এই উত্তরের পেছনে কতটা বাস্তব ডেটা আছে।';

  @override
  String get tour4Title => 'শিখা কোথায় টিকে থাকে';

  @override
  String get tour4Body =>
      'উষ্ণ রং মানে জ্বলতে থাকে। দাগকাটা অংশে NASA-র ডেটা কম, চাঁদ ও মঙ্গলের মাধ্যাকর্ষণসহ।';

  @override
  String get tour5Title => 'চাঁদের আবাসের অগ্নি-নিরাপত্তা';

  @override
  String get tour5Body =>
      'NASA 34% অক্সিজেনসহ আবাসের পরিকল্পনা করছে। দেখুন সেখানে কোন উপাদান জ্বলতে পারে, এবং কোন পাঁচটি পরীক্ষা NASA-কে সবচেয়ে বেশি শেখাবে।';

  @override
  String get tour6Title => 'প্রতিটি সংখ্যার একটি উৎস আছে';

  @override
  String get tour6Body =>
      'যেকোনো পরীক্ষা খুলে দেখুন এটি কোন NASA ডেটাসেট বা প্রতিবেদন থেকে এসেছে।';

  @override
  String get tour7Title => 'NASA-র নথিকে প্রশ্ন করুন';

  @override
  String get tour7Body => 'উত্তরগুলো সঠিক নথি ও পৃষ্ঠা উল্লেখ করে।';

  @override
  String get tour8Title => 'পৃথিবীর জন্য শিক্ষা';

  @override
  String get tour8Body =>
      'মহাকাশের আগুন গবেষণা ঘর, যানবাহন ও কর্মস্থলের অগ্নি-নিরাপত্তায় কী অর্থ বহন করে।';

  @override
  String get missionsTitle => 'একটি মিশনের পরিকল্পনা করুন';

  @override
  String get missionsDesc =>
      'NASA-র পরবর্তী আবাসে আইএসএস-এর চেয়ে কম চাপ ও বেশি অক্সিজেন থাকতে পারে। একটি মিশন বেছে নিন এবং দেখুন সেখানে কোন উপাদান জ্বলতে পারে, আর কোথায় NASA-র এখনো ডেটা নেই।';

  @override
  String get missionIss => 'আন্তর্জাতিক মহাকাশ স্টেশন';

  @override
  String get missionLunar => 'আর্টেমিস চন্দ্র আবাস';

  @override
  String get missionMarsTransit => 'মঙ্গল যাত্রাপথ';

  @override
  String get missionMars => 'মঙ্গলপৃষ্ঠের আবাস';

  @override
  String get missionEarth => 'পৃথিবী (তুলনার জন্য)';

  @override
  String get missionIssNote => 'বর্তমান মহাকাশ স্টেশনের কেবিনের বায়ুমণ্ডল।';

  @override
  String get missionLunarNote => 'চাঁদের মাধ্যাকর্ষণে অনুসন্ধানী বায়ুমণ্ডল।';

  @override
  String get missionMarsTransitNote => 'ওজনহীন যাত্রায় অনুসন্ধানী বায়ুমণ্ডল।';

  @override
  String get missionMarsNote => 'মঙ্গলের মাধ্যাকর্ষণে অনুসন্ধানী বায়ুমণ্ডল।';

  @override
  String get missionEarthNote => 'তুলনার জন্য সমুদ্রপৃষ্ঠের বাতাস।';

  @override
  String missionAtmosphere(String pressure, String o2, String gravity) {
    return '$pressure kPa, $o2% অক্সিজেন, $gravity';
  }

  @override
  String get missionSource => 'উৎস';

  @override
  String get missionCountBurn => 'জ্বলার সম্ভাবনা';

  @override
  String get missionCountOut => 'নিভে যাওয়ার সম্ভাবনা';

  @override
  String get missionCountUnknown => 'অজানা';

  @override
  String get verdictBurns => 'জ্বলতে থাকার সম্ভাবনা';

  @override
  String get verdictOut => 'নিভে যাওয়ার সম্ভাবনা';

  @override
  String get verdictUnknown => 'অজানা, যথেষ্ট ডেটা নেই';

  @override
  String get verdictUncertain => 'অনিশ্চিত';

  @override
  String get missionMaterial => 'উপাদান';

  @override
  String get missionVerdict => 'রায়';

  @override
  String get missionWorstCase => 'সবচেয়ে খারাপ ক্ষেত্রে';

  @override
  String get missionWorstFlow => 'সবচেয়ে খারাপ ক্ষেত্রে বায়ুপ্রবাহ';

  @override
  String get missionSupport => 'ডেটা সমর্থন';

  @override
  String get missionMaterials => 'উপাদান';

  @override
  String get missionWorstCaseTip =>
      'এই মিশনের মাধ্যাকর্ষণ, চাপ ও অক্সিজেনে, ডেটার সব বায়ুপ্রবাহ গতির মধ্যে জ্বলার সর্বোচ্চ সম্ভাবনা।';

  @override
  String get missionNoMaterials => 'ডেটাসেটে এখনো কোনো উপাদান নেই।';

  @override
  String missionGap(String n, String gravity) {
    return 'এই ডেটাসেটে $gravity মাধ্যাকর্ষণে $nটি NASA পরীক্ষা আছে। এখানের রায়গুলো কক্ষপথ ও পৃথিবীর ডেটা থেকে বহির্বেশন।';
  }

  @override
  String get wishlistTitle => 'NASA-র পরবর্তী পরীক্ষা কোথায় হওয়া উচিত';

  @override
  String get wishlistCaption =>
      'একটি র‍্যাঙ্কিং সহায়িকা: যেখানে মডেল সবচেয়ে কম নিশ্চিত এবং কাছাকাছি কোনো NASA পরীক্ষা নেই। পরীক্ষা নকশা এখনো বিজ্ঞানীরাই করেন।';

  @override
  String wishlistReasonUnsure(String p) {
    return 'এখানে মডেল অনিশ্চিত (p ≈ $p)।';
  }

  @override
  String get wishlistReasonFar => 'এই অবস্থার কাছাকাছি কোনো NASA পরীক্ষা নেই।';

  @override
  String get wishlistReasonWide => 'বিস্তার-হারের পরিসর বড়।';

  @override
  String wishlistConditions(
    String o2,
    String pressure,
    String flow,
    String fuel,
  ) {
    return '$o2% O₂, $pressure kPa, $flow mm/s, $fuel';
  }

  @override
  String wishlistPlanned(String label, String pct) {
    return 'পরিকল্পিত NASA পরীক্ষা ($label) FlameSense-এর তালিকার শীর্ষ $pct%-এ আছে।';
  }

  @override
  String wishlistPlannedLegend(String label) {
    return 'পরিকল্পিত NASA পরীক্ষা ($label)';
  }

  @override
  String wishlistPin(String n) {
    return 'প্রস্তাবিত পরীক্ষা $n';
  }

  @override
  String get wishlistCsv => 'টেস্ট ম্যাট্রিক্স ডাউনলোড করুন (CSV)';

  @override
  String get wishlistCsvDone => 'টেস্ট ম্যাট্রিক্স ডাউনলোড হয়েছে';

  @override
  String get wishlistEmpty =>
      'তালিকার জন্য জ্বলার মডেল দরকার, যার এখনো যথেষ্ট ডেটা নেই।';

  @override
  String get briefButton => 'মিশন ফায়ার ব্রিফ ডাউনলোড করুন (PDF)';

  @override
  String get briefDone => 'ব্রিফ ডাউনলোড হয়েছে';

  @override
  String get missionsNotice =>
      'মিশনের বায়ুমণ্ডল NASA নথি থেকে নেওয়া। কেবিনের বায়ুপ্রবাহ বদলায় বলে FlameSense প্রতিটি উপাদান পরীক্ষিত সবচেয়ে খারাপ বায়ুপ্রবাহে যাচাই করে।';

  @override
  String get missionsEmptyTitle => 'মিশনের প্রিসেট যাচাই করা হচ্ছে';

  @override
  String get missionsEmptyBody =>
      'প্রতিটি মিশনের বায়ুমণ্ডল এখানে আসার আগে তার NASA উৎসের সঙ্গে মিলিয়ে দেখা হয়।';

  @override
  String get missionUnsourcedDebug =>
      'ডিবাগ বিল্ড: এই মিশনের উৎস নেই এবং রিলিজে লুকানো থাকে।';

  @override
  String get plannedFm2 => 'FM2';

  @override
  String briefTitle(String mission) {
    return 'মিশন ফায়ার ব্রিফ: $mission';
  }

  @override
  String briefSummary(String a, String b, String c) {
    return '$aটি উপাদান জ্বলতে থাকার সম্ভাবনা, $bটি নিভে যাওয়ার সম্ভাবনা, $cটি অজানা।';
  }

  @override
  String briefFooter(String url, String date) {
    return 'FlameSense ($url) দ্বারা $date তারিখে তৈরি। এটি কোনো সনদপ্রাপ্ত নিরাপত্তা মূল্যায়ন নয়।';
  }

  @override
  String get briefDataGap => 'ডেটার ঘাটতি';

  @override
  String get briefPlanned => 'পরিকল্পিত NASA পরীক্ষা';

  @override
  String get briefCitations => 'উৎসসমূহ';

  @override
  String get briefDisclaimerTitle => 'দায়মুক্তি';

  @override
  String get briefConditions => 'অবস্থা';

  @override
  String get briefReasons => 'এখানে কেন পরীক্ষা';
}
