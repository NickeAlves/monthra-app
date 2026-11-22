import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monthra/core/design_system/design_system.dart';
import 'package:monthra/core/network/api_error_text.dart';
import 'package:monthra/core/network/api_exception.dart';
import 'package:monthra/features/settings/application/sessions_controller.dart';
import 'package:monthra/features/settings/data/models/session_info.dart';
import 'package:monthra/features/settings/domain/device_label.dart';
import 'package:monthra/l10n/l10n.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// The signed-in devices ([SessionsController]): this one first, then the
/// others with their address and last use, each with a sign-out, and a
/// way to sign out every other one (asked first).
class SessionsSection extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<SessionsSection> createState() => _SessionsSectionState();
}

class _SessionsSectionState extends ConsumerState<SessionsSection> {
  /// Sessions being signed out ('*' for every other one).
  final Set<String> _busy = {};

  SessionsController get _controller =>
      ref.read(sessionsControllerProvider.notifier);

  Future<void> _run(
    String key,
    Future<void> Function() call,
    String done,
  ) async {
    final l10n = context.l10n;
    setState(() => _busy.add(key));
    try {
      await call();
      if (!mounted) return;
      showMonthraToast(context, title: done, closeLabel: l10n.appClose);
    } on ApiException catch (e) {
      if (!mounted) return;
      showMonthraToast(
        context,
        title: l10n.sessionsRevokeFailed,
        description: l10n.apiError(e).message,
        destructive: true,
        closeLabel: l10n.appClose,
      );
    } finally {
      if (mounted) setState(() => _busy.remove(key));
    }
  }

  Future<void> _revokeOthers() async {
    final l10n = context.l10n;
    final confirmed = await showMonthraConfirm(
      context,
      title: l10n.sessionsRevokeOthersTitle,
      description: l10n.sessionsRevokeOthersDescription,
      confirmLabel: l10n.sessionsRevokeOthersConfirm,
      cancelLabel: l10n.appCancel,
      barrierLabel: l10n.appClose,
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    await _run('*', _controller.revokeOthers, l10n.sessionsOthersRevoked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final sessions = ref.watch(sessionsControllerProvider);
    return MonthraCard(
      title: Text(l10n.sessionsTitle),
      description: Text(l10n.sessionsDescription),
      // ShadCard sets the content right under the description.
      child: Padding(
        padding: const EdgeInsets.only(top: MonthraSpacing.x6),
        child: switch (sessions) {
          AsyncData(value: final list) => _list(list),
          AsyncError(:final error) => ErrorState(
            title: l10n.sessionsLoadFailed,
            message: error is ApiException
                ? l10n.apiError(error).message
                : null,
            onRetry: () => ref.invalidate(sessionsControllerProvider),
            retryLabel: l10n.appRetry,
          ),
          _ => const _Loading(),
        },
      ),
    );
  }

  Widget _list(List<SessionInfo> sessions) {
    final theme = ShadTheme.of(context);
    final l10n = context.l10n;
    final others = sessions.where((s) => !s.current).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, session) in sessions.indexed) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: MonthraSpacing.x4),
              child: SizedBox(
                height: 1,
                child: ColoredBox(color: theme.colorScheme.border),
              ),
            ),
          _SessionRow(
            session: session,
            busy: _busy.contains(session.id) || _busy.contains('*'),
            onRevoke: () => _run(
              session.id,
              () => _controller.revoke(session.id),
              l10n.sessionsRevoked,
            ),
          ),
        ],
        const SizedBox(height: MonthraSpacing.x6),
        if (others.isEmpty)
          Text(
            l10n.sessionsNoOthers,
            style: theme.textTheme.muted.copyWith(
              color: theme.colorScheme.mutedForeground,
            ),
          )
        else
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: ShadButton.outline(
              enabled: _busy.isEmpty,
              onPressed: _revokeOthers,
              leading: const Icon(LucideIcons.logOut),
              child: ButtonLabel(l10n.sessionsRevokeOthers),
            ),
          ),
      ],
    );
  }
}

/// The name a session's device goes by.
String deviceName(AppLocalizations l10n, String userAgent) =>
    switch (describeUserAgent(userAgent)) {
      (app: true, :final os, browser: _) => l10n.sessionsApp(os ?? ''),
      (browser: final b?, os: final o?, app: _) => l10n.sessionsDevice(b, o),
      (browser: final b?, os: null, app: _) => b,
      (browser: null, os: final o?, app: _) => o,
      _ => l10n.sessionsUnknownDevice,
    };

class _SessionRow extends StatelessWidget {
  const new({
    required this.session,
    required this.busy,
    required this.onRevoke,
  });

  final SessionInfo session;
  final bool busy;
  final VoidCallback onRevoke;

  static IconData _icon(DeviceLabel device) => switch (device.os) {
    'iPadOS' => LucideIcons.tablet,
    'iOS' || 'Android' => LucideIcons.smartphone,
    _ => LucideIcons.monitor,
  };

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final l10n = context.l10n;
    final device = describeUserAgent(session.userAgent);
    final name = deviceName(l10n, session.userAgent);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final when = DateFormat.yMMMd(locale)
        .add_Hm()
        .format(session.lastUsedAt.toLocal());
    final muted = theme.textTheme.muted.copyWith(
      color: theme.colorScheme.mutedForeground,
    );
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: MonthraSpacing.x2,
          runSpacing: MonthraSpacing.x1,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              name,
              style: theme.textTheme.p.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.foreground,
              ),
            ),
            if (session.current)
              ShadBadge.secondary(child: Text(l10n.sessionsThisDevice)),
          ],
        ),
        const SizedBox(height: MonthraSpacing.x1),
        Text(
          session.current
              ? l10n.sessionsActiveNow
              : l10n.sessionsLastActive(when),
          style: muted,
        ),
        Text(l10n.sessionsIp(session.ip), style: muted),
      ],
    );
    final revoke = session.current
        ? null
        : ShadButton.outline(
            enabled: !busy,
            onPressed: onRevoke,
            child: ButtonLabel(
              l10n.sessionsRevoke,
              semanticsLabel: l10n.sessionsRevokeLabel(name),
            ),
          );
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 480;
        final row = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                _icon(device),
                size: 20,
                color: theme.colorScheme.mutedForeground,
              ),
            ),
            const SizedBox(width: MonthraSpacing.x3),
            Expanded(child: text),
            if (revoke != null && !narrow) ...[
              const SizedBox(width: MonthraSpacing.x4),
              revoke,
            ],
          ],
        );
        if (revoke == null || !narrow) return row;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            row,
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: 20 + MonthraSpacing.x3,
                top: MonthraSpacing.x3,
              ),
              child: revoke,
            ),
          ],
        );
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    const row = Row(
      children: [
        Skeleton.circle(size: 20),
        SizedBox(width: MonthraSpacing.x3),
        Expanded(child: SkeletonText()),
      ],
    );
    return const Column(
      children: [
        row,
        SizedBox(height: MonthraSpacing.x4),
        row,
      ],
    );
  }
}
