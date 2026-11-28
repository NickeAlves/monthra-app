import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/forms/form_alert.dart';
import 'package:monthra/core/forms/validators.dart';
import 'package:monthra/core/network/api_error_text.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/features/auth/application/auth_controller.dart';
import 'package:monthra/features/auth/application/auth_state.dart';
import 'package:monthra/features/settings/application/profile_controller.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The display name (editable) and the sign-in address (read-only: the
/// server has no email change yet).
class ProfileSection extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends ConsumerState<ProfileSection> {
  final _form = GlobalKey<ShadFormState>();
  late final TextEditingController _name = TextEditingController(
    text: _savedName,
  );

  bool _busy = false;
  ApiException? _error;

  String get _savedName => switch (ref.read(authControllerProvider)) {
    SignedIn(:final me) => me.name,
    _ => '',
  };

  bool get _changed => _name.text.trim() != _savedName;

  ApiProblemException? get _problem => switch (_error) {
    final ApiProblemException p => p,
    _ => null,
  };

  @override
  void initState() {
    super.initState();
    _name.addListener(_onNameChanged);
  }

  @override
  void dispose() {
    _name
      ..removeListener(_onNameChanged)
      ..dispose();
    super.dispose();
  }

  void _onNameChanged() => setState(() {});

  Future<void> _save() async {
    if (_busy || !_changed) return;
    setState(() => _error = null);
    if (!(_form.currentState?.validate() ?? false)) return;
    setState(() => _busy = true);
    final l10n = context.l10n;
    try {
      await ref.read(profileControllerProvider.notifier).rename(_name.text);
      if (!mounted) return;
      // The name as the server stored it (trimmed).
      _name.text = _savedName;
      showMonthraToast(
        context,
        title: l10n.settingsNameSaved,
        closeLabel: l10n.appClose,
      );
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final l10n = context.l10n;
    // Follows a rename made elsewhere while the field is untouched.
    ref.listen(
      authControllerProvider.select((s) => s is SignedIn ? s.me.name : null),
      (previous, next) {
        if (next != null && _name.text.trim() == previous) _name.text = next;
      },
    );
    final email = ref.watch(
      authControllerProvider.select((s) => s is SignedIn ? s.me.email : ''),
    );
    final error = _error;
    final problem = _problem;
    final fieldError = problem == null
        ? null
        : l10n.serverFieldError(
            problem.problem,
            'name',
            max: AuthLimits.nameMax,
          );
    return MonthraCard(
      title: Text(l10n.settingsProfileTitle),
      description: Text(l10n.settingsProfileDescription),
      // ShadCard sets the content right under the description.
      child: Padding(
        padding: const EdgeInsets.only(top: MonthraSpacing.x6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (error != null && fieldError == null) ...[
              FormAlert.error(l10n.apiError(error)),
              const SizedBox(height: MonthraSpacing.x4),
            ],
            ShadForm(
              key: _form,
              child: ShadInputFormField(
                id: 'name',
                controller: _name,
                label: Text(l10n.settingsNameLabel),
                validator: l10n.validateName,
                forceErrorText: fieldError,
                autofillHints: const [AutofillHints.name],
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onChanged: (_) {
                  if (fieldError != null) setState(() => _error = null);
                },
                onSubmitted: (_) => unawaited(_save()),
              ),
            ),
            const SizedBox(height: MonthraSpacing.x4),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: MonthraTapTarget(
                child: ShadButton(
                  enabled: _changed && !_busy,
                  onPressed: _save,
                  child: ButtonLabel(l10n.settingsSaveName),
                ),
              ),
            ),
            const SizedBox(height: MonthraSpacing.x6),
            MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settingsEmailLabel,
                    style: theme.textTheme.small.copyWith(
                      color: theme.colorScheme.foreground,
                    ),
                  ),
                  const SizedBox(height: MonthraSpacing.x2),
                  Text(
                    email,
                    style: theme.textTheme.p.copyWith(
                      color: theme.colorScheme.foreground,
                    ),
                  ),
                  const SizedBox(height: MonthraSpacing.x1),
                  Text(
                    l10n.settingsEmailHint,
                    style: theme.textTheme.muted.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
