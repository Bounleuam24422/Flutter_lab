import 'package:flutter/material.dart';
import 'package:fnt_back/unit_api.dart'; // Import the ApiService

class Unit {
  String id;
  String unitName;

  Unit({
    required this.id,
    required this.unitName,
  });

  // Convert JSON to a Unit object
  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['_id'],
      unitName: json['unitName'],
    );
  }

  // Convert a Unit object to JSON
  Map<String, dynamic> toJson() {
    return {
      'unitName': unitName,
    };
  }
}

class UnitScreen extends StatefulWidget {
  const UnitScreen({super.key});

  @override
  State<UnitScreen> createState() => _UnitScreenState();
}

class _UnitScreenState extends State<UnitScreen> {
  List<Unit> units = [];
  final UnitService apiService = UnitService();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUnits();
  }

  Future<void> loadUnits() async {
    try {
      List<Unit> fetchedUnits = await apiService.fetchUnits();
      setState(() {
        units = fetchedUnits;
      });
    } catch (e) {
      debugPrint('Error loading units: $e');
    }
  }

  void _addUnit(Unit unit) async {
    await apiService.addUnit(unit);
    loadUnits();
  }

  void _updateUnit(String id, Unit updatedUnit) async {
    bool updateUnit = await apiService.updateUnit(id, updatedUnit);
    if (updateUnit) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Update Success...',
            textAlign: TextAlign.center,
          ),
        ),
      );
      loadUnits();
    }
  }

  void _deleteUnit(String id) async {
    bool deleteUnit = await apiService.deleteUnit(id);
    if (deleteUnit) {
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
      await loadUnits();
    }
  }

  void _showAddEditDialog({Unit? unit}) {
    final TextEditingController unitNameController =
        TextEditingController(text: unit?.unitName ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(unit == null ? 'Add Unit' : 'Edit Unit'),
          content: TextField(
            controller: unitNameController,
            decoration: const InputDecoration(labelText: 'Unit Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final filter = units.where(
                    (item) => item.unitName == unitNameController.text.trim());
                if (filter.isEmpty) {
                  final String unitName = unitNameController.text.trim();
                  if (unitName.isNotEmpty) {
                    final Unit newUnit = Unit(
                      id: unit?.id ?? '',
                      unitName: unitName,
                    );

                    if (unit == null) {
                      _addUnit(newUnit);
                    } else {
                      _updateUnit(unit.id, newUnit);
                    }
                  }
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(
                        'Already have Unit',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }
              },
              child: Text(unit == null ? 'Add' : 'Edit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unit List')),
      body: units.isEmpty
          ? const Center(child: Text('No units added yet!'))
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
                    itemCount: units.length,
                    itemBuilder: (context, index) {
                      final unit = units[index];
                      return _controller.text.isEmpty ||
                              unit.unitName
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
                                    Text('${unit.unitName}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () {
                                            _showAddEditDialog(unit: unit);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () => _deleteUnit(unit.id),
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
