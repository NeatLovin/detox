// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Detox';

  @override
  String get envMissingTitle => 'Configuration manquante';

  @override
  String get envMissingBody =>
      'SUPABASE_URL et SUPABASE_ANON_KEY sont vides.\n\nCrée env.json à partir de env.example.json puis lance :\nflutter run --dart-define-from-file=env.json';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonContinue => 'Continuer';

  @override
  String get commonBack => 'Retour';

  @override
  String get commonCopy => 'Copier';

  @override
  String get commonCopied => 'Copié !';

  @override
  String get commonShare => 'Partager';

  @override
  String get commonRequired => 'Requis';

  @override
  String get commonInvalidNumber => 'Nombre invalide';

  @override
  String get errorGeneric => 'Oups, quelque chose a coincé. Réessaie.';

  @override
  String get errorNetwork => 'Pas de connexion. Vérifie ton réseau.';

  @override
  String get errorInvalidOtp => 'Code invalide ou expiré.';

  @override
  String get errorOtpRateLimit =>
      'Trop de demandes. Attends un peu avant de redemander un code.';

  @override
  String get errorUsernameTaken => 'Ce pseudo est déjà pris.';

  @override
  String get errorUsernameInvalid =>
      '3 à 20 caractères : lettres, chiffres, . _ -';

  @override
  String get errorSquadFull => 'Cette escouade est complète (10 max).';

  @override
  String get errorInvalidInviteCode => 'Code d\'invitation introuvable.';

  @override
  String get errorAlreadyInSquad => 'Tu es déjà dans une escouade.';

  @override
  String get errorRelapseInFuture => 'La date ne peut pas être dans le futur.';

  @override
  String get errorRelapseBeforeStreak =>
      'Cette date est avant le début de ta série actuelle.';

  @override
  String get errorQuitDateInFuture =>
      'La date d\'arrêt ne peut pas être dans le futur.';

  @override
  String get errorAddictionArchived => 'Cette addiction est archivée.';

  @override
  String get navHome => 'Accueil';

  @override
  String get navSquad => 'Escouade';

  @override
  String get navProfile => 'Profil';

  @override
  String get authTagline => 'Arrête avec ton escouade.\nLevel up chaque jour.';

  @override
  String get authEmailLabel => 'Ton email';

  @override
  String get authEmailInvalid => 'Email invalide';

  @override
  String get authSendCode => 'Recevoir mon code';

  @override
  String authCodeSentTo(String email) {
    return 'Code envoyé à $email';
  }

  @override
  String get authCodeLabel => 'Code à 6 chiffres';

  @override
  String get authCodeInvalidFormat => 'Le code fait 6 chiffres';

  @override
  String get authVerify => 'Valider';

  @override
  String get authResend => 'Renvoyer le code';

  @override
  String authResendIn(int seconds) {
    return 'Renvoyer dans $seconds s';
  }

  @override
  String get authCodeResent => 'Nouveau code envoyé 📬';

  @override
  String get authChangeEmail => 'Changer d\'email';

  @override
  String onboardingStep(int current, int total) {
    return 'Étape $current/$total';
  }

  @override
  String get onboardingProfileTitle => 'Crée ton perso';

  @override
  String get onboardingUsernameLabel => 'Pseudo';

  @override
  String get onboardingUsernameAvailable => 'Dispo ✅';

  @override
  String get onboardingAvatarTitle => 'Choisis ton avatar';

  @override
  String get onboardingAddictionsTitle => 'Tu arrêtes quoi ?';

  @override
  String get onboardingAddictionsSubtitle =>
      'Choisis une ou plusieurs addictions. Tout reste modifiable plus tard.';

  @override
  String get onboardingSelectAtLeastOne => 'Choisis au moins une addiction.';

  @override
  String get onboardingFinish => 'C\'est parti 🚀';

  @override
  String get addictionLabelField => 'Nom';

  @override
  String get addictionUnitField => 'Unité';

  @override
  String get addictionUnitCostField => 'Coût par unité (CHF)';

  @override
  String get addictionBaselineField => 'Conso de base par jour';

  @override
  String get addictionPrivateToggle => 'Privée';

  @override
  String get addictionPrivateHint => 'Ton escouade ne verra jamais son nom.';

  @override
  String get addictionQuitDateField => 'Date d\'arrêt';

  @override
  String addictionXpPerDay(int xp) {
    return '+$xp XP par jour clean';
  }

  @override
  String get addictionFormNewTitle => 'Nouvelle addiction';

  @override
  String get addictionFormEditTitle => 'Modifier l\'addiction';

  @override
  String addictionTypeLabel(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'porn': 'Porno',
      'snus': 'Snus',
      'cigarette': 'Cigarette',
      'vape': 'Vape',
      'weed': 'Beuh',
      'alcohol': 'Alcool',
      'sugar': 'Sucre',
      'other': 'Autre',
    });
    return '$_temp0';
  }

  @override
  String get squadSetupTitle => 'Ton escouade';

  @override
  String get squadSetupSubtitle => 'Seul on va vite, ensemble on va loin.';

  @override
  String get squadCreateTab => 'Créer';

  @override
  String get squadJoinTab => 'Rejoindre';

  @override
  String get squadNameLabel => 'Nom de l\'escouade';

  @override
  String get squadCreateButton => 'Créer l\'escouade';

  @override
  String get squadCodeLabel => 'Code d\'invitation';

  @override
  String get squadJoinButton => 'Rejoindre';

  @override
  String get squadCreatedTitle => 'Escouade créée 🎉';

  @override
  String get squadCreatedBody =>
      'Partage ce code à tes potes pour qu\'ils te rejoignent (10 max).';

  @override
  String squadShareMessage(String name, String code) {
    return 'Rejoins mon escouade « $name » sur Detox ! Code : $code';
  }

  @override
  String get squadEnter => 'Entrer dans l\'escouade';

  @override
  String homeGreeting(String username) {
    return 'Salut $username 👋';
  }

  @override
  String playerLevel(int level) {
    return 'Niv. $level';
  }

  @override
  String playerXpProgress(int current, int total) {
    return '$current / $total XP';
  }

  @override
  String playerHp(int hp) {
    return '$hp HP';
  }

  @override
  String get playerKo =>
      'KO 😵 Chaque jour clean te rend +5 HP. Tu vas te relever.';

  @override
  String playerLevelUp(int level) {
    return 'Niveau $level ! ⬆️';
  }

  @override
  String get homeNoAddictions => 'Aucune addiction suivie pour l\'instant.';

  @override
  String get homeAddAddiction => 'Ajouter une addiction';

  @override
  String get cardCleanFor => 'Clean depuis';

  @override
  String get cardSaved => 'Économisés';

  @override
  String get cardAvoided => 'Évités';

  @override
  String get cardRecord => 'Record';

  @override
  String cardNextMilestone(int days) {
    return 'Prochain palier : $days j';
  }

  @override
  String cardMilestoneBonus(int xp) {
    return '+$xp XP';
  }

  @override
  String get cardAllMilestones => 'Tous les paliers atteints 👑';

  @override
  String get cardPrivate => 'Privée';

  @override
  String durationCompact(int days, int hours, int minutes, int seconds) {
    return '${days}j ${hours}h ${minutes}m ${seconds}s';
  }

  @override
  String durationDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count jours',
      one: '1 jour',
      zero: '0 jour',
    );
    return '$_temp0';
  }

  @override
  String get relapseButton => 'J\'ai rechuté';

  @override
  String relapseSheetTitle(String label) {
    return 'Rechute · $label';
  }

  @override
  String get relapseSheetSubtitle =>
      'Pas de jugement ici. On note et on repart.';

  @override
  String get relapseWhen => 'Quand ?';

  @override
  String get relapseNoteLabel => 'Note (optionnelle)';

  @override
  String get relapseNoteHint => 'Ce qui s\'est passé, ce que tu retiens…';

  @override
  String get relapseShareToggle => 'Partager à l\'escouade';

  @override
  String get relapseSharePrivateHint =>
      'Addiction privée : l\'escouade verra seulement « une addiction privée ».';

  @override
  String get relapseConfirm => 'Valider';

  @override
  String get relapseKindMessage =>
      'Ça arrive. Ton XP et ton niveau restent. On repart. 💪';

  @override
  String get leaderboardTitle => 'Classement de la semaine';

  @override
  String leaderboardXp(int xp) {
    return '$xp XP';
  }

  @override
  String get leaderboardYou => 'toi';

  @override
  String get feedTitle => 'Le feed';

  @override
  String get feedEmpty =>
      'Rien pour l\'instant. Le premier palier arrive vite !';

  @override
  String feedJoined(String username) {
    return '$username a rejoint l\'escouade';
  }

  @override
  String feedLeft(String username) {
    return '$username a quitté l\'escouade';
  }

  @override
  String feedMilestone(String username, int days, String label) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days jours clean',
      one: '1 jour clean',
    );
    return '$username : $_temp0 ($label)';
  }

  @override
  String feedLevelUp(String username, int level) {
    return '$username passe niveau $level';
  }

  @override
  String feedRelapse(String username, String label) {
    return '$username a rechuté ($label). Envoie-lui de la force 💪';
  }

  @override
  String feedUnknown(String username) {
    return '$username a fait un truc';
  }

  @override
  String get timeAgoNow => 'à l\'instant';

  @override
  String timeAgoMinutes(int n) {
    return 'il y a $n min';
  }

  @override
  String timeAgoHours(int n) {
    return 'il y a $n h';
  }

  @override
  String timeAgoDays(int n) {
    return 'il y a $n j';
  }

  @override
  String get squadSettingsTitle => 'Réglages de l\'escouade';

  @override
  String squadMembersTitle(int count) {
    return 'Membres ($count/10)';
  }

  @override
  String get squadOwner => 'Chef';

  @override
  String get squadLeave => 'Quitter l\'escouade';

  @override
  String get squadLeaveConfirmTitle => 'Quitter l\'escouade ?';

  @override
  String get squadLeaveConfirmBody =>
      'Tu gardes ton XP, ton niveau et tes addictions. Tu pourras en rejoindre une autre.';

  @override
  String get profileEdit => 'Modifier le profil';

  @override
  String get profileUpdated => 'Profil mis à jour ✅';

  @override
  String get profileAddictionsTitle => 'Mes addictions';

  @override
  String get profileArchivedTitle => 'Archivées';

  @override
  String get profileArchive => 'Archiver';

  @override
  String profileArchiveConfirmTitle(String label) {
    return 'Archiver « $label » ?';
  }

  @override
  String get profileArchiveConfirmBody =>
      'Le suivi s\'arrête. Ton XP et ton niveau restent.';

  @override
  String get profileSignOut => 'Se déconnecter';

  @override
  String profileStats(int level, int xp) {
    return 'Niv. $level · $xp XP';
  }
}
