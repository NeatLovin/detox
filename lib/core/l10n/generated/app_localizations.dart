import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
  static const List<Locale> supportedLocales = <Locale>[Locale('fr')];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'Detox'**
  String get appTitle;

  /// No description provided for @envMissingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Configuration manquante'**
  String get envMissingTitle;

  /// No description provided for @envMissingBody.
  ///
  /// In fr, this message translates to:
  /// **'SUPABASE_URL et SUPABASE_ANON_KEY sont vides.\n\nCrée env.json à partir de env.example.json puis lance :\nflutter run --dart-define-from-file=env.json'**
  String get envMissingBody;

  /// No description provided for @commonRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get commonSave;

  /// No description provided for @commonContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get commonContinue;

  /// No description provided for @commonBack.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get commonBack;

  /// No description provided for @commonCopy.
  ///
  /// In fr, this message translates to:
  /// **'Copier'**
  String get commonCopy;

  /// No description provided for @commonCopied.
  ///
  /// In fr, this message translates to:
  /// **'Copié !'**
  String get commonCopied;

  /// No description provided for @commonShare.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get commonShare;

  /// No description provided for @commonRequired.
  ///
  /// In fr, this message translates to:
  /// **'Requis'**
  String get commonRequired;

  /// No description provided for @commonInvalidNumber.
  ///
  /// In fr, this message translates to:
  /// **'Nombre invalide'**
  String get commonInvalidNumber;

  /// No description provided for @errorGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Oups, quelque chose a coincé. Réessaie.'**
  String get errorGeneric;

  /// No description provided for @errorNetwork.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion. Vérifie ton réseau.'**
  String get errorNetwork;

  /// No description provided for @errorInvalidOtp.
  ///
  /// In fr, this message translates to:
  /// **'Code invalide ou expiré.'**
  String get errorInvalidOtp;

  /// No description provided for @errorOtpRateLimit.
  ///
  /// In fr, this message translates to:
  /// **'Trop de demandes. Attends un peu avant de redemander un code.'**
  String get errorOtpRateLimit;

  /// No description provided for @errorUsernameTaken.
  ///
  /// In fr, this message translates to:
  /// **'Ce pseudo est déjà pris.'**
  String get errorUsernameTaken;

  /// No description provided for @errorUsernameInvalid.
  ///
  /// In fr, this message translates to:
  /// **'3 à 20 caractères : lettres, chiffres, . _ -'**
  String get errorUsernameInvalid;

  /// No description provided for @errorSquadFull.
  ///
  /// In fr, this message translates to:
  /// **'Cette escouade est complète (10 max).'**
  String get errorSquadFull;

  /// No description provided for @errorInvalidInviteCode.
  ///
  /// In fr, this message translates to:
  /// **'Code d\'invitation introuvable.'**
  String get errorInvalidInviteCode;

  /// No description provided for @errorAlreadyInSquad.
  ///
  /// In fr, this message translates to:
  /// **'Tu es déjà dans une escouade.'**
  String get errorAlreadyInSquad;

  /// No description provided for @errorRelapseInFuture.
  ///
  /// In fr, this message translates to:
  /// **'La date ne peut pas être dans le futur.'**
  String get errorRelapseInFuture;

  /// No description provided for @errorRelapseBeforeStreak.
  ///
  /// In fr, this message translates to:
  /// **'Cette date est avant le début de ta série actuelle.'**
  String get errorRelapseBeforeStreak;

  /// No description provided for @errorQuitDateInFuture.
  ///
  /// In fr, this message translates to:
  /// **'La date d\'arrêt ne peut pas être dans le futur.'**
  String get errorQuitDateInFuture;

  /// No description provided for @errorAddictionArchived.
  ///
  /// In fr, this message translates to:
  /// **'Cette addiction est archivée.'**
  String get errorAddictionArchived;

  /// No description provided for @errorTooManyAddictions.
  ///
  /// In fr, this message translates to:
  /// **'Maximum 6 addictions actives, dont 2 perso. Archive-en une pour en ajouter une autre.'**
  String get errorTooManyAddictions;

  /// No description provided for @navHome.
  ///
  /// In fr, this message translates to:
  /// **'Accueil'**
  String get navHome;

  /// No description provided for @navSquad.
  ///
  /// In fr, this message translates to:
  /// **'Escouade'**
  String get navSquad;

  /// No description provided for @navProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @authTagline.
  ///
  /// In fr, this message translates to:
  /// **'Arrête avec ton escouade.\nLevel up chaque jour.'**
  String get authTagline;

  /// No description provided for @authEmailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Ton email'**
  String get authEmailLabel;

  /// No description provided for @authEmailInvalid.
  ///
  /// In fr, this message translates to:
  /// **'Email invalide'**
  String get authEmailInvalid;

  /// No description provided for @authSendCode.
  ///
  /// In fr, this message translates to:
  /// **'Recevoir mon code'**
  String get authSendCode;

  /// No description provided for @authCodeSentTo.
  ///
  /// In fr, this message translates to:
  /// **'Code envoyé à {email}'**
  String authCodeSentTo(String email);

  /// No description provided for @authCodeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Code à 6 chiffres'**
  String get authCodeLabel;

  /// No description provided for @authCodeInvalidFormat.
  ///
  /// In fr, this message translates to:
  /// **'Le code fait 6 chiffres'**
  String get authCodeInvalidFormat;

  /// No description provided for @authVerify.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get authVerify;

  /// No description provided for @authResend.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer le code'**
  String get authResend;

  /// No description provided for @authResendIn.
  ///
  /// In fr, this message translates to:
  /// **'Renvoyer dans {seconds} s'**
  String authResendIn(int seconds);

  /// No description provided for @authCodeResent.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau code envoyé 📬'**
  String get authCodeResent;

  /// No description provided for @authChangeEmail.
  ///
  /// In fr, this message translates to:
  /// **'Changer d\'email'**
  String get authChangeEmail;

  /// No description provided for @onboardingStep.
  ///
  /// In fr, this message translates to:
  /// **'Étape {current}/{total}'**
  String onboardingStep(int current, int total);

  /// No description provided for @onboardingProfileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Crée ton perso'**
  String get onboardingProfileTitle;

  /// No description provided for @onboardingUsernameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Pseudo'**
  String get onboardingUsernameLabel;

  /// No description provided for @onboardingUsernameAvailable.
  ///
  /// In fr, this message translates to:
  /// **'Dispo ✅'**
  String get onboardingUsernameAvailable;

  /// No description provided for @onboardingAvatarTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisis ton avatar'**
  String get onboardingAvatarTitle;

  /// No description provided for @onboardingAddictionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tu arrêtes quoi ?'**
  String get onboardingAddictionsTitle;

  /// No description provided for @onboardingAddictionsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisis une ou plusieurs addictions. Tout reste modifiable plus tard.'**
  String get onboardingAddictionsSubtitle;

  /// No description provided for @onboardingSelectAtLeastOne.
  ///
  /// In fr, this message translates to:
  /// **'Choisis au moins une addiction.'**
  String get onboardingSelectAtLeastOne;

  /// No description provided for @onboardingFinish.
  ///
  /// In fr, this message translates to:
  /// **'C\'est parti 🚀'**
  String get onboardingFinish;

  /// No description provided for @addictionLabelField.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get addictionLabelField;

  /// No description provided for @addictionUnitField.
  ///
  /// In fr, this message translates to:
  /// **'Unité'**
  String get addictionUnitField;

  /// No description provided for @addictionUnitCostField.
  ///
  /// In fr, this message translates to:
  /// **'Coût par unité (CHF)'**
  String get addictionUnitCostField;

  /// No description provided for @addictionBaselineField.
  ///
  /// In fr, this message translates to:
  /// **'Conso de base par jour'**
  String get addictionBaselineField;

  /// No description provided for @addictionPrivateToggle.
  ///
  /// In fr, this message translates to:
  /// **'Privée'**
  String get addictionPrivateToggle;

  /// No description provided for @addictionPrivateHint.
  ///
  /// In fr, this message translates to:
  /// **'Ton escouade ne verra jamais son nom.'**
  String get addictionPrivateHint;

  /// No description provided for @addictionQuitDateField.
  ///
  /// In fr, this message translates to:
  /// **'Date d\'arrêt'**
  String get addictionQuitDateField;

  /// No description provided for @addictionXpPerDay.
  ///
  /// In fr, this message translates to:
  /// **'+{xp} XP par jour clean'**
  String addictionXpPerDay(int xp);

  /// No description provided for @addictionFormNewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle addiction'**
  String get addictionFormNewTitle;

  /// No description provided for @addictionFormEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'addiction'**
  String get addictionFormEditTitle;

  /// No description provided for @addictionTypeLabel.
  ///
  /// In fr, this message translates to:
  /// **'{type, select, porn{Porno} snus{Snus} cigarette{Cigarette} vape{Vape} weed{Beuh} alcohol{Alcool} sugar{Sucre} other{Autre}}'**
  String addictionTypeLabel(String type);

  /// No description provided for @squadSetupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ton escouade'**
  String get squadSetupTitle;

  /// No description provided for @squadSetupSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Seul on va vite, ensemble on va loin.'**
  String get squadSetupSubtitle;

  /// No description provided for @squadCreateTab.
  ///
  /// In fr, this message translates to:
  /// **'Créer'**
  String get squadCreateTab;

  /// No description provided for @squadJoinTab.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre'**
  String get squadJoinTab;

  /// No description provided for @squadNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'escouade'**
  String get squadNameLabel;

  /// No description provided for @squadCreateButton.
  ///
  /// In fr, this message translates to:
  /// **'Créer l\'escouade'**
  String get squadCreateButton;

  /// No description provided for @squadCodeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Code d\'invitation'**
  String get squadCodeLabel;

  /// No description provided for @squadJoinButton.
  ///
  /// In fr, this message translates to:
  /// **'Rejoindre'**
  String get squadJoinButton;

  /// No description provided for @squadCreatedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Escouade créée 🎉'**
  String get squadCreatedTitle;

  /// No description provided for @squadCreatedBody.
  ///
  /// In fr, this message translates to:
  /// **'Partage ce code à tes potes pour qu\'ils te rejoignent (10 max).'**
  String get squadCreatedBody;

  /// No description provided for @squadShareMessage.
  ///
  /// In fr, this message translates to:
  /// **'Rejoins mon escouade « {name} » sur Detox ! Code : {code}'**
  String squadShareMessage(String name, String code);

  /// No description provided for @squadEnter.
  ///
  /// In fr, this message translates to:
  /// **'Entrer dans l\'escouade'**
  String get squadEnter;

  /// No description provided for @homeGreeting.
  ///
  /// In fr, this message translates to:
  /// **'Salut {username} 👋'**
  String homeGreeting(String username);

  /// No description provided for @playerLevel.
  ///
  /// In fr, this message translates to:
  /// **'Niv. {level}'**
  String playerLevel(int level);

  /// No description provided for @playerXpProgress.
  ///
  /// In fr, this message translates to:
  /// **'{current} / {total} XP'**
  String playerXpProgress(int current, int total);

  /// No description provided for @playerHp.
  ///
  /// In fr, this message translates to:
  /// **'{hp} HP'**
  String playerHp(int hp);

  /// No description provided for @playerKo.
  ///
  /// In fr, this message translates to:
  /// **'KO 😵 Chaque jour clean te rend +5 HP. Tu vas te relever.'**
  String get playerKo;

  /// No description provided for @playerLevelUp.
  ///
  /// In fr, this message translates to:
  /// **'Niveau {level} ! ⬆️'**
  String playerLevelUp(int level);

  /// No description provided for @homeNoAddictions.
  ///
  /// In fr, this message translates to:
  /// **'Aucune addiction suivie pour l\'instant.'**
  String get homeNoAddictions;

  /// No description provided for @homeAddAddiction.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une addiction'**
  String get homeAddAddiction;

  /// No description provided for @cardCleanFor.
  ///
  /// In fr, this message translates to:
  /// **'Clean depuis'**
  String get cardCleanFor;

  /// No description provided for @cardSaved.
  ///
  /// In fr, this message translates to:
  /// **'Économisés'**
  String get cardSaved;

  /// No description provided for @cardAvoided.
  ///
  /// In fr, this message translates to:
  /// **'Évités'**
  String get cardAvoided;

  /// No description provided for @cardRecord.
  ///
  /// In fr, this message translates to:
  /// **'Record'**
  String get cardRecord;

  /// No description provided for @cardNextMilestone.
  ///
  /// In fr, this message translates to:
  /// **'Prochain palier : {days} j'**
  String cardNextMilestone(int days);

  /// No description provided for @cardMilestoneBonus.
  ///
  /// In fr, this message translates to:
  /// **'+{xp} XP'**
  String cardMilestoneBonus(int xp);

  /// No description provided for @cardAllMilestones.
  ///
  /// In fr, this message translates to:
  /// **'Tous les paliers atteints 👑'**
  String get cardAllMilestones;

  /// No description provided for @cardPrivate.
  ///
  /// In fr, this message translates to:
  /// **'Privée'**
  String get cardPrivate;

  /// No description provided for @durationCompact.
  ///
  /// In fr, this message translates to:
  /// **'{days}j {hours}h {minutes}m {seconds}s'**
  String durationCompact(int days, int hours, int minutes, int seconds);

  /// No description provided for @durationDays.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{0 jour} =1{1 jour} other{{count} jours}}'**
  String durationDays(int count);

  /// No description provided for @relapseButton.
  ///
  /// In fr, this message translates to:
  /// **'J\'ai rechuté'**
  String get relapseButton;

  /// No description provided for @relapseSheetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rechute · {label}'**
  String relapseSheetTitle(String label);

  /// No description provided for @relapseSheetSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Pas de jugement ici. On note et on repart.'**
  String get relapseSheetSubtitle;

  /// No description provided for @relapseWhen.
  ///
  /// In fr, this message translates to:
  /// **'Quand ?'**
  String get relapseWhen;

  /// No description provided for @relapseNoteLabel.
  ///
  /// In fr, this message translates to:
  /// **'Note (optionnelle)'**
  String get relapseNoteLabel;

  /// No description provided for @relapseNoteHint.
  ///
  /// In fr, this message translates to:
  /// **'Ce qui s\'est passé, ce que tu retiens…'**
  String get relapseNoteHint;

  /// No description provided for @relapseShareToggle.
  ///
  /// In fr, this message translates to:
  /// **'Partager à l\'escouade'**
  String get relapseShareToggle;

  /// No description provided for @relapseSharePrivateHint.
  ///
  /// In fr, this message translates to:
  /// **'Addiction privée : l\'escouade verra seulement « une addiction privée ».'**
  String get relapseSharePrivateHint;

  /// No description provided for @relapseConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Valider'**
  String get relapseConfirm;

  /// No description provided for @relapseKindMessage.
  ///
  /// In fr, this message translates to:
  /// **'Ça arrive. Ton XP et ton niveau restent. On repart. 💪'**
  String get relapseKindMessage;

  /// No description provided for @leaderboardTitle.
  ///
  /// In fr, this message translates to:
  /// **'Classement de la semaine'**
  String get leaderboardTitle;

  /// No description provided for @leaderboardXp.
  ///
  /// In fr, this message translates to:
  /// **'{xp} XP'**
  String leaderboardXp(int xp);

  /// No description provided for @leaderboardYou.
  ///
  /// In fr, this message translates to:
  /// **'toi'**
  String get leaderboardYou;

  /// No description provided for @feedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Le feed'**
  String get feedTitle;

  /// No description provided for @feedEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Rien pour l\'instant. Le premier palier arrive vite !'**
  String get feedEmpty;

  /// No description provided for @feedJoined.
  ///
  /// In fr, this message translates to:
  /// **'{username} a rejoint l\'escouade'**
  String feedJoined(String username);

  /// No description provided for @feedLeft.
  ///
  /// In fr, this message translates to:
  /// **'{username} a quitté l\'escouade'**
  String feedLeft(String username);

  /// No description provided for @feedMilestone.
  ///
  /// In fr, this message translates to:
  /// **'{username} : {days, plural, =1{1 jour clean} other{{days} jours clean}} ({label})'**
  String feedMilestone(String username, int days, String label);

  /// No description provided for @feedLevelUp.
  ///
  /// In fr, this message translates to:
  /// **'{username} passe niveau {level}'**
  String feedLevelUp(String username, int level);

  /// No description provided for @feedRelapse.
  ///
  /// In fr, this message translates to:
  /// **'{username} a rechuté ({label}). Envoie-lui de la force 💪'**
  String feedRelapse(String username, String label);

  /// No description provided for @feedUnknown.
  ///
  /// In fr, this message translates to:
  /// **'{username} a fait un truc'**
  String feedUnknown(String username);

  /// No description provided for @timeAgoNow.
  ///
  /// In fr, this message translates to:
  /// **'à l\'instant'**
  String get timeAgoNow;

  /// No description provided for @timeAgoMinutes.
  ///
  /// In fr, this message translates to:
  /// **'il y a {n} min'**
  String timeAgoMinutes(int n);

  /// No description provided for @timeAgoHours.
  ///
  /// In fr, this message translates to:
  /// **'il y a {n} h'**
  String timeAgoHours(int n);

  /// No description provided for @timeAgoDays.
  ///
  /// In fr, this message translates to:
  /// **'il y a {n} j'**
  String timeAgoDays(int n);

  /// No description provided for @squadSettingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réglages de l\'escouade'**
  String get squadSettingsTitle;

  /// No description provided for @squadMembersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Membres ({count}/10)'**
  String squadMembersTitle(int count);

  /// No description provided for @squadOwner.
  ///
  /// In fr, this message translates to:
  /// **'Chef'**
  String get squadOwner;

  /// No description provided for @squadLeave.
  ///
  /// In fr, this message translates to:
  /// **'Quitter l\'escouade'**
  String get squadLeave;

  /// No description provided for @squadLeaveConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quitter l\'escouade ?'**
  String get squadLeaveConfirmTitle;

  /// No description provided for @squadLeaveConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Tu gardes ton XP, ton niveau et tes addictions. Tu pourras en rejoindre une autre.'**
  String get squadLeaveConfirmBody;

  /// No description provided for @profileEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le profil'**
  String get profileEdit;

  /// No description provided for @profileUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Profil mis à jour ✅'**
  String get profileUpdated;

  /// No description provided for @profileAddictionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes addictions'**
  String get profileAddictionsTitle;

  /// No description provided for @profileArchivedTitle.
  ///
  /// In fr, this message translates to:
  /// **'Archivées'**
  String get profileArchivedTitle;

  /// No description provided for @profileArchive.
  ///
  /// In fr, this message translates to:
  /// **'Archiver'**
  String get profileArchive;

  /// No description provided for @profileArchiveConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Archiver « {label} » ?'**
  String profileArchiveConfirmTitle(String label);

  /// No description provided for @profileArchiveConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Le suivi s\'arrête. Ton XP et ton niveau restent.'**
  String get profileArchiveConfirmBody;

  /// No description provided for @profileSignOut.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get profileSignOut;

  /// No description provided for @profileStats.
  ///
  /// In fr, this message translates to:
  /// **'Niv. {level} · {xp} XP'**
  String profileStats(int level, int xp);

  /// No description provided for @navQuests.
  ///
  /// In fr, this message translates to:
  /// **'Quêtes'**
  String get navQuests;

  /// No description provided for @errorTooManyQuests.
  ///
  /// In fr, this message translates to:
  /// **'Maximum 8 quêtes actives. Archive-en une pour en ajouter une autre.'**
  String get errorTooManyQuests;

  /// No description provided for @errorQuestDayOutOfRange.
  ///
  /// In fr, this message translates to:
  /// **'Tu peux seulement noter aujourd’hui ou hier.'**
  String get errorQuestDayOutOfRange;

  /// No description provided for @errorQuestArchived.
  ///
  /// In fr, this message translates to:
  /// **'Cette quête est archivée.'**
  String get errorQuestArchived;

  /// No description provided for @errorCravingInFuture.
  ///
  /// In fr, this message translates to:
  /// **'L’envie ne peut pas être dans le futur.'**
  String get errorCravingInFuture;

  /// No description provided for @errorCravingTooOld.
  ///
  /// In fr, this message translates to:
  /// **'Tu peux noter les envies des 7 derniers jours seulement.'**
  String get errorCravingTooOld;

  /// No description provided for @errorSosNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Ce SOS n’existe plus.'**
  String get errorSosNotFound;

  /// No description provided for @errorSosOwnAlert.
  ///
  /// In fr, this message translates to:
  /// **'Tu ne peux pas soutenir ton propre SOS.'**
  String get errorSosOwnAlert;

  /// No description provided for @errorSosExpired.
  ///
  /// In fr, this message translates to:
  /// **'Ce SOS est trop ancien.'**
  String get errorSosExpired;

  /// No description provided for @errorSosAlreadyResolved.
  ///
  /// In fr, this message translates to:
  /// **'Ce SOS est déjà terminé.'**
  String get errorSosAlreadyResolved;

  /// No description provided for @errorTooManyMotivations.
  ///
  /// In fr, this message translates to:
  /// **'5 raisons maximum.'**
  String get errorTooManyMotivations;

  /// No description provided for @homeSosButton.
  ///
  /// In fr, this message translates to:
  /// **'SOS'**
  String get homeSosButton;

  /// No description provided for @homeLogCraving.
  ///
  /// In fr, this message translates to:
  /// **'Noter une envie'**
  String get homeLogCraving;

  /// No description provided for @pledgeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Engagement du jour'**
  String get pledgeTitle;

  /// No description provided for @pledgeBody.
  ///
  /// In fr, this message translates to:
  /// **'Engage-toi devant ton escouade à tenir aujourd’hui.'**
  String get pledgeBody;

  /// No description provided for @pledgeButton.
  ///
  /// In fr, this message translates to:
  /// **'Je m’engage 🤝'**
  String get pledgeButton;

  /// No description provided for @pledgeDone.
  ///
  /// In fr, this message translates to:
  /// **'Engagé pour aujourd’hui ✅'**
  String get pledgeDone;

  /// No description provided for @xpGain.
  ///
  /// In fr, this message translates to:
  /// **'+{xp} XP'**
  String xpGain(int xp);

  /// No description provided for @cravingSheetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Une envie ?'**
  String get cravingSheetTitle;

  /// No description provided for @cravingSheetSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'La noter aide à repérer tes moments à risque.'**
  String get cravingSheetSubtitle;

  /// No description provided for @cravingAddictionLabel.
  ///
  /// In fr, this message translates to:
  /// **'Envie de quoi ?'**
  String get cravingAddictionLabel;

  /// No description provided for @cravingIntensity.
  ///
  /// In fr, this message translates to:
  /// **'Intensité : {value}/5'**
  String cravingIntensity(int value);

  /// No description provided for @cravingTriggerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Déclencheur'**
  String get cravingTriggerTitle;

  /// No description provided for @cravingTriggerLabel.
  ///
  /// In fr, this message translates to:
  /// **'{trigger, select, stress{Stress} boredom{Ennui} party{Soirée} after_meal{Après le repas} morning{Réveil} screen{Écran} social{Avec des potes} tired{Fatigue} other{Autre}}'**
  String cravingTriggerLabel(String trigger);

  /// No description provided for @cravingNoteLabel.
  ///
  /// In fr, this message translates to:
  /// **'Note (optionnel)'**
  String get cravingNoteLabel;

  /// No description provided for @cravingResisted.
  ///
  /// In fr, this message translates to:
  /// **'J’ai résisté 💪'**
  String get cravingResisted;

  /// No description provided for @cravingGaveIn.
  ///
  /// In fr, this message translates to:
  /// **'J’ai craqué'**
  String get cravingGaveIn;

  /// No description provided for @cravingSavedXp.
  ///
  /// In fr, this message translates to:
  /// **'Bien joué ! +{xp} XP'**
  String cravingSavedXp(int xp);

  /// No description provided for @cravingSaved.
  ///
  /// In fr, this message translates to:
  /// **'Envie notée 📝'**
  String get cravingSaved;

  /// No description provided for @cravingJournalTitle.
  ///
  /// In fr, this message translates to:
  /// **'Journal des envies'**
  String get cravingJournalTitle;

  /// No description provided for @cravingJournalEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune envie notée pour l’instant. Note la prochaine : c’est comme ça qu’on repère ses pièges.'**
  String get cravingJournalEmpty;

  /// No description provided for @cravingStats.
  ///
  /// In fr, this message translates to:
  /// **'{resisted}/{total} envies résistées ({percent} %)'**
  String cravingStats(int resisted, int total, int percent);

  /// No description provided for @cravingTopTrigger.
  ///
  /// In fr, this message translates to:
  /// **'Ton déclencheur n°1 : {trigger}'**
  String cravingTopTrigger(String trigger);

  /// No description provided for @cravingResistedTag.
  ///
  /// In fr, this message translates to:
  /// **'Résistée'**
  String get cravingResistedTag;

  /// No description provided for @cravingGaveInTag.
  ///
  /// In fr, this message translates to:
  /// **'Craquée'**
  String get cravingGaveInTag;

  /// No description provided for @cravingDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get cravingDelete;

  /// No description provided for @sosPickAddiction.
  ///
  /// In fr, this message translates to:
  /// **'SOS : envie de quoi ?'**
  String get sosPickAddiction;

  /// No description provided for @sosTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tiens bon'**
  String get sosTitle;

  /// No description provided for @sosSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Une envie dure rarement plus de quelques minutes. Respire avec le cercle.'**
  String get sosSubtitle;

  /// No description provided for @sosBreathIn.
  ///
  /// In fr, this message translates to:
  /// **'Inspire'**
  String get sosBreathIn;

  /// No description provided for @sosBreathHold.
  ///
  /// In fr, this message translates to:
  /// **'Bloque'**
  String get sosBreathHold;

  /// No description provided for @sosBreathOut.
  ///
  /// In fr, this message translates to:
  /// **'Expire'**
  String get sosBreathOut;

  /// No description provided for @sosTimeLeft.
  ///
  /// In fr, this message translates to:
  /// **'Encore {time}'**
  String sosTimeLeft(String time);

  /// No description provided for @sosTimeUp.
  ///
  /// In fr, this message translates to:
  /// **'Le plus dur est passé 💪'**
  String get sosTimeUp;

  /// No description provided for @sosReasonsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Tes raisons'**
  String get sosReasonsTitle;

  /// No description provided for @sosNoReasons.
  ///
  /// In fr, this message translates to:
  /// **'Ajoute tes raisons d’arrêter dans ton profil : elles s’afficheront ici.'**
  String get sosNoReasons;

  /// No description provided for @sosGroundingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ancrage 5-4-3-2-1'**
  String get sosGroundingTitle;

  /// No description provided for @sosGrounding5.
  ///
  /// In fr, this message translates to:
  /// **'5 choses que tu vois'**
  String get sosGrounding5;

  /// No description provided for @sosGrounding4.
  ///
  /// In fr, this message translates to:
  /// **'4 choses que tu peux toucher'**
  String get sosGrounding4;

  /// No description provided for @sosGrounding3.
  ///
  /// In fr, this message translates to:
  /// **'3 sons que tu entends'**
  String get sosGrounding3;

  /// No description provided for @sosGrounding2.
  ///
  /// In fr, this message translates to:
  /// **'2 odeurs que tu sens'**
  String get sosGrounding2;

  /// No description provided for @sosGrounding1.
  ///
  /// In fr, this message translates to:
  /// **'1 goût dans ta bouche'**
  String get sosGrounding1;

  /// No description provided for @sosSquadNotified.
  ///
  /// In fr, this message translates to:
  /// **'Ton escouade est prévenue'**
  String get sosSquadNotified;

  /// No description provided for @sosNoSquad.
  ///
  /// In fr, this message translates to:
  /// **'Pas d’escouade : personne n’est prévenu.'**
  String get sosNoSquad;

  /// No description provided for @sosSupportsReceived.
  ///
  /// In fr, this message translates to:
  /// **'Soutien reçu'**
  String get sosSupportsReceived;

  /// No description provided for @sosResisted.
  ///
  /// In fr, this message translates to:
  /// **'J’ai tenu 💪'**
  String get sosResisted;

  /// No description provided for @sosGaveIn.
  ///
  /// In fr, this message translates to:
  /// **'J’ai craqué'**
  String get sosGaveIn;

  /// No description provided for @sosVictory.
  ///
  /// In fr, this message translates to:
  /// **'Victoire ! Envie résistée 🏆'**
  String get sosVictory;

  /// No description provided for @sosLeaveConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quitter le SOS ?'**
  String get sosLeaveConfirmTitle;

  /// No description provided for @sosLeaveConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Dis-nous comment ça s’est fini : ça compte pour ton journal.'**
  String get sosLeaveConfirmBody;

  /// No description provided for @squadSosTitle.
  ///
  /// In fr, this message translates to:
  /// **'{username} traverse une envie ({label})'**
  String squadSosTitle(String username, String label);

  /// No description provided for @squadSosSupport.
  ///
  /// In fr, this message translates to:
  /// **'Envoie-lui de la force'**
  String get squadSosSupport;

  /// No description provided for @squadSosSent.
  ///
  /// In fr, this message translates to:
  /// **'Soutien envoyé {emoji}'**
  String squadSosSent(String emoji);

  /// No description provided for @feedPledge.
  ///
  /// In fr, this message translates to:
  /// **'{username} s’engage pour aujourd’hui 🤝'**
  String feedPledge(String username);

  /// No description provided for @feedBadge.
  ///
  /// In fr, this message translates to:
  /// **'{username} débloque le badge « {badge} »'**
  String feedBadge(String username, String badge);

  /// No description provided for @feedSos.
  ///
  /// In fr, this message translates to:
  /// **'{username} lance un SOS ({label}). Envoie-lui de la force !'**
  String feedSos(String username, String label);

  /// No description provided for @feedSosSupport.
  ///
  /// In fr, this message translates to:
  /// **'{username} envoie {emoji} à {to}'**
  String feedSosSupport(String username, String emoji, String to);

  /// No description provided for @feedSosResolved.
  ///
  /// In fr, this message translates to:
  /// **'{username} a résisté à son envie ({label}) 🏆'**
  String feedSosResolved(String username, String label);

  /// No description provided for @feedQuestsAllDone.
  ///
  /// In fr, this message translates to:
  /// **'{username} a bouclé toutes ses quêtes du jour ✅'**
  String feedQuestsAllDone(String username);

  /// No description provided for @badgesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Badges'**
  String get badgesTitle;

  /// No description provided for @badgesProgress.
  ///
  /// In fr, this message translates to:
  /// **'{unlocked}/{total} débloqués'**
  String badgesProgress(int unlocked, int total);

  /// No description provided for @badgeName.
  ///
  /// In fr, this message translates to:
  /// **'{badge, select, first_pledge{Premier engagement} pledge_streak_7{Parole tenue} first_resist{Première victoire} resist_10{Mur de briques} sos_first{Appel à l\'aide} helper{Pote en or} streak_7{Une semaine} streak_30{Un mois} streak_90{Trois mois} comeback{Comeback} quest_streak_7{Régulier} level_5{Niveau 5} level_10{Niveau 10} other{Badge}}'**
  String badgeName(String badge);

  /// No description provided for @badgeDescription.
  ///
  /// In fr, this message translates to:
  /// **'{badge, select, first_pledge{Faire ton premier engagement du matin.} pledge_streak_7{T\'engager 7 jours d\'affilée.} first_resist{Résister à ta première envie.} resist_10{Résister à 10 envies.} sos_first{Tenir bon grâce au SOS.} helper{Soutenir 5 fois un pote en SOS.} streak_7{7 jours clean sur une addiction.} streak_30{30 jours clean sur une addiction.} streak_90{90 jours clean sur une addiction.} comeback{30 jours clean après une rechute.} quest_streak_7{Boucler une quête 7 jours d\'affilée.} level_5{Atteindre le niveau 5.} level_10{Atteindre le niveau 10.} other{}}'**
  String badgeDescription(String badge);

  /// No description provided for @badgeLocked.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore débloqué'**
  String get badgeLocked;

  /// No description provided for @badgeUnlockedOn.
  ///
  /// In fr, this message translates to:
  /// **'Débloqué le {date}'**
  String badgeUnlockedOn(String date);

  /// No description provided for @questsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Quêtes du jour'**
  String get questsTitle;

  /// No description provided for @questsSummary.
  ///
  /// In fr, this message translates to:
  /// **'{done}/{total} quêtes'**
  String questsSummary(int done, int total);

  /// No description provided for @questsAllDoneHint.
  ///
  /// In fr, this message translates to:
  /// **'Boucle toutes tes quêtes (3 min.) : +{xp} XP bonus'**
  String questsAllDoneHint(int xp);

  /// No description provided for @questsAllDone.
  ///
  /// In fr, this message translates to:
  /// **'Journée bouclée ✅'**
  String get questsAllDone;

  /// No description provided for @questsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Ajoute tes premières quêtes : eau, sport, sommeil…'**
  String get questsEmpty;

  /// No description provided for @questsAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une quête'**
  String get questsAdd;

  /// No description provided for @questStreak.
  ///
  /// In fr, this message translates to:
  /// **'🔥 {days} j'**
  String questStreak(int days);

  /// No description provided for @questTypeLabel.
  ///
  /// In fr, this message translates to:
  /// **'{type, select, water{Eau} sport{Sport} sleep{Sommeil} steps{Pas} meditation{Méditation} reading{Lecture} no_screen{Sans écran} other{Perso}}'**
  String questTypeLabel(String type);

  /// No description provided for @questFormNewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle quête'**
  String get questFormNewTitle;

  /// No description provided for @questFormEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la quête'**
  String get questFormEditTitle;

  /// No description provided for @questLabelField.
  ///
  /// In fr, this message translates to:
  /// **'Nom'**
  String get questLabelField;

  /// No description provided for @questUnitField.
  ///
  /// In fr, this message translates to:
  /// **'Unité'**
  String get questUnitField;

  /// No description provided for @questTargetField.
  ///
  /// In fr, this message translates to:
  /// **'Objectif par jour'**
  String get questTargetField;

  /// No description provided for @questArchive.
  ///
  /// In fr, this message translates to:
  /// **'Archiver la quête'**
  String get questArchive;

  /// No description provided for @questSetValueTitle.
  ///
  /// In fr, this message translates to:
  /// **'{label} aujourd’hui'**
  String questSetValueTitle(String label);

  /// No description provided for @questDone.
  ///
  /// In fr, this message translates to:
  /// **'Fait'**
  String get questDone;

  /// No description provided for @questsLimit.
  ///
  /// In fr, this message translates to:
  /// **'Maximum {max} quêtes actives.'**
  String questsLimit(int max);

  /// No description provided for @motivationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes raisons d’arrêter'**
  String get motivationsTitle;

  /// No description provided for @motivationsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Elles s’affichent pendant un SOS.'**
  String get motivationsSubtitle;

  /// No description provided for @motivationsAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une raison'**
  String get motivationsAdd;

  /// No description provided for @motivationsHint.
  ///
  /// In fr, this message translates to:
  /// **'Ex : avoir du souffle au foot'**
  String get motivationsHint;

  /// No description provided for @motivationsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune raison pour l’instant.'**
  String get motivationsEmpty;

  /// No description provided for @commonDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get commonDelete;

  /// No description provided for @commonEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get commonEdit;
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
      <String>['fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
