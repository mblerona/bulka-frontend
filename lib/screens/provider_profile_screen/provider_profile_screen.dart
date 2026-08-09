import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/models/provider_listing.dart';
import 'package:bulka_frontend/models/registration_profile.dart';
import 'package:bulka_frontend/services/provider_listing_controller.dart';
import 'package:bulka_frontend/widgets/collapsible_checklist.dart';
import 'package:bulka_frontend/widgets/labeled_text_field.dart';
import 'package:bulka_frontend/widgets/photo_grid.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';
import 'package:bulka_frontend/widgets/secondary_button.dart';
import 'package:bulka_frontend/widgets/status_badge.dart';
import 'package:bulka_frontend/widgets/subject_type_toggle.dart';
import 'package:bulka_frontend/widgets/xfile_image.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({
    super.key,
    this.profile = const RegistrationProfile(
      fullName: AppStrings.providerExampleName,
      email: AppStrings.providerExampleEmail,
      phone: AppStrings.providerExamplePhone,
    ),
  });

  final RegistrationProfile profile;

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  static const List<String> _categories = [
    AppStrings.providerCategoryAccommodation,
    AppStrings.providerCategoryGastronomy,
    AppStrings.providerCategoryFarmParticipation,
    AppStrings.providerCategoryDirectSales,
    AppStrings.providerCategoryFarmEducation,
    AppStrings.providerCategoryFarmRecreation,
    AppStrings.providerCategoryOffFarmTours,
  ];

  // No verification system exists yet, so a freshly-registered provider
  // hasn't actually been verified by anyone — default to "not verified"
  // rather than the Figma mock's literal "ВЕРИФИКУВАН" state.
  static const bool _isVerified = false;

  final ProviderListingController _listingController =
      ProviderListingController.instance;

  int get _activeOffersCount => _listingController.activeListingsCount;

  // Average of active listings' own ratings — 0 if none are rated yet.
  double get _averageRating {
    final ratings = _listingController.listings
        .where((l) => l.status == ListingStatus.active && l.rating != null)
        .map((l) => l.rating!)
        .toList();
    if (ratings.isEmpty) return 0;
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }

  // ── Физичко лице (individual) fields ──
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _offerNameController;
  late final TextEditingController _locationController;

  late String _savedName;
  late String _savedPhone;
  late String _savedOfferName;
  late String _savedLocation;

  late Set<String> _selectedCategories;
  late Set<String> _savedCategories;

  // ── Правно лице (legal entity) fields ──
  late final TextEditingController _companyNameController;
  late final TextEditingController _responsiblePersonController;
  late final TextEditingController _legalPhoneController;
  late final TextEditingController _legalEmailController;
  late final TextEditingController _taxIdController;
  late final TextEditingController _businessAddressController;

  late String _savedCompanyName;
  late String _savedResponsiblePerson;
  late String _savedLegalPhone;
  late String _savedLegalEmail;
  late String _savedTaxId;
  late String _savedBusinessAddress;

  late Set<String> _selectedLegalCategories;
  late Set<String> _savedLegalCategories;

  final List<TextEditingController> _contactControllers = [];
  List<String> _savedContacts = [];

  File? _logoFile;
  String? _savedLogoPath;

  final List<XFile> _photos = [];
  List<String> _savedPhotoPaths = [];

  int _subjectTypeIndex = 0;
  int _savedSubjectTypeIndex = 0;

  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _listingController.addListener(_handleListingsChanged);
    _savedName = widget.profile.fullName;
    _savedPhone = widget.profile.phone;
    _savedOfferName = '';
    _savedLocation = '';
    _savedCategories = {AppStrings.providerCategoryAccommodation};
    _selectedCategories = Set.of(_savedCategories);

    _nameController = TextEditingController(text: _savedName)
      ..addListener(_handleFieldChanged);
    _phoneController = TextEditingController(text: _savedPhone)
      ..addListener(_handleFieldChanged);
    _offerNameController = TextEditingController(text: _savedOfferName)
      ..addListener(_handleFieldChanged);
    _locationController = TextEditingController(text: _savedLocation)
      ..addListener(_handleFieldChanged);

    _savedCompanyName = '';
    // Responsible person / phone / email can be taken straight from what
    // was entered at registration, same as the Физичко лице fields above.
    _savedResponsiblePerson = widget.profile.fullName;
    _savedLegalPhone = widget.profile.phone;
    _savedLegalEmail = widget.profile.email;
    _savedTaxId = '';
    _savedBusinessAddress = '';
    _savedLegalCategories = {AppStrings.providerCategoryAccommodation};
    _selectedLegalCategories = Set.of(_savedLegalCategories);

    _companyNameController = TextEditingController(text: _savedCompanyName)
      ..addListener(_handleFieldChanged);
    _responsiblePersonController =
        TextEditingController(text: _savedResponsiblePerson)
          ..addListener(_handleFieldChanged);
    _legalPhoneController = TextEditingController(text: _savedLegalPhone)
      ..addListener(_handleFieldChanged);
    _legalEmailController = TextEditingController(text: _savedLegalEmail)
      ..addListener(_handleFieldChanged);
    _taxIdController = TextEditingController(text: _savedTaxId)
      ..addListener(_handleFieldChanged);
    _businessAddressController =
        TextEditingController(text: _savedBusinessAddress)
          ..addListener(_handleFieldChanged);

    _contactControllers.add(TextEditingController()..addListener(_handleFieldChanged));
    _savedContacts = _contactValues;
  }

  void _handleListingsChanged() => setState(() {});

  @override
  void dispose() {
    _listingController.removeListener(_handleListingsChanged);
    _nameController.dispose();
    _phoneController.dispose();
    _offerNameController.dispose();
    _locationController.dispose();
    _companyNameController.dispose();
    _responsiblePersonController.dispose();
    _legalPhoneController.dispose();
    _legalEmailController.dispose();
    _taxIdController.dispose();
    _businessAddressController.dispose();
    for (final controller in _contactControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  List<String> get _contactValues =>
      _contactControllers.map((c) => c.text).toList();

  void _handleFieldChanged() {
    _recomputeHasChanges();
  }

  void _recomputeHasChanges() {
    final subjectChanged = _subjectTypeIndex != _savedSubjectTypeIndex;
    final changed = subjectChanged ||
        (_subjectTypeIndex == 1 ? _hasLegalChanges : _hasIndividualChanges);
    if (changed != _hasChanges) {
      setState(() => _hasChanges = changed);
    }
  }

  bool get _hasIndividualChanges =>
      _nameController.text != _savedName ||
      _phoneController.text != _savedPhone ||
      _offerNameController.text != _savedOfferName ||
      _locationController.text != _savedLocation ||
      !setEquals(_selectedCategories, _savedCategories);

  bool get _hasLegalChanges =>
      _companyNameController.text != _savedCompanyName ||
      _responsiblePersonController.text != _savedResponsiblePerson ||
      _legalPhoneController.text != _savedLegalPhone ||
      _legalEmailController.text != _savedLegalEmail ||
      _taxIdController.text != _savedTaxId ||
      _businessAddressController.text != _savedBusinessAddress ||
      !setEquals(_selectedLegalCategories, _savedLegalCategories) ||
      !listEquals(_contactValues, _savedContacts) ||
      _logoFile?.path != _savedLogoPath ||
      !listEquals(_photos.map((f) => f.path).toList(), _savedPhotoPaths);

  void _handleCategoriesChanged(Set<String> updated) {
    setState(() => _selectedCategories = updated);
    _recomputeHasChanges();
  }

  void _handleLegalCategoriesChanged(Set<String> updated) {
    setState(() => _selectedLegalCategories = updated);
    _recomputeHasChanges();
  }

  void _addContact() {
    setState(() {
      _contactControllers.add(
        TextEditingController()..addListener(_handleFieldChanged),
      );
    });
    _recomputeHasChanges();
  }

  void _removeContact(int index) {
    final removed = _contactControllers.removeAt(index);
    removed.dispose();
    setState(() {});
    _recomputeHasChanges();
  }

  Future<ImageSource?> _showImageSourceSheet() {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.dsRadiusLg),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.agroForest950,
              ),
              title: const Text(AppStrings.imageSourceGallery),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: AppColors.agroForest950,
              ),
              title: const Text(AppStrings.imageSourceCamera),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickLogo() async {
    final source = await _showImageSourceSheet();
    if (source == null) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked == null) return;
    setState(() => _logoFile = File(picked.path));
    _recomputeHasChanges();
  }

  Future<void> _pickPhotos() async {
    final source = await _showImageSourceSheet();
    if (source == null) return;
    if (source == ImageSource.gallery) {
      final picked = await ImagePicker().pickMultiImage(imageQuality: 85);
      if (picked.isEmpty) return;
      setState(() => _photos.addAll(picked));
    } else {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
      );
      if (picked == null) return;
      setState(() => _photos.add(picked));
    }
    _recomputeHasChanges();
  }

  void _removePhoto(int index) {
    setState(() => _photos.removeAt(index));
    _recomputeHasChanges();
  }

  void _handleSave() {
    setState(() {
      _savedName = _nameController.text;
      _savedPhone = _phoneController.text;
      _savedOfferName = _offerNameController.text;
      _savedLocation = _locationController.text;
      _savedCategories = Set.of(_selectedCategories);

      _savedCompanyName = _companyNameController.text;
      _savedResponsiblePerson = _responsiblePersonController.text;
      _savedLegalPhone = _legalPhoneController.text;
      _savedLegalEmail = _legalEmailController.text;
      _savedTaxId = _taxIdController.text;
      _savedBusinessAddress = _businessAddressController.text;
      _savedLegalCategories = Set.of(_selectedLegalCategories);
      _savedContacts = _contactValues;
      _savedLogoPath = _logoFile?.path;
      _savedPhotoPaths = _photos.map((f) => f.path).toList();

      _savedSubjectTypeIndex = _subjectTypeIndex;
      _hasChanges = false;
    });
    // TODO: persist these fields (subject type, all Физичко/Правно лице
    // fields above, logo and photo uploads) to the backend/database once it
    // exists — same save pathway as the rest of the registration data.
  }

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
    final isLegalEntity = _subjectTypeIndex == 1;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          isLegalEntity
              ? const ScreenHeader(
                  title: AppStrings.providerSetupTitle,
                  subtitle: AppStrings.providerSetupSubtitle,
                  titleFontSize: AppDimensions.dsHeaderSubtitleTitleFontSize,
                  bottomPadding: AppDimensions.dsCompactHeaderBottomPadding,
                  contentGap: AppDimensions.dsHeaderSubtitleGap,
                  subtitleFontSize: AppDimensions.dsSubheadingFontSize,
                )
              : const ScreenHeader(
                  title: AppStrings.profileTitle,
                  titleFontSize: AppDimensions.dsCompactHeaderTitleFontSize,
                  bottomPadding: AppDimensions.dsCompactHeaderBottomPadding,
                  contentGap: AppDimensions.dsCompactHeaderGap,
                ),
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: AppDimensions.dsBodyHorizontalPadding,
                  right: AppDimensions.dsBodyHorizontalPadding,
                  top: AppDimensions.dsBodyTopPadding,
                  bottom: AppDimensions.profileBodyBottomPadding,
                ),
                child: isLegalEntity
                    ? _buildLegalEntityBody()
                    : _buildIndividualBody(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AvatarRow(
          initials: _initials,
          nameController: _nameController,
          email: widget.profile.email,
          isVerified: _isVerified,
        ),
        const SizedBox(height: AppDimensions.profileBodyGap),
        _sectionHeading(AppStrings.providerSubjectTypeLabel),
        const SizedBox(height: AppDimensions.providerSubjectTypeGap),
        SubjectTypeToggle(
          options: const [
            AppStrings.providerSubjectTypeIndividual,
            AppStrings.providerSubjectTypeLegal,
          ],
          selectedIndex: _subjectTypeIndex,
          onChanged: (index) {
            setState(() => _subjectTypeIndex = index);
            _recomputeHasChanges();
          },
        ),
        const SizedBox(height: AppDimensions.profileBodyGap),
        _sectionHeading(AppStrings.profilePersonalDataHeading),
        const SizedBox(height: AppDimensions.profileBodyGap),
        LabeledTextField(
          label: AppStrings.registerNameLabel,
          hintText: AppStrings.registerNamePlaceholder,
          controller: _nameController,
        ),
        const SizedBox(height: AppDimensions.profileFieldsGap),
        LabeledTextField(
          label: AppStrings.profilePhoneLabel,
          hintText: AppStrings.registerPhonePlaceholder,
          keyboardType: TextInputType.phone,
          controller: _phoneController,
        ),
        const SizedBox(height: AppDimensions.profileBodyGap),
        _sectionHeading(AppStrings.providerOfferInfoHeading),
        const SizedBox(height: AppDimensions.profileBodyGap),
        LabeledTextField(
          label: AppStrings.providerOfferNameLabel,
          hintText: AppStrings.providerOfferNamePlaceholder,
          controller: _offerNameController,
        ),
        const SizedBox(height: AppDimensions.profileFieldsGap),
        CollapsibleChecklist(
          headerLabel: AppStrings.providerCategoryHeading,
          items: _categories,
          selectedItems: _selectedCategories,
          onChanged: _handleCategoriesChanged,
        ),
        const SizedBox(height: AppDimensions.profileFieldsGap),
        LabeledTextField(
          label: AppStrings.providerLocationLabel,
          hintText: AppStrings.providerLocationPlaceholder,
          controller: _locationController,
        ),
        const SizedBox(height: AppDimensions.profileBodyGap),
        Row(
          children: [
            _StatCard(
              value: '$_activeOffersCount',
              label: AppStrings.providerActiveOffersLabel,
            ),
            const SizedBox(width: AppDimensions.profileStatsRowGap),
            _StatCard(
              value: '${_averageRating.toStringAsFixed(1)} ★',
              label: AppStrings.providerAverageRatingLabel,
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
    );
  }

  Widget _buildLegalEntityBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: _LogoUploadAvatar(imageFile: _logoFile, onTap: _pickLogo),
        ),
        const SizedBox(height: AppDimensions.providerSetupSectionGap),
        _sectionHeading(AppStrings.providerSubjectTypeLabel),
        const SizedBox(height: AppDimensions.providerSubjectTypeGap),
        SubjectTypeToggle(
          options: const [
            AppStrings.providerSubjectTypeIndividual,
            AppStrings.providerSubjectTypeLegal,
          ],
          selectedIndex: _subjectTypeIndex,
          onChanged: (index) {
            setState(() => _subjectTypeIndex = index);
            _recomputeHasChanges();
          },
        ),
        const SizedBox(height: AppDimensions.providerSetupSectionGap),
        LabeledTextField(
          label: AppStrings.providerLegalCompanyNameLabel,
          hintText: AppStrings.providerLegalCompanyNamePlaceholder,
          controller: _companyNameController,
        ),
        const SizedBox(height: AppDimensions.profileFieldsGap),
        LabeledTextField(
          label: AppStrings.providerLegalResponsiblePersonLabel,
          hintText: AppStrings.providerLegalResponsiblePersonPlaceholder,
          controller: _responsiblePersonController,
        ),
        const SizedBox(height: AppDimensions.profileFieldsGap),
        LabeledTextField(
          label: AppStrings.profilePhoneLabel,
          hintText: AppStrings.registerPhonePlaceholder,
          keyboardType: TextInputType.phone,
          controller: _legalPhoneController,
        ),
        const SizedBox(height: AppDimensions.profileFieldsGap),
        LabeledTextField(
          label: AppStrings.emailLabel,
          hintText: AppStrings.providerLegalEmailPlaceholder,
          keyboardType: TextInputType.emailAddress,
          controller: _legalEmailController,
        ),
        const SizedBox(height: AppDimensions.providerSetupSectionGap),
        _sectionHeading(AppStrings.providerLegalBusinessDetailsHeading),
        const SizedBox(height: AppDimensions.profileFieldsGap),
        LabeledTextField(
          label: AppStrings.providerLegalTaxIdLabel,
          hintText: AppStrings.providerLegalTaxIdPlaceholder,
          keyboardType: TextInputType.number,
          controller: _taxIdController,
        ),
        const SizedBox(height: AppDimensions.profileFieldsGap),
        CollapsibleChecklist(
          headerLabel: AppStrings.providerLegalCategoryHeading,
          items: _categories,
          selectedItems: _selectedLegalCategories,
          onChanged: _handleLegalCategoriesChanged,
        ),
        const SizedBox(height: AppDimensions.profileFieldsGap),
        LabeledTextField(
          label: AppStrings.providerLegalAddressLabel,
          hintText: AppStrings.providerLegalAddressPlaceholder,
          controller: _businessAddressController,
        ),
        const SizedBox(height: AppDimensions.providerSetupSectionGap),
        _sectionHeading(AppStrings.providerAdditionalContactsHeading),
        const SizedBox(height: AppDimensions.providerContactsSectionGap),
        for (var i = 0; i < _contactControllers.length; i++) ...[
          _ContactRow(
            controller: _contactControllers[i],
            onRemove: i == 0 ? null : () => _removeContact(i),
          ),
          if (i != _contactControllers.length - 1)
            const SizedBox(height: AppDimensions.profileFieldsGap),
        ],
        const SizedBox(height: AppDimensions.providerContactsSectionGap),
        SecondaryButton(
          label: AppStrings.providerAddContactButton,
          onPressed: _addContact,
        ),
        const SizedBox(height: AppDimensions.providerSetupSectionGap),
        _sectionHeading(AppStrings.providerPhotosHeading),
        const SizedBox(height: AppDimensions.providerContactsSectionGap),
        PhotoGrid(
          photos: _photos,
          onAdd: _pickPhotos,
          onRemove: _removePhoto,
        ),
        const SizedBox(height: AppDimensions.providerSetupSectionGap),
        PrimaryButton(
          label: AppStrings.providerSaveAndContinueButton,
          disabledBackgroundColor: AppColors.agroGreen600,
          disabledForegroundColor: AppColors.white,
          onPressed: _hasChanges ? _handleSave : null,
        ),
      ],
    );
  }

  Widget _sectionHeading(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: AppDimensions.profileSectionHeadingFontSize,
        color: AppColors.agroForest950,
      ),
    );
  }
}

class _AvatarRow extends StatelessWidget {
  const _AvatarRow({
    required this.initials,
    required this.nameController,
    required this.email,
    required this.isVerified,
  });

  final String initials;
  final TextEditingController nameController;
  final String email;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Row(
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
            initials,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: AppDimensions.profileAvatarInitialsFontSize,
              color: AppColors.agroInk500,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.profileAvatarRowGap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: nameController,
                builder: (context, value, _) => Text(
                  value.text,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: AppDimensions.profileNameFontSize,
                    color: AppColors.agroForest950,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.profileNameColGap),
              // Email is display-only on this screen — it isn't part of the
              // editable "Лични податоци" fields.
              Text(
                email,
                style: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: AppDimensions.profileEmailFontSize,
                  color: AppColors.profileSecondaryText,
                ),
              ),
              const SizedBox(height: AppDimensions.profileNameColGap),
              StatusBadge(
                label: isVerified
                    ? AppStrings.providerVerifiedBadge
                    : AppStrings.providerNotVerifiedBadge,
                backgroundColor: isVerified
                    ? AppColors.profileSoftMint
                    : AppColors.agroGold100,
                textColor: isVerified
                    ? AppColors.agroInk500
                    : AppColors.agroForest950,
              ),
            ],
          ),
        ),
      ],
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

/// Circular, tappable company-logo picker with a camera edit badge — the
/// "Avatar Upload" component from the Правно лице Figma frame. Unlike the
/// individual variant's read-only initials avatar, this one is a real image
/// picker since a legal entity's profile is expected to carry an actual
/// logo image.
class _LogoUploadAvatar extends StatelessWidget {
  const _LogoUploadAvatar({required this.imageFile, required this.onTap});

  final File? imageFile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: SizedBox(
            width: AppDimensions.providerLogoAvatarSize,
            height: AppDimensions.providerLogoAvatarSize,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: AppDimensions.providerLogoAvatarSize,
                  height: AppDimensions.providerLogoAvatarSize,
                  decoration: BoxDecoration(
                    color: AppColors.profileSoftMint,
                    shape: BoxShape.circle,
                    image: imageFile != null
                        ? DecorationImage(
                            image: xfileImageProvider(imageFile!.path),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: AppDimensions.providerLogoEditBadgeSize,
                    height: AppDimensions.providerLogoEditBadgeSize,
                    decoration: BoxDecoration(
                      color: AppColors.agroForest950,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white,
                        width: AppDimensions.providerLogoEditBadgeBorderWidth,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.camera_alt,
                      size: AppDimensions.providerLogoEditBadgeIconSize,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.providerLogoCaptionGap),
        const Text(
          AppStrings.providerAddLogoLabel,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: AppDimensions.providerLogoCaptionFontSize,
            color: AppColors.agroInk500,
          ),
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.controller, this.onRemove});

  final TextEditingController controller;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final field = LabeledTextField(
      label: AppStrings.providerAdditionalContactLabel,
      hintText: AppStrings.providerAdditionalContactPlaceholder,
      controller: controller,
    );
    if (onRemove == null) return field;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: field),
        IconButton(
          onPressed: onRemove,
          icon: const Icon(
            Icons.close,
            size: 18,
            color: AppColors.agroInk500,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
      ],
    );
  }
}

