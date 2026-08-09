import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_dimensions.dart';
import 'package:bulka_frontend/widgets/dashed_border_box.dart';
import 'package:bulka_frontend/widgets/xfile_image.dart';

/// A wrapping grid of picked-photo thumbnails (each removable) plus a
/// trailing dashed "+" tile to add more. Shared by the Provider Profile
/// Setup (Правно лице) photo section and the Create Offer wizard's Step
/// 5 — [tileSize] lets each call site match its own Figma spec (106px vs
/// 108px) without forking the widget.
class PhotoGrid extends StatelessWidget {
  const PhotoGrid({
    super.key,
    required this.photos,
    required this.onAdd,
    required this.onRemove,
    this.tileSize = AppDimensions.providerPhotoTileSize,
    this.gap = AppDimensions.providerPhotoGridGap,
  });

  final List<XFile> photos;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final double tileSize;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: [
        for (var i = 0; i < photos.length; i++)
          _PhotoTile(
            file: photos[i],
            tileSize: tileSize,
            onRemove: () => onRemove(i),
          ),
        _AddPhotoTile(tileSize: tileSize, onTap: onAdd),
      ],
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.file,
    required this.tileSize,
    required this.onRemove,
  });

  final XFile file;
  final double tileSize;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: tileSize,
      height: tileSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.dsRadiusSm),
            child: XFileImage(
              path: file.path,
              width: tileSize,
              height: tileSize,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.agroForest950,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.tileSize, required this.onTap});

  final double tileSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DashedBorderBox(
        radius: AppDimensions.dsRadiusSm,
        child: SizedBox(
          width: tileSize,
          height: tileSize,
          child: const Center(
            child: Text(
              '+',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppDimensions.providerAddPhotoPlusFontSize,
                color: AppColors.agroInk500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
