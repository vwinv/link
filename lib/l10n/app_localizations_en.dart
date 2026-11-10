// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DropOne';

  @override
  String get createdByMega => 'Created by MEGA';

  @override
  String get navCards => 'Cards';

  @override
  String get navScan => 'AI Scan';

  @override
  String get navContacts => 'Contacts';

  @override
  String get navProfile => 'Profile';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileSectionAccount => 'ACCOUNT';

  @override
  String get profileSectionSettings => 'SETTINGS';

  @override
  String get profileTeamSpace => 'My team';

  @override
  String get profileRefer => 'Refer';

  @override
  String get profileReferSubtitle => 'Earn points';

  @override
  String get referralTitle => 'Referrals';

  @override
  String get referralLoadError => 'Unable to load referrals.';

  @override
  String get referralBalanceLabel => 'Your balance';

  @override
  String get referralPointsUnit => 'points';

  @override
  String referralBalanceFcfa(String amount) {
    return '≈ $amount FCFA';
  }

  @override
  String get referralYourCode => 'Your referral code';

  @override
  String referralInvitedCount(int count) {
    return '$count invited';
  }

  @override
  String get referralShare => 'Refer';

  @override
  String referralShareText(String code, String storeUrl) {
    return 'Download DropOne and sign up with my code $code:\n$storeUrl';
  }

  @override
  String get referralHowTitle => 'How to earn points?';

  @override
  String referralHowBody(
    String referralPoints,
    String visitPoints,
    String fcfa,
  ) {
    return '• $referralPoints point when a referral subscribes with your code\n• $visitPoints point per person who visits your card (once only)\n• 1 point = $fcfa FCFA';
  }

  @override
  String get referralEnterCodeTitle => 'Have a code?';

  @override
  String get referralEnterCodeHint => 'DROP-XXXX';

  @override
  String get referralFirstLoginHint =>
      'Enter your referrer’s code when creating your account. You won’t be able to do it later.';

  @override
  String get referralSkipCode => 'Skip';

  @override
  String get referralApply => 'Apply';

  @override
  String get referralCodeApplied => 'Referral code saved';

  @override
  String get referralCodeApplyError => 'Unable to apply this code';

  @override
  String get referralHistoryTitle => 'History';

  @override
  String get referralHistoryEmpty => 'No activity yet.';

  @override
  String get referralLedgerReferral => 'Referral (subscription)';

  @override
  String get referralLedgerVisit => 'New visitor';

  @override
  String get referralLedgerPurchase => 'Points purchase';

  @override
  String get referralLedgerAdjustment => 'Adjustment';

  @override
  String get referralLedgerCredit => 'Credit';

  @override
  String get referralLedgerDebit => 'Debit';

  @override
  String get referralCodeFieldLabel => 'Referral code (optional)';

  @override
  String get profileManageWallet => 'Manage Wallet';

  @override
  String get profileNotifications => 'Notifications';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'No notifications yet';

  @override
  String get notificationsLoadError => 'Unable to load notifications';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get profileMyCards => 'My cards';

  @override
  String get profilePrivacy => 'Privacy';

  @override
  String get privacyPolicyTitle => 'Privacy';

  @override
  String get profileLogout => 'Log out';

  @override
  String get profileDeleteAccount => 'Delete account';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileEdit => 'Edit';

  @override
  String get profilePremiumTitle => 'Upgrade to Premium';

  @override
  String get profilePremiumSubtitle => 'Pro designs, colors…';

  @override
  String get profileTeamConfigure => 'Set up your team';

  @override
  String profileTeamMembers(String teamName, int count) {
    return '$teamName - $count members';
  }

  @override
  String profileCardsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$_temp0';
  }

  @override
  String get profilePrivacySoon => 'Privacy settings coming soon';

  @override
  String get profileDeleteAccountTitle => 'Delete account';

  @override
  String get profileDeleteAccountMessage =>
      'Your account will be deactivated. To recover it, contact us at contact@mega-sn.com.';

  @override
  String get profileDeleteAccountError => 'Unable to delete account right now';

  @override
  String get profileCreateCardFirst => 'Create a card to get started';

  @override
  String get profileCreateCardForWallet => 'Create a card before using Wallet';

  @override
  String get commonBack => 'Back';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonSave => 'Save';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonShare => 'Share';

  @override
  String get commonContinue => 'Continue';

  @override
  String get commonUnlock => 'Unlock';

  @override
  String get cardKindPersonal => 'Personal card';

  @override
  String get cardKindTeam => 'Team card';

  @override
  String get cardKindMember => 'Member card';

  @override
  String get cardScopePersonal => 'Personal';

  @override
  String get cardScopeProfessional => 'Professional';

  @override
  String get cardScopeMember => 'Member';

  @override
  String get cardScopePersonalShort => 'Personal card';

  @override
  String get cardScopeProfessionalShort => 'Pro card';

  @override
  String get cardScopeMemberShort => 'Member card';

  @override
  String get portfolioScope => 'Portfolio';

  @override
  String get portfolioHomeHeadline =>
      'Create your portfolio and make an impact professionally';

  @override
  String get portfolioPathLabel => 'CAREER';

  @override
  String get portfolioSkillsLabel => 'SKILLS';

  @override
  String get portfolioPathEmpty => 'Add your experience';

  @override
  String get portfolioSkillsEmpty => 'Add your skills';

  @override
  String get portfolioStatsSubtitle => 'Find out who viewed your portfolio';

  @override
  String get portfolioStatsTitle => 'Portfolio statistics';

  @override
  String get portfolioStatsVisits => 'Site visits';

  @override
  String get portfolioStatsClicks => 'Clicks on “View my portfolio”';

  @override
  String get portfolioStatsHint => 'Numbers appear after the first visits.';

  @override
  String get portfolioStatsClose => 'Close';

  @override
  String get portfolioEmptySubtitle =>
      'Publish your experience and skills to stand out.';

  @override
  String get portfolioCreate => 'Create my portfolio';

  @override
  String get portfolioStyleTitle => 'Portfolio style';

  @override
  String get portfolioStyleSubtitle =>
      'Choose a layout, then a color. You can change them anytime without losing your content.';

  @override
  String get portfolioStyleModels => 'LAYOUT';

  @override
  String get portfolioStyleColor => 'COLOR';

  @override
  String portfolioStyleChoose(String layout, String color) {
    return 'Choose · $layout · $color';
  }

  @override
  String portfolioStyleContinue(String layout, String color) {
    return 'Continue · $layout · $color';
  }

  @override
  String get portfolioStyleSaved => 'Portfolio style saved';

  @override
  String get portfolioStyleSaveError => 'Unable to save the portfolio style';

  @override
  String get portfolioEditorTitle => 'My portfolio';

  @override
  String get portfolioEditorTheme => 'Theme';

  @override
  String get portfolioEditorPreview => 'Preview';

  @override
  String get portfolioEditorPublish => 'Publish my portfolio';

  @override
  String portfolioEditorProgress(int percent) {
    return '$percent% complete';
  }

  @override
  String get portfolioEditorPhotoTitle => 'Portfolio photo';

  @override
  String get portfolioEditorPhotoHint =>
      'A portrait works best, on a plain or cut-out background.';

  @override
  String get portfolioEditorPhotoChange => 'Change';

  @override
  String get portfolioEditorPersonal => 'Personal details';

  @override
  String get portfolioEditorFirstName => 'First name';

  @override
  String get portfolioEditorLastName => 'Last name';

  @override
  String get portfolioEditorAge => 'Age';

  @override
  String get portfolioEditorAgeHint => 'e.g. 32';

  @override
  String get portfolioEditorPhone => 'Phone';

  @override
  String get portfolioEditorAddress => 'Address';

  @override
  String get portfolioEditorAddressHint => 'Neighborhood, city, country';

  @override
  String get portfolioEditorHidePersonal => 'Hide age and address on the site';

  @override
  String get portfolioEditorPresentation => 'Introduction';

  @override
  String get portfolioEditorPortfolioTitle => 'Portfolio title';

  @override
  String get portfolioEditorDescription => 'Description';

  @override
  String get portfolioEditorDescriptionHint =>
      'Who you are, what you do, and for whom. 3 to 4 sentences.';

  @override
  String get portfolioEditorSocialTitle => 'Portfolio socials';

  @override
  String get portfolioEditorSocialSubtitle =>
      'Separate from your card socials. Shown on the public site.';

  @override
  String get portfolioEditorSocialChoice =>
      'How do you want to set your socials?';

  @override
  String get portfolioEditorSocialCopyCard => 'Copy from my card';

  @override
  String get portfolioEditorSocialRetype => 'Enter them again';

  @override
  String get portfolioEditorSocialNoCardLinks =>
      'No socials configured on this card.';

  @override
  String get portfolioEditorExperience => 'Work experience';

  @override
  String portfolioEditorPosts(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count roles',
      one: '1 role',
      zero: '0 roles',
    );
    return '$_temp0';
  }

  @override
  String get portfolioEditorAddExperience => 'Add an experience';

  @override
  String get portfolioEditorTeaching => 'Teaching experience';

  @override
  String portfolioEditorEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
      zero: '0 entries',
    );
    return '$_temp0';
  }

  @override
  String get portfolioEditorAddTeaching => 'Add a teaching experience';

  @override
  String get portfolioEditorEdit => 'Edit';

  @override
  String get portfolioEditorReorderHint => 'Hold ≡ to reorder the display';

  @override
  String get portfolioEditorSkills => 'Skills (with level)';

  @override
  String get portfolioEditorAddSkill => 'Add a skill';

  @override
  String get portfolioEditorCompetences => 'Competences';

  @override
  String get portfolioEditorCompetencesHint => 'Professional know-how';

  @override
  String get portfolioEditorStrengths => 'Strengths';

  @override
  String get portfolioEditorStrengthsHint => 'What sets you apart';

  @override
  String get portfolioEditorInterests => 'Interests';

  @override
  String get portfolioEditorInterestsHint => 'A personal touch';

  @override
  String get portfolioEditorAdd => 'Add';

  @override
  String get portfolioEditorProjects => 'Work';

  @override
  String get portfolioEditorProjectsHint =>
      'Up to 12 works. Photo and link are optional.';

  @override
  String get portfolioEditorImport => 'Import';

  @override
  String get portfolioEditorImportCv => 'Import my CV (PDF)';

  @override
  String get portfolioEditorImportCvHint =>
      'The app reads your CV and prefills the fields. Nothing is saved until you publish.';

  @override
  String get portfolioEditorImportCvConfirmTitle => 'Replace current content?';

  @override
  String get portfolioEditorImportCvConfirmBody =>
      'Current portfolio fields will be replaced with data extracted from the CV. Your photo is kept. You can review everything before saving.';

  @override
  String get portfolioEditorImportCvLoading => 'Analyzing CV…';

  @override
  String get portfolioEditorImportCvReady =>
      'CV imported. Review the fields, then publish to save.';

  @override
  String get portfolioEditorImportCvError => 'Unable to analyze this CV';

  @override
  String get portfolioEditorImportCvPickError => 'Please select a PDF file';

  @override
  String get portfolioEditorRole => 'Job title';

  @override
  String get portfolioEditorCompany => 'Company';

  @override
  String get portfolioEditorPeriod => 'Period';

  @override
  String get portfolioEditorPeriodHint => '2021 – today';

  @override
  String get portfolioEditorCourse => 'Course or workshop title';

  @override
  String get portfolioEditorSchool => 'School';

  @override
  String get portfolioEditorYear => 'Year';

  @override
  String get portfolioEditorSkillName => 'Skill';

  @override
  String get portfolioEditorProjectTitle => 'Title';

  @override
  String get portfolioEditorCaption => 'Description';

  @override
  String get portfolioEditorProjectPhoto => 'Photo (optional)';

  @override
  String get portfolioEditorProjectPhotoAdd => 'Add a photo';

  @override
  String get portfolioEditorProjectPhotoChange => 'Change the photo';

  @override
  String get portfolioEditorProjectLink => 'Link (optional)';

  @override
  String get portfolioEditorProjectLinkHint => 'https://...';

  @override
  String get portfolioEditorSave => 'Save';

  @override
  String get portfolioEditorDelete => 'Delete';

  @override
  String get portfolioEditorPublished => 'Portfolio published';

  @override
  String get portfolioEditorSaveError => 'Unable to save the portfolio';

  @override
  String get portfolioEditorNameRequired => 'Enter your first and last name';

  @override
  String get portfolioEditorMissing =>
      'Choose a theme first to create the portfolio.';

  @override
  String get portfolioEditorChipHint => 'New';

  @override
  String get portfolioEditorNewChip => 'New...';

  @override
  String get portfolioEditorPoste => 'Role';

  @override
  String get portfolioEditorPosteHint => 'e.g. Communications lead';

  @override
  String get portfolioEditorCompanyHint => 'e.g. Mega-SN';

  @override
  String get portfolioEditorPeriodExample => 'e.g. 2021 – today';

  @override
  String get portfolioEditorMissions => 'Responsibilities';

  @override
  String get portfolioEditorMissionsHint =>
      'Main responsibilities in one sentence';

  @override
  String get portfolioEditorCourseHint => 'e.g. Digital marketing';

  @override
  String get portfolioEditorSchoolHint => 'e.g. ISM Dakar';

  @override
  String get portfolioEditorYearHint => 'e.g. 2023';

  @override
  String get portfolioEditorAudience => 'Audience, hours';

  @override
  String get portfolioEditorAudienceHint => 'e.g. Master\'s 1 · 20 h';

  @override
  String get portfolioEditorSkillSheet => 'Skill';

  @override
  String get portfolioEditorSkillNameLabel => 'Skill name';

  @override
  String get portfolioEditorSkillHint => 'e.g. Negotiation';

  @override
  String get portfolioEditorLevel => 'Level';

  @override
  String get portfolioLayoutClassique => 'Classic';

  @override
  String get portfolioLayoutClassiqueHint => 'Round photo, timeline';

  @override
  String get portfolioLayoutCouverture => 'Cover';

  @override
  String get portfolioLayoutCouvertureHint => 'Large photo on top';

  @override
  String get portfolioLayoutEditorial => 'Editorial';

  @override
  String get portfolioLayoutEditorialHint => 'Type, ruled sections';

  @override
  String get portfolioLayoutGalerie => 'Gallery';

  @override
  String get portfolioLayoutGalerieHint => 'Work first';

  @override
  String get portfolioLayoutMinimal => 'Minimal';

  @override
  String get portfolioLayoutMinimalHint => 'Clean, centered';

  @override
  String get portfolioLayoutBento => 'Bento';

  @override
  String get portfolioLayoutBentoHint => 'Block mosaic';

  @override
  String get portfolioLayoutPortrait => 'Portrait';

  @override
  String get portfolioLayoutPortraitHint => 'Vertical photo';

  @override
  String get portfolioLayoutCartes => 'Cards';

  @override
  String get portfolioLayoutCartesHint => 'Sections as cards';

  @override
  String get portfolioColorBleu => 'Drop Blue';

  @override
  String get portfolioColorIvoire => 'Ivory';

  @override
  String get portfolioColorNoir => 'Black & Gold';

  @override
  String get portfolioColorForet => 'Emerald';

  @override
  String get portfolioColorNeon => 'Neon';

  @override
  String get portfolioColorCorail => 'Sunset';

  @override
  String get portfolioColorLagon => 'Lagoon';

  @override
  String get portfolioColorLilas => 'Aurora';

  @override
  String get portfolioColorTerre => 'Terracotta';

  @override
  String get portfolioColorSable => 'Editorial';

  @override
  String get portfolioColorSoleil => 'Brutal';

  @override
  String get portfolioColorMinuit => 'Frosted glass';

  @override
  String myCardsGreeting(String name) {
    return 'Hello, $name 👋';
  }

  @override
  String get myCardsTitle => 'My cards';

  @override
  String get myCardsSharedContacts => 'SHARED CONTACTS';

  @override
  String get myCardsSeeAll => 'See all';

  @override
  String get myCardsViews => 'Views';

  @override
  String get myCardsShares => 'Shares';

  @override
  String get myCardsScans => 'Scans';

  @override
  String get myCardsNoContacts => 'No contacts yet';

  @override
  String get myCardsProTitle => 'Professional card';

  @override
  String get homePreviewMyCard => 'View my card';

  @override
  String get homePreviewMyPortfolio => 'View my portfolio';

  @override
  String get previewShareLinksHint =>
      'Share your card. Your visitors will get this feature.';

  @override
  String get previewSharePortfolioLinksHint =>
      'Share your portfolio. Your visitors will get this feature.';

  @override
  String get myCardsPersonalTitle => 'Personal card';

  @override
  String get myCardsPersonalSubtitle =>
      'Create your personal card to share your details and grow your network.';

  @override
  String get myCardsCreatePersonal => 'Create my personal card';

  @override
  String get myCardsProWithTeam =>
      'Your team space is ready. Finish your professional card to continue.';

  @override
  String get myCardsProWithoutTeam =>
      'Your pro card is linked to a team space. Start by setting the name, logo and brand color.';

  @override
  String get myCardsCreatePro => 'Create my pro card';

  @override
  String get myCardsEditTeam => 'Edit team';

  @override
  String get myCardsContinueSetup => 'Continue setup';

  @override
  String get myCardsSetupTeam => 'Set up my team space';

  @override
  String get myCardTitle => 'My card';

  @override
  String get myCardSocialNetworks => 'SOCIAL NETWORKS';

  @override
  String get myCardPortfolio => 'PORTFOLIO';

  @override
  String get myCardPortfolioLinked => 'Your portfolio is linked to this card.';

  @override
  String get myCardPortfolioPremium =>
      'Link your portfolio to the card with Premium';

  @override
  String myCardSocialNotConfigured(String platform) {
    return '$platform is not configured yet';
  }

  @override
  String get myCardLinkOpenError => 'Unable to open this link';

  @override
  String get pickCardTitle => 'Choose a card';

  @override
  String get walletTitle => 'Wallet';

  @override
  String get walletAddApple => 'Add to Apple Wallet';

  @override
  String get walletAddGoogle => 'Add to Google Wallet';

  @override
  String get walletSubtitle =>
      'Access your card from the lock screen, anytime.';

  @override
  String get walletAdding => 'Adding...';

  @override
  String walletAdded(String walletName) {
    return 'Card added to $walletName.';
  }

  @override
  String get walletUnavailable => 'Wallet is not available on this device.';

  @override
  String get walletAddError => 'Unable to add the card to Wallet.';

  @override
  String get walletAppleName => 'Apple Wallet';

  @override
  String get walletGoogleName => 'Google Wallet';

  @override
  String get editCardTitle => 'Edit my card';

  @override
  String get editCardSubtitle =>
      'This information appears on your DropOne card.';

  @override
  String get editCardFullName => 'Full name';

  @override
  String get editCardJobTitle => 'Job title';

  @override
  String get editCardCompany => 'Company';

  @override
  String get editCardEmail => 'Email';

  @override
  String get editCardPhone => 'Phone';

  @override
  String get editCardAddress => 'Company address';

  @override
  String get editCardAddressTeamHint =>
      'Shared with the whole team. Only the owner and admins can edit it.';

  @override
  String get editCardCompanyLogo => 'COMPANY LOGO';

  @override
  String get editCardChangeLogo => 'Change logo';

  @override
  String get editCardImportLogo => 'Import a logo';

  @override
  String get editCardLogoHint => 'JPG, PNG - max 5 MB';

  @override
  String get editCardRemoveLogo => 'Remove logo';

  @override
  String get editCardRemovePhoto => 'Remove photo';

  @override
  String get editCardSocialTitle => 'SOCIAL NETWORKS';

  @override
  String get editCardSocialSubtitle => 'Add the links to display on your card.';

  @override
  String get editCardSocialTeamSubtitle =>
      'These links are shared with the whole team.';

  @override
  String get editCardSocialTeamLocked =>
      'Only the owner and admins can edit the team’s social networks.';

  @override
  String get editCardSaved => 'Card information saved';

  @override
  String get editCardSaveError => 'Unable to save information';

  @override
  String get editCardNameRequired => 'Name required';

  @override
  String get editCardEmailRequired => 'Email required';

  @override
  String get editCardEmailInvalid => 'Invalid email';

  @override
  String get editCardNoCard => 'No card to edit';

  @override
  String editCardGalleryError(String message) {
    return 'Unable to open gallery: $message';
  }

  @override
  String get contactsTitle => 'Contacts';

  @override
  String get contactsSearchHint => 'Search a contact';

  @override
  String get contactsCountZero => 'No contacts saved';

  @override
  String get contactsCountOne => '1 contact saved';

  @override
  String contactsCountMany(int count) {
    return '$count contacts saved';
  }

  @override
  String get contactsAll => 'ALL CONTACTS';

  @override
  String get contactsScanPaperTitle => 'Scan a paper card';

  @override
  String get contactsScanPaperSubtitle => 'Digitize a contact with AI';

  @override
  String get contactsScanBannerTitle => 'Scan a business card';

  @override
  String get contactsScanBannerSubtitle =>
      'AI extracts info and creates a contact';

  @override
  String get contactsScanAction => 'Scan';

  @override
  String get contactsEmpty => 'No contacts yet';

  @override
  String get contactsEmptySearch => 'No results for this search';

  @override
  String get contactDetailTitle => 'Contact details';

  @override
  String get contactDetailUntitled => 'Contact';

  @override
  String get contactDetailViewCard => 'View card';

  @override
  String get contactDetailInfoTitle => 'Information';

  @override
  String get contactDetailJob => 'Job title';

  @override
  String get contactDetailCompany => 'Company';

  @override
  String get contactDetailPhone => 'Phone';

  @override
  String get contactDetailEmail => 'Email';

  @override
  String get contactDetailSource => 'Source';

  @override
  String get contactDetailAddedAt => 'Added on';

  @override
  String get contactDetailSourceExchange => 'Drop One exchange';

  @override
  String get contactDetailSourceScan => 'AI Scan';

  @override
  String get contactDetailUnavailable => '-';

  @override
  String get contactDetailActionsTitle => 'Actions';

  @override
  String get contactDetailCall => 'Call';

  @override
  String get contactDetailSendEmail => 'Send email';

  @override
  String get contactDetailSendMessage => 'Send a message';

  @override
  String get contactDetailShare => 'Share contact';

  @override
  String get contactDetailCopied => 'Contact copied to clipboard';

  @override
  String get myCardsRecentContacts => 'RECENT CONTACTS';

  @override
  String get myCardsStatsSaved => 'Saved';

  @override
  String get myCardsNoContactsDot => 'No contacts yet.';

  @override
  String get myCardsSeeVisitors => 'See visitors';

  @override
  String get myCardsSeeVisitorsSubtitle => 'Find out who viewed your card';

  @override
  String get myCardsSeeStats => 'See your statistics';

  @override
  String get myCardsSeeStatsSubtitle => 'Find out who viewed your card';

  @override
  String get myCardsMemberLogin => 'Sign in to my member space';

  @override
  String get myCardsMemberLoginSubtitle => 'Access your card and your team';

  @override
  String get memberHomeCardTab => 'My card';

  @override
  String get memberHomeTeamTab => 'My team';

  @override
  String get memberHomeMyCardTitle => 'My card';

  @override
  String get memberHomeTeamTitle => 'My team';

  @override
  String get memberHomeShare => 'Share';

  @override
  String get memberHomeWallet => 'Wallet';

  @override
  String get memberHomeTotalViews => 'Total views';

  @override
  String get memberHomeUniquePeople => 'Unique people';

  @override
  String get memberHomeViewersTitle => 'People who viewed my card';

  @override
  String get memberHomeSeeAll => 'See all';

  @override
  String get memberHomeTeamOverview => 'Team overview';

  @override
  String get memberHomeMembersLabel => 'Members';

  @override
  String get memberHomeMembersListTitle => 'Team members';

  @override
  String get memberHomeNoCard => 'No member card yet.';

  @override
  String get memberHomeNoViewers => 'Nobody has viewed your card yet.';

  @override
  String get memberHomeToday => 'Today';

  @override
  String get memberHomeYesterday => 'Yesterday';

  @override
  String memberHomeDaysAgo(int count) {
    return '${count}d';
  }

  @override
  String get workspaceSwitchToPersonal => 'My personal space';

  @override
  String get workspaceStayMember => 'Stay in member space';

  @override
  String get workspaceMemberAccessBlocked =>
      'Member access unavailable. Ask your team for a new invitation.';

  @override
  String get teamInviteScreenTitle => 'Invitation to join a team';

  @override
  String get teamInvitationDeclinedBlocked =>
      'Invitation declined. Member access is blocked until a new invitation.';

  @override
  String get cardAnalyticsTitle => 'Card analytics';

  @override
  String get cardAnalyticsTotalViews => 'Total views';

  @override
  String get cardAnalyticsUniqueVisitors => 'Unique visitors';

  @override
  String get cardAnalyticsSavedCards => 'Saved cards';

  @override
  String get cardAnalyticsShares => 'Shares';

  @override
  String cardAnalyticsWeekChange(String change) {
    return '$change% this week';
  }

  @override
  String get cardAnalyticsPeriod7 => '7 days';

  @override
  String get cardAnalyticsPeriod30 => '30 days';

  @override
  String get cardAnalyticsPeriodCustom => 'Customize';

  @override
  String get cardAnalyticsScopeAll => 'All';

  @override
  String get cardAnalyticsScopeTeam => 'Team';

  @override
  String get cardAnalyticsScopePersonal => 'Personal';

  @override
  String get cardAnalyticsScopeProfessional => 'Professional';

  @override
  String get cardAnalyticsShowVisitors =>
      'Show the list of people who viewed your card';

  @override
  String get cardAnalyticsViewsEvolution => 'Views over time';

  @override
  String get cardAnalyticsDiscoverySources => 'Discovery sources';

  @override
  String get cardAnalyticsSeeAll => 'See all';

  @override
  String get cardAnalyticsRealtimeTip => 'Statistics are updated in real time.';

  @override
  String get cardAnalyticsLoadError => 'Unable to load statistics.';

  @override
  String get cardAnalyticsSourceQr => 'QR Code';

  @override
  String get cardAnalyticsSourceShare => 'Direct share';

  @override
  String get cardAnalyticsSourceLink => 'Link';

  @override
  String get cardAnalyticsSourceNfc => 'Other';

  @override
  String get cardAnalyticsSourceApp => 'App';

  @override
  String get cardAnalyticsSourceOther => 'Other';

  @override
  String get cardVisitorsTitle => 'Card views';

  @override
  String get cardVisitorsSearchHint => 'Search a visitor...';

  @override
  String get cardVisitorsTotalViews => 'Total views';

  @override
  String get cardVisitorsUnique => 'Unique visitors';

  @override
  String get cardVisitorsSaved => 'Saved cards';

  @override
  String get cardVisitorsShares => 'Shares';

  @override
  String get cardVisitorsFilterAll => 'All';

  @override
  String get cardVisitorsFilterDropOne => 'Drop One';

  @override
  String get cardVisitorsFilterGuest => 'No account';

  @override
  String get cardVisitorsToday => 'TODAY';

  @override
  String get cardVisitorsYesterday => 'YESTERDAY';

  @override
  String get cardVisitorsEmpty => 'No visitors yet.';

  @override
  String get cardVisitorsLoadError => 'Unable to load visitors.';

  @override
  String get cardVisitorDetailTitle => 'Visitor details';

  @override
  String get cardVisitorDetailAnonymousName => 'Anonymous visitor';

  @override
  String get cardVisitorDetailGuestBadge => 'No Drop One account';

  @override
  String get cardVisitorDetailAnonymousSubtitle =>
      'This person doesn\'t have a Drop One account yet.';

  @override
  String get cardVisitorDetailAnonymousTip =>
      'Once they sign up, you\'ll be able to see their profile and get in touch.';

  @override
  String get cardVisitorDetailInviteCta => 'Invite to Drop One';

  @override
  String get cardVisitorDetailInviteShort => 'Invite';

  @override
  String get cardVisitorDetailInviteBannerTitle => 'Invite this visitor';

  @override
  String get cardVisitorDetailInviteBannerBody =>
      'Send them an invite to join Drop One and exchange easily.';

  @override
  String get cardVisitorDetailViewCard => 'View card';

  @override
  String get cardVisitorDetailConsultationTitle => 'Visit information';

  @override
  String get cardVisitorDetailDate => 'Date';

  @override
  String get cardVisitorDetailTime => 'Time';

  @override
  String get cardVisitorDetailMethod => 'Method';

  @override
  String get cardVisitorDetailDuration => 'Time spent';

  @override
  String get cardVisitorDetailLocation => 'Location';

  @override
  String get cardVisitorDetailDevice => 'Device';

  @override
  String get cardVisitorDetailSaved => 'Saved your card';

  @override
  String get cardVisitorDetailShared => 'Shared your card';

  @override
  String get cardVisitorDetailYes => 'Yes';

  @override
  String get cardVisitorDetailNo => 'No';

  @override
  String get cardVisitorDetailUnavailable => '-';

  @override
  String get cardVisitorDetailMethodQr => 'QR Code';

  @override
  String get cardVisitorDetailMethodNfc => 'Link';

  @override
  String get cardVisitorDetailMethodShare => 'Direct share';

  @override
  String get cardVisitorDetailMethodApp => 'App';

  @override
  String get cardVisitorDetailMethodLink => 'Shared link';

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
  String get cardVisitorDetailSendMessage => 'Send a message';

  @override
  String get cardVisitorDetailAddContact => 'Add to contacts';

  @override
  String get cardVisitorDetailShareProfile => 'Share their profile';

  @override
  String get cardVisitorDetailInviteShareSubject => 'Join me on Drop One';

  @override
  String cardVisitorDetailInviteShareText(
    String appStoreUrl,
    String playStoreUrl,
    String cardUrl,
  ) {
    return 'Hey! Join me on Drop One to exchange business cards easily.\n\nDownload the app:\n• iOS: $appStoreUrl\n• Android: $playStoreUrl\n\nMy card: $cardUrl';
  }

  @override
  String cardVisitorDetailMessageShareText(String name, String url) {
    return 'Here\'s $name\'s Drop One profile: $url';
  }

  @override
  String cardVisitorDetailGuestMessageShareText(String name, String url) {
    return 'Hi $name, thanks for checking my Drop One card. Here\'s my link: $url';
  }

  @override
  String cardVisitorDetailContactAdded(String name) {
    return '$name added to your contacts';
  }

  @override
  String get cardVisitorDetailContactError => 'Unable to add this contact.';

  @override
  String get scanTitle => 'AI Scan';

  @override
  String get scanSubtitle => 'Scan a paper card to save it.';

  @override
  String get scanScanCard => 'Scan card';

  @override
  String get scanAnalyzing => 'Analyzing card…';

  @override
  String get scanNoTextDetected =>
      'No text detected. Retake the photo with better lighting.';

  @override
  String get scanUnreadableCard =>
      'Card was hard to read. Check the fields before saving.';

  @override
  String get scanOwnCardError =>
      'You can\'t scan your own DropOne card. Use someone else\'s paper card.';

  @override
  String scanContactAddedNamed(String name) {
    return '$name added to your contacts';
  }

  @override
  String scanContactSavedToPhoneNamed(String name) {
    return '$name added to your contacts and phone';
  }

  @override
  String get scanContactPhonePermissionDenied =>
      'Contact saved. Allow contacts access to also add it to your phone.';

  @override
  String get scanReviewTitle => 'Review contact';

  @override
  String get scanReviewSubtitle =>
      'Fix the details extracted from the card before saving.';

  @override
  String get scanReviewName => 'Full name';

  @override
  String get scanReviewJobTitle => 'Job title';

  @override
  String get scanReviewCompany => 'Company';

  @override
  String get scanReviewEmail => 'Email';

  @override
  String get scanReviewPhone => 'Phone';

  @override
  String get scanReviewSave => 'Save';

  @override
  String get socialLinkedIn => 'LinkedIn';

  @override
  String get socialInstagram => 'Instagram';

  @override
  String get socialWhatsApp => 'WhatsApp';

  @override
  String get socialTikTok => 'TikTok';

  @override
  String get socialYouTube => 'YouTube';

  @override
  String get socialX => 'X';

  @override
  String get socialFacebook => 'Facebook';

  @override
  String get socialWebsite => 'Website';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonStart => 'Get started';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonFinish => 'Finish';

  @override
  String get commonOrEmail => 'or by email';

  @override
  String get commonIncluded => 'Included';

  @override
  String get commonNotIncluded => 'Not included';

  @override
  String get commonIncludedFeminine => 'Included';

  @override
  String get commonUnlimited => 'Unlimited';

  @override
  String get commonGoHome => 'Go to home';

  @override
  String get commonAlreadyAccount => 'Already have an account? ';

  @override
  String get commonNoAccount => 'No account? ';

  @override
  String get commonEmailHint => 'you@example.com';

  @override
  String get commonPasswordHint => '••••••••';

  @override
  String get commonNameHint => 'Alex Moreau';

  @override
  String get authLoginTitle => 'Welcome back 👋';

  @override
  String get authLoginSubtitle => 'Sign in to access your cards.';

  @override
  String get authPassword => 'Password';

  @override
  String get authPasswordRequired => 'Password required';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get authForgotPasswordTitle => 'Forgot password';

  @override
  String get authForgotPasswordLead =>
      'Enter the email of your account. We’ll send you a link to choose a new password.';

  @override
  String get authForgotPasswordSubmit => 'Send reset link';

  @override
  String get authForgotPasswordSending => 'Sending…';

  @override
  String authForgotPasswordSent(String email) {
    return 'An email was sent to $email with the reset link.';
  }

  @override
  String get authForgotPasswordEmailRequired => 'Email required';

  @override
  String get authForgotPasswordEmailInvalid => 'Invalid email';

  @override
  String get authForgotPasswordBackToLogin => 'Back to sign in';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authContinueApple => 'Continue with Apple';

  @override
  String get authContinueGoogle => 'Continue with Google';

  @override
  String get authGoogleNotConfigured =>
      'Google Sign-In is not configured. Add your OAuth client IDs.';

  @override
  String get authAppleNotConfigured =>
      'Apple Sign-In is not configured on the server.';

  @override
  String get authOAuthCancelled => 'Sign-in cancelled';

  @override
  String get authCreateAccount => 'Create an account';

  @override
  String get authRegisterTitle => 'Let\'s create your account';

  @override
  String get authRegisterSubtitle => 'Just a few seconds and you\'re set.';

  @override
  String get authFullNameRequired => 'Full name required';

  @override
  String get authPasswordMinLength => 'Minimum 8 characters';

  @override
  String get authCreateMyAccount => 'Create my account';

  @override
  String get authAccountDeleted =>
      'This account has been deleted. Please contact us at contact@mega-sn.com if you want to recover your account.';

  @override
  String get accountTypeTitle => 'How will you\nuse DropOne?';

  @override
  String get accountTypeSubtitle => 'You can change this anytime.';

  @override
  String get accountTypePersonalTitle => 'For me';

  @override
  String get accountTypePersonalDescription =>
      'A personal card to network and share.';

  @override
  String get accountTypeTeamTitle => 'For my team';

  @override
  String get accountTypeTeamDescription =>
      'Branded cards centralized for your whole team.';

  @override
  String get accountTypeTeamBadge => 'Team';

  @override
  String get accountTypeMemberLogin => 'Sign in as a member';

  @override
  String get onboardingPage1Title => 'Your business card,\nalways with you';

  @override
  String get onboardingPage1Description =>
      'Create an elegant digital identity card in under 2 minutes.';

  @override
  String get onboardingPage2Title => 'Share in an instant';

  @override
  String get onboardingPage2Description =>
      'QR code, AirDrop or link - no app required for your contacts.';

  @override
  String get onboardingPage3Title => 'Keep it in your Wallet';

  @override
  String get onboardingPage3Description =>
      'Add your card to Apple Wallet and access it from the lock screen.';

  @override
  String get createCardPromptTitle => 'Let\'s create your card';

  @override
  String get createCardPromptSubtitle =>
      'We start with the essentials,\nyou\'ll customize later.';

  @override
  String get createCardPromptButton => 'Create my card';

  @override
  String get createCardHeaderTitle => 'New card';

  @override
  String get createCardStepInfo => 'Information';

  @override
  String get createCardStepNetworks => 'Networks';

  @override
  String get createCardStepPortfolio => 'Portfolio';

  @override
  String get createCardYourInfoTitle => 'Your information';

  @override
  String get createCardYourInfoSubtitle => 'It will appear on your card.';

  @override
  String get createCardYourNetworksTitle => 'Your networks';

  @override
  String get createCardSkipStep => 'Skip this step';

  @override
  String get createCardSuccessTitle => 'Your card is ready!';

  @override
  String get createCardSuccessSubtitle =>
      'Share it or add it to your Wallet right now.';

  @override
  String get createCardAddToWallet => 'Add to Wallet';

  @override
  String get walletAddedGeneric => 'Card added to your Wallet.';

  @override
  String get shareCardTitle => 'Share my card';

  @override
  String get shareCardQrHint =>
      'Have this code scanned - no app required for your contacts.';

  @override
  String get sharePortfolioTitle => 'Share my portfolio';

  @override
  String get sharePortfolioQrHint =>
      'Have this code scanned to open the portfolio.';

  @override
  String get sharePortfolioPublishedTitle => 'Portfolio published';

  @override
  String get sharePortfolioLiveTitle => 'Your site is live';

  @override
  String get sharePortfolioLiveBody =>
      'It now appears on your Drop One card\nwith the “View my portfolio” button.';

  @override
  String get sharePortfolioCopy => 'Copy';

  @override
  String get sharePortfolioCardPreview => 'PREVIEW ON YOUR CARD';

  @override
  String get sharePortfolioViewOnCard => 'View my portfolio';

  @override
  String get sharePortfolioExchange => 'Exchange my details';

  @override
  String get sharePortfolioStatsRowHint =>
      'Visits and clicks, with your card stats';

  @override
  String get shareOptionQr => 'QR code';

  @override
  String get shareOptionMore => 'More';

  @override
  String get shareOptionMessage => 'Message';

  @override
  String get shareOptionAirDrop => 'AirDrop';

  @override
  String get shareOptionLink => 'Link';

  @override
  String shareQuotaReached(int max) {
    return 'Share quota of $max reached.';
  }

  @override
  String shareQuotaUsed(int used, int max) {
    return '$used / $max shares';
  }

  @override
  String get shareSeePremium => 'Upgrade to Premium';

  @override
  String get shareBlockedHint => 'Upgrade to Premium for unlimited sharing.';

  @override
  String get sharePortfolioLockedHint =>
      'A Portfolio subscription is required to share this site.';

  @override
  String get sharePortfolioLockedCta => 'See Portfolio offers';

  @override
  String get portfolioOfferExpired => 'A Portfolio subscription is required';

  @override
  String get portfolioOfferExpiredSubtitle =>
      'Sharing, theme and statistics depend on a Portfolio offer.';

  @override
  String get sharePortfolioLinkLocked =>
      'Link available with the Portfolio offer';

  @override
  String scanQuotaReached(int max) {
    return 'Quota of $max AI scans reached for this month.';
  }

  @override
  String get scanContactAdded => 'Contact added from AI scan';

  @override
  String get scanRecordError => 'Unable to record scan';

  @override
  String get scanStart => 'Start a scan';

  @override
  String get scanSeePremium => 'See Premium offers';

  @override
  String get scanUnlimited => 'Unlimited scans';

  @override
  String get scanNotIncluded => 'AI scan not included';

  @override
  String scanUsedCount(int used, int max) {
    return '$used / $max scans used this month';
  }

  @override
  String get premiumTitle => 'DropOne Premium';

  @override
  String get premiumStart => 'Start Premium';

  @override
  String get premiumProceedToPayment => 'Proceed to payment';

  @override
  String get premiumCheckoutRedirect =>
      'Complete payment in your browser, then return to the app.';

  @override
  String get premiumCheckoutLaunchError => 'Unable to open the payment page';

  @override
  String get premiumRenewalNote => 'Auto-renewal. Cancel anytime in settings.';

  @override
  String get premiumSignUp => 'Sign up';

  @override
  String get premiumPayWithApple => 'Pay with Apple';

  @override
  String get premiumRestorePurchases => 'Restore purchases';

  @override
  String get premiumRestoreEmpty => 'No Apple purchases to restore.';

  @override
  String premiumRestoreSuccess(String title) {
    return 'Purchase restored. $title is now active.';
  }

  @override
  String get premiumAppleIapNote =>
      'Payment will be charged to your Apple account. The subscription renews automatically unless cancelled at least 24 hours before the end of the current period in iOS Settings.';

  @override
  String get premiumTermsOfUse => 'Terms of Use';

  @override
  String get premiumSignupOk => 'Got it';

  @override
  String get premiumSignupNote =>
      'We\'ll get back to you with the registration details.';

  @override
  String premiumSignupThanksTitle(String name) {
    return 'Thank you, $name';
  }

  @override
  String get premiumSignupThanksTitleAnonymous => 'Thank you';

  @override
  String get premiumSignupThanks =>
      'Your request has been recorded. We\'ll get back to you with the registration details.';

  @override
  String get premiumSignupThanksAnonymous =>
      'Your request has been recorded. We\'ll get back to you with the registration details.';

  @override
  String get premiumLoadError => 'Unable to load offers.';

  @override
  String premiumActivated(String title, String price) {
    return 'Premium $title ($price) activated';
  }

  @override
  String get premiumSubscribeError => 'Unable to create subscription';

  @override
  String get premiumNoOffers => 'No offers configured yet';

  @override
  String get premiumFeatureType => 'Type';

  @override
  String get premiumFeatureScans => 'AI Scans';

  @override
  String get premiumFeatureUsers => 'Users';

  @override
  String get premiumFeatureCustomization => 'Customization';

  @override
  String get premiumFeaturePortfolio => 'Portfolio';

  @override
  String get premiumFeatureWallet => 'Wallet';

  @override
  String get premiumFeatureAnalytics => 'Analytics';

  @override
  String get premiumFeatureVisitors => 'Detailed visitors';

  @override
  String get premiumFeatureSocial => 'Social networks';

  @override
  String get premiumOfferFeaturePersonalCard => '1 personal card';

  @override
  String premiumOfferFeatureTeamSeats(int count) {
    return 'From $count users';
  }

  @override
  String premiumOfferFeatureTeamLimit(int count) {
    return '$count included seats';
  }

  @override
  String get premiumOfferFeatureEnterpriseDashboard => 'Company dashboard';

  @override
  String get premiumOfferFeatureShareChannels =>
      'QR Code, link, WhatsApp, message, AirDrop';

  @override
  String get premiumOfferFeatureSharesUnlimited => 'Unlimited sharing';

  @override
  String premiumOfferFeatureShares(int count) {
    return 'Up to $count shares';
  }

  @override
  String get premiumOfferFeatureCustomize => 'Card customization';

  @override
  String get premiumOfferFeatureWallet => 'Wallet (Apple / Google)';

  @override
  String get premiumOfferFeatureAnalytics => 'View analytics';

  @override
  String get premiumOfferFeatureVisitors => 'Visitor insights';

  @override
  String get premiumOfferFeatureSocial => 'Social links';

  @override
  String get premiumOfferFeaturePortfolio => 'Portfolio';

  @override
  String get premiumOfferFeatureAiUnlimited => 'Unlimited AI scans';

  @override
  String premiumOfferFeatureAiScans(int count) {
    return '$count AI scans / month';
  }

  @override
  String get premiumSocialUnlock => 'Add your social networks with Premium';

  @override
  String get premiumSocialSubtitle => 'LinkedIn, Instagram, WhatsApp and more.';

  @override
  String get premiumNoPricing => 'No pricing configured';

  @override
  String get premiumAudienceTeam => 'Team';

  @override
  String get premiumAudiencePersonal => 'Personal';

  @override
  String get premiumAudiencePortfolio => 'Portfolio';

  @override
  String premiumIncludedPlaces(int count) {
    return '$count included seats';
  }

  @override
  String premiumIncludedSeats(int count) {
    return '$count included seats';
  }

  @override
  String premiumTeamMembers(int count) {
    return 'Up to $count members';
  }

  @override
  String premiumSeatsFrom(int min) {
    return 'From $min users';
  }

  @override
  String premiumSeatsRange(int min, int max) {
    return 'From $min to $max users';
  }

  @override
  String get premiumSeatsPickerTitle => 'Number of users';

  @override
  String premiumSeatsIncludedHint(int count) {
    return '$count included - cannot decrease';
  }

  @override
  String premiumSeatsTotal(String amount) {
    return 'Total: $amount';
  }

  @override
  String premiumScansPerPeriod(int count) {
    return '$count / month';
  }

  @override
  String get premiumOneUser => '1 user';

  @override
  String get premiumBadge => 'Premium';

  @override
  String get premiumPortfolioLinked => 'Portfolio linked to card';

  @override
  String get premiumSeeOffers => 'See Premium offers';

  @override
  String get premiumPortfolioSubtitle =>
      'Link your projects and work to your card.';

  @override
  String get cardOfferExpired =>
      'Renew your subscription to reactivate this card';

  @override
  String get cardOfferExpiredSubtitle =>
      'Without a valid plan, this card can no longer be shared.';

  @override
  String get customizeTitle => 'Customize';

  @override
  String get customizeStyleSection => 'CARD STYLE';

  @override
  String get customizeOptionsSection => 'OPTIONS';

  @override
  String get customizeSaved => 'Card saved';

  @override
  String get customizeSyncError => 'Changes applied, sync failed';

  @override
  String get customizeProDesigns => 'Professional designs';

  @override
  String get customizeProDesignsSubtitle => 'Premium ready-to-use templates.';

  @override
  String get customizeShowQr => 'Show QR code';

  @override
  String get customizeCardBadge => 'Card badge';

  @override
  String get teamMembersLoadError => 'Could not load members';

  @override
  String get teamMembersSubscriptionRequired =>
      'An active team subscription is required to add members.';

  @override
  String teamMembersSeatLimitReached(int max) {
    return 'All $max seats are in use. Each extra seat is paid.';
  }

  @override
  String get teamExtraSeatTitle => 'Extra seat';

  @override
  String get teamExtraSeatMessage =>
      'The included seats are in use. Each extra seat is paid.';

  @override
  String get teamExtraSeatPay => 'Pay for one seat';

  @override
  String get teamExtraSeatAdded => 'Seat added. You can invite a member.';

  @override
  String get teamMembersAddTitle => 'Add member';

  @override
  String get teamMembersAddSubtitle =>
      'Send an email invitation. They will need to accept it to join the team.';

  @override
  String get teamMembersFullNameHint => 'Nina Ba';

  @override
  String get teamMembersJobTitleHint => 'Sales representative';

  @override
  String get teamMembersEmailHint => 'nina@company.com';

  @override
  String get teamMembersInvite => 'Invite';

  @override
  String get teamMembersSendInvitation => 'Send invitation';

  @override
  String get teamMembersSetAdmin => 'Set as admin';

  @override
  String get teamMembersSetAdminSubtitle => 'Can manage the team and brand.';

  @override
  String get teamMembersRemoveMember => 'Remove from team';

  @override
  String get teamMembersRemoveTitle => 'Remove this member?';

  @override
  String teamMembersRemoveMessage(String name) {
    return 'Remove $name from the team?';
  }

  @override
  String get teamMembersRemoveSuccess => 'Member removed from the team';

  @override
  String get teamMembersRemoveError => 'Could not remove this member';

  @override
  String get teamMembersCancelInvite => 'Cancel invitation';

  @override
  String get teamMembersCancelInviteTitle => 'Cancel invitation?';

  @override
  String teamMembersCancelInviteMessage(String name) {
    return 'Cancel the invitation sent to $name?';
  }

  @override
  String get teamMembersCancelInviteSuccess => 'Invitation cancelled';

  @override
  String get teamMembersInviteSuccess => 'Invitation sent';

  @override
  String get teamMembersInviteError => 'Could not send the invitation';

  @override
  String get teamMembersSectionTitle => 'TEAM MEMBERS';

  @override
  String teamMembersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count members',
      one: '1 member',
    );
    return '$_temp0';
  }

  @override
  String get teamMembersSeatsUsed => 'Seats used';

  @override
  String get teamMembersStatusActive => 'Active';

  @override
  String get teamMembersStatusPending => 'Pending';

  @override
  String get teamInvitationTitle => 'Team invitation';

  @override
  String teamInvitationMessage(String teamName) {
    return 'You have been invited to join $teamName.';
  }

  @override
  String teamInvitationMessageWithInviter(String inviterName, String teamName) {
    return '$inviterName invited you to join $teamName.';
  }

  @override
  String get teamInvitationAccept => 'Accept';

  @override
  String get teamInvitationDecline => 'Decline';

  @override
  String teamInvitationAccepted(String teamName) {
    return 'You joined $teamName';
  }

  @override
  String get teamInvitationDeclined => 'Invitation declined';

  @override
  String get teamInvitationRespondError =>
      'Could not respond to the invitation';

  @override
  String get setupTeamNameRequired => 'Team name required';

  @override
  String get setupTeamNameLabel => 'TEAM NAME';

  @override
  String get setupTeamNameHint => 'Mega SN';

  @override
  String get setupTeamTitleCreate => 'Set up your team space';

  @override
  String get setupTeamTitleEdit => 'Finish setting up your team space';

  @override
  String get setupTeamSubtitleCreate => 'Set your team\'s logo and card color.';

  @override
  String get setupTeamSubtitleEdit =>
      'Resume your team setup or continue to the next step.';

  @override
  String get setupTeamLogoLabel => 'LOGO';

  @override
  String get setupTeamColorLabel => 'TEAM CARD COLOR';

  @override
  String get setupTeamColorSubtitle => 'Applied to all team members\' cards.';

  @override
  String setupTeamCreated(String name) {
    return 'Team « $name » created';
  }

  @override
  String setupTeamUpdated(String name) {
    return 'Team « $name » updated';
  }

  @override
  String get setupTeamCreateError => 'Could not create the team';

  @override
  String get setupTeamAppRestart =>
      'Fully restart the app (stop + flutter run) then try again.';

  @override
  String proDesignsSubtitle(int count) {
    return '$count Premium ready-to-use templates';
  }

  @override
  String get proDesignsCardTypeSection => 'CARD TYPE';

  @override
  String get proDesignsConfiguringTeam => 'Setting up your team space…';

  @override
  String get proDesignsOpenTeamSetup =>
      'Open team setup to create your pro card.';

  @override
  String proDesignsTemplatesSection(int count) {
    return '$count TEMPLATES - LIVE PREVIEW';
  }

  @override
  String get proDesignsCompanyColors => 'Company colors';

  @override
  String get proDesignsCompanyColorsSubtitle =>
      'Recolors compatible templates with your brand';

  @override
  String get proDesignPreviewCompanyColorRequired =>
      'Choose a company color before applying.';

  @override
  String proDesignPreviewApplied(String name) {
    return 'Template $name applied';
  }

  @override
  String get proDesignPreviewApplyError =>
      'Could not apply the template. Try again.';

  @override
  String get proDesignPreviewRecipientPreview => 'Recipient preview';

  @override
  String get proDesignPreviewUseTemplate => 'Use this template';

  @override
  String get appUpdateSoftTitle => 'Update available';

  @override
  String get appUpdateForceTitle => 'Update required';

  @override
  String get appUpdateSoftMessage =>
      'A new version of DropOne is available. Update to get the latest improvements.';

  @override
  String get appUpdateForceMessage =>
      'This version of DropOne is no longer supported. Please update the app to continue.';

  @override
  String get appUpdateCta => 'Update';

  @override
  String get appUpdateLater => 'Later';
}
