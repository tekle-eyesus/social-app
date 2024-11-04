import 'package:flutter/material.dart';

class ProfessionDropdown extends StatefulWidget {
  @override
  _ProfessionDropdownState createState() => _ProfessionDropdownState();
}

class _ProfessionDropdownState extends State<ProfessionDropdown> {
  String? selectedProfession;
  final List<String> professions = [
    'Software Developer/Engineer',
    'Web Developer',
    'Data Scientist',
    'Product Manager',
    'UX/UI Designer',
    'DevOps Engineer',
    'Systems Analyst',
    'Cybersecurity Analyst',
    'Cloud Engineer',
    'Machine Learning Engineer',
    'Quality Assurance (QA) Tester',
    'Database Administrator',
    'IT Support Specialist',
    'Mobile App Developer',
    'Technical Writer',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedProfession,
          hint: Text(
            'Select Profession',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          icon: Icon(Icons.arrow_drop_down, color: Colors.blueAccent),
          isExpanded: true,
          style: TextStyle(fontSize: 16, color: Colors.black),
          items: professions.map((String profession) {
            return DropdownMenuItem<String>(
              value: profession,
              child: Text(profession),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedProfession = newValue;
              print(selectedProfession);
            });
          },
        ),
      ),
    );
  }
}
