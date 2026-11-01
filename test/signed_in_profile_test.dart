import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bulka_frontend/blocs/app_bloc_providers.dart';
import 'package:bulka_frontend/blocs/auth/auth_bloc.dart';
import 'package:bulka_frontend/models/auth_user.dart';
import 'package:bulka_frontend/screens/profile_screen/profile_screen.dart';
import 'package:bulka_frontend/screens/provider_profile_screen/provider_profile_screen.dart';
import 'package:bulka_frontend/screens/tourist_home_screen/tourist_home_screen.dart';

import 'test_helpers.dart';

class _MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

const _tourist = AuthUser(
  id: 'u1',
  email: 'ana@example.com',
  roles: ['Buyer'],
  firstName: 'Ана',
  lastName: 'Петровска',
  phone: '071 222 333',
);

const _provider = AuthUser(
  id: 'u2',
  email: 'marko@example.com',
  roles: ['Buyer', 'Provider'],
  firstName: 'Марко',
  lastName: 'Стојанов',
);

Future<void> _pumpSignedIn(
  WidgetTester tester,
  AuthUser user,
  Widget screen,
) async {
  await usePhoneScreen(tester);
  final auth = _MockAuthBloc();
  whenListen(
    auth,
    const Stream<AuthState>.empty(),
    initialState: AuthState(user: user),
  );
  await tester.pumpWidget(
    AppBlocProviders(
      initialLocale: const Locale('mk'),
      // Replaces the real AuthBloc with one that already has a user.
      child: BlocProvider<AuthBloc>.value(
        value: auth,
        child: MaterialApp(home: screen),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('Tourist Home greets the signed-in user', (tester) async {
    await _pumpSignedIn(tester, _tourist, const TouristHomeScreen());
    expect(find.textContaining('Ана'), findsWidgets);
    expect(find.textContaining('Јована'), findsNothing);
  });

  testWidgets('Profile shows the signed-in user', (tester) async {
    await _pumpSignedIn(tester, _tourist, const ProfileScreen());
    expect(find.text('Ана Петровска'), findsWidgets);
    expect(find.text('ana@example.com'), findsWidgets);
    expect(find.text('071 222 333'), findsOneWidget);
    expect(find.textContaining('Јована'), findsNothing);
  });

  testWidgets('Provider Profile shows the signed-in user', (tester) async {
    await _pumpSignedIn(tester, _provider, const ProviderProfileScreen());
    expect(find.text('Марко Стојанов'), findsWidgets);
  });
}
