/// Contenu officiel de la Politique de confidentialité DropOne.
abstract final class PrivacyPolicyContent {
  static const lastUpdatedLabel = 'Dernière mise à jour : 21 juillet 2026';
  static const title = 'Politique de confidentialité - DropOne';

  static const sections = <PrivacyPolicySection>[
    PrivacyPolicySection(
      title: '1. Introduction',
      paragraphs: [
        'La présente Politique de confidentialité décrit la manière dont MEGA - SN (« nous », « notre » ou « nos ») collecte, utilise, stocke et protège les données personnelles des utilisateurs de l\'application DropOne.',
        'En utilisant DropOne, vous acceptez les pratiques décrites dans cette politique.',
      ],
    ),
    PrivacyPolicySection(
      title: '2. Responsable du traitement',
      paragraphs: [
        'MEGA - SN',
        'Site web : https://mega-sn.com',
        'E-mail : contact@mega-sn.com',
      ],
    ),
    PrivacyPolicySection(
      title: '3. Données collectées',
      paragraphs: [
        'Selon votre utilisation de l\'application, nous pouvons collecter les informations suivantes :',
      ],
      subsections: [
        PrivacyPolicySubsection(
          title: 'Informations de compte',
          bullets: [
            'Nom et prénom',
            'Adresse e-mail',
            'Numéro de téléphone',
            'Photo de profil',
          ],
        ),
        PrivacyPolicySubsection(
          title: 'Informations professionnelles',
          bullets: [
            'Fonction ou poste',
            'Nom de l\'entreprise',
            'Informations de l\'équipe (pour les comptes Entreprise)',
          ],
        ),
        PrivacyPolicySubsection(
          title: 'Informations de profil (facultatives)',
          bullets: [
            'Réseaux sociaux',
            // 'Portfolio',
            'Site web',
            'Informations de présentation',
          ],
        ),
        PrivacyPolicySubsection(
          title: 'Authentification',
          paragraphs: [
            'Lorsque vous choisissez de vous connecter avec Google ou Apple, nous recevons uniquement les informations nécessaires à votre authentification conformément aux autorisations accordées.',
          ],
        ),
        PrivacyPolicySubsection(
          title: 'Notifications',
          paragraphs: [
            'Nous utilisons les notifications push afin de vous informer notamment des nouvelles demandes, des mises à jour et des événements liés à votre compte.',
            'Vous pouvez désactiver ces notifications à tout moment depuis les paramètres de votre appareil.',
          ],
        ),
        PrivacyPolicySubsection(
          title: 'Paiements',
          paragraphs: [
            'Pour les abonnements et achats, les paiements peuvent être réalisés via des prestataires tiers tels que Wave et Orange Money.',
            'Les informations bancaires ou de paiement ne sont jamais stockées par DropOne.',
          ],
        ),
      ],
    ),
    PrivacyPolicySection(
      title: '4. Utilisation des données',
      paragraphs: [
        'Vos données sont utilisées afin de :',
      ],
      bullets: [
        'créer et gérer votre compte ;',
        'générer votre carte de visite numérique ;',
        'partager votre profil via QR Code ou lien ;',
        'gérer les équipes et entreprises ;',
        'permettre l\'authentification sécurisée ;',
        'envoyer des notifications importantes ;',
        'traiter les abonnements et paiements ;',
        'améliorer les performances et la sécurité de l\'application ;',
        'fournir une assistance utilisateur.',
      ],
    ),
    PrivacyPolicySection(
      title: '5. Partage des données',
      paragraphs: [
        'Nous ne vendons jamais vos données personnelles.',
        'Vos informations peuvent uniquement être partagées :',
      ],
      bullets: [
        'avec les prestataires techniques nécessaires au fonctionnement de l\'application ;',
        'avec les services d\'authentification (Google ou Apple) lorsque vous utilisez ces modes de connexion ;',
        'avec les prestataires de paiement (Wave ou Orange Money) lors des transactions ;',
        'lorsque la loi l\'exige.',
      ],
    ),
    PrivacyPolicySection(
      title: '6. Sécurité',
      paragraphs: [
        'Nous mettons en œuvre des mesures techniques et organisationnelles destinées à protéger vos données contre tout accès non autorisé, toute perte, modification ou divulgation.',
        'Cependant, aucun système informatique ne peut garantir une sécurité absolue.',
      ],
    ),
    PrivacyPolicySection(
      title: '7. Conservation des données',
      paragraphs: [
        'Vos données sont conservées aussi longtemps que votre compte est actif ou aussi longtemps que nécessaire pour fournir les services proposés.',
        'Vous pouvez demander la suppression de votre compte à tout moment.',
      ],
    ),
    PrivacyPolicySection(
      title: '8. Vos droits',
      paragraphs: [
        'Vous pouvez à tout moment :',
      ],
      bullets: [
        'consulter vos informations ;',
        'modifier votre profil ;',
        'demander la suppression de votre compte ;',
        'demander la suppression de vos données personnelles ;',
        'retirer votre consentement lorsque celui-ci est applicable.',
      ],
      closingParagraphs: [
        'Pour toute demande, contactez-nous à : contact@mega-sn.com',
      ],
    ),
    PrivacyPolicySection(
      title: '9. Services tiers',
      paragraphs: [
        'DropOne peut utiliser les services suivants :',
      ],
      bullets: [
        'Google Sign-In',
        'Sign in with Apple',
        'Firebase Cloud Messaging (notifications push)',
        'Wave',
        'Orange Money',
      ],
      closingParagraphs: [
        'Ces services disposent de leurs propres politiques de confidentialité.',
      ],
    ),
    PrivacyPolicySection(
      title: '10. Protection des enfants',
      paragraphs: [
        'DropOne n\'est pas destiné aux enfants de moins de 13 ans.',
        'Nous ne collectons pas sciemment de données personnelles concernant des mineurs sans autorisation parentale lorsque celle-ci est requise.',
      ],
    ),
    PrivacyPolicySection(
      title: '11. Modifications',
      paragraphs: [
        'Nous pouvons modifier la présente Politique de confidentialité afin de tenir compte des évolutions légales, techniques ou fonctionnelles.',
        'La date de dernière mise à jour figurera toujours en haut de cette page.',
      ],
    ),
    PrivacyPolicySection(
      title: '12. Contact',
      paragraphs: [
        'Pour toute question relative à cette Politique de confidentialité ou à vos données personnelles, vous pouvez nous contacter :',
        'MEGA - SN',
        'Site : https://mega-sn.com',
        'E-mail : contact@mega-sn.com',
      ],
    ),
  ];
}

class PrivacyPolicySection {
  const PrivacyPolicySection({
    required this.title,
    this.paragraphs = const [],
    this.bullets = const [],
    this.subsections = const [],
    this.closingParagraphs = const [],
  });

  final String title;
  final List<String> paragraphs;
  final List<String> bullets;
  final List<PrivacyPolicySubsection> subsections;
  final List<String> closingParagraphs;
}

class PrivacyPolicySubsection {
  const PrivacyPolicySubsection({
    required this.title,
    this.paragraphs = const [],
    this.bullets = const [],
  });

  final String title;
  final List<String> paragraphs;
  final List<String> bullets;
}
