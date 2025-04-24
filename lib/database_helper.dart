import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static DatabaseHelper get instance => _instance;
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'department_area.db');
    return await openDatabase(
      path,
      version: 4, 
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create departments table
    await db.execute('''
      CREATE TABLE departments(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE
      )
    ''');

    // Create areas table
    await db.execute('''
      CREATE TABLE areas(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        departmentId INTEGER,
        name TEXT,
        FOREIGN KEY(departmentId) REFERENCES departments(id) ON DELETE CASCADE
      )
    ''');

    // Create checklist_results table
    await db.execute('''
      CREATE TABLE checklist_results(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        departmentName TEXT,
        areaName TEXT,
        personName TEXT,
        totalScore REAL,
        maxPossibleScore REAL,
        formattedDate TEXT,
        senbetsu1Score REAL,
        seiton2Score REAL,
        seiso3Score REAL,
        seiketsu4Score REAL,
        shitsuke5Score REAL,
        jishuku6Score REAL,
        anzen7Score REAL,
        taikekasuru8Score REAL,
        maxTotalScore REAL,
        pointsPerQuestion REAL,
        auditType TEXT,         
        auditPeriod TEXT,      
        teamMembers TEXT         
      )
    ''');

    // Create question_details table
    await db.execute('''
      CREATE TABLE question_details(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        no TEXT,
        checklistResultId INTEGER,
        particular TEXT,
        question TEXT,
        answer TEXT,
        category TEXT,
        remark TEXT,
        imageCode TEXT,
        FOREIGN KEY(checklistResultId) REFERENCES checklist_results(id) ON DELETE CASCADE
      )
    ''');

    // Create images table
    await db.execute('''
      CREATE TABLE question_images(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        questionDetailId INTEGER,
        imagePath TEXT,
        imageCode TEXT,
        FOREIGN KEY(questionDetailId) REFERENCES question_details(id) ON DELETE CASCADE
      )
    ''');
  }
  
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE checklist_results(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          departmentName TEXT,
          areaName TEXT,
          personName TEXT,
          totalScore REAL,
          maxPossibleScore REAL,
          formattedDate TEXT,
          senbetsu1Score REAL,
          seiton2Score REAL,
          seiso3Score REAL,
          seiketsu4Score REAL,
          shitsuke5Score REAL,
          jishuku6Score REAL,
          anzen7Score REAL,
          taikekasuru8Score REAL,
          maxTotalScore REAL,
          pointsPerQuestion REAL,
          auditType TEXT,         
          auditPeriod TEXT,       
          teamMembers TEXT       
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE question_details(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          no TEXT,
          checklistResultId INTEGER,
          particular TEXT,
          question TEXT,
          answer TEXT,
          category TEXT,
          remark TEXT,
          FOREIGN KEY(checklistResultId) REFERENCES checklist_results(id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 4) {
      // Add imageCode to question_details
      await db.execute('''
        ALTER TABLE question_details ADD COLUMN imageCode TEXT
      ''');
      
      // Create images table
      await db.execute('''
        CREATE TABLE question_images(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          questionDetailId INTEGER,
          imagePath TEXT,
          imageCode TEXT,
          FOREIGN KEY(questionDetailId) REFERENCES question_details(id) ON DELETE CASCADE
        )
      ''');
    }
  }

  // Insert a department
  Future<int> insertDepartment(String name) async {
    Database db = await database;
    return await db.insert('departments', {'name': name});
  }

  // Insert checklist result
  Future<int> insertChecklistResult({
    required String departmentName,
    required String areaName,
    required String personName,
    required double totalScore,
    required double maxPossibleScore,
    required String formattedDate,
    required double senbetsu1Score,  
    required double seiton2Score, 
    required double seiso3Score, 
    required double seiketsu4Score, 
    required double shitsuke5Score,
    required double jishuku6Score,
    required double anzen7Score,
    required double taikekasuru8Score,
    required double pointsPerQuestion,
    required double maxTotalScore,
    required String auditType,
    required String auditPeriod,
    required String teamMembers,
  }) async {
    Database db = await database;
    return await db.insert('checklist_results', {
      'departmentName': departmentName,
      'areaName': areaName,
      'personName': personName,
      'totalScore': totalScore,
      'maxPossibleScore': maxPossibleScore,
      'formattedDate': formattedDate,
      'senbetsu1Score': senbetsu1Score,
      'seiton2Score': seiton2Score,
      'seiso3Score': seiso3Score,
      'seiketsu4Score': seiketsu4Score,
      'shitsuke5Score': shitsuke5Score,
      'jishuku6Score': jishuku6Score,
      'anzen7Score': anzen7Score,
      'taikekasuru8Score': taikekasuru8Score,
      'pointsPerQuestion': pointsPerQuestion,
      'maxTotalScore': maxTotalScore,
      'auditType': auditType,           
      'auditPeriod': auditPeriod,       
      'teamMembers': teamMembers,  
    });
  }

  // Insert question details
  Future<int> insertQuestionDetails({
    required int checklistResultId,
    required String particular,
    required String question,
    required String answer,
    required String category,
    required String no,
    required String remark,
    String? imageCode,
  }) async {
    Database db = await database;
    return await db.insert('question_details', {
      'checklistResultId': checklistResultId,
      'no': no,
      'particular': particular,
      'question': question,
      'answer': answer,
      'category': category,
      'remark': remark,
      'imageCode': imageCode,
    });
  }

  // Insert an image for a question detail
  Future<int> insertQuestionImage({
    required int questionDetailId,
    required String imagePath,
    required String imageCode,
  }) async {
    Database db = await database;
    return await db.insert('question_images', {
      'questionDetailId': questionDetailId,
      'imagePath': imagePath,
      'imageCode': imageCode,
    });
  }

  // Get all departments
  Future<List<Map<String, dynamic>>> getDepartments() async {
    Database db = await database;
    return await db.query('departments');
  }

  // Get areas for a department
  Future<List<Map<String, dynamic>>> getAreas(int departmentId) async {
    Database db = await database;
    return await db.query(
      'areas',
      where: 'departmentId = ?',
      whereArgs: [departmentId],
    );
  }

  // Get all checklist results
  Future<List<Map<String, dynamic>>> getChecklistResults() async {
    Database db = await database;
    return await db.query('checklist_results');
  }

  // Get question details for a checklist result
  Future<List<Map<String, dynamic>>> getQuestionDetails(int checklistResultId) async {
    Database db = await database;
    return await db.query(
      'question_details',
      where: 'checklistResultId = ?',
      whereArgs: [checklistResultId],
    );
  }

  // Get images for a question detail
  Future<List<Map<String, dynamic>>> getQuestionImages(int questionDetailId) async {
    Database db = await database;
    return await db.query(
      'question_images',
      where: 'questionDetailId = ?',
      whereArgs: [questionDetailId],
    );
  }

  // Delete a department
  Future<void> deleteDepartment(String name) async {
    Database db = await database;
    
    // First get the department ID
    List<Map<String, dynamic>> result = await db.query(
      'departments',
      where: 'name = ?',
      whereArgs: [name],
    );
    
    if (result.isNotEmpty) {
      int departmentId = result.first['id'] as int;
      await db.delete('departments', where: 'id = ?', whereArgs: [departmentId]);
    }
  }

  Future<void> deleteChecklistResult(int id) async {
    Database db = await database;
    await db.delete('checklist_results', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateDepartment(String oldName, String newName) async {
    final db = await database;
    return await db.update('departments', {'name': newName}, where: "name = ?", whereArgs: [oldName]);
  }

  Future<List<String>> getAreasForDepartment(String departmentName) async {
    final db = await database;
    
    List<Map<String, dynamic>> deptResult = await db.query(
      'departments',
      where: 'name = ?',
      whereArgs: [departmentName],
    );
    
    if (deptResult.isEmpty) return [];
    
    int departmentId = deptResult.first['id'] as int;
    
    List<Map<String, dynamic>> areaMaps = await db.query(
      'areas',
      where: 'departmentId = ?',
      whereArgs: [departmentId],
    );
    
    return areaMaps.map((map) => map['name'] as String).toList();
  }

  Future<int> insertArea(String departmentName, String areaName) async {
    final db = await database;
    
    List<Map<String, dynamic>> deptResult = await db.query(
      'departments',
      where: 'name = ?',
      whereArgs: [departmentName],
    );
    
    if (deptResult.isEmpty) {
      throw Exception('Department not found');
    }
    
    int departmentId = deptResult.first['id'] as int;
    
    return await db.insert('areas', {
      'departmentId': departmentId,
      'name': areaName,
    });
  }

  Future<int> updateArea(String oldName, String newName) async {
    final db = await database;
    return await db.update(
      'areas',
      {'name': newName},
      where: 'name = ?',
      whereArgs: [oldName],
    );
  }

  Future<int> deleteArea(String name) async {
    final db = await database;
    return await db.delete(
      'areas',
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  Future<int> updateChecklistResult({
    required int id,
    required String departmentName,
    required String areaName,
    required String personName,
    required double totalScore,
    required double maxPossibleScore,
    required String formattedDate,
    required double senbetsu1Score,
    required double seiton2Score,
    required double seiso3Score,
    required double seiketsu4Score,
    required double shitsuke5Score,
    required double jishuku6Score,
    required double anzen7Score,
    required double taikekasuru8Score,
    required double pointsPerQuestion,
    required double maxTotalScore,
    required String auditType,
    required String auditPeriod,
    required String teamMembers,
  }) async {
    final db = await database;
    return await db.update(
      'checklist_results',
      {
        'departmentName': departmentName,
        'areaName': areaName,
        'personName': personName,
        'totalScore': totalScore,
        'maxPossibleScore': maxPossibleScore,
        'formattedDate': formattedDate,
        'senbetsu1Score': senbetsu1Score,
        'seiton2Score': seiton2Score,
        'seiso3Score': seiso3Score,
        'seiketsu4Score': seiketsu4Score,
        'shitsuke5Score': shitsuke5Score,
        'jishuku6Score': jishuku6Score,
        'anzen7Score': anzen7Score,
        'taikekasuru8Score': taikekasuru8Score,
        'pointsPerQuestion': pointsPerQuestion,
        'maxTotalScore': maxTotalScore,
        'auditType': auditType,
        'auditPeriod': auditPeriod,
        'teamMembers': teamMembers,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteQuestionDetails(int checklistResultId) async {
    final db = await database;
    return await db.delete(
      'question_details',
      where: 'checklistResultId = ?',
      whereArgs: [checklistResultId],
    );
  }

  Future<int> deleteQuestionImages(int questionDetailId) async {
    final db = await database;
    return await db.delete(
      'question_images',
      where: 'questionDetailId = ?',
      whereArgs: [questionDetailId],
    );
  }

  Future<int> deleteAllChecklistResults() async {
    final db = await database;
    return await db.delete('checklist_results');
  }

  // Helper method to generate image codes
  Future<String> generateImageCode(int questionDetailId, String baseCode) async {
    final db = await database;
    
    // Get all images with this base code for the question
    final images = await db.query(
      'question_images',
      where: 'questionDetailId = ? AND imageCode LIKE ?',
      whereArgs: [questionDetailId, '$baseCode%'],
    );
    
    if (images.isEmpty) {
      return baseCode; // Return base code if no images exist
    }
    
    // Find the highest suffix number
    int maxSuffix = 0;
    for (var image in images) {
      final code = image['imageCode'] as String;
      if (code == baseCode) {
        maxSuffix = maxSuffix < 1 ? 1 : maxSuffix;
      } else {
        final suffix = int.tryParse(code.substring(baseCode.length)) ?? 0;
        if (suffix > maxSuffix) {
          maxSuffix = suffix;
        }
      }
    }
    
    return maxSuffix == 0 ? baseCode : '$baseCode${maxSuffix + 1}';
  }
}