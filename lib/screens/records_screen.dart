import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/stat_card.dart';
import '../widgets/trend_bars.dart';
import '../widgets/app_card.dart';
import '../widgets/app_tag.dart';

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      children: [
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/chart'),
          child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Cycle Trends', style: AppText.secIn), const SizedBox(height: 10), const TrendBars()])),
        ),
        const SizedBox(height: 12),
        const Row(
          children: [Expanded(child: StatCard(label: '', value: '28.4 d', sub: 'Average Cycle')), SizedBox(width: 12), Expanded(child: StatCard(label: '', value: '5.2 d', sub: 'Average Bleed'))],
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chronology of Bleeds', style: AppText.secIn),
              _Crow(date: 'Sept 14 – Sept 19', len: '5 Days', tag: 'On Time', pink: false),
              _Crow(date: 'Aug 16 – Aug 21', len: '5 Days', tag: 'On Time', pink: false),
              _Crow(date: 'July 19 – July 23', len: '4 Days', tag: 'Short', pink: true),
            ],
          ),
        ),
      ],
    );
  }
}

class _Crow extends StatelessWidget {
  final String date;
  final String len;
  final String tag;
  final bool pink;
  const _Crow({required this.date, required this.len, required this.tag, required this.pink});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.line))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(date, style: AppText.sans(12, w: FontWeight.w600, c: AppColors.ink)), Text(len, style: AppText.sans(9.5, c: AppColors.muted))],
          ),
          pink ? AppTag.pink(tag) : AppTag(tag),
        ],
      ),
    );
  }
}
