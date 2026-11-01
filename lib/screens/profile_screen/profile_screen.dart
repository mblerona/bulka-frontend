import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/models/registration_profile.dart';
import 'package:bulka_frontend/models/user_role.dart';
import 'package:bulka_frontend/widgets/app_bottom_nav.dart';
import 'package:bulka_frontend/widgets/labeled_text_field.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.profile = const RegistrationProfile(
      fullName: 'Јована Јованова',
      email: 'jovana@example.com',
      phone: '070 123 456',
      city: 'Охрид, Северна Македонија',
    ),
  });

  final RegistrationProfile profile;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _cityController;

  late String _savedName;
  late String _savedEmail;
  late String _savedPhone;
  late String _savedCity;

  bool _hasChanges = false;

  // Real users start with none of either; these increment once the
  // reservations/favorites systems exist and the user actually makes a
  // reservation or favorites a place.
  static const int _reservationsCount = 0;
  static const int _favoritePlacesCount = 0;

  @override
  void initState() {
    super.initState();
    _savedName = widget.profile.fullName;
    _savedEmail = widget.profile.email;
    _savedPhone = widget.profile.phone;
    _savedCity = widget.profile.city;

    _nameController = TextEditingController(text: _savedName)
      ..addListener(_handleFieldChanged);
    _emailController = TextEditingController(text: _savedEmail)
      ..addListener(_handleFieldChanged);
    _phoneController = TextEditingController(text: _savedPhone)
      ..addListener(_handleFieldChanged);
    _cityController = TextEditingController(text: _savedCity)
      ..addListener(_handleFieldChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _handleFieldChanged() {
    final changed =
        _nameController.text != _savedName ||
        _emailController.text != _savedEmail ||
        _phoneController.text != _savedPhone ||
        _cityController.text != _savedCity;
    if (changed != _hasChanges) {
      setState(() => _hasChanges = changed);
    }
  }

  void _handleSave() {
    setState(() {
      _savedName = _nameController.text;
      _savedEmail = _emailController.text;
      _savedPhone = _phoneController.text;
      _savedCity = _cityController.text;
      _hasChanges = false;
    });
    // TODO: persist these fields (including city) to the backend/database
    // once it exists — same save pathway as the rest of the registration data.
  }

  String get _roleLabel => widget.profile.role == UserRole.buyer
      ? AppStrings.registerRoleGuest
      : AppStrings.registerRoleProvider;

  String get _initials {
    final parts = _nameController.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    final first = parts.first.characters.first;
    final second = parts.length > 1 ? parts[1].characters.first : '';
    return (first + second).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      bottomNavigationBar: const TouristBottomNav(selectedIndex: 4),
      body: Column(
        children: [
          ScreenHeader(
            title: AppStrings.profileTitle,
            titleFontSize: AppDimensions.dsCompactHeaderTitleFontSize,
            bottomPadding: AppDimensions.dsCompactHeaderBottomPadding,
            contentGap: AppDimensions.dsCompactHeaderGap,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: AppDimensions.dsBodyHorizontalPadding,
                  right: AppDimensions.dsBodyHorizontalPadding,
                  top: AppDimensions.dsBodyTopPadding,
                  bottom: AppDimensions.profileBodyBottomPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: AppDimensions.profileAvatarSize,
                          height: AppDimensions.profileAvatarSize,
                          decoration: const BoxDecoration(
                            color: AppColors.profileSoftMint,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _initials,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize:
                                  AppDimensions.profileAvatarInitialsFontSize,
                              color: AppColors.agroInk500,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: AppDimensions.profileAvatarRowGap,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _nameController.text,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: AppDimensions.profileNameFontSize,
                                  color: AppColors.agroForest950,
                                ),
                              ),
                              const SizedBox(
                                height: AppDimensions.profileNameColGap,
                              ),
                              Text(
                                _emailController.text,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: AppDimensions.profileEmailFontSize,
                                  color: AppColors.profileSecondaryText,
                                ),
                              ),
                              const SizedBox(
                                height: AppDimensions.profileNameColGap,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppDimensions
                                      .profileRoleBadgeHorizontalPadding,
                                  vertical: AppDimensions
                                      .profileRoleBadgeVerticalPadding,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.profileSoftMint,
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.pillBorderRadius,
                                  ),
                                ),
                                child: Text(
                                  _roleLabel.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize:
                                        AppDimensions.profileRoleBadgeFontSize,
                                    color: AppColors.agroInk500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.profileBodyGap),
                    Text(
                      AppStrings.profilePersonalDataHeading,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: AppDimensions.profileSectionHeadingFontSize,
                        color: AppColors.agroForest950,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.profileBodyGap),
                    Column(
                      children: [
                        LabeledTextField(
                          label: AppStrings.registerNameLabel,
                          hintText: AppStrings.registerNamePlaceholder,
                          controller: _nameController,
                        ),
                        const SizedBox(height: AppDimensions.profileFieldsGap),
                        LabeledTextField(
                          label: AppStrings.emailLabel,
                          hintText: AppStrings.emailPlaceholder,
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                        ),
                        const SizedBox(height: AppDimensions.profileFieldsGap),
                        LabeledTextField(
                          label: AppStrings.profilePhoneLabel,
                          hintText: AppStrings.registerPhonePlaceholder,
                          keyboardType: TextInputType.phone,
                          controller: _phoneController,
                        ),
                        const SizedBox(height: AppDimensions.profileFieldsGap),
                        LabeledTextField(
                          label: AppStrings.profileCityLabel,
                          hintText: AppStrings.profileCityPlaceholder,
                          controller: _cityController,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.profileBodyGap),
                    Row(
                      children: [
                        _StatCard(
                          value: '$_reservationsCount',
                          label: AppStrings.profileReservationsLabel,
                        ),
                        const SizedBox(width: AppDimensions.profileStatsRowGap),
                        _StatCard(
                          value: '$_favoritePlacesCount',
                          label: AppStrings.profileFavoritePlacesLabel,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.profileBodyGap),
                    PrimaryButton(
                      label: AppStrings.profileSaveButton,
                      disabledBackgroundColor: AppColors.agroGreen600,
                      disabledForegroundColor: AppColors.white,
                      onPressed: _hasChanges ? _handleSave : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: AppDimensions.profileStatCardWidth,
        padding: const EdgeInsets.all(AppDimensions.profileStatCardPadding),
        decoration: BoxDecoration(
          color: AppColors.profileStatCardBackground,
          border: Border.all(color: AppColors.profileStatCardBorder),
          borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: AppDimensions.profileStatNumberFontSize,
                color: AppColors.agroInk500,
              ),
            ),
            const SizedBox(height: AppDimensions.profileStatCardGap),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: AppDimensions.profileStatLabelFontSize,
                color: AppColors.profileSecondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
