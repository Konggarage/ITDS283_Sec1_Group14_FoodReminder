import 'package:flutter/material.dart';
import 'package:myapp/pages/analyze.dart';
import 'package:myapp/pages/settingpage.dart';

class FoodRecommendationPage extends StatelessWidget {
  const FoodRecommendationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Analyze()),
            );
          },
          icon: Icon(Icons.bar_chart, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
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
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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
      color: Colors.grey[800],
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Management Tips:',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Here you can provide information and tips related to $title.',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            // Add any more information or tips about the category here
          ],
        ),
      ),
    );
  }
}
