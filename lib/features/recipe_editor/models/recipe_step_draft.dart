import 'package:flutter/material.dart';

class RecipeStepDraft {
  final TextEditingController titleCtrl;
  final TextEditingController durationCtrl;
  final TextEditingController waterCtrl;
  final TextEditingController instructionCtrl;

  RecipeStepDraft({
    String title = '',
    String duration = '35',
    String water = '50',
    String instruction = '',
  })  : titleCtrl = TextEditingController(text: title),
        durationCtrl = TextEditingController(text: duration),
        waterCtrl = TextEditingController(text: water),
        instructionCtrl = TextEditingController(text: instruction);

  void dispose() {
    titleCtrl.dispose();
    durationCtrl.dispose();
    waterCtrl.dispose();
    instructionCtrl.dispose();
  }
}
