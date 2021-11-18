//This file is used for utility functions and class extensions.
//Multiple extensions were in this file at point, but were discarded
//when left unused.

///An extension on String to capitalize itself (the first letter)
extension StringExt on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
