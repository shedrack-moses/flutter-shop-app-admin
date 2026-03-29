String calculateDiscount({required int oldPrice, required int newPrice}) {
  if (oldPrice <= 0) {
    return '0';
  }
  var discount = ((oldPrice - newPrice) / oldPrice) * 100;
  return discount.toString();
}
