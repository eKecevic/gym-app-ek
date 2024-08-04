import 'package:flutter/material.dart';
import 'dart:async';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'models.dart';

class WorkoutExecutionScreen extends StatefulWidget {
  final List<Workout> workouts;
  final String selectedDuration;
  final String selectedRestTime;

  WorkoutExecutionScreen({
    required this.workouts,
    required this.selectedDuration,
    required this.selectedRestTime,
  });

  @override
  _WorkoutExecutionScreenState createState() => _WorkoutExecutionScreenState();
}

class _WorkoutExecutionScreenState extends State<WorkoutExecutionScreen> {
  int currentExerciseIndex = 0;
  int currentSetIndex = 0;
  late Timer workoutTimer;
  late Timer restTimer;
  int remainingTime = 0;
  int totalDuration = 0;
  int setStartTime = 0;
  int lastSetDuration = 0;
  ExerciseSet? lastSet;
  bool isResting = false;
  int restTime = 0;
  int remainingRestTime = 0;
  bool showRestPopup = false;
  bool canSkipRest = false; // Flag to track if rest can be skipped
  late int currentSetDuration; // New variable to track current set duration

  @override
  void initState() {
    super.initState();
    totalDuration = getDurationInMinutes(widget.selectedDuration) * 60;
    restTime = getRestTimeInSeconds(widget.selectedRestTime);
    startWorkoutTimer();
    currentSetDuration = 0; // Initialize currentSetDuration
  }

  @override
  void dispose() {
    workoutTimer.cancel();
    restTimer?.cancel();
    super.dispose();
  }

  void startWorkoutTimer() {
    workoutTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime < totalDuration) {
          remainingTime++;
          if (!isResting) {
            currentSetDuration++; // Increment only when not resting
          }
        } else {
          timer.cancel();
        }
      });
    });
  }

  void startRestTimer() {
    remainingRestTime = restTime;
    restTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingRestTime > 0) {
          remainingRestTime--;
        } else {
          timer.cancel();
          isResting = false;
          showRestPopup = false;
          canSkipRest = false; // Reset flag
          proceedToNextSet();
        }
      });
    });
  }

  void proceedToNextSet() {
    if (currentSetIndex <
        widget.workouts[currentExerciseIndex].workingSets.length - 1) {
      currentSetIndex++;
      currentSetDuration = 0; // Reset duration for the next set
    } else if (currentExerciseIndex < widget.workouts.length - 1) {
      currentExerciseIndex++;
      currentSetIndex = 0;
      currentSetDuration = 0; // Reset duration for the next set
    } else {
      // Workout completed
      workoutTimer.cancel();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Workout Completed'),
          content: Text('You have completed your workout!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void nextSet() {
    if (isResting) {
      if (canSkipRest) {
        // Skip rest time if the flag is true
        restTimer.cancel();
        isResting = false;
        showRestPopup = false;
        canSkipRest = false;
        proceedToNextSet();
      } else {
        // Just hide the popup on the first click
        setState(() {
          showRestPopup = false;
          canSkipRest =
              true; // Set the flag to allow skipping rest on the next click
        });
      }
    } else {
      setState(() {
        lastSetDuration = currentSetDuration; // Update last set duration
        lastSet =
            widget.workouts[currentExerciseIndex].workingSets[currentSetIndex];
        setStartTime = remainingTime;
        isResting = true;
        showRestPopup = true;
        canSkipRest = false; // Reset the flag
        startRestTimer();
      });
    }
  }

  void previousSet() {
    if (isResting) return;
    setState(() {
      if (currentSetIndex > 0) {
        currentSetIndex--;
      } else if (currentExerciseIndex > 0) {
        currentExerciseIndex--;
        currentSetIndex =
            widget.workouts[currentExerciseIndex].workingSets.length - 1;
      }
      setStartTime = remainingTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalSets = widget.workouts
        .fold<int>(0, (sum, workout) => sum + workout.workingSets.length);
    final completedSets = widget.workouts
            .take(currentExerciseIndex)
            .fold<int>(0, (sum, workout) => sum + workout.workingSets.length) +
        currentSetIndex;
    final progress = completedSets / totalSets;
    final bufferSize = 1 / widget.workouts.length;
    final bufferProgress = (currentExerciseIndex + 1) * bufferSize;

    return Scaffold(
      appBar: AppBar(
        title: Text('Workout Execution'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 10),
              Align(
                alignment: Alignment.topCenter,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularPercentIndicator(
                      radius: 100.0,
                      lineWidth: 8.0,
                      percent: bufferProgress,
                      progressColor: Colors.tealAccent.withOpacity(0.5),
                      backgroundColor: Colors.grey.withOpacity(0.2),
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                    CircularPercentIndicator(
                      radius: 90.0,
                      lineWidth: 8.0,
                      percent: progress,
                      center: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${(progress * 100).toStringAsFixed(1)}%'),
                          Text(
                            '${Duration(seconds: remainingTime).inHours.toString().padLeft(2, '0')}:${Duration(seconds: remainingTime).inMinutes.remainder(60).toString().padLeft(2, '0')}:${(remainingTime % 60).toString().padLeft(2, '0')} / ${widget.selectedDuration}',
                          ),
                        ],
                      ),
                      progressColor: Colors.green,
                      backgroundColor: Colors.transparent,
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Text(
                widget.workouts[currentExerciseIndex].title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Color.fromARGB(255, 250, 255, 232),
                child: Padding(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Set ${currentSetIndex + 1}/${widget.workouts[currentExerciseIndex].workingSets.length}',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      Text(
                        '${widget.workouts[currentExerciseIndex].workingSets[currentSetIndex].reps} reps - ${widget.workouts[currentExerciseIndex].workingSets[currentSetIndex].weight} kg',
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                'Set Duration: ${currentSetDuration ~/ 60}:${(currentSetDuration % 60).toString().padLeft(2, '0')}', // Updated to use currentSetDuration
                style: TextStyle(fontSize: 16),
              ),
              if (isResting) // Display rest time countdown only if resting
                Text(
                  'Rest Time: ${remainingRestTime ~/ 60}:${(remainingRestTime % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(
                      fontSize: 16, color: Color.fromARGB(255, 184, 205, 0)),
                ),
              Text(
                lastSet != null
                    ? 'Last Set Duration: ${lastSetDuration ~/ 60}:${(lastSetDuration % 60).toString().padLeft(2, '0')} (${lastSet?.reps} reps - ${lastSet?.weight} kg)'
                    : 'Last Set Duration: N/A',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 10),
              Spacer(), // Use Spacer to push buttons to the bottom
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: previousSet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back, color: Colors.white),
                        SizedBox(width: 5),
                        Text("Previous Set",
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: nextSet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Row(
                      children: [
                        Text("Next Set", style: TextStyle(color: Colors.white)),
                        SizedBox(width: 5),
                        Icon(Icons.arrow_forward, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                'Next: ${widget.workouts[currentExerciseIndex].workingSets[(currentSetIndex + 1) % widget.workouts[currentExerciseIndex].workingSets.length].reps} reps - ${widget.workouts[currentExerciseIndex].workingSets[(currentSetIndex + 1) % widget.workouts[currentExerciseIndex].workingSets.length].weight} kg',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          if (showRestPopup) // Show popup if needed
            Positioned(
              top: 50,
              left: MediaQuery.of(context).size.width * 0.2,
              child: Card(
                color: Colors.blueAccent,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Time to Rest!',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  int getDurationInMinutes(String duration) {
    final parts = duration.split(' ');
    final hours = int.parse(parts[0].replaceAll('h', ''));
    final minutes = int.parse(parts[1].replaceAll('m', ''));
    return hours * 60 + minutes;
  }

  int getRestTimeInSeconds(String restTime) {
    return int.parse(restTime.replaceAll('m', '')) * 60;
  }
}
