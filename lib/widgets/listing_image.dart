import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';

/// A listing photo from the backend, or a plain placeholder fill when
/// there's none, while it loads, or if it fails to load.
class ListingImage extends StatelessWidget {
  const ListingImage({
    super.key,
    required this.url,
    required this.height,
    this.width = double.infinity,
    this.placeholderColor = AppColors.profileSoftMint,
  });

  final String? url;
  final double height;
  final double width;
  final Color placeholderColor;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: width,
      height: height,
      color: placeholderColor,
    );
    final url = this.url;
    if (url == null) return placeholder;
    return Image.network(
      url,
      width: width,
      height: height,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : placeholder,
      errorBuilder: (context, error, stackTrace) => placeholder,
    );
  }
}
