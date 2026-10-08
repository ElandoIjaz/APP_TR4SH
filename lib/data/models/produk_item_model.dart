class ProdukItem {
  final String id;
  final String title;
  final int price;
  final int originalPrice;
  final String discount;
  final String image;
  final String badge;
  final String materialTag;
  final double rating;
  final int reviewCount;
  final String soldCount;
  final String category;
  final String plasticSaved;
  final String carbonReduction;
  final String merchantName;
  final String merchantLocation;
  final String material;
  final String dimensions;
  final String mainFeature;
  final String description;

  const ProdukItem({
    required this.id,
    required this.title,
    required this.price,
    required this.originalPrice,
    required this.discount,
    required this.image,
    required this.badge,
    required this.materialTag,
    required this.rating,
    required this.reviewCount,
    required this.soldCount,
    required this.category,
    required this.plasticSaved,
    required this.carbonReduction,
    required this.merchantName,
    required this.merchantLocation,
    required this.material,
    required this.dimensions,
    required this.mainFeature,
    required this.description,
  });
}
