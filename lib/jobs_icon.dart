import 'package:bakryapp/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JobTitleIcon extends StatelessWidget {
  final double size; // Size of the circular image

  const JobTitleIcon({super.key, this.size = 50.0});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final jobTitle = userProvider.jobTitle;

    // Map job titles to corresponding PNG paths
    final jobTitleIcons = {
      'Clinical Pharmacist': 'assets/images/clinical pharmacist.png',
      'IV Pharmacist': 'assets/images/IV.png',
      'Specialist': 'assets/images/specialist.png',
      'Physician': 'assets/images/doctor.png',
      'Admin': 'assets/images/admin.png',
      'TPN': 'assets/images/TPN.png',
    };

    // Get the image path based on the job title
    final imagePath = jobTitleIcons[jobTitle] ?? 'assets/images/default.png';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipOval(
          child: Image.asset(
            imagePath,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}
