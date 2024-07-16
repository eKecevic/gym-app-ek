import 'package:flutter/material.dart';
import 'models.dart';

class WorkoutCard extends StatelessWidget {
  final Workout workout;
  final VoidCallback onTap;

  WorkoutCard({required this.workout, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      child: ListTile(
        leading: Icon(Icons.fitness_center),
        title: Text(workout.title),
        subtitle: Text(
            '${workout.warmUpSets.length + workout.workingSets.length} sets'),
        trailing: Icon(Icons.more_vert),
        onTap: onTap,
      ),
    );
  }
}
