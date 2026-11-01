import 'package:flutter/material.dart';
import 'package:bulka_frontend/core/constants/app_colors.dart';
import 'package:bulka_frontend/core/constants/app_strings.dart';

/// A single promotional banner in Tourist Home's horizontally scrolling
/// "Promo Banners" row.
class PromoBanner {
  const PromoBanner({
    required this.id,
    required this.title,
    required this.actionLabel,
    required this.backgroundColor,
  });

  final String id;
  final String title;
  final String actionLabel;
  final Color backgroundColor;
}

/// Local/mock seed data only, matching the 3 example banners in the Figma
/// "20 – Buyer · Discover Home" frame exactly (copy and colors). Isolated
/// here the same way `ProviderListingController._mockListings()` isolates
/// its own seed — nothing else reads/mutates banners yet, so a full
/// `ChangeNotifier` singleton isn't needed; swapping this for a backend
/// fetch later only touches this list, not the widgets that render it.
List<PromoBanner> get mockPromoBanners => [
  PromoBanner(
    id: '1',
    title: AppStrings.homeBanner1Title,
    actionLabel: AppStrings.homeBanner1Action,
    backgroundColor: AppColors.homeBannerGold,
  ),
  PromoBanner(
    id: '2',
    title: AppStrings.homeBanner2Title,
    actionLabel: AppStrings.homeBanner2Action,
    backgroundColor: AppColors.agroInk500,
  ),
  PromoBanner(
    id: '3',
    title: AppStrings.homeBanner3Title,
    actionLabel: AppStrings.homeBanner3Action,
    backgroundColor: AppColors.agroGreen700,
  ),
];
