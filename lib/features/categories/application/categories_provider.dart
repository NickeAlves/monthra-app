import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:monthra/core/network/api_providers.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/categories/data/categories_api.dart';
import 'package:monthra/features/categories/data/models/category.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'categories_provider.g.dart';

/// Every category of the signed-in person. Reset when the signed-in person
/// changes, and read again when the UI language does: the server names the
/// default categories in the `Accept-Language`. Empty signed out.
@Riverpod(retry: noProviderRetry)
Future<List<Category>> categories(Ref ref) {
  final userId = ref.watch(
    authControllerProvider.select((s) => s is SignedIn ? s.me.id : null),
  );
  ref.watch(apiLanguageProvider);
  if (userId == null) return Future.value(const []);
  return ref.watch(categoriesApiProvider).list();
}
