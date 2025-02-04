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
  final ApiService apiService = ApiService();

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
    await apiService.updateUnit(id, updatedUnit);
    loadUnits();
  }

  void _deleteUnit(String id) async {
    await apiService.deleteUnit(id);
    await loadUnits();
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
              },
              child: Text(unit == null ? 'Add' : 'Save'),
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
          : ListView.builder(
              itemCount: units.length,
              itemBuilder: (context, index) {
                final unit = units[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    title: Text(unit.unitName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _showAddEditDialog(unit: unit),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteUnit(unit.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
