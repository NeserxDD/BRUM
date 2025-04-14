import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'result.dart';
import 'package:intl/intl.dart';
import 'route_observer.dart';
import 'dart:convert';
// Import all question files
import 'question.dart' as softS;
import 'questionHO.dart' as hardSOffice;
import 'questionHH.dart' as hardSHospital;

// Dynamic imports based on audit type
List<Map<String, String>> getQuestions(String auditType) {
  switch (auditType) {
    case 'Hard S Office':
      return List.from(hardSOffice.questions);
    case 'Hard S Hospital':
      return List.from(hardSHospital.questions);
    case 'Soft S':
    default:
      return List.from(softS.questions);
  }
}



class ChecklistScreen extends StatefulWidget {
  final String departmentName;
  final String areaName;
  final String personName;
  final String auditType;
  final String auditPeriod;
  final List<String> teamMembers;
  final List<Map<String, String>>? existingQuestions; 
  final int? checklistResultId;
    final String? existingDate; 
  

  const ChecklistScreen({
    required this.departmentName,
    required this.areaName,
    required this.personName,
    required this.auditType,
    required this.teamMembers,
    required this.auditPeriod,
    this.existingQuestions,
    this.checklistResultId,
     this.existingDate, 
  
    Key? key,
  }) : super(key: key);

  @override
  _ChecklistScreenState createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> with RouteAware {
  late List<Map<String, String>> questions;
  double totalScore = 0.0;
  double maxPossibleScore = 0;
  int answeredQuestions = 0;
  double progressPercentage = 0.0;
  double senbetsu1Score = 0.0;
  double seiton2Score = 0.0;
  double seiso3Score = 0.0;
  double seiketsu4Score = 0.0;
  double shitsuke5Score = 0.0;
  double jishuku6Score = 0.0;
  double anzen7Score = 0.0;
  double taikekasuru8Score = 0.0;
  double pointsPerQuestion = 0.0;
  double maxTotalScore = 0.0;


  Map<String, List<String>> questionImages = {};

  // Cache for grouped questions to avoid rebuilding on every frame
  late Map<String, Map<String, List<Map<String, String>>>> _groupedQuestions;
  bool _needsRebuild = true;

  @override
  void initState() {
    super.initState();
    // Initialize questions based on audit type
    questions = widget.existingQuestions ?? getQuestions(widget.auditType);
    pointsPerQuestion = 100 / questions.length;
    maxTotalScore = pointsPerQuestion * questions.length;

    if (widget.existingQuestions == null) {
      _resetAnswers();
    } else {
      _calculateScore();
      _calculateProgress();
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when the route is popped and we're returning to it
    _resetAnswers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text("Exit Audit"),
                backgroundColor: Color.fromARGB(255, 221, 231, 241),
                content: const Text(
                  "Are you sure you want to exit? Your progress will be lost.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      "Exit",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
        )) ??
        false;
  }

  void _updateAnswer(int index, String answer, {String? remark}) {
    setState(() {
      questions[index]["answer"] = answer;
      if (remark != null) {
        questions[index]["remark"] = remark;
      }
      _calculateScore();
      _calculateProgress();
      _needsRebuild = true;
    });
  }

  void _calculateScore() {
    totalScore = 0.0;
    maxPossibleScore = 0.0;
    senbetsu1Score = 0.0;
    seiton2Score = 0.0;
    seiso3Score = 0.0;
    seiketsu4Score = 0.0;
    shitsuke5Score = 0.0;
    jishuku6Score = 0.0;
    anzen7Score = 0.0;
    taikekasuru8Score = 0.0;

    for (var question in questions) {
      String category = question["category"]!;
      if (question["answer"] == "Yes") {
        totalScore += pointsPerQuestion;
        maxPossibleScore += pointsPerQuestion;

        // Update category scores
        if (category.contains("Senbetsu")) {
          senbetsu1Score += pointsPerQuestion;
        } else if (category.contains("Seiton")) {
          seiton2Score += pointsPerQuestion;
        } else if (category.contains("Seiso")) {
          seiso3Score += pointsPerQuestion;
        } else if (category.contains("Seiketsu")) {
          seiketsu4Score += pointsPerQuestion;
        } else if (category.contains("Shitsuke")) {
          shitsuke5Score += pointsPerQuestion;
        } else if (category.contains("Jishuku")) {
          jishuku6Score += pointsPerQuestion;
        } else if (category.contains("Anzen")) {
          anzen7Score += pointsPerQuestion;
        } else if (category.contains("Taikekasuru")) {
          taikekasuru8Score += pointsPerQuestion;
        }
      } else if (question["answer"] == "No") {
        maxPossibleScore += pointsPerQuestion;
      }
    }
  }

  void _calculateProgress() {
    int answered = 0;
    for (var question in questions) {
      if (question["answer"] == "Yes" ||
          question["answer"] == "No" ||
          question["answer"] == "Not Applicable") {
        answered++;
      }
    }
    setState(() {
      answeredQuestions = answered;
      progressPercentage = (answeredQuestions / questions.length) * 100;
    });
  }

  Map<String, Map<String, List<Map<String, String>>>>
  _groupQuestionsByCategoryAndParticular() {
    if (!_needsRebuild) {
      return _groupedQuestions;
    }

    final groupedQuestions = <String, Map<String, List<Map<String, String>>>>{};

    for (var question in questions) {
      final category = question["category"]!;
      final particular = question["particular"]!;

      groupedQuestions.putIfAbsent(category, () => {});
      groupedQuestions[category]!.putIfAbsent(particular, () => []);
      groupedQuestions[category]![particular]!.add(question);
    }

    _groupedQuestions = groupedQuestions;
    _needsRebuild = false;
    return groupedQuestions;
  }

  Future<void> _saveData() async {

  final now = DateTime.now();
final String formattedDate = widget.existingDate ?? DateFormat('yyyy-MM-dd hh:mm a').format(now);
    final dbHelper = DatabaseHelper();

    final teamMembersJson = jsonEncode(widget.teamMembers);
    int checklistResultId;

    if (widget.checklistResultId != null) {
      // Update existing audit
      checklistResultId = widget.checklistResultId!;
      await dbHelper.updateChecklistResult(
        id: checklistResultId,
        departmentName: widget.departmentName,
        areaName: widget.areaName,
        personName: widget.personName,
        totalScore: totalScore,
        maxPossibleScore: maxPossibleScore,
        formattedDate: formattedDate,
        senbetsu1Score: senbetsu1Score,
        seiton2Score: seiton2Score,
        seiso3Score: seiso3Score,
        seiketsu4Score: seiketsu4Score,
        shitsuke5Score: shitsuke5Score,
        jishuku6Score: jishuku6Score,
        anzen7Score: anzen7Score,
        taikekasuru8Score: taikekasuru8Score,
        pointsPerQuestion: pointsPerQuestion,
        maxTotalScore: maxTotalScore,
        auditType: widget.auditType,
        auditPeriod: widget.auditPeriod,
        teamMembers: teamMembersJson,
        
      );

      // Delete old question details
      await dbHelper.deleteQuestionDetails(checklistResultId);
    } else {
      // Create new audit
      checklistResultId = await dbHelper.insertChecklistResult(
        
        departmentName: widget.departmentName,
        areaName: widget.areaName,
        personName: widget.personName,
        totalScore: totalScore,
        maxPossibleScore: maxPossibleScore,
        formattedDate: formattedDate,
        senbetsu1Score: senbetsu1Score,
        seiton2Score: seiton2Score,
        seiso3Score: seiso3Score,
        seiketsu4Score: seiketsu4Score,
        shitsuke5Score: shitsuke5Score,
        jishuku6Score: jishuku6Score,
        anzen7Score: anzen7Score,
        taikekasuru8Score: taikekasuru8Score,
        pointsPerQuestion: pointsPerQuestion,
        maxTotalScore: maxTotalScore,
        auditType: widget.auditType,
        auditPeriod: widget.auditPeriod,
        teamMembers: teamMembersJson,
      );
    }

    // Save each question's details
    for (var question in questions) {
      await dbHelper.insertQuestionDetails(
        checklistResultId: checklistResultId,
        no: question["no"]!,
        particular: question["particular"]!,
        question: question["question"]!,
        category: question["category"]!,
        answer: question["answer"] ?? "Not Answered",
        remark: question["remark"] ?? "",
      );
    }

    //result page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ResultPage(
              departmentName: widget.departmentName,
              areaName: widget.areaName,
              personName: widget.personName,
              totalScore: totalScore,
              maxPossibleScore: maxPossibleScore,
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
              pointsPerQuestion: pointsPerQuestion,
              maxTotalScore: maxTotalScore,
              auditType: widget.auditType,
              auditPeriod: widget.auditPeriod,
              teamMembers: widget.teamMembers,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'Current fontFamily: ${DefaultTextStyle.of(context).style.fontFamily}',
    );
    final groupedQuestions = _groupQuestionsByCategoryAndParticular();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 45, 103, 161),
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            '${widget.auditType} Audit Questions',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    expandedHeight: 200 + (widget.teamMembers.length * 20.0),
                    floating: false,
                    pinned: false,
                    snap: false,
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        padding: const EdgeInsets.all(4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${widget.auditType} Checklist',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),

                            Text(
                              'Audit Type: ${widget.auditType}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Text(
                              'Department: ${widget.departmentName}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),
                            if (widget.areaName.isNotEmpty) ...[
                              Text(
                                'Area: ${widget.areaName}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                            ],

                            Text(
                              'Audit Period: ${widget.auditPeriod}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),

                            Text(
                              'Team Leader: ${widget.personName}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Team Members:',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ...widget.teamMembers
                                .map(
                                  (member) => Text(
                                    '• $member',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                )
                                .toList(),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Checklist Content
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final categoryEntry = groupedQuestions.entries.elementAt(
                        index,
                      );
                      final category = categoryEntry.key;
                      final particulars = categoryEntry.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              category,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ),
                          ...particulars.entries.map((particularEntry) {
                            final particular = particularEntry.key;
                            final questionsInParticular = particularEntry.value;

                            return _QuestionCard(
                              particular: particular,
                              questions: questionsInParticular,
                              onAnswerUpdated: (index, answer, remark) {
                                final globalIndex = questions.indexOf(
                                  questionsInParticular[index],
                                );
                                _updateAnswer(
                                  globalIndex,
                                  answer,
                                  remark: remark,
                                );
                              },
                            );
                          }).toList(),
                        ],
                      );
                    }, childCount: groupedQuestions.entries.length),
                  ),
                ],
              ),
            ),

            // Footer Section
            _FooterSection(
              totalScore: totalScore,
              maxTotalScore: maxTotalScore,
              progressPercentage: progressPercentage,
              answeredQuestions: answeredQuestions,
              totalQuestions: questions.length,
              onSubmitted:
                  answeredQuestions == questions.length ? _saveData : null,
            ),
          ],
        ),
      ),
    );
  }

  void _resetAnswers() {
    setState(() {
      for (var question in questions) {
        question["answer"] = "";
        question["remark"] = "";
      }
      totalScore = 0;
      maxPossibleScore = 0;
      answeredQuestions = 0;
      progressPercentage = 0.0;
      senbetsu1Score = 0.0;
      seiton2Score = 0.0;
      seiso3Score = 0.0;
      seiketsu4Score = 0.0;
      shitsuke5Score = 0.0;
      jishuku6Score = 0.0;
      anzen7Score = 0.0;
      taikekasuru8Score = 0.0;
      _needsRebuild = true;
    });
  }
}

class _QuestionCard extends StatelessWidget {
  final String particular;
  final List<Map<String, String>> questions;
  final Function(int index, String answer, String? remark) onAnswerUpdated;

  const _QuestionCard({
    required this.particular,
    required this.questions,
    required this.onAnswerUpdated,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 255, 234, 206),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              particular,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const Divider(thickness: 1.5),

            // Questions List
            ...questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;

              return _QuestionItem(
                question: question,
                onAnswerUpdated: (answer, remark) {
                  onAnswerUpdated(index, answer, remark);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

class _QuestionItem extends StatefulWidget {
  final Map<String, String> question;
  final Function(String answer, String? remark) onAnswerUpdated;

  const _QuestionItem({
    required this.question,
    required this.onAnswerUpdated,
    Key? key,
  }) : super(key: key);

  @override
  __QuestionItemState createState() => __QuestionItemState();
}

class __QuestionItemState extends State<_QuestionItem> {
  final TextEditingController _remarkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _remarkController.text = widget.question["remark"] ?? "";
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.question["question"]!,
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ChoiceChip(
              label: SizedBox(width: 50, child: Center(child: Text("Yes"))),
              selected: widget.question["answer"] == "Yes",
              onSelected: (selected) {
                widget.onAnswerUpdated("Yes", _remarkController.text);
              },
              selectedColor: Color.fromARGB(255, 200, 228, 255),
              backgroundColor: Color.fromARGB(255, 238, 246, 254),
            ),
            ChoiceChip(
              label: SizedBox(width: 50, child: Center(child: Text("No"))),
              selected: widget.question["answer"] == "No",
              onSelected: (selected) {
                widget.onAnswerUpdated("No", _remarkController.text);
              },
              selectedColor: Color.fromARGB(255, 200, 228, 255),
              backgroundColor: Color.fromARGB(255, 238, 246, 254),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _remarkController,
          cursorColor: Colors.blue[700],
          onTapUpOutside: (event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          decoration: const InputDecoration(
            labelText: 'Remarks',
            labelStyle: TextStyle(color: Colors.black),
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              // Border when NOT focused
              borderSide: BorderSide(color: Color.fromARGB(255, 192, 200, 210)),
            ),
            focusedBorder: OutlineInputBorder(
              // Border when focused
              borderSide: BorderSide(
                color: Color.fromARGB(255, 125, 181, 253),
                width: 2,
              ),
            ),
          ),
          keyboardType: TextInputType.multiline,
          maxLines: null,
          minLines: 1,
          onChanged: (value) {
            widget.onAnswerUpdated(widget.question["answer"] ?? "", value);
          },
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// footer section
class _FooterSection extends StatelessWidget {
  final double totalScore;
  final double maxTotalScore;
  final double progressPercentage;
  final int answeredQuestions;
  final int totalQuestions;
  final VoidCallback? onSubmitted;

  const _FooterSection({
    required this.totalScore,
    required this.maxTotalScore,
    required this.progressPercentage,
    required this.answeredQuestions,
    required this.totalQuestions,
    this.onSubmitted,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            'Total Score: ${totalScore.toStringAsFixed(2)}/${maxTotalScore.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progressPercentage / 100,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color.fromRGBO(58, 137, 240, 0.373),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Questions Remaining: ${totalQuestions - answeredQuestions}',
            style: const TextStyle(
              fontSize: 14,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          if (onSubmitted != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: ElevatedButton(
                onPressed: onSubmitted,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Color.fromARGB(255, 45, 103, 161),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
