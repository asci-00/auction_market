import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions/build_context_x.dart';
import '../../../core/l10n/app_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../../core/widgets/app_panel.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../application/order_action_service.dart';

enum OrderPaymentReturnRouteMode {
  success,
  fail,
}

enum _OrderPaymentReturnViewState {
  pending,
  success,
  fail,
  invalid,
}

class OrderPaymentReturnScreen extends ConsumerStatefulWidget {
  const OrderPaymentReturnScreen.success({
    super.key,
    required this.orderId,
    required this.paymentKey,
    required this.amount,
  })  : mode = OrderPaymentReturnRouteMode.success,
        failureCode = null,
        failureMessage = null;

  const OrderPaymentReturnScreen.fail({
    super.key,
    required this.orderId,
    this.failureCode,
    this.failureMessage,
  })  : mode = OrderPaymentReturnRouteMode.fail,
        paymentKey = null,
        amount = null;

  final OrderPaymentReturnRouteMode mode;
  final String? orderId;
  final String? paymentKey;
  final int? amount;
  final String? failureCode;
  final String? failureMessage;

  @override
  ConsumerState<OrderPaymentReturnScreen> createState() =>
      _OrderPaymentReturnScreenState();
}

class _OrderPaymentReturnScreenState
    extends ConsumerState<OrderPaymentReturnScreen> {
  _OrderPaymentReturnViewState _viewState =
      _OrderPaymentReturnViewState.pending;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.mode == OrderPaymentReturnRouteMode.fail) {
      _viewState = _OrderPaymentReturnViewState.fail;
      _errorMessage = _mapFailureMessage(widget.failureMessage);
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _confirmReturnedPayment();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return AppPageScaffold(
      title: context.l10n.ordersTitle,
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          tokens.screenPadding,
          tokens.space4,
          tokens.screenPadding,
          tokens.space8,
        ),
        children: [
          _PaymentReturnStatusPanel(
            mode: widget.mode,
            viewState: _viewState,
            orderId: widget.orderId,
            errorMessage: _errorMessage,
            failureCode: widget.failureCode,
          ),
          SizedBox(height: tokens.space5),
          _PaymentReturnActions(
            orderId: widget.orderId,
            showOpenOrder: widget.orderId != null,
            isPrimaryOrderAction:
                _viewState != _OrderPaymentReturnViewState.pending,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmReturnedPayment() async {
    final orderId = widget.orderId?.trim();
    final paymentKey = widget.paymentKey?.trim();
    final amount = widget.amount;

    if (orderId?.isEmpty != false ||
        paymentKey?.isEmpty != false ||
        amount == null ||
        amount <= 0) {
      if (mounted) {
        setState(() {
          _viewState = _OrderPaymentReturnViewState.invalid;
        });
      }
      return;
    }

    try {
      await ref.read(orderActionServiceProvider).confirmPayment(
            orderId: orderId!,
            paymentKey: paymentKey!,
            amount: amount,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _viewState = _OrderPaymentReturnViewState.success;
      });
    } on FirebaseFunctionsException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _viewState = _OrderPaymentReturnViewState.fail;
        _errorMessage = _mapFirebaseError(error);
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _viewState = _OrderPaymentReturnViewState.fail;
      });
    }
  }

  String? _mapFailureMessage(String? rawMessage) {
    _logInternalError('payment return fail query', rawMessage);
    return null;
  }

  String? _mapFirebaseError(FirebaseFunctionsException error) {
    _logInternalError(
      'payment return confirm failure',
      '${error.code}: ${error.message}',
    );
    return null;
  }

  void _logInternalError(String context, String? detail) {
    final normalized = detail?.trim();
    if (normalized == null || normalized.isEmpty) {
      return;
    }
    debugPrint('[$context] $normalized');
  }
}

class _PaymentReturnStatusPanel extends StatelessWidget {
  const _PaymentReturnStatusPanel({
    required this.mode,
    required this.viewState,
    required this.orderId,
    required this.errorMessage,
    required this.failureCode,
  });

  final OrderPaymentReturnRouteMode mode;
  final _OrderPaymentReturnViewState viewState;
  final String? orderId;
  final String? errorMessage;
  final String? failureCode;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    if (viewState == _OrderPaymentReturnViewState.pending) {
      return AppPanel(
        tone: AppPanelTone.elevated,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.ordersPaymentReturnPendingTitle,
              style: context.textTheme.headlineSmall,
            ),
            SizedBox(height: tokens.space2),
            Text(
              context.l10n.ordersPaymentReturnPendingDescription,
              style: context.textTheme.bodyMedium,
            ),
            SizedBox(height: tokens.space4),
            const AppShimmer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppShimmerBlock(height: 20, width: 160, radius: 12),
                  SizedBox(height: 12),
                  AppShimmerBlock(height: 16, radius: 12),
                  SizedBox(height: 8),
                  AppShimmerBlock(height: 16, width: 200, radius: 12),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final panelTone = switch (viewState) {
      _OrderPaymentReturnViewState.success => AppPanelTone.dark,
      _OrderPaymentReturnViewState.fail => AppPanelTone.surface,
      _OrderPaymentReturnViewState.invalid => AppPanelTone.surface,
      _OrderPaymentReturnViewState.pending => AppPanelTone.elevated,
    };
    final iconData = switch (viewState) {
      _OrderPaymentReturnViewState.success => Icons.check_circle_rounded,
      _OrderPaymentReturnViewState.fail => Icons.error_outline_rounded,
      _OrderPaymentReturnViewState.invalid => Icons.info_outline_rounded,
      _OrderPaymentReturnViewState.pending => Icons.hourglass_bottom_rounded,
    };
    final iconColor = switch (viewState) {
      _OrderPaymentReturnViewState.success => AppColors.accentSuccess,
      _OrderPaymentReturnViewState.fail => AppColors.accentUrgent,
      _OrderPaymentReturnViewState.invalid => AppColors.textSecondary,
      _OrderPaymentReturnViewState.pending => AppColors.accentPrimary,
    };

    return AppPanel(
      tone: panelTone,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(tokens.cardRadius),
            ),
            child: Icon(iconData, color: iconColor),
          ),
          SizedBox(height: tokens.space4),
          Text(
            _title(context),
            style: context.textTheme.headlineSmall?.copyWith(
              color: viewState == _OrderPaymentReturnViewState.success
                  ? AppColors.textInverse
                  : null,
            ),
          ),
          SizedBox(height: tokens.space2),
          Text(
            _description(context),
            style: context.textTheme.bodyMedium?.copyWith(
              color: viewState == _OrderPaymentReturnViewState.success
                  ? AppColors.textInverse.withValues(alpha: 0.78)
                  : null,
            ),
          ),
          if (orderId?.isNotEmpty ?? false) ...[
            SizedBox(height: tokens.space4),
            Text(
              '#$orderId',
              style: context.textTheme.labelLarge?.copyWith(
                color: viewState == _OrderPaymentReturnViewState.success
                    ? AppColors.textInverse
                    : AppColors.textSecondary,
              ),
            ),
          ],
          if (errorMessage?.isNotEmpty ?? false) ...[
            SizedBox(height: tokens.space3),
            Text(
              errorMessage!,
              style: context.textTheme.bodySmall?.copyWith(
                color: viewState == _OrderPaymentReturnViewState.success
                    ? AppColors.textInverse.withValues(alpha: 0.72)
                    : AppColors.accentUrgent,
              ),
            ),
          ],
          if (failureCode?.isNotEmpty ?? false) ...[
            SizedBox(height: tokens.space2),
            Text(
              context.l10n.ordersPaymentReturnCodeLabel(failureCode!),
              style: context.textTheme.bodySmall?.copyWith(
                color: viewState == _OrderPaymentReturnViewState.success
                    ? AppColors.textInverse.withValues(alpha: 0.72)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _title(BuildContext context) {
    return switch (viewState) {
      _OrderPaymentReturnViewState.pending =>
        context.l10n.ordersPaymentReturnPendingTitle,
      _OrderPaymentReturnViewState.success =>
        context.l10n.ordersPaymentReturnSuccessTitle,
      _OrderPaymentReturnViewState.fail =>
        context.l10n.ordersPaymentReturnFailTitle,
      _OrderPaymentReturnViewState.invalid =>
        context.l10n.ordersPaymentReturnInvalidTitle,
    };
  }

  String _description(BuildContext context) {
    return switch (viewState) {
      _OrderPaymentReturnViewState.pending =>
        context.l10n.ordersPaymentReturnPendingDescription,
      _OrderPaymentReturnViewState.success =>
        context.l10n.ordersPaymentReturnSuccessDescription,
      _OrderPaymentReturnViewState.fail =>
        context.l10n.ordersPaymentReturnFailDescription,
      _OrderPaymentReturnViewState.invalid =>
        context.l10n.ordersPaymentReturnInvalidDescription,
    };
  }
}

class _PaymentReturnActions extends StatelessWidget {
  const _PaymentReturnActions({
    required this.orderId,
    required this.showOpenOrder,
    required this.isPrimaryOrderAction,
  });

  final String? orderId;
  final bool showOpenOrder;
  final bool isPrimaryOrderAction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final normalizedOrderId = orderId?.trim();
    final encodedOrderId =
        normalizedOrderId == null || normalizedOrderId.isEmpty
            ? null
            : Uri.encodeComponent(normalizedOrderId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showOpenOrder && encodedOrderId != null)
          isPrimaryOrderAction
              ? FilledButton(
                  onPressed: () => context.router.go('/orders/$encodedOrderId'),
                  child: Text(context.l10n.ordersPaymentReturnActionOpenOrder),
                )
              : OutlinedButton(
                  onPressed: () => context.router.go('/orders/$encodedOrderId'),
                  child: Text(context.l10n.ordersPaymentReturnActionOpenOrder),
                ),
        if (showOpenOrder && encodedOrderId != null)
          SizedBox(height: tokens.space3),
        isPrimaryOrderAction
            ? OutlinedButton(
                onPressed: () => context.router.go('/orders'),
                child: Text(context.l10n.ordersPaymentReturnActionBackToOrders),
              )
            : FilledButton.tonal(
                onPressed: () => context.router.go('/orders'),
                child: Text(context.l10n.ordersPaymentReturnActionBackToOrders),
              ),
      ],
    );
  }
}
