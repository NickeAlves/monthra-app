import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Maps the Lucide names categories store (kebab-case) to icons.
///
/// The map is const so icon tree shaking keeps only these glyphs. It holds
/// the icons of the default categories (server
/// `internal/domain/category_defaults.go`); the categories PR adds the
/// picker's set, and the 3D icons PR draws its art behind this API.
abstract final class CategoryIcons {
  static const IconData fallback = LucideIcons.tag;

  static const Map<String, IconData> byName = {
    'house': LucideIcons.house,
    'shopping-cart': LucideIcons.shoppingCart,
    'utensils': LucideIcons.utensils,
    'car': LucideIcons.car,
    'heart-pulse': LucideIcons.heartPulse,
    'graduation-cap': LucideIcons.graduationCap,
    'party-popper': LucideIcons.partyPopper,
    'shopping-bag': LucideIcons.shoppingBag,
    'zap': LucideIcons.zap,
    'repeat': LucideIcons.repeat,
    'sparkles': LucideIcons.sparkles,
    'paw-print': LucideIcons.pawPrint,
    'plane': LucideIcons.plane,
    'landmark': LucideIcons.landmark,
    'gift': LucideIcons.gift,
    'circle-ellipsis': LucideIcons.circleEllipsis,
    'briefcase': LucideIcons.briefcase,
    'laptop': LucideIcons.laptop,
    'trending-up': LucideIcons.trendingUp,
    'rotate-ccw': LucideIcons.rotateCcw,
    'hand-heart': LucideIcons.handHeart,
    'circle-plus': LucideIcons.circlePlus,
    'tag': LucideIcons.tag,
  };

  /// The icon named [name], or [fallback] for a name this build lacks.
  static IconData resolve(String name) => byName[name] ?? fallback;
}
