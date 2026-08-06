import 'package:freezed_annotation/freezed_annotation.dart';

part 'couple_link.freezed.dart';
part 'couple_link.g.dart';

/// Local placeholder for a couples-mode link.
///
/// **Design note (real backend deferred):** a future backend will pair two
/// devices by exchange of a share code; until then this link is generated and
/// stored **on-device only**. Nothing is transmitted, no third-party services
/// are involved, and no partner data leaves the device.
@freezed
abstract class CoupleLink with _$CoupleLink {
  const factory CoupleLink({
    required String code,
    required DateTime createdAt,
    String? partnerDisplayName,
    @Default(false) bool connected,
  }) = _CoupleLink;

  factory CoupleLink.fromJson(Map<String, dynamic> json) =>
      _$CoupleLinkFromJson(json);
}

/// Formats a raw uuid-derived token into a short, human-shareable code,
/// e.g. `AB12-CD34-EF56`. Pure and deterministic for testability.
String formatCoupleCode(String token) {
  final String upper = token.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  final String body = upper.padRight(12, '0').substring(0, 12);
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < body.length; i += 4) {
    if (i > 0) buffer.write('-');
    buffer.write(body.substring(i, i + 4));
  }
  return buffer.toString();
}
