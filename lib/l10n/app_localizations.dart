import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
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
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'DropOne'**
  String get appTitle;

  /// No description provided for @navCards.
  ///
  /// In fr, this message translates to:
  /// **'Cartes'**
  String get navCards;

  /// No description provided for @navScan.
  ///
  /// In fr, this message translates to:
  /// **'Scan IA'**
  String get navScan;

  /// No description provided for @navContacts.
  ///
  /// In fr, this message translates to:
  /// **'Contacts'**
  String get navContacts;

  /// No description provided for @navProfile.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @profileTitle.
  ///
  /// In fr, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @profileSectionAccount.
  ///
  /// In fr, this message translates to:
  /// **'COMPTE'**
  String get profileSectionAccount;

  /// No description provided for @profileSectionSettings.
  ///
  /// In fr, this message translates to:
  /// **'RÉGLAGES'**
  String get profileSectionSettings;

  /// No description provided for @profileTeamSpace.
  ///
  /// In fr, this message translates to:
  /// **'Espace équipe'**
  String get profileTeamSpace;

  /// No description provided for @profileManageWallet.
  ///
  /// In fr, this message translates to:
  /// **'Gérer le Wallet'**
  String get profileManageWallet;

  /// No description provided for @profileNotifications.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @notificationsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune notification pour le moment'**
  String get notificationsEmpty;

  /// No description provided for @notificationsLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les notifications'**
  String get notificationsLoadError;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In fr, this message translates to:
  /// **'Tout lu'**
  String get notificationsMarkAllRead;

  /// No description provided for @profileMyCards.
  ///
  /// In fr, this message translates to:
  /// **'Mes cartes'**
  String get profileMyCards;

  /// No description provided for @profilePrivacy.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité'**
  String get profilePrivacy;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Confidentialité'**
  String get privacyPolicyTitle;

  /// No description provided for @profileLogout.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get profileLogout;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le compte'**
  String get profileDeleteAccount;

  /// No description provided for @profileLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get profileLanguage;

  /// No description provided for @profileEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get profileEdit;

  /// No description provided for @profilePremiumTitle.
  ///
  /// In fr, this message translates to:
  /// **'Passer à Premium'**
  String get profilePremiumTitle;

  /// No description provided for @profilePremiumSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Portfolio, designs pro, couleurs…'**
  String get profilePremiumSubtitle;

  /// No description provided for @profileTeamConfigure.
  ///
  /// In fr, this message translates to:
  /// **'Configurer votre équipe'**
  String get profileTeamConfigure;

  /// No description provided for @profileTeamMembers.
  ///
  /// In fr, this message translates to:
  /// **'{teamName} - {count} membres'**
  String profileTeamMembers(String teamName, int count);

  /// No description provided for @profileCardsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 carte} other{{count} cartes}}'**
  String profileCardsCount(int count);

  /// No description provided for @profilePrivacySoon.
  ///
  /// In fr, this message translates to:
  /// **'Paramètres de confidentialité bientôt disponibles'**
  String get profilePrivacySoon;

  /// No description provided for @profileDeleteAccountTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le compte'**
  String get profileDeleteAccountTitle;

  /// No description provided for @profileDeleteAccountMessage.
  ///
  /// In fr, this message translates to:
  /// **'Votre compte sera désactivé. Pour le récupérer, contactez-nous à contact@mega-sn.com.'**
  String get profileDeleteAccountMessage;

  /// No description provided for @profileDeleteAccountError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de supprimer le compte pour le moment'**
  String get profileDeleteAccountError;

  /// No description provided for @profileCreateCardFirst.
  ///
  /// In fr, this message translates to:
  /// **'Créez une carte pour commencer'**
  String get profileCreateCardFirst;

  /// No description provided for @profileCreateCardForWallet.
  ///
  /// In fr, this message translates to:
  /// **'Créez une carte avant d’utiliser le Wallet'**
  String get profileCreateCardForWallet;

  /// No description provided for @commonBack.
  ///
  /// In fr, this message translates to:
  /// **'Retour'**
  String get commonBack;

  /// No description provided for @commonCancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get commonDelete;

  /// No description provided for @commonSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get commonSave;

  /// No description provided for @commonEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get commonEdit;

  /// No description provided for @commonShare.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get commonShare;

  /// No description provided for @commonContinue.
  ///
  /// In fr, this message translates to:
  /// **'Continuer'**
  String get commonContinue;

  /// No description provided for @commonUnlock.
  ///
  /// In fr, this message translates to:
  /// **'Débloquer'**
  String get commonUnlock;

  /// No description provided for @cardKindPersonal.
  ///
  /// In fr, this message translates to:
  /// **'Carte perso'**
  String get cardKindPersonal;

  /// No description provided for @cardKindTeam.
  ///
  /// In fr, this message translates to:
  /// **'Carte équipe'**
  String get cardKindTeam;

  /// No description provided for @cardKindMember.
  ///
  /// In fr, this message translates to:
  /// **'Carte membre'**
  String get cardKindMember;

  /// No description provided for @cardScopePersonal.
  ///
  /// In fr, this message translates to:
  /// **'Personnelle'**
  String get cardScopePersonal;

  /// No description provided for @cardScopeProfessional.
  ///
  /// In fr, this message translates to:
  /// **'Professionnelle'**
  String get cardScopeProfessional;

  /// No description provided for @cardScopeMember.
  ///
  /// In fr, this message translates to:
  /// **'Membre'**
  String get cardScopeMember;

  /// No description provided for @cardScopePersonalShort.
  ///
  /// In fr, this message translates to:
  /// **'Carte perso'**
  String get cardScopePersonalShort;

  /// No description provided for @cardScopeProfessionalShort.
  ///
  /// In fr, this message translates to:
  /// **'Carte pro'**
  String get cardScopeProfessionalShort;

  /// No description provided for @cardScopeMemberShort.
  ///
  /// In fr, this message translates to:
  /// **'Carte membre'**
  String get cardScopeMemberShort;

  /// No description provided for @myCardsGreeting.
  ///
  /// In fr, this message translates to:
  /// **'Bonjour, {name} 👋'**
  String myCardsGreeting(String name);

  /// No description provided for @myCardsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mes cartes'**
  String get myCardsTitle;

  /// No description provided for @myCardsSharedContacts.
  ///
  /// In fr, this message translates to:
  /// **'CONTACTS PARTAGÉS'**
  String get myCardsSharedContacts;

  /// No description provided for @myCardsSeeAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout voir'**
  String get myCardsSeeAll;

  /// No description provided for @myCardsViews.
  ///
  /// In fr, this message translates to:
  /// **'Vues'**
  String get myCardsViews;

  /// No description provided for @myCardsShares.
  ///
  /// In fr, this message translates to:
  /// **'Partages'**
  String get myCardsShares;

  /// No description provided for @myCardsScans.
  ///
  /// In fr, this message translates to:
  /// **'Scans'**
  String get myCardsScans;

  /// No description provided for @myCardsNoContacts.
  ///
  /// In fr, this message translates to:
  /// **'Aucun contact pour le moment'**
  String get myCardsNoContacts;

  /// No description provided for @myCardsProTitle.
  ///
  /// In fr, this message translates to:
  /// **'Carte professionnelle'**
  String get myCardsProTitle;

  /// No description provided for @myCardsPersonalTitle.
  ///
  /// In fr, this message translates to:
  /// **'Carte personnelle'**
  String get myCardsPersonalTitle;

  /// No description provided for @myCardsPersonalSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre carte personnelle pour partager vos coordonnées et développer votre réseau.'**
  String get myCardsPersonalSubtitle;

  /// No description provided for @myCardsCreatePersonal.
  ///
  /// In fr, this message translates to:
  /// **'Créer ma carte personnelle'**
  String get myCardsCreatePersonal;

  /// No description provided for @myCardsProWithTeam.
  ///
  /// In fr, this message translates to:
  /// **'Votre espace équipe est prêt. Finalisez votre carte professionnelle pour continuer.'**
  String get myCardsProWithTeam;

  /// No description provided for @myCardsProWithoutTeam.
  ///
  /// In fr, this message translates to:
  /// **'Votre carte pro est liée à un espace équipe. Commencez par définir le nom, le logo et la couleur de marque.'**
  String get myCardsProWithoutTeam;

  /// No description provided for @myCardsCreatePro.
  ///
  /// In fr, this message translates to:
  /// **'Créer ma carte pro'**
  String get myCardsCreatePro;

  /// No description provided for @myCardsEditTeam.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l’équipe'**
  String get myCardsEditTeam;

  /// No description provided for @myCardsContinueSetup.
  ///
  /// In fr, this message translates to:
  /// **'Continuer la configuration'**
  String get myCardsContinueSetup;

  /// No description provided for @myCardsSetupTeam.
  ///
  /// In fr, this message translates to:
  /// **'Configurer mon espace équipe'**
  String get myCardsSetupTeam;

  /// No description provided for @myCardTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ma carte'**
  String get myCardTitle;

  /// No description provided for @myCardSocialNetworks.
  ///
  /// In fr, this message translates to:
  /// **'RÉSEAUX SOCIAUX'**
  String get myCardSocialNetworks;

  /// No description provided for @myCardPortfolio.
  ///
  /// In fr, this message translates to:
  /// **'PORTFOLIO'**
  String get myCardPortfolio;

  /// No description provided for @myCardPortfolioLinked.
  ///
  /// In fr, this message translates to:
  /// **'Votre portfolio est relié à cette carte.'**
  String get myCardPortfolioLinked;

  /// No description provided for @myCardPortfolioPremium.
  ///
  /// In fr, this message translates to:
  /// **'Reliez votre portfolio à la carte avec Premium'**
  String get myCardPortfolioPremium;

  /// No description provided for @myCardSocialNotConfigured.
  ///
  /// In fr, this message translates to:
  /// **'{platform} n’est pas encore configuré'**
  String myCardSocialNotConfigured(String platform);

  /// No description provided for @myCardLinkOpenError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d’ouvrir ce lien'**
  String get myCardLinkOpenError;

  /// No description provided for @pickCardTitle.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une carte'**
  String get pickCardTitle;

  /// No description provided for @walletTitle.
  ///
  /// In fr, this message translates to:
  /// **'Wallet'**
  String get walletTitle;

  /// No description provided for @walletAddApple.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter à Apple Wallet'**
  String get walletAddApple;

  /// No description provided for @walletAddGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter à Google Wallet'**
  String get walletAddGoogle;

  /// No description provided for @walletSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Accédez à votre carte depuis l’écran verrouillé, à tout moment.'**
  String get walletSubtitle;

  /// No description provided for @walletAdding.
  ///
  /// In fr, this message translates to:
  /// **'Ajout en cours...'**
  String get walletAdding;

  /// No description provided for @walletAdded.
  ///
  /// In fr, this message translates to:
  /// **'Carte ajoutée à {walletName}.'**
  String walletAdded(String walletName);

  /// No description provided for @walletUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Wallet non disponible sur cet appareil.'**
  String get walletUnavailable;

  /// No description provided for @walletAddError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d’ajouter la carte au Wallet.'**
  String get walletAddError;

  /// No description provided for @walletAppleName.
  ///
  /// In fr, this message translates to:
  /// **'Apple Wallet'**
  String get walletAppleName;

  /// No description provided for @walletGoogleName.
  ///
  /// In fr, this message translates to:
  /// **'Google Wallet'**
  String get walletGoogleName;

  /// No description provided for @editCardTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier ma carte'**
  String get editCardTitle;

  /// No description provided for @editCardSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ces informations apparaissent sur votre carte DropOne.'**
  String get editCardSubtitle;

  /// No description provided for @editCardFullName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get editCardFullName;

  /// No description provided for @editCardJobTitle.
  ///
  /// In fr, this message translates to:
  /// **'Fonction'**
  String get editCardJobTitle;

  /// No description provided for @editCardCompany.
  ///
  /// In fr, this message translates to:
  /// **'Entreprise'**
  String get editCardCompany;

  /// No description provided for @editCardEmail.
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get editCardEmail;

  /// No description provided for @editCardPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get editCardPhone;

  /// No description provided for @editCardAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse de l’entreprise'**
  String get editCardAddress;

  /// No description provided for @editCardCompanyLogo.
  ///
  /// In fr, this message translates to:
  /// **'LOGO ENTREPRISE'**
  String get editCardCompanyLogo;

  /// No description provided for @editCardChangeLogo.
  ///
  /// In fr, this message translates to:
  /// **'Changer le logo'**
  String get editCardChangeLogo;

  /// No description provided for @editCardImportLogo.
  ///
  /// In fr, this message translates to:
  /// **'Importer un logo'**
  String get editCardImportLogo;

  /// No description provided for @editCardLogoHint.
  ///
  /// In fr, this message translates to:
  /// **'JPG, PNG - max 5 Mo'**
  String get editCardLogoHint;

  /// No description provided for @editCardRemoveLogo.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le logo'**
  String get editCardRemoveLogo;

  /// No description provided for @editCardRemovePhoto.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer la photo'**
  String get editCardRemovePhoto;

  /// No description provided for @editCardSocialTitle.
  ///
  /// In fr, this message translates to:
  /// **'RÉSEAUX SOCIAUX'**
  String get editCardSocialTitle;

  /// No description provided for @editCardSocialSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez les liens à afficher sur votre carte.'**
  String get editCardSocialSubtitle;

  /// No description provided for @editCardSaved.
  ///
  /// In fr, this message translates to:
  /// **'Informations de la carte enregistrées'**
  String get editCardSaved;

  /// No description provided for @editCardSaveError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d’enregistrer les informations'**
  String get editCardSaveError;

  /// No description provided for @editCardNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Nom requis'**
  String get editCardNameRequired;

  /// No description provided for @editCardEmailRequired.
  ///
  /// In fr, this message translates to:
  /// **'E-mail requis'**
  String get editCardEmailRequired;

  /// No description provided for @editCardEmailInvalid.
  ///
  /// In fr, this message translates to:
  /// **'E-mail invalide'**
  String get editCardEmailInvalid;

  /// No description provided for @editCardNoCard.
  ///
  /// In fr, this message translates to:
  /// **'Aucune carte à modifier'**
  String get editCardNoCard;

  /// No description provided for @editCardGalleryError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d’ouvrir la galerie : {message}'**
  String editCardGalleryError(String message);

  /// No description provided for @contactsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Contacts'**
  String get contactsTitle;

  /// No description provided for @contactsSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un contact'**
  String get contactsSearchHint;

  /// No description provided for @contactsCountZero.
  ///
  /// In fr, this message translates to:
  /// **'Aucun contact enregistré'**
  String get contactsCountZero;

  /// No description provided for @contactsCountOne.
  ///
  /// In fr, this message translates to:
  /// **'1 contact enregistré'**
  String get contactsCountOne;

  /// No description provided for @contactsCountMany.
  ///
  /// In fr, this message translates to:
  /// **'{count} contacts enregistrés'**
  String contactsCountMany(int count);

  /// No description provided for @contactsAll.
  ///
  /// In fr, this message translates to:
  /// **'TOUS LES CONTACTS'**
  String get contactsAll;

  /// No description provided for @contactsScanPaperTitle.
  ///
  /// In fr, this message translates to:
  /// **'Scanner une carte papier'**
  String get contactsScanPaperTitle;

  /// No description provided for @contactsScanPaperSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Numérisez un contact avec l’IA'**
  String get contactsScanPaperSubtitle;

  /// No description provided for @contactsScanBannerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Scanner une carte de visite'**
  String get contactsScanBannerTitle;

  /// No description provided for @contactsScanBannerSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'L’IA extrait les infos et crée un contact'**
  String get contactsScanBannerSubtitle;

  /// No description provided for @contactsScanAction.
  ///
  /// In fr, this message translates to:
  /// **'Scanner'**
  String get contactsScanAction;

  /// No description provided for @contactsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun contact pour le moment'**
  String get contactsEmpty;

  /// No description provided for @contactsEmptySearch.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat pour cette recherche'**
  String get contactsEmptySearch;

  /// No description provided for @contactDetailTitle.
  ///
  /// In fr, this message translates to:
  /// **'Fiche contact'**
  String get contactDetailTitle;

  /// No description provided for @contactDetailUntitled.
  ///
  /// In fr, this message translates to:
  /// **'Contact'**
  String get contactDetailUntitled;

  /// No description provided for @contactDetailViewCard.
  ///
  /// In fr, this message translates to:
  /// **'Voir carte'**
  String get contactDetailViewCard;

  /// No description provided for @contactDetailInfoTitle.
  ///
  /// In fr, this message translates to:
  /// **'Informations'**
  String get contactDetailInfoTitle;

  /// No description provided for @contactDetailJob.
  ///
  /// In fr, this message translates to:
  /// **'Poste'**
  String get contactDetailJob;

  /// No description provided for @contactDetailCompany.
  ///
  /// In fr, this message translates to:
  /// **'Entreprise'**
  String get contactDetailCompany;

  /// No description provided for @contactDetailPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get contactDetailPhone;

  /// No description provided for @contactDetailEmail.
  ///
  /// In fr, this message translates to:
  /// **'Email'**
  String get contactDetailEmail;

  /// No description provided for @contactDetailSource.
  ///
  /// In fr, this message translates to:
  /// **'Source'**
  String get contactDetailSource;

  /// No description provided for @contactDetailAddedAt.
  ///
  /// In fr, this message translates to:
  /// **'Ajouté le'**
  String get contactDetailAddedAt;

  /// No description provided for @contactDetailSourceExchange.
  ///
  /// In fr, this message translates to:
  /// **'Échange Drop One'**
  String get contactDetailSourceExchange;

  /// No description provided for @contactDetailSourceScan.
  ///
  /// In fr, this message translates to:
  /// **'Scan IA'**
  String get contactDetailSourceScan;

  /// No description provided for @contactDetailUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'-'**
  String get contactDetailUnavailable;

  /// No description provided for @contactDetailActionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Actions'**
  String get contactDetailActionsTitle;

  /// No description provided for @contactDetailCall.
  ///
  /// In fr, this message translates to:
  /// **'Appeler'**
  String get contactDetailCall;

  /// No description provided for @contactDetailSendEmail.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer un email'**
  String get contactDetailSendEmail;

  /// No description provided for @contactDetailSendMessage.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer un message'**
  String get contactDetailSendMessage;

  /// No description provided for @contactDetailShare.
  ///
  /// In fr, this message translates to:
  /// **'Partager le contact'**
  String get contactDetailShare;

  /// No description provided for @contactDetailCopied.
  ///
  /// In fr, this message translates to:
  /// **'Contact copié dans le presse-papiers'**
  String get contactDetailCopied;

  /// No description provided for @myCardsRecentContacts.
  ///
  /// In fr, this message translates to:
  /// **'CONTACTS RÉCENTS'**
  String get myCardsRecentContacts;

  /// No description provided for @myCardsStatsSaved.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrées'**
  String get myCardsStatsSaved;

  /// No description provided for @myCardsNoContactsDot.
  ///
  /// In fr, this message translates to:
  /// **'Aucun contact pour le moment.'**
  String get myCardsNoContactsDot;

  /// No description provided for @myCardsSeeVisitors.
  ///
  /// In fr, this message translates to:
  /// **'Voir les visiteurs'**
  String get myCardsSeeVisitors;

  /// No description provided for @myCardsSeeVisitorsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Découvrez qui a vu votre carte'**
  String get myCardsSeeVisitorsSubtitle;

  /// No description provided for @myCardsSeeStats.
  ///
  /// In fr, this message translates to:
  /// **'Voir vos statistiques'**
  String get myCardsSeeStats;

  /// No description provided for @myCardsSeeStatsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Découvrez qui a vu votre carte'**
  String get myCardsSeeStatsSubtitle;

  /// No description provided for @myCardsMemberLogin.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter à mon espace membre'**
  String get myCardsMemberLogin;

  /// No description provided for @myCardsMemberLoginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Accédez à votre carte et votre équipe'**
  String get myCardsMemberLoginSubtitle;

  /// No description provided for @memberHomeCardTab.
  ///
  /// In fr, this message translates to:
  /// **'Ma carte'**
  String get memberHomeCardTab;

  /// No description provided for @memberHomeTeamTab.
  ///
  /// In fr, this message translates to:
  /// **'Mon équipe'**
  String get memberHomeTeamTab;

  /// No description provided for @memberHomeMyCardTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ma carte'**
  String get memberHomeMyCardTitle;

  /// No description provided for @memberHomeTeamTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon équipe'**
  String get memberHomeTeamTitle;

  /// No description provided for @memberHomeShare.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get memberHomeShare;

  /// No description provided for @memberHomeWallet.
  ///
  /// In fr, this message translates to:
  /// **'Wallet'**
  String get memberHomeWallet;

  /// No description provided for @memberHomeTotalViews.
  ///
  /// In fr, this message translates to:
  /// **'Vues totales'**
  String get memberHomeTotalViews;

  /// No description provided for @memberHomeUniquePeople.
  ///
  /// In fr, this message translates to:
  /// **'Personnes uniques'**
  String get memberHomeUniquePeople;

  /// No description provided for @memberHomeViewersTitle.
  ///
  /// In fr, this message translates to:
  /// **'Personnes ayant vu ma carte'**
  String get memberHomeViewersTitle;

  /// No description provided for @memberHomeSeeAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get memberHomeSeeAll;

  /// No description provided for @memberHomeTeamOverview.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu de l’équipe'**
  String get memberHomeTeamOverview;

  /// No description provided for @memberHomeMembersLabel.
  ///
  /// In fr, this message translates to:
  /// **'Membres'**
  String get memberHomeMembersLabel;

  /// No description provided for @memberHomeMembersListTitle.
  ///
  /// In fr, this message translates to:
  /// **'Membres de l’équipe'**
  String get memberHomeMembersListTitle;

  /// No description provided for @memberHomeNoCard.
  ///
  /// In fr, this message translates to:
  /// **'Aucune carte membre pour le moment.'**
  String get memberHomeNoCard;

  /// No description provided for @memberHomeNoViewers.
  ///
  /// In fr, this message translates to:
  /// **'Personne n’a encore vu votre carte.'**
  String get memberHomeNoViewers;

  /// No description provided for @memberHomeToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd’hui'**
  String get memberHomeToday;

  /// No description provided for @memberHomeYesterday.
  ///
  /// In fr, this message translates to:
  /// **'Hier'**
  String get memberHomeYesterday;

  /// No description provided for @memberHomeDaysAgo.
  ///
  /// In fr, this message translates to:
  /// **'{count}j'**
  String memberHomeDaysAgo(int count);

  /// No description provided for @workspaceSwitchToPersonal.
  ///
  /// In fr, this message translates to:
  /// **'Mon espace perso'**
  String get workspaceSwitchToPersonal;

  /// No description provided for @workspaceStayMember.
  ///
  /// In fr, this message translates to:
  /// **'Rester sur l’espace membre'**
  String get workspaceStayMember;

  /// No description provided for @workspaceMemberAccessBlocked.
  ///
  /// In fr, this message translates to:
  /// **'Accès membre indisponible. Demandez une nouvelle invitation à votre équipe.'**
  String get workspaceMemberAccessBlocked;

  /// No description provided for @teamInviteScreenTitle.
  ///
  /// In fr, this message translates to:
  /// **'Invitation à rejoindre une équipe'**
  String get teamInviteScreenTitle;

  /// No description provided for @teamInvitationDeclinedBlocked.
  ///
  /// In fr, this message translates to:
  /// **'Invitation refusée. L’accès membre est bloqué jusqu’à une nouvelle invitation.'**
  String get teamInvitationDeclinedBlocked;

  /// No description provided for @cardAnalyticsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get cardAnalyticsTitle;

  /// No description provided for @cardAnalyticsTotalViews.
  ///
  /// In fr, this message translates to:
  /// **'Total views'**
  String get cardAnalyticsTotalViews;

  /// No description provided for @cardAnalyticsUniqueVisitors.
  ///
  /// In fr, this message translates to:
  /// **'Visiteurs uniques'**
  String get cardAnalyticsUniqueVisitors;

  /// No description provided for @cardAnalyticsSavedCards.
  ///
  /// In fr, this message translates to:
  /// **'Cartes enregistrées'**
  String get cardAnalyticsSavedCards;

  /// No description provided for @cardAnalyticsShares.
  ///
  /// In fr, this message translates to:
  /// **'Partages'**
  String get cardAnalyticsShares;

  /// No description provided for @cardAnalyticsWeekChange.
  ///
  /// In fr, this message translates to:
  /// **'{change}% cette semaine'**
  String cardAnalyticsWeekChange(String change);

  /// No description provided for @cardAnalyticsPeriod7.
  ///
  /// In fr, this message translates to:
  /// **'7 jours'**
  String get cardAnalyticsPeriod7;

  /// No description provided for @cardAnalyticsPeriod30.
  ///
  /// In fr, this message translates to:
  /// **'30 jours'**
  String get cardAnalyticsPeriod30;

  /// No description provided for @cardAnalyticsPeriodCustom.
  ///
  /// In fr, this message translates to:
  /// **'Personnaliser'**
  String get cardAnalyticsPeriodCustom;

  /// No description provided for @cardAnalyticsScopeAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get cardAnalyticsScopeAll;

  /// No description provided for @cardAnalyticsScopeTeam.
  ///
  /// In fr, this message translates to:
  /// **'Équipe'**
  String get cardAnalyticsScopeTeam;

  /// No description provided for @cardAnalyticsScopePersonal.
  ///
  /// In fr, this message translates to:
  /// **'Perso'**
  String get cardAnalyticsScopePersonal;

  /// No description provided for @cardAnalyticsScopeProfessional.
  ///
  /// In fr, this message translates to:
  /// **'Professionnel'**
  String get cardAnalyticsScopeProfessional;

  /// No description provided for @cardAnalyticsShowVisitors.
  ///
  /// In fr, this message translates to:
  /// **'Afficher la liste des personnes qui ont vu votre carte'**
  String get cardAnalyticsShowVisitors;

  /// No description provided for @cardAnalyticsViewsEvolution.
  ///
  /// In fr, this message translates to:
  /// **'Évolution des vues'**
  String get cardAnalyticsViewsEvolution;

  /// No description provided for @cardAnalyticsDiscoverySources.
  ///
  /// In fr, this message translates to:
  /// **'Sources de découverte'**
  String get cardAnalyticsDiscoverySources;

  /// No description provided for @cardAnalyticsSeeAll.
  ///
  /// In fr, this message translates to:
  /// **'Voir tout'**
  String get cardAnalyticsSeeAll;

  /// No description provided for @cardAnalyticsRealtimeTip.
  ///
  /// In fr, this message translates to:
  /// **'Les statistiques sont mises à jour en temps réel.'**
  String get cardAnalyticsRealtimeTip;

  /// No description provided for @cardAnalyticsLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les statistiques.'**
  String get cardAnalyticsLoadError;

  /// No description provided for @cardAnalyticsSourceQr.
  ///
  /// In fr, this message translates to:
  /// **'QR Code'**
  String get cardAnalyticsSourceQr;

  /// No description provided for @cardAnalyticsSourceShare.
  ///
  /// In fr, this message translates to:
  /// **'Partage direct'**
  String get cardAnalyticsSourceShare;

  /// No description provided for @cardAnalyticsSourceLink.
  ///
  /// In fr, this message translates to:
  /// **'Lien'**
  String get cardAnalyticsSourceLink;

  /// No description provided for @cardAnalyticsSourceNfc.
  ///
  /// In fr, this message translates to:
  /// **'NFC'**
  String get cardAnalyticsSourceNfc;

  /// No description provided for @cardAnalyticsSourceApp.
  ///
  /// In fr, this message translates to:
  /// **'Application'**
  String get cardAnalyticsSourceApp;

  /// No description provided for @cardAnalyticsSourceOther.
  ///
  /// In fr, this message translates to:
  /// **'Autres'**
  String get cardAnalyticsSourceOther;

  /// No description provided for @cardVisitorsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Card views'**
  String get cardVisitorsTitle;

  /// No description provided for @cardVisitorsSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un visiteur...'**
  String get cardVisitorsSearchHint;

  /// No description provided for @cardVisitorsTotalViews.
  ///
  /// In fr, this message translates to:
  /// **'Total views'**
  String get cardVisitorsTotalViews;

  /// No description provided for @cardVisitorsUnique.
  ///
  /// In fr, this message translates to:
  /// **'Visiteurs uniques'**
  String get cardVisitorsUnique;

  /// No description provided for @cardVisitorsSaved.
  ///
  /// In fr, this message translates to:
  /// **'Cartes enregistrées'**
  String get cardVisitorsSaved;

  /// No description provided for @cardVisitorsShares.
  ///
  /// In fr, this message translates to:
  /// **'Partages'**
  String get cardVisitorsShares;

  /// No description provided for @cardVisitorsFilterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get cardVisitorsFilterAll;

  /// No description provided for @cardVisitorsFilterDropOne.
  ///
  /// In fr, this message translates to:
  /// **'Drop One'**
  String get cardVisitorsFilterDropOne;

  /// No description provided for @cardVisitorsFilterGuest.
  ///
  /// In fr, this message translates to:
  /// **'Sans compte'**
  String get cardVisitorsFilterGuest;

  /// No description provided for @cardVisitorsToday.
  ///
  /// In fr, this message translates to:
  /// **'AUJOURD’HUI'**
  String get cardVisitorsToday;

  /// No description provided for @cardVisitorsYesterday.
  ///
  /// In fr, this message translates to:
  /// **'HIER'**
  String get cardVisitorsYesterday;

  /// No description provided for @cardVisitorsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun visiteur pour le moment.'**
  String get cardVisitorsEmpty;

  /// No description provided for @cardVisitorsLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les visiteurs.'**
  String get cardVisitorsLoadError;

  /// No description provided for @cardVisitorDetailTitle.
  ///
  /// In fr, this message translates to:
  /// **'Détails du visiteur'**
  String get cardVisitorDetailTitle;

  /// No description provided for @cardVisitorDetailAnonymousName.
  ///
  /// In fr, this message translates to:
  /// **'Visiteur anonyme'**
  String get cardVisitorDetailAnonymousName;

  /// No description provided for @cardVisitorDetailGuestBadge.
  ///
  /// In fr, this message translates to:
  /// **'Sans compte Drop One'**
  String get cardVisitorDetailGuestBadge;

  /// No description provided for @cardVisitorDetailAnonymousSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Cette personne n\'a pas encore de compte Drop One.'**
  String get cardVisitorDetailAnonymousSubtitle;

  /// No description provided for @cardVisitorDetailAnonymousTip.
  ///
  /// In fr, this message translates to:
  /// **'Une fois inscrit, vous pourrez voir son profil et entrer en contact.'**
  String get cardVisitorDetailAnonymousTip;

  /// No description provided for @cardVisitorDetailInviteCta.
  ///
  /// In fr, this message translates to:
  /// **'Inviter sur Drop One'**
  String get cardVisitorDetailInviteCta;

  /// No description provided for @cardVisitorDetailInviteShort.
  ///
  /// In fr, this message translates to:
  /// **'Inviter'**
  String get cardVisitorDetailInviteShort;

  /// No description provided for @cardVisitorDetailInviteBannerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Invitez ce visiteur'**
  String get cardVisitorDetailInviteBannerTitle;

  /// No description provided for @cardVisitorDetailInviteBannerBody.
  ///
  /// In fr, this message translates to:
  /// **'Envoyez-lui une invitation pour qu\'il rejoigne Drop One et échangez facilement.'**
  String get cardVisitorDetailInviteBannerBody;

  /// No description provided for @cardVisitorDetailViewCard.
  ///
  /// In fr, this message translates to:
  /// **'Voir carte'**
  String get cardVisitorDetailViewCard;

  /// No description provided for @cardVisitorDetailConsultationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Informations de consultation'**
  String get cardVisitorDetailConsultationTitle;

  /// No description provided for @cardVisitorDetailDate.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get cardVisitorDetailDate;

  /// No description provided for @cardVisitorDetailTime.
  ///
  /// In fr, this message translates to:
  /// **'Heure'**
  String get cardVisitorDetailTime;

  /// No description provided for @cardVisitorDetailMethod.
  ///
  /// In fr, this message translates to:
  /// **'Méthode'**
  String get cardVisitorDetailMethod;

  /// No description provided for @cardVisitorDetailDuration.
  ///
  /// In fr, this message translates to:
  /// **'Temps passé'**
  String get cardVisitorDetailDuration;

  /// No description provided for @cardVisitorDetailLocation.
  ///
  /// In fr, this message translates to:
  /// **'Localisation'**
  String get cardVisitorDetailLocation;

  /// No description provided for @cardVisitorDetailDevice.
  ///
  /// In fr, this message translates to:
  /// **'Appareil'**
  String get cardVisitorDetailDevice;

  /// No description provided for @cardVisitorDetailSaved.
  ///
  /// In fr, this message translates to:
  /// **'A enregistré votre carte'**
  String get cardVisitorDetailSaved;

  /// No description provided for @cardVisitorDetailShared.
  ///
  /// In fr, this message translates to:
  /// **'A partagé votre carte'**
  String get cardVisitorDetailShared;

  /// No description provided for @cardVisitorDetailYes.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get cardVisitorDetailYes;

  /// No description provided for @cardVisitorDetailNo.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get cardVisitorDetailNo;

  /// No description provided for @cardVisitorDetailUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'-'**
  String get cardVisitorDetailUnavailable;

  /// No description provided for @cardVisitorDetailMethodQr.
  ///
  /// In fr, this message translates to:
  /// **'QR Code'**
  String get cardVisitorDetailMethodQr;

  /// No description provided for @cardVisitorDetailMethodNfc.
  ///
  /// In fr, this message translates to:
  /// **'NFC'**
  String get cardVisitorDetailMethodNfc;

  /// No description provided for @cardVisitorDetailMethodShare.
  ///
  /// In fr, this message translates to:
  /// **'Partage direct'**
  String get cardVisitorDetailMethodShare;

  /// No description provided for @cardVisitorDetailMethodApp.
  ///
  /// In fr, this message translates to:
  /// **'Application'**
  String get cardVisitorDetailMethodApp;

  /// No description provided for @cardVisitorDetailMethodLink.
  ///
  /// In fr, this message translates to:
  /// **'Lien partagé'**
  String get cardVisitorDetailMethodLink;

  /// No description provided for @cardVisitorDetailDurationSeconds.
  ///
  /// In fr, this message translates to:
  /// **'{seconds} s'**
  String cardVisitorDetailDurationSeconds(int seconds);

  /// No description provided for @cardVisitorDetailDurationMinutes.
  ///
  /// In fr, this message translates to:
  /// **'{minutes} min {seconds} s'**
  String cardVisitorDetailDurationMinutes(int minutes, int seconds);

  /// No description provided for @cardVisitorDetailActionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Actions'**
  String get cardVisitorDetailActionsTitle;

  /// No description provided for @cardVisitorDetailSendMessage.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer un message'**
  String get cardVisitorDetailSendMessage;

  /// No description provided for @cardVisitorDetailAddContact.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter aux contacts'**
  String get cardVisitorDetailAddContact;

  /// No description provided for @cardVisitorDetailShareProfile.
  ///
  /// In fr, this message translates to:
  /// **'Partager son profil'**
  String get cardVisitorDetailShareProfile;

  /// No description provided for @cardVisitorDetailInviteShareSubject.
  ///
  /// In fr, this message translates to:
  /// **'Rejoins-moi sur Drop One'**
  String get cardVisitorDetailInviteShareSubject;

  /// No description provided for @cardVisitorDetailInviteShareText.
  ///
  /// In fr, this message translates to:
  /// **'Salut ! Rejoins-moi sur Drop One pour échanger nos cartes facilement.\n\nTélécharge l\'app :\n• iOS : {appStoreUrl}\n• Android : {playStoreUrl}\n\nMa carte : {cardUrl}'**
  String cardVisitorDetailInviteShareText(
    String appStoreUrl,
    String playStoreUrl,
    String cardUrl,
  );

  /// No description provided for @cardVisitorDetailMessageShareText.
  ///
  /// In fr, this message translates to:
  /// **'Voici le profil Drop One de {name} : {url}'**
  String cardVisitorDetailMessageShareText(String name, String url);

  /// No description provided for @cardVisitorDetailContactAdded.
  ///
  /// In fr, this message translates to:
  /// **'{name} ajouté à vos contacts'**
  String cardVisitorDetailContactAdded(String name);

  /// No description provided for @cardVisitorDetailContactError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ajouter ce contact.'**
  String get cardVisitorDetailContactError;

  /// No description provided for @scanTitle.
  ///
  /// In fr, this message translates to:
  /// **'Scan IA'**
  String get scanTitle;

  /// No description provided for @scanSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Scannez une carte papier pour l\'enregistrer.'**
  String get scanSubtitle;

  /// No description provided for @scanScanCard.
  ///
  /// In fr, this message translates to:
  /// **'Scanner la carte'**
  String get scanScanCard;

  /// No description provided for @scanAnalyzing.
  ///
  /// In fr, this message translates to:
  /// **'Analyse de la carte…'**
  String get scanAnalyzing;

  /// No description provided for @scanNoTextDetected.
  ///
  /// In fr, this message translates to:
  /// **'Aucun texte détecté. Reprenez la photo avec un meilleur éclairage.'**
  String get scanNoTextDetected;

  /// No description provided for @scanUnreadableCard.
  ///
  /// In fr, this message translates to:
  /// **'Carte difficile à lire. Vérifiez les champs avant d\'enregistrer.'**
  String get scanUnreadableCard;

  /// No description provided for @scanOwnCardError.
  ///
  /// In fr, this message translates to:
  /// **'Vous ne pouvez pas scanner votre propre carte DropOne. Utilisez une carte papier d\'un autre contact.'**
  String get scanOwnCardError;

  /// No description provided for @scanContactAddedNamed.
  ///
  /// In fr, this message translates to:
  /// **'{name} ajouté à vos contacts'**
  String scanContactAddedNamed(String name);

  /// No description provided for @scanContactSavedToPhoneNamed.
  ///
  /// In fr, this message translates to:
  /// **'{name} ajouté à vos contacts et au téléphone'**
  String scanContactSavedToPhoneNamed(String name);

  /// No description provided for @scanContactPhonePermissionDenied.
  ///
  /// In fr, this message translates to:
  /// **'Contact enregistré. Autorisez l\'accès aux contacts pour l\'ajouter aussi au téléphone.'**
  String get scanContactPhonePermissionDenied;

  /// No description provided for @scanReviewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier le contact'**
  String get scanReviewTitle;

  /// No description provided for @scanReviewSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Corrigez les informations extraites de la carte avant d\'enregistrer.'**
  String get scanReviewSubtitle;

  /// No description provided for @scanReviewName.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet'**
  String get scanReviewName;

  /// No description provided for @scanReviewJobTitle.
  ///
  /// In fr, this message translates to:
  /// **'Poste'**
  String get scanReviewJobTitle;

  /// No description provided for @scanReviewCompany.
  ///
  /// In fr, this message translates to:
  /// **'Entreprise'**
  String get scanReviewCompany;

  /// No description provided for @scanReviewEmail.
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get scanReviewEmail;

  /// No description provided for @scanReviewPhone.
  ///
  /// In fr, this message translates to:
  /// **'Téléphone'**
  String get scanReviewPhone;

  /// No description provided for @scanReviewSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get scanReviewSave;

  /// No description provided for @socialLinkedIn.
  ///
  /// In fr, this message translates to:
  /// **'LinkedIn'**
  String get socialLinkedIn;

  /// No description provided for @socialInstagram.
  ///
  /// In fr, this message translates to:
  /// **'Instagram'**
  String get socialInstagram;

  /// No description provided for @socialWhatsApp.
  ///
  /// In fr, this message translates to:
  /// **'WhatsApp'**
  String get socialWhatsApp;

  /// No description provided for @socialX.
  ///
  /// In fr, this message translates to:
  /// **'X'**
  String get socialX;

  /// No description provided for @socialFacebook.
  ///
  /// In fr, this message translates to:
  /// **'Facebook'**
  String get socialFacebook;

  /// No description provided for @socialWebsite.
  ///
  /// In fr, this message translates to:
  /// **'Site web'**
  String get socialWebsite;

  /// No description provided for @commonSkip.
  ///
  /// In fr, this message translates to:
  /// **'Passer'**
  String get commonSkip;

  /// No description provided for @commonStart.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get commonStart;

  /// No description provided for @commonRetry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get commonRetry;

  /// No description provided for @commonFinish.
  ///
  /// In fr, this message translates to:
  /// **'Terminer'**
  String get commonFinish;

  /// No description provided for @commonOrEmail.
  ///
  /// In fr, this message translates to:
  /// **'ou par e-mail'**
  String get commonOrEmail;

  /// No description provided for @commonIncluded.
  ///
  /// In fr, this message translates to:
  /// **'Inclus'**
  String get commonIncluded;

  /// No description provided for @commonNotIncluded.
  ///
  /// In fr, this message translates to:
  /// **'Non inclus'**
  String get commonNotIncluded;

  /// No description provided for @commonIncludedFeminine.
  ///
  /// In fr, this message translates to:
  /// **'Incluse'**
  String get commonIncludedFeminine;

  /// No description provided for @commonUnlimited.
  ///
  /// In fr, this message translates to:
  /// **'Illimités'**
  String get commonUnlimited;

  /// No description provided for @commonGoHome.
  ///
  /// In fr, this message translates to:
  /// **'Aller à l\'accueil'**
  String get commonGoHome;

  /// No description provided for @commonAlreadyAccount.
  ///
  /// In fr, this message translates to:
  /// **'Déjà un compte ? '**
  String get commonAlreadyAccount;

  /// No description provided for @commonNoAccount.
  ///
  /// In fr, this message translates to:
  /// **'Pas de compte ? '**
  String get commonNoAccount;

  /// No description provided for @commonEmailHint.
  ///
  /// In fr, this message translates to:
  /// **'vous@exemple.com'**
  String get commonEmailHint;

  /// No description provided for @commonPasswordHint.
  ///
  /// In fr, this message translates to:
  /// **'••••••••'**
  String get commonPasswordHint;

  /// No description provided for @commonNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Alex Moreau'**
  String get commonNameHint;

  /// No description provided for @authLoginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bon retour 👋'**
  String get authLoginTitle;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Connectez-vous pour accéder à vos cartes.'**
  String get authLoginSubtitle;

  /// No description provided for @authPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get authPassword;

  /// No description provided for @authPasswordRequired.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe requis'**
  String get authPasswordRequired;

  /// No description provided for @authForgotPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ?'**
  String get authForgotPassword;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié'**
  String get authForgotPasswordTitle;

  /// No description provided for @authForgotPasswordLead.
  ///
  /// In fr, this message translates to:
  /// **'Indiquez l’e-mail de votre compte. Nous vous enverrons un lien pour choisir un nouveau mot de passe.'**
  String get authForgotPasswordLead;

  /// No description provided for @authForgotPasswordSubmit.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer le lien'**
  String get authForgotPasswordSubmit;

  /// No description provided for @authForgotPasswordSending.
  ///
  /// In fr, this message translates to:
  /// **'Envoi…'**
  String get authForgotPasswordSending;

  /// No description provided for @authForgotPasswordSent.
  ///
  /// In fr, this message translates to:
  /// **'Un e-mail a été envoyé à {email} avec le lien de réinitialisation.'**
  String authForgotPasswordSent(String email);

  /// No description provided for @authForgotPasswordEmailRequired.
  ///
  /// In fr, this message translates to:
  /// **'E-mail requis'**
  String get authForgotPasswordEmailRequired;

  /// No description provided for @authForgotPasswordEmailInvalid.
  ///
  /// In fr, this message translates to:
  /// **'E-mail invalide'**
  String get authForgotPasswordEmailInvalid;

  /// No description provided for @authForgotPasswordBackToLogin.
  ///
  /// In fr, this message translates to:
  /// **'Retour à la connexion'**
  String get authForgotPasswordBackToLogin;

  /// No description provided for @authSignIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get authSignIn;

  /// No description provided for @authContinueApple.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Apple'**
  String get authContinueApple;

  /// No description provided for @authContinueGoogle.
  ///
  /// In fr, this message translates to:
  /// **'Continuer avec Google'**
  String get authContinueGoogle;

  /// No description provided for @authGoogleNotConfigured.
  ///
  /// In fr, this message translates to:
  /// **'Google Sign-In n’est pas configuré. Ajoutez vos identifiants OAuth.'**
  String get authGoogleNotConfigured;

  /// No description provided for @authAppleNotConfigured.
  ///
  /// In fr, this message translates to:
  /// **'Apple Sign-In n’est pas configuré sur le serveur.'**
  String get authAppleNotConfigured;

  /// No description provided for @authOAuthCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Connexion annulée'**
  String get authOAuthCancelled;

  /// No description provided for @authCreateAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer un compte'**
  String get authCreateAccount;

  /// No description provided for @authRegisterTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créons votre compte'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Quelques secondes et c\'est prêt.'**
  String get authRegisterSubtitle;

  /// No description provided for @authFullNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Nom complet requis'**
  String get authFullNameRequired;

  /// No description provided for @authPasswordMinLength.
  ///
  /// In fr, this message translates to:
  /// **'Minimum 8 caractères'**
  String get authPasswordMinLength;

  /// No description provided for @authCreateMyAccount.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon compte'**
  String get authCreateMyAccount;

  /// No description provided for @authAccountDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Ce compte a été supprimé. Veuillez nous contacter au contact@mega-sn.com si vous voulez récupérer votre compte.'**
  String get authAccountDeleted;

  /// No description provided for @accountTypeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Comment allez-vous\nutiliser DropOne ?'**
  String get accountTypeTitle;

  /// No description provided for @accountTypeSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vous pourrez changer à tout moment.'**
  String get accountTypeSubtitle;

  /// No description provided for @accountTypePersonalTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pour moi'**
  String get accountTypePersonalTitle;

  /// No description provided for @accountTypePersonalDescription.
  ///
  /// In fr, this message translates to:
  /// **'Une carte personnelle pour réseauter et partager.'**
  String get accountTypePersonalDescription;

  /// No description provided for @accountTypeTeamTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pour mon équipe'**
  String get accountTypeTeamTitle;

  /// No description provided for @accountTypeTeamDescription.
  ///
  /// In fr, this message translates to:
  /// **'Cartes de marque centralisées pour toute l\'équipe.'**
  String get accountTypeTeamDescription;

  /// No description provided for @accountTypeTeamBadge.
  ///
  /// In fr, this message translates to:
  /// **'Équipe'**
  String get accountTypeTeamBadge;

  /// No description provided for @accountTypeMemberLogin.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter en tant que membre'**
  String get accountTypeMemberLogin;

  /// No description provided for @onboardingPage1Title.
  ///
  /// In fr, this message translates to:
  /// **'Votre carte de visite,\ntoujours sur vous'**
  String get onboardingPage1Title;

  /// No description provided for @onboardingPage1Description.
  ///
  /// In fr, this message translates to:
  /// **'Créez une carte d\'identité numérique élégante en moins de 2 minutes.'**
  String get onboardingPage1Description;

  /// No description provided for @onboardingPage2Title.
  ///
  /// In fr, this message translates to:
  /// **'Partagez en un instant'**
  String get onboardingPage2Title;

  /// No description provided for @onboardingPage2Description.
  ///
  /// In fr, this message translates to:
  /// **'QR code, AirDrop ou lien - sans application pour vos contacts.'**
  String get onboardingPage2Description;

  /// No description provided for @onboardingPage3Title.
  ///
  /// In fr, this message translates to:
  /// **'Gardez-la dans votre Wallet'**
  String get onboardingPage3Title;

  /// No description provided for @onboardingPage3Description.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez votre carte à Apple Wallet et accédez-y depuis l\'écran verrouillé.'**
  String get onboardingPage3Description;

  /// No description provided for @createCardPromptTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créons votre carte'**
  String get createCardPromptTitle;

  /// No description provided for @createCardPromptSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'On démarre avec l\'essentiel, vous\npersonnaliserez ensuite.'**
  String get createCardPromptSubtitle;

  /// No description provided for @createCardPromptButton.
  ///
  /// In fr, this message translates to:
  /// **'Créer ma carte'**
  String get createCardPromptButton;

  /// No description provided for @createCardHeaderTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle carte'**
  String get createCardHeaderTitle;

  /// No description provided for @createCardStepInfo.
  ///
  /// In fr, this message translates to:
  /// **'Informations'**
  String get createCardStepInfo;

  /// No description provided for @createCardStepNetworks.
  ///
  /// In fr, this message translates to:
  /// **'Réseaux'**
  String get createCardStepNetworks;

  /// No description provided for @createCardStepPortfolio.
  ///
  /// In fr, this message translates to:
  /// **'Portfolio'**
  String get createCardStepPortfolio;

  /// No description provided for @createCardYourInfoTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos informations'**
  String get createCardYourInfoTitle;

  /// No description provided for @createCardYourInfoSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Elles apparaîtront sur votre carte.'**
  String get createCardYourInfoSubtitle;

  /// No description provided for @createCardYourNetworksTitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos réseaux'**
  String get createCardYourNetworksTitle;

  /// No description provided for @createCardSkipStep.
  ///
  /// In fr, this message translates to:
  /// **'Ignorer cette étape'**
  String get createCardSkipStep;

  /// No description provided for @createCardSuccessTitle.
  ///
  /// In fr, this message translates to:
  /// **'Votre carte est prête !'**
  String get createCardSuccessTitle;

  /// No description provided for @createCardSuccessSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Partagez-la ou ajoutez-la à votre Wallet dès maintenant.'**
  String get createCardSuccessSubtitle;

  /// No description provided for @createCardAddToWallet.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter au Wallet'**
  String get createCardAddToWallet;

  /// No description provided for @walletAddedGeneric.
  ///
  /// In fr, this message translates to:
  /// **'Carte ajoutée à votre Wallet.'**
  String get walletAddedGeneric;

  /// No description provided for @shareCardTitle.
  ///
  /// In fr, this message translates to:
  /// **'Partager ma carte'**
  String get shareCardTitle;

  /// No description provided for @shareCardQrHint.
  ///
  /// In fr, this message translates to:
  /// **'Faites scanner ce code - aucune app requise pour vos contacts.'**
  String get shareCardQrHint;

  /// No description provided for @shareOptionMessage.
  ///
  /// In fr, this message translates to:
  /// **'Message'**
  String get shareOptionMessage;

  /// No description provided for @shareOptionAirDrop.
  ///
  /// In fr, this message translates to:
  /// **'AirDrop'**
  String get shareOptionAirDrop;

  /// No description provided for @shareQuotaReached.
  ///
  /// In fr, this message translates to:
  /// **'Quota de {max} partages atteint.'**
  String shareQuotaReached(int max);

  /// No description provided for @shareQuotaUsed.
  ///
  /// In fr, this message translates to:
  /// **'{used} / {max} partages'**
  String shareQuotaUsed(int used, int max);

  /// No description provided for @shareSeePremium.
  ///
  /// In fr, this message translates to:
  /// **'Passer à Premium'**
  String get shareSeePremium;

  /// No description provided for @shareBlockedHint.
  ///
  /// In fr, this message translates to:
  /// **'Passez à Premium pour partager sans limite.'**
  String get shareBlockedHint;

  /// No description provided for @scanQuotaReached.
  ///
  /// In fr, this message translates to:
  /// **'Quota de {max} scans IA atteint pour ce mois.'**
  String scanQuotaReached(int max);

  /// No description provided for @scanContactAdded.
  ///
  /// In fr, this message translates to:
  /// **'Contact ajouté depuis le scan IA'**
  String get scanContactAdded;

  /// No description provided for @scanRecordError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'enregistrer le scan'**
  String get scanRecordError;

  /// No description provided for @scanStart.
  ///
  /// In fr, this message translates to:
  /// **'Lancer un scan'**
  String get scanStart;

  /// No description provided for @scanSeePremium.
  ///
  /// In fr, this message translates to:
  /// **'Voir les offres Premium'**
  String get scanSeePremium;

  /// No description provided for @scanUnlimited.
  ///
  /// In fr, this message translates to:
  /// **'Scans illimités'**
  String get scanUnlimited;

  /// No description provided for @scanNotIncluded.
  ///
  /// In fr, this message translates to:
  /// **'Scan IA non inclus'**
  String get scanNotIncluded;

  /// No description provided for @scanUsedCount.
  ///
  /// In fr, this message translates to:
  /// **'{used} / {max} scans utilisés par mois'**
  String scanUsedCount(int used, int max);

  /// No description provided for @premiumTitle.
  ///
  /// In fr, this message translates to:
  /// **'DropOne Premium'**
  String get premiumTitle;

  /// No description provided for @premiumStart.
  ///
  /// In fr, this message translates to:
  /// **'Démarrer Premium'**
  String get premiumStart;

  /// No description provided for @premiumProceedToPayment.
  ///
  /// In fr, this message translates to:
  /// **'Procéder au paiement'**
  String get premiumProceedToPayment;

  /// No description provided for @premiumCheckoutRedirect.
  ///
  /// In fr, this message translates to:
  /// **'Finalisez le paiement dans votre navigateur, puis revenez dans l\'application.'**
  String get premiumCheckoutRedirect;

  /// No description provided for @premiumCheckoutLaunchError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d\'ouvrir la page de paiement'**
  String get premiumCheckoutLaunchError;

  /// No description provided for @premiumRenewalNote.
  ///
  /// In fr, this message translates to:
  /// **'Renouvellement automatique. Annulable à tout moment dans les réglages.'**
  String get premiumRenewalNote;

  /// No description provided for @premiumSignUp.
  ///
  /// In fr, this message translates to:
  /// **'S\'inscrire'**
  String get premiumSignUp;

  /// No description provided for @premiumSignupOk.
  ///
  /// In fr, this message translates to:
  /// **'Compris'**
  String get premiumSignupOk;

  /// No description provided for @premiumSignupNote.
  ///
  /// In fr, this message translates to:
  /// **'Nous vous recontacterons pour les modalités d\'inscription.'**
  String get premiumSignupNote;

  /// No description provided for @premiumSignupThanksTitle.
  ///
  /// In fr, this message translates to:
  /// **'Merci, {name}'**
  String premiumSignupThanksTitle(String name);

  /// No description provided for @premiumSignupThanksTitleAnonymous.
  ///
  /// In fr, this message translates to:
  /// **'Merci'**
  String get premiumSignupThanksTitleAnonymous;

  /// No description provided for @premiumSignupThanks.
  ///
  /// In fr, this message translates to:
  /// **'Votre demande a été enregistrée. Nous vous reviendrons pour les modalités d\'inscription.'**
  String get premiumSignupThanks;

  /// No description provided for @premiumSignupThanksAnonymous.
  ///
  /// In fr, this message translates to:
  /// **'Votre demande a été enregistrée. Nous vous reviendrons pour les modalités d\'inscription.'**
  String get premiumSignupThanksAnonymous;

  /// No description provided for @premiumLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les offres.'**
  String get premiumLoadError;

  /// No description provided for @premiumActivated.
  ///
  /// In fr, this message translates to:
  /// **'Premium {title} ({price}) activé'**
  String premiumActivated(String title, String price);

  /// No description provided for @premiumSubscribeError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de créer l\'abonnement'**
  String get premiumSubscribeError;

  /// No description provided for @premiumNoOffers.
  ///
  /// In fr, this message translates to:
  /// **'Aucune offre configurée pour le moment'**
  String get premiumNoOffers;

  /// No description provided for @premiumFeatureType.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get premiumFeatureType;

  /// No description provided for @premiumFeatureScans.
  ///
  /// In fr, this message translates to:
  /// **'Scans IA'**
  String get premiumFeatureScans;

  /// No description provided for @premiumFeatureUsers.
  ///
  /// In fr, this message translates to:
  /// **'Utilisateurs'**
  String get premiumFeatureUsers;

  /// No description provided for @premiumFeatureCustomization.
  ///
  /// In fr, this message translates to:
  /// **'Personnalisation'**
  String get premiumFeatureCustomization;

  /// No description provided for @premiumFeaturePortfolio.
  ///
  /// In fr, this message translates to:
  /// **'Portfolio'**
  String get premiumFeaturePortfolio;

  /// No description provided for @premiumFeatureWallet.
  ///
  /// In fr, this message translates to:
  /// **'Wallet'**
  String get premiumFeatureWallet;

  /// No description provided for @premiumFeatureAnalytics.
  ///
  /// In fr, this message translates to:
  /// **'Statistiques'**
  String get premiumFeatureAnalytics;

  /// No description provided for @premiumFeatureVisitors.
  ///
  /// In fr, this message translates to:
  /// **'Visiteurs détaillés'**
  String get premiumFeatureVisitors;

  /// No description provided for @premiumFeatureSocial.
  ///
  /// In fr, this message translates to:
  /// **'Réseaux sociaux'**
  String get premiumFeatureSocial;

  /// No description provided for @premiumSocialUnlock.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez vos réseaux sociaux avec Premium'**
  String get premiumSocialUnlock;

  /// No description provided for @premiumSocialSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'LinkedIn, Instagram, WhatsApp et plus encore.'**
  String get premiumSocialSubtitle;

  /// No description provided for @premiumNoPricing.
  ///
  /// In fr, this message translates to:
  /// **'Aucun tarif configuré'**
  String get premiumNoPricing;

  /// No description provided for @premiumAudienceTeam.
  ///
  /// In fr, this message translates to:
  /// **'Équipe'**
  String get premiumAudienceTeam;

  /// No description provided for @premiumAudiencePersonal.
  ///
  /// In fr, this message translates to:
  /// **'Personnel'**
  String get premiumAudiencePersonal;

  /// No description provided for @premiumTeamMembers.
  ///
  /// In fr, this message translates to:
  /// **'Jusqu\'à {count} membres'**
  String premiumTeamMembers(int count);

  /// No description provided for @premiumSeatsFrom.
  ///
  /// In fr, this message translates to:
  /// **'À partir de {min} utilisateurs'**
  String premiumSeatsFrom(int min);

  /// No description provided for @premiumSeatsRange.
  ///
  /// In fr, this message translates to:
  /// **'De {min} à {max} utilisateurs'**
  String premiumSeatsRange(int min, int max);

  /// No description provided for @premiumSeatsPickerTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nombre d\'utilisateurs'**
  String get premiumSeatsPickerTitle;

  /// No description provided for @premiumSeatsIncludedHint.
  ///
  /// In fr, this message translates to:
  /// **'{count} inclus - non diminuable'**
  String premiumSeatsIncludedHint(int count);

  /// No description provided for @premiumSeatsTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total : {amount}'**
  String premiumSeatsTotal(String amount);

  /// No description provided for @premiumScansPerPeriod.
  ///
  /// In fr, this message translates to:
  /// **'{count} / mois'**
  String premiumScansPerPeriod(int count);

  /// No description provided for @premiumOneUser.
  ///
  /// In fr, this message translates to:
  /// **'1 utilisateur'**
  String get premiumOneUser;

  /// No description provided for @premiumBadge.
  ///
  /// In fr, this message translates to:
  /// **'Premium'**
  String get premiumBadge;

  /// No description provided for @premiumPortfolioLinked.
  ///
  /// In fr, this message translates to:
  /// **'Portfolio relié à la carte'**
  String get premiumPortfolioLinked;

  /// No description provided for @premiumSeeOffers.
  ///
  /// In fr, this message translates to:
  /// **'Voir les offres Premium'**
  String get premiumSeeOffers;

  /// No description provided for @premiumPortfolioSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Reliez vos projets et réalisations à votre carte.'**
  String get premiumPortfolioSubtitle;

  /// No description provided for @cardOfferExpired.
  ///
  /// In fr, this message translates to:
  /// **'Renouvelez votre abonnement pour réactiver cette carte'**
  String get cardOfferExpired;

  /// No description provided for @cardOfferExpiredSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Sans offre valide, la carte n’est plus partageable.'**
  String get cardOfferExpiredSubtitle;

  /// No description provided for @customizeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Personnaliser'**
  String get customizeTitle;

  /// No description provided for @customizeStyleSection.
  ///
  /// In fr, this message translates to:
  /// **'STYLE DE CARTE'**
  String get customizeStyleSection;

  /// No description provided for @customizeOptionsSection.
  ///
  /// In fr, this message translates to:
  /// **'OPTIONS'**
  String get customizeOptionsSection;

  /// No description provided for @customizeSaved.
  ///
  /// In fr, this message translates to:
  /// **'Carte enregistrée'**
  String get customizeSaved;

  /// No description provided for @customizeSyncError.
  ///
  /// In fr, this message translates to:
  /// **'Modifications appliquées, synchronisation impossible'**
  String get customizeSyncError;

  /// No description provided for @customizeProDesigns.
  ///
  /// In fr, this message translates to:
  /// **'Designs professionnels'**
  String get customizeProDesigns;

  /// No description provided for @customizeProDesignsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Modèles premium prêts à l\'emploi.'**
  String get customizeProDesignsSubtitle;

  /// No description provided for @customizeShowQr.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le QR code'**
  String get customizeShowQr;

  /// No description provided for @customizeCardBadge.
  ///
  /// In fr, this message translates to:
  /// **'Badge de la carte'**
  String get customizeCardBadge;

  /// No description provided for @teamMembersLoadError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de charger les membres'**
  String get teamMembersLoadError;

  /// No description provided for @teamMembersSubscriptionRequired.
  ///
  /// In fr, this message translates to:
  /// **'Un abonnement équipe actif est requis pour ajouter des membres.'**
  String get teamMembersSubscriptionRequired;

  /// No description provided for @teamMembersSeatLimitReached.
  ///
  /// In fr, this message translates to:
  /// **'Limite de {max} sièges atteinte. Passez à une offre supérieure.'**
  String teamMembersSeatLimitReached(int max);

  /// No description provided for @teamMembersAddTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un membre'**
  String get teamMembersAddTitle;

  /// No description provided for @teamMembersAddSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Envoyez une invitation par e-mail. La personne devra l’accepter pour rejoindre l’équipe.'**
  String get teamMembersAddSubtitle;

  /// No description provided for @teamMembersFullNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Nina Ba'**
  String get teamMembersFullNameHint;

  /// No description provided for @teamMembersJobTitleHint.
  ///
  /// In fr, this message translates to:
  /// **'Commerciale'**
  String get teamMembersJobTitleHint;

  /// No description provided for @teamMembersEmailHint.
  ///
  /// In fr, this message translates to:
  /// **'nina@megasn.com'**
  String get teamMembersEmailHint;

  /// No description provided for @teamMembersInvite.
  ///
  /// In fr, this message translates to:
  /// **'Inviter'**
  String get teamMembersInvite;

  /// No description provided for @teamMembersSendInvitation.
  ///
  /// In fr, this message translates to:
  /// **'Envoyer l’invitation'**
  String get teamMembersSendInvitation;

  /// No description provided for @teamMembersSetAdmin.
  ///
  /// In fr, this message translates to:
  /// **'Définir comme admin'**
  String get teamMembersSetAdmin;

  /// No description provided for @teamMembersSetAdminSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Peut gérer l’équipe et la marque.'**
  String get teamMembersSetAdminSubtitle;

  /// No description provided for @teamMembersRemoveMember.
  ///
  /// In fr, this message translates to:
  /// **'Retirer de l’équipe'**
  String get teamMembersRemoveMember;

  /// No description provided for @teamMembersRemoveTitle.
  ///
  /// In fr, this message translates to:
  /// **'Retirer ce membre ?'**
  String get teamMembersRemoveTitle;

  /// No description provided for @teamMembersRemoveMessage.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous retirer {name} de l’équipe ?'**
  String teamMembersRemoveMessage(String name);

  /// No description provided for @teamMembersRemoveSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Membre retiré de l’équipe'**
  String get teamMembersRemoveSuccess;

  /// No description provided for @teamMembersRemoveError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de retirer ce membre'**
  String get teamMembersRemoveError;

  /// No description provided for @teamMembersCancelInvite.
  ///
  /// In fr, this message translates to:
  /// **'Annuler l’invitation'**
  String get teamMembersCancelInvite;

  /// No description provided for @teamMembersCancelInviteTitle.
  ///
  /// In fr, this message translates to:
  /// **'Annuler l’invitation ?'**
  String get teamMembersCancelInviteTitle;

  /// No description provided for @teamMembersCancelInviteMessage.
  ///
  /// In fr, this message translates to:
  /// **'Voulez-vous annuler l’invitation envoyée à {name} ?'**
  String teamMembersCancelInviteMessage(String name);

  /// No description provided for @teamMembersCancelInviteSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Invitation annulée'**
  String get teamMembersCancelInviteSuccess;

  /// No description provided for @teamMembersInviteSuccess.
  ///
  /// In fr, this message translates to:
  /// **'Invitation envoyée'**
  String get teamMembersInviteSuccess;

  /// No description provided for @teamMembersInviteError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d’envoyer l’invitation'**
  String get teamMembersInviteError;

  /// No description provided for @teamMembersSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'MEMBRES DE L’ÉQUIPE'**
  String get teamMembersSectionTitle;

  /// No description provided for @teamMembersCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 membre} other{{count} membres}}'**
  String teamMembersCount(int count);

  /// No description provided for @teamMembersSeatsUsed.
  ///
  /// In fr, this message translates to:
  /// **'Sièges utilisés'**
  String get teamMembersSeatsUsed;

  /// No description provided for @teamMembersStatusActive.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get teamMembersStatusActive;

  /// No description provided for @teamMembersStatusPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get teamMembersStatusPending;

  /// No description provided for @teamInvitationTitle.
  ///
  /// In fr, this message translates to:
  /// **'Invitation équipe'**
  String get teamInvitationTitle;

  /// No description provided for @teamInvitationMessage.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez été invité à rejoindre l’équipe {teamName}.'**
  String teamInvitationMessage(String teamName);

  /// No description provided for @teamInvitationMessageWithInviter.
  ///
  /// In fr, this message translates to:
  /// **'{inviterName} vous invite à rejoindre l’équipe {teamName}.'**
  String teamInvitationMessageWithInviter(String inviterName, String teamName);

  /// No description provided for @teamInvitationAccept.
  ///
  /// In fr, this message translates to:
  /// **'Accepter'**
  String get teamInvitationAccept;

  /// No description provided for @teamInvitationDecline.
  ///
  /// In fr, this message translates to:
  /// **'Refuser'**
  String get teamInvitationDecline;

  /// No description provided for @teamInvitationAccepted.
  ///
  /// In fr, this message translates to:
  /// **'Vous avez rejoint {teamName}'**
  String teamInvitationAccepted(String teamName);

  /// No description provided for @teamInvitationDeclined.
  ///
  /// In fr, this message translates to:
  /// **'Invitation refusée'**
  String get teamInvitationDeclined;

  /// No description provided for @teamInvitationRespondError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de répondre à l’invitation'**
  String get teamInvitationRespondError;

  /// No description provided for @setupTeamNameRequired.
  ///
  /// In fr, this message translates to:
  /// **'Nom d’équipe requis'**
  String get setupTeamNameRequired;

  /// No description provided for @setupTeamNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'NOM DE L’ÉQUIPE'**
  String get setupTeamNameLabel;

  /// No description provided for @setupTeamNameHint.
  ///
  /// In fr, this message translates to:
  /// **'Mega SN'**
  String get setupTeamNameHint;

  /// No description provided for @setupTeamTitleCreate.
  ///
  /// In fr, this message translates to:
  /// **'Configurez votre espace équipe'**
  String get setupTeamTitleCreate;

  /// No description provided for @setupTeamTitleEdit.
  ///
  /// In fr, this message translates to:
  /// **'Finalisez votre espace équipe'**
  String get setupTeamTitleEdit;

  /// No description provided for @setupTeamSubtitleCreate.
  ///
  /// In fr, this message translates to:
  /// **'Définissez le logo et la couleur des cartes de votre équipe.'**
  String get setupTeamSubtitleCreate;

  /// No description provided for @setupTeamSubtitleEdit.
  ///
  /// In fr, this message translates to:
  /// **'Reprennez la configuration de votre équipe ou passez à l’étape suivante.'**
  String get setupTeamSubtitleEdit;

  /// No description provided for @setupTeamLogoLabel.
  ///
  /// In fr, this message translates to:
  /// **'LOGO'**
  String get setupTeamLogoLabel;

  /// No description provided for @setupTeamColorLabel.
  ///
  /// In fr, this message translates to:
  /// **'COULEUR DES CARTES DE L’ÉQUIPE'**
  String get setupTeamColorLabel;

  /// No description provided for @setupTeamColorSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Appliquée aux cartes de tous les membres de l’équipe.'**
  String get setupTeamColorSubtitle;

  /// No description provided for @setupTeamCreated.
  ///
  /// In fr, this message translates to:
  /// **'Équipe « {name} » créée'**
  String setupTeamCreated(String name);

  /// No description provided for @setupTeamUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Équipe « {name} » mise à jour'**
  String setupTeamUpdated(String name);

  /// No description provided for @setupTeamCreateError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de créer l’équipe'**
  String get setupTeamCreateError;

  /// No description provided for @setupTeamAppRestart.
  ///
  /// In fr, this message translates to:
  /// **'Relancez l’app complètement (arrêt + flutter run) puis réessayez.'**
  String get setupTeamAppRestart;

  /// No description provided for @proDesignsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'{count} modèles Premium prêts à l’emploi'**
  String proDesignsSubtitle(int count);

  /// No description provided for @proDesignsCardTypeSection.
  ///
  /// In fr, this message translates to:
  /// **'TYPE DE CARTE'**
  String get proDesignsCardTypeSection;

  /// No description provided for @proDesignsConfiguringTeam.
  ///
  /// In fr, this message translates to:
  /// **'Configuration de votre espace équipe…'**
  String get proDesignsConfiguringTeam;

  /// No description provided for @proDesignsOpenTeamSetup.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrez la configuration équipe pour créer votre carte pro.'**
  String get proDesignsOpenTeamSetup;

  /// No description provided for @proDesignsTemplatesSection.
  ///
  /// In fr, this message translates to:
  /// **'{count} MODÈLES - APERÇU EN TEMPS RÉEL'**
  String proDesignsTemplatesSection(int count);

  /// No description provided for @proDesignsCompanyColors.
  ///
  /// In fr, this message translates to:
  /// **'Couleurs de l’entreprise'**
  String get proDesignsCompanyColors;

  /// No description provided for @proDesignsCompanyColorsSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Recolore les modèles compatibles avec votre charte'**
  String get proDesignsCompanyColorsSubtitle;

  /// No description provided for @proDesignPreviewCompanyColorRequired.
  ///
  /// In fr, this message translates to:
  /// **'Choisissez une couleur entreprise avant d’appliquer.'**
  String get proDesignPreviewCompanyColorRequired;

  /// No description provided for @proDesignPreviewApplied.
  ///
  /// In fr, this message translates to:
  /// **'Modèle {name} appliqué'**
  String proDesignPreviewApplied(String name);

  /// No description provided for @proDesignPreviewApplyError.
  ///
  /// In fr, this message translates to:
  /// **'Impossible d’appliquer le modèle. Réessayez.'**
  String get proDesignPreviewApplyError;

  /// No description provided for @proDesignPreviewRecipientPreview.
  ///
  /// In fr, this message translates to:
  /// **'Aperçu destinataire'**
  String get proDesignPreviewRecipientPreview;

  /// No description provided for @proDesignPreviewUseTemplate.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser ce modèle'**
  String get proDesignPreviewUseTemplate;
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
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
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
