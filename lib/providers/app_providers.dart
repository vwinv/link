import 'package:linkflutter/core/api/api_client.dart';
import 'package:linkflutter/features/auth/services/auth_api_service.dart';
import 'package:linkflutter/features/auth/services/social_auth_service.dart';
import 'package:linkflutter/features/cards/services/cards_api_service.dart';
import 'package:linkflutter/features/teams/services/teams_api_service.dart';
import 'package:linkflutter/features/uploads/services/uploads_api_service.dart';
import 'package:linkflutter/features/sharing/services/sharing_api_service.dart';
import 'package:linkflutter/features/contacts/services/contacts_api_service.dart';
import 'package:linkflutter/features/scan/services/scans_api_service.dart';
import 'package:linkflutter/features/subscriptions/services/subscriptions_api_service.dart';
import 'package:linkflutter/features/wallet/services/wallet_api_service.dart';
import 'package:linkflutter/features/wallet/services/wallet_platform_service.dart';
import 'package:linkflutter/providers/account_type_provider.dart';
import 'package:linkflutter/providers/auth_provider.dart';
import 'package:linkflutter/providers/cards_provider.dart';
import 'package:linkflutter/providers/contacts_provider.dart';
import 'package:linkflutter/providers/create_card_provider.dart';
import 'package:linkflutter/providers/subscriptions_provider.dart';
import 'package:linkflutter/providers/teams_provider.dart';
import 'package:linkflutter/providers/card_analytics_refresh_notifier.dart';
import 'package:linkflutter/core/deep_link/deep_link_service.dart';
import 'package:linkflutter/providers/locale_provider.dart';
import 'package:linkflutter/providers/workspace_mode_provider.dart';
import 'package:linkflutter/providers/onboarding_provider.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

abstract final class AppProviders {
  static final ApiClient _apiClient = ApiClient();

  static List<SingleChildWidget> get providers => [
    Provider<ApiClient>.value(value: _apiClient),
    Provider(
      create: (_) => DeepLinkService(),
      dispose: (_, service) => service.dispose(),
    ),
    Provider(create: (_) => AuthApiService(_apiClient)),
    Provider(create: (_) => SocialAuthService()),
    Provider(create: (_) => CardsApiService(_apiClient)),
    Provider(create: (_) => TeamsApiService(_apiClient)),
    Provider(create: (_) => UploadsApiService(_apiClient)),
    Provider(create: (_) => SubscriptionsApiService(_apiClient)),
    Provider(create: (_) => ScansApiService(_apiClient)),
    Provider(create: (_) => ContactsApiService(_apiClient)),
    Provider(create: (_) => SharingApiService(_apiClient)),
    Provider(create: (_) => WalletApiService(_apiClient)),
    Provider(
      create: (context) =>
          WalletPlatformService(context.read<WalletApiService>()),
    ),
    ChangeNotifierProvider(
      create: (context) => AuthProvider(
        authApi: context.read<AuthApiService>(),
        apiClient: _apiClient,
        socialAuth: context.read<SocialAuthService>(),
      ),
    ),
    ChangeNotifierProvider(create: (_) => OnboardingProvider()),
    ChangeNotifierProvider(create: (_) => CardAnalyticsRefreshNotifier()),
    ChangeNotifierProvider(create: (_) => LocaleProvider()),
    ChangeNotifierProvider(create: (_) => AccountTypeProvider()),
    ChangeNotifierProvider(create: (_) => WorkspaceModeProvider()),
    ChangeNotifierProvider(
      create: (context) =>
          CardsProvider(cardsApi: context.read<CardsApiService>()),
    ),
    ChangeNotifierProvider(
      create: (context) =>
          TeamsProvider(teamsApi: context.read<TeamsApiService>()),
    ),
    ChangeNotifierProvider(
      create: (context) => SubscriptionsProvider(
        subscriptionsApi: context.read<SubscriptionsApiService>(),
      ),
    ),
    ChangeNotifierProvider(
      create: (context) =>
          ContactsProvider(contactsApi: context.read<ContactsApiService>()),
    ),
    ChangeNotifierProvider(
      create: (context) =>
          CreateCardProvider(cardsApi: context.read<CardsApiService>()),
    ),
  ];
}
