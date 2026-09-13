/// Request body for `POST /api/auth/register/provider`, matching
/// `RegisterProviderRequest` in `backend/swagger.json` exactly (adds
/// `businessName` on top of the Buyer fields).
class ProviderRegisterRequest {
  const ProviderRegisterRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    required this.businessName,
    required this.acceptedTerms,
    required this.acceptedPrivacy,
    required this.turnstileToken,
  });

  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String displayName;
  final String businessName;
  final bool acceptedTerms;
  final bool acceptedPrivacy;
  final String turnstileToken;

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'firstName': firstName,
    'lastName': lastName,
    'displayName': displayName,
    'businessName': businessName,
    'acceptedTerms': acceptedTerms,
    'acceptedPrivacy': acceptedPrivacy,
    'turnstileToken': turnstileToken,
  };
}
