import '../../../../core/l10n/l10n.dart';
import '../../domain/addiction.dart';

/// Localized name of an addiction type (the custom type reads "Autre").
String addictionTypeLabel(AppLocalizations l10n, AddictionType type) =>
    l10n.addictionTypeLabel(type.dbValue);
