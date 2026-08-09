import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/widgets/app_checkbox.dart';

/// DS/CollapsibleSection — a tappable header (label + chevron) that expands
/// to reveal a bordered box of checkbox rows.
class CollapsibleChecklist extends StatefulWidget {
  const CollapsibleChecklist({
    super.key,
    required this.headerLabel,
    required this.items,
    required this.selectedItems,
    required this.onChanged,
    this.initiallyExpanded = true,
  });

  final String headerLabel;
  final List<String> items;
  final Set<String> selectedItems;
  final ValueChanged<Set<String>> onChanged;
  final bool initiallyExpanded;

  @override
  State<CollapsibleChecklist> createState() => _CollapsibleChecklistState();
}

class _CollapsibleChecklistState extends State<CollapsibleChecklist> {
  late bool _expanded = widget.initiallyExpanded;

  void _toggleItem(String item) {
    final updated = Set<String>.from(widget.selectedItems);
    if (!updated.remove(item)) {
      updated.add(item);
    }
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.headerLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: AppDimensions.dsFieldLabelFontSize,
                  color: AppColors.agroForest950,
                ),
              ),
              Icon(
                _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: AppDimensions.providerChevronIconSize,
                color: AppColors.profileSecondaryText,
              ),
            ],
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: AppDimensions.dsFieldGap),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(
              AppDimensions.providerChecklistBoxPadding,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.agroBorder300),
              borderRadius: BorderRadius.circular(AppDimensions.dsRadiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < widget.items.length; i++) ...[
                  _ChecklistRow(
                    label: widget.items[i],
                    value: widget.selectedItems.contains(widget.items[i]),
                    onChanged: (_) => _toggleItem(widget.items[i]),
                  ),
                  if (i != widget.items.length - 1)
                    const SizedBox(height: AppDimensions.providerChecklistRowGap),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppCheckbox(value: value, onChanged: onChanged),
        const SizedBox(width: AppDimensions.dsCheckboxTextGap),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: AppDimensions.dsCheckboxLabelFontSize,
              color: AppColors.agroForest950,
            ),
          ),
        ),
      ],
    );
  }
}
