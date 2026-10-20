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
  String get errorTooManyAddictions =>
      'Maximum 6 addictions actives, dont 2 perso. Archive-en une pour en ajouter une autre.';

  @override
  String get navHome => 'Accueil';

  @override
  String get navProfile => 'Profil';

  @override
  String get authTagline => 'Arrête avec tes potes.\nLevel up chaque jour.';

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
  String get addictionPrivateHint =>
      'Les autres joueurs ne verront jamais cette addiction.';

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
  String get relapseShareToggle => 'Partager dans le feed';

  @override
  String get relapseSharePrivateHint =>
      'Addiction privée : le feed affichera seulement « une addiction privée ».';

  @override
  String get relapseConfirm => 'Valider';

  @override
  String get relapseKindMessage =>
      'Ça arrive. Ton XP et ton niveau restent. On repart. 💪';

  @override
  String get leaderboardTitle => 'Classement général';

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
    return '$username a rejoint Detox 👋';
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

  @override
  String get navQuests => 'Quêtes';

  @override
  String get errorTooManyQuests =>
      'Maximum 8 quêtes actives. Archive-en une pour en ajouter une autre.';

  @override
  String get errorQuestDayOutOfRange =>
      'Tu peux seulement noter aujourd’hui ou hier.';

  @override
  String get errorQuestArchived => 'Cette quête est archivée.';

  @override
  String get errorCravingInFuture => 'L’envie ne peut pas être dans le futur.';

  @override
  String get errorCravingTooOld =>
      'Tu peux noter les envies des 7 derniers jours seulement.';

  @override
  String get errorSosNotFound => 'Ce SOS n’existe plus.';

  @override
  String get errorSosOwnAlert => 'Tu ne peux pas soutenir ton propre SOS.';

  @override
  String get errorSosExpired => 'Ce SOS est trop ancien.';

  @override
  String get errorSosAlreadyResolved => 'Ce SOS est déjà terminé.';

  @override
  String get errorTooManyMotivations => '5 raisons maximum.';

  @override
  String get homeSosButton => 'SOS';

  @override
  String get homeLogCraving => 'Noter une envie';

  @override
  String get pledgeTitle => 'Engagement du jour';

  @override
  String get pledgeBody =>
      'Engage-toi devant tout le monde à tenir aujourd’hui.';

  @override
  String get pledgeButton => 'Je m’engage 🤝';

  @override
  String get pledgeDone => 'Engagé pour aujourd’hui ✅';

  @override
  String xpGain(int xp) {
    return '+$xp XP';
  }

  @override
  String get cravingSheetTitle => 'Une envie ?';

  @override
  String get cravingSheetSubtitle =>
      'La noter aide à repérer tes moments à risque.';

  @override
  String get cravingAddictionLabel => 'Envie de quoi ?';

  @override
  String cravingIntensity(int value) {
    return 'Intensité : $value/5';
  }

  @override
  String get cravingTriggerTitle => 'Déclencheur';

  @override
  String cravingTriggerLabel(String trigger) {
    String _temp0 = intl.Intl.selectLogic(trigger, {
      'stress': 'Stress',
      'boredom': 'Ennui',
      'party': 'Soirée',
      'after_meal': 'Après le repas',
      'morning': 'Réveil',
      'screen': 'Écran',
      'social': 'Avec des potes',
      'tired': 'Fatigue',
      'other': 'Autre',
    });
    return '$_temp0';
  }

  @override
  String get cravingNoteLabel => 'Note (optionnel)';

  @override
  String get cravingResisted => 'J’ai résisté 💪';

  @override
  String get cravingGaveIn => 'J’ai craqué';

  @override
  String cravingSavedXp(int xp) {
    return 'Bien joué ! +$xp XP';
  }

  @override
  String get cravingSaved => 'Envie notée 📝';

  @override
  String get cravingJournalTitle => 'Journal des envies';

  @override
  String get cravingJournalEmpty =>
      'Aucune envie notée pour l’instant. Note la prochaine : c’est comme ça qu’on repère ses pièges.';

  @override
  String cravingStats(int resisted, int total, int percent) {
    return '$resisted/$total envies résistées ($percent %)';
  }

  @override
  String cravingTopTrigger(String trigger) {
    return 'Ton déclencheur n°1 : $trigger';
  }

  @override
  String get cravingResistedTag => 'Résistée';

  @override
  String get cravingGaveInTag => 'Craquée';

  @override
  String get cravingDelete => 'Supprimer';

  @override
  String get sosPickAddiction => 'SOS : envie de quoi ?';

  @override
  String get sosTitle => 'Tiens bon';

  @override
  String get sosSubtitle =>
      'Une envie dure rarement plus de quelques minutes. Respire avec le cercle.';

  @override
  String get sosBreathIn => 'Inspire';

  @override
  String get sosBreathHold => 'Bloque';

  @override
  String get sosBreathOut => 'Expire';

  @override
  String sosTimeLeft(String time) {
    return 'Encore $time';
  }

  @override
  String get sosTimeUp => 'Le plus dur est passé 💪';

  @override
  String get sosReasonsTitle => 'Tes raisons';

  @override
  String get sosNoReasons =>
      'Ajoute tes raisons d’arrêter dans ton profil : elles s’afficheront ici.';

  @override
  String get sosGroundingTitle => 'Ancrage 5-4-3-2-1';

  @override
  String get sosGrounding5 => '5 choses que tu vois';

  @override
  String get sosGrounding4 => '4 choses que tu peux toucher';

  @override
  String get sosGrounding3 => '3 sons que tu entends';

  @override
  String get sosGrounding2 => '2 odeurs que tu sens';

  @override
  String get sosGrounding1 => '1 goût dans ta bouche';

  @override
  String get sosSupportsReceived => 'Soutien reçu';

  @override
  String get sosResisted => 'J’ai tenu 💪';

  @override
  String get sosGaveIn => 'J’ai craqué';

  @override
  String get sosVictory => 'Victoire ! Envie résistée 🏆';

  @override
  String get sosLeaveConfirmTitle => 'Quitter le SOS ?';

  @override
  String get sosLeaveConfirmBody =>
      'Dis-nous comment ça s’est fini : ça compte pour ton journal.';

  @override
  String sosCardTitle(String username, String label) {
    return '$username traverse une envie ($label)';
  }

  @override
  String get sosCardSupport => 'Envoie-lui de la force';

  @override
  String sosCardSent(String emoji) {
    return 'Soutien envoyé $emoji';
  }

  @override
  String feedPledge(String username) {
    return '$username s’engage pour aujourd’hui 🤝';
  }

  @override
  String feedBadge(String username, String badge) {
    return '$username débloque le badge « $badge »';
  }

  @override
  String feedSos(String username, String label) {
    return '$username lance un SOS ($label). Envoie-lui de la force !';
  }

  @override
  String feedSosSupport(String username, String emoji, String to) {
    return '$username envoie $emoji à $to';
  }

  @override
  String feedSosResolved(String username, String label) {
    return '$username a résisté à son envie ($label) 🏆';
  }

  @override
  String feedQuestsAllDone(String username) {
    return '$username a bouclé toutes ses quêtes du jour ✅';
  }

  @override
  String get badgesTitle => 'Badges';

  @override
  String badgesProgress(int unlocked, int total) {
    return '$unlocked/$total débloqués';
  }

  @override
  String badgeName(String badge) {
    String _temp0 = intl.Intl.selectLogic(badge, {
      'first_pledge': 'Premier engagement',
      'pledge_streak_7': 'Parole tenue',
      'first_resist': 'Première victoire',
      'resist_10': 'Mur de briques',
      'sos_first': 'Appel à l\'aide',
      'helper': 'Pote en or',
      'streak_7': 'Une semaine',
      'streak_30': 'Un mois',
      'streak_90': 'Trois mois',
      'comeback': 'Comeback',
      'quest_streak_7': 'Régulier',
      'level_5': 'Niveau 5',
      'level_10': 'Niveau 10',
      'other': 'Badge',
    });
    return '$_temp0';
  }

  @override
  String badgeDescription(String badge) {
    String _temp0 = intl.Intl.selectLogic(badge, {
      'first_pledge': 'Faire ton premier engagement du matin.',
      'pledge_streak_7': 'T\'engager 7 jours d\'affilée.',
      'first_resist': 'Résister à ta première envie.',
      'resist_10': 'Résister à 10 envies.',
      'sos_first': 'Tenir bon grâce au SOS.',
      'helper': 'Soutenir 5 fois un pote en SOS.',
      'streak_7': '7 jours clean sur une addiction.',
      'streak_30': '30 jours clean sur une addiction.',
      'streak_90': '90 jours clean sur une addiction.',
      'comeback': '30 jours clean après une rechute.',
      'quest_streak_7': 'Boucler une quête 7 jours d\'affilée.',
      'level_5': 'Atteindre le niveau 5.',
      'level_10': 'Atteindre le niveau 10.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get badgeLocked => 'Pas encore débloqué';

  @override
  String badgeUnlockedOn(String date) {
    return 'Débloqué le $date';
  }

  @override
  String get questsTitle => 'Quêtes du jour';

  @override
  String questsSummary(int done, int total) {
    return '$done/$total quêtes';
  }

  @override
  String questsAllDoneHint(int xp) {
    return 'Boucle toutes tes quêtes (3 min.) : +$xp XP bonus';
  }

  @override
  String get questsAllDone => 'Journée bouclée ✅';

  @override
  String get questsEmpty =>
      'Ajoute tes premières quêtes : eau, sport, sommeil…';

  @override
  String get questsAdd => 'Ajouter une quête';

  @override
  String questStreak(int days) {
    return '🔥 $days j';
  }

  @override
  String questTypeLabel(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'water': 'Eau',
      'sport': 'Sport',
      'sleep': 'Sommeil',
      'steps': 'Pas',
      'meditation': 'Méditation',
      'reading': 'Lecture',
      'no_screen': 'Sans écran',
      'other': 'Perso',
    });
    return '$_temp0';
  }

  @override
  String get questFormNewTitle => 'Nouvelle quête';

  @override
  String get questFormEditTitle => 'Modifier la quête';

  @override
  String get questLabelField => 'Nom';

  @override
  String get questUnitField => 'Unité';

  @override
  String get questTargetField => 'Objectif par jour';

  @override
  String get questArchive => 'Archiver la quête';

  @override
  String questSetValueTitle(String label) {
    return '$label aujourd’hui';
  }

  @override
  String get questDone => 'Fait';

  @override
  String questsLimit(int max) {
    return 'Maximum $max quêtes actives.';
  }

  @override
  String get motivationsTitle => 'Mes raisons d’arrêter';

  @override
  String get motivationsSubtitle => 'Elles s’affichent pendant un SOS.';

  @override
  String get motivationsAdd => 'Ajouter une raison';

  @override
  String get motivationsHint => 'Ex : avoir du souffle au foot';

  @override
  String get motivationsEmpty => 'Aucune raison pour l’instant.';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get navCommunity => 'Classement';

  @override
  String get leaderboardEmpty => 'Personne dans le classement pour l’instant.';

  @override
  String get errorProfilePrivate => 'Ce profil est privé.';

  @override
  String get errorPlayerNotFound => 'Joueur introuvable.';

  @override
  String get sosCommunityNotified => 'Tout le monde est prévenu';

  @override
  String get sosPrivateNotShared => 'Profil privé : personne n’est prévenu';

  @override
  String playerPrivate(String username) {
    return 'Le profil de $username est privé 🔒';
  }

  @override
  String get playerPrivateBody =>
      'Ce profil est privé. Seuls son pseudo, son niveau et son XP apparaissent dans le classement.';

  @override
  String playerSince(String date) {
    return 'Sur Detox depuis le $date';
  }

  @override
  String get playerRankLabel => 'Rang';

  @override
  String get playerLevelLabel => 'Niveau';

  @override
  String get playerNoBadges => 'Aucun badge pour l’instant.';

  @override
  String get playerAddictionsTitle => 'Ses défis';

  @override
  String get playerNoAddictions => 'Aucune addiction publique.';

  @override
  String get profilePrivateToggle => 'Profil privé';

  @override
  String get profilePrivateOn =>
      'Tu restes dans le classement (pseudo, niveau, XP), mais personne ne peut ouvrir ton profil ni voir ton feed ou tes SOS.';

  @override
  String get profilePrivateOff =>
      'Tout le monde peut voir ton niveau, tes badges et tes addictions non privées.';

  @override
  String get onboardingQuestsTitle => 'Tes défis du jour';

  @override
  String get onboardingQuestsSubtitle =>
      'Les habitudes que tu veux tenir chaque jour. Chaque défi bouclé rapporte de l’XP, et tous les boucler donne un bonus.';

  @override
  String get onboardingQuestsNone =>
      'Aucun défi choisi : tu pourras en ajouter plus tard dans l’onglet Quêtes.';

  @override
  String get onboardingCustomQuestHint => 'Ex : prendre l’air 15 min';

  @override
  String get onboardingQuestToggleHint => 'À cocher une fois par jour.';

  @override
  String get onboardingPrefsTitle => 'Tes préférences';

  @override
  String get onboardingPrefsSubtitle =>
      'Tout reste modifiable plus tard dans ton profil.';

  @override
  String get onboardingMotivationsSubtitle =>
      'Pourquoi tu arrêtes ? Elles s’afficheront quand tu appuieras sur SOS. Optionnel.';

  @override
  String updateTitle(int build) {
    return 'Nouvelle version dispo (build $build)';
  }

  @override
  String get updateInstall => 'Installer';

  @override
  String get updateLater => 'Plus tard';

  @override
  String get updateDownloadHint =>
      'Téléchargement lancé : ouvre le fichier .apk depuis la notification pour installer. Tes données sont conservées.';

  @override
  String get updateOpenFailed => 'Impossible d’ouvrir le lien de mise à jour.';

  @override
  String get levelUpTitle => 'LEVEL UP !';

  @override
  String levelUpBody(int level) {
    return 'Tu passes niveau $level. Continue comme ça 💪';
  }

  @override
  String get levelUpContinue => 'Let’s go';
}
