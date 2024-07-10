class Workout {
  final String title;
  final List<ExerciseSet> warmUpSets;
  final List<ExerciseSet> workingSets;

  Workout({
    required this.title,
    required this.warmUpSets,
    required this.workingSets,
  });
}

class ExerciseSet {
  int reps;
  int weight;

  ExerciseSet({required this.reps, required this.weight});
}
