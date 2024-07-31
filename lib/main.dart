import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  String selectedRestTime = '1m';
  List<Workout> workouts = [];
  Map<String, int> muscleCounts = {};
  Map<String, Color> muscleColors = {
    'Schultern': Colors.grey,
    'Brust': Colors.grey,
    'Bizeps': Colors.grey,
    'Trizeps': Colors.grey,
    'Rücken': Colors.grey,
    'Bauch': Colors.grey,
    'Beine': Colors.grey,
    'Waden': Colors.grey,
  };

  String svgString = '';

  @override
  void initState() {
    super.initState();
    loadWorkouts();
    loadSvg();
  }

  Future<void> loadSvg() async {
    svgString = await rootBundle.loadString('assets/body.svg');
    setState(() {});
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
            _updateMuscleCounts();
            highlightMuscles(muscleCounts.keys.toList());
          });
          return;
        }
      }
      final response = await rootBundle.loadString('assets/data/workouts.json');
      final data = json.decode(response);
      setState(() {
        workouts = _getWorkoutsForSelectedType(data);
        _updateMuscleCounts();
        highlightMuscles(muscleCounts.keys.toList());
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
      _updateMuscleCounts();
      highlightMuscles(muscleCounts.keys.toList());
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
        _updateMuscleCounts();
        highlightMuscles(muscleCounts.keys.toList());
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

  void highlightMuscles(List<String> muscles) {
    setState(() {
      muscleColors = {
        for (var muscle in muscleColors.keys)
          muscle: muscles.contains(muscle) ? Colors.yellow : Colors.grey,
      };
      svgString = _updateSvgColors(svgString, muscleColors);
    });
  }

  String _updateSvgColors(String svg, Map<String, Color> colors) {
    colors.forEach((muscle, color) {
      final colorHex = '#${color.value.toRadixString(16).substring(2)}';
      svg = svg.replaceAll(RegExp('id="$muscle" style="[^"]*"'),
          'id="$muscle" style="fill:$colorHex;stroke:#000000;stroke-linejoin:round;stroke-miterlimit:1.4142;"');
    });
    return svg;
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
                    loadWorkouts();
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
            height: 400,
            child: svgString.isNotEmpty
                ? SvgPicture.string(
                    svgString,
                    semanticsLabel: 'Körper mit hervorgehobenen Muskeln',
                  )
                : CircularProgressIndicator(),
          ),
          SizedBox(height: 10),
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
                key: Key('${workout.title}-$index'),
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
                              _updateMuscleCounts();
                              highlightMuscles(muscleCounts.keys.toList());
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
          SizedBox(height: 20),
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
                selectedRestTime: selectedRestTime,
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
