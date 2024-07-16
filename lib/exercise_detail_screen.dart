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
    setState(() {
      workout.warmUpSets.add(ExerciseSet(reps: 10, weight: 40));
      widget.onSave(workout);
    });
  }

  void addWorkingSet() {
    setState(() {
      workout.workingSets.add(ExerciseSet(reps: 8, weight: 60));
      widget.onSave(workout);
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
            title: Text('Warm-up Sets'),
            trailing: ElevatedButton(
              onPressed: addWarmUpSet,
              child: Text('Add Warm-up Set'),
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
                      decoration: InputDecoration(labelText: 'Reps'),
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
                      decoration: InputDecoration(labelText: 'Weight'),
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
            title: Text('Working Sets'),
            trailing: ElevatedButton(
              onPressed: addWorkingSet,
              child: Text('Add Working Set'),
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
                      decoration: InputDecoration(labelText: 'Reps'),
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
                      decoration: InputDecoration(labelText: 'Weight'),
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
}
