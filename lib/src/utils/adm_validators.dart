/// A collection of reusable field validators compatible with [TextFormField]
/// and [AdmInput].
///
/// Each method returns `null` when the value is valid, or a localised error
/// string (Portuguese) when it is not.
///
/// ### Compose validators
/// Chain multiple validators with [combine]:
/// ```dart
/// AdmInput(
///   validator: AdmValidators.combine([
///     AdmValidators.notEmpty,
///     AdmValidators.email,
///   ]),
/// )
/// ```
sealed class AdmValidators {
  /// Field must not be null or blank.
  static String? notEmpty<T>(T? value, {String? msg}) {
    if (value == null || value.toString().trim().isEmpty) {
      return msg ?? 'Campo obrigatório';
    }
    return null;
  }

  /// Field must not contain spaces.
  static String? noSpace<T>(T? value, {String? msg}) {
    if (value == null || value.toString().trim().isEmpty) return null;
    if (value.toString().contains(' ')) {
      return msg ?? 'Campo não deve conter espaço';
    }
    return null;
  }

  /// Portuguese NIF — exactly 9 digits.
  static String? nif(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.length != 9) return 'NIF deve conter 9 dígitos';
    return null;
  }

  /// Valid e-mail address format.
  static String? email(String? value, {String? msg}) {
    if (value == null || value.trim().isEmpty) return null;
    if (!RegExp(
      r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$',
    ).hasMatch(value)) {
      return msg ?? 'Email inválido';
    }
    return null;
  }

  /// Letters, digits, spaces, hyphens and plus signs only.
  static String? name(String? value, {String? msg}) {
    if (value == null || value.trim().isEmpty) return null;
    if (!RegExp(r'^[\p{L}0-9\s\-\+]+$', unicode: true).hasMatch(value)) {
      return msg ?? 'Nome inválido';
    }
    return null;
  }

  /// Password must be non-empty and at least 8 characters.
  static String? password(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Palavra-passe obrigatório';
    }
    if (value.length < 8) {
      return 'Palavra-passe deve conter pelo menos 8 caracteres';
    }
    return null;
  }

  /// Value must be exactly [length] characters.
  static String? length(String? value, int length, {String? msg}) {
    if ((value?.length ?? 0) != length) {
      return msg ?? 'Campo deve ter $length caracteres';
    }
    return null;
  }

  /// Value length must be within [[min], [max]] (both optional).
  static String? lengthRange(
    String? value, {
    int? min,
    int? max,
    String? msg,
  }) {
    if (value == null || value.isEmpty) return null;
    final len = value.length;
    if (min != null && len < min) {
      return msg ?? 'Campo deve ter no mínimo $min caracteres';
    }
    if (max != null && len > max) {
      return msg ?? 'Campo deve ter no máximo $max caracteres';
    }
    return null;
  }

  /// Numeric value must be within [[min], [max]] (both optional).
  static String? range(
    String? value, {
    num? min,
    num? max,
    String? msg,
  }) {
    if (value == null || value.isEmpty) return null;
    final n = num.tryParse(value);
    if (n == null) return msg ?? 'Valor inválido';
    if (min != null && n < min) return msg ?? 'Valor tem que ser no mínimo $min';
    if (max != null && n > max) return msg ?? 'Valor tem que ser no máximo $max';
    return null;
  }

  // ── Conditional helpers ───────────────────────────────────────────────────

  /// Returns [error] only when [condition] is `true`.
  static String? validateIf(bool condition, String? error) =>
      condition ? error : null;

  /// Returns [error] only when [value] is non-null and non-blank.
  static String? validateIfNotNull<T>(T? value, String? error) {
    if (value == null || value.toString().trim().isEmpty) return null;
    return error;
  }

  /// Returns [error] only when [value] is null or blank.
  static String? validateIfNull<T>(T? value, String? error) {
    if (value == null || value.toString().trim().isEmpty) return error;
    return null;
  }

  // ── Composition ───────────────────────────────────────────────────────────

  /// Runs [validators] in order and returns the first non-null error.
  ///
  /// ```dart
  /// validator: AdmValidators.combine([
  ///   AdmValidators.notEmpty,
  ///   (v) => AdmValidators.lengthRange(v, min: 3, max: 50),
  ///   AdmValidators.email,
  /// ]),
  /// ```
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final v in validators) {
        final error = v(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
