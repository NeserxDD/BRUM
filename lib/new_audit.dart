import 'package:flutter/material.dart';
import 'package:project1/checklist.dart';


import 'department_selection.dart';
import 'area_selection.dart';

class NewAuditScreen extends StatefulWidget {
  @override
  _NewAuditScreenState createState() => _NewAuditScreenState();
}

class _NewAuditScreenState extends State<NewAuditScreen> {
  final TextEditingController _auditorController = TextEditingController();
  String? _selectedAuditType;
  String? _selectedDepartment;
  String? _selectedArea;
  String? _selectedSemester;
  int? _selectedYear;
  final List<TextEditingController> _teamMemberControllers = [
    TextEditingController()
  ];

  final List<String> _auditTypes = [
    'Soft S',
    'Hard S Office',
    'Hard S Hospital'
  ];

  final List<String> _semesters = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
  'September',
  'October',
  'November',
  'December',
  ];

  Future<void> _selectYear() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDatePickerMode: DatePickerMode.year,
      fieldLabelText: 'Select Year',
      helpText: 'Select Year Only',
    );

    if (picked != null) {
      setState(() {
        _selectedYear = picked.year;
      });
    }
  }

  void _selectSemester() async {
    final semester = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Month'),
          children: _semesters.map((sem) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, sem);
              },
              child: Text(sem),
            );
          }).toList(),
        );
      },
    );

    if (semester != null) {
      setState(() {
        _selectedSemester = semester;
      });
    }
  }

  void _selectAuditType() async {
    final type = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Select Type of Audit'),
          children: _auditTypes.map((type) {
            return SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, type);
              },
              child: Text(type),
            );
          }).toList(),
        );
      },
    );

    if (type != null && type != _selectedAuditType) {
      setState(() {
        _selectedAuditType = type;
        _selectedDepartment = null;
        _selectedArea = null;
      });
    }
  }

  void _selectDepartment() async {
    final department = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DepartmentSelectionScreen(
          onDepartmentSelected: (selectedDept) => Navigator.pop(context, selectedDept),
        ),
      ),
    );

    if (department != null && department != _selectedDepartment) {
      setState(() {
        _selectedDepartment = department;
        _selectedArea = null;
      });
    }
  }

  void _selectArea() async {
    if (_selectedDepartment == null) return;

    final area = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AreaSelectionScreen(department: _selectedDepartment!),
      ),
    );

    if (area != null) {
      setState(() => _selectedArea = area);
    }
  }

  void _addTeamMember() {
    if (_teamMemberControllers.length < 5) {
      setState(() {
        _teamMemberControllers.add(TextEditingController());
      });
    }
  }

  void _removeTeamMember(int index) {
    if (_teamMemberControllers.length > 1) {
      setState(() {
        _teamMemberControllers.removeAt(index);
      });
    }
  }

  void _startAudit() {
    final teamMembers = _teamMemberControllers
        .map((controller) => controller.text.trim())
        .where((name) => name.isNotEmpty)
        .toList();

    if (_auditorController.text.isNotEmpty &&
        _selectedAuditType != null &&
        _selectedDepartment != null &&
        (_selectedAuditType == 'Soft S' || _selectedArea != null) &&
        teamMembers.isNotEmpty &&
        _selectedSemester != null &&
        _selectedYear != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChecklistScreen(
            personName: _auditorController.text,
            departmentName: _selectedDepartment!,
            areaName: _selectedArea ?? '',
            auditType: _selectedAuditType!,
            teamMembers: teamMembers,
            auditPeriod: '${_selectedSemester} ${_selectedYear}',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _auditorController.dispose();
    for (var controller in _teamMemberControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool hasTeamMembers = _teamMemberControllers.any(
      (controller) => controller.text.trim().isNotEmpty,
    );

    bool isFormComplete = _auditorController.text.isNotEmpty &&
        _selectedAuditType != null &&
        _selectedDepartment != null &&
        (_selectedAuditType == 'Soft S' || _selectedArea != null) &&
        hasTeamMembers &&
        _selectedSemester != null &&
        _selectedYear != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New Audit',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 45, 103, 161),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Audit Type Selection
            ListTile(
              title: Text(_selectedAuditType ?? 'Select Type of Audit'),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.blue[700]),
              onTap: _selectAuditType,
            ),
            const Divider(),
            
            // Audit Period Section
            const Text(
              'Audit Period:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(_selectedSemester ?? 'Select Month'),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.blue[700]),
                    onTap: _selectSemester,
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(_selectedYear?.toString() ?? 'Select Year'),
                    trailing: Icon(Icons.arrow_forward_ios, color: Colors.blue[700]),
                    onTap: _selectYear,
                  ),
                ),
              ],
            ),
            const Divider(),
            
            // Auditor Name
            TextField(
              controller: _auditorController,
              cursorColor: Colors.blue[700],
              decoration: InputDecoration(
                labelText: "Team Leader's Name",
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 167, 205, 255),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                ),
              ),
              style: TextStyle(color: Colors.black),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Team Members Section
            const Text(
              'Team Members:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ..._teamMemberControllers.asMap().entries.map((entry) {
              final index = entry.key;
              final controller = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: 'Team Member ${index + 1}',
                          border: OutlineInputBorder(),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: const Color.fromARGB(255, 167, 205, 255),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    if (_teamMemberControllers.length > 1)
                      IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => _removeTeamMember(index),
                      ),
                  ],
                ),
              );
            }).toList(),
            if (_teamMemberControllers.length < 5)
              TextButton(
                onPressed: _addTeamMember,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: Colors.blue[700]),
                    const SizedBox(width: 4),
                    Text(
                      'Add Team Member',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Department Selection
            ListTile(
              title: Text(_selectedDepartment ?? 'Select Department'),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.blue[700]),
              onTap: _selectedAuditType != null ? _selectDepartment : null,
            ),
            const Divider(),

            // Area Selection (only shown if not Soft S)
            if (_selectedAuditType != null && _selectedAuditType != 'Soft S')
              Column(
                children: [
                  ListTile(
                    title: Text(
                      _selectedArea ??
                          (_selectedDepartment == null
                              ? 'Select Department First'
                              : 'Select Area'),
                    ),
                    trailing: _selectedDepartment != null
                        ? Icon(Icons.arrow_forward_ios, color: Colors.blue[700])
                        : null,
                    onTap: _selectedDepartment != null ? _selectArea : null,
                  ),
                  const Divider(),
                ],
              ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isFormComplete ? _startAudit : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Color.fromARGB(255, 45, 103, 161),
              ),
              child: const Text(
                'Start Audit',
                style: TextStyle(color: Colors.white),
              ),
            ),
          
          ],
        ),
      ),
    );
  }
}