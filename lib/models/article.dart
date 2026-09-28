import 'package:flutter/material.dart';

class Article {
  final String id;
  final String category;
  final String readTime;
  final String title;
  final String excerpt;
  final List<Color> thumb;
  const Article({required this.id, required this.category, required this.readTime, required this.title, required this.excerpt, required this.thumb});
}
