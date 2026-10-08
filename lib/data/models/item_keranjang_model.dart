import 'produk_item_model.dart';

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
