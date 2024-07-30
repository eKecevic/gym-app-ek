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
  String selectedType = 'Push muscles';
  String selectedRestTime = '1m'; // New variable for rest time
  List<Workout> workouts = [];

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
          });
          return;
        }
      }
      // Load from assets if not available in shared preferences
      final response = await rootBundle.loadString('assets/data/workouts.json');
      final data = json.decode(response);
      setState(() {
        workouts = _getWorkoutsForSelectedType(data);
      });
    } catch (e) {
      print("Error loading workouts: $e");
    }
  }

  List<Workout> _getWorkoutsForSelectedType(Map<String, dynamic> data) {
    switch (selectedType) {
      case 'Push muscles':
        return (data['push'] as List).map((i) => Workout.fromJson(i)).toList();
      case 'Pull muscles':
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
      saveWorkouts();
    });
  }

  void replaceWorkout(int index) {
    print("Replace workout at index $index");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout Plan'),
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
                items: ['Push muscles', 'Pull muscles', 'Legs'],
                onChanged: (String? newValue) {
                  setState(() {
                    selectedType = newValue!;
                    loadWorkouts(); // Reload workouts based on new type
                  });
                },
              ),
              _buildDropdownButton(
                value: 'Equipment',
                items: ['Equipment'],
                onChanged: (String? newValue) {
                  // Implement equipment change logic if needed
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
              'Target Muscles',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                TargetMuscleWidget(muscle: 'Chest', percentage: 58),
                TargetMuscleWidget(muscle: 'Triceps', percentage: 58),
                TargetMuscleWidget(muscle: 'Shoulders', percentage: 58),
                TargetMuscleWidget(
                    muscle: 'Legs', percentage: 60), // Added Legs
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${workouts.length} Exercises',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Column(
            children: workouts.asMap().entries.map((entry) {
              int index = entry.key;
              Workout workout = entry.value;
              return Dismissible(
                key: Key(workout.title),
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
                            Text("Replace",
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
                            Text("Delete",
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
  final String muscle;
  final int percentage;

  TargetMuscleWidget({required this.muscle, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$muscle clicked!')),
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
            Text(muscle),
            Text('$percentage%'),
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
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Fitness Goal'),
            subtitle: Text('Strength Training'),
          ),
          ListTile(
            title: Text('Fitness Experience'),
            subtitle: Text('Intermediate'),
          ),
          ListTile(
            title: Text('Timed Intervals'),
            subtitle: Text('Off'),
          ),
        ],
      ),
    );
  }
}

class TimerScreen extends StatelessWidget {
  final int selectedDuration;

  TimerScreen({required this.selectedDuration});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timer'),
      ),
      body: Center(
        child: TimerWidget(
          duration: selectedDuration,
        ),
      ),
    );
  }
}

class TimerWidget extends StatefulWidget {
  final int duration;

  TimerWidget({required this.duration});

  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late int remainingTime;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    remainingTime = widget.duration;
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = Duration(seconds: remainingTime);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return Text(
      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} / ${widget.duration ~/ 60}h ${widget.duration % 60}m',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}
