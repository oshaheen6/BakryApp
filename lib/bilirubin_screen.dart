import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThresholdScreen extends StatefulWidget {
  @override
  _ThresholdScreenState createState() => _ThresholdScreenState();
}

class _ThresholdScreenState extends State<ThresholdScreen> {
  Map<String, dynamic>? thresholds;
  String? selectedGestationalAge;
  double? bilirubinLevel;
  int? hoursOfAge;
  DateTime? dateOfBirth;
  TimeOfDay? timeOfBirth;
  bool useCalculatedAge = false;

  final List<String> gestationalAges = [
    '≥40 Weeks',
    '39 Weeks',
    '38 Weeks',
    '37 Weeks',
    '36 Weeks',
    '35 Weeks',
    '34 Weeks',
    '33-32 Weeks',
    '31-30 Weeks',
    '29-28 Weeks',
    '< 28 Weeks',
  ];

  // Risk factors
  final List<String> riskFactors = [
    'Albumin <3.0 g/dL',
    'Isoimmune hemolytic disease',
    'G6PD deficiency',
    'Sepsis',
    'Significant clinical instability in the previous 24 h',
  ];

  List<bool> selectedRiskFactors =
      List.filled(6, false); // Track selected risk factors

  @override
  void initState() {
    super.initState();
    loadThresholds();
  }

  Future<void> loadThresholds() async {
    final jsonString = await rootBundle.loadString('assets/thresholds.json');
    setState(() {
      thresholds = jsonDecode(jsonString);
    });
  }

  String determineRiskCategory() {
    // Check if any risk factor is selected
    return selectedRiskFactors.contains(true) ? 'withRisk' : 'withoutRisk';
  }

  String determineAction() {
    String selectedRisk = determineRiskCategory();

    if (selectedGestationalAge == null ||
        bilirubinLevel == null ||
        hoursOfAge == null) {
      return "Incomplete data";
    }

    final phototherapy = (thresholds!['thresholds'][selectedRisk]
            ['phototherapy'][selectedGestationalAge] as List)
        .cast<num>();

    final exchange = (thresholds!['thresholds'][selectedRisk]['exchange']
            [selectedGestationalAge] as List)
        .cast<num>();

    final xAxis = (thresholds!['xAxis'] as List).cast<num>();

    int index = xAxis.indexWhere((hour) => hour >= hoursOfAge!);
    if (index == -1) {
      index = xAxis.length - 1;
    }

    if (bilirubinLevel! >= exchange[index]) {
      final exchangeNum = exchange[index];
      return "Exchange transfusion required, The exchange threshold is $exchangeNum at $hoursOfAge hours of Age";
    } else if (bilirubinLevel! >= phototherapy[index]) {
      final photoNum = phototherapy[index];
      return "Phototherapy required, The phototherapy threshold is $photoNum at $hoursOfAge hours of Age";
    } else {
      return "No action needed";
    }
  }

  int calculateAgeInHours() {
    if (dateOfBirth == null || timeOfBirth == null) {
      return 0;
    }

    final now = DateTime.now();
    final birthDateTime = DateTime(
      dateOfBirth!.year,
      dateOfBirth!.month,
      dateOfBirth!.day,
      timeOfBirth!.hour,
      timeOfBirth!.minute,
    );
    return now.difference(birthDateTime).inHours;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bilirubin Thresholds"),
      ),
      body: thresholds == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: "Gestational Age"),
                      items: gestationalAges.map((age) {
                        return DropdownMenuItem(value: age, child: Text(age));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedGestationalAge = value;
                        });
                      },
                    ),
                    TextField(
                      decoration: const InputDecoration(
                          labelText: "Bilirubin Level (mg/dL)"),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          bilirubinLevel = double.tryParse(value);
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    SwitchListTile(
                      title: const Text("Enter birth day instead of Age/hour"),
                      value: useCalculatedAge,
                      onChanged: (value) {
                        setState(() {
                          useCalculatedAge = value;
                          if (value) {
                            hoursOfAge = calculateAgeInHours();
                          }
                        });
                      },
                    ),
                    if (useCalculatedAge) ...[
                      TextButton(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (pickedDate != null) {
                            setState(() {
                              dateOfBirth = pickedDate;
                              if (timeOfBirth != null) {
                                hoursOfAge = calculateAgeInHours();
                              }
                            });
                          }
                        },
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: dateOfBirth == null
                                    ? "Select Date of Birth "
                                    : DateFormat.yMMMd().format(dateOfBirth!),
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .displayMedium
                                        ?.color),
                              ),
                              const TextSpan(
                                text: '*',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ),
                      TextButton(
                          onPressed: () async {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                            );
                            if (pickedTime != null) {
                              setState(() {
                                timeOfBirth = pickedTime;
                                if (dateOfBirth != null) {
                                  hoursOfAge = calculateAgeInHours();
                                }
                              });
                            }
                          },
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: timeOfBirth == null
                                      ? "Select Time of Birth "
                                      : timeOfBirth!.format(context),
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color),
                                ),
                                const TextSpan(
                                  text: '*',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          )),
                      if (hoursOfAge != null)
                        Text("Calculated Age: $hoursOfAge hours"),
                    ] else ...[
                      TextField(
                        decoration:
                            const InputDecoration(labelText: "Age (hours)"),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            hoursOfAge = int.tryParse(value);
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 20),
                    const Text(
                      "Hyperbilirubinemia Neurotoxicity Risk Factors",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    ...List.generate(riskFactors.length, (index) {
                      return CheckboxListTile(
                        title: Text(riskFactors[index]),
                        value: selectedRiskFactors[index],
                        onChanged: (value) {
                          setState(() {
                            selectedRiskFactors[index] = value!;
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        try {
                          final action = determineAction();
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text("Recommended Action"),
                              content: Text(action),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("OK"),
                                ),
                              ],
                            ),
                          );
                        } catch (e, stackTrace) {
                          debugPrint("Error: $e");
                          print(stackTrace);
                        }
                      },
                      child: const Text("Check Threshold"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
