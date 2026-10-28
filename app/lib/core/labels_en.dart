import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_en.dart';
import 'format.dart';

/// English strings and formatting for English-only outputs (PDF brief).
class FsLabelsEn {
  FsLabelsEn._();

  static final instance = FsLabelsEn._();

  final AppLocalizations l = AppLocalizationsEn();
  final FsFormat f = FsFormat('en');
}
