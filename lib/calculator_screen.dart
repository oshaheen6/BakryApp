import 'package:flutter/material.dart';

class CalculatorsScreen extends StatefulWidget {
  const CalculatorsScreen({Key? key}) : super(key: key);

  @override
  _CalculatorsScreenState createState() => _CalculatorsScreenState();
}

class _CalculatorsScreenState extends State<CalculatorsScreen> {
  final TextEditingController _weightController = TextEditingController();
  double? _calculatedAmount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculators'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateAmount,
              child: const Text('Calculate'),
            ),
            if (_calculatedAmount != null)
              Text(
                  'Calculated Amount: ${_calculatedAmount!.toStringAsFixed(2)} mL'),
          ],
        ),
      ),
    );
  }

  void _calculateAmount() {
    final weight = double.tryParse(_weightController.text);

    if (weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a valid weight')),
      );
      return;
    }

    // Replace this with the actual calculation logic
    _calculatedAmount = weight * 1.5; // Example calculation

    setState(() {});
  }
}
