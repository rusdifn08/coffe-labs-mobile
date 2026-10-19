import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _beanController = TextEditingController();
  final _tempController = TextEditingController();
  final _coffeeController = TextEditingController();
  final _waterController = TextEditingController();
  final _descController = TextEditingController();
  
  String _selectedCategory = 'V60';
  final List<Map<String, dynamic>> _steps = [];

  bool _isSubmitting = false;

  void _addStep() {
    setState(() {
      _steps.add({
        "title": TextEditingController(),
        "timeSeconds": TextEditingController(),
        "waterGrams": TextEditingController(),
      });
    });
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one step!'))
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      int totalTime = 0;
      List<Map<String, dynamic>> parsedSteps = [];
      
      for (var s in _steps) {
        int time = int.parse((s["timeSeconds"] as TextEditingController).text);
        int water = int.parse((s["waterGrams"] as TextEditingController).text);
        totalTime += time;
        parsedSteps.add({
          "title": (s["title"] as TextEditingController).text,
          "timeSeconds": time,
          "waterGrams": water,
        });
      }

      Map<String, dynamic> payload = {
        "title": _titleController.text,
        "author": _authorController.text,
        "coverImageUrl": "https://images.unsplash.com/photo-1511920170033-f8396924c348?w=1200&h=675&fit=crop",
        "authorAvatarUrl": "https://i.pravatar.cc/512?img=50",
        "authorImageUrl": "https://images.unsplash.com/photo-1511920170033-f8396924c348?w=1200&h=675&fit=crop",
        "beanName": _beanController.text,
        "method": _selectedCategory,
        "category": _selectedCategory,
        "waterTempCelsius": int.parse(_tempController.text),
        "coffeeWeightGrams": int.parse(_coffeeController.text),
        "totalWaterWeightGrams": int.parse(_waterController.text),
        "totalTimeSeconds": totalTime,
        "description": _descController.text,
        "isCustom": true,
        "steps": parsedSteps
      };

      await ApiService.createRecipe(payload);
      if (mounted) {
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Recipe'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildSectionTitle('General Info'),
            _buildTextField(_titleController, 'Recipe Title', CupertinoIcons.doc_text),
            _buildTextField(_authorController, 'Author Name', CupertinoIcons.person),
            _buildTextField(_beanController, 'Bean Name (e.g. Ethiopia Natural)', CupertinoIcons.circle),
            
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                prefixIcon: const Icon(CupertinoIcons.tag),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              items: ['V60', 'Japanese Iced', 'Vietnam Drip']
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedCategory = val);
              },
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Parameters'),
            Row(
              children: [
                Expanded(child: _buildTextField(_tempController, 'Temp (°C)', CupertinoIcons.thermometer, isNumber: true)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(_coffeeController, 'Coffee (g)', CupertinoIcons.cube_box, isNumber: true)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField(_waterController, 'Water (g)', CupertinoIcons.drop, isNumber: true)),
              ],
            ),
            _buildTextField(_descController, 'Description', CupertinoIcons.text_quote, maxLines: 3),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle('Brewing Steps'),
                TextButton.icon(
                  onPressed: _addStep,
                  icon: const Icon(CupertinoIcons.add),
                  label: const Text('Add Step'),
                )
              ],
            ),
            ..._steps.asMap().entries.map((entry) {
              int index = entry.key;
              var step = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primaryBrown.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Step ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(CupertinoIcons.trash, color: Colors.red, size: 20),
                          onPressed: () => _removeStep(index),
                        )
                      ],
                    ),
                    _buildTextField(step['title'], 'Step Title (e.g. Blooming)', CupertinoIcons.tag),
                    Row(
                      children: [
                        Expanded(child: _buildTextField(step['timeSeconds'], 'Duration (s)', CupertinoIcons.timer, isNumber: true)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField(step['waterGrams'], 'Water Added (g)', CupertinoIcons.drop, isNumber: true)),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 40),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save & Publish Recipe', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
