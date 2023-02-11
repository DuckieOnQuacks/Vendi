import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../machine_class.dart';

class DatabaseHelper {
  static const int _version = 2;
  static const String _dbName = 'Machine.db';

  //Create database and return it
  Future<Database> onCreate() async {
    return openDatabase(join(await getDatabasesPath(), _dbName),
        onCreate: (db, version) async =>
        await db.execute("CREATE TABLE Machine("
            "id INTEGER NOT NULL, "
            "description TEXT, "
            "latitude DOUBLE PRECISION NOT NULL, "
            "longitude DOUBLE PRECISION NOT NULL, "
            "imagePath TEXT, "
            "favorite INTEGER NOT NULL DEFAULT '0',"
            "icon TEXT)"),
        version: _version);
  }

  Future<int> addMachine(Machine machine) async {
    final db = await onCreate();
    return await db.insert("Machine", machine.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateMachine(Machine machine) async {
    final db = await onCreate();
    return await db.update("Machine", machine.toJson(),
        where: 'id =?',
        whereArgs: [machine.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> deleteMachine(Machine machine) async {
    final db = await onCreate();
    return await db.delete(
      "Machine",
      where: 'id =?',
      whereArgs: [machine.id],
    );
  }

  Future<List<Machine>> getAllFavorited() async {
    final db = await onCreate();
    List<Map<String, dynamic>> favorite = await db.query("Machine", where: "favorite = 1");
    return List.generate(favorite.length, (index){
      return Machine.fromJson(favorite[index]);
    });
  }

  Future<List<Machine>> getAllMachines() async {
    final db = await onCreate();
    final List<Map<String, dynamic>> maps = await db.query("Machine");
    return List.generate(maps.length, (index) => Machine.fromJson(maps[index]));
  }

  Future<int> queryRowCount() async {
    final db = await onCreate();
    final results = await db.rawQuery('SELECT COUNT(*) FROM $Machine');
    return Sqflite.firstIntValue(results) ?? 0;
  }
}
