// muscle_map.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MuscleMap extends StatelessWidget {
  final List<String> activeMuscles;

  MuscleMap({required this.activeMuscles});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SvgPicture.asset(
          'assets/body.svg', // Ensure this path is correct
          fit: BoxFit.contain,
        ),
        _buildMuscle('assets/muscles/schultern.svg', 'Schultern'),
        _buildMuscle('assets/muscles/brust.svg', 'Brust'),
        _buildMuscle('assets/muscles/bizeps.svg', 'Bizeps'),
        _buildMuscle('assets/muscles/trizeps.svg', 'Trizeps'),
        _buildMuscle('assets/muscles/rücken.svg', 'Rücken'),
        _buildMuscle('assets/muscles/bauch.svg', 'Bauch'),
        _buildMuscle('assets/muscles/beine.svg', 'Beine'),
        _buildMuscle('assets/muscles/waden.svg', 'Waden'),
        _buildMuscle('assets/muscles/arsch.svg', 'Arsch'),
        _buildMuscle('assets/muscles/adduktoren.svg', 'Adduktoren'),
        _buildMuscle('assets/muscles/ellbogen.svg', 'Ellbogen'),
        _buildMuscle('assets/muscles/füße.svg', 'Füße'),
        _buildMuscle('assets/muscles/handgelenk.svg', 'Handgelenk'),
        _buildMuscle('assets/muscles/hüfte.svg', 'Hüfte'),
        _buildMuscle('assets/muscles/knie.svg', 'Knie'),
        _buildMuscle('assets/muscles/nacken.svg', 'Nacken'),
        _buildMuscle('assets/muscles/oberschenkel.svg', 'Oberschenkel'),
        _buildMuscle(
            'assets/muscles/schrägbauchmuskeln.svg', 'Schrägbauchmuskeln'),
        _buildMuscle('assets/muscles/unterarm.svg', 'Unterarm'),
        _buildMuscle('assets/muscles/unterer_rücken.svg', 'Unterer Rücken'),
      ],
    );
  }

  Widget _buildMuscle(String assetPath, String muscleName) {
    return SvgPicture.asset(
      assetPath,
      color: activeMuscles.contains(muscleName) ? Colors.blue : Colors.grey,
      fit: BoxFit.contain,
    );
  }
}
