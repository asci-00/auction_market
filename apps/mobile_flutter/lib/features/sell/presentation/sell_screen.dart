import 'package:cloud_functions/cloud_functions.dart';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/extensions/build_context_x.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../../core/l10n/app_localization.dart';
import '../../../core/logging/app_logger.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_editorial_hero.dart';
import '../../../core/widgets/app_loading_overlay.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../../core/widgets/app_shell_insets.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../application/sell_flow_service.dart';
import '../data/sell_draft_form_data.dart';
import '../data/sell_draft_summary.dart';
import 'sell_validation_state.dart';
import 'sell_view_model.dart';
import 'widgets/sell_action_panel.dart';
import 'widgets/sell_category_panel.dart';
import 'widgets/sell_details_panel.dart';
import 'widgets/sell_image_picker_panel.dart';
import 'widgets/sell_policy_panel.dart';
import 'widgets/sell_progress_panel.dart';
import 'widgets/sell_pricing_panel.dart';
import 'widgets/sell_recent_drafts_section.dart';

class SellScreen extends ConsumerStatefulWidget {
  const SellScreen({super.key});

  @override
  ConsumerState<SellScreen> createState() => _SellScreenState();
}

class _SellScreenState extends ConsumerState<SellScreen> {
  final _categorySubController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _conditionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _startPriceController = TextEditingController();
  final _buyNowPriceController = TextEditingController();
  final _scrollController = ScrollController();
  final _imagePicker = ImagePicker();

  String? _itemId;
  String _categoryMain = 'GOODS';
  int _durationDays = 3;
  bool _appraisalRequested = false;
  bool _isSavingDraft = false;
  bool _isPublishing = false;
  bool _hasUnsavedChanges = false;
  bool _suppressDirtyTracking = false;
  DateTime? _lastSavedAt;
  SellValidationState _validationState = const SellValidationState.empty();
  List<String> _existingImageUrls = <String>[];
  List<String> _existingAuthImageUrls = <String>[];
  List<XFile> _newImageFiles = <XFile>[];
  List<XFile> _newAuthImageFiles = <XFile>[];

  @override
  void initState() {
    super.initState();
    for (final controller in _formControllers) {
      controller.addListener(_handleFormChanged);
    }
  }

  @override
  void dispose() {
    for (final controller in _formControllers) {
      controller.removeListener(_handleFormChanged);
    }
    _categorySubController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _conditionController.dispose();
    _tagsController.dispose();
    _startPriceController.dispose();
    _buyNowPriceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final userId = ref.watch(firebaseAuthProvider).currentUser?.uid;
    final sellAsync = userId == null
        ? null
        : ref.watch(sellViewModelProvider(userId));

    return AppPageScaffold(
      title: context.l10n.sellTitle,
      body: AppLoadingOverlay(
        isLoading: _isSavingDraft || _isPublishing,
        message: _isPublishing
            ? context.l10n.sellPublishing
            : context.l10n.sellSavingDraft,
        child: NotificationListener<ScrollStartNotification>(
          onNotification: (notification) {
            if (defaultTargetPlatform == TargetPlatform.iOS) {
              final focus = FocusManager.instance.primaryFocus;
              if (focus != null && focus.hasFocus) {
                focus.unfocus();
              }
            }
            return false;
          },
          child: ListView(
            controller: _scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(
              tokens.screenPadding,
              tokens.space4,
              tokens.screenPadding,
              math.max(tokens.space8 + context.shellBottomInset, tokens.space4),
            ),
            children: [
              AppEditorialHero(
                eyebrow: context.l10n.sellHeroEyebrow,
                title: context.l10n.sellHeroTitle,
                description: context.l10n.sellHeroDescription,
                badges: const [
                  AppStatusBadge(kind: AppStatusKind.pending),
                  AppStatusBadge(kind: AppStatusKind.verified),
                ],
              ),
              SizedBox(height: tokens.space5),
              const SellPolicyPanel(),
              SizedBox(height: tokens.space6),
              SellProgressPanel(
                categoryReady: _categoryReady,
                detailsReady: _detailsReady,
                pricingReady: _pricingReady,
                imagesReady: _imagesReady,
                publishReady: _publishReady,
                currentDraftId: _itemId,
                hasUnsavedChanges: _hasUnsavedChanges,
                lastSavedAt: _lastSavedAt,
              ),
              SizedBox(height: tokens.space6),
              SellRecentDraftsSection(
                userId: userId,
                drafts: sellAsync?.valueOrNull?.recentDrafts ?? const [],
                isLoading: sellAsync?.isLoading ?? false,
                hasError: sellAsync?.hasError ?? false,
                onSelectDraft: _applyDraft,
              ),
              SizedBox(height: tokens.space6),
              SellCategoryPanel(
                categoryMain: _categoryMain,
                categorySubController: _categorySubController,
                categorySubError: _validationState.errorFor(
                  SellValidationField.categorySub,
                ),
                onCategoryMainChanged: (value) {
                  setState(() {
                    _categoryMain = value;
                    _hasUnsavedChanges = true;
                    _syncValidationState();
                  });
                },
              ),
              SizedBox(height: tokens.space4),
              SellDetailsPanel(
                titleController: _titleController,
                conditionController: _conditionController,
                tagsController: _tagsController,
                descriptionController: _descriptionController,
                appraisalRequested: _appraisalRequested,
                titleError: _validationState.errorFor(
                  SellValidationField.title,
                ),
                conditionError: _validationState.errorFor(
                  SellValidationField.condition,
                ),
                descriptionError: _validationState.errorFor(
                  SellValidationField.description,
                ),
                onAppraisalChanged: (value) {
                  setState(() {
                    _appraisalRequested = value;
                    _hasUnsavedChanges = true;
                    _syncValidationState();
                  });
                },
              ),
              SizedBox(height: tokens.space4),
              SellPricingPanel(
                startPriceController: _startPriceController,
                buyNowPriceController: _buyNowPriceController,
                durationDays: _durationDays,
                startPriceError: _validationState.errorFor(
                  SellValidationField.startPrice,
                ),
                buyNowPriceError: _validationState.errorFor(
                  SellValidationField.buyNowPrice,
                ),
                onDurationChanged: (value) {
                  setState(() {
                    _durationDays = value;
                    _hasUnsavedChanges = true;
                    _syncValidationState();
                  });
                },
              ),
              SizedBox(height: tokens.space4),
              SellImagePickerPanel(
                title: context.l10n.sellImageMainTitle,
                description: context.l10n.sellImageMainDescription,
                buttonLabel: context.l10n.sellImageMainAction,
                existingUrls: _existingImageUrls,
                newFiles: _newImageFiles,
                onPickPressed: _pickGalleryImages,
                errorText: _validationState.errorFor(
                  SellValidationField.galleryImages,
                ),
              ),
              SizedBox(height: tokens.space4),
              SellImagePickerPanel(
                title: context.l10n.sellImageAuthTitle,
                description: context.l10n.sellImageAuthDescription,
                buttonLabel: context.l10n.sellImageAuthAction,
                existingUrls: _existingAuthImageUrls,
                newFiles: _newAuthImageFiles,
                onPickPressed: _pickAuthImages,
                errorText: _validationState.errorFor(
                  SellValidationField.authImages,
                ),
              ),
              SizedBox(height: tokens.space6),
              SellActionPanel(
                itemId: _itemId,
                isSavingDraft: _isSavingDraft,
                isPublishing: _isPublishing,
                onSaveDraft: _saveDraft,
                onPublish: _publish,
                validationMode: _validationState.mode,
                validationSummary: _validationState.summaryErrors,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickGalleryImages() async {
    final picked = await _imagePicker.pickMultiImage();
    if (picked.isEmpty) {
      return;
    }

    final remainingSlots =
        10 - _existingImageUrls.length - _newImageFiles.length;
    if (remainingSlots <= 0) {
      return;
    }

    setState(() {
      _newImageFiles = [..._newImageFiles, ...picked.take(remainingSlots)];
      _hasUnsavedChanges = true;
      _syncValidationState();
    });
  }

  Future<void> _pickAuthImages() async {
    final picked = await _imagePicker.pickMultiImage();
    if (picked.isEmpty) {
      return;
    }

    setState(() {
      _newAuthImageFiles = [..._newAuthImageFiles, ...picked].toList();
      _hasUnsavedChanges = true;
      _syncValidationState();
    });
  }

  void _applyDraft(SellDraftSummary draft) {
    _suppressDirtyTracking = true;
    _categorySubController.text = draft.categorySub;
    _titleController.text = draft.title;
    _descriptionController.text = draft.description;
    _conditionController.text = draft.condition;
    _tagsController.text = draft.tags.join(', ');
    _startPriceController.text = draft.startPrice?.toString() ?? '';
    _buyNowPriceController.text = draft.buyNowPrice?.toString() ?? '';
    _suppressDirtyTracking = false;

    setState(() {
      _itemId = draft.id;
      _categoryMain = draft.categoryMain;
      _appraisalRequested = draft.appraisalRequested;
      _durationDays = draft.durationDays;
      _existingImageUrls = draft.imageUrls;
      _existingAuthImageUrls = draft.authImageUrls;
      _newImageFiles = <XFile>[];
      _newAuthImageFiles = <XFile>[];
      _hasUnsavedChanges = false;
      _lastSavedAt = draft.updatedAt;
      _validationState = const SellValidationState.empty();
    });
  }

  Future<void> _saveDraft() async {
    final validationState = _buildValidationState(SellValidationMode.draft);
    if (validationState.hasErrors) {
      setState(() {
        _validationState = validationState;
      });
      return;
    }

    setState(() {
      _isSavingDraft = true;
      _validationState = const SellValidationState.empty();
    });

    try {
      final savedDraft = await ref
          .read(sellFlowServiceProvider)
          .saveDraft(
            _buildFormData(),
            newImageFiles: _newImageFiles,
            newAuthImageFiles: _newAuthImageFiles,
          );
      if (!mounted) {
        return;
      }

      setState(() {
        _itemId = savedDraft.itemId;
        _existingImageUrls = savedDraft.imageUrls;
        _existingAuthImageUrls = savedDraft.authImageUrls;
        _newImageFiles = <XFile>[];
        _newAuthImageFiles = <XFile>[];
        _hasUnsavedChanges = false;
        _lastSavedAt = DateTime.now();
        _validationState = const SellValidationState.empty();
      });

      context.showSnackBarMessage(context.l10n.sellActionSaved);
    } on FirebaseFunctionsException catch (error) {
      if (!mounted) {
        return;
      }
      context.showErrorSnackBar(error.message ?? context.l10n.sellActionFailed);
    } catch (error, stackTrace) {
      if (!mounted) {
        return;
      }
      ref
          .read(appLoggerProvider)
          .error(
            'Draft save failed: $error',
            domain: AppLogDomain.sell,
            source: 'sell_screen:save_draft',
            error: error,
            stackTrace: stackTrace,
          );
      context.showErrorSnackBar(context.l10n.sellActionFailed);
    } finally {
      if (mounted) {
        setState(() {
          _isSavingDraft = false;
        });
      }
    }
  }

  Future<void> _publish() async {
    final validationState = _buildValidationState(SellValidationMode.publish);
    if (validationState.hasErrors) {
      setState(() {
        _validationState = validationState;
      });
      return;
    }

    setState(() {
      _isPublishing = true;
      _validationState = const SellValidationState.empty();
    });

    try {
      final auctionId = await ref
          .read(sellFlowServiceProvider)
          .publishAuction(
            _buildFormData(),
            newImageFiles: _newImageFiles,
            newAuthImageFiles: _newAuthImageFiles,
          );
      if (!mounted) {
        return;
      }

      context.showSnackBarMessage(context.l10n.sellActionPublished);
      context.go('/auction/$auctionId');
    } on FirebaseFunctionsException catch (error) {
      if (!mounted) {
        return;
      }
      context.showErrorSnackBar(error.message ?? context.l10n.sellActionFailed);
    } catch (error, stackTrace) {
      if (!mounted) {
        return;
      }
      ref
          .read(appLoggerProvider)
          .error(
            'Publish failed: $error',
            domain: AppLogDomain.sell,
            source: 'sell_screen:publish',
            error: error,
            stackTrace: stackTrace,
          );
      context.showErrorSnackBar(context.l10n.sellActionFailed);
    } finally {
      if (mounted) {
        setState(() {
          _isPublishing = false;
        });
      }
    }
  }

  SellDraftFormData _buildFormData() {
    final buyNowPriceText = _buyNowPriceController.text.trim();

    return SellDraftFormData(
      itemId: _itemId,
      categoryMain: _categoryMain,
      categorySub: _categorySubController.text.trim(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      condition: _conditionController.text.trim(),
      tags: _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList(),
      existingImageUrls: _existingImageUrls,
      existingAuthImageUrls: _existingAuthImageUrls,
      appraisalRequested: _appraisalRequested,
      startPrice: int.tryParse(_startPriceController.text.trim()),
      buyNowPrice: buyNowPriceText.isEmpty
          ? null
          : int.tryParse(buyNowPriceText),
      durationDays: _durationDays,
    );
  }

  List<TextEditingController> get _formControllers => [
    _categorySubController,
    _titleController,
    _descriptionController,
    _conditionController,
    _tagsController,
    _startPriceController,
    _buyNowPriceController,
  ];

  void _handleFormChanged() {
    if (_suppressDirtyTracking || !mounted) {
      return;
    }

    setState(() {
      _hasUnsavedChanges = true;
      _syncValidationState();
    });
  }

  void _syncValidationState() {
    if (_validationState.mode == SellValidationMode.none) {
      return;
    }
    _validationState = _buildValidationState(_validationState.mode);
  }

  SellValidationState _buildValidationState(SellValidationMode mode) {
    if (mode == SellValidationMode.none) {
      return const SellValidationState.empty();
    }

    final errors = <SellValidationField, String>{};

    if (_categorySubController.text.trim().isEmpty) {
      errors[SellValidationField.categorySub] = _categorySubValidationMessage(
        mode,
      );
    }
    if (_titleController.text.trim().isEmpty) {
      errors[SellValidationField.title] = _titleValidationMessage(mode);
    }
    if (_conditionController.text.trim().isEmpty) {
      errors[SellValidationField.condition] = _conditionValidationMessage(mode);
    }
    if (_descriptionController.text.trim().isEmpty) {
      errors[SellValidationField.description] = _descriptionValidationMessage(
        mode,
      );
    }
    if (_categoryMain == 'GOODS' &&
        _existingAuthImageUrls.isEmpty &&
        _newAuthImageFiles.isEmpty) {
      errors[SellValidationField.authImages] = _authImagesValidationMessage(
        mode,
      );
    }

    if (mode == SellValidationMode.publish) {
      if (_existingImageUrls.isEmpty && _newImageFiles.isEmpty) {
        errors[SellValidationField.galleryImages] =
            context.l10n.sellValidationImages;
      }

      final startPrice = int.tryParse(_startPriceController.text.trim());
      final buyNowPriceText = _buyNowPriceController.text.trim();
      final buyNowPrice = buyNowPriceText.isEmpty
          ? null
          : int.tryParse(buyNowPriceText);

      if (startPrice == null || startPrice <= 0) {
        errors[SellValidationField.startPrice] =
            context.l10n.sellValidationStartPrice;
      }
      if (buyNowPriceText.isNotEmpty && buyNowPrice == null) {
        errors[SellValidationField.buyNowPrice] =
            context.l10n.sellValidationBuyNowPriceInvalid;
      } else if (startPrice != null &&
          buyNowPrice != null &&
          buyNowPrice <= startPrice) {
        errors[SellValidationField.buyNowPrice] =
            context.l10n.sellValidationBuyNowPrice;
      }
    }

    return SellValidationState(
      mode: mode,
      fieldErrors: errors,
      summaryErrors: errors.values.toList(growable: false),
    );
  }

  bool get _categoryReady => _categorySubController.text.trim().isNotEmpty;

  bool get _detailsReady =>
      _titleController.text.trim().isNotEmpty &&
      _conditionController.text.trim().isNotEmpty &&
      _descriptionController.text.trim().isNotEmpty;

  bool get _pricingReady {
    final startPrice = int.tryParse(_startPriceController.text.trim());
    final buyNowPriceText = _buyNowPriceController.text.trim();
    final buyNowPrice = buyNowPriceText.isEmpty
        ? null
        : int.tryParse(buyNowPriceText);

    return startPrice != null &&
        startPrice > 0 &&
        (buyNowPriceText.isEmpty || buyNowPrice != null) &&
        (buyNowPrice == null || buyNowPrice > startPrice);
  }

  bool get _imagesReady {
    final hasGallery =
        _existingImageUrls.isNotEmpty || _newImageFiles.isNotEmpty;
    final hasRequiredAuth =
        _categoryMain != 'GOODS' ||
        _existingAuthImageUrls.isNotEmpty ||
        _newAuthImageFiles.isNotEmpty;

    return hasGallery && hasRequiredAuth;
  }

  bool get _publishReady =>
      _categoryReady && _detailsReady && _pricingReady && _imagesReady;

  String _categorySubValidationMessage(SellValidationMode mode) {
    return switch (mode) {
      SellValidationMode.publish =>
        context.l10n.sellValidationCategorySubPublish,
      _ => context.l10n.sellValidationCategorySub,
    };
  }

  String _titleValidationMessage(SellValidationMode mode) {
    return switch (mode) {
      SellValidationMode.publish => context.l10n.sellValidationTitlePublish,
      _ => context.l10n.sellValidationTitle,
    };
  }

  String _conditionValidationMessage(SellValidationMode mode) {
    return switch (mode) {
      SellValidationMode.publish => context.l10n.sellValidationConditionPublish,
      _ => context.l10n.sellValidationCondition,
    };
  }

  String _descriptionValidationMessage(SellValidationMode mode) {
    return switch (mode) {
      SellValidationMode.publish =>
        context.l10n.sellValidationDescriptionPublish,
      _ => context.l10n.sellValidationDescription,
    };
  }

  String _authImagesValidationMessage(SellValidationMode mode) {
    return switch (mode) {
      SellValidationMode.publish =>
        context.l10n.sellValidationAuthImagesPublish,
      _ => context.l10n.sellValidationAuthImages,
    };
  }
}
