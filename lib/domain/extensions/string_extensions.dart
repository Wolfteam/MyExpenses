extension StringNullExtension on String? {
  /// Returns true if string is:
  /// - null
  /// - empty
  /// - whitespace string.
  ///
  /// Characters considered "whitespace" are listed [here](https://stackoverflow.com/a/59826129/10830091).
  bool get isNullEmptyOrWhitespace => this == null || this!.isEmpty || this!.trim().isEmpty;

  bool isNullOrEmpty({int minLength = 0, int maxLength = 255}) =>
      this == null || this!.trim().isEmpty || this!.length > maxLength || this!.length < minLength;
}
