import 'package:flutter/material.dart';
import 'workouts.dart';
import 'workout_card.dart';
import 'models.dart';
import 'exercise_detail_screen.dart';

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

  void removeWorkout(int index) {
    setState(() {
      workouts.removeAt(index);
    });
  }

  void replaceWorkout(int index) {
    // Hier sollte die Logik für das Ersetzen der Übung implementiert werden
    // Zum Beispiel könnte ein Popup oder ein neuer Bildschirm geöffnet werden
    print("Replace workout at index $index");
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
                items: ['Push muscles', 'Pull muscles'],
                onChanged: (String? newValue) {
                  setState(() {
                    selectedType = newValue!;
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
                child: WorkoutCard(workout: workout),
              );
            }).toList(),
          ),
        ],
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
          // Add more settings options as needed
        ],
      ),
    );
  }
}
