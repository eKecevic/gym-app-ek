import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'exercise_detail_screen.dart';
import 'workout_card.dart';
import 'workout_execution_screen.dart';
import 'models.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'create_exercise_screen.dart';
import 'exercise_pool_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness App',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: WorkoutScreen(),
    );
  }
}

class WorkoutScreen extends StatefulWidget {
  @override
  _WorkoutScreenState createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  String selectedDuration = '1h 30m';
  String selectedType = 'Push';
  String selectedRestTime = '1m'; // New variable for rest time
  List<Workout> workouts = [];
  Map<String, int> muscleCounts = {}; // Neue Variable für die Muskelgruppen

  @override
  void initState() {
    super.initState();
    loadWorkouts();
  }

  Future<void> loadWorkouts() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        final workoutsString = prefs.getString('workouts');
        if (workoutsString != null) {
          final data = json.decode(workoutsString);
          setState(() {
            workouts = _getWorkoutsForSelectedType(data);
            _updateMuscleCounts(); // Aktualisiere die Muskelgruppen
          });
          return;
        }
      }
      // Load from assets if not available in shared preferences
      final response = await rootBundle.loadString('assets/data/workouts.json');
      final data = json.decode(response);
      setState(() {
        workouts = _getWorkoutsForSelectedType(data);
        _updateMuscleCounts(); // Aktualisiere die Muskelgruppen
      });
    } catch (e) {
      print("Error loading workouts: $e");
    }
  }

  List<Workout> _getWorkoutsForSelectedType(Map<String, dynamic> data) {
    switch (selectedType) {
      case 'Push':
        return (data['push'] as List).map((i) => Workout.fromJson(i)).toList();
      case 'Pull':
        return (data['pull'] as List).map((i) => Workout.fromJson(i)).toList();
      case 'Legs':
        return (data['legs'] as List).map((i) => Workout.fromJson(i)).toList();
      default:
        return [];
    }
  }

  Future<void> saveWorkouts() async {
    try {
      final data = {
        'push': workouts
            .where((w) => w.type == 'push')
            .map((w) => w.toJson())
            .toList(),
        'pull': workouts
            .where((w) => w.type == 'pull')
            .map((w) => w.toJson())
            .toList(),
        'legs': workouts
            .where((w) => w.type == 'legs')
            .map((w) => w.toJson())
            .toList(),
      };

      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('workouts', json.encode(data));
      } else {
        // Save workouts to local storage if not on web
        final directory = await getApplicationDocumentsDirectory();
        final path = directory.path;
        final file = File('$path/workouts.json');
        final backupFile = File('$path/workouts_backup.json');

        if (await file.exists()) {
          await file.copy(backupFile.path);
        }

        await file.writeAsString(json.encode(data));
      }
    } catch (e) {
      print("Error saving workouts: $e");
    }
  }

  void removeWorkout(int index) {
    setState(() {
      workouts.removeAt(index);
      _updateMuscleCounts(); // Aktualisiere die Muskelgruppen
      saveWorkouts();
    });
  }

  void replaceWorkout(int index) {
    print("Workout an Index $index ersetzen");
  }

  int getDurationInMinutes(String duration) {
    final parts = duration.split(' ');
    final hours = int.parse(parts[0].replaceAll('h', ''));
    final minutes = int.parse(parts[1].replaceAll('m', ''));
    return hours * 60 + minutes;
  }

  int getRestTimeInSeconds(String restTime) {
    return int.parse(restTime.replaceAll('m', '')) * 60;
  }

  void addExercise() async {
    final newExercise = await showDialog<Workout>(
      context: context,
      builder: (context) => AddExerciseDialog(),
    );

    if (newExercise != null) {
      setState(() {
        workouts.add(newExercise);
        _updateMuscleCounts(); // Aktualisiere die Muskelgruppen
        saveWorkouts();
      });
    }
  }

  void _updateMuscleCounts() {
    final counts = <String, int>{};
    for (var workout in workouts) {
      for (var muscle in workout.muscles) {
        if (counts.containsKey(muscle)) {
          counts[muscle] = counts[muscle]! + 1;
        } else {
          counts[muscle] = 1;
        }
      }
    }
    setState(() {
      muscleCounts = counts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trainingsplan'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildDropdownButton(
                value: selectedDuration,
                items: ['1h 00m', '1h 30m', '2h 00m'],
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDuration = newValue!;
                  });
                },
              ),
              _buildDropdownButton(
                value: selectedType,
                items: ['Push', 'Pull', 'Legs'],
                onChanged: (String? newValue) {
                  setState(() {
                    selectedType = newValue!;
                    loadWorkouts(); // Reload workouts based on new type
                  });
                },
              ),
              _buildDropdownButton(
                value: selectedRestTime,
                items: ['1m', '2m', '3m'],
                onChanged: (String? newValue) {
                  setState(() {
                    selectedRestTime = newValue!;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Zielmuskeln',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: muscleCounts.entries.map((entry) {
                return TargetMuscleWidget(
                    muskel: entry.key, anteil: entry.value);
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${workouts.length} Übungen',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Column(
            children: workouts.asMap().entries.map((entry) {
              int index = entry.key;
              Workout workout = entry.value;
              return Dismissible(
                key: Key('${workout.title}-$index'), // Eindeutiger Schlüssel
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return false;
                },
                onDismissed: (direction) {},
                background: Container(
                  color: Colors.transparent,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          replaceWorkout(index);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.swap_horiz, color: Colors.white),
                            SizedBox(width: 5),
                            Text("Ersetzen",
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          removeWorkout(index);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.white),
                            SizedBox(width: 5),
                            Text("Löschen",
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                child: WorkoutCard(
                  workout: workout,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExerciseDetailScreen(
                          workout: workout,
                          onSave: (updatedWorkout) {
                            setState(() {
                              workouts[index] = updatedWorkout;
                              _updateMuscleCounts(); // Aktualisiere die Muskelgruppen
                              saveWorkouts();
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 20), // Add some space before the plus button
          Center(
            child: FloatingActionButton(
              onPressed: addExercise,
              child: Icon(Icons.add),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkoutExecutionScreen(
                workouts: workouts,
                selectedDuration: selectedDuration,
                selectedRestTime:
                    selectedRestTime, // Pass the selected rest time
              ),
            ),
          );
        },
        child: Icon(Icons.play_arrow),
      ),
    );
  }

  Widget _buildDropdownButton({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.0),
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class TargetMuscleWidget extends StatelessWidget {
  final String muskel;
  final int anteil;

  TargetMuscleWidget({required this.muskel, required this.anteil});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$muskel angeklickt!')),
        );
      },
      child: Container(
        width: 100,
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 40),
            SizedBox(height: 4),
            Text(muskel),
            Text('$anteil Übungen'),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Einstellungen'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Fitnessziel'),
            subtitle: Text('Krafttraining'),
          ),
          ListTile(
            title: Text('Fitnesserfahrung'),
            subtitle: Text('Mittelstufe'),
          ),
          ListTile(
            title: Text('Zeitgesteuerte Intervalle'),
            subtitle: Text('Aus'),
          ),
        ],
      ),
    );
  }
}

class AddExerciseDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Übung hinzufügen'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ExercisePoolScreen()),
              ).then((selectedExercise) {
                if (selectedExercise != null) {
                  Navigator.pop(context, selectedExercise);
                }
              });
            },
            child: Text('Aus Pool hinzufügen'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newWorkout = await Navigator.push<Workout>(
                context,
                MaterialPageRoute(builder: (context) => CreateExerciseScreen()),
              );
              if (newWorkout != null) {
                Navigator.pop(context, newWorkout);
              }
            },
            child: Text('Eigene Übung erstellen'),
          ),
        ],
      ),
    );
  }
}
