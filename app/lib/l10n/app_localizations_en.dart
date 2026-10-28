// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'FlameSense';

  @override
  String get tagline => 'See how fire behaves where \"up\" doesn\'t exist.';

  @override
  String get navHome => 'Home';

  @override
  String get navMissions => 'Missions';

  @override
  String get navExplore => 'Explore';

  @override
  String get navLab => 'Fire Lab';

  @override
  String get navMap => 'Map';

  @override
  String get navAsk => 'Ask';

  @override
  String get navEarth => 'Earth lessons';

  @override
  String get navMethods => 'Methods';

  @override
  String get navAbout => 'About';

  @override
  String get navMore => 'More';

  @override
  String get takeTour => 'Take the tour';

  @override
  String get themeSystem => 'Use system theme';

  @override
  String get themeLight => 'Light theme';

  @override
  String get themeDark => 'Dark theme';

  @override
  String themeSwitchTo(String mode) {
    return 'Switch to $mode';
  }

  @override
  String get langEnglish => 'EN';

  @override
  String get langBangla => 'বাং';

  @override
  String get langLabel => 'Language';

  @override
  String get menuOptions => 'More options';

  @override
  String get disclaimer =>
      'FlameSense is a research and education tool. It is not a certified fire-safety system and must not be used for operational safety decisions.';

  @override
  String get notAffiliated =>
      'Not affiliated with or endorsed by NASA. Uses NASA open data.';

  @override
  String get credits =>
      'Data: NASA open data. Code: Apache-2.0. Built for NASA Space Apps Challenge 2026, Rajshahi.';

  @override
  String get loadingData => 'Loading NASA experiment data';

  @override
  String get loadErrorTitle => 'FlameSense couldn\'t load its data';

  @override
  String loadErrorBody(String file) {
    return 'The file $file is missing or damaged. Reload the page. If this keeps happening, the deployment is incomplete.';
  }

  @override
  String get reload => 'Reload';

  @override
  String get tryAgain => 'Try again';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get finish => 'Finish';

  @override
  String get exitTour => 'Exit tour';

  @override
  String get linkCopied => 'Link copied';

  @override
  String get csvDownloaded => 'CSV downloaded';

  @override
  String get answerCopied => 'Answer copied';

  @override
  String pageTitle(String page) {
    return '$page | FlameSense';
  }

  @override
  String get homePageTitle =>
      'FlameSense: fire safety insights from NASA\'s space-station fire experiments';

  @override
  String get valueYes => 'Yes';

  @override
  String get valueNo => 'No';

  @override
  String get notAvailable => '—';

  @override
  String get openInNewTab => 'Opens in a new tab';

  @override
  String get dismiss => 'Dismiss';

  @override
  String get info => 'More information';

  @override
  String get gEarth => 'Earth';

  @override
  String get gMars => 'Mars';

  @override
  String get gMoon => 'Moon';

  @override
  String get gIss => 'ISS orbit';

  @override
  String get gCustom => 'Custom';

  @override
  String gravityValue(String label, String value) {
    return '$label ($value g)';
  }

  @override
  String get gravityClassMicro => 'Microgravity';

  @override
  String get gravityClassPartial => 'Moon or Mars';

  @override
  String get gravityClassEarth => 'Earth';

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
  String get unitSeconds => 's';

  @override
  String get unitWmK => 'W/m·K';

  @override
  String get unitM2S => 'm²/s';

  @override
  String get unitK => 'K';

  @override
  String get unitJkgK => 'J/kg·K';

  @override
  String get unitM => 'm';

  @override
  String get unitMS => 'm/s';

  @override
  String get unitMs2 => 'm/s²';

  @override
  String get colUnit => 'Unit';

  @override
  String get methodsTocLabel => 'Jump to section';

  @override
  String get featO2 => 'Oxygen';

  @override
  String get featPressure => 'Pressure';

  @override
  String get featFlow => 'Airflow';

  @override
  String get featGravity => 'Gravity';

  @override
  String get featThickness => 'Thickness';

  @override
  String get featDensity => 'Density';

  @override
  String get featFuelClass => 'Material type';

  @override
  String get featFlowDir => 'Airflow direction';

  @override
  String get featDiluent => 'Diluent gas';

  @override
  String get featO2Partial => 'Oxygen partial pressure';

  @override
  String get featLogFlow => 'Airflow (log scale)';

  @override
  String get featLogGravity => 'Gravity (log scale)';

  @override
  String get featArealDensity => 'Areal density';

  @override
  String get fuelThinSolid => 'Thin solid';

  @override
  String get fuelThickSolid => 'Thick solid';

  @override
  String get fuelDroplet => 'Fuel droplet';

  @override
  String get fuelGasJet => 'Gas jet';

  @override
  String get fuelOther => 'Other';

  @override
  String get dirOpposed => 'Opposed';

  @override
  String get dirConcurrent => 'Concurrent';

  @override
  String get dirQuiescent => 'None';

  @override
  String get dirOther => 'Other';

  @override
  String get diluentN2 => 'Nitrogen';

  @override
  String get diluentHe => 'Helium';

  @override
  String get diluentCo2 => 'Carbon dioxide';

  @override
  String get diluentOther => 'Other';

  @override
  String get platformIss => 'ISS';

  @override
  String get platformFreeFlyer => 'Free flyer';

  @override
  String get platformDropTower => 'Drop tower';

  @override
  String get platformParabolic => 'Parabolic flight';

  @override
  String get platformGround => 'Ground';

  @override
  String get qualityOk => 'Measured';

  @override
  String get qualityEstimated => 'Estimated';

  @override
  String get qualityDigitized => 'Digitized';

  @override
  String get qualityVideoDerived => 'Video-derived';

  @override
  String get qualitySuspect => 'Flagged';

  @override
  String get supportHigh => 'Data support: high';

  @override
  String get supportMedium => 'Data support: medium';

  @override
  String get supportLow => 'Data support: low';

  @override
  String get supportHighTip =>
      'Many NASA test runs were done near these conditions.';

  @override
  String get supportMediumTip =>
      'Some NASA test runs are near these conditions. Treat the prediction as approximate.';

  @override
  String get supportLowTip =>
      'Few or no NASA test runs are near these conditions. This is an extrapolation.';

  @override
  String get supportShortHigh => 'high';

  @override
  String get supportShortMedium => 'med';

  @override
  String get supportShortLow => 'low';

  @override
  String askErrRate(String minutes) {
    return 'Too many questions in a short time. Try again in $minutes min.';
  }

  @override
  String get askErrUpstream =>
      'The answer service didn\'t respond. Try again, or pick a suggested question; those answers are saved.';

  @override
  String get askErrOffline =>
      'You\'re offline. Suggested questions still work.';

  @override
  String get askErrInvalid => 'Write a question between 3 and 500 characters.';

  @override
  String get askErrServer =>
      'Something went wrong on the server. Try again in a minute.';

  @override
  String numErrRange(String min, String max) {
    return 'Enter a number between $min and $max.';
  }

  @override
  String noticeOutside(String feature, String min, String max, String unit) {
    return '$feature is outside the range NASA tested ($min–$max $unit). The prediction is an extrapolation.';
  }

  @override
  String get noticeLowSupport =>
      'Few NASA test runs are near these conditions. Use this as a rough estimate.';

  @override
  String get noticePartialG =>
      'NASA has little or no fire data at Moon or Mars gravity. Predictions here are extrapolations between Earth and orbit. This is a real research gap.';

  @override
  String noticeUnavailable(String output) {
    return 'There isn\'t enough NASA data to predict $output reliably, so FlameSense doesn\'t show one.';
  }

  @override
  String get noticeOneExperiment =>
      'All runs come from one experiment, so comparisons across experiments aren\'t possible yet.';

  @override
  String get noticeQuantiles =>
      'The three spread-rate models crossed, so their values were put back in order.';

  @override
  String get outputSustain => 'the chance a flame keeps burning';

  @override
  String get outputSpread => 'the flame spread rate';

  @override
  String mapGapNotice(String body, String n) {
    return 'No NASA fire tests at $body gravity are in this dataset ($n runs). The colors here are extrapolated, which is why most of the map is hatched. Filling this gap matters for Artemis and future Mars missions.';
  }

  @override
  String get physicsNotApplicable =>
      'The physics check covers thin materials in opposing airflow. These conditions are outside it.';

  @override
  String get physicsNearExt =>
      'Near extinction the simple theory over-predicts spread. Trust the data-driven prediction more here.';

  @override
  String get physicsUnavailable =>
      'The physics check is switched off until its parameters are verified.';

  @override
  String get homeHeadline => 'Fire has no \"up\" in space.';

  @override
  String get homeSubhead =>
      'On Earth, rising hot air stretches a flame into a teardrop. On the space station nothing rises, so flames turn round, blue and slow. FlameSense turns NASA\'s space-station fire experiments into predictions you can explore.';

  @override
  String get homeCtaLab => 'Open the Fire Lab';

  @override
  String homeDataSentence(String runs, String experiments, String fuels) {
    return 'Built on $runs test runs from $experiments NASA experiments across $fuels materials.';
  }

  @override
  String get homeDataPending =>
      'NASA test runs are being added to the dataset. Predictions appear once enough runs are in.';

  @override
  String get homeEarthFlame => 'Earth';

  @override
  String get homeYourGravity => 'Your gravity';

  @override
  String get homeBuoyantFlow => 'Buoyant airflow';

  @override
  String get homePredictedSpread => 'Predicted spread';

  @override
  String get homeNextTitle => 'Where to go next';

  @override
  String get homeNextMissions => 'Plan for a mission';

  @override
  String get homeNextMissionsDesc =>
      'Which materials could burn in a Moon habitat';

  @override
  String get homeNextExplore => 'Explore the experiments';

  @override
  String get homeNextExploreDesc =>
      'Every run, filterable, with its NASA source';

  @override
  String get homeNextMap => 'See the flammability map';

  @override
  String get homeNextMapDesc => 'Where flames survive, by oxygen and airflow';

  @override
  String get homeNextAsk => 'Ask the NASA papers';

  @override
  String get homeNextAskDesc => 'Answers with citations';

  @override
  String get homeNextEarth => 'Lessons for Earth';

  @override
  String get homeNextEarthDesc => 'What space fires teach us about safety here';

  @override
  String flameSemantics(String label, String shape) {
    return 'Flame at $label. $shape';
  }

  @override
  String get flameShapeEarth =>
      'An orange teardrop stretched upward by rising hot air.';

  @override
  String get flameShapeSpace =>
      'A dim blue sphere: nothing rises without gravity.';

  @override
  String get flameShapeMid =>
      'Rounder and bluer than on Earth, with weaker buoyancy.';

  @override
  String get exploreTitle => 'Explore the experiments';

  @override
  String get exploreDesc =>
      'Every NASA test run FlameSense uses, in one table. Each row links to its source.';

  @override
  String get filterExperiment => 'Experiment';

  @override
  String get filterPlatform => 'Platform';

  @override
  String get filterFuelClass => 'Material type';

  @override
  String get filterGravity => 'Gravity';

  @override
  String get filterO2 => 'Oxygen range';

  @override
  String get filterPressure => 'Pressure range';

  @override
  String get filterQuality => 'Quality';

  @override
  String get qualityIncEstimated => 'Include estimated';

  @override
  String get qualityIncDigitized => 'Include digitized';

  @override
  String get qualityIncVideo => 'Include video-derived';

  @override
  String get qualityIncFlagged => 'Include flagged';

  @override
  String get filterAll => 'All';

  @override
  String get filtersButton => 'Filters';

  @override
  String get filterApply => 'Apply';

  @override
  String filterRangeValue(String min, String max, String unit) {
    return '$min–$max $unit';
  }

  @override
  String exploreShowing(String shown, String total) {
    return 'Showing $shown of $total runs';
  }

  @override
  String get exploreClear => 'Clear filters';

  @override
  String get exploreDownload => 'Download CSV';

  @override
  String get exploreTabSpread => 'Spread vs oxygen';

  @override
  String get exploreTabBurning => 'Burning vs airflow';

  @override
  String get exploreTabRuns => 'Runs per experiment';

  @override
  String get exploreEmptyTitle => 'No runs match these filters';

  @override
  String get exploreEmptyBody =>
      'Widen the oxygen or pressure range, or include more experiments.';

  @override
  String get exploreNoDataTitle => 'No NASA runs loaded yet';

  @override
  String get exploreNoDataBody =>
      'Runs appear here once their NASA source files are added to the dataset.';

  @override
  String get chartNoPoints => 'No runs with these values to plot.';

  @override
  String get colRun => 'Run';

  @override
  String get colExperiment => 'Experiment';

  @override
  String get colFuel => 'Fuel';

  @override
  String get colO2 => 'O₂ (%)';

  @override
  String get colPressure => 'Pressure (kPa)';

  @override
  String get colFlow => 'Airflow (mm/s)';

  @override
  String get colGravity => 'Gravity (g)';

  @override
  String get colOutcome => 'Outcome';

  @override
  String get colSpread => 'Spread (mm/s)';

  @override
  String get colQuality => 'Quality';

  @override
  String sortBy(String column) {
    return 'Sort by $column';
  }

  @override
  String get axisO2 => 'Oxygen (%)';

  @override
  String get axisSpread => 'Spread rate (mm/s, log scale)';

  @override
  String get axisFlow => 'Airflow (mm/s, log scale)';

  @override
  String get axisRuns => 'Runs';

  @override
  String chartSpreadSummary(String n) {
    return 'Scatter of $n runs: flame spread rate against oxygen, colored by gravity class.';
  }

  @override
  String chartBurningSummary(String n, String kept, String out) {
    return 'Strip chart of $n runs against airflow: $kept kept burning, $out went out.';
  }

  @override
  String chartRunsSummary(String n, String experiments) {
    return 'Bar chart of $n runs across $experiments experiments.';
  }

  @override
  String runTitle(String id) {
    return 'Run $id';
  }

  @override
  String get runKeptBurning => 'Kept burning';

  @override
  String get runWentOut => 'Went out';

  @override
  String get runNoIgnition => 'Did not ignite';

  @override
  String get runUnknownOutcome => 'Outcome not recorded';

  @override
  String get runOpenSource => 'Open source';

  @override
  String get runLoadLab => 'Load these conditions in the Fire Lab';

  @override
  String get runSource => 'Source';

  @override
  String get fieldGroup => 'Test series';

  @override
  String get fieldExperiment => 'Experiment';

  @override
  String get fieldPlatform => 'Platform';

  @override
  String get fieldGravity => 'Gravity';

  @override
  String get fieldFuelName => 'Material';

  @override
  String get fieldFuelClass => 'Material type';

  @override
  String get fieldThickness => 'Thickness';

  @override
  String get fieldDensity => 'Density';

  @override
  String get fieldO2 => 'Oxygen';

  @override
  String get fieldPressure => 'Pressure';

  @override
  String get fieldDiluent => 'Diluent gas';

  @override
  String get fieldFlow => 'Airflow';

  @override
  String get fieldFlowDir => 'Airflow direction';

  @override
  String get fieldIgnited => 'Ignited';

  @override
  String get fieldSustained => 'Kept burning';

  @override
  String get fieldSpread => 'Flame spread rate';

  @override
  String get fieldBurningRate => 'Burning-rate constant';

  @override
  String get fieldExtinction => 'Extinction reason';

  @override
  String get fieldSourceFile => 'Source file';

  @override
  String get fieldQuality => 'Quality';

  @override
  String get fieldNotes => 'Notes';

  @override
  String get labTitle => 'Fire Lab';

  @override
  String get labDesc =>
      'Set the conditions of a fire test and see what NASA\'s data predicts.';

  @override
  String get labConditions => 'Conditions';

  @override
  String get labPrediction => 'Prediction';

  @override
  String get labMaterial => 'Material';

  @override
  String get labMaterialCustom => 'Custom';

  @override
  String labMaterialSummary(String fuelClass, String thickness) {
    return '$fuelClass, $thickness mm';
  }

  @override
  String get labMarkerSeaLevel => 'Sea level 101.3 kPa';

  @override
  String get labMarkerEarthAir => 'Earth air 21%';

  @override
  String get labReset => 'Reset to defaults';

  @override
  String get labCopyLink => 'Copy link to this setup';

  @override
  String get labCompare => 'Compare with Earth';

  @override
  String get labGaugeCaption => 'chance the flame keeps burning';

  @override
  String get labGoesOut => 'Goes out';

  @override
  String get labKeepsBurning => 'Keeps burning';

  @override
  String get labGaugeUnavailable => 'Not enough data to predict this';

  @override
  String labGaugeSemantics(String pct) {
    return 'Chance the flame keeps burning: $pct percent.';
  }

  @override
  String get labChanceLabel => 'Chance it keeps burning';

  @override
  String get labSpreadTitle => 'Flame spread rate';

  @override
  String labRange80(String low, String high) {
    return '80% range: $low to $high mm/s';
  }

  @override
  String labSpreadSemantics(String mid, String low, String high) {
    return 'Flame spread rate $mid millimetres per second, 80% range $low to $high.';
  }

  @override
  String get labEffectiveFlow => 'Effective airflow';

  @override
  String labEffectiveFlowCaption(String forced, String buoyant) {
    return '(forced $forced + buoyant $buoyant)';
  }

  @override
  String get labEffectiveFlowForcedOnly =>
      '(forced airflow only; the buoyant part needs the physics check)';

  @override
  String get labSensTitle => 'What moves the risk';

  @override
  String get labSensCaption =>
      'Each row nudges one setting by 10% of its range and keeps the rest fixed.';

  @override
  String labSensRow(String feature, String delta, String change) {
    return 'Raising $feature by $delta: $change';
  }

  @override
  String labSensPoints(String value) {
    return '$value points';
  }

  @override
  String labSensMmS(String value) {
    return '$value mm/s';
  }

  @override
  String get labSensEmpty =>
      'Sensitivity appears once a prediction is available.';

  @override
  String get labPhysicsTitle => 'Physics check';

  @override
  String get labPhysicsPredicts => 'Thin-fuel theory predicts';

  @override
  String labPhysicsLower(String pct) {
    return 'ML prediction is $pct% lower, as expected near extinction, where the simple theory over-predicts.';
  }

  @override
  String labPhysicsHigher(String pct) {
    return 'ML prediction is $pct% higher than the simple theory.';
  }

  @override
  String get labPhysicsSeeEquation => 'See the equation';

  @override
  String get labCompareYourG => 'At your gravity';

  @override
  String get labCompareEarth => 'On Earth (1 g)';

  @override
  String labDeltaMore(String n) {
    return '$n points more likely to keep burning on Earth';
  }

  @override
  String labDeltaLess(String n) {
    return '$n points less likely to keep burning on Earth';
  }

  @override
  String get labDeltaSame => 'Equally likely to keep burning on Earth';

  @override
  String labDeltaFaster(String ratio) {
    return '×$ratio faster on Earth';
  }

  @override
  String labDeltaSlower(String ratio) {
    return '×$ratio slower on Earth';
  }

  @override
  String labSticky(String pct, String spread) {
    return '$pct% keeps burning, $spread mm/s';
  }

  @override
  String labStickyNoSpread(String pct) {
    return '$pct% keeps burning';
  }

  @override
  String sliderSemantics(String value, String unit) {
    return '$value $unit';
  }

  @override
  String sliderPercentSemantics(String value) {
    return '$value percent';
  }

  @override
  String numberFieldLabel(String feature) {
    return '$feature value';
  }

  @override
  String get mapTitle => 'Flammability map';

  @override
  String get mapDesc =>
      'How likely a flame is to keep burning across oxygen levels and airflow speeds.';

  @override
  String get mapLegendLow => 'Likely to go out';

  @override
  String get mapLegendHigh => 'Likely to keep burning';

  @override
  String get mapHatch => 'Little or no NASA data here';

  @override
  String get mapOpenLab => 'Open in Fire Lab';

  @override
  String get mapOverlays => 'Overlays';

  @override
  String get mapOverlayRuns => 'NASA runs';

  @override
  String get mapOverlayContour => '50% line';

  @override
  String get mapContourLabel => '50%';

  @override
  String get mapInspectorHint => 'Hover a cell';

  @override
  String get mapInspectorTapHint => 'Tap a cell';

  @override
  String mapCellProb(String pct) {
    return '$pct% keeps burning';
  }

  @override
  String get mapPinned => 'Pinned';

  @override
  String get mapKeptBurning => 'kept burning';

  @override
  String get mapWentOut => 'went out';

  @override
  String get mapSettings => 'Map settings';

  @override
  String mapPressureValue(String value) {
    return 'Pressure $value kPa';
  }

  @override
  String mapGravityValue(String label) {
    return 'Gravity: $label';
  }

  @override
  String get mapEmptyTitle => 'Not enough data to draw the map';

  @override
  String get mapEmptyBody =>
      'FlameSense needs at least 40 NASA runs with a known outcome. You can still see every run that exists.';

  @override
  String get mapEmptyCta => 'Show the runs in Explore';

  @override
  String mapSemantics(
    String o2min,
    String o2max,
    String fmin,
    String fmax,
    String low,
    String total,
  ) {
    return 'Heatmap of the chance a flame keeps burning, oxygen $o2min to $o2max percent against airflow $fmin to $fmax mm/s. $low of $total cells have little NASA data.';
  }

  @override
  String get askTitle => 'Ask the NASA papers';

  @override
  String get askDesc =>
      'Answers come only from the NASA documents FlameSense has read. Every sentence cites its source.';

  @override
  String get askSuggested => 'Suggested questions';

  @override
  String get askQ1 => 'Why are flames round in microgravity?';

  @override
  String get askQ2 => 'Can a material burn in space but not on Earth?';

  @override
  String get askQ3 => 'What did NASA\'s Saffire experiments test?';

  @override
  String get askQ4 => 'How does airflow affect flame spread in microgravity?';

  @override
  String get askQ5 => 'Why are flames in space blue?';

  @override
  String get askQ6 => 'How is spacecraft material flammability tested?';

  @override
  String get askPlaceholder => 'Ask about fire in microgravity';

  @override
  String get askInputLabel => 'Your question';

  @override
  String get askButton => 'Ask';

  @override
  String askCounter(String n) {
    return '$n / 500';
  }

  @override
  String get askGrounded => 'Answered from NASA sources';

  @override
  String get askNotGrounded => 'Not found in FlameSense\'s NASA sources';

  @override
  String get askSaved => 'Saved answer';

  @override
  String get askSearching => 'Searching NASA documents';

  @override
  String get askCopy => 'Copy answer';

  @override
  String get askOpenDoc => 'Open document';

  @override
  String get askSources => 'Sources';

  @override
  String askPage(String n) {
    return 'Page $n';
  }

  @override
  String get askEarlier => 'Earlier questions';

  @override
  String get askRelated => 'Try a related question';

  @override
  String askCitationTip(String title, String page) {
    return '$title, page $page';
  }

  @override
  String askCitationSemantics(String n) {
    return 'Source $n';
  }

  @override
  String get askFootnote =>
      'Answers are generated by an AI model from the cited documents and can contain mistakes. Check the source before relying on it.';

  @override
  String get earthTitle => 'Lessons for Earth';

  @override
  String get earthDesc =>
      'What fire experiments in orbit teach us about fire safety in rooms, vehicles and workplaces here.';

  @override
  String get earthInOrbit => 'In orbit';

  @override
  String get earthOnEarth => 'On Earth';

  @override
  String get earthPractice => 'What this means in practice';

  @override
  String get earthFooter =>
      'These are general findings from research, not safety rules for a specific building. Follow your local fire service\'s guidance.';

  @override
  String get earthEmptyTitle => 'Lessons are being reviewed';

  @override
  String get earthEmptyBody =>
      'Each lesson is checked against its sources before it appears here.';

  @override
  String get methodsTitle => 'Methods';

  @override
  String get methodsDesc =>
      'Where the data comes from, how predictions are made, how well they work, and where they stop.';

  @override
  String get methodsToc => 'On this page';

  @override
  String get methodsDataTitle => 'Where the data comes from';

  @override
  String get methodsPredTitle => 'How predictions work';

  @override
  String get methodsValTitle => 'How well it works';

  @override
  String get methodsPhysTitle => 'Physics check';

  @override
  String get methodsSupportTitle => 'Data support and extrapolation';

  @override
  String get methodsLimitsTitle => 'Limitations';

  @override
  String get methodsUsabilityTitle => 'Tested with people';

  @override
  String get methodsHonestyTitle => 'What FlameSense will never do';

  @override
  String methodsDataBody(String runs, String experiments) {
    return 'FlameSense uses $runs test runs from $experiments experiments. Every run keeps its source file and citation.';
  }

  @override
  String methodsBuild(String version, String date) {
    return 'Data version $version, built $date.';
  }

  @override
  String get colSource => 'Source';

  @override
  String get colRuns => 'Runs';

  @override
  String get colLink => 'Link';

  @override
  String get colFlag => 'Quality flag';

  @override
  String get colMeaning => 'Meaning';

  @override
  String get methodsNoSources => 'No sources are loaded yet.';

  @override
  String get qualityOkDesc => 'Taken directly from a NASA data file.';

  @override
  String get qualityEstimatedDesc =>
      'Read or converted from a source that gives an approximate value.';

  @override
  String get qualityDigitizedDesc =>
      'Copied by hand from a table or chart in a published report.';

  @override
  String get qualityVideoDesc =>
      'Spread rate measured from experiment video by FlameSense\'s tracker.';

  @override
  String get qualitySuspectDesc =>
      'An outlier. Shown in Explore but not used to train the models.';

  @override
  String get methodsPredBody =>
      'FlameSense learns from NASA test runs which conditions let a flame keep burning and how fast it spreads. It uses gradient-boosted decision trees, which run entirely in your browser. Every prediction comes with a data-support level and warnings when it leaves the tested range.';

  @override
  String get methodsTwoModels =>
      'Two models: one estimates the chance a flame keeps burning; three estimate the slow, typical and fast spread rate (10th, 50th and 90th percentiles).';

  @override
  String get methodsOxygenConstraint =>
      'Oxygen is constrained so that more oxygen can never lower the risk, matching combustion science.';

  @override
  String get methodsOxygenPending =>
      'The oxygen constraint is switched off until the lead confirms its sign.';

  @override
  String get methodsFeatures => 'Inputs the models use';

  @override
  String methodsTaskUnavailable(String reason) {
    return 'Not trained: $reason';
  }

  @override
  String get methodsSustainModel => 'Chance a flame keeps burning';

  @override
  String get methodsSpreadModel => 'Flame spread rate';

  @override
  String get colMetric => 'Metric';

  @override
  String get colValue => 'Value';

  @override
  String get colPlain => 'In plain words';

  @override
  String get metricRows => 'Runs used';

  @override
  String get metricGroups => 'Independent test series';

  @override
  String get metricCv => 'Cross-validation';

  @override
  String get metricRocAuc => 'ROC-AUC';

  @override
  String get metricRocAucPlain =>
      'How well it ranks burning above going out. 0.5 is a coin flip, 1 is perfect.';

  @override
  String get metricBrier => 'Brier score';

  @override
  String get metricBrierPlain =>
      'Average squared error of the probability. Lower is better.';

  @override
  String get metricBaselineBrier => 'Baseline Brier score';

  @override
  String get metricBaselineBrierPlain =>
      'The score from always guessing the average outcome.';

  @override
  String get metricAccuracy => 'Accuracy at 50%';

  @override
  String get metricAccuracyPlain =>
      'Share of runs classified correctly when the cut-off is 50%.';

  @override
  String get metricMae => 'Mean absolute error';

  @override
  String get metricMaePlain =>
      'Typical difference between predicted and measured spread rate.';

  @override
  String get metricBaselineMae => 'Baseline error';

  @override
  String get metricBaselineMaePlain =>
      'The error from always predicting the typical training value.';

  @override
  String get metricMedianApe => 'Median percentage error';

  @override
  String get metricMedianApePlain =>
      'Half of the predictions are closer than this.';

  @override
  String get metricR2 => 'R² (log scale)';

  @override
  String get metricR2Plain =>
      'Share of the variation explained. 1 is perfect, 0 is no better than the average.';

  @override
  String get metricCoverage => '80% range coverage';

  @override
  String get metricCoveragePlain =>
      'Share of measured rates inside the predicted 80% range. Near 80% is honest.';

  @override
  String get metricPhysicsMae => 'Physics check error';

  @override
  String get metricPhysicsMaePlain =>
      'Error of the thin-fuel theory on the runs it covers.';

  @override
  String get methodsCalibration =>
      'Predicted chance against the observed share that kept burning';

  @override
  String methodsCalibrationSemantics(String n) {
    return 'Calibration chart with $n bins. Points near the diagonal mean the probabilities are honest.';
  }

  @override
  String get axisPredicted => 'Predicted probability';

  @override
  String get axisObserved => 'Observed share';

  @override
  String get methodsCvNote =>
      'Tested on whole test series the model never saw, so results aren\'t inflated by near-duplicate runs.';

  @override
  String get methodsBaselineNote =>
      'Each metric is shown next to a no-model baseline so you can see the gain.';

  @override
  String get methodsEq1 => 'Thin-fuel opposed-flow spread (de Ris, 1969)';

  @override
  String get methodsEq2 => 'Characteristic buoyant velocity';

  @override
  String get methodsEq3 => 'Effective airflow shown in the Lab';

  @override
  String get colSymbol => 'Symbol';

  @override
  String get colParameter => 'Parameter';

  @override
  String get symVf => 'Flame spread rate';

  @override
  String get symLambda => 'Gas thermal conductivity';

  @override
  String get symTf => 'Flame temperature (from oxygen)';

  @override
  String get symTv => 'Pyrolysis temperature of the fuel';

  @override
  String get symTinf => 'Ambient temperature';

  @override
  String get symRho => 'Fuel density';

  @override
  String get symCs => 'Fuel specific heat';

  @override
  String get symTau => 'Fuel half-thickness';

  @override
  String get symUb => 'Buoyant velocity';

  @override
  String get symG => 'Gravitational acceleration';

  @override
  String get symAlpha => 'Gas thermal diffusivity';

  @override
  String get symUeff => 'Effective airflow';

  @override
  String get methodsApplicability =>
      'The check applies only to thin materials in opposing airflow (or still air in orbit). It does not cover thick materials, airflow in the same direction as the spread, or droplets.';

  @override
  String get methodsPhysLimit =>
      'The thin-fuel formula ignores finite-rate chemistry and radiation, so it over-predicts spread near extinction (very low airflow in microgravity, or low oxygen). The data-driven model learns that region from data.';

  @override
  String methodsSignedOff(String date) {
    return 'Checked against the cited sources on $date';
  }

  @override
  String get methodsPending => 'Pending verification';

  @override
  String get methodsParamsPending =>
      'Parameter values are added once they are sourced and verified.';

  @override
  String get methodsSupportBody =>
      'The data-support badge measures how close your settings are to real NASA runs. High means many runs nearby; medium means some; low means few or none, so the prediction is an extrapolation. On the map, hatched cells have low support. Settings outside the tested range always show a warning.';

  @override
  String limit1(String runs) {
    return 'Small dataset: $runs runs. Results can change as data is added.';
  }

  @override
  String get limit2 =>
      'Runs from one test series share hardware and procedures, so they are not fully independent.';

  @override
  String get limit3 =>
      'Outside the tested ranges, and at Moon or Mars gravity, predictions are extrapolations.';

  @override
  String get limit4 =>
      'The physics check is a simplified theory and does not hold near extinction.';

  @override
  String get limit5 =>
      'Not for operational use: FlameSense does not replace fire safety engineering.';

  @override
  String get methodsUsabilityPending =>
      'Results appear here after the usability test sessions with non-developers.';

  @override
  String methodsUsabilityIntro(String n) {
    return '$n people who don\'t build software tried these tasks.';
  }

  @override
  String get colTask => 'Task';

  @override
  String get colCompleted => 'Completed';

  @override
  String get colMedianTime => 'Median time';

  @override
  String usabilityCompleted(String n, String total) {
    return '$n of $total';
  }

  @override
  String usabilityTime(String s) {
    return '$s s';
  }

  @override
  String get honesty1 =>
      'No synthetic data: every run comes from a cited NASA or published source.';

  @override
  String get honesty2 =>
      'No hidden extrapolation: predictions outside NASA\'s tested range are flagged.';

  @override
  String get honesty3 =>
      'No safety certification claims: FlameSense is a research and education tool.';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutDesc => 'What FlameSense is, who built it, and how.';

  @override
  String get aboutWhatTitle => 'What FlameSense is';

  @override
  String get aboutWhatBody =>
      'FlameSense turns NASA\'s microgravity combustion experiments into an explorer, honest predictions and lessons for safety on Earth. It shows how fire behaves in orbit, on the Moon and on Mars, and where NASA has no data yet.';

  @override
  String get aboutTeamTitle => 'Team';

  @override
  String get aboutTeamBody =>
      'Team FlameSense from Rajshahi. Ehsanur leads code, data and science checks; two team members lead registrations, videos and usability testing.';

  @override
  String get aboutChallengeTitle => 'Challenge';

  @override
  String get aboutChallengeBody =>
      'NASA Space Apps Challenge 2026: Flame in Freefall';

  @override
  String get aboutOpenSourceTitle => 'Open source';

  @override
  String get aboutOpenSourceBody =>
      'All code is public under the Apache-2.0 license.';

  @override
  String get aboutGithub => 'View the code on GitHub';

  @override
  String get aboutAiTitle => 'AI use';

  @override
  String get aboutAiBody =>
      'A coding agent (Claude Code) wrote the code under the lead\'s review; every prompt is listed in AI_USAGE.md. The Ask page uses the Claude API only over retrieved NASA documents. Predictions come from LightGBM models trained on NASA data. No images or voices in the app are AI-generated.';

  @override
  String get aboutLicensesTitle => 'Licenses and credits';

  @override
  String get aboutLicenseCode => 'Code: Apache-2.0.';

  @override
  String get aboutLicenseFonts =>
      'Fonts: Archivo and Noto Sans Bengali, SIL Open Font License 1.1.';

  @override
  String aboutDataCredits(String sources) {
    return 'Data credits: $sources';
  }

  @override
  String get aboutDataCreditsPending =>
      'Data credits are listed per source once data is added.';

  @override
  String get aboutViewLicenses => 'View all licenses';

  @override
  String get aboutContactTitle => 'Contact';

  @override
  String get aboutContactBody =>
      'Report a data error or ask a question on GitHub.';

  @override
  String get aboutContactButton => 'Open an issue on GitHub';

  @override
  String aboutVersion(String version, String data, String date) {
    return 'Version $version, data $data, built $date.';
  }

  @override
  String get aboutPrivacyTitle => 'Privacy';

  @override
  String get aboutPrivacy =>
      'FlameSense collects no personal data and sets no cookies. Questions you type in Ask are sent to the AI provider only to generate the answer.';

  @override
  String get notFoundTitle => 'This page drifted off';

  @override
  String get notFoundBody =>
      'The address may be mistyped, or the page has moved.';

  @override
  String get notFoundCta => 'Go to Home';

  @override
  String tourStep(String n, String total) {
    return 'Step $n of $total';
  }

  @override
  String get tour1Title => 'Fire changes shape without gravity';

  @override
  String get tour1Body =>
      'Drag gravity from Earth to orbit. The flame turns from an orange teardrop into a slow blue sphere.';

  @override
  String get tour2Title => 'Set up a fire test';

  @override
  String get tour2Body =>
      'Pick a material and set oxygen, pressure, airflow and gravity, like NASA\'s space-station experiments.';

  @override
  String get tour3Title => 'An honest prediction';

  @override
  String get tour3Body =>
      'The model is trained only on NASA test runs. The badge shows how much real data supports this answer.';

  @override
  String get tour4Title => 'Where flames survive';

  @override
  String get tour4Body =>
      'Hot colors keep burning. Hatched areas have little NASA data, including Moon and Mars gravity.';

  @override
  String get tour5Title => 'Fire safety for a Moon habitat';

  @override
  String get tour5Body =>
      'NASA plans habitats with 34% oxygen. See which materials are likely to burn there, and the five experiments that would teach NASA the most.';

  @override
  String get tour6Title => 'Every number has a source';

  @override
  String get tour6Body =>
      'Open any run to see the NASA dataset or report it came from.';

  @override
  String get tour7Title => 'Ask the NASA papers';

  @override
  String get tour7Body => 'Answers cite the exact document and page.';

  @override
  String get tour8Title => 'Lessons for Earth';

  @override
  String get tour8Body =>
      'What space fire research means for fire safety in rooms, vehicles and workplaces.';

  @override
  String get missionsTitle => 'Plan for a mission';

  @override
  String get missionsDesc =>
      'NASA\'s next habitats may use less pressure and more oxygen than the ISS. Pick a mission to see which materials are likely to burn there, and where NASA has no data yet.';

  @override
  String get missionIss => 'International Space Station';

  @override
  String get missionLunar => 'Artemis lunar habitat';

  @override
  String get missionMarsTransit => 'Mars transit';

  @override
  String get missionMars => 'Mars surface habitat';

  @override
  String get missionEarth => 'Earth (reference)';

  @override
  String get missionIssNote => 'Cabin atmosphere of the space station today.';

  @override
  String get missionLunarNote => 'Exploration atmosphere at Moon gravity.';

  @override
  String get missionMarsTransitNote =>
      'Exploration atmosphere in weightless cruise.';

  @override
  String get missionMarsNote => 'Exploration atmosphere at Mars gravity.';

  @override
  String get missionEarthNote => 'Sea-level air, for comparison.';

  @override
  String missionAtmosphere(String pressure, String o2, String gravity) {
    return '$pressure kPa, $o2% oxygen, $gravity';
  }

  @override
  String get missionSource => 'Source';

  @override
  String get missionCountBurn => 'likely to burn';

  @override
  String get missionCountOut => 'likely to go out';

  @override
  String get missionCountUnknown => 'unknown';

  @override
  String get verdictBurns => 'Likely to keep burning';

  @override
  String get verdictOut => 'Likely to go out';

  @override
  String get verdictUnknown => 'Unknown, not enough data';

  @override
  String get verdictUncertain => 'Uncertain';

  @override
  String get missionMaterial => 'Material';

  @override
  String get missionVerdict => 'Verdict';

  @override
  String get missionWorstCase => 'Worst case';

  @override
  String get missionWorstFlow => 'Airflow at worst case';

  @override
  String get missionSupport => 'Data support';

  @override
  String get missionMaterials => 'Materials';

  @override
  String get missionWorstCaseTip =>
      'The highest chance of burning across every airflow speed in the data, at this mission\'s gravity, pressure and oxygen.';

  @override
  String get missionNoMaterials => 'No materials are in the dataset yet.';

  @override
  String missionGap(String n, String gravity) {
    return '$n NASA runs at $gravity gravity in this dataset. Verdicts here are extrapolations from orbit and Earth data.';
  }

  @override
  String get wishlistTitle => 'Where NASA should test next';

  @override
  String get wishlistCaption =>
      'A ranking aid: conditions where the model is least sure and no NASA run is nearby. Scientists still design the experiments.';

  @override
  String wishlistReasonUnsure(String p) {
    return 'The model is unsure here (p ≈ $p).';
  }

  @override
  String get wishlistReasonFar => 'No NASA run is close to these conditions.';

  @override
  String get wishlistReasonWide => 'The spread-rate range is wide.';

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
    return 'Planned NASA tests ($label) rank in the top $pct% of FlameSense\'s list.';
  }

  @override
  String wishlistPlannedLegend(String label) {
    return 'Planned NASA test ($label)';
  }

  @override
  String wishlistPin(String n) {
    return 'Suggested test $n';
  }

  @override
  String get wishlistCsv => 'Download test matrix (CSV)';

  @override
  String get wishlistCsvDone => 'Test matrix downloaded';

  @override
  String get wishlistEmpty =>
      'The wishlist needs the burning model, which doesn\'t have enough data yet.';

  @override
  String get briefButton => 'Download Mission Fire Brief (PDF)';

  @override
  String get briefDone => 'Brief downloaded';

  @override
  String get missionsNotice =>
      'Mission atmospheres come from NASA documents. FlameSense checks each material at the worst airflow it tested, because cabin airflow varies.';

  @override
  String get missionsEmptyTitle => 'Mission presets are being verified';

  @override
  String get missionsEmptyBody =>
      'Each mission\'s atmosphere is checked against its NASA source before it appears here.';

  @override
  String get missionUnsourcedDebug =>
      'Debug build: this mission has no source and is hidden in release.';

  @override
  String get plannedFm2 => 'FM2';

  @override
  String briefTitle(String mission) {
    return 'Mission Fire Brief: $mission';
  }

  @override
  String briefSummary(String a, String b, String c) {
    return '$a materials likely to keep burning, $b likely to go out, $c unknown.';
  }

  @override
  String briefFooter(String url, String date) {
    return 'Generated by FlameSense ($url) on $date. Not a certified safety assessment.';
  }

  @override
  String get briefDataGap => 'Data gap';

  @override
  String get briefPlanned => 'Planned NASA tests';

  @override
  String get briefCitations => 'Citations';

  @override
  String get briefDisclaimerTitle => 'Disclaimer';

  @override
  String get briefConditions => 'Conditions';

  @override
  String get briefReasons => 'Why test here';
}
