import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'models.dart';

class WorkoutProvider with ChangeNotifier {
  List<Workout> _workouts = [];

  List<Workout> get workouts => _workouts;

  Future<void> loadWorkouts(String selectedType) async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/workouts.json');
      String response;

      if (await file.exists()) {
        response = await file.readAsString();
      } else {
        response = await rootBundle.loadString('assets/data/workouts.json');
      }

      final data = await json.decode(response);
      _workouts = selectedType == 'Push muscles'
          ? (data['push'] as List).map((i) => Workout.fromJson(i)).toList()
          : (data['pull'] as List).map((i) => Workout.fromJson(i)).toList();

      notifyListeners();
    } catch (e) {
      print('Error loading workouts: $e');
    }
  }

  Future<void> saveWorkouts() async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/workouts.json');
      final data = {
        'push': _workouts
            .where((w) => w.type == 'push')
            .map((w) => w.toJson())
            .toList(),
        'pull': _workouts
            .where((w) => w.type == 'pull')
            .map((w) => w.toJson())
            .toList()
      };
      await file.writeAsString(json.encode(data));
    } catch (e) {
      print('Error saving workouts: $e');
    }
  }

  Future<void> createBackup() async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/workouts.json');
      final File backupFile = File('${directory.path}/workouts_backup.json');
      if (await file.exists()) {
        await backupFile.writeAsBytes(await file.readAsBytes());
      }
    } catch (e) {
      print('Error creating backup: $e');
    }
  }

  void removeWorkout(int index) {
    _workouts.removeAt(index);
    saveWorkouts();
    notifyListeners();
  }

  void replaceWorkout(int index, Workout newWorkout) {
    _workouts[index] = newWorkout;
    saveWorkouts();
    notifyListeners();
  }
}
