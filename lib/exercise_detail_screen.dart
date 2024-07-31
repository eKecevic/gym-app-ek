import 'package:flutter/material.dart';
import 'models.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Workout workout;
  final Function(Workout) onSave;

  ExerciseDetailScreen({required this.workout, required this.onSave});

  @override
  _ExerciseDetailScreenState createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late Workout workout;

  @override
  void initState() {
    super.initState();
    workout = widget.workout;
  }

  void addWarmUpSet() {
    _addSetDialog(context, 'Warm-Up Set hinzufügen', (reps, weight) {
      setState(() {
        workout.warmUpSets.add(ExerciseSet(reps: reps, weight: weight));
        widget.onSave(workout);
      });
    });
  }

  void addWorkingSet() {
    _addSetDialog(context, 'Arbeitssatz hinzufügen', (reps, weight) {
      setState(() {
        workout.workingSets.add(ExerciseSet(reps: reps, weight: weight));
        widget.onSave(workout);
      });
    });
  }

  void updateWarmUpSet(int index, int reps, int weight) {
    setState(() {
      workout.warmUpSets[index] = ExerciseSet(reps: reps, weight: weight);
      widget.onSave(workout);
    });
  }

  void updateWorkingSet(int index, int reps, int weight) {
    setState(() {
      workout.workingSets[index] = ExerciseSet(reps: reps, weight: weight);
      widget.onSave(workout);
    });
  }

  void deleteWarmUpSet(int index) {
    setState(() {
      workout.warmUpSets.removeAt(index);
      widget.onSave(workout);
    });
  }

  void deleteWorkingSet(int index) {
    setState(() {
      workout.workingSets.removeAt(index);
      widget.onSave(workout);
    });
  }

  void saveChanges() {
    widget.onSave(workout);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workout.title),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: saveChanges,
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Warm-Up Sets'),
            trailing: ElevatedButton(
              onPressed: addWarmUpSet,
              child: Text('Warm-Up Set hinzufügen'),
            ),
          ),
          ...workout.warmUpSets.asMap().entries.map((entry) {
            int index = entry.key;
            ExerciseSet set = entry.value;
            return ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: set.reps.toString(),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Wiederholungen'),
                      onChanged: (value) {
                        int reps = int.tryParse(value) ?? set.reps;
                        updateWarmUpSet(index, reps, set.weight);
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      initialValue: set.weight.toString(),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Gewicht (kg)'),
                      onChanged: (value) {
                        int weight = int.tryParse(value) ?? set.weight;
                        updateWarmUpSet(index, set.reps, weight);
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      deleteWarmUpSet(index);
                    },
                  ),
                ],
              ),
            );
          }),
          ListTile(
            title: Text('Arbeitssätze'),
            trailing: ElevatedButton(
              onPressed: addWorkingSet,
              child: Text('Arbeitssatz hinzufügen'),
            ),
          ),
          ...workout.workingSets.asMap().entries.map((entry) {
            int index = entry.key;
            ExerciseSet set = entry.value;
            return ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: set.reps.toString(),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Wiederholungen'),
                      onChanged: (value) {
                        int reps = int.tryParse(value) ?? set.reps;
                        updateWorkingSet(index, reps, set.weight);
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      initialValue: set.weight.toString(),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: 'Gewicht (kg)'),
                      onChanged: (value) {
                        int weight = int.tryParse(value) ?? set.weight;
                        updateWorkingSet(index, set.reps, weight);
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      deleteWorkingSet(index);
                    },
                  ),
                ],
              ),
            );
          }),
        ],
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
