// screens/edit_card_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/card.dart';

class EditCardScreen extends StatefulWidget {
  final Function(CommCard) onSave;
  // FIX: Added optional existingCard so this screen doubles as an edit screen,
  // completing the TODO in carer_mode.dart.
  final CommCard? existingCard;

  const EditCardScreen({super.key, required this.onSave, this.existingCard});

  @override
  State<EditCardScreen> createState() => _EditCardScreenState();
}

class _EditCardScreenState extends State<EditCardScreen> {
  late final TextEditingController _textController;
  String? _imagePath;
  String _category = 'Basic';
  String _language = 'en';

  static const List<String> _categories = ['Basic', 'Feelings', 'Pain', 'Food', 'Other'];
  static const Map<String, String> _languages = {
    'English':  'en',
    'Español':  'es',
    'Français': 'fr',
    'Deutsch':  'de',
    '中文':      'zh',
  };

  @override
  void initState() {
    super.initState();
    // Pre-populate fields if we're editing an existing card
    final existing = widget.existingCard;
    _textController = TextEditingController(text: existing?.text ?? '');
    _imagePath  = existing?.imagePath;
    _category   = existing?.category ?? 'Basic';
    _language   = existing?.language ?? 'en';
  }

  // FIX: Dispose the controller. Previously it leaked on every Add/Edit screen open.
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => _imagePath = file.path);
    }
  }

  void _save() {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter text for the card')),
      );
      return;
    }

    widget.onSave(CommCard(
      id: widget.existingCard?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      imagePath: _imagePath,
      category: _category,
      language: _language,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingCard != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Card' : 'Add New Card')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                labelText: 'What should the button say?',
                labelStyle: TextStyle(fontSize: 18),
              ),
              style: const TextStyle(fontSize: 24),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 20),

            // Image preview + picker
            if (_imagePath != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  // FIX: Use Image.file — imagePath comes from ImagePicker and is
                  // a filesystem path, not an asset bundle path (Image.asset fails).
                  child: Image.file(
                    File(_imagePath!),
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image, size: 80),
                  ),
                ),
              ),
            ElevatedButton.icon(
              icon: const Icon(Icons.photo_library),
              label: Text(_imagePath == null ? 'Choose Photo from Gallery' : 'Change Photo'),
              onPressed: _pickImage,
            ),
            const SizedBox(height: 20),

            // Category picker
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),

            // Language picker
            DropdownButtonFormField<String>(
              value: _language,
              decoration: const InputDecoration(labelText: 'Language'),
              items: _languages.entries
                  .map((e) => DropdownMenuItem(value: e.value, child: Text(e.key)))
                  .toList(),
              onChanged: (v) => setState(() => _language = v!),
            ),

            const Spacer(),
            ElevatedButton(
              onPressed: _save,
              child: Text(
                isEditing ? 'Save Changes' : 'Save Card',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
