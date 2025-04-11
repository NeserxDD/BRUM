import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'custom_widgets.dart';

class AreaSelectionScreen extends StatefulWidget {
  final String department;

  const AreaSelectionScreen({Key? key, required this.department})
    : super(key: key);

  @override
  _AreaSelectionScreenState createState() => _AreaSelectionScreenState();
}

class _AreaSelectionScreenState extends State<AreaSelectionScreen> {
  List<String> areas = [];
  List<String> filteredAreas = [];
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAreas();
    _searchController.addListener(_filterAreas);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _loadAreas() async {
    try {
      List<String> loadedAreas = await DatabaseHelper().getAreasForDepartment(
        widget.department,
      );
      setState(() {
        areas = loadedAreas;
        filteredAreas = loadedAreas;
      });
    } catch (e) {
      CustomSnackbar.show(
        context,
        message: "Failed to load areas: $e",
        isError: true,
      );
    }
  }

  void _filterAreas() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredAreas =
          areas.where((area) => area.toLowerCase().contains(query)).toList();
    });
  }

  void _showOptionsDialog(String area) {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.edit,
                  color: Color.fromARGB(255, 45, 103, 161),
                ),
                title: const Text("Rename Area"),
                onTap: () {
                  Navigator.pop(context);
                  _renameArea(area);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Delete Area"),
                onTap: () {
                  Navigator.pop(context);
                  _deleteArea(area);
                },
              ),
            ],
          ),
    );
  }

  Future<void> _renameArea(String oldName) async {
    String? newName = await CustomInputDialog.show(
      context,
      title: "Rename Area",
      initialValue: oldName,
    );

    if (newName != null && newName.isNotEmpty && newName != oldName) {
      try {
        await DatabaseHelper().updateArea(oldName, newName);
        _loadAreas();
        CustomSnackbar.show(context, message: "Area renamed successfully");
      } catch (e) {
        CustomSnackbar.show(
          context,
          message: "Failed to rename area: $e",
          isError: true,
        );
      }
    }
  }

  Future<void> _deleteArea(String area) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete Area?'),
            backgroundColor: Color.fromARGB(255, 221, 231, 241),
            content: Text('Are you sure you want to delete "$area"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirmDelete == true) {
      try {
        await DatabaseHelper().deleteArea(area);
        _loadAreas();
        CustomSnackbar.show(context, message: "Area deleted successfully");
      } catch (e) {
        CustomSnackbar.show(
          context,
          message: "Failed to delete area: $e",
          isError: true,
        );
      }
    }
  }

  void _selectArea(String selectedArea) {
    Navigator.pop(context, selectedArea);
  }

  Future<void> _addNewArea() async {
    String? newArea = await CustomInputDialog.show(
      context,
      title: "Add New Area",
      hintText: "Enter area name",
    );

    if (newArea != null && newArea.isNotEmpty) {
      try {
        if (areas.contains(newArea)) {
          CustomSnackbar.show(
            context,
            message: "Area already exists",
            isError: true,
          );
          return;
        }

        await DatabaseHelper().insertArea(widget.department, newArea);
        _loadAreas();
        CustomSnackbar.show(context, message: "Area added successfully");
      } catch (e) {
        CustomSnackbar.show(
          context,
          message: "Failed to add area: $e",
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 45, 103, 161),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Select Area in ${widget.department} ',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            onPressed: _loadAreas,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              cursorColor: Colors.blue[700],
              decoration: InputDecoration(
                labelText: 'Search Area',
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
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Color.fromARGB(255, 45, 103, 161),
                          ),

                          onPressed: () {
                            _searchController.clear();
                            _filterAreas();
                          },
                        )
                        : null,
              ),
            ),
          ),
          Expanded(
            child:
                filteredAreas.isEmpty
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
                          Text(
                            _searchController.text.isEmpty
                                ? "No areas found for ${widget.department}"
                                : "No matching areas found",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchController.text.isEmpty
                                ? "Tap the + button to add a New Area"
                                : "Try a different search term",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      itemCount: filteredAreas.length,
                      itemBuilder: (context, index) {
                        String area = filteredAreas[index];

                        return ListTile(
                          title: Text(area),
                          onTap: () => _selectArea(area),
                          onLongPress: () => _showOptionsDialog(area),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewArea,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add Area", style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 45, 103, 161),
      ),
    );
  }
}
