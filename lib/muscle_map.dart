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
        ..._buildMuscles(context),
      ],
    );
  }

  List<Widget> _buildMuscles(BuildContext context) {
    return [
      _buildMuscle(context, 'assets/muscles/schultern.svg', 'Schultern'),
      _buildMuscle(context, 'assets/muscles/brust.svg', 'Brust'),
      _buildMuscle(context, 'assets/muscles/bizeps.svg', 'Bizeps'),
      _buildMuscle(context, 'assets/muscles/trizeps.svg', 'Trizeps'),
      _buildMuscle(context, 'assets/muscles/rücken.svg', 'Rücken'),
      _buildMuscle(context, 'assets/muscles/bauch.svg', 'Bauch'),
      _buildMuscle(context, 'assets/muscles/beine.svg', 'Beine'),
      _buildMuscle(context, 'assets/muscles/waden.svg', 'Waden'),
      _buildMuscle(context, 'assets/muscles/arsch.svg', 'Arsch'),
      _buildMuscle(context, 'assets/muscles/adduktoren.svg', 'Adduktoren'),
      _buildMuscle(context, 'assets/muscles/ellbogen.svg', 'Ellbogen'),
      _buildMuscle(context, 'assets/muscles/füße.svg', 'Füße'),
      _buildMuscle(context, 'assets/muscles/handgelenk.svg', 'Handgelenk'),
      _buildMuscle(context, 'assets/muscles/hüfte.svg', 'Hüfte'),
      _buildMuscle(context, 'assets/muscles/knie.svg', 'Knie'),
      _buildMuscle(context, 'assets/muscles/nacken.svg', 'Nacken'),
      _buildMuscle(context, 'assets/muscles/oberschenkel.svg', 'Oberschenkel'),
      _buildMuscle(context, 'assets/muscles/schrägbauchmuskeln.svg',
          'Schrägbauchmuskeln'),
      _buildMuscle(context, 'assets/muscles/unterarm.svg', 'Unterarm'),
      _buildMuscle(
          context, 'assets/muscles/unterer_rücken.svg', 'Unterer Rücken'),
    ];
  }

  Widget _buildMuscle(
      BuildContext context, String assetPath, String muscleName) {
    return FutureBuilder<String>(
      future: _loadSvgAsString(context, assetPath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          String svgString = snapshot.data!;
          Color muscleColor =
              activeMuscles.contains(muscleName) ? Colors.blue : Colors.grey;
          Color outlineColor = activeMuscles.contains(muscleName)
              ? Colors.blue[900]!
              : Colors.grey[800]!;

          // Update the SVG string with new fill and stroke colors
          String colorString =
              '#${muscleColor.value.toRadixString(16).substring(2)}';
          String outlineColorString =
              '#${outlineColor.value.toRadixString(16).substring(2)}';

          // Update fill and stroke with color and outlineColor
          String updatedSvgString = svgString
              .replaceAll(RegExp(r'fill:[^;]+;'), 'fill:$colorString;')
              .replaceAll(
                  RegExp(r'stroke:[^;]+;'), 'stroke:$outlineColorString;');

          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: SvgPicture.string(
              updatedSvgString,
              fit: BoxFit.contain,
            ),
          );
        } else {
          return Container(); // Return an empty container while loading
        }
      },
    );
  }

  Future<String> _loadSvgAsString(
      BuildContext context, String assetPath) async {
    return await DefaultAssetBundle.of(context).loadString(assetPath);
  }
}
