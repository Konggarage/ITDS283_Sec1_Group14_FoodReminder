import 'package:flutter/material.dart';
import 'package:myapp/pages/analyze.dart';
import 'package:myapp/pages/settingpage.dart';

class FoodRecommendationPage extends StatelessWidget {
  const FoodRecommendationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Analyze()),
            );
          },
          icon: Icon(Icons.bar_chart),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Open settings page or perform any action
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Settingpage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Categories',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Category List
            Expanded(
              child: ListView(
                children: [
                  CategoryItem(title: 'Vegetables & Fruits'),
                  CategoryItem(title: 'Meat & Fish'),
                  CategoryItem(title: 'Bread & Bakery Products'),
                  CategoryItem(title: 'Rice & Pasta'),
                  CategoryItem(title: 'Beverages'),
                  CategoryItem(title: 'Processed Foods'),
                  CategoryItem(title: 'Condiments & Sauces'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String title;

  const CategoryItem({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          // Navigate to the details page for each category
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryDetailsPage(title: title),
            ),
          );
        },
      ),
    );
  }
}

class CategoryDetailsPage extends StatelessWidget {
  final String title;

  const CategoryDetailsPage({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title == 'Vegetables & Fruits')
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: AssetImage('assets/Categories/Vegetable.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Management Tips:',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🟢 Composting:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '  Rotten vegetables and fruits can be composted to create nutrient-rich soil.',
                          ),
                          SizedBox(height: 12),
                          Text(
                            '🟢 Use It All:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '  Plan meals to use up the produce before it spoils.',
                          ),
                          SizedBox(height: 12),
                          Text(
                            '🟢 Storage:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '  Store fruits and vegetables in the fridge or cool place to extend their shelf life.',
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else if (title == 'Meat & Fish')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: AssetImage('assets/Categories/Meatfish.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Management Tips:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '🧊 Freezing: Freeze meat and fish if not used within a few days to prolong shelf life.',
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '📅 Labeling: Label packages with date of purchase to track freshness.',
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '🌡️ Storage: Store at appropriate temperature immediately after purchase.',
                    ),
                  ],
                )
              else if (title == 'Bread & Bakery Products')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/Categories/Bakery-Products.jpg',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Management Tips:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '🥖 Storage: Keep bread in a breadbox or airtight container at room temperature.',
                    ),
                    const SizedBox(height: 12),
                    const Text('🧊 Freezing: Freeze bread for longer storage.'),
                    const SizedBox(height: 12),
                    const Text(
                      '❌ Avoid: Don’t store bread in the fridge, it speeds up staling.',
                    ),
                  ],
                )
              else if (title == 'Rice & Pasta')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: AssetImage('assets/Categories/rice.jpg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Management Tips:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '🍚 Storage: Store dry rice and pasta in airtight containers.',
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '📅 Shelf Life: Check expiration dates and use FIFO (First In, First Out).',
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '🔥 Cooking: Cook only necessary portions to reduce waste.',
                    ),
                  ],
                )
              else if (title == 'Beverages')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/Categories/beverages.jpg',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Management Tips:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '🥤 Storage: Keep sealed beverages in cool, dark places.',
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '🧊 Refrigerate: After opening, refrigerate and consume within a few days.',
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '🔄 Rotation: Rotate stock to avoid expired products.',
                    ),
                  ],
                )
              else if (title == 'Processed Foods')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/Categories/ProcessedFoods.jpg',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Management Tips:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '📦 Shelf Life: Monitor expiration dates and store in a cool, dry area.',
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '🧂 Minimize Waste: Use opened items before starting new ones.',
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '🗑️ Avoid Overbuying: Only stock what you can consume before expiry.',
                    ),
                  ],
                )
              else if (title == 'Condiments & Sauces')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: AssetImage('assets/Categories/Sauces.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Management Tips:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            '🧴 Refrigeration: Store opened condiments as recommended.',
                            style: TextStyle(color: Colors.white70),
                          ),
                          SizedBox(height: 12),
                          Text(
                            '📅 Track Usage: Label with date opened.',
                            style: TextStyle(color: Colors.white70),
                          ),
                          SizedBox(height: 12),
                          Text(
                            '🧂 Use Small Portions: Avoid contamination by not double-dipping.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Text(
                  'No tips available for this category.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
