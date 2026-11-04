import 'package:flutter/material.dart';

class RecipeEditorControllers {
  final TextEditingController title = TextEditingController();
  final TextEditingController author = TextEditingController(text: 'Barista 🇮🇩');
  final TextEditingController coffee = TextEditingController(text: '15');
  final TextEditingController water = TextEditingController(text: '225');
  final TextEditingController ice = TextEditingController(text: '0');
  final TextEditingController temp = TextEditingController(text: '92');
  final TextEditingController grind = TextEditingController();
  final TextEditingController method = TextEditingController(text: 'Hario V60 02');
  final TextEditingController bean = TextEditingController();
  final TextEditingController tasting = TextEditingController();
  final TextEditingController desc = TextEditingController();

  void dispose() {
    title.dispose();
    author.dispose();
    coffee.dispose();
    water.dispose();
    ice.dispose();
    temp.dispose();
    grind.dispose();
    method.dispose();
    bean.dispose();
    tasting.dispose();
    desc.dispose();
  }
}
