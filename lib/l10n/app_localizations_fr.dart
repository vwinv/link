// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'DropOne';

  @override
  String get navCards => 'Cartes';

  @override
  String get navScan => 'Scan IA';

  @override
  String get navContacts => 'Contacts';

  @override
  String get navProfile => 'Profil';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileSectionAccount => 'COMPTE';

  @override
  String get profileSectionSettings => 'RÉGLAGES';

  @override
  String get profileTeamSpace => 'Espace équipe';

  @override
  String get profileManageWallet => 'Gérer le Wallet';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'Aucune notification pour le moment';

  @override
  String get notificationsLoadError =>
      'Impossible de charger les notifications';

  @override
  String get notificationsMarkAllRead => 'Tout lu';

  @override
  String get profileMyCards => 'Mes cartes';

  @override
  String get profilePrivacy => 'Confidentialité';

  @override
  String get privacyPolicyTitle => 'Confidentialité';

  @override
  String get profileLogout => 'Se déconnecter';

  @override
  String get profileDeleteAccount => 'Supprimer le compte';

  @override
  String get profileLanguage => 'Langue';

  @override
  String get profileEdit => 'Modifier';

  @override
  String get profilePremiumTitle => 'Passer à Premium';

  @override
  String get profilePremiumSubtitle => 'Portfolio, designs pro, couleurs…';

  @override
  String get profileTeamConfigure => 'Configurer votre équipe';

  @override
  String profileTeamMembers(String teamName, int count) {
    return '$teamName - $count membres';
  }

  @override
  String profileCardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartes',
      one: '1 carte',
    );
    return '$_temp0';
  }

  @override
  String get profilePrivacySoon =>
      'Paramètres de confidentialité bientôt disponibles';

  @override
  String get profileDeleteAccountTitle => 'Supprimer le compte';

  @override
  String get profileDeleteAccountMessage =>
      'Votre compte sera désactivé. Pour le récupérer, contactez-nous à contact@mega-sn.com.';

  @override
  String get profileDeleteAccountError =>
      'Impossible de supprimer le compte pour le moment';

  @override
  String get profileCreateCardFirst => 'Créez une carte pour commencer';

  @override
  String get profileCreateCardForWallet =>
      'Créez une carte avant d’utiliser le Wallet';

  @override
  String get commonBack => 'Retour';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get commonShare => 'Partager';

  @override
  String get commonContinue => 'Continuer';

  @override
  String get commonUnlock => 'Débloquer';

  @override
  String get cardKindPersonal => 'Carte perso';

  @override
  String get cardKindTeam => 'Carte équipe';

  @override
  String get cardKindMember => 'Carte membre';

  @override
  String get cardScopePersonal => 'Personnelle';

  @override
  String get cardScopeProfessional => 'Professionnelle';

  @override
  String get cardScopeMember => 'Membre';

  @override
  String get cardScopePersonalShort => 'Carte perso';

  @override
  String get cardScopeProfessionalShort => 'Carte pro';

  @override
  String get cardScopeMemberShort => 'Carte membre';

  @override
  String myCardsGreeting(String name) {
    return 'Bonjour, $name 👋';
  }

  @override
  String get myCardsTitle => 'Mes cartes';

  @override
  String get myCardsSharedContacts => 'CONTACTS PARTAGÉS';

  @override
  String get myCardsSeeAll => 'Tout voir';

  @override
  String get myCardsViews => 'Vues';

  @override
  String get myCardsShares => 'Partages';

  @override
  String get myCardsScans => 'Scans';

  @override
  String get myCardsNoContacts => 'Aucun contact pour le moment';

  @override
  String get myCardsProTitle => 'Carte professionnelle';

  @override
  String get myCardsPersonalTitle => 'Carte personnelle';

  @override
  String get myCardsPersonalSubtitle =>
      'Créez votre carte personnelle pour partager vos coordonnées et développer votre réseau.';

  @override
  String get myCardsCreatePersonal => 'Créer ma carte personnelle';

  @override
  String get myCardsProWithTeam =>
      'Votre espace équipe est prêt. Finalisez votre carte professionnelle pour continuer.';

  @override
  String get myCardsProWithoutTeam =>
      'Votre carte pro est liée à un espace équipe. Commencez par définir le nom, le logo et la couleur de marque.';

  @override
  String get myCardsCreatePro => 'Créer ma carte pro';

  @override
  String get myCardsEditTeam => 'Modifier l’équipe';

  @override
  String get myCardsContinueSetup => 'Continuer la configuration';

  @override
  String get myCardsSetupTeam => 'Configurer mon espace équipe';

  @override
  String get myCardTitle => 'Ma carte';

  @override
  String get myCardSocialNetworks => 'RÉSEAUX SOCIAUX';

  @override
  String get myCardPortfolio => 'PORTFOLIO';

  @override
  String get myCardPortfolioLinked =>
      'Votre portfolio est relié à cette carte.';

  @override
  String get myCardPortfolioPremium =>
      'Reliez votre portfolio à la carte avec Premium';

  @override
  String myCardSocialNotConfigured(String platform) {
    return '$platform n’est pas encore configuré';
  }

  @override
  String get myCardLinkOpenError => 'Impossible d’ouvrir ce lien';

  @override
  String get pickCardTitle => 'Choisir une carte';

  @override
  String get walletTitle => 'Wallet';

  @override
  String get walletAddApple => 'Ajouter à Apple Wallet';

  @override
  String get walletAddGoogle => 'Ajouter à Google Wallet';

  @override
  String get walletSubtitle =>
      'Accédez à votre carte depuis l’écran verrouillé, à tout moment.';

  @override
  String get walletAdding => 'Ajout en cours...';

  @override
  String walletAdded(String walletName) {
    return 'Carte ajoutée à $walletName.';
  }

  @override
  String get walletUnavailable => 'Wallet non disponible sur cet appareil.';

  @override
  String get walletAddError => 'Impossible d’ajouter la carte au Wallet.';

  @override
  String get walletAppleName => 'Apple Wallet';

  @override
  String get walletGoogleName => 'Google Wallet';

  @override
  String get editCardTitle => 'Modifier ma carte';

  @override
  String get editCardSubtitle =>
      'Ces informations apparaissent sur votre carte DropOne.';

  @override
  String get editCardFullName => 'Nom complet';

  @override
  String get editCardJobTitle => 'Fonction';

  @override
  String get editCardCompany => 'Entreprise';

  @override
  String get editCardEmail => 'E-mail';

  @override
  String get editCardPhone => 'Téléphone';

  @override
  String get editCardAddress => 'Adresse de l’entreprise';

  @override
  String get editCardCompanyLogo => 'LOGO ENTREPRISE';

  @override
  String get editCardChangeLogo => 'Changer le logo';

  @override
  String get editCardImportLogo => 'Importer un logo';

  @override
  String get editCardLogoHint => 'JPG, PNG - max 5 Mo';

  @override
  String get editCardRemoveLogo => 'Supprimer le logo';

  @override
  String get editCardRemovePhoto => 'Supprimer la photo';

  @override
  String get editCardSocialTitle => 'RÉSEAUX SOCIAUX';

  @override
  String get editCardSocialSubtitle =>
      'Ajoutez les liens à afficher sur votre carte.';

  @override
  String get editCardSaved => 'Informations de la carte enregistrées';

  @override
  String get editCardSaveError => 'Impossible d’enregistrer les informations';

  @override
  String get editCardNameRequired => 'Nom requis';

  @override
  String get editCardEmailRequired => 'E-mail requis';

  @override
  String get editCardEmailInvalid => 'E-mail invalide';

  @override
  String get editCardNoCard => 'Aucune carte à modifier';

  @override
  String editCardGalleryError(String message) {
    return 'Impossible d’ouvrir la galerie : $message';
  }

  @override
  String get contactsTitle => 'Contacts';

  @override
  String get contactsSearchHint => 'Rechercher un contact';

  @override
  String get contactsCountZero => 'Aucun contact enregistré';

  @override
  String get contactsCountOne => '1 contact enregistré';

  @override
  String contactsCountMany(int count) {
    return '$count contacts enregistrés';
  }

  @override
  String get contactsAll => 'TOUS LES CONTACTS';

  @override
  String get contactsScanPaperTitle => 'Scanner une carte papier';

  @override
  String get contactsScanPaperSubtitle => 'Numérisez un contact avec l’IA';

  @override
  String get contactsScanBannerTitle => 'Scanner une carte de visite';

  @override
  String get contactsScanBannerSubtitle =>
      'L’IA extrait les infos et crée un contact';

  @override
  String get contactsScanAction => 'Scanner';

  @override
  String get contactsEmpty => 'Aucun contact pour le moment';

  @override
  String get contactsEmptySearch => 'Aucun résultat pour cette recherche';

  @override
  String get contactDetailTitle => 'Fiche contact';

  @override
  String get contactDetailUntitled => 'Contact';

  @override
  String get contactDetailViewCard => 'Voir carte';

  @override
  String get contactDetailInfoTitle => 'Informations';

  @override
  String get contactDetailJob => 'Poste';

  @override
  String get contactDetailCompany => 'Entreprise';

  @override
  String get contactDetailPhone => 'Téléphone';

  @override
  String get contactDetailEmail => 'Email';

  @override
  String get contactDetailSource => 'Source';

  @override
  String get contactDetailAddedAt => 'Ajouté le';

  @override
  String get contactDetailSourceExchange => 'Échange Drop One';

  @override
  String get contactDetailSourceScan => 'Scan IA';

  @override
  String get contactDetailUnavailable => '-';

  @override
  String get contactDetailActionsTitle => 'Actions';

  @override
  String get contactDetailCall => 'Appeler';

  @override
  String get contactDetailSendEmail => 'Envoyer un email';

  @override
  String get contactDetailSendMessage => 'Envoyer un message';

  @override
  String get contactDetailShare => 'Partager le contact';

  @override
  String get contactDetailCopied => 'Contact copié dans le presse-papiers';

  @override
  String get myCardsRecentContacts => 'CONTACTS RÉCENTS';

  @override
  String get myCardsStatsSaved => 'Enregistrées';

  @override
  String get myCardsNoContactsDot => 'Aucun contact pour le moment.';

  @override
  String get myCardsSeeVisitors => 'Voir les visiteurs';

  @override
  String get myCardsSeeVisitorsSubtitle => 'Découvrez qui a vu votre carte';

  @override
  String get myCardsSeeStats => 'Voir vos statistiques';

  @override
  String get myCardsSeeStatsSubtitle => 'Découvrez qui a vu votre carte';

  @override
  String get myCardsMemberLogin => 'Se connecter à mon espace membre';

  @override
  String get myCardsMemberLoginSubtitle =>
      'Accédez à votre carte et votre équipe';

  @override
  String get memberHomeCardTab => 'Ma carte';

  @override
  String get memberHomeTeamTab => 'Mon équipe';

  @override
  String get memberHomeMyCardTitle => 'Ma carte';

  @override
  String get memberHomeTeamTitle => 'Mon équipe';

  @override
  String get memberHomeShare => 'Partager';

  @override
  String get memberHomeWallet => 'Wallet';

  @override
  String get memberHomeTotalViews => 'Vues totales';

  @override
  String get memberHomeUniquePeople => 'Personnes uniques';

  @override
  String get memberHomeViewersTitle => 'Personnes ayant vu ma carte';

  @override
  String get memberHomeSeeAll => 'Voir tout';

  @override
  String get memberHomeTeamOverview => 'Aperçu de l’équipe';

  @override
  String get memberHomeMembersLabel => 'Membres';

  @override
  String get memberHomeMembersListTitle => 'Membres de l’équipe';

  @override
  String get memberHomeNoCard => 'Aucune carte membre pour le moment.';

  @override
  String get memberHomeNoViewers => 'Personne n’a encore vu votre carte.';

  @override
  String get memberHomeToday => 'Aujourd’hui';

  @override
  String get memberHomeYesterday => 'Hier';

  @override
  String memberHomeDaysAgo(int count) {
    return '${count}j';
  }

  @override
  String get workspaceSwitchToPersonal => 'Mon espace perso';

  @override
  String get workspaceStayMember => 'Rester sur l’espace membre';

  @override
  String get workspaceMemberAccessBlocked =>
      'Accès membre indisponible. Demandez une nouvelle invitation à votre équipe.';

  @override
  String get teamInviteScreenTitle => 'Invitation à rejoindre une équipe';

  @override
  String get teamInvitationDeclinedBlocked =>
      'Invitation refusée. L’accès membre est bloqué jusqu’à une nouvelle invitation.';

  @override
  String get cardAnalyticsTitle => 'Statistiques';

  @override
  String get cardAnalyticsTotalViews => 'Total views';

  @override
  String get cardAnalyticsUniqueVisitors => 'Visiteurs uniques';

  @override
  String get cardAnalyticsSavedCards => 'Cartes enregistrées';

  @override
  String get cardAnalyticsShares => 'Partages';

  @override
  String cardAnalyticsWeekChange(String change) {
    return '$change% cette semaine';
  }

  @override
  String get cardAnalyticsPeriod7 => '7 jours';

  @override
  String get cardAnalyticsPeriod30 => '30 jours';

  @override
  String get cardAnalyticsPeriodCustom => 'Personnaliser';

  @override
  String get cardAnalyticsScopeAll => 'Tous';

  @override
  String get cardAnalyticsScopeTeam => 'Équipe';

  @override
  String get cardAnalyticsScopePersonal => 'Perso';

  @override
  String get cardAnalyticsScopeProfessional => 'Professionnel';

  @override
  String get cardAnalyticsShowVisitors =>
      'Afficher la liste des personnes qui ont vu votre carte';

  @override
  String get cardAnalyticsViewsEvolution => 'Évolution des vues';

  @override
  String get cardAnalyticsDiscoverySources => 'Sources de découverte';

  @override
  String get cardAnalyticsSeeAll => 'Voir tout';

  @override
  String get cardAnalyticsRealtimeTip =>
      'Les statistiques sont mises à jour en temps réel.';

  @override
  String get cardAnalyticsLoadError =>
      'Impossible de charger les statistiques.';

  @override
  String get cardAnalyticsSourceQr => 'QR Code';

  @override
  String get cardAnalyticsSourceShare => 'Partage direct';

  @override
  String get cardAnalyticsSourceLink => 'Lien';

  @override
  String get cardAnalyticsSourceNfc => 'NFC';

  @override
  String get cardAnalyticsSourceApp => 'Application';

  @override
  String get cardAnalyticsSourceOther => 'Autres';

  @override
  String get cardVisitorsTitle => 'Card views';

  @override
  String get cardVisitorsSearchHint => 'Rechercher un visiteur...';

  @override
  String get cardVisitorsTotalViews => 'Total views';

  @override
  String get cardVisitorsUnique => 'Visiteurs uniques';

  @override
  String get cardVisitorsSaved => 'Cartes enregistrées';

  @override
  String get cardVisitorsShares => 'Partages';

  @override
  String get cardVisitorsFilterAll => 'Tous';

  @override
  String get cardVisitorsFilterDropOne => 'Drop One';

  @override
  String get cardVisitorsFilterGuest => 'Sans compte';

  @override
  String get cardVisitorsToday => 'AUJOURD’HUI';

  @override
  String get cardVisitorsYesterday => 'HIER';

  @override
  String get cardVisitorsEmpty => 'Aucun visiteur pour le moment.';

  @override
  String get cardVisitorsLoadError => 'Impossible de charger les visiteurs.';

  @override
  String get cardVisitorDetailTitle => 'Détails du visiteur';

  @override
  String get cardVisitorDetailAnonymousName => 'Visiteur anonyme';

  @override
  String get cardVisitorDetailGuestBadge => 'Sans compte Drop One';

  @override
  String get cardVisitorDetailAnonymousSubtitle =>
      'Cette personne n\'a pas encore de compte Drop One.';

  @override
  String get cardVisitorDetailAnonymousTip =>
      'Une fois inscrit, vous pourrez voir son profil et entrer en contact.';

  @override
  String get cardVisitorDetailInviteCta => 'Inviter sur Drop One';

  @override
  String get cardVisitorDetailInviteShort => 'Inviter';

  @override
  String get cardVisitorDetailInviteBannerTitle => 'Invitez ce visiteur';

  @override
  String get cardVisitorDetailInviteBannerBody =>
      'Envoyez-lui une invitation pour qu\'il rejoigne Drop One et échangez facilement.';

  @override
  String get cardVisitorDetailViewCard => 'Voir carte';

  @override
  String get cardVisitorDetailConsultationTitle =>
      'Informations de consultation';

  @override
  String get cardVisitorDetailDate => 'Date';

  @override
  String get cardVisitorDetailTime => 'Heure';

  @override
  String get cardVisitorDetailMethod => 'Méthode';

  @override
  String get cardVisitorDetailDuration => 'Temps passé';

  @override
  String get cardVisitorDetailLocation => 'Localisation';

  @override
  String get cardVisitorDetailDevice => 'Appareil';

  @override
  String get cardVisitorDetailSaved => 'A enregistré votre carte';

  @override
  String get cardVisitorDetailShared => 'A partagé votre carte';

  @override
  String get cardVisitorDetailYes => 'Oui';

  @override
  String get cardVisitorDetailNo => 'Non';

  @override
  String get cardVisitorDetailUnavailable => '-';

  @override
  String get cardVisitorDetailMethodQr => 'QR Code';

  @override
  String get cardVisitorDetailMethodNfc => 'NFC';

  @override
  String get cardVisitorDetailMethodShare => 'Partage direct';

  @override
  String get cardVisitorDetailMethodApp => 'Application';

  @override
  String get cardVisitorDetailMethodLink => 'Lien partagé';

  @override
  String cardVisitorDetailDurationSeconds(int seconds) {
    return '$seconds s';
  }

  @override
  String cardVisitorDetailDurationMinutes(int minutes, int seconds) {
    return '$minutes min $seconds s';
  }

  @override
  String get cardVisitorDetailActionsTitle => 'Actions';

  @override
  String get cardVisitorDetailSendMessage => 'Envoyer un message';

  @override
  String get cardVisitorDetailAddContact => 'Ajouter aux contacts';

  @override
  String get cardVisitorDetailShareProfile => 'Partager son profil';

  @override
  String get cardVisitorDetailInviteShareSubject => 'Rejoins-moi sur Drop One';

  @override
  String cardVisitorDetailInviteShareText(
    String appStoreUrl,
    String playStoreUrl,
    String cardUrl,
  ) {
    return 'Salut ! Rejoins-moi sur Drop One pour échanger nos cartes facilement.\n\nTélécharge l\'app :\n• iOS : $appStoreUrl\n• Android : $playStoreUrl\n\nMa carte : $cardUrl';
  }

  @override
  String cardVisitorDetailMessageShareText(String name, String url) {
    return 'Voici le profil Drop One de $name : $url';
  }

  @override
  String cardVisitorDetailContactAdded(String name) {
    return '$name ajouté à vos contacts';
  }

  @override
  String get cardVisitorDetailContactError =>
      'Impossible d\'ajouter ce contact.';

  @override
  String get scanTitle => 'Scan IA';

  @override
  String get scanSubtitle => 'Scannez une carte papier pour l\'enregistrer.';

  @override
  String get scanScanCard => 'Scanner la carte';

  @override
  String get scanAnalyzing => 'Analyse de la carte…';

  @override
  String get scanNoTextDetected =>
      'Aucun texte détecté. Reprenez la photo avec un meilleur éclairage.';

  @override
  String get scanUnreadableCard =>
      'Carte difficile à lire. Vérifiez les champs avant d\'enregistrer.';

  @override
  String get scanOwnCardError =>
      'Vous ne pouvez pas scanner votre propre carte DropOne. Utilisez une carte papier d\'un autre contact.';

  @override
  String scanContactAddedNamed(String name) {
    return '$name ajouté à vos contacts';
  }

  @override
  String scanContactSavedToPhoneNamed(String name) {
    return '$name ajouté à vos contacts et au téléphone';
  }

  @override
  String get scanContactPhonePermissionDenied =>
      'Contact enregistré. Autorisez l\'accès aux contacts pour l\'ajouter aussi au téléphone.';

  @override
  String get scanReviewTitle => 'Vérifier le contact';

  @override
  String get scanReviewSubtitle =>
      'Corrigez les informations extraites de la carte avant d\'enregistrer.';

  @override
  String get scanReviewName => 'Nom complet';

  @override
  String get scanReviewJobTitle => 'Poste';

  @override
  String get scanReviewCompany => 'Entreprise';

  @override
  String get scanReviewEmail => 'E-mail';

  @override
  String get scanReviewPhone => 'Téléphone';

  @override
  String get scanReviewSave => 'Enregistrer';

  @override
  String get socialLinkedIn => 'LinkedIn';

  @override
  String get socialInstagram => 'Instagram';

  @override
  String get socialWhatsApp => 'WhatsApp';

  @override
  String get socialX => 'X';

  @override
  String get socialFacebook => 'Facebook';

  @override
  String get socialWebsite => 'Site web';

  @override
  String get commonSkip => 'Passer';

  @override
  String get commonStart => 'Commencer';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonFinish => 'Terminer';

  @override
  String get commonOrEmail => 'ou par e-mail';

  @override
  String get commonIncluded => 'Inclus';

  @override
  String get commonNotIncluded => 'Non inclus';

  @override
  String get commonIncludedFeminine => 'Incluse';

  @override
  String get commonUnlimited => 'Illimités';

  @override
  String get commonGoHome => 'Aller à l\'accueil';

  @override
  String get commonAlreadyAccount => 'Déjà un compte ? ';

  @override
  String get commonNoAccount => 'Pas de compte ? ';

  @override
  String get commonEmailHint => 'vous@exemple.com';

  @override
  String get commonPasswordHint => '••••••••';

  @override
  String get commonNameHint => 'Alex Moreau';

  @override
  String get authLoginTitle => 'Bon retour 👋';

  @override
  String get authLoginSubtitle => 'Connectez-vous pour accéder à vos cartes.';

  @override
  String get authPassword => 'Mot de passe';

  @override
  String get authPasswordRequired => 'Mot de passe requis';

  @override
  String get authForgotPassword => 'Mot de passe oublié ?';

  @override
  String get authForgotPasswordTitle => 'Mot de passe oublié';

  @override
  String get authForgotPasswordLead =>
      'Indiquez l’e-mail de votre compte. Nous vous enverrons un lien pour choisir un nouveau mot de passe.';

  @override
  String get authForgotPasswordSubmit => 'Envoyer le lien';

  @override
  String get authForgotPasswordSending => 'Envoi…';

  @override
  String authForgotPasswordSent(String email) {
    return 'Un e-mail a été envoyé à $email avec le lien de réinitialisation.';
  }

  @override
  String get authForgotPasswordEmailRequired => 'E-mail requis';

  @override
  String get authForgotPasswordEmailInvalid => 'E-mail invalide';

  @override
  String get authForgotPasswordBackToLogin => 'Retour à la connexion';

  @override
  String get authSignIn => 'Se connecter';

  @override
  String get authContinueApple => 'Continuer avec Apple';

  @override
  String get authContinueGoogle => 'Continuer avec Google';

  @override
  String get authGoogleNotConfigured =>
      'Google Sign-In n’est pas configuré. Ajoutez vos identifiants OAuth.';

  @override
  String get authAppleNotConfigured =>
      'Apple Sign-In n’est pas configuré sur le serveur.';

  @override
  String get authOAuthCancelled => 'Connexion annulée';

  @override
  String get authCreateAccount => 'Créer un compte';

  @override
  String get authRegisterTitle => 'Créons votre compte';

  @override
  String get authRegisterSubtitle => 'Quelques secondes et c\'est prêt.';

  @override
  String get authFullNameRequired => 'Nom complet requis';

  @override
  String get authPasswordMinLength => 'Minimum 8 caractères';

  @override
  String get authCreateMyAccount => 'Créer mon compte';

  @override
  String get authAccountDeleted =>
      'Ce compte a été supprimé. Veuillez nous contacter au contact@mega-sn.com si vous voulez récupérer votre compte.';

  @override
  String get accountTypeTitle => 'Comment allez-vous\nutiliser DropOne ?';

  @override
  String get accountTypeSubtitle => 'Vous pourrez changer à tout moment.';

  @override
  String get accountTypePersonalTitle => 'Pour moi';

  @override
  String get accountTypePersonalDescription =>
      'Une carte personnelle pour réseauter et partager.';

  @override
  String get accountTypeTeamTitle => 'Pour mon équipe';

  @override
  String get accountTypeTeamDescription =>
      'Cartes de marque centralisées pour toute l\'équipe.';

  @override
  String get accountTypeTeamBadge => 'Équipe';

  @override
  String get accountTypeMemberLogin => 'Se connecter en tant que membre';

  @override
  String get onboardingPage1Title =>
      'Votre carte de visite,\ntoujours sur vous';

  @override
  String get onboardingPage1Description =>
      'Créez une carte d\'identité numérique élégante en moins de 2 minutes.';

  @override
  String get onboardingPage2Title => 'Partagez en un instant';

  @override
  String get onboardingPage2Description =>
      'QR code, AirDrop ou lien - sans application pour vos contacts.';

  @override
  String get onboardingPage3Title => 'Gardez-la dans votre Wallet';

  @override
  String get onboardingPage3Description =>
      'Ajoutez votre carte à Apple Wallet et accédez-y depuis l\'écran verrouillé.';

  @override
  String get createCardPromptTitle => 'Créons votre carte';

  @override
  String get createCardPromptSubtitle =>
      'On démarre avec l\'essentiel, vous\npersonnaliserez ensuite.';

  @override
  String get createCardPromptButton => 'Créer ma carte';

  @override
  String get createCardHeaderTitle => 'Nouvelle carte';

  @override
  String get createCardStepInfo => 'Informations';

  @override
  String get createCardStepNetworks => 'Réseaux';

  @override
  String get createCardStepPortfolio => 'Portfolio';

  @override
  String get createCardYourInfoTitle => 'Vos informations';

  @override
  String get createCardYourInfoSubtitle =>
      'Elles apparaîtront sur votre carte.';

  @override
  String get createCardYourNetworksTitle => 'Vos réseaux';

  @override
  String get createCardSkipStep => 'Ignorer cette étape';

  @override
  String get createCardSuccessTitle => 'Votre carte est prête !';

  @override
  String get createCardSuccessSubtitle =>
      'Partagez-la ou ajoutez-la à votre Wallet dès maintenant.';

  @override
  String get createCardAddToWallet => 'Ajouter au Wallet';

  @override
  String get walletAddedGeneric => 'Carte ajoutée à votre Wallet.';

  @override
  String get shareCardTitle => 'Partager ma carte';

  @override
  String get shareCardQrHint =>
      'Faites scanner ce code - aucune app requise pour vos contacts.';

  @override
  String get shareOptionMessage => 'Message';

  @override
  String get shareOptionAirDrop => 'AirDrop';

  @override
  String shareQuotaReached(int max) {
    return 'Quota de $max partages atteint.';
  }

  @override
  String shareQuotaUsed(int used, int max) {
    return '$used / $max partages';
  }

  @override
  String get shareSeePremium => 'Passer à Premium';

  @override
  String get shareBlockedHint => 'Passez à Premium pour partager sans limite.';

  @override
  String scanQuotaReached(int max) {
    return 'Quota de $max scans IA atteint pour ce mois.';
  }

  @override
  String get scanContactAdded => 'Contact ajouté depuis le scan IA';

  @override
  String get scanRecordError => 'Impossible d\'enregistrer le scan';

  @override
  String get scanStart => 'Lancer un scan';

  @override
  String get scanSeePremium => 'Voir les offres Premium';

  @override
  String get scanUnlimited => 'Scans illimités';

  @override
  String get scanNotIncluded => 'Scan IA non inclus';

  @override
  String scanUsedCount(int used, int max) {
    return '$used / $max scans utilisés par mois';
  }

  @override
  String get premiumTitle => 'DropOne Premium';

  @override
  String get premiumStart => 'Démarrer Premium';

  @override
  String get premiumProceedToPayment => 'Procéder au paiement';

  @override
  String get premiumCheckoutRedirect =>
      'Finalisez le paiement dans votre navigateur, puis revenez dans l\'application.';

  @override
  String get premiumCheckoutLaunchError =>
      'Impossible d\'ouvrir la page de paiement';

  @override
  String get premiumRenewalNote =>
      'Renouvellement automatique. Annulable à tout moment dans les réglages.';

  @override
  String get premiumLoadError => 'Impossible de charger les offres.';

  @override
  String premiumActivated(String title, String price) {
    return 'Premium $title ($price) activé';
  }

  @override
  String get premiumSubscribeError => 'Impossible de créer l\'abonnement';

  @override
  String get premiumNoOffers => 'Aucune offre configurée pour le moment';

  @override
  String get premiumFeatureType => 'Type';

  @override
  String get premiumFeatureScans => 'Scans IA';

  @override
  String get premiumFeatureUsers => 'Utilisateurs';

  @override
  String get premiumFeatureCustomization => 'Personnalisation';

  @override
  String get premiumFeaturePortfolio => 'Portfolio';

  @override
  String get premiumFeatureWallet => 'Wallet';

  @override
  String get premiumFeatureAnalytics => 'Statistiques';

  @override
  String get premiumFeatureVisitors => 'Visiteurs détaillés';

  @override
  String get premiumFeatureSocial => 'Réseaux sociaux';

  @override
  String get premiumSocialUnlock => 'Ajoutez vos réseaux sociaux avec Premium';

  @override
  String get premiumSocialSubtitle =>
      'LinkedIn, Instagram, WhatsApp et plus encore.';

  @override
  String get premiumNoPricing => 'Aucun tarif configuré';

  @override
  String get premiumAudienceTeam => 'Équipe';

  @override
  String get premiumAudiencePersonal => 'Personnel';

  @override
  String premiumTeamMembers(int count) {
    return 'Jusqu\'à $count membres';
  }

  @override
  String premiumSeatsFrom(int min) {
    return 'À partir de $min utilisateurs';
  }

  @override
  String premiumSeatsRange(int min, int max) {
    return 'De $min à $max utilisateurs';
  }

  @override
  String get premiumSeatsPickerTitle => 'Nombre d\'utilisateurs';

  @override
  String premiumSeatsIncludedHint(int count) {
    return '$count inclus - non diminuable';
  }

  @override
  String premiumSeatsTotal(String amount) {
    return 'Total : $amount';
  }

  @override
  String premiumScansPerPeriod(int count) {
    return '$count / mois';
  }

  @override
  String get premiumOneUser => '1 utilisateur';

  @override
  String get premiumBadge => 'Premium';

  @override
  String get premiumPortfolioLinked => 'Portfolio relié à la carte';

  @override
  String get premiumSeeOffers => 'Voir les offres Premium';

  @override
  String get premiumPortfolioSubtitle =>
      'Reliez vos projets et réalisations à votre carte.';

  @override
  String get customizeTitle => 'Personnaliser';

  @override
  String get customizeStyleSection => 'STYLE DE CARTE';

  @override
  String get customizeOptionsSection => 'OPTIONS';

  @override
  String get customizeSaved => 'Carte enregistrée';

  @override
  String get customizeSyncError =>
      'Modifications appliquées, synchronisation impossible';

  @override
  String get customizeProDesigns => 'Designs professionnels';

  @override
  String get customizeProDesignsSubtitle =>
      'Modèles premium prêts à l\'emploi.';

  @override
  String get customizeShowQr => 'Afficher le QR code';

  @override
  String get customizeCardBadge => 'Badge de la carte';

  @override
  String get teamMembersLoadError => 'Impossible de charger les membres';

  @override
  String get teamMembersSubscriptionRequired =>
      'Un abonnement équipe actif est requis pour ajouter des membres.';

  @override
  String teamMembersSeatLimitReached(int max) {
    return 'Limite de $max sièges atteinte. Passez à une offre supérieure.';
  }

  @override
  String get teamMembersAddTitle => 'Ajouter un membre';

  @override
  String get teamMembersAddSubtitle =>
      'Envoyez une invitation par e-mail. La personne devra l’accepter pour rejoindre l’équipe.';

  @override
  String get teamMembersFullNameHint => 'Nina Ba';

  @override
  String get teamMembersJobTitleHint => 'Commerciale';

  @override
  String get teamMembersEmailHint => 'nina@megasn.com';

  @override
  String get teamMembersInvite => 'Inviter';

  @override
  String get teamMembersSendInvitation => 'Envoyer l’invitation';

  @override
  String get teamMembersSetAdmin => 'Définir comme admin';

  @override
  String get teamMembersSetAdminSubtitle => 'Peut gérer l’équipe et la marque.';

  @override
  String get teamMembersRemoveMember => 'Retirer de l’équipe';

  @override
  String get teamMembersRemoveTitle => 'Retirer ce membre ?';

  @override
  String teamMembersRemoveMessage(String name) {
    return 'Voulez-vous retirer $name de l’équipe ?';
  }

  @override
  String get teamMembersRemoveSuccess => 'Membre retiré de l’équipe';

  @override
  String get teamMembersRemoveError => 'Impossible de retirer ce membre';

  @override
  String get teamMembersCancelInvite => 'Annuler l’invitation';

  @override
  String get teamMembersCancelInviteTitle => 'Annuler l’invitation ?';

  @override
  String teamMembersCancelInviteMessage(String name) {
    return 'Voulez-vous annuler l’invitation envoyée à $name ?';
  }

  @override
  String get teamMembersCancelInviteSuccess => 'Invitation annulée';

  @override
  String get teamMembersInviteSuccess => 'Invitation envoyée';

  @override
  String get teamMembersInviteError => 'Impossible d’envoyer l’invitation';

  @override
  String get teamMembersSectionTitle => 'MEMBRES DE L’ÉQUIPE';

  @override
  String teamMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count membres',
      one: '1 membre',
    );
    return '$_temp0';
  }

  @override
  String get teamMembersSeatsUsed => 'Sièges utilisés';

  @override
  String get teamMembersStatusActive => 'Actif';

  @override
  String get teamMembersStatusPending => 'En attente';

  @override
  String get teamInvitationTitle => 'Invitation équipe';

  @override
  String teamInvitationMessage(String teamName) {
    return 'Vous avez été invité à rejoindre l’équipe $teamName.';
  }

  @override
  String teamInvitationMessageWithInviter(String inviterName, String teamName) {
    return '$inviterName vous invite à rejoindre l’équipe $teamName.';
  }

  @override
  String get teamInvitationAccept => 'Accepter';

  @override
  String get teamInvitationDecline => 'Refuser';

  @override
  String teamInvitationAccepted(String teamName) {
    return 'Vous avez rejoint $teamName';
  }

  @override
  String get teamInvitationDeclined => 'Invitation refusée';

  @override
  String get teamInvitationRespondError =>
      'Impossible de répondre à l’invitation';

  @override
  String get setupTeamNameRequired => 'Nom d’équipe requis';

  @override
  String get setupTeamNameLabel => 'NOM DE L’ÉQUIPE';

  @override
  String get setupTeamNameHint => 'Mega SN';

  @override
  String get setupTeamTitleCreate => 'Configurez votre espace équipe';

  @override
  String get setupTeamTitleEdit => 'Finalisez votre espace équipe';

  @override
  String get setupTeamSubtitleCreate =>
      'Définissez le logo et la couleur des cartes de votre équipe.';

  @override
  String get setupTeamSubtitleEdit =>
      'Reprennez la configuration de votre équipe ou passez à l’étape suivante.';

  @override
  String get setupTeamLogoLabel => 'LOGO';

  @override
  String get setupTeamColorLabel => 'COULEUR DES CARTES DE L’ÉQUIPE';

  @override
  String get setupTeamColorSubtitle =>
      'Appliquée aux cartes de tous les membres de l’équipe.';

  @override
  String setupTeamCreated(String name) {
    return 'Équipe « $name » créée';
  }

  @override
  String setupTeamUpdated(String name) {
    return 'Équipe « $name » mise à jour';
  }

  @override
  String get setupTeamCreateError => 'Impossible de créer l’équipe';

  @override
  String get setupTeamAppRestart =>
      'Relancez l’app complètement (arrêt + flutter run) puis réessayez.';

  @override
  String get proDesignsSubtitle => '30 modèles Premium prêts à l’emploi';

  @override
  String get proDesignsCardTypeSection => 'TYPE DE CARTE';

  @override
  String get proDesignsConfiguringTeam =>
      'Configuration de votre espace équipe…';

  @override
  String get proDesignsOpenTeamSetup =>
      'Ouvrez la configuration équipe pour créer votre carte pro.';

  @override
  String proDesignsTemplatesSection(int count) {
    return '$count MODÈLES - APERÇU EN TEMPS RÉEL';
  }

  @override
  String get proDesignsCompanyColors => 'Couleurs de l’entreprise';

  @override
  String get proDesignsCompanyColorsSubtitle =>
      'Recolore les modèles compatibles avec votre charte';

  @override
  String get proDesignPreviewCompanyColorRequired =>
      'Choisissez une couleur entreprise avant d’appliquer.';

  @override
  String proDesignPreviewApplied(String name) {
    return 'Modèle $name appliqué';
  }

  @override
  String get proDesignPreviewApplyError =>
      'Impossible d’appliquer le modèle. Réessayez.';

  @override
  String get proDesignPreviewRecipientPreview => 'Aperçu destinataire';

  @override
  String get proDesignPreviewUseTemplate => 'Utiliser ce modèle';
}
