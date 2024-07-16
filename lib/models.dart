class Workout {
  final String title;
  final List<ExerciseSet> warmUpSets;
  final List<ExerciseSet> workingSets;
  final String type;

  Workout({
    required this.title,
    required this.warmUpSets,
    required this.workingSets,
    required this.type,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      title: json['title'],
      warmUpSets: (json['warmUpSets'] as List)
          .map((set) => ExerciseSet.fromJson(set))
          .toList(),
      workingSets: (json['workingSets'] as List)
          .map((set) => ExerciseSet.fromJson(set))
          .toList(),
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'warmUpSets': warmUpSets.map((set) => set.toJson()).toList(),
      'workingSets': workingSets.map((set) => set.toJson()).toList(),
      'type': type,
    };
  }
}

class ExerciseSet {
  int reps;
  int weight;

  ExerciseSet({required this.reps, required this.weight});

  factory ExerciseSet.fromJson(Map<String, dynamic> json) {
    return ExerciseSet(
      reps: json['reps'],
      weight: json['weight'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reps': reps,
      'weight': weight,
    };
  }
}
