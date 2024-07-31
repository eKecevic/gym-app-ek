import 'package:flutter/material.dart';
import 'models.dart';

class CreateExerciseScreen extends StatefulWidget {
  @override
  _CreateExerciseScreenState createState() => _CreateExerciseScreenState();
}

class _CreateExerciseScreenState extends State<CreateExerciseScreen> {
  String title = '';
  String type = 'custom';
  List<ExerciseSet> warmUpSets = [];
  List<ExerciseSet> workingSets = [];
  List<String> selectedMuscles = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Neue Übung erstellen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Übungsname'),
              onChanged: (value) {
                setState(() {
                  title = value;
                });
              },
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 8.0,
              children: [
                FilterChip(
                  label: Text('Brust'),
                  selected: selectedMuscles.contains('Brust'),
                  onSelected: (isSelected) {
                    setState(() {
                      isSelected
                          ? selectedMuscles.add('Brust')
                          : selectedMuscles.remove('Brust');
                    });
                  },
                ),
                FilterChip(
                  label: Text('Trizeps'),
                  selected: selectedMuscles.contains('Trizeps'),
                  onSelected: (isSelected) {
                    setState(() {
                      isSelected
                          ? selectedMuscles.add('Trizeps')
                          : selectedMuscles.remove('Trizeps');
                    });
                  },
                ),
                FilterChip(
                  label: Text('Schultern'),
                  selected: selectedMuscles.contains('Schultern'),
                  onSelected: (isSelected) {
                    setState(() {
                      isSelected
                          ? selectedMuscles.add('Schultern')
                          : selectedMuscles.remove('Schultern');
                    });
                  },
                ),
                FilterChip(
                  label: Text('Beine'),
                  selected: selectedMuscles.contains('Beine'),
                  onSelected: (isSelected) {
                    setState(() {
                      isSelected
                          ? selectedMuscles.add('Beine')
                          : selectedMuscles.remove('Beine');
                    });
                  },
                ),
                // Füge hier weitere Muskelgruppen hinzu, falls erforderlich
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _addSetDialog(context, 'Warm-Up Set hinzufügen',
                    (reps, weight) {
                  setState(() {
                    warmUpSets.add(ExerciseSet(reps: reps, weight: weight));
                  });
                });
              },
              child: Text('Warm-Up Set hinzufügen'),
            ),
            ElevatedButton(
              onPressed: () {
                _addSetDialog(context, 'Arbeitssatz hinzufügen',
                    (reps, weight) {
                  setState(() {
                    workingSets.add(ExerciseSet(reps: reps, weight: weight));
                  });
                });
              },
              child: Text('Arbeitssatz hinzufügen'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: warmUpSets.length + workingSets.length,
                itemBuilder: (context, index) {
                  if (index < warmUpSets.length) {
                    final set = warmUpSets[index];
                    return ListTile(
                      title: Text(
                          '${set.reps} Wiederholungen - ${set.weight} kg (Warm-Up)'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            warmUpSets.removeAt(index);
                          });
                        },
                      ),
                    );
                  } else {
                    final set = workingSets[index - warmUpSets.length];
                    return ListTile(
                      title:
                          Text('${set.reps} Wiederholungen - ${set.weight} kg'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            workingSets.removeAt(index - warmUpSets.length);
                          });
                        },
                      ),
                    );
                  }
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final newWorkout = Workout(
                  title: title,
                  type: type,
                  warmUpSets: warmUpSets,
                  workingSets: workingSets,
                  muscles: selectedMuscles,
                );
                Navigator.pop(context, newWorkout);
              },
              child: Text('Übung speichern'),
            ),
          ],
        ),
      ),
    );
  }

  void _addSetDialog(
      BuildContext context, String title, Function(int, int) onAdd) {
    int reps = 0;
    int weight = 0;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Wiederholungen'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  reps = int.parse(value);
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Gewicht (kg)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  weight = int.parse(value);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Abbrechen'),
            ),
            TextButton(
              onPressed: () {
                onAdd(reps, weight);
                Navigator.of(context).pop();
              },
              child: Text('Hinzufügen'),
            ),
          ],
        );
      },
    );
  }
}
