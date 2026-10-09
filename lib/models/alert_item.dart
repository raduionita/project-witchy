import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'alert_type.dart';

class AlertItem {
  final String id;
  final AlertType type;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime eventDate;
  final bool read;

  const AlertItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.eventDate,
    this.read = false,
  });

  FaIconData get icon => type.icon;
  Color get badgeBg => type.badgeBg;
  Color get badgeFg => type.badgeFg;

  AlertItem copyWith({bool? read}) => AlertItem(
    id: id,
    type: type,
    title: title,
    body: body,
    createdAt: createdAt,
    eventDate: eventDate,
    read: read ?? this.read,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.toJson(),
    'title': title,
    'body': body,
    'createdAt': createdAt.toIso8601String(),
    'eventDate': eventDate.toIso8601String(),
    'read': read,
  };

  factory AlertItem.fromJson(Map<String, dynamic> json) => AlertItem(
    id: json['id'] as String,
    type: AlertTypePresentation.fromJson(json['type']),
    title: json['title'] as String? ?? '',
    body: json['body'] as String? ?? '',
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime(2000),
    eventDate: DateTime.tryParse(json['eventDate'] as String? ?? '') ?? DateTime(2000),
    read: json['read'] as bool? ?? false,
  );
}
