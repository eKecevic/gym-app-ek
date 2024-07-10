import 'package:flutter/material.dart';
import 'models.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final String title;
  final List<ExerciseSet> warmUpSets;
  final List<ExerciseSet> workingSets;

  ExerciseDetailScreen({
    required this.title,
    required this.warmUpSets,
    required this.workingSets,
  });

  @override
  _ExerciseDetailScreenState createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {
  late List<ExerciseSet> warmUpSets;
  late List<ExerciseSet> workingSets;

  @override
  void initState() {
    super.initState();
    warmUpSets = widget.warmUpSets;
    workingSets = widget.workingSets;
  }

  void _addWarmUpSet() {
    setState(() {
      warmUpSets.add(ExerciseSet(reps: 0, weight: 0));
    });
  }

  void _addWorkingSet() {
    setState(() {
      workingSets.add(ExerciseSet(reps: 0, weight: 0));
    });
  }

  void _removeWarmUpSet(int index) {
    setState(() {
      warmUpSets.removeAt(index);
    });
  }

  void _removeWorkingSet(int index) {
    setState(() {
      workingSets.removeAt(index);
    });
  }

  void _updateReps(ExerciseSet set, String reps) {
    setState(() {
      set.reps = int.tryParse(reps) ?? set.reps;
    });
  }

  void _updateWeight(ExerciseSet set, String weight) {
    setState(() {
      set.weight = int.tryParse(weight) ?? set.weight;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(8.0),
        children: [
          _buildSetList(
            title: 'WARM-UP SETS',
            sets: warmUpSets,
            onAddSet: _addWarmUpSet,
            onRemoveSet: _removeWarmUpSet,
          ),
          SizedBox(height: 20),
          _buildSetList(
            title: 'WORKING SETS',
            sets: workingSets,
            onAddSet: _addWorkingSet,
            onRemoveSet: _removeWorkingSet,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Save or any other action
            },
            child: Text('Start Workout'),
          ),
        ],
      ),
    );
  }

  Widget _buildSetList({
    required String title,
    required List<ExerciseSet> sets,
    required VoidCallback onAddSet,
    required void Function(int) onRemoveSet,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$title',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ...sets.asMap().entries.map((entry) {
          int index = entry.key;
          ExerciseSet set = entry.value;
          return Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: set.reps.toString(),
                  decoration: InputDecoration(labelText: 'Reps'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _updateReps(set, value),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  initialValue: set.weight.toString(),
                  decoration: InputDecoration(labelText: 'Weight'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _updateWeight(set, value),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => onRemoveSet(index),
              ),
            ],
          );
        }).toList(),
        SizedBox(height: 10),
        TextButton(
          onPressed: onAddSet,
          child: Text('Add Set'),
        ),
      ],
    );
  }
}
