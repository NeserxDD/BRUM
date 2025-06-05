// result_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:project1/checklist.dart';
import 'package:project1/history.dart';

import 'pdf_generator.dart'; // Import the new file
import 'hard_s_hospital_pdf_generator.dart';
import 'hard_s_office_pdf_generator.dart';
class ResultPage extends StatelessWidget {
  final String departmentName;
  final String areaName;
  final String personName;
  final double totalScore;
  final double maxPossibleScore;
  final String formattedDate;
  final double senbetsu1Score;
  final double seiton2Score;
  final double seiso3Score;
  final double seiketsu4Score;
  final double shitsuke5Score;
  final double jishuku6Score;
  final double anzen7Score;
  final double taikekasuru8Score;
  final double pointsPerQuestion;
  final double maxTotalScore;
  

  final String auditType;
  final String auditPeriod;
  final List<String> teamMembers;

  final List<Map<String, dynamic>> questions;
  final int? checklistResultId; // Add this line

  const ResultPage({
    required this.departmentName,
    required this.areaName,
    required this.personName,
    required this.totalScore,
    required this.maxPossibleScore,
    required this.questions,
    required this.formattedDate,
    required this.senbetsu1Score,
    required this.seiton2Score,
    required this.seiso3Score,
    required this.seiketsu4Score,
    required this.shitsuke5Score,
    required this.jishuku6Score,
    required this.anzen7Score,
    required this.taikekasuru8Score,
    required this.pointsPerQuestion,
    required this.maxTotalScore,
    required this.auditPeriod,
    required this.auditType,
    required this.teamMembers,
    this.checklistResultId, // Add this
    Key? key,
  }) : super(key: key);


Future<void> _generateAndSharePDF(BuildContext context) async {
  // Show loading indicator
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(width: 16),
          const Text("Generating PDF..."),
        ],
      ),
      duration: const Duration(seconds: 2),
    ),
  );

  try {
    // Choose the appropriate PDF generator
    if (auditType == 'Hard S Office') {
      await HardSOfficePdfGenerator(
          departmentName: departmentName,
          areaName: areaName,
          personName: personName,
          questions: questions,
          formattedDate: formattedDate,
          senbetsu1Score: senbetsu1Score,
          seiton2Score: seiton2Score,
          seiso3Score: seiso3Score,
          seiketsu4Score: seiketsu4Score,
          shitsuke5Score: shitsuke5Score,
          jishuku6Score: jishuku6Score,
          anzen7Score: anzen7Score,
          taikekasuru8Score: taikekasuru8Score,
          totalScore: totalScore,
          maxPossibleScore: maxPossibleScore,
          pointsPerQuestion: pointsPerQuestion,
          maxTotalScore: maxTotalScore,
          auditType: auditType,
          auditPeriod: auditPeriod,
          teamMembers: teamMembers,
       
      ).generateAndSharePdf();
    } 
   else if (auditType == 'Hard S Hospital') {
      await HardSHospitalPdfGenerator(
          departmentName: departmentName,
          areaName: areaName,
          personName: personName,
          questions: questions,
          formattedDate: formattedDate,
          senbetsu1Score: senbetsu1Score,
          seiton2Score: seiton2Score,
          seiso3Score: seiso3Score,
          seiketsu4Score: seiketsu4Score,
          shitsuke5Score: shitsuke5Score,
          jishuku6Score: jishuku6Score,
          anzen7Score: anzen7Score,
          taikekasuru8Score: taikekasuru8Score,
          totalScore: totalScore,
          maxPossibleScore: maxPossibleScore,
          pointsPerQuestion: pointsPerQuestion,
          maxTotalScore: maxTotalScore,
          auditType: auditType,
          auditPeriod: auditPeriod,
          teamMembers: teamMembers,
      ).generateAndSharePdf();
    } 
    else if (auditType == 'Soft S') {
      await PdfGenerator(
          departmentName: departmentName,
          areaName: areaName,
          personName: personName,
          questions: questions,
          formattedDate: formattedDate,
          senbetsu1Score: senbetsu1Score,
          seiton2Score: seiton2Score,
          seiso3Score: seiso3Score,
          seiketsu4Score: seiketsu4Score,
          shitsuke5Score: shitsuke5Score,
          jishuku6Score: jishuku6Score,
          anzen7Score: anzen7Score,
          taikekasuru8Score: taikekasuru8Score,
          totalScore: totalScore,
          maxPossibleScore: maxPossibleScore,
          pointsPerQuestion: pointsPerQuestion,
          maxTotalScore: maxTotalScore,
          auditType: auditType,
          auditPeriod: auditPeriod,
          teamMembers: teamMembers,

      ).generateAndSharePdf();
    }

    else{

     ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Could not identify the audit type"),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
    }

    // Show success
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("PDF successfully generated!"),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: ${e.toString()}"),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
    debugPrint("PDF Error: $e");
  }
}

 Map<String, Map<String, List<Map<String, dynamic>>>> _groupQuestionsByCategoryAndParticular() {
  Map<String, Map<String, List<Map<String, dynamic>>>> groupedQuestions = {};

  for (var question in questions) {
    String category = question["category"] ?? "Uncategorized";
    String particular = question["particular"] ?? "No Particular";

    if (!groupedQuestions.containsKey(category)) {
      groupedQuestions[category] = {};
    }

    if (!groupedQuestions[category]!.containsKey(particular)) {
      groupedQuestions[category]![particular] = [];
    }

    groupedQuestions[category]![particular]!.add(question);
  }

  return groupedQuestions;
}



  @override
  Widget build(BuildContext context) {
    final Map<String, double> categoryScores = {
      'SORT or "Senbetsu or Seiri" /Pagliligpit': senbetsu1Score,
      'Set (In Order) Or "Seiton" / Pagsasa-Ayos': seiton2Score,
      'Shine or "Seiso" / Paglilinis': seiso3Score,
      'Standardize or "Seiketsu" / Pamantayan': seiketsu4Score,
      'Sustain or "Shitsuke" / Disiplina': shitsuke5Score,
      'Self-Discipline or "Jishuku" / Pagpipigil sa Sarili': jishuku6Score,
      'Safety or "Anzen" / Kaligtasan': anzen7Score,
      'Systematize or "Taikekasuru" / Sistema': taikekasuru8Score,
    };

    // Group questions by category and particular
    final groupedQuestions = _groupQuestionsByCategoryAndParticular();



 Future<bool> _handleBack() async {
    Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HistoryPage()),
    );
    return false; // Prevent default back behavior
  }

return WillPopScope(

  onWillPop: _handleBack,
    child:  Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 45, 103, 161),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Audit Summary',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: ListView(
        children: [
          Container(
            alignment: Alignment.center,

            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text(
              'Result',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display department, area, person, date, and scores
                Text(
                  'Audit Type: $auditType',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),                
                
                Text(
                  'Department: $departmentName',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                if (areaName.isNotEmpty) ...[
                Text(
                  'Area: $areaName',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                 ],

                Text(
                  'Audit Period: $auditPeriod',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                
                Text(
                  'Team Leader: $personName',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              SizedBox(height: 4),
                Text(
                  'Team Members:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                  ...teamMembers
                                .map(
                                  (member) => Text(
                                    '• $member',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                )
                                .toList(),
                SizedBox(height: 4),
                Text(
                  'Date: $formattedDate',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),

                // Display category scores in a table
                Table(
                  border: TableBorder.all(),
                  columnWidths: {0: FlexColumnWidth(2), 1: FlexColumnWidth(1)},
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.blue[100]),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Category",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Score",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    ...categoryScores.entries.map((entry) {
                      return TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              entry.key,
                              style: TextStyle(fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              entry.value.toStringAsFixed(2),
                              style: TextStyle(fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    }),
                    TableRow(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Total',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            '${totalScore.toStringAsFixed(2)} / ${maxTotalScore.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Display questions grouped by category and particular
                ...groupedQuestions.entries.map((categoryEntry) {
                  String category = categoryEntry.key;
                  Map<String, List<Map<String, dynamic>>> particulars =
                      categoryEntry.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      ...particulars.entries.map((particularEntry) {
                        String particular = particularEntry.key;
                        List<Map<String, dynamic>> questionsInParticular =
                            particularEntry.value;

                        return Card(
                          color: Color.fromARGB(255, 255, 228, 206),
                          margin: EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  particular,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                Divider(thickness: 1.5),

                             ...questionsInParticular.map((question) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 8),
      Text(
        question["question"] ?? "No question",
        style: TextStyle(fontSize: 16),
      ),
      SizedBox(height: 8),
      Text(
        'Answer: ${question["answer"] ?? "No answer"}',
        style: TextStyle(fontSize: 16),
      ),
      Text(
        'Points: ${question["answer"] == "Yes" ? pointsPerQuestion.toStringAsFixed(2) : 0}',
        style: TextStyle(fontSize: 16),
      ),
      Text(
        'Remark: ${question["remark"] ?? " "}',
        style: TextStyle(fontSize: 16),
      ),
      
      // Add this new section for images
      if (question["imagePaths"] != null && (question["imagePaths"] as List).isNotEmpty) ...[
        SizedBox(height: 16),
        Text(
          'Attached Images:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
        Table(
          border: TableBorder.all(),
          columnWidths: {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(3),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey[200]),
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Image Code",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Image",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            ...List<TableRow>.generate(
              (question["imagePaths"] as List).length,
              (index) => TableRow(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'I-${questions.indexOf(question)+1}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Image.file(
                      File((question["imagePaths"] as List)[index]),
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ],
  );
}).toList(),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),

floatingActionButton: Column(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    FloatingActionButton(
      onPressed: () =>   _generateAndSharePDF(context),
      backgroundColor: Color.fromARGB(255, 45, 103, 161),
      child: Icon(Icons.picture_as_pdf, color: Colors.white),
    ),
    SizedBox(height: 18),
FloatingActionButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChecklistScreen(
          departmentName: departmentName,
          areaName: areaName,
          personName: personName,
          auditType: auditType,
          teamMembers: teamMembers,
          auditPeriod: auditPeriod,
          existingQuestions: questions, // Pass the current questions
          checklistResultId: checklistResultId, // Pass the ID if available
          existingDate: formattedDate, 
    
          
        ),
      ),
    );
  },
  backgroundColor: Color.fromARGB(255, 45, 103, 161),
  child: Icon(Icons.edit, color: Colors.white),
  heroTag: 'edit',
),
    SizedBox(height: 18),
    FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HistoryPage()),
        );
      },
      backgroundColor: Color.fromARGB(255, 45, 103, 161),
      child: Icon(Icons.home, color: Colors.white),
      heroTag: 'home',
    ),
  ],
),
    ),
    );
  }
}
