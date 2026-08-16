import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';
import 'package:bulka_frontend/models/support_attachment.dart';
import 'package:bulka_frontend/services/support_ticket_controller.dart';
import 'package:bulka_frontend/widgets/dashed_border_box.dart';
import 'package:bulka_frontend/widgets/labeled_text_field.dart';
import 'package:bulka_frontend/widgets/primary_button.dart';
import 'package:bulka_frontend/widgets/screen_header.dart';

enum _AttachmentSource { camera, gallery, document }

class NewSupportTicketScreen extends StatefulWidget {
  const NewSupportTicketScreen({super.key});

  @override
  State<NewSupportTicketScreen> createState() => _NewSupportTicketScreenState();
}

class _NewSupportTicketScreenState extends State<NewSupportTicketScreen> {
  static const List<String> _categories = [
    AppStrings.newTicketCategoryReservations,
    AppStrings.newTicketCategoryListings,
    AppStrings.newTicketCategoryPayments,
    AppStrings.newTicketCategoryProfile,
    AppStrings.newTicketCategoryOther,
  ];

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _category = _categories.first;
  SupportAttachment? _attachment;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _titleController.addListener(_updateValidity);
    _descriptionController.addListener(_updateValidity);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateValidity() {
    final isValid =
        _titleController.text.trim().isNotEmpty &&
        _descriptionController.text.trim().isNotEmpty;
    if (isValid != _isValid) {
      setState(() => _isValid = isValid);
    }
  }

  Future<_AttachmentSource?> _showAttachmentSourceSheet() {
    return showModalBottomSheet<_AttachmentSource>(
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
              onTap: () =>
                  Navigator.pop(sheetContext, _AttachmentSource.gallery),
            ),
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: AppColors.agroForest950,
              ),
              title: const Text(AppStrings.imageSourceCamera),
              onTap: () =>
                  Navigator.pop(sheetContext, _AttachmentSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.insert_drive_file_outlined,
                color: AppColors.agroForest950,
              ),
              title: const Text(AppStrings.attachmentSourceDocument),
              onTap: () =>
                  Navigator.pop(sheetContext, _AttachmentSource.document),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAttachment() async {
    final source = await _showAttachmentSourceSheet();
    if (source == null) return;

    if (source == _AttachmentSource.document) {
      final result = await FilePicker.platform.pickFiles();
      if (result == null || result.files.isEmpty) return;
      final file = result.files.first;
      setState(() {
        _attachment = SupportAttachment(
          fileName: file.name,
          localPath: file.path ?? '',
          type: SupportAttachmentType.document,
          sizeBytes: file.size,
        );
      });
      return;
    }

    final picked = await ImagePicker().pickImage(
      source: source == _AttachmentSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return;
    final sizeBytes = await picked.length();
    setState(() {
      _attachment = SupportAttachment(
        fileName: picked.name,
        localPath: picked.path,
        type: SupportAttachmentType.image,
        sizeBytes: sizeBytes,
      );
    });
  }

  void _removeAttachment() => setState(() => _attachment = null);

  void _handleSubmit() {
    if (!_isValid) return;
    SupportTicketController.instance.createTicket(
      category: _category,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      attachment: _attachment,
    );
    // The new ticket is now first in SupportTicketController's shared
    // list — My Tickets renders from that same list, so popping back to it
    // shows the new ticket immediately without any extra plumbing.
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          const ScreenHeader(
            title: AppStrings.newTicketTitle,
            subtitle: AppStrings.newTicketSubtitle,
            titleFontSize: AppDimensions.dsHeaderSubtitleTitleFontSize,
            bottomPadding: AppDimensions.dsCompactHeaderBottomPadding,
            contentGap: AppDimensions.dsHeaderSubtitleGap,
            subtitleFontSize: AppDimensions.dsSubheadingFontSize,
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CategoryField(
                      categories: _categories,
                      value: _category,
                      onChanged: (value) => setState(() => _category = value),
                    ),
                    const SizedBox(height: AppDimensions.newTicketBodyGap),
                    LabeledTextField(
                      label: AppStrings.newTicketTitleLabel,
                      hintText: AppStrings.newTicketTitlePlaceholder,
                      controller: _titleController,
                    ),
                    const SizedBox(height: AppDimensions.newTicketBodyGap),
                    _DescriptionField(controller: _descriptionController),
                    const SizedBox(height: AppDimensions.newTicketBodyGap),
                    _AttachmentField(
                      attachment: _attachment,
                      onTap: _pickAttachment,
                      onRemove: _removeAttachment,
                    ),
                    const SizedBox(height: AppDimensions.newTicketBodyGap),
                    PrimaryButton(
                      label: AppStrings.newTicketSubmitButton,
                      backgroundColor: AppColors.agroGreen600,
                      disabledBackgroundColor: AppColors.agroGreen600,
                      disabledForegroundColor: AppColors.white,
                      onPressed: _isValid ? _handleSubmit : null,
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

class _CategoryField extends StatelessWidget {
  const _CategoryField({
    required this.categories,
    required this.value,
    required this.onChanged,
  });

  final List<String> categories;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          AppStrings.newTicketCategoryLabel,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: AppDimensions.dsFieldLabelFontSize,
            color: AppColors.agroForest950,
          ),
        ),
        const SizedBox(height: AppDimensions.newTicketFieldGap),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.dsInputHorizontalPadding,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.profileStatCardBorder),
            borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.agroInk500,
              ),
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: AppDimensions.dsInputFontSize,
                color: AppColors.agroForest950,
              ),
              items: [
                for (final category in categories)
                  DropdownMenuItem(value: category, child: Text(category)),
              ],
              onChanged: (selected) {
                if (selected != null) onChanged(selected);
              },
            ),
          ),
        ),
      ],
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
          AppStrings.newTicketDescriptionLabel,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: AppDimensions.dsFieldLabelFontSize,
            color: AppColors.agroForest950,
          ),
        ),
        const SizedBox(height: AppDimensions.newTicketFieldGap),
        Container(
          width: double.infinity,
          height: AppDimensions.newTicketTextareaHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.dsInputHorizontalPadding,
            vertical: AppDimensions.dsInputVerticalPadding,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.profileStatCardBorder),
            borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
          ),
          child: TextField(
            controller: controller,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: AppDimensions.dsInputFontSize,
              color: AppColors.agroForest950,
            ),
            decoration: const InputDecoration(
              hintText: AppStrings.newTicketDescriptionPlaceholder,
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

class _AttachmentField extends StatelessWidget {
  const _AttachmentField({
    required this.attachment,
    required this.onTap,
    required this.onRemove,
  });

  final SupportAttachment? attachment;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  String _formatSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    return '${kb.toStringAsFixed(kb < 10 ? 1 : 0)} KB';
  }

  @override
  Widget build(BuildContext context) {
    final current = attachment;
    if (current == null) {
      return GestureDetector(
        onTap: onTap,
        child: DashedBorderBox(
          radius: AppDimensions.dsRadiusMd,
          child: SizedBox(
            width: double.infinity,
            height: AppDimensions.newTicketAttachmentBoxHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  AppStrings.newTicketAttachmentLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: AppDimensions.dsFieldLabelFontSize,
                    color: AppColors.agroForest950,
                  ),
                ),
                const SizedBox(height: AppDimensions.newTicketAttachmentBoxGap),
                const Text(
                  AppStrings.newTicketAttachmentOptional,
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: AppDimensions.newTicketAttachmentSubtextFontSize,
                    color: AppColors.profileSecondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.dsInputHorizontalPadding,
        vertical: AppDimensions.dsInputVerticalPadding,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.profileStatCardBorder),
        borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
      ),
      child: Row(
        children: [
          Icon(
            current.type == SupportAttachmentType.image
                ? Icons.image_outlined
                : Icons.insert_drive_file_outlined,
            size: AppDimensions.newTicketAttachmentRowIconSize,
            color: AppColors.agroInk500,
          ),
          const SizedBox(width: AppDimensions.newTicketAttachmentRowGap),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    current.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: AppDimensions.dsFieldLabelFontSize,
                      color: AppColors.agroForest950,
                    ),
                  ),
                  if (current.sizeBytes != null)
                    Text(
                      _formatSize(current.sizeBytes),
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize:
                            AppDimensions.newTicketAttachmentSubtextFontSize,
                        color: AppColors.profileSecondaryText,
                      ),
                    ),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(
              Icons.close,
              size: AppDimensions.newTicketAttachmentRowIconSize,
              color: AppColors.agroInk500,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}
