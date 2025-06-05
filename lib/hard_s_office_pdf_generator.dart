// pdf_generator.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
// import 'package:path_provider/path_provider.dart';
import 'dart:io';
const PdfPageFormat folio = PdfPageFormat(8.5 * PdfPageFormat.inch, 13 * PdfPageFormat.inch);

class HardSOfficePdfGenerator {
  final String departmentName;
  final String areaName;
  final String personName;
  final String formattedDate;
  final double senbetsu1Score;
  final double seiton2Score;
  final double seiso3Score;
  final double seiketsu4Score;
  final double shitsuke5Score;
  final double jishuku6Score;
  final double anzen7Score;
  final double taikekasuru8Score;
  final double totalScore;
  final double maxPossibleScore;
  final double maxTotalScore;
  final double pointsPerQuestion;
  final List<Map<String, dynamic>> questions;
  final String auditType;
  final String auditPeriod;
  final List<String> teamMembers;

  HardSOfficePdfGenerator({
    required this.departmentName,
    required this.areaName,
    required this.personName,
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
    required this.totalScore,
    required this.maxPossibleScore,
    required this.maxTotalScore,
    required this.pointsPerQuestion,
    required this.auditType,
    required this.auditPeriod,
    required this.teamMembers,
  });

  // Method to group questions by category
  List<pw.Page> _buildImagesPages(pw.ThemeData theme, Uint8List logoImage) {
    final questionsWithImages =
        questions
            .where(
              (q) =>
                  q["imagePaths"] != null &&
                  (q["imagePaths"] as List).isNotEmpty,
            )
            .toList();

    final pages = <pw.Page>[];
    final imageRows = <pw.TableRow>[];

    // Create table header row
    final headerRow = pw.TableRow(
      decoration: pw.BoxDecoration(color: PdfColors.grey200),
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8.0),
          child: pw.Text(
            'Image Code',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8.0),
          child: pw.Text(
            'Image',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            textAlign: pw.TextAlign.center,
          ),
        ),
      ],
    );

    // Generate all image rows first
    for (var question in questionsWithImages) {
      final imagePaths = question["imagePaths"] as List;
      for (var imagePath in imagePaths) {
        imageRows.add(
          pw.TableRow(
            verticalAlignment: pw.TableCellVerticalAlignment.middle,
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8.0),
                child: pw.Text(
                  'I-${questions.indexOf(question) + 1}',
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Container(
                height: 350, // Fixed height for each image row
                child: pw.Image(
                  pw.MemoryImage(File(imagePath).readAsBytesSync()),
                  fit: pw.BoxFit.contain,
                ),
              ),
            ],
          ),
        );
      }
    }

    // Now paginate the rows
    const maxRowsPerPage = 2; // Adjust based on your needs
    for (var i = 0; i < imageRows.length; i += maxRowsPerPage) {
      final currentRows = imageRows.sublist(
        i,
        i + maxRowsPerPage > imageRows.length
            ? imageRows.length
            : i + maxRowsPerPage,
      );

      pages.add(
        pw.Page(
          margin: const pw.EdgeInsets.fromLTRB(30, 10, 30, 20),
          pageFormat: folio,
          build: (pw.Context context) {
            return pw.Theme(
              data: theme,
              child: pw.Column(
                children: [
                  // Header (only on first page)
                  if (i == 0) ...[
                    pw.Container(
                      alignment: pw.Alignment.center,
                      child: pw.Column(
                        children: [
                          pw.Center(
                            child: pw.Image(
                              pw.MemoryImage(logoImage),
                              height: 80,
                              width: 80,
                            ),
                          ),
                          pw.Text(
                            'Republic of the Philippines\nPROVINCE OF PANGASINAN\nLingayen',
                            style: pw.TextStyle(fontSize: 14),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 15),
                          pw.Text(
                            '8S Audit - Attached Images',
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                          pw.SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ] else ...[
                    pw.SizedBox(height: 20),
                  ],

                  // Table with current page's rows
                  pw.Table(
                    border: pw.TableBorder.all(),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(1),
                      1: const pw.FlexColumnWidth(3),
                    },
                    children: [headerRow, ...currentRows],
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    return pages;
  }

  Map<String, List<Map<String, dynamic>>> _groupQuestionsByCategory() {
    Map<String, List<Map<String, dynamic>>> groupedQuestions = {};

    for (var question in questions) {
      String category = question["category"]?.toString() ?? "Uncategorized";
      if (category.isEmpty) category = "Uncategorized";

      if (!groupedQuestions.containsKey(category)) {
        groupedQuestions[category] = [];
      }
      groupedQuestions[category]!.add(question);
    }

    return groupedQuestions;
  }

  // Method to calculate the total score for a category
  double _calculateCategoryTotalScore(
    List<Map<String, dynamic>> questionsInCategory,
  ) {
    double totalCategoryScore = 0.0;
    for (var question in questionsInCategory) {
      if (question["answer"] == "No") {
        totalCategoryScore += pointsPerQuestion;
      }
    }
    return totalCategoryScore;
  }

  Future<Directory?> _getPublicDownloadsDirectory() async {
    if (!Platform.isAndroid) {
      return null; // Only support Android
    }

    // Define the path to the "Brum PDF Files" folder inside Downloads
    const String downloadsPath = '/storage/emulated/0/Download/Brum PDF Files';
    final Directory brumPdfDir = Directory(downloadsPath);

    // Create the directory if it doesn't exist
    if (!await brumPdfDir.exists()) {
      await brumPdfDir.create(recursive: true);
    }

    return brumPdfDir;
  }

  // Method to generate and share PDF
  Future<void> generateAndSharePdf() async {
    try {
      final pdf = pw.Document();

      final theme = pw.ThemeData.withFont(
        base: pw.Font.times(),
        bold: pw.Font.timesBold(),
      );

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

      final image1 =
          (await rootBundle.load(
            'lib/assets/fonts/pangasinan_logo.png',
          )).buffer.asUint8List();

      pdf.addPage(
        pw.Page(
          margin: pw.EdgeInsets.fromLTRB(30, 10, 30, 3),
          pageFormat: folio,
          build: (pw.Context context) {
            return pw.Stack(
              children: [
                pw.Theme(
                  // Set the default font for all text in this theme
                  data: theme,

                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Container(
                        alignment: pw.Alignment.center,
                        child: pw.Column(
                          children: [
                            pw.Center(
                              child: pw.Image(
                                pw.MemoryImage(image1),
                                height: 80,
                                width: 80,
                              ),
                            ),
                            pw.Text(
                              'Republic of the Philippines\nPROVINCE OF PANGASINAN\nLingayen',
                              style: pw.TextStyle(fontSize: 14),
                              textAlign: pw.TextAlign.center,
                            ),

                            pw.SizedBox(height: 15),
                            pw.Text(
                              '8S of Good Housekeeping Checklist - HARD S OFFICE',
                              style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                            pw.SizedBox(height: 10),
                          ],
                        ),
                      ),

                      pw.Container(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Column(
                          children: [
                            pw.Text(
                              'Department Name:  $departmentName',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      pw.Container(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Column(
                          children: [
                            pw.Text(
                              'Area Name:  $areaName',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      pw.Container(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Column(
                          children: [
                            pw.Text(
                              'Team Leader:  $personName',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      pw.Container(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Column(
                          children: [
                            pw.Text(
                              'Team Members:',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                            ...teamMembers
                                .map(
                                  (member) => pw.Text(
                                    '- $member',
                                    style: const pw.TextStyle(fontSize: 14),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                )
                                .toList(),
                          ],
                        ),
                      ),

                      pw.Container(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Column(
                          children: [
                            pw.Text(
                              'Audit Period:  $auditPeriod',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      pw.Container(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Column(
                          children: [
                            pw.Text(
                              'Date Audited:  $formattedDate',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                              textAlign: pw.TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Table(
                        border: pw.TableBorder.all(),
                        columnWidths: {
                          0: const pw.FlexColumnWidth(
                            3,
                          ), // Wider for category name
                          1: const pw.FlexColumnWidth(1), // Narrower for score
                        },
                        children: [
                          // Table Header
                          pw.TableRow(
                            children: [
                              pw.Container(
                                padding: const pw.EdgeInsets.all(12.0),
                                child: pw.Text(
                                  'Category',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                              pw.Container(
                                padding: const pw.EdgeInsets.all(12.0),
                                child: pw.Text(
                                  'Score',
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                            ],
                          ),

                          ...categoryScores.entries.map((entry) {
                            return pw.TableRow(
                              children: [
                                pw.Container(
                                  padding: const pw.EdgeInsets.all(12.0),
                                  child: pw.Text(
                                    entry.key, // Category name
                                    style: pw.TextStyle(fontSize: 14),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                ),
                                pw.Container(
                                  padding: const pw.EdgeInsets.all(12.0),
                                  child: pw.Text(
                                    entry.value.toStringAsFixed(2), // Score
                                    style: pw.TextStyle(fontSize: 14),

                                    textAlign: pw.TextAlign.center,
                                  ),
                                ),
                              ],
                            );
                          }).toList(),

                          pw.TableRow(
                            children: [
                              pw.Container(
                                padding: const pw.EdgeInsets.all(12.0),
                                child: pw.Text(
                                  'Total', // Score
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),

                              pw.Container(
                                padding: const pw.EdgeInsets.all(12.0),
                                child: pw.Text(
                                  '${totalScore.toStringAsFixed(2)} / ${maxTotalScore.toStringAsFixed(0)}', // Score
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      pw.SizedBox(height: 60),
                      pw.Expanded(
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Prepared by:',
                                  textAlign: pw.TextAlign.left,
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),

                                pw.SizedBox(height: 30),
                                pw.Text(
                                  '________________________',
                                  textAlign: pw.TextAlign.center,
                                ),
                                pw.Text(
                                  'Signature over printed name',
                                  textAlign: pw.TextAlign.center,
                                ),
                              ],
                            ),

                            // Noted by section
                            pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  'Noted by:',
                                  textAlign: pw.TextAlign.left,
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.SizedBox(height: 30),

                                pw.Text('________________________'),
                                pw.Text(
                                  ' (Supervisor / Team leader)',
                                  textAlign: pw.TextAlign.center,
                                ),
                                pw.Text('Signature over printed name'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                pw.Positioned(
                  bottom: 1, // Now touches the page edge
                  left: 0,
                  right: 0,

                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Container(
                        height: 15, // Matches reduced bottom margin
                        alignment: pw.Alignment.bottomLeft,
                        child: pw.Text(
                          'Generated by Brum apk',
                          style: const pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.black,
                          ),
                        ),
                      ),

                      pw.Container(
                        height: 15, // Matches reduced bottom margin
                        alignment: pw.Alignment.bottomCenter,
                        child: pw.Text(
                          '8s of Good Housekeeping Checklist',
                          style: const pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.black,
                          ),
                        ),
                      ),

                      pw.Container(
                        height: 15, // Matches reduced bottom margin
                        alignment: pw.Alignment.bottomRight,
                        child: pw.Text(
                          'ED|KC|EV',
                          style: const pw.TextStyle(
                            fontSize: 8,
                            color: PdfColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Group questions by category
      final groupedQuestions = _groupQuestionsByCategory();

      // Add pages for each category
      groupedQuestions.forEach((category, questionsInCategory) {
        double categoryTotalScore = _calculateCategoryTotalScore(
          questionsInCategory,
        );

        pdf.addPage(
          pw.Page(
            margin: pw.EdgeInsets.fromLTRB(30, 10, 30, 0),
            pageFormat: folio,
            build: (pw.Context context) {
              return pw.Theme(
                // Set the default font for all text in this theme
                data: theme,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Container(
                      alignment: pw.Alignment.center,
                      child: pw.Column(
                        children: [
                          pw.Center(
                            child: pw.Image(
                              pw.MemoryImage(image1),
                              height: 80,
                              width: 80,
                            ),
                          ),
                          pw.Text(
                            'Republic of the Philippines\nPROVINCE OF PANGASINAN\nLingayen',
                            style: pw.TextStyle(fontSize: 14),
                            textAlign: pw.TextAlign.center,
                          ),

                          pw.SizedBox(height: 15), // Add spacing

                          pw.Row(
                            children: [
                              pw.Expanded(
                                child: pw.Text(
                                  '8S of Good Housekeeping Checklist',
                                  style: pw.TextStyle(
                                    fontSize: 18,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                  textAlign: pw.TextAlign.center,
                                ),
                              ),
                              pw.Text(
                                'Hard S',
                                style: pw.TextStyle(
                                  fontSize: 18,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                                textAlign: pw.TextAlign.right,
                              ),
                            ],
                          ),

                          pw.SizedBox(height: 10), // Add spacing
                        ],
                      ),
                    ),

                    // Category Name (Merged Row)
                    pw.Table(
                      border: pw.TableBorder.all(),
                      children: [
                        pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(12.0),
                              child: pw.Center(
                                child: pw.Text(
                                  category,
                                  style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Table with ID, Particular, Question, and Points as columns
                    pw.Table(
                      defaultVerticalAlignment:
                          pw.TableCellVerticalAlignment.middle,
                      border: pw.TableBorder.all(),
                      columnWidths: {
                        0: const pw.FlexColumnWidth(
                          1,
                        ), // Equal width for all columns
                        1: const pw.FlexColumnWidth(4), // Wider for Particular
                        2: const pw.FlexColumnWidth(5), // Wider for Question
                        3: const pw.FlexColumnWidth(
                          2,
                        ), // Equal width for Points
                        4: const pw.FlexColumnWidth(
                          2,
                        ), // Equal width for Points
                      },
                      children: [
                        // Table Headers
                        pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4.0),
                              child: pw.Text(
                                'No.',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4.0),
                              child: pw.Text(
                                'Particular',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4.0),
                              child: pw.Text(
                                'Policies/Guidelines',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4.0),
                              child: pw.Text(
                                'Demerit Points',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4.0),
                              child: pw.Text(
                                'Remarks',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ],
                        ),

                        // Table Rows for Questions
                        ...questionsInCategory.map((question) {
                          return pw.TableRow(
                            children: [
                              pw.Container(
                                padding: const pw.EdgeInsets.all(4.0),
                                child: pw.Text(
                                  question["no"] ?? "N/A",
                                  style: pw.TextStyle(fontSize: 10),
                                  textAlign: pw.TextAlign.center,
                                ),
                                alignment: pw.Alignment.center,
                              ),

                              pw.Expanded(
                                child: pw.Container(
                                  alignment: pw.Alignment.centerLeft,
                                  padding: const pw.EdgeInsets.all(4),
                                  child: pw.Text(
                                    question["particular"] ?? "No particular",
                                    style: pw.TextStyle(fontSize: 10),
                                    textAlign: pw.TextAlign.left,
                                  ),
                                ),
                              ),

                              pw.Expanded(
                                child: pw.Container(
                                  alignment: pw.Alignment.center,
                                  padding: const pw.EdgeInsets.all(8),
                                  child: pw.Text(
                                    question["question"] ?? "No question",
                                    style: pw.TextStyle(fontSize: 10),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                ),
                              ),

                              pw.Container(
                                padding: const pw.EdgeInsets.all(4.0),

                                child: pw.Text(
                                  question["answer"] == "No"
                                      ? "${pointsPerQuestion.toStringAsFixed(2)}"
                                      : "0",
                                  style: pw.TextStyle(fontSize: 10),
                                  textAlign: pw.TextAlign.center,
                                ),
                                alignment: pw.Alignment.center,
                              ),

                              pw.Container(
                                padding: const pw.EdgeInsets.all(4.0),
                                child: pw.Text(
                                  question["remark"] ?? " ",
                                  style: pw.TextStyle(fontSize: 10),
                                  textAlign: pw.TextAlign.center,
                                ),
                                alignment: pw.Alignment.center,
                              ),
                            ],
                          );
                        }).toList(),

                        // Add a row for the total score of the category
                        pw.TableRow(
                          children: [
                            pw.Container(
                              padding: const pw.EdgeInsets.all(4.0),
                              child: pw.Text(
                                'Total',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                              alignment: pw.Alignment.center,
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.all(4.0),
                              child: pw.Text(
                                '',
                                style: pw.TextStyle(fontSize: 10),
                                textAlign: pw.TextAlign.center,
                              ),
                              alignment: pw.Alignment.center,
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.all(4.0),
                              child: pw.Text(
                                '',
                                style: pw.TextStyle(fontSize: 10),
                                textAlign: pw.TextAlign.center,
                              ),
                              alignment: pw.Alignment.center,
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.all(4.0),
                              child: pw.Text(
                                categoryTotalScore.toStringAsFixed(2),
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 10,
                                ),
                                textAlign: pw.TextAlign.center,
                              ),
                              alignment: pw.Alignment.center,
                            ),
                            pw.Container(
                              padding: const pw.EdgeInsets.all(4.0),
                              child: pw.Text(
                                '',
                                style: pw.TextStyle(fontSize: 10),
                                textAlign: pw.TextAlign.center,
                              ),
                              alignment: pw.Alignment.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      });

      // Change it to:
      if (questions.any(
        (q) => q["imagePaths"] != null && (q["imagePaths"] as List).isNotEmpty,
      )) {
        final imagePages = _buildImagesPages(theme, image1);
        for (final page in imagePages) {
          pdf.addPage(page); // Add each page one by one
        }
      }
      final directory = await _getPublicDownloadsDirectory();
      if (directory == null) {
        throw Exception("Could not access Downloads directory");
      }

      final filePath = "${directory.path}/${_getFileName()}";
      print("PDF file path: $filePath");
      final file = File(filePath);

      await file.writeAsBytes(await pdf.save());

      // Share the PDF file
      if (await file.exists()) {
        await Share.shareFiles([
          file.path,
        ], text: '8S of Good Housekeeping Checklist');
      } else {
        print("PDF file does not exist.");
      }
    } catch (e) {
      print("Error generating or sharing PDF: $e");
    }
  }

  // Method to generate file name
  String _getFileName() {
    DateTime dateTime = DateFormat('yyyy-MM-dd hh:mm a').parse(formattedDate);
    final String newFormattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
    return "HARD_S-Office_${newFormattedDate}_${personName}-${departmentName}-${areaName}.pdf";
  }
}
