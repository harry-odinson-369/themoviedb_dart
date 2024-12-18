extension ListExtension<T> on List<T> {

  bool matchAll(bool Function(T e) predict) {
    for (var el in this) {
      if (!predict(el)) {
        return false;
      }
    }

    return true;
  }

  T? firstWhereOrNull(bool Function(T e) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }

}