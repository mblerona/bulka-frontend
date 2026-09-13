/// Request body for `POST /api/auth/register/buyer`, matching
/// `RegisterBuyerRequest` in `backend/swagger.json` exactly.
class BuyerRegisterRequest {
  const BuyerRegisterRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    required this.acceptedTerms,
    required this.acceptedPrivacy,
    required this.turnstileToken,
  });

  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String displayName;
  final bool acceptedTerms;
  final bool acceptedPrivacy;
  final String turnstileToken;

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'firstName': firstName,
    'lastName': lastName,
    'displayName': displayName,
    'acceptedTerms': acceptedTerms,
    'acceptedPrivacy': acceptedPrivacy,
    'turnstileToken': turnstileToken,
  };
}
