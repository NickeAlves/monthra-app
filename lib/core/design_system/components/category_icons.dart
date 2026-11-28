import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Maps the Lucide names categories store (kebab-case) to icons.
///
/// The map is const so icon tree shaking keeps only these glyphs. It holds
/// the icons of the default categories (server
/// `internal/domain/category_defaults.go`); the categories PR adds the
/// picker's set, and the 3D icons PR draws its art behind this API.
abstract final class CategoryIcons {
  static const IconData fallback = LucideIcons.tag300;

  static const Map<String, IconData> byName = {
    'house': LucideIcons.house300,
    'shopping-cart': LucideIcons.shoppingCart300,
    'utensils': LucideIcons.utensils300,
    'car': LucideIcons.car300,
    'heart-pulse': LucideIcons.heartPulse300,
    'graduation-cap': LucideIcons.graduationCap300,
    'party-popper': LucideIcons.partyPopper300,
    'shopping-bag': LucideIcons.shoppingBag300,
    'zap': LucideIcons.zap300,
    'repeat': LucideIcons.repeat300,
    'sparkles': LucideIcons.sparkles300,
    'paw-print': LucideIcons.pawPrint300,
    'plane': LucideIcons.plane300,
    'landmark': LucideIcons.landmark300,
    'gift': LucideIcons.gift300,
    'circle-ellipsis': LucideIcons.circleEllipsis300,
    'briefcase': LucideIcons.briefcase300,
    'laptop': LucideIcons.laptop300,
    'trending-up': LucideIcons.trendingUp300,
    'rotate-ccw': LucideIcons.rotateCcw300,
    'hand-heart': LucideIcons.handHeart300,
    'circle-plus': LucideIcons.circlePlus300,
    'tag': LucideIcons.tag300,
  };

  /// The icon named [name], or [fallback] for a name this build lacks.
  static IconData resolve(String name) => byName[name] ?? fallback;
}
