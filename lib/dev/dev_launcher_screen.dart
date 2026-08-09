import 'package:flutter/material.dart';
import 'package:bulka_frontend/models/registration_profile.dart';
import 'package:bulka_frontend/screens/chat_list_screen/chat_list_screen.dart';
import 'package:bulka_frontend/screens/chat_thread_screen/chat_thread_screen.dart';
import 'package:bulka_frontend/screens/email_verification_screen/email_verification_screen.dart';
import 'package:bulka_frontend/screens/forgot_password_screen/forgot_password_screen.dart';
import 'package:bulka_frontend/screens/login_screen/login_screen.dart';
import 'package:bulka_frontend/screens/my_tickets_screen/my_tickets_screen.dart';
import 'package:bulka_frontend/screens/new_support_ticket_screen/new_support_ticket_screen.dart';
import 'package:bulka_frontend/screens/notifications_screen/notifications_screen.dart';
import 'package:bulka_frontend/screens/profile_screen/profile_screen.dart';
import 'package:bulka_frontend/screens/provider_profile_screen/provider_profile_screen.dart';
import 'package:bulka_frontend/screens/register_screen/register_screen.dart';
import 'package:bulka_frontend/screens/settings_screen/settings_screen.dart';
import 'package:bulka_frontend/screens/splash_screen/splash_screen.dart';
import 'package:bulka_frontend/screens/terms_privacy_screen/terms_privacy_screen.dart';
import 'package:bulka_frontend/services/chat_controller.dart';

/// Debug-only screen picker. Lists every real screen currently implemented
/// in the app and opens it with a plain `Navigator.push` — the actual
/// widget, the actual singleton controllers/state, nothing duplicated or
/// mocked here.
///
/// Only reachable via the `kDebugMode` branch in `main.dart`, so it is
/// never part of the app's real navigation flow and never shows up in a
/// release build.
///
/// To add a newly implemented screen: import it above and append one
/// [_DevScreenEntry] to the relevant section in [_sections] (or add a new
/// section) — no other wiring needed.
class DevLauncherScreen extends StatelessWidget {
  const DevLauncherScreen({super.key});

  static const RegistrationProfile _devProfile = RegistrationProfile(
    fullName: 'Дев Тестовски',
    email: 'dev@example.com',
    phone: '070 000 000',
  );

  static final List<_DevScreenSection> _sections = [
    _DevScreenSection('Onboarding / Auth', [
      _DevScreenEntry('Splash & Language', (_) => const SplashScreen()),
      _DevScreenEntry('Login', (_) => const LoginScreen()),
      _DevScreenEntry(
        'Forgot Password',
        (_) => const ForgotPasswordScreen(),
      ),
      _DevScreenEntry('Register', (_) => const RegisterScreen()),
      _DevScreenEntry(
        'Terms & Privacy',
        (_) => const TermsPrivacyScreen(profile: _devProfile),
      ),
      _DevScreenEntry(
        'Email Verification',
        (_) => const EmailVerificationScreen(),
      ),
    ]),
    _DevScreenSection('Profiles', [
      _DevScreenEntry('Profile · Tourist', (_) => const ProfileScreen()),
      _DevScreenEntry(
        'Profile · Provider',
        (_) => const ProviderProfileScreen(),
      ),
    ]),
    _DevScreenSection('Messaging', [
      _DevScreenEntry('Chat List', (_) => const ChatListScreen()),
      _DevScreenEntry(
        'Chat Thread (first mock conversation)',
        (_) => ChatThreadScreen(
          conversationId: ChatController.instance.conversations.first.id,
        ),
      ),
    ]),
    _DevScreenSection('Support', [
      _DevScreenEntry('My Tickets', (_) => const MyTicketsScreen()),
      _DevScreenEntry(
        'New Support Ticket',
        (_) => const NewSupportTicketScreen(),
      ),
    ]),
    _DevScreenSection('Other', [
      _DevScreenEntry('Notifications', (_) => const NotificationsScreen()),
      _DevScreenEntry('Settings', (_) => const SettingsScreen()),
    ]),
  ];

  void _open(BuildContext context, _DevScreenEntry entry) {
    Navigator.of(context).push(MaterialPageRoute(builder: entry.builder));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dev Screen Launcher'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          for (final section in _sections) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
              child: Text(
                section.title.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 0.6,
                  color: Colors.black54,
                ),
              ),
            ),
            for (final entry in section.entries)
              ListTile(
                title: Text(entry.label),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _open(context, entry),
              ),
          ],
        ],
      ),
    );
  }
}

class _DevScreenSection {
  const _DevScreenSection(this.title, this.entries);
  final String title;
  final List<_DevScreenEntry> entries;
}

class _DevScreenEntry {
  const _DevScreenEntry(this.label, this.builder);
  final String label;
  final WidgetBuilder builder;
}
