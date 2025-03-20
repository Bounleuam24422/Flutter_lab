import 'package:flutter/material.dart';
import 'package:fnt_back/category_api.dart'; // Import the ApiService

class Category {
  String id;
  String cateName;

  Category({
    required this.id,
    required this.cateName,
  });

  // Convert JSON to a Category object
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'],
      cateName: json['cateName'],
    );
  }

  // Convert a Category object to JSON
  Map<String, dynamic> toJson() {
    return {
      'cateName': cateName,
    };
  }
}

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<Category> categories = [];
  final ApiServiceCategory apiServiceCategory = ApiServiceCategory();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      List<Category> fetchedCategories =
          await apiServiceCategory.fetchCategories();
      setState(() {
        categories = fetchedCategories;
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  void _addCategory(Category category) async {
    await apiServiceCategory.addCategory(category);
    loadCategories();
  }

  void _updateCategory(String id, Category updatedCategory) async {
    bool update = await apiServiceCategory.updateCategory(id, updatedCategory);
    if (update) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Update Success...',
            textAlign: TextAlign.center,
          ),
        ),
      );
      loadCategories();
    }
  }

  void _deleteCategory(String id) async {
    bool deleteCategory = await apiServiceCategory.deleteCategory(id);
    if (deleteCategory) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            'Delete Success...',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
      await loadCategories();
    }
  }

  void _showAddEditDialog({Category? category}) {
    final TextEditingController categoryNameController =
        TextEditingController(text: category?.cateName ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(category == null ? 'Add Category' : 'Edit Category'),
          content: TextField(
            controller: categoryNameController,
            decoration: const InputDecoration(labelText: 'Category Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final filter = categories.where((item) =>
                    item.cateName == categoryNameController.text.trim());
                if (filter.isEmpty) {
                  final String cateName = categoryNameController.text.trim();
                  if (cateName.isNotEmpty) {
                    final Category newCategory = Category(
                      id: category?.id ?? '',
                      cateName: cateName,
                    );

                    if (category == null) {
                      _addCategory(newCategory);
                    } else {
                      _updateCategory(category.id, newCategory);
                    }
                  }
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(
                        'Already have Category',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }
              },
              child: Text(category == null ? 'Add' : 'Edit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Category List')),
      body: categories.isEmpty
          ? const Center(child: Text('No categories added yet!'))
          : Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                  child: TextField(
                    controller: _controller,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _controller.text.isEmpty ||
                              category.cateName
                                  .toUpperCase()
                                  .contains(_controller.text.toUpperCase())
                          ? Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${category.cateName}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () {
                                            _showAddEditDialog(
                                                category: category);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () =>
                                              _deleteCategory(category.id),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : const SizedBox();
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
