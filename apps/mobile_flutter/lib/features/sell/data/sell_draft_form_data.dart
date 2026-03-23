class SellDraftFormData {
  const SellDraftFormData({
    this.itemId,
    required this.categoryMain,
    required this.categorySub,
    required this.title,
    required this.description,
    required this.condition,
    required this.tags,
    required this.existingImageUrls,
    required this.existingAuthImageUrls,
    required this.appraisalRequested,
    required this.startPrice,
    required this.buyNowPrice,
    required this.durationDays,
  });

  final String? itemId;
  final String categoryMain;
  final String categorySub;
  final String title;
  final String description;
  final String condition;
  final List<String> tags;
  final List<String> existingImageUrls;
  final List<String> existingAuthImageUrls;
  final bool appraisalRequested;
  final int? startPrice;
  final int? buyNowPrice;
  final int durationDays;
}
