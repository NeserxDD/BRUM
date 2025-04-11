import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'custom_widgets.dart';

class DepartmentSelectionScreen extends StatefulWidget {
  final Function(String) onDepartmentSelected;

  const DepartmentSelectionScreen({
    Key? key,
    required this.onDepartmentSelected,
  }) : super(key: key);

  @override
  _DepartmentSelectionScreenState createState() =>
      _DepartmentSelectionScreenState();
}

class _DepartmentSelectionScreenState extends State<DepartmentSelectionScreen> {
  List<String> departments = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    List<Map<String, dynamic>> departmentMaps =
        await DatabaseHelper.instance.getDepartments();
    setState(
      () =>
          departments =
              departmentMaps.map((map) => map['name'] as String).toList(),
    );
  }

  Future<void> _addDepartment() async {
    String? name = await CustomInputDialog.show(
      context,
      title: "Add Department",
      hintText: "Enter department name",
    );

    if (name != null && name.isNotEmpty) {
      try {
        int result = await DatabaseHelper.instance.insertDepartment(name);
        if (result != -1) {
          await Future.delayed(const Duration(milliseconds: 500));
          _loadDepartments();
          CustomSnackbar.show(
            context,
            message: "Department added successfully",
          );
        } else {
          CustomSnackbar.show(
            context,
            message: "Department already exists",
            isError: true,
          );
        }
      } catch (e) {
        CustomSnackbar.show(
          context,
          message: "Failed to add department: $e",
          isError: true,
        );
      }
    }
  }

  Future<void> _editDepartment(String oldName) async {
    String? newName = await CustomInputDialog.show(
      context,
      title: "Rename Department",
      initialValue: oldName,
    );

    if (newName != null && newName.isNotEmpty && newName != oldName) {
      try {
        await DatabaseHelper.instance.updateDepartment(oldName, newName);
        _loadDepartments();
        CustomSnackbar.show(
          context,
          message: "Department renamed successfully",
        );
      } catch (e) {
        CustomSnackbar.show(
          context,
          message: "Failed to rename department: $e",
          isError: true,
        );
      }
    }
  }

  Future<void> _deleteDepartment(String name) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("Delete Department"),
            backgroundColor: Color.fromARGB(255, 221, 231, 241),
            content: Text("Are you sure you want to delete \"$name\"?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        // First get the department ID
        final db = await DatabaseHelper().database;
        List<Map<String, dynamic>> result = await db.query(
          'departments',
          where: 'name = ?',
          whereArgs: [name],
        );

        if (result.isNotEmpty) {
          int departmentId = result.first['id'] as int;
          await db.delete(
            'departments',
            where: 'id = ?',
            whereArgs: [departmentId],
          );
          _loadDepartments();
          CustomSnackbar.show(
            context,
            message: "Department deleted successfully",
          );
        }
      } catch (e) {
        CustomSnackbar.show(
          context,
          message: "Failed to delete department: $e",
          isError: true,
        );
      }
    }
  }

  void _showDepartmentOptions(String department) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.edit,
                  color: Color.fromARGB(255, 45, 103, 161),
                ),
                title: const Text("Rename"),
                onTap: () {
                  Navigator.pop(context);
                  _editDepartment(department);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Delete"),
                onTap: () {
                  Navigator.pop(context);
                  _deleteDepartment(department);
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Department",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 45, 103, 161),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            onPressed: _loadDepartments,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              cursorColor: Colors.blue[700],
              decoration: InputDecoration(
                labelText: "Search",
                labelStyle: TextStyle(color: Colors.black),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color.fromARGB(255, 17, 67, 118),
                ),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  // Border when NOT focused
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 167, 205, 255),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  // Border when focused
                  borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                ),

                suffixIcon:
                    searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Color.fromARGB(255, 45, 103, 161),
                          ),
                          onPressed: () {
                            searchController.clear();
                            setState(() {});
                          },
                        )
                        : null,
              ),
              onChanged: (query) => setState(() {}),
            ),
          ),
          Expanded(
            child:
                departments.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 48,
                            color: Color.fromARGB(255, 45, 103, 161),
                          ),
                          const SizedBox(height: 16),

                          const SizedBox(height: 8),
                          Text(
                            searchController.text.isEmpty
                                ? "No departments found"
                                : "No matching departments found",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            searchController.text.isEmpty
                                ? "Tap the + button to add a New Department"
                                : "Try a different search term",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount:
                          departments
                              .where(
                                (dept) => dept.toLowerCase().contains(
                                  searchController.text.toLowerCase(),
                                ),
                              )
                              .length,
                      itemBuilder: (context, index) {
                        final dept =
                            departments
                                .where(
                                  (dept) => dept.toLowerCase().contains(
                                    searchController.text.toLowerCase(),
                                  ),
                                )
                                .toList()[index];
                        return ListTile(
                          title: Text(dept),
                          onTap: () => widget.onDepartmentSelected(dept),
                          onLongPress: () => _showDepartmentOptions(dept),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addDepartment,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add Department",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color.fromARGB(255, 45, 103, 161),
      ),
    );
  }
}
