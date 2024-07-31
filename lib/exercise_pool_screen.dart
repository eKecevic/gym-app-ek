import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'models.dart';

class ExercisePoolScreen extends StatelessWidget {
  Future<List<Workout>> loadWorkouts() async {
    final data = await rootBundle.loadString('assets/data/workouts.json');
    final jsonData = json.decode(data) as Map<String, dynamic>;

    final push = (jsonData['push'] as List<dynamic>?)
            ?.map((i) => Workout.fromJson(i as Map<String, dynamic>))
            .toList() ??
        [];
    final pull = (jsonData['pull'] as List<dynamic>?)
            ?.map((i) => Workout.fromJson(i as Map<String, dynamic>))
            .toList() ??
        [];
    final legs = (jsonData['legs'] as List<dynamic>?)
            ?.map((i) => Workout.fromJson(i as Map<String, dynamic>))
            .toList() ??
        [];

    return [...push, ...pull, ...legs];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Übungspool'),
      ),
      body: FutureBuilder<List<Workout>>(
        future: loadWorkouts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Fehler: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Keine Übungen gefunden.'));
          }

          final exercises = snapshot.data!;

          return ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final workout = exercises[index];
              return ListTile(
                title: Text(workout.title),
                subtitle: Text('${workout.workingSets.length} Sätze'),
                onTap: () {
                  Navigator.pop(context, workout);
                },
              );
            },
          );
        },
      ),
    );
  }
}
