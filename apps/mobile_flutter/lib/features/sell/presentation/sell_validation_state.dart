enum SellValidationMode { none, draft, publish }

enum SellValidationField {
  categorySub,
  title,
  condition,
  description,
  startPrice,
  buyNowPrice,
  galleryImages,
  authImages,
}

class SellValidationState {
  const SellValidationState({
    required this.mode,
    required this.fieldErrors,
    required this.summaryErrors,
  });

  const SellValidationState.empty()
    : mode = SellValidationMode.none,
      fieldErrors = const <SellValidationField, String>{},
      summaryErrors = const <String>[];

  final SellValidationMode mode;
  final Map<SellValidationField, String> fieldErrors;
  final List<String> summaryErrors;

  bool get hasErrors => fieldErrors.isNotEmpty;

  String? errorFor(SellValidationField field) => fieldErrors[field];
}
