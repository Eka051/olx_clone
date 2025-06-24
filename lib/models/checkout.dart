import 'dart:convert';

String checkoutRequestToJson(CheckoutRequest data) => json.encode(data.toJson());

class CheckoutRequest {
    final List<CheckoutItem> items;
    final int totalAmount;

    CheckoutRequest({
        required this.items,
        required this.totalAmount,
    });

    Map<String, dynamic> toJson() => {
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
        "totalAmount": totalAmount,
    };
}

class CheckoutItem {
    final int adPackageId;
    final int productId;
    final int quantity;

    CheckoutItem({
        required this.adPackageId,
        required this.productId,
        required this.quantity,
    });

    Map<String, dynamic> toJson() => {
        "adPackageId": adPackageId,
        "productId": productId,
        "quantity": quantity,
    };
}
