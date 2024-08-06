import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'models.dart';
import 'package:fitness_app/exercise_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<DateTime, List<Workout>> workoutsByDate = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _loadWorkoutHistory();
  }

  Future<void> _loadWorkoutHistory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/workout_history.json';
      final file = File(path);

      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> history = json.decode(contents);

        setState(() {
          workoutsByDate = {};
          for (var workoutData in history) {
            final workout = Workout.fromJson(workoutData);
            final date = DateTime.parse(workoutData['timestamp'])
                .toLocal(); // Konvertiere zu lokaler Zeit

            if (workoutsByDate.containsKey(date)) {
              workoutsByDate[date]!.add(workout);
            } else {
              workoutsByDate[date] = [workout];
            }
          }
        });
      } else {
        print('Keine gespeicherten Workouts gefunden.');
      }
    } catch (e) {
      print("Fehler beim Laden der Workouts: $e");
    }
  }

  List<Workout> _getWorkoutsForDay(DateTime date) {
    return workoutsByDate[date] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kalender'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: CalendarFormat.month,
            onFormatChanged: (format) {
              // Aktualisiere das Kalenderformat
            },
            eventLoader: _getWorkoutsForDay,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blueAccent,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: _getWorkoutsForDay(_selectedDay ?? _focusedDay)
                  .map((workout) => ListTile(
                        title: Text(workout.title),
                        subtitle: Text(
                            'Sets: ${workout.workingSets.length}, Muscles: ${workout.muscles.join(', ')}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExerciseDetailScreen(
                                workout: workout,
                                onSave: (updatedWorkout) {
                                  setState(() {
                                    // Aktualisiere Workout-Details
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
