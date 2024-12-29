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

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DrugMonographDetailsScreen(drug: drug),
            ),
          ),
          child: Card(
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
          ),
        );
      },
    );
  }
}

class DrugMonographDetailsScreen extends StatelessWidget {
  final DrugMonograph drug;

  const DrugMonographDetailsScreen({Key? key, required this.drug})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(drug.genericName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Center(
              child: Text(
                drug.genericName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(thickness: 2, height: 20),

            // General Information Section
            _buildSectionHeader('General Information'),
            if (drug.category != null)
              _buildDetailRow('Category', drug.category!),
            _buildDetailRow('Vial Concentration', '${drug.vialConc} mg'),
            _buildDetailRow('Dilution', '${drug.dilution} ml'),
            _buildDetailRow('Final Concentration', drug.finalConc),
            if (drug.aware != null) _buildDetailRow('Aware', drug.aware!),

            // Adjustment Section
            if (drug.renalAdjustmentNicu != null ||
                drug.picuAdverseEffect != null ||
                drug.nicuAdverseEffect != null) ...[
              const SizedBox(height: 20),
              _buildSectionHeader('Adjustments & Effects'),
              if (drug.renalAdjustmentNicu != null)
                _buildDetailRow(
                    'Renal Adjustment (NICU)', drug.renalAdjustmentNicu!),
              if (drug.picuAdverseEffect != null)
                _buildDetailRow('PICU Adverse Effect', drug.picuAdverseEffect!),
              if (drug.nicuAdverseEffect != null)
                _buildDetailRow('NICU Adverse Effect', drug.nicuAdverseEffect!),
            ],

            // Administration & Stability Section
            if (drug.administration != null || drug.stability != null) ...[
              const SizedBox(height: 20),
              _buildSectionHeader('Administration & Stability'),
              if (drug.administration != null)
                _buildDetailRow('Administration', drug.administration!),
              if (drug.stability != null)
                _buildDetailRow('Stability', drug.stability!),
            ],

            // CSF Section
            if (drug.csf != null) ...[
              const SizedBox(height: 20),
              _buildSectionHeader('CSF Information'),
              _buildDetailRow('CSF', drug.csf!),
            ],
          ],
        ),
      ),
    );
  }

  // Helper Method: Builds section headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  // Helper Method: Builds key-value rows
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
