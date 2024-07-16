import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'models.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Workout workout;

  ExerciseDetailScreen({required this.workout});

  @override
  _ExerciseDetailScreenState createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late Workout workout;

  @override
  void initState() {
    super.initState();
    workout = widget.workout;
  }

  Future<void> saveWorkouts() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final file = File('$path/workouts.json');
    final backupFile = File('$path/workouts_backup.json');

    if (await file.exists()) {
      await file.copy(backupFile.path);
    }

    final data = {
      'push': workout.type == 'push' ? [workout.toJson()] : [],
      'pull': workout.type == 'pull' ? [workout.toJson()] : []
    };

    await file.writeAsString(json.encode(data));
  }

  void addSet() {
    setState(() {
      workout.workingSets.add(ExerciseSet(reps: 0, weight: 0));
      saveWorkouts();
    });
  }

  void removeSet(int index) {
    setState(() {
      workout.workingSets.removeAt(index);
      saveWorkouts();
    });
  }

  void updateSet(int index, int reps, int weight) {
    setState(() {
      workout.workingSets[index] = ExerciseSet(reps: reps, weight: weight);
      saveWorkouts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workout.title),
      ),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Warm-up Sets',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Column(
            children: workout.warmUpSets
                .asMap()
                .entries
                .map((entry) => buildSetTile(entry.key, entry.value, true))
                .toList(),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Working Sets',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Column(
            children: workout.workingSets
                .asMap()
                .entries
                .map((entry) => buildSetTile(entry.key, entry.value, false))
                .toList(),
          ),
          ElevatedButton(
            onPressed: addSet,
            child: Text('Add Working Set'),
          ),
        ],
      ),
    );
  }

  Widget buildSetTile(int index, ExerciseSet set, bool isWarmUp) {
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: set.reps.toString(),
              decoration: InputDecoration(labelText: 'Reps'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                int reps = int.parse(value);
                updateSet(index, reps, set.weight);
              },
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: TextFormField(
              initialValue: set.weight.toString(),
              decoration: InputDecoration(labelText: 'Weight'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                int weight = int.parse(value);
                updateSet(index, set.reps, weight);
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => removeSet(index),
          ),
        ],
      ),
    );
  }
}
