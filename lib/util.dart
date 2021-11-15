extension IterableExt<T> on Iterable<T> {
  Iterable<T> intersperse(T item) sync* {
    if (iterator.moveNext()) {
      yield iterator.current;
      while (iterator.moveNext()) {
        yield item;
        yield iterator.current;
      }
    }
  }

  Iterable<T> prepend(T item) sync* {
    yield item;
    while (iterator.moveNext()) {
      yield iterator.current;
    }
  }
}

extension StringExt on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
