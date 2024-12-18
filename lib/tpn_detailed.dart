import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TpnDetailScreen extends StatelessWidget {
  final String patientId;
  final String theDepartment;
  final String date;

  TpnDetailScreen({
    required this.patientId,
    required this.date,
    required this.theDepartment,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TPN Parameters on $date'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('departments')
            .doc(theDepartment)
            .collection('patients')
            .doc(patientId)
            .collection('tpnParameters')
            .where('date', isEqualTo: date)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No TPN data found for $date',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final parameters =
              snapshot.data!.docs.first.data() as Map<String, dynamic>;

          return LayoutBuilder(
            builder: (context, constraints) {
              // Determine the orientation
              bool isPortrait = constraints.maxWidth < constraints.maxHeight;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: isPortrait
                    ? ListView(
                        children: [
                          _buildCard(
                            title: 'Info',
                            data: {
                              'Patient Name': parameters['patient_name'] ?? '',
                              'Weight (Kg)':
                                  _getNonNaNValue(parameters['weight']),
                              'Net Volume':
                                  _getNonNaNValue(parameters['net_volume']),
                              'Rate': _getNonNaNValue(
                                  parameters['net_volume'] != null
                                      ? (parameters['net_volume'] / 24)
                                          .toStringAsFixed(2)
                                      : null),
                            },
                          ),
                          _buildCard(
                            title: 'Fluid Calculation',
                            data: {
                              'ml/kg/day': _getNonNaNValue(parameters['ml_kg']),
                              'Feeding':
                                  _getNonNaNValue(parameters['total_feeding']),
                              'Restriction':
                                  _getNonNaNValue(parameters['restriction_ml']),
                              'Drugs (mls)':
                                  _getNonNaNValue(parameters['Drugs_mls']),
                              'Fills': _getNonNaNValue(parameters['fills_ml']),
                            },
                          ),
                          _buildCard(
                            title: 'Parameters',
                            data: {
                              'Na': _getNonNaNValue(parameters['sodium_meq']),
                              'K': _getNonNaNValue(parameters['potassium_meq']),
                              'Glycophos':
                                  _getNonNaNValue(parameters['glyco_mmol']),
                              'Mg':
                                  _getNonNaNValue(parameters['magnesium_mmol']),
                              'Vitamin': _getNonNaNValue(
                                  parameters['vitamin_concentration']),
                              'Trace Element': _getNonNaNValue(
                                  parameters['trace_elements_concentration']),
                              'Protein':
                                  _getNonNaNValue(parameters['protein_grams']),
                              'Lipid':
                                  _getNonNaNValue(parameters['lipid_grams']),
                              'GIR':
                                  _getNonNaNValue(parameters['Gir_required']),
                            },
                          ),
                          _buildCard(
                            title: 'Osmolarity & Calories',
                            data: {
                              'Osmolarity':
                                  _getNonNaNValue(parameters['osmolarity']),
                              'Kcal from Fluid': _getNonNaNValue(
                                  parameters['kcal_from_fluid']),
                              'Feeding Kcal':
                                  _getNonNaNValue(parameters['feeding_kcal']),
                              'Total Kcal':
                                  _getNonNaNValue(parameters['total_kcal']),
                            },
                          ),
                        ],
                      )
                    : GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.8,
                        children: [
                          _buildCard(
                            title: 'Info',
                            data: {
                              'Patient Name': parameters['patient_name'] ?? '',
                              'Weight (Kg)':
                                  _getNonNaNValue(parameters['weight']),
                              'Net Volume':
                                  _getNonNaNValue(parameters['net_volume']),
                              'Rate': _getNonNaNValue(
                                  parameters['net_volume'] != null
                                      ? (parameters['net_volume'] / 24)
                                          .toStringAsFixed(2)
                                      : null),
                            },
                          ),
                          _buildCard(
                            title: 'Fluid Calculation',
                            data: {
                              'ml/kg/day': _getNonNaNValue(parameters['ml_kg']),
                              'Feeding':
                                  _getNonNaNValue(parameters['total_feeding']),
                              'Restriction':
                                  _getNonNaNValue(parameters['restriction_ml']),
                              'Drugs (mls)':
                                  _getNonNaNValue(parameters['Drugs_mls']),
                              'Fills': _getNonNaNValue(parameters['fills_ml']),
                            },
                          ),
                          _buildCard(
                            title: 'Parameters',
                            data: {
                              'Na': _getNonNaNValue(parameters['sodium_meq']),
                              'K': _getNonNaNValue(parameters['potassium_meq']),
                              'Glycophos':
                                  _getNonNaNValue(parameters['glyco_mmol']),
                              'Mg':
                                  _getNonNaNValue(parameters['magnesium_mmol']),
                              'Vitamin': _getNonNaNValue(
                                  parameters['vitamin_concentration']),
                              'Trace Element': _getNonNaNValue(
                                  parameters['trace_elements_concentration']),
                              'Protein':
                                  _getNonNaNValue(parameters['protein_grams']),
                              'Lipid':
                                  _getNonNaNValue(parameters['lipid_grams']),
                              'GIR':
                                  _getNonNaNValue(parameters['Gir_required']),
                            },
                          ),
                          _buildCard(
                            title: 'Osmolarity & Calories',
                            data: {
                              'Osmolarity':
                                  _getNonNaNValue(parameters['osmolarity']),
                              'Kcal from Fluid': _getNonNaNValue(
                                  parameters['kcal_from_fluid']),
                              'Feeding Kcal':
                                  _getNonNaNValue(parameters['feeding_kcal']),
                              'Total Kcal':
                                  _getNonNaNValue(parameters['total_kcal']),
                            },
                          ),
                        ],
                      ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCard(
      {required String title, required Map<String, String> data}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: data.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            flex: 4,
                            child: Text(
                              '${entry.key}:',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            flex: 6,
                            child: Text(
                              entry.value.isEmpty ? '—' : entry.value,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                              softWrap:
                                  true, // Ensure text wraps to the next line
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedTpnScreen(List<Map<String, String>> tpnDataList) {
    return GridView.builder(
      padding: const EdgeInsets.all(12.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Always show 2 cards side by side
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75, // Adjust this to tweak card height vs width
      ),
      itemCount: tpnDataList.length,
      itemBuilder: (context, index) {
        final tpnData = tpnDataList[index];
        final title = 'TPN ${index + 1}'; // Example title, customize as needed
        return _buildCard(title: title, data: tpnData);
      },
    );
  }

  String _getNonNaNValue(dynamic value) {
    if (value is double && value.isNaN) {
      return '';
    }
    return value?.toString() ?? '';
  }
}
