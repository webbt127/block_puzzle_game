import 'dart:math';
import 'package:flutter/material.dart';
import 'widgets/patriotic_title.dart';

class PardonPopup extends StatefulWidget {
  const PardonPopup({super.key});

  @override
  State<PardonPopup> createState() => _PardonPopupState();
}

class _PardonPopupState extends State<PardonPopup> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  static const Map<String, String> bidenGifs = {
    'assets/gifs/thumbs_up.gif': "YOU GOT IT, JACK!",  // Thumbs up
    'assets/gifs/pointing.gif': "HERE'S THE DEAL:\nYOU'RE PARDONED!",  // Pointing and smiling
    'assets/gifs/laughing.gif': "NO MALARKEY,\nTHAT WAS GOOD!",  // Laughing
    'assets/gifs/no_joke.gif': "AND THAT'S\nNO JOKE, FOLKS!",  // Not a Joke
  };

  late final String selectedGif;
  late final String selectedMessage;

  @override
  void initState() {
    super.initState();
    final random = Random();
    final entries = bidenGifs.entries.toList();
    final selectedEntry = entries[random.nextInt(entries.length)];
    selectedGif = selectedEntry.key;
    selectedMessage = selectedEntry.value;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward();

    // Auto-dismiss after 5.8 seconds if not tapped
    Future.delayed(const Duration(milliseconds: 5800), () {
      if (mounted) {
        _controller.reverse().then((_) {
          Navigator.of(context).pop();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          _controller.reverse().then((_) {
            Navigator.of(context).pop();
          });
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _opacityAnimation,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    selectedGif,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 16),
                  PatrioticTitle(
                    text: selectedMessage,
                    fontSize: 32,
                    isSecondary: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
