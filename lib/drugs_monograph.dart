import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:bakryapp/provider/drug_monograph_hive.dart';

class DrugMonographScreen extends StatefulWidget {
  const DrugMonographScreen({Key? key}) : super(key: key);

  @override
  _DrugMonographScreenState createState() => _DrugMonographScreenState();
}

class _DrugMonographScreenState extends State<DrugMonographScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final drugBox = Provider.of<Box<DrugMonograph>>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Drug Monographs'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                labelText: 'Search Drug',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: _buildDrugList(drugBox),
          ),
        ],
      ),
    );
  }

  Widget _buildDrugList(Box<DrugMonograph> drugBox) {
    // Convert to list and sort by ID
    final drugs = drugBox.values.toList()..sort((a, b) => a.id.compareTo(b.id));

    // Filter drugs based on the search query
    final filteredDrugs = drugs.where((drug) {
      final drugName = drug.genericName.toLowerCase();
      return drugName.contains(_searchQuery);
    }).toList();

    if (filteredDrugs.isEmpty) {
      return const Center(
        child: Text('No matching drug found'),
      );
    }

    return ListView.builder(
      itemCount: filteredDrugs.length,
      itemBuilder: (context, index) {
        final drug = filteredDrugs[index];

        // Determine the color based on the 'aware' field
        Color color;
        switch (drug.aware?.toLowerCase()) {
          case 'access':
            color = Colors.green;
            break;
          case 'watch':
            color = Colors.yellow;
            break;
          case 'reserve':
            color = Colors.red;
            break;
          default:
            color = Colors.grey;
        }

        return Card(
          margin: const EdgeInsets.all(8.0),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            tileColor: color.withOpacity(0.3),
            title: Text(
              drug.genericName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (drug.category != null) Text('Category: ${drug.category}'),
                Text('Vial Concentration: ${drug.vialConc}'),
                Text('Dilution: ${drug.dilution}'),
                Text('Final Concentration: ${drug.finalConc}'),
                if (drug.aware != null) Text('Aware: ${drug.aware}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
