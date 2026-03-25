import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/extensions/build_context_x.dart';
import '../../../core/firebase/firebase_providers.dart';
import '../../../core/l10n/app_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_editorial_hero.dart';
import '../../../core/widgets/app_loading_overlay.dart';
import '../../../core/widgets/app_page_scaffold.dart';
import '../../../core/widgets/app_status_badge.dart';
import '../application/sell_flow_service.dart';
import '../data/sell_draft_form_data.dart';
import '../data/sell_draft_summary.dart';
import 'widgets/sell_action_panel.dart';
import 'widgets/sell_category_panel.dart';
import 'widgets/sell_details_panel.dart';
import 'widgets/sell_image_picker_panel.dart';
import 'widgets/sell_policy_panel.dart';
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
  final _imagePicker = ImagePicker();

  String? _itemId;
  String _categoryMain = 'GOODS';
  int _durationDays = 3;
  bool _appraisalRequested = false;
  bool _isSavingDraft = false;
  bool _isPublishing = false;
  List<String> _existingImageUrls = <String>[];
  List<String> _existingAuthImageUrls = <String>[];
  List<XFile> _newImageFiles = <XFile>[];
  List<XFile> _newAuthImageFiles = <XFile>[];

  @override
  void dispose() {
    _categorySubController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _conditionController.dispose();
    _tagsController.dispose();
    _startPriceController.dispose();
    _buyNowPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final userId = ref.watch(firebaseAuthProvider).currentUser?.uid;

    return AppPageScaffold(
      title: context.l10n.sellTitle,
      body: AppLoadingOverlay(
        isLoading: _isSavingDraft || _isPublishing,
        message: _isPublishing
            ? context.l10n.sellPublishing
            : context.l10n.sellSavingDraft,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            tokens.screenPadding,
            tokens.space4,
            tokens.screenPadding,
            tokens.space8,
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
            SellRecentDraftsSection(
              userId: userId,
              onSelectDraft: _applyDraft,
            ),
            SizedBox(height: tokens.space6),
            SellCategoryPanel(
              categoryMain: _categoryMain,
              categorySubController: _categorySubController,
              onCategoryMainChanged: (value) {
                setState(() {
                  _categoryMain = value;
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
              onAppraisalChanged: (value) {
                setState(() {
                  _appraisalRequested = value;
                });
              },
            ),
            SizedBox(height: tokens.space4),
            SellPricingPanel(
              startPriceController: _startPriceController,
              buyNowPriceController: _buyNowPriceController,
              durationDays: _durationDays,
              onDurationChanged: (value) {
                setState(() {
                  _durationDays = value;
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
            ),
            SizedBox(height: tokens.space4),
            SellImagePickerPanel(
              title: context.l10n.sellImageAuthTitle,
              description: context.l10n.sellImageAuthDescription,
              buttonLabel: context.l10n.sellImageAuthAction,
              existingUrls: _existingAuthImageUrls,
              newFiles: _newAuthImageFiles,
              onPickPressed: _pickAuthImages,
            ),
            SizedBox(height: tokens.space6),
            SellActionPanel(
              itemId: _itemId,
              isSavingDraft: _isSavingDraft,
              isPublishing: _isPublishing,
              onSaveDraft: _saveDraft,
              onPublish: _publish,
            ),
          ],
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
    });
  }

  Future<void> _pickAuthImages() async {
    final picked = await _imagePicker.pickMultiImage();
    if (picked.isEmpty) {
      return;
    }

    setState(() {
      _newAuthImageFiles = [..._newAuthImageFiles, ...picked].toList();
    });
  }

  void _applyDraft(SellDraftSummary draft) {
    setState(() {
      _itemId = draft.id;
      _categoryMain = draft.categoryMain;
      _categorySubController.text = draft.categorySub;
      _titleController.text = draft.title;
      _descriptionController.text = draft.description;
      _conditionController.text = draft.condition;
      _tagsController.text = draft.tags.join(', ');
      _appraisalRequested = draft.appraisalRequested;
      _startPriceController.text = draft.startPrice?.toString() ?? '';
      _buyNowPriceController.text = draft.buyNowPrice?.toString() ?? '';
      _durationDays = draft.durationDays;
      _existingImageUrls = draft.imageUrls;
      _existingAuthImageUrls = draft.authImageUrls;
      _newImageFiles = <XFile>[];
      _newAuthImageFiles = <XFile>[];
    });
  }

  Future<void> _saveDraft() async {
    final validationError = _validateForDraft();
    if (validationError != null) {
      context.showErrorSnackBar(validationError);
      return;
    }

    setState(() {
      _isSavingDraft = true;
    });

    try {
      final savedDraft = await ref.read(sellFlowServiceProvider).saveDraft(
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
      if (kDebugMode) {
        debugPrint('Draft save failed: $error\n$stackTrace');
      }
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
    final validationError = _validateForPublish();
    if (validationError != null) {
      context.showErrorSnackBar(validationError);
      return;
    }

    setState(() {
      _isPublishing = true;
    });

    try {
      final auctionId = await ref.read(sellFlowServiceProvider).publishAuction(
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
      if (kDebugMode) {
        debugPrint('Publish failed: $error\n$stackTrace');
      }
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
      buyNowPrice: _buyNowPriceController.text.trim().isEmpty
          ? null
          : int.tryParse(_buyNowPriceController.text.trim()),
      durationDays: _durationDays,
    );
  }

  String? _validateForDraft() {
    if (_categorySubController.text.trim().isEmpty) {
      return context.l10n.sellValidationCategorySub;
    }
    if (_titleController.text.trim().isEmpty) {
      return context.l10n.sellValidationTitle;
    }
    if (_conditionController.text.trim().isEmpty) {
      return context.l10n.sellValidationCondition;
    }
    if (_descriptionController.text.trim().isEmpty) {
      return context.l10n.sellValidationDescription;
    }
    if (_categoryMain == 'GOODS' &&
        _existingAuthImageUrls.isEmpty &&
        _newAuthImageFiles.isEmpty) {
      return context.l10n.sellValidationAuthImages;
    }

    return null;
  }

  String? _validateForPublish() {
    final draftError = _validateForDraft();
    if (draftError != null) {
      return draftError;
    }
    if (_existingImageUrls.isEmpty && _newImageFiles.isEmpty) {
      return context.l10n.sellValidationImages;
    }

    final startPrice = int.tryParse(_startPriceController.text.trim());
    final buyNowPrice = _buyNowPriceController.text.trim().isEmpty
        ? null
        : int.tryParse(_buyNowPriceController.text.trim());

    if (startPrice == null || startPrice <= 0) {
      return context.l10n.sellValidationStartPrice;
    }
    if (buyNowPrice != null && buyNowPrice <= startPrice) {
      return context.l10n.sellValidationBuyNowPrice;
    }

    return null;
  }
}
