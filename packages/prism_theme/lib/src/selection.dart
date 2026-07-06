import 'brightness.dart';

/// The persisted unit of theming — tiny, re-auditable, forward-safe.
///
/// Sources live in code (keyed by [sourceId]); persistence stores only the
/// *selection*, never the compiled scheme. A `ThemeService` recompiles the pair
/// at boot from the referenced source and resolves it for [brightness].
class PrismThemeSelection {
  /// The JSON schema version.
  static const int version = 1;

  /// Identifies the authored source in the in-code registry.
  final String sourceId;

  /// The chosen brightness (persisted as a discrete light/dark choice).
  final PrismBrightness brightness;

  const PrismThemeSelection({required this.sourceId, required this.brightness});

  Map<String, dynamic> toJson() => {
    'v': version,
    'sourceId': sourceId,
    'brightness': brightness.name,
  };

  /// Parses a selection; throws [FormatException] on an unsupported version or a
  /// missing/malformed `sourceId`/`brightness`. Unknown keys are ignored
  /// (forward-safe).
  factory PrismThemeSelection.fromJson(Map<String, dynamic> json) {
    if (json['v'] != version) {
      throw FormatException(
        'Unsupported PrismThemeSelection version: ${json['v']}',
      );
    }
    final sourceId = json['sourceId'];
    final brightness = json['brightness'];
    if (sourceId is! String || brightness is! String) {
      throw FormatException('Malformed PrismThemeSelection: $json');
    }
    return PrismThemeSelection(
      sourceId: sourceId,
      brightness: PrismBrightness.fromName(brightness),
    );
  }

  PrismThemeSelection copyWith({
    String? sourceId,
    PrismBrightness? brightness,
  }) => PrismThemeSelection(
    sourceId: sourceId ?? this.sourceId,
    brightness: brightness ?? this.brightness,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrismThemeSelection &&
          sourceId == other.sourceId &&
          brightness == other.brightness;

  @override
  int get hashCode => Object.hash(sourceId, brightness);

  @override
  String toString() => 'PrismThemeSelection($sourceId, $brightness)';
}
