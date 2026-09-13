import 'package:bulka_frontend/models/user_role.dart';

/// Translates the backend's raw `AuthUser.roles` strings into this app's
/// [UserRole]. THE one centralized place that comparison happens — nothing
/// else should switch on a raw role string.
///
/// Confirmed backend role strings so far: only `"Admin"`, observed on a real
/// `/api/auth/login` response for an admin test account.
/// `backend/swagger.json` declares no role enum and no role field anywhere
/// in the whole document. The `buyer`/`provider` segments in
/// `/api/auth/register/buyer` and `/api/auth/register/provider` (and the
/// `RegisterBuyerRequest`/`RegisterProviderRequest` schema names) are
/// URL/schema naming conventions, not confirmed role string values — do NOT
/// assume the real Buyer/Provider role strings are `"Buyer"`/`"Provider"`.
///
/// Returns `null` for:
/// - `"Admin"` (confirmed real role; this app has no Admin destination), and
/// - any other/unrecognized role string (nothing else has been confirmed).
///
/// Add a case here — and only here — once a real Buyer or Provider account's
/// login response confirms the actual role string.
UserRole? mapBackendRoleToUserRole(List<String> roles) {
  for (final role in roles) {
    switch (role) {
      case 'Admin':
        return null;
    }
  }
  return null;
}
