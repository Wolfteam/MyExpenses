extension StringNullExtension on String? {
  bool get isNullEmptyOrWhitespace => this == null || this!.isEmpty || this!.trim().isEmpty;

  bool get isNotNullEmptyOrWhitespace => !isNullEmptyOrWhitespace;

  bool isNullOrEmpty({int minLength = 0, int maxLength = 255}) =>
      this == null || this!.trim().isEmpty || this!.length > maxLength || this!.length < minLength;

  String toCapitalized() => this == null
      ? ''
      : this!.isNotEmpty
          ? '${this![0].toUpperCase()}${this!.substring(1).toLowerCase()}'
          : '';
}
