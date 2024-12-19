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

  static const Map<String, String> bidenContent = {
    'https://i.giphy.com/media/v1.Y2lkPTc5MGI3NjExa2Jjc2U4d2p6azNjcDUwMThvMHJtc3JkNmMxa3JjN2hvanI2enNsNCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/4F4lRI7NDcYDTT9aZI/giphy.gif': 
        "YOU GOT IT, JACK!",  // Thumbs up
    'https://i.giphy.com/media/v1.Y2lkPTc5MGI3NjExejVtOWpjcGdwc3p1bWFvZDkzcDNvZmRrcjRoemNpbDNhZHoxejRuMiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/Y1qcnIBrILmQ25p7vl/giphy.gif': 
        "HERE'S THE DEAL:\nYOU'RE PARDONED!",  // Pointing and smiling
    'https://i.giphy.com/media/v1.Y2lkPTc5MGI3NjExb2hpMjA4OHg0Mm95d3o2cDRjNWZkbHBtMWVuYmV3YWRjdHduaGdseSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/Kwi0Iu9MxxOgg/giphy.gif': 
        "NO MALARKEY,\nTHAT WAS GOOD!",  // Laughing
    'https://i.giphy.com/media/v1.Y2lkPTc5MGI3NjExZTlzM3NrZHhzdno4cXY1ZWxza2RoOWFlaXZkMDQ3Zm15ZXBubDgwNyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/rX6REfmpQKqkGazkzm/giphy.gif': 
        "AND THAT'S\nNO JOKE, FOLKS!",  // Not a Joke
  };

  late final String selectedGif;
  late final String selectedMessage;

  @override
  void initState() {
    super.initState();
    final random = Random();
    final entries = bidenContent.entries.toList();
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
                  Image.network(
                    selectedGif,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        height: 200,
                        width: 200,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        height: 200,
                        width: 200,
                        child: Center(
                          child: Icon(Icons.error),
                        ),
                      );
                    },
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
