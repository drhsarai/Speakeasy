// screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:reorderables/reorderables.dart';
import 'dart:convert';
import '../models/card.dart';
import '../widgets/comm_card.dart';
import '../services/tts_service.dart';
import 'carer_mode.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CommCard> _cards = [];
  String _currentLang = 'en';

  // FIX: Removed `final FlutterTts _tts = FlutterTts()` — that instance was
  // never initialised, so the language/rate/pitch set in TTSService.init() had
  // no effect on the cards. All TTS now goes through TTSService.

  // Language display name → short BCP-47 base code used by TTSService.
  static const Map<String, String> _langOptions = {
    'English':   'en',
    'Español':   'es',
    'Français':  'fr',
    'Deutsch':   'de',
    '中文':       'zh',
  };

  @override
  void initState() {
    super.initState();
    TTSService.init();
    _loadCards();
    _checkTrial();
  }

  Future<void> _loadCards() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('cards') ?? [];

    // FIX: Wrap JSON decode in try/catch so a single corrupt entry doesn't
    // crash the whole load. Bad entries are silently skipped.
    final parsed = <CommCard>[];
    for (final s in saved) {
      try {
        parsed.add(CommCard.fromJson(json.decode(s) as Map<String, dynamic>));
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      _cards = parsed;
      if (_cards.isEmpty) _loadStarterPack();
    });
  }

  void _loadStarterPack() {
    _cards = [
      CommCard(id: '1', text: 'Hello',      category: 'Basic',    language: 'en'),
      CommCard(id: '2', text: 'Water',      category: 'Basic',    language: 'en'),
      CommCard(id: '3', text: 'Hungry',     category: 'Basic',    language: 'en'),
      CommCard(id: '4', text: 'Toilet',     category: 'Basic',    language: 'en'),
      CommCard(id: '5', text: 'Pain',       category: 'Pain',     language: 'en'),
      CommCard(id: '6', text: 'Help',       category: 'Basic',    language: 'en'),
      CommCard(id: '7', text: 'Yes',        category: 'Basic',    language: 'en'),
      CommCard(id: '8', text: 'No',         category: 'Basic',    language: 'en'),
      CommCard(id: '9', text: 'I love you', category: 'Feelings', language: 'en'),
    ];
    _saveCards(); // intentionally not awaited here; called inside setState
  }

  Future<void> _saveCards() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'cards',
      _cards.map((c) => json.encode(c.toJson())).toList(),
    );
  }

  Future<void> _checkTrial() async {
    final prefs = await SharedPreferences.getInstance();

    // FIX: Previously this read trialStart and fell back to now, but NEVER
    // saved it — so daysUsed was always ~0 and the trial nag never appeared.
    // Now we save the start timestamp on first run.
    int? start = prefs.getInt('trialStart');
    if (start == null) {
      start = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt('trialStart', start);
    }

    final daysUsed = (DateTime.now().millisecondsSinceEpoch - start) / 86400000;

    // FIX: Guard against using context after the widget has been disposed
    // (the await above means the widget tree might have changed).
    if (!mounted) return;

    if (daysUsed > 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('30-day free trial ended. \$10/year unlocks updates & new cards.'),
          duration: Duration(seconds: 6),
        ),
      );
    }
  }

  void _showLanguagePicker() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Change Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          // FIX: Use the explicit _langOptions map rather than slicing display
          // names. The old approach broke for '中文' (produces '中文', not a valid
          // locale code) and would be fragile for any future additions.
          children: _langOptions.entries.map((entry) => ListTile(
            title: Text(entry.key),
            selected: _currentLang == entry.value,
            onTap: () {
              setState(() => _currentLang = entry.value);
              Navigator.pop(context);
            },
          )).toList(),
        ),
      ),
    );
  }

  void _enterCarerMode(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CarerModeScreen(
          cards: _cards,
          onCardsChanged: (newCards) {
            setState(() => _cards = newCards);
            _saveCards();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SpeakEasy AAC',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, size: 32),
            onPressed: _showLanguagePicker,
            tooltip: 'Change language',
          ),
          IconButton(
            icon: const Icon(Icons.settings, size: 32),
            onPressed: () => _enterCarerMode(context),
            tooltip: 'Carer mode',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _cards.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ReorderableWrap(
                spacing: 16,
                runSpacing: 16,
                // FIX: CommunicationCard no longer needs a tts parameter
                children: _cards
                    .map((card) => CommunicationCard(key: ValueKey(card.id), card: card))
                    .toList(),
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    final item = _cards.removeAt(oldIndex);
                    _cards.insert(newIndex, item);
                  });
                  _saveCards();
                },
              ),
      ),
    );
  }
}
