import 'package:flutter/material.dart';
import 'models.dart';
import 'exercise_detail_screen.dart';

class WorkoutCard extends StatelessWidget {
  final Workout workout;

  WorkoutCard({
    required this.workout,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      child: ListTile(
        leading: Icon(Icons.fitness_center),
        title: Text(workout.title),
        subtitle: Text('${workout.workingSets.length} sets'),
        trailing: Icon(Icons.more_vert),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseDetailScreen(
                title: workout.title,
                warmUpSets: workout.warmUpSets,
                workingSets: workout.workingSets,
              ),
            ),
          );
        },
      ),
    );
  }
}
