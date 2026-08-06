import 'package:flutter/material.dart';

class ContentScreen extends StatelessWidget {
  const ContentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Library'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 24),
            _buildCategories(),
            const SizedBox(height: 24),
            _buildFeaturedArticles(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search health articles...',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      {'icon': Icons.local_hospital, 'label': 'Menstruation', 'color': Colors.pink},
      {'icon': Icons.pregnant_woman, 'label': 'Pregnancy', 'color': Colors.purple},
      {'icon': Icons.science, 'label': 'Fertility', 'color': Colors.green},
      {'icon': Icons.psychology, 'label': 'Mental Health', 'color': Colors.blue},
      {'icon': Icons.food_bank, 'label': 'Nutrition', 'color': Colors.orange},
      {'icon': Icons.sports_gymnastics, 'label': 'Exercise', 'color': Colors.teal},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return InkWell(
          onTap: () {
            // Navigate to category
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
                  decoration: BoxDecoration(
                    color: (category['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category['icon'] as IconData,
                  color: category['color'] as Color,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  category['label'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedArticles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Featured Articles',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildArticleCard(
          title: 'Understanding Your Menstrual Cycle',
          excerpt: 'Learn about the different phases of your cycle and what happens each month.',
          category: 'Menstruation',
          readTime: '5 min read',
        ),
        const SizedBox(height: 12),
        _buildArticleCard(
          title: 'Fertility Awareness: What You Need to Know',
          excerpt: 'Discover how to track your fertility window and understand your body signals.',
          category: 'Fertility',
          readTime: '8 min read',
        ),
        const SizedBox(height: 12),
        _buildArticleCard(
          title: 'Pregnancy Trimester Guide',
          excerpt: 'Everything you need to know about each trimester of pregnancy.',
          category: 'Pregnancy',
          readTime: '10 min read',
        ),
      ],
    );
  }

  Widget _buildArticleCard({
    required String title,
    required String excerpt,
    required String category,
    required String readTime,
  }) {
    return InkWell(
      onTap: () {
        // Navigate to article
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C27B0),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  readTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              excerpt,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}