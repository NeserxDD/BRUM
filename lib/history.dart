import 'package:flutter/material.dart';
import 'package:project1/new_audit.dart';
import 'database_helper.dart';
import 'result.dart';
import 'route_observer.dart';
import 'dart:convert';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> with RouteAware {
  List<Map<String, dynamic>> checklistResults = [];
  List<Map<String, dynamic>> filteredResults = [];
  final ScrollController _scrollController = ScrollController();
    String? _selectedAuditTypeFilter; // null means "All audits"
  String? _selectedSortFilter; // null means no sorting
  bool _isAppBarCollapsed = false;


  @override
  void initState() {
    super.initState();
    _loadChecklistResults();

    _scrollController.addListener(() {
      setState(() {
        // Check if the app bar is collapsed (scrolled up)
        _isAppBarCollapsed = _scrollController.offset > (125 - kToolbarHeight);
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(
      this,
      ModalRoute.of(context)!,
    ); // Subscribe to route changes
  }

  @override
  void didPopNext() {
    // Called when returning to this page
    _loadChecklistResults();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this); // Unsubscribe to avoid memory leaks
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _showAppInfoDialog() async {
    final manualText = await rootBundle.loadString('lib/assets/manualText.md');

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 800, maxHeight: 550),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text('App Manual'),
                backgroundColor: Color.fromARGB(255, 45, 103, 161),
              ),
              Expanded(
                child: Markdown(
                  data: manualText,
                  padding: EdgeInsets.all(20),
                  styleSheet: MarkdownStyleSheet(
                    h1: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    h2: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    p: TextStyle(fontSize: 16),
                    listBullet: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showDeleteAllConfirmationDialog();
                  },
                  child: Text(
                    'DELETE ALL CHECKLISTS',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteAllConfirmationDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete All'),
        content: Text(
          'Are you sure you want to delete ALL audit records? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Delete All', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.of(context).pop(); // Close the confirmation dialog
              await _deleteAllChecklists(); // Perform the deletion
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllChecklists() async {
    try {
      DatabaseHelper dbHelper = DatabaseHelper();
      await dbHelper.deleteAllChecklistResults();
      _loadChecklistResults(); // Refresh the list
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All audit records have been deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting records: $e')));
    }
  }

  List<String> _parseTeamMembers(dynamic teamMembersData) {
    try {
      if (teamMembersData is String) {
        // Parse JSON string if stored as string
        return List<String>.from(jsonDecode(teamMembersData));
      } else if (teamMembersData is List) {
        // Handle case where it's already a list (shouldn't happen but just in case)
        return List<String>.from(teamMembersData);
      }
    } catch (e) {
      debugPrint("Error parsing teamMembers: $e");
    }
    return []; // Return empty list if parsing fails
  }

  Future<void> _loadChecklistResults() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<Map<String, dynamic>> results = await dbHelper.getChecklistResults();
    setState(() {
      checklistResults = results.reversed.toList();
      _applyFilters();
    });
  }

  void _applyFilters() {
    // First apply audit type filter
    if (_selectedAuditTypeFilter == null) {
      filteredResults = List.from(checklistResults);
    } else {
      filteredResults = checklistResults.where((result) => 
        result['auditType'] == _selectedAuditTypeFilter
      ).toList();
    }

    // Then apply sorting
    if (_selectedSortFilter != null) {
      switch (_selectedSortFilter) {
        case 'Department':
                filteredResults.sort((a, b) {
          final aName = a['departmentName'] as String;
          final bName = b['departmentName'] as String;
          return aName.compareTo(bName);  // ← THIS IS ESSENTIAL
        });
              
          break;
        case 'Highest Score':
          filteredResults.sort((a, b) => (b['totalScore'] as double)
              .compareTo(a['totalScore'] as double));
          break;
        case 'Latest':
          // Since we already reversed the list in _loadChecklistResults,
          // the newest are first by default
          break;
      }
    }
  }
  




  Future<void> _deleteChecklistResult(int id) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    await dbHelper.deleteChecklistResult(id);
    _loadChecklistResults();
  }

  void _showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Audit'),
          backgroundColor: Color.fromARGB(255, 221, 231, 241),
          content: Text('Are you sure you want to delete this audit?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await _deleteChecklistResult(id); // Delete the checklist result
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

DropdownMenuItem<String> _buildDropdownItem(String? value, String text) {
  return DropdownMenuItem(
    value: value,
    child: Container(
      constraints: BoxConstraints(maxWidth: 120), // Constrain item width
      child: Text(
        text,
        style: TextStyle(fontSize: 10),
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: Color.fromARGB(255, 45, 103, 161),
            expandedHeight: 125,
            floating: false,
            pinned: true,
            snap: false,
            // stretch: true,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(bottom: 30),
              title: _isAppBarCollapsed
                  ? Transform.translate(
                      offset: const Offset(10, 15),
                      child: const Text(
                        'Past Audits',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null, // No title when expanded
              background: GestureDetector(
                onLongPress: _showAppInfoDialog,
                child: Image.asset(
                  'lib/assets/fonts/sliver.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Past Audits',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  SizedBox(height: 10),
                 // Filter row with two dropdowns
               Row(
  children: [
    Expanded(
      flex: 3,
      child: DropdownButtonFormField<String>(
        value: _selectedAuditTypeFilter,
      
        decoration: InputDecoration(
          labelText: 'Audit Type',
          labelStyle: TextStyle(fontSize: 10),
        
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          isDense: true,
        ),
        items: [
          _buildDropdownItem(null, 'All audit types'),
          _buildDropdownItem('Soft S', 'Soft S'),
          _buildDropdownItem('Hard S Hospital', 'Hard S Hospital'),
          _buildDropdownItem('Hard S Office', 'Hard S Office'),
        ],
        onChanged: (String? newValue) {
          setState(() => _selectedAuditTypeFilter = newValue);
        },
      ),
    ),
    SizedBox(width: 4),
    Expanded(
      flex: 2,
      child: DropdownButtonFormField<String>(
        value: _selectedSortFilter,
      
        decoration: InputDecoration(
         
          labelText: 'Sort By',
          labelStyle: TextStyle(fontSize: 10),
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          isDense: true,
        ),
        items: [
          _buildDropdownItem(null, 'Default'),
          _buildDropdownItem('Department', 'Department'),
          _buildDropdownItem('Highest Score', 'Highest Score'),
          _buildDropdownItem('Latest', 'Latest'),
        ],
        onChanged: (String? newValue) {
          setState(() => _selectedSortFilter = newValue);
        },
      ),
    ),
  ],
)
                ],
              ),
            ),
          ),
          filteredResults.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No audits found',
                      style: TextStyle(fontSize: 15),
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    var result = filteredResults[index];
                    return Card(
                      color: Color.fromARGB(255, 255, 228, 206),
                      margin: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: ListTile(
                        title: Text('Audit Type: ${result['auditType']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Department: ${result['departmentName']}'),
                            if (result['areaName'].isNotEmpty) ...[
                              Text('Area: ${result['areaName']}'),
                            ],
                            Text('Audit Period: ${result['auditPeriod']}'),
                            Text('Team Leader: ${result['personName']}'),
                            Text('Date: ${result['formattedDate']}'),
                            Text(
                              'Score: ${result['totalScore'].toStringAsFixed(2)} / ${result['maxTotalScore'].toStringAsFixed(0)}',
                            ),
                          ],
                        ),
                        onTap: () async {
                          DatabaseHelper dbHelper = DatabaseHelper();
                          List<Map<String, dynamic>> questionDetails =
                              await dbHelper.getQuestionDetails(result['id']);

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ResultPage(
                                departmentName:
                                    result['departmentName'] as String,
                                areaName: result['areaName'] as String,
                                personName: result['personName'] as String,
                                totalScore: result['totalScore'] as double,
                                maxPossibleScore:
                                    result['maxPossibleScore'] as double,
                                formattedDate:
                                    result['formattedDate'] as String,
                                senbetsu1Score:
                                    result['senbetsu1Score'] as double,
                                seiton2Score:
                                    result['seiton2Score'] as double,
                                seiso3Score: result['seiso3Score'] as double,
                                seiketsu4Score:
                                    result['seiketsu4Score'] as double,
                                shitsuke5Score:
                                    result['shitsuke5Score'] as double,
                                jishuku6Score:
                                    result['jishuku6Score'] as double,
                                anzen7Score: result['anzen7Score'] as double,
                                taikekasuru8Score:
                                    result['taikekasuru8Score'] as double,
                                pointsPerQuestion:
                                    result['pointsPerQuestion'] as double,
                                maxTotalScore:
                                    result['maxTotalScore'] as double,
                                auditType: result['auditType'] as String,
                                auditPeriod: result['auditPeriod'] as String,
                                teamMembers: _parseTeamMembers(
                                  result['teamMembers'],
                                ),
                                questions: questionDetails.map((detail) {
                                  return {
                                    "particular":
                                        detail['particular'] as String,
                                    "question":
                                        detail['question'] as String,
                                    "answer": detail['answer'] as String,
                                    "category":
                                        detail['category'] as String,
                                    "no": detail['no'] as String,
                                    "remark": detail['remark'] as String,
                                  };
                                }).toList(),
                                checklistResultId: result['id'],
                              ),
                            ),
                          );
                        },
                        onLongPress: () {
                          _showDeleteDialog(
                            result['id'],
                          ); // Show delete dialog on long press
                        },
                      ),
                    );
                  }, childCount: filteredResults.length),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NewAuditScreen()),
        ),
        backgroundColor: Color.fromARGB(255, 45, 103, 161),
        label: const Text(
          'Start New Audit',
          style: TextStyle(color: Colors.white),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}