// screens/carer_mode.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/card.dart';
import 'edit_card_screen.dart';

class CarerModeScreen extends StatefulWidget {
  final List<CommCard> cards;
  final Function(List<CommCard>) onCardsChanged;

  const CarerModeScreen({
    super.key,
    required this.cards,
    required this.onCardsChanged,
  });

  @override
  State<CarerModeScreen> createState() => _CarerModeScreenState();
}

class _CarerModeScreenState extends State<CarerModeScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _unlocked = false;
  String _storedPin = '1234'; // loaded from prefs in initState
  bool _obscurePin = true;

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  // FIX: Previously the PIN was hardcoded as a plain string literal in source.
  // It is now loaded from (and saved to) SharedPreferences so it persists and
  // can be changed by the carer without recompiling.
  Future<void> _loadPin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _storedPin = prefs.getString('carerPin') ?? '1234';
    });
  }

  Future<void> _savePin(String newPin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('carerPin', newPin);
    if (!mounted) return;
    setState(() => _storedPin = newPin);
  }

  // FIX: Dispose controllers to avoid memory leaks.
  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _tryUnlock() {
    if (_pinController.text == _storedPin) {
      setState(() => _unlocked = true);
      _pinController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect PIN')),
      );
      _pinController.clear();
    }
  }

  void _showChangePinDialog() {
    final newPinController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Change PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: newPinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New 4-digit PIN'),
            ),
            TextField(
              controller: confirmController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm new PIN'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPinController.text.length == 4 &&
                  newPinController.text == confirmController.text) {
                _savePin(newPinController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PIN updated')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PINs must match and be 4 digits')),
                );
              }
              newPinController.dispose();
              confirmController.dispose();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // FIX: Added card deletion functionality (was entirely missing).
  void _deleteCard(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete card?'),
        content: Text('Remove "${widget.cards[index].text}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final updated = List<CommCard>.from(widget.cards)..removeAt(index);
              widget.onCardsChanged(updated);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_unlocked) {
      return Scaffold(
        appBar: AppBar(title: const Text('Carer Mode — Enter PIN')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter 4-digit PIN', style: TextStyle(fontSize: 22)),
                const SizedBox(height: 20),
                TextField(
                  controller: _pinController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  textAlign: TextAlign.center,
                  obscureText: _obscurePin,
                  style: const TextStyle(fontSize: 32),
                  onSubmitted: (_) => _tryUnlock(),
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePin ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePin = !_obscurePin),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _tryUnlock,
                  child: const Text('Unlock Carer Mode', style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Unlocked Carer Mode
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carer Mode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock),
            tooltip: 'Change PIN',
            onPressed: _showChangePinDialog,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add New Card'),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditCardScreen(
                  onSave: (newCard) {
                    final updated = List<CommCard>.from(widget.cards)..add(newCard);
                    widget.onCardsChanged(updated);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Current Cards:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // FIX: Added delete button. Previously the trailing only had an edit
          // icon with a TODO comment and no delete option at all.
          ...List.generate(widget.cards.length, (i) {
            final c = widget.cards[i];
            return ListTile(
              title: Text(c.text),
              subtitle: Text('${c.category} · ${c.language}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: 'Edit',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditCardScreen(
                          existingCard: c,
                          onSave: (updated) {
                            final list = List<CommCard>.from(widget.cards);
                            list[i] = updated;
                            widget.onCardsChanged(list);
                          },
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Delete',
                    onPressed: () => _deleteCard(i),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            icon: const Icon(Icons.cloud_download),
            label: const Text('Check for Updates'),
            onPressed: () {/* TODO: Call UpdateService */},
          ),
        ],
      ),
    );
  }
}
