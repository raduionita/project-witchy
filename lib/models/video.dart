import 'package:freezed_annotation/freezed_annotation.dart';

part 'video.freezed.dart';
part 'video.g.dart';

/// A curated educational video shown in the Content Library.
@freezed
abstract class Video with _$Video {
  const factory Video({
    required String id,
    required String title,
    required String category,
    required String url,
    String? description,
    DateTime? publishedAt,
  }) = _Video;

  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);
}