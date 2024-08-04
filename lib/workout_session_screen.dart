import 'package:flutter/material.dart';
import 'dart:async';

class WorkoutSessionScreen extends StatefulWidget {
  final String duration;

  WorkoutSessionScreen({required this.duration});

  @override
  _WorkoutSessionScreenState createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  late Timer _timer;
  late int _elapsedSeconds;
  late int _totalSeconds;

  @override
  void initState() {
    super.initState();
    _elapsedSeconds = 0;
    _totalSeconds = _parseDuration(widget.duration);
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });

      if (_elapsedSeconds >= _totalSeconds) {
        _timer.cancel();
      }
    });
  }

  int _parseDuration(String duration) {
    final parts = duration.split(' ');
    final hours = int.parse(parts[0].substring(0, parts[0].length - 1));
    final minutes = int.parse(parts[1].substring(0, parts[1].length - 1));
    return hours * 3600 + minutes * 60;
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout Session'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Duration: ${widget.duration}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Text(
              'Elapsed Time: ${_formatDuration(_elapsedSeconds)}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Text(
              'Remaining Time: ${_formatDuration(_totalSeconds - _elapsedSeconds)}',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
      // Hier verwenden wir heroTag, um es eindeutig zu machen
      floatingActionButton: FloatingActionButton(
        heroTag:
            'workoutSessionFab', // Eindeutiges heroTag für diesen FloatingActionButton
        onPressed: () {
          // Aktion, die ausgeführt werden soll, wenn der Button gedrückt wird
          Navigator.pop(
              context); // Beispiel: Gehe zurück zum vorherigen Bildschirm
        },
        child: Icon(Icons.stop),
      ),
    );
  }
}
