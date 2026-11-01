import 'package:bulka_frontend/models/user_role.dart';

/// Translates the backend's raw `AuthUser.roles` strings into this app's
/// [UserRole]. THE one centralized place that comparison happens — nothing
/// else should switch on a raw role string.
///
/// Confirmed backend role strings: `"Admin"` (an admin test account),
/// `"Buyer"`, and `"Provider"` — all confirmed live on real
/// `/api/auth/login` responses.
///
/// **Critical, confirmed live:** a real Provider account's `roles` was
/// `["Buyer", "Provider"]`, not just `["Provider"]` — every Provider
/// account is apparently also a Buyer. So this deliberately checks for
/// `"Provider"` first via [List.contains] rather than iterating the list
/// and returning on whichever role is matched first — doing that would
/// return [UserRole.buyer] for a real Provider account whenever `"Buyer"`
/// happens to be listed before `"Provider"`, exactly as observed. Do not
/// "simplify" this back down to a single iterate-and-switch loop.
///
/// Returns `null` for:
/// - `"Admin"` (confirmed real role; this app has no Admin destination), and
/// - any other/unrecognized role string — never defaults an unrecognized
///   role to [UserRole.buyer].
UserRole? mapBackendRoleToUserRole(List<String> roles) {
  if (roles.contains('Provider')) return UserRole.owner;
  if (roles.contains('Buyer')) return UserRole.buyer;
  return null;
}
