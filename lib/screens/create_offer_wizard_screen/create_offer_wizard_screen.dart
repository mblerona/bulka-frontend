import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/core/utils/price_format.dart';
import 'package:bulka_frontend/models/create_listing_draft.dart';
import 'package:bulka_frontend/models/listing_amenity.dart';
import 'package:bulka_frontend/screens/chat_list_screen/chat_list_screen.dart';
import 'package:bulka_frontend/screens/create_offer_success_screen/create_offer_success_screen.dart';
import 'package:bulka_frontend/screens/provider_availability_calendar_screen/provider_availability_calendar_screen.dart';
import 'package:bulka_frontend/screens/provider_dashboard_screen/provider_dashboard_screen.dart';
import 'package:bulka_frontend/screens/provider_offers_screen/provider_offers_screen.dart';
import 'package:bulka_frontend/screens/provider_profile_screen/provider_profile_screen.dart';
import 'package:bulka_frontend/services/provider_listing_controller.dart';
import 'package:bulka_frontend/widgets/app_checkbox.dart';
import 'package:bulka_frontend/widgets/bottom_nav_bar.dart';
import 'package:bulka_frontend/widgets/labeled_text_field.dart';
import 'package:bulka_frontend/widgets/photo_grid.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';
import 'package:bulka_frontend/widgets/xfile_image.dart';

const int _totalSteps = 7;

/// The entire 7-step Create Offer flow as one route/widget — every step is
/// just a different `_currentStep` rendering of the same `State`, sharing
/// one mutable [CreateListingDraft] for the whole session. This is what
/// makes "data survives Next/Back/rebuilds" trivially true: nothing is
/// ever disposed between steps, unlike a per-step-pushed-route design
/// would require.
class CreateOfferWizardScreen extends StatefulWidget {
  const CreateOfferWizardScreen({super.key});

  @override
  State<CreateOfferWizardScreen> createState() =>
      _CreateOfferWizardScreenState();
}

class _CreateOfferWizardScreenState extends State<CreateOfferWizardScreen> {
  final ProviderListingController _listingController =
      ProviderListingController.instance;
  final CreateListingDraft _draft = CreateListingDraft();

  int _currentStep = 0;

  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController()
      ..addListener(() => setState(() => _draft.title = _titleController.text));
    _locationController = TextEditingController()
      ..addListener(
        () => setState(() => _draft.location = _locationController.text),
      );
    _descriptionController = TextEditingController()
      ..addListener(
        () => setState(() => _draft.description = _descriptionController.text),
      );
    _priceController = TextEditingController()
      ..addListener(
        () => setState(
          () => _draft.price = double.tryParse(_priceController.text),
        ),
      );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  bool get _isCurrentStepValid {
    switch (_currentStep) {
      case 0:
        return _draft.isStep1Valid;
      case 1:
        return _draft.isStep2Valid;
      case 2:
        return _draft.isStep3Valid;
      case 3:
        return _draft.isStep4Valid;
      case 4:
        return _draft.isStep5Valid;
      case 5:
        return _draft.isStep6Valid;
      default:
        return true; // Review — unreachable in an invalid state anyway.
    }
  }

  Future<bool> _confirmDiscardIfNeeded() async {
    if (!_draft.hasMeaningfulContent) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.wizardDiscardDialogTitle),
        content: const Text(AppStrings.wizardDiscardDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              AppStrings.wizardDiscardDialogCancel,
              style: TextStyle(color: AppColors.agroForest950),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              AppStrings.wizardDiscardDialogConfirm,
              style: TextStyle(
                color: AppColors.settingsDangerColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _handleExit() async {
    final shouldExit = await _confirmDiscardIfNeeded();
    if (!shouldExit || !mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _handleBack() async {
    if (_currentStep == 0) {
      await _handleExit();
      return;
    }
    setState(() => _currentStep -= 1);
  }

  void _handleNext() {
    if (!_isCurrentStepValid) return;
    if (_currentStep == _totalSteps - 1) {
      _handlePublish();
      return;
    }
    setState(() => _currentStep += 1);
  }

  void _handlePublish() {
    _listingController.createListing(_draft);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const CreateOfferSuccessScreen()),
    );
  }

  /// Navbar taps mid-wizard are treated as leaving the creation flow
  /// entirely (not a stacked push that leaves the wizard alive
  /// underneath) — confirm-discard first if there's anything to lose,
  /// then replace this route with the tapped tab's screen.
  Future<void> _handleNavTap(int index) async {
    final shouldLeave = await _confirmDiscardIfNeeded();
    if (!shouldLeave || !mounted) return;
    final Widget target;
    switch (index) {
      case 0:
        target = const ProviderDashboardScreen();
        break;
      case 1:
        target = const ProviderOffersScreen();
        break;
      case 2:
        target = const ProviderAvailabilityCalendarScreen();
        break;
      case 3:
        target = const ChatListScreen();
        break;
      default:
        target = const ProviderProfileScreen();
    }
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => target));
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

  Future<void> _pickPhotos() async {
    final source = await _showImageSourceSheet();
    if (source == null) return;
    if (source == ImageSource.gallery) {
      final picked = await ImagePicker().pickMultiImage(imageQuality: 85);
      if (picked.isEmpty) return;
      setState(() => _draft.photos.addAll(picked));
    } else {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
      );
      if (picked == null) return;
      setState(() => _draft.photos.add(picked));
    }
  }

  void _removePhoto(int index) => setState(() => _draft.photos.removeAt(index));

  void _selectCategory(String category) =>
      setState(() => _draft.category = category);

  void _toggleAmenity(ListingAmenity amenity) {
    setState(() {
      if (!_draft.amenities.remove(amenity)) {
        _draft.amenities.add(amenity);
      }
    });
  }

  void _adjustGuests(int delta) => setState(() {
    _draft.guestCapacity = (_draft.guestCapacity + delta).clamp(1, 999);
  });

  void _adjustRooms(int delta) => setState(() {
    _draft.roomCount = (_draft.roomCount + delta).clamp(1, 999);
  });

  void _adjustBeds(int delta) => setState(() {
    _draft.bedCount = (_draft.bedCount + delta).clamp(1, 999);
  });

  Future<void> _handlePopAttempt() async {
    final shouldExit = await _confirmDiscardIfNeeded();
    if (shouldExit && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_draft.hasMeaningfulContent,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handlePopAttempt();
      },
      child: Scaffold(
        backgroundColor: AppColors.beigeBackground,
        bottomNavigationBar: BottomNavBar(
          items: providerBottomNavItems,
          selectedIndex: 0,
          onTap: _handleNavTap,
        ),
        body: Column(
          children: [
            ScreenHeader(
              title: AppStrings.wizardHeaderTitle,
              titleFontSize: AppDimensions.dsCompactHeaderTitleFontSize,
              bottomPadding: AppDimensions.dsCompactHeaderBottomPadding,
              contentGap: AppDimensions.dsCompactHeaderGap,
              onBackPressed: _handleExit,
            ),
            _WizardTopBar(currentStep: _currentStep, onClose: _handleExit),
            _WizardProgressBar(currentStep: _currentStep),
            Expanded(
              child: SafeArea(
                top: false,
                bottom: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: AppDimensions.dsBodyHorizontalPadding,
                    right: AppDimensions.dsBodyHorizontalPadding,
                    top: AppDimensions.wizardContentTopPadding,
                    bottom: AppDimensions.wizardContentBottomPadding,
                  ),
                  child: _buildStepContent(),
                ),
              ),
            ),
            _WizardFooter(
              isLastStep: _currentStep == _totalSteps - 1,
              nextEnabled: _isCurrentStepValid,
              onBack: _handleBack,
              onNext: _handleNext,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      case 3:
        return _buildStep4();
      case 4:
        return _buildStep5();
      case 5:
        return _buildStep6();
      default:
        return _buildReview();
    }
  }

  Widget _buildStep1() {
    return _stepColumn([
      _heading(AppStrings.wizardStep1Heading),
      _subtitle(AppStrings.wizardStep1Subtitle),
      _sectionLabel(AppStrings.wizardCategoryLabel),
      Wrap(
        spacing: AppDimensions.wizardChipGap,
        runSpacing: AppDimensions.wizardChipGap,
        children: [
          for (final category in createOfferCategories)
            _CategoryChip(
              label: category,
              isSelected: category == _draft.category,
              onTap: () => _selectCategory(category),
            ),
        ],
      ),
      LabeledTextField(
        label: AppStrings.wizardTitleLabel,
        hintText: AppStrings.wizardTitlePlaceholder,
        controller: _titleController,
      ),
    ]);
  }

  Widget _buildStep2() {
    return _stepColumn([
      _heading(AppStrings.wizardStep2Heading),
      _subtitle(AppStrings.wizardStep2Subtitle),
      LabeledTextField(
        label: AppStrings.wizardLocationLabel,
        hintText: AppStrings.wizardLocationPlaceholder,
        controller: _locationController,
      ),
      Container(
        width: double.infinity,
        height: AppDimensions.wizardMapHeight,
        decoration: BoxDecoration(
          color: AppColors.agroGreen100,
          borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
        ),
        alignment: Alignment.center,
        // TODO: replace with a real map/geocoding integration once one
        // exists — this is intentionally just a static placeholder,
        // matching the Figma design, with no map/location dependency.
        child: const Text(
          AppStrings.wizardMapPinGlyph,
          style: TextStyle(fontSize: AppDimensions.wizardMapPinFontSize),
        ),
      ),
    ]);
  }

  Widget _buildStep3() {
    return _stepColumn([
      _heading(AppStrings.wizardStep3Heading),
      _subtitle(AppStrings.wizardStep3Subtitle),
      _CapacityStepperRow(
        label: AppStrings.wizardGuestsLabel,
        value: _draft.guestCapacity,
        onDecrement: () => _adjustGuests(-1),
        onIncrement: () => _adjustGuests(1),
      ),
      const _StepperDivider(),
      _CapacityStepperRow(
        label: AppStrings.wizardRoomsLabel,
        value: _draft.roomCount,
        onDecrement: () => _adjustRooms(-1),
        onIncrement: () => _adjustRooms(1),
      ),
      const _StepperDivider(),
      _CapacityStepperRow(
        label: AppStrings.wizardBedsLabel,
        value: _draft.bedCount,
        onDecrement: () => _adjustBeds(-1),
        onIncrement: () => _adjustBeds(1),
      ),
    ]);
  }

  Widget _buildStep4() {
    return _stepColumn([
      _heading(AppStrings.wizardStep4Heading),
      _subtitle(AppStrings.wizardStep4Subtitle),
      Column(
        children: [
          for (final amenity in ListingAmenity.values)
            _AmenityRow(
              amenity: amenity,
              isSelected: _draft.amenities.contains(amenity),
              onChanged: (_) => _toggleAmenity(amenity),
            ),
        ],
      ),
    ]);
  }

  Widget _buildStep5() {
    return _stepColumn([
      _heading(AppStrings.wizardStep5Heading),
      _subtitle(AppStrings.wizardStep5Subtitle),
      PhotoGrid(
        photos: _draft.photos,
        onAdd: _pickPhotos,
        onRemove: _removePhoto,
        tileSize: AppDimensions.wizardPhotoTileSize,
        gap: AppDimensions.wizardPhotoGridGap,
      ),
    ]);
  }

  Widget _buildStep6() {
    return _stepColumn([
      _heading(AppStrings.wizardStep6Heading),
      _subtitle(AppStrings.wizardStep6Subtitle),
      _DescriptionField(controller: _descriptionController),
      LabeledTextField(
        label: AppStrings.wizardPriceLabel,
        hintText: AppStrings.wizardPricePlaceholder,
        controller: _priceController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
      ),
    ]);
  }

  Widget _buildReview() {
    final rows = <Widget>[
      _ReviewRow(label: AppStrings.wizardReviewTitleRow, value: _draft.title),
      _ReviewRow(
        label: AppStrings.wizardReviewCategoryRow,
        value: _draft.category,
      ),
      _ReviewRow(
        label: AppStrings.wizardReviewLocationRow,
        value: _draft.location,
      ),
      _ReviewRow(
        label: AppStrings.wizardReviewCapacityRow,
        value: _capacitySummary(),
      ),
      _ReviewRow(
        label: AppStrings.wizardReviewAmenitiesRow,
        value: _countSummary(
          _draft.amenities.length,
          AppStrings.wizardAmenitySingular,
          AppStrings.wizardAmenitiesPlural,
        ),
      ),
      _ReviewRow(
        label: AppStrings.wizardReviewPhotosRow,
        value: _countSummary(
          _draft.photos.length,
          AppStrings.wizardPhotoSingular,
          AppStrings.wizardPhotosPlural,
        ),
      ),
      if (categoryRequiresPrice(_draft.category) || _draft.price != null)
        _ReviewRow(
          label: AppStrings.wizardReviewPriceRow,
          value: _draft.price != null
              ? '${formatMkPrice(_draft.price!)} ${AppStrings.wizardPricePerNightSuffix}'
              : '',
        ),
    ];

    return _stepColumn([
      _heading(AppStrings.wizardReviewHeading),
      _subtitle(AppStrings.wizardReviewSubtitle),
      _buildReviewImage(),
      ...rows,
    ]);
  }

  Widget _buildReviewImage() {
    if (_draft.photos.isEmpty) {
      return Container(
        width: double.infinity,
        height: AppDimensions.wizardReviewImageHeight,
        decoration: BoxDecoration(
          color: AppColors.agroGreen100,
          borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
      child: XFileImage(
        path: _draft.photos.first.path,
        width: double.infinity,
        height: AppDimensions.wizardReviewImageHeight,
        fit: BoxFit.cover,
      ),
    );
  }

  String _capacitySummary() {
    final guests = _countSummary(
      _draft.guestCapacity,
      AppStrings.reservationGuestSingular,
      AppStrings.reservationGuestsPlural,
    );
    final rooms = _countSummary(
      _draft.roomCount,
      AppStrings.wizardRoomSingular,
      AppStrings.wizardRoomsPlural,
    );
    final beds = _countSummary(
      _draft.bedCount,
      AppStrings.wizardBedSingular,
      AppStrings.wizardBedsPlural,
    );
    return '$guests · $rooms · $beds';
  }
}

String _countSummary(int count, String singular, String plural) {
  return '$count ${count == 1 ? singular : plural}';
}

Widget _stepColumn(List<Widget> children) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (var i = 0; i < children.length; i++) ...[
        children[i],
        if (i != children.length - 1)
          const SizedBox(height: AppDimensions.wizardContentGap),
      ],
    ],
  );
}

Widget _heading(String text) => Text(
  text,
  style: const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: AppDimensions.wizardHeadingFontSize,
    color: AppColors.agroForest950,
  ),
);

Widget _subtitle(String text) => Text(
  text,
  style: const TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: AppDimensions.wizardSubtitleFontSize,
    color: AppColors.profileSecondaryText,
  ),
);

Widget _sectionLabel(String text) => Text(
  text,
  style: const TextStyle(
    fontWeight: FontWeight.w600,
    fontSize: AppDimensions.profileSectionHeadingFontSize,
    color: AppColors.agroForest950,
  ),
);

class _WizardTopBar extends StatelessWidget {
  const _WizardTopBar({required this.currentStep, required this.onClose});

  final int currentStep;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.dsBodyHorizontalPadding,
        right: AppDimensions.dsBodyHorizontalPadding,
        top: AppDimensions.wizardTopBarTopPadding,
        bottom: AppDimensions.wizardTopBarBottomPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${AppStrings.wizardStepLabel} ${currentStep + 1} '
            '${AppStrings.wizardStepOfLabel} $_totalSteps',
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: AppDimensions.dsSubheadingFontSize,
              color: AppColors.profileSecondaryText,
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: const Text(
              AppStrings.wizardCloseGlyph,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppDimensions.wizardCloseFontSize,
                color: AppColors.agroInk500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WizardProgressBar extends StatelessWidget {
  const _WizardProgressBar({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppDimensions.dsBodyHorizontalPadding,
        right: AppDimensions.dsBodyHorizontalPadding,
        bottom: AppDimensions.wizardProgressBottomPadding,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.pillBorderRadius),
        child: Container(
          height: AppDimensions.wizardProgressTrackHeight,
          color: AppColors.agroCream100,
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: (currentStep + 1) / _totalSteps,
            child: Container(color: AppColors.agroForest950),
          ),
        ),
      ),
    );
  }
}

class _WizardFooter extends StatelessWidget {
  const _WizardFooter({
    required this.isLastStep,
    required this.nextEnabled,
    required this.onBack,
    required this.onNext,
  });

  final bool isLastStep;
  final bool nextEnabled;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        left: AppDimensions.dsBodyHorizontalPadding,
        right: AppDimensions.dsBodyHorizontalPadding,
        top: AppDimensions.wizardFooterTopPadding,
        bottom: AppDimensions.wizardFooterBottomPadding,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.agroBorder300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Text(
              AppStrings.wizardBackButton,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppDimensions.wizardFooterBackFontSize,
                color: AppColors.agroForest950,
              ),
            ),
          ),
          _WizardPrimaryButton(
            label: isLastStep
                ? AppStrings.wizardPublishButton
                : AppStrings.wizardNextButton,
            enabled: nextEnabled,
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

/// Intrinsic-width primary button — unlike every other `PrimaryButton` in
/// the app (always `width: double.infinity`), Figma's footer button here
/// is sized to its content, so it needs its own small widget rather than
/// forcing the shared one into a shape it doesn't support.
class _WizardPrimaryButton extends StatelessWidget {
  const _WizardPrimaryButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.dsButtonHorizontalPadding,
          vertical: AppDimensions.dsButtonVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: enabled ? AppColors.agroGreen600 : AppColors.agroBorder300,
          borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: AppDimensions.dsButtonFontSize,
            color: enabled ? AppColors.white : AppColors.agroInk500,
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.wizardChipHorizontalPadding,
          vertical: AppDimensions.wizardChipVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.agroForest950 : AppColors.white,
          border: isSelected
              ? null
              : Border.all(color: AppColors.agroBorder300),
          borderRadius: BorderRadius.circular(AppDimensions.pillBorderRadius),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            fontSize: AppDimensions.wizardChipFontSize,
            color: isSelected ? AppColors.white : AppColors.agroInk500,
          ),
        ),
      ),
    );
  }
}

class _StepperDivider extends StatelessWidget {
  const _StepperDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: AppColors.agroBorder300);
  }
}

class _CapacityStepperRow extends StatelessWidget {
  const _CapacityStepperRow({
    required this.label,
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  final String label;
  final int value;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.wizardStepperRowVerticalPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AppDimensions.wizardStepperLabelFontSize,
              color: AppColors.agroForest950,
            ),
          ),
          Row(
            children: [
              _StepperButton(glyph: '–', onTap: value > 1 ? onDecrement : null),
              SizedBox(width: AppDimensions.wizardStepperGap),
              Text(
                '$value',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: AppDimensions.wizardStepperValueFontSize,
                  color: AppColors.agroForest950,
                ),
              ),
              SizedBox(width: AppDimensions.wizardStepperGap),
              _StepperButton(glyph: '+', onTap: onIncrement),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.glyph, required this.onTap});

  final String glyph;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Container(
          width: AppDimensions.wizardStepperButtonSize,
          height: AppDimensions.wizardStepperButtonSize,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.agroBorder300),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            glyph,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: AppDimensions.wizardStepperButtonFontSize,
              color: AppColors.agroForest950,
            ),
          ),
        ),
      ),
    );
  }
}

class _AmenityRow extends StatelessWidget {
  const _AmenityRow({
    required this.amenity,
    required this.isSelected,
    required this.onChanged,
  });

  final ListingAmenity amenity;
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.wizardAmenityRowVerticalPadding,
      ),
      child: Row(
        children: [
          Text(
            amenity.emoji,
            style: const TextStyle(
              fontSize: AppDimensions.wizardAmenityEmojiFontSize,
            ),
          ),
          const SizedBox(width: AppDimensions.wizardAmenityRowGap),
          Expanded(
            child: Text(
              amenity.label,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: AppDimensions.wizardAmenityLabelFontSize,
                color: AppColors.agroForest950,
              ),
            ),
          ),
          AppCheckbox(value: isSelected, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _DescriptionField extends StatelessWidget {
  const _DescriptionField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          AppStrings.wizardDescriptionLabel,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: AppDimensions.dsFieldLabelFontSize,
            color: AppColors.agroForest950,
          ),
        ),
        const SizedBox(height: AppDimensions.dsFieldGap),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.dsInputHorizontalPadding,
            vertical: AppDimensions.dsInputVerticalPadding,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.agroBorder300),
            borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
          ),
          child: TextField(
            controller: controller,
            minLines: 4,
            maxLines: null,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: AppDimensions.dsInputFontSize,
              color: AppColors.agroForest950,
            ),
            decoration: const InputDecoration(
              hintText: AppStrings.wizardDescriptionPlaceholder,
              hintStyle: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: AppDimensions.dsInputFontSize,
                color: AppColors.profileSecondaryText,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.wizardReviewRowVerticalPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: AppDimensions.wizardReviewLabelFontSize,
              color: AppColors.profileSecondaryText,
            ),
          ),
          const SizedBox(width: AppDimensions.wizardContentGap),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppDimensions.wizardReviewLabelFontSize,
                color: AppColors.agroForest950,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
