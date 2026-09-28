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

class ItemKeranjang {
  final String id;
  final ProdukItem product;
  final String variant;
  final String materialBadge;
  int quantity;
  bool isSelected;

  ItemKeranjang({
    required this.id,
    required this.product,
    required this.variant,
    required this.materialBadge,
    this.quantity = 1,
    this.isSelected = true,
  });
}

class ProdukData {
  ProdukData._();

  static const List<ProdukItem> listProduk = [
    ProdukItem(
      id: 'prod-1',
      title: 'Pot Bunga dari Botol Plastik Daur Ulang',
      price: 35000,
      originalPrice: 45000,
      discount: '22% OFF',
      image: 'assets/images/produk_pot_bunga.jpg',
      badge: 'Best Seller',
      materialTag: '250g plastik',
      rating: 4.8,
      reviewCount: 320,
      soldCount: '1.2k+',
      category: 'Dekorasi Rumah',
      plasticSaved: '250g',
      carbonReduction: '-420g',
      merchantName: 'Karya Mandiri Eco Cr...',
      merchantLocation: 'Bandung, Jawa Barat',
      material: '100% Recycled PET Plastic & Natural Mineral Powder',
      dimensions: 'Diameter 12 cm, Tinggi 14 cm',
      mainFeature: 'Lubang drainase terintegrasi, tahan cuaca outdoor',
      description:
          'Pot tanaman premium bergaya minimalis kontemporer. Dibuat secara presisi dari lelehan botol plastik bekas yang dipadukan dengan bubuk mineral alami untuk menghasilkan tekstur matte sentuhan marmer sage green yang tahan banting, awet, dan ramah lingkungan.',
    ),
    ProdukItem(
      id: 'prod-2',
      title: 'Lampu Hias dari Limbah Botol',
      price: 78000,
      originalPrice: 95000,
      discount: '18% OFF',
      image: 'assets/images/produk_lampu_botol.jpg',
      badge: 'Eco Friendly',
      materialTag: 'Low Waste',
      rating: 4.9,
      reviewCount: 412,
      soldCount: '850+',
      category: 'Dekorasi Rumah',
      plasticSaved: '320g',
      carbonReduction: '-650g',
      merchantName: 'Karya Mandiri Eco Cr...',
      merchantLocation: 'Bandung, Jawa Barat',
      material: 'Upcycled Glass Bottle & Solid Oak Wood Base',
      dimensions: 'Diameter 10 cm, Tinggi 28 cm',
      mainFeature: 'Warm LED Edison Bulb, hemat energi & kabel vintage',
      description:
          'Lampu meja hias unik bernuansa industrial vintage yang diproduksi dari daur ulang botol kaca minuman tebal berkualitas tinggi. Dilengkapi dudukan kayu jati belanda rekondisi.',
    ),
    ProdukItem(
      id: 'prod-3',
      title: 'Tas Tote dari Karung Bekas',
      price: 55000,
      originalPrice: 70000,
      discount: '21% OFF',
      image: 'assets/images/produk_tas_karung.jpg',
      badge: 'Upcycle',
      materialTag: '180g karung',
      rating: 4.7,
      reviewCount: 258,
      soldCount: '430+',
      category: 'Fashion Upcycle',
      plasticSaved: '180g',
      carbonReduction: '-310g',
      merchantName: 'Re-Craft Studio',
      merchantLocation: 'Yogyakarta',
      material: 'Vintage Burlap Coffee Sack & Heavyweight Cotton Canvas',
      dimensions: 'Panjang 38 cm, Lebar 10 cm, Tinggi 42 cm',
      mainFeature: 'Tali katun kanvas kuat, jahitan ganda tahan beban 12 kg',
      description:
          'Tas tote bag fungsional dengan estetika rustic otentik yang dijahit dari karung kopi goni pilihan. Dicuci bersih dan disterilkan secara ramah lingkungan sebelum diproduksi.',
    ),
    ProdukItem(
      id: 'prod-4',
      title: 'Tempat Pensil dari Kardus Bekas',
      price: 22500,
      originalPrice: 30000,
      discount: '25% OFF',
      image: 'assets/images/produk_tempat_pensil.jpg',
      badge: 'Produk Lokal',
      materialTag: '100% Kardus',
      rating: 4.6,
      reviewCount: 189,
      soldCount: '620+',
      category: 'Aksesoris',
      plasticSaved: '160g',
      carbonReduction: '-280g',
      merchantName: 'Karya Mandiri Eco Cr...',
      merchantLocation: 'Bandung, Jawa Barat',
      material: 'Multi-layer Recycled Kraft Cardboard dengan coating tahan air',
      dimensions: '18 cm x 12 cm x 10 cm',
      mainFeature: 'Desain geometris modular dengan 4 sekat fungsional',
      description:
          'Organizer meja dan tempat alat tulis serbaguna dengan desain geometris elegan. Dibuat dari potongan kardus kemasan berdensitas tinggi yang dilapisi lilin lebah alami agar tahan percikan air.',
    ),
  ];

  static List<ItemKeranjang> getInitialCart() {
    return [
      ItemKeranjang(
        id: 'cart-1',
        product: listProduk[0],
        variant: 'Pot Bunga Daur Ulang - Sage Green',
        materialBadge: 'Plastik HDPE No.2',
        quantity: 1,
        isSelected: true,
      ),
      ItemKeranjang(
        id: 'cart-2',
        product: listProduk[3],
        variant: 'Tempat Pensil Geometris',
        materialBadge: 'Kardus Daur Ulang',
        quantity: 2,
        isSelected: true,
      ),
      ItemKeranjang(
        id: 'cart-3',
        product: listProduk[2],
        variant: 'Tas Tote Canvas Karung Vintage',
        materialBadge: 'Upcycled Burlap',
        quantity: 1,
        isSelected: true,
      ),
    ];
  }
}
