import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// =====================================================
// ARTICLE DATA MODEL
// =====================================================

class LearningArticle {
  final String title;
  final String category;
  final String summary;
  final String content;
  final String imagePath;
  final IconData icon;
  final String source;

  const LearningArticle({
    required this.title,
    required this.category,
    required this.summary,
    required this.content,
    required this.imagePath,
    required this.icon,
    required this.source,
  });
}

// =====================================================
// OFFLINE EDUCATIONAL ARTICLES
// =====================================================

const List<LearningArticle> learningArticles = [
  LearningArticle(
    title: 'Recognising Food Spoilage',
    category: 'Food Safety',
    summary:
        'Understand common visible signs that fruits and vegetables '
        'may be deteriorating.',
    imagePath: 'assets/images/learning/food_spoilage.jpg',
    icon: Icons.visibility_outlined,
    source: 'Further reading: WHO food safety guidance',
    content: '''
Food spoilage occurs when food deteriorates due to factors such as microorganisms, enzymes, physical damage, and storage conditions.

Common visible signs include:

• Mould growth on the surface.
• Unusual discolouration.
• Soft, slimy, or excessively mushy areas.
• Significant changes in texture.
• Visible leakage or decay.

Some produce naturally changes colour as it ripens. A colour change alone does not always mean that food is unsafe.

Food can also contain harmful microorganisms without showing visible signs of spoilage.

If food shows significant signs of decay or contamination, avoid consuming it.

FreshTrack can help identify possible visible spoilage indicators, but a smartphone image cannot guarantee that food is safe to eat.
''',
  ),

  LearningArticle(
    title: 'Storing Fruits and Vegetables',
    category: 'Food Safety',
    summary:
        'Learn practical storage habits that may help maintain '
        'produce quality.',
    imagePath: 'assets/images/learning/food_storage.jpg',
    icon: Icons.kitchen_outlined,
    source: 'Further reading: FAO post-harvest handling resources',
    content: '''
Correct storage can help slow deterioration and reduce avoidable food waste.

Helpful practices include:

• Keep storage areas clean and well ventilated.
• Separate damaged or decaying produce from healthy produce.
• Refrigerate produce that requires cold storage.
• Avoid crushing delicate fruits and vegetables.
• Use clean, suitable containers.
• Check stored produce regularly.

Different fruits and vegetables have different storage requirements.

Some fruits continue ripening after harvest, while others are sensitive to cold temperatures.

Store cut produce promptly under appropriate refrigeration.

Good storage practices help preserve quality, but they cannot make already unsafe food safe.
''',
  ),

  LearningArticle(
    title: 'Safe Food Handling and Hygiene',
    category: 'Food Safety',
    summary:
        'Simple hygiene practices for handling fresh produce '
        'at home or in a food business.',
    imagePath: 'assets/images/learning/food_hygiene.jpg',
    icon: Icons.health_and_safety_outlined,
    source: 'Further reading: WHO Five Keys to Safer Food',
    content: '''
Food hygiene is important during purchasing, preparation, storage, and serving.

Recommended practices include:

• Wash your hands with soap and safe water before handling food.
• Clean utensils and preparation surfaces.
• Wash fruits and vegetables with safe running water where appropriate.
• Keep produce away from raw meat and other contamination sources.
• Use clean storage containers.
• Follow appropriate refrigeration practices.

Avoid using soap or household detergents directly on fruits and vegetables.

Discard produce that is clearly contaminated or extensively decayed.

Clean handling reduces risks, but appearance alone cannot establish whether food is microbiologically safe.
''',
  ),

  LearningArticle(
    title: 'Reducing Food Waste Safely',
    category: 'Food Safety',
    summary:
        'Make better use of produce while keeping food safety '
        'a priority.',
    imagePath: 'assets/images/learning/food_waste.jpg',
    icon: Icons.recycling_outlined,
    source: 'Further reading: FAO food loss and waste resources',
    content: '''
Reducing food waste begins with planning, storage, and careful handling.

Practical steps include:

• Plan purchases according to expected consumption.
• Use older suitable produce before newer produce.
• Store fruits and vegetables correctly.
• Check produce regularly for deterioration.
• Share or donate suitable surplus food before it spoils.
• Compost unsuitable plant waste where appropriate.

Some fruits and vegetables with minor cosmetic imperfections may still be suitable for use.

However, produce that is mouldy, extensively decayed, or otherwise unsafe should not be repurposed for consumption.

Food waste reduction should never come at the expense of food safety.
''',
  ),

  LearningArticle(
    title: 'Drying Surplus Mangoes',
    category: 'Value Addition',
    summary:
        'Explore how drying can extend the usefulness of '
        'suitable surplus mangoes.',
    imagePath: 'assets/images/learning/dried_mangoes.jpg',
    icon: Icons.wb_sunny_outlined,
    source: 'Further reading: FAO fruit processing resources',
    content: '''
Drying is a value addition method that removes moisture from food to help slow deterioration.

A basic mango-drying workflow includes:

1. Select sound, suitable mangoes.
2. Wash the fruit and preparation equipment.
3. Peel and slice the mangoes uniformly.
4. Use a suitable food dehydrator or controlled drying method.
5. Dry the slices adequately using a validated process.
6. Cool and package them hygienically.
7. Store in appropriate moisture-resistant packaging.

Drying conditions affect product quality and safety.

Avoid using mangoes that are mouldy, rotten, or contaminated.

Drying does not reliably eliminate every food safety hazard and must not be used to rescue spoiled fruit.
''',
  ),

  LearningArticle(
    title: 'Fruit Jams and Preserves',
    category: 'Value Addition',
    summary:
        'An introduction to transforming suitable fruit '
        'into jams and preserves.',
    imagePath: 'assets/images/learning/fruit_jam.jpg',
    icon: Icons.breakfast_dining_outlined,
    source: 'Further reading: FAO small-scale fruit processing',
    content: '''
Jam production is a common fruit value addition activity.

The process generally involves:

1. Selecting suitable, sound fruit.
2. Washing and preparing the ingredients.
3. Combining fruit with an appropriate formulation.
4. Cooking according to a tested recipe.
5. Filling suitable containers hygienically.
6. Processing and storing the product as required.

Safe preservation depends on factors such as acidity, sugar concentration, processing conditions, and packaging.

Use a tested preservation recipe rather than estimating processing requirements.

Do not use rotten or mouldy fruit for jam production.

Jam-making cannot be assumed to make spoiled fruit safe.
''',
  ),

  LearningArticle(
    title: 'Safe Fruit Juice Preparation',
    category: 'Value Addition',
    summary:
        'Learn about hygienic fruit juice preparation '
        'and the importance of safe storage.',
    imagePath: 'assets/images/learning/fruit_juice.jpg',
    icon: Icons.local_drink_outlined,
    source: 'Further reading: WHO food hygiene guidance',
    content: '''
Fruit juice can be prepared for household consumption or small-scale sale.

Important considerations include:

• Select sound, suitable fruit.
• Wash hands, equipment, and preparation surfaces.
• Use safe water where needed.
• Prevent contamination during cutting and extraction.
• Use clean food-grade containers.
• Refrigerate perishable juice promptly.
• Follow appropriate validated processing requirements for products intended for sale or extended storage.

Freshly squeezed juice may contain harmful microorganisms.

Unpasteurised juice requires particular care and should not be assumed safe for everyone.

Never use spoiled fruit as an ingredient simply because the juice will be filtered or processed.
''',
  ),

  LearningArticle(
    title: 'Vegetable Drying and Preservation',
    category: 'Value Addition',
    summary:
        'Understand basic vegetable drying principles '
        'and safe preservation practices.',
    imagePath: 'assets/images/learning/vegetable_drying.jpg',
    icon: Icons.eco_outlined,
    source: 'Further reading: FAO vegetable processing resources',
    content: '''
Vegetable drying can reduce moisture and help preserve suitable produce.

A general process includes:

1. Select sound vegetables.
2. Wash and prepare them hygienically.
3. Cut into suitable, uniform pieces.
4. Apply appropriate pretreatment where required.
5. Dry using a controlled, validated method.
6. Cool and package hygienically.
7. Store in clean, suitable conditions.

Different vegetables require different preparation and drying conditions.

Inadequate drying or poor packaging can lead to deterioration during storage.

Use reliable food preservation guidance for specific temperatures, times, and storage requirements.

Do not dry vegetables that are rotten, mouldy, or otherwise unsafe.
''',
  ),
];

// =====================================================
// LEARNING HUB SCREEN
// =====================================================

class LearningHubScreen extends StatefulWidget {
  final String initialCategory;

  const LearningHubScreen({super.key, this.initialCategory = 'All'});

  @override
  State<LearningHubScreen> createState() => _LearningHubScreenState();
}

class _LearningHubScreenState extends State<LearningHubScreen> {
  static const Color forest = AppTheme.forest;
  static const Color muted = AppTheme.muted;
  static const Color border = AppTheme.border;

  static const List<String> categories = [
    'All',
    'Food Safety',
    'Value Addition',
  ];

  late String selectedCategory;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();

    selectedCategory = categories.contains(widget.initialCategory)
        ? widget.initialCategory
        : 'All';
  }

  List<LearningArticle> get filteredArticles {
    return learningArticles.where((article) {
      final matchesCategory =
          selectedCategory == 'All' || article.category == selectedCategory;

      final query = searchQuery.trim().toLowerCase();

      final matchesSearch =
          query.isEmpty ||
          article.title.toLowerCase().contains(query) ||
          article.summary.toLowerCase().contains(query) ||
          article.category.toLowerCase().contains(query);

      return matchesCategory && matchesSearch;
    }).toList();
  }

  Color _categoryBackground(String category) {
    return category == 'Food Safety'
        ? const Color(0xFFE4F1E6)
        : const Color(0xFFFFE9D7);
  }

  void _openArticle(LearningArticle article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LearningArticleScreen(article: article),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final articles = filteredArticles;

    return Scaffold(
      backgroundColor: AppTheme.ivory,
      appBar: AppBar(
        backgroundColor: AppTheme.ivory,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: forest,
        title: const Text(
          'Learn & Explore',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
          children: [
            const Text(
              'Food knowledge for\neveryday decisions.',
              style: TextStyle(
                color: forest,
                fontSize: 27,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                height: 1.18,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Explore practical articles on food safety, '
              'storage and value addition. Available offline.',
              style: TextStyle(color: muted, fontSize: 13, height: 1.5),
            ),

            const SizedBox(height: 22),

            // SEARCH
            TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search articles...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: forest, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // CATEGORY FILTERS
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((category) {
                  final isSelected = selectedCategory == category;

                  return Padding(
                    padding: const EdgeInsets.only(right: 9),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      selectedColor: AppTheme.sage,
                      backgroundColor: Colors.white,
                      side: BorderSide(color: isSelected ? forest : border),
                      labelStyle: TextStyle(
                        color: forest,
                        fontWeight: isSelected
                            ? FontWeight.w800
                            : FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 23),

            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedCategory == 'All'
                        ? 'All articles'
                        : selectedCategory,
                    style: const TextStyle(
                      color: forest,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${articles.length} articles',
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),

            const SizedBox(height: 14),

            if (articles.isEmpty)
              _buildEmptyState()
            else
              ...articles.map(_buildArticleCard),

            const SizedBox(height: 22),

            _buildSafetyNote(),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // ARTICLE CARD WITH IMAGE
  // =====================================================

  Widget _buildArticleCard(LearningArticle article) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () => _openArticle(article),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: Image.asset(
                    article.imagePath,
                    width: 92,
                    height: 105,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 92,
                        height: 105,
                        color: _categoryBackground(article.category),
                        child: Icon(article.icon, color: forest, size: 32),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.category.toUpperCase(),
                        style: const TextStyle(
                          color: muted,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: forest,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        article.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: muted,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Row(
                        children: [
                          Text(
                            'Read article',
                            style: TextStyle(
                              color: forest,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: forest,
                            size: 15,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_outlined, color: muted, size: 39),
          SizedBox(height: 10),
          Text(
            'No matching articles',
            style: TextStyle(color: forest, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6),
          Text(
            'Try a different search or category.',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyNote() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppTheme.sage,
        borderRadius: BorderRadius.circular(17),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: forest, size: 22),
          SizedBox(width: 11),
          Expanded(
            child: Text(
              'Educational information only. FreshTrack image '
              'assessments cannot confirm that food is safe '
              'to consume.',
              style: TextStyle(color: forest, fontSize: 12, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// ARTICLE DETAIL SCREEN
// =====================================================

class LearningArticleScreen extends StatelessWidget {
  final LearningArticle article;

  const LearningArticleScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    const Color forest = AppTheme.forest;
    const Color muted = AppTheme.muted;

    final Color background = article.category == 'Food Safety'
        ? const Color(0xFFE4F1E6)
        : const Color(0xFFFFE9D7);

    return Scaffold(
      backgroundColor: AppTheme.ivory,
      appBar: AppBar(
        backgroundColor: AppTheme.ivory,
        surfaceTintColor: Colors.transparent,
        foregroundColor: forest,
        elevation: 0,
        title: const Text(
          'Article',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 35),
          children: [
            // LARGE ARTICLE IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(
                article.imagePath,
                height: 225,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 225,
                    color: background,
                    alignment: Alignment.center,
                    child: Icon(article.icon, color: forest, size: 75),
                  );
                },
              ),
            ),

            const SizedBox(height: 23),

            Text(
              article.category.toUpperCase(),
              style: const TextStyle(
                color: muted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 11),

            Text(
              article.title,
              style: const TextStyle(
                color: forest,
                fontSize: 29,
                fontWeight: FontWeight.w800,
                height: 1.2,
                letterSpacing: -0.7,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              article.summary,
              style: const TextStyle(color: muted, fontSize: 14, height: 1.6),
            ),

            const SizedBox(height: 20),

            const Divider(color: AppTheme.border),

            const SizedBox(height: 18),

            const Text(
              'What you should know',
              style: TextStyle(
                color: forest,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 14),

            Text(
              article.content.trim(),
              style: const TextStyle(color: forest, fontSize: 14, height: 1.8),
            ),

            const SizedBox(height: 28),

            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(17),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.menu_book_outlined, color: forest, size: 22),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Suggested further reading',
                          style: TextStyle(
                            color: forest,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          article.source,
                          style: const TextStyle(
                            color: forest,
                            fontSize: 12,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'This article is provided for educational purposes. '
              'Follow appropriate food safety guidance when '
              'handling or processing produce.',
              style: TextStyle(color: muted, fontSize: 11, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
