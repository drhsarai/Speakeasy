// widgets/comm_card.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../models/card.dart';
import '../services/tts_service.dart';

class CommunicationCard extends StatelessWidget {
  final CommCard card;

  // FIX: Removed the FlutterTts tts parameter. Previously HomeScreen created its
  // own FlutterTts instance (separate from TTSService's static instance) that was
  // never initialised — so language, rate, pitch and volume settings had no effect.
  // All speech now goes through the single TTSService instance.
  const CommunicationCard({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => TTSService.speak(card.text, lang: card.language),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(12),
          width: 140,
          height: 140,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildImage(),
              const SizedBox(height: 8),
              Text(
                card.text,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (card.imagePath == null) {
      return const Icon(Icons.message, size: 80, color: Colors.blue);
    }

    // FIX: Previously used Image.asset() for imagePath values that come from
    // ImagePicker, which returns absolute filesystem paths — not asset bundle
    // paths. Image.asset() silently fails on these and the errorBuilder shows
    // a broken-image icon. Use Image.file() instead for picker-sourced paths.
    return Image.file(
      File(card.imagePath!),
      width: 80,
      height: 80,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 80, color: Colors.grey),
    );
  }
}
