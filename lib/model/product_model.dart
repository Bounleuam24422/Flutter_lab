import 'dart:convert';

class ProductResponse {
  final String message;
  final List<ProductData> products;

  ProductResponse({
    required this.message,
    required this.products,
  });

  factory ProductResponse.fromJson(String source) =>
      ProductResponse.fromMap(json.decode(source));

  String toJson() => json.encode(toMap());

  factory ProductResponse.fromMap(Map<String, dynamic> json) => ProductResponse(
        message: json["message"],
        products: List<ProductData>.from(
            json["products"].map((x) => ProductData.fromMap(x))),
      );

  Map<String, dynamic> toMap() => {
        "message": message,
        "products": List<dynamic>.from(products.map((x) => x.toMap())),
      };
}

class ProductData {
  final String id;
  final String productName;
  final int quantity;
  final int salePrice;
  final int importPrice;
  final int level;
  final int price;
  final UnitData? unit;
  final CategoryData? category;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductData({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.salePrice,
    required this.importPrice,
    required this.level,
    required this.price,
    this.unit,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductData.fromMap(Map<String, dynamic> json) => ProductData(
        id: json["_id"],
        productName: json["productName"],
        quantity: json["quatity"], // Fix incorrect spelling in JSON
        salePrice: json["sale_price"],
        importPrice: json["imprice"],
        level: json["level"],
        price: json["price"],
        unit: json["unitID"] != null ? UnitData.fromMap(json["unitID"]) : null,
        category: json["cateID"] != null
            ? CategoryData.fromMap(json["cateID"])
            : null,
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toMap() => {
        "_id": id,
        "productName": productName,
        "quatity": quantity, // Keep spelling consistent with API response
        "sale_price": salePrice,
        "imprice": importPrice,
        "level": level,
        "price": price,
        "unitID": unit?.toMap(),
        "cateID": category?.toMap(),
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
      };
}

class UnitData {
  final String id;
  final String unitName;

  UnitData({
    required this.id,
    required this.unitName,
  });

  factory UnitData.fromMap(Map<String, dynamic> json) => UnitData(
        id: json["_id"],
        unitName: json["unitName"],
      );

  Map<String, dynamic> toMap() => {
        "_id": id,
        "unitName": unitName,
      };
}

class CategoryData {
  final String id;
  final String categoryName;

  CategoryData({
    required this.id,
    required this.categoryName,
  });

  factory CategoryData.fromMap(Map<String, dynamic> json) => CategoryData(
        id: json["_id"],
        categoryName: json["cateName"],
      );

  Map<String, dynamic> toMap() => {
        "_id": id,
        "cateName": categoryName,
      };
}
