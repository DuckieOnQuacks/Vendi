import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'machine_class.dart';

class DatabaseHelper {
  // Define database name and version number
  static const int version = 1;
  static const String dbName = 'Machine.db';

  // Define table columns
  static const table = 'Machine';
  static const columnId = 'id';
  static const columnName = 'name';
  static const columnDesc = 'description';
  static const columnLat = 'latitude';
  static const columnLon = 'longitude';
  static const columnImagePath = 'imagePath';
  static const columnFavorite = 'favorite';
  static const columnIcon = 'icon';
  static const columnCash = 'cash';
  static const columnCard = 'card';
  static const columnStock = 'stock';
  static const columnOperational = 'operational';

  late Database db;

  // Initialize the database
  Future<void> init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, dbName);
    db = await openDatabase(
      path,
      version: version,
      onCreate: onCreate,
    );
    debugPrint('here');
  }

  // Create the database table
  Future onCreate(Database db, int version) async {
    await db.execute('''
        CREATE TABLE $table(
            $columnId TEXT NO NULL,
            $columnName TEXT NO NULL,
            $columnDesc TEXT NOT NULL,
            $columnLat INTEGER NOT NULL,
            $columnLon INTEGER NOT NULL,
            $columnImagePath TEXT NOT NULL,
            $columnFavorite INTEGER NOT NULL DEFAULT '0',
            $columnIcon TEXT NOT NULL,
            $columnCard INTEGER NOT NULL,
            $columnCash INTEGER NOT NULL,
            $columnOperational INTEGER NOT NULL,
            $columnStock INTEGER NOT NULL)
            ''');
  }

  // Add a machine to the database
  Future<int> addMachine(Machine machine) async {
    return await db.insert(table, machine.toJson(),conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Update a machine in the database
  Future<int> updateMachine(Machine machine) async {
    return await db.update(table, machine.toJson(),
        where: 'id =?',
        whereArgs: [machine.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Delete a machine from the database
  Future<int> deleteMachine(Machine machine) async {
    return await db.delete(
      table,
      where: 'id =?',
      whereArgs: [machine.id],
    );
  }

  // Get a list of all favorited machines from the database
  Future<List<Machine>> getAllFavorited() async {
    List<Map<String, dynamic>> favorite = await db.query(table, where: "favorite = 1");
    return List.generate(favorite.length, (index){
      return Machine.fromJson(favorite[index]);
    });
  }

  // Get a list of all machines from the database
  Future<List<Machine>> getAllMachines() async {
    final List<Map<String, dynamic>> maps = await db.query(table);
    return List.generate(maps.length, (index) => Machine.fromJson(maps[index]));
  }

  // Get the total number of rows in the database
  Future<int> queryRowCount() async {
    final results = await db.rawQuery('SELECT COUNT(*) FROM $table');
    return Sqflite.firstIntValue(results) ?? 0;
  }
}
