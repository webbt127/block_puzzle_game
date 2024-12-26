import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/games_services.dart';
import 'package:games_services/games_services.dart';
import 'dart:convert';
import 'dart:typed_data';

class TopPlayerShowcase extends ConsumerStatefulWidget {
  const TopPlayerShowcase({super.key});

  @override
  ConsumerState<TopPlayerShowcase> createState() => _TopPlayerShowcaseState();
}

class _TopPlayerShowcaseState extends ConsumerState<TopPlayerShowcase> {
  String? topPlayerName;
  String? topPlayerAvatar;
  int? topScore;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTopPlayer();
  }

  Future<void> _loadTopPlayer() async {
    try {
      if (await GameServicesService.isSignedIn()) {
        final scores = await GameServicesService.loadTopScores();
        if (scores != null && scores.isNotEmpty) {
          print('Top Player Data:');
          print('Name: ${scores[0].scoreHolder.displayName}');
          print('Avatar data length: ${scores[0].scoreHolder.iconImage?.length ?? 0}');
          print('Score: ${scores[0].rawScore}');
          print('Rank: ${scores[0].rank}');
          
          setState(() {
            topPlayerName = scores[0].scoreHolder.displayName;
            topPlayerAvatar = scores[0].scoreHolder.iconImage;
            topScore = scores[0].rawScore;
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      print('Error loading top player: $e');
    }
  }

  ImageProvider? _getAvatarImage() {
    if (topPlayerAvatar == null) return null;
    try {
      final data = base64.decode(topPlayerAvatar!);
      return MemoryImage(data);
    } catch (e) {
      print('Error decoding avatar image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 50,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (topPlayerName == null || topScore == null) {
      return const SizedBox.shrink();
    }

    final avatarImage = _getAvatarImage();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Champion:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 8),
          if (avatarImage != null) ...[
            CircleAvatar(
              backgroundImage: avatarImage,
              radius: 12,
              backgroundColor: Colors.transparent,
              onBackgroundImageError: (exception, stackTrace) {
                print('Error displaying avatar image:');
                print('Exception: $exception');
                print('Stack trace: $stackTrace');
              },
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              topPlayerName!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$topScore',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
