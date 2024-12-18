import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:block_puzzle_game/providers/feedback_providers.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedbackManager = ref.watch(feedbackManagerProvider);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        title: Text(
          'about'.tr(),
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () async {
            await feedbackManager.playFeedback();
            if (!context.mounted) return;
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'legal'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                await feedbackManager.playFeedback();
                await _launchURL('https://www.app-architects.com/privacy-policy');
              },
              child: Text('privacy_policy'.tr()),
            ),
            TextButton(
              onPressed: () async {
                await feedbackManager.playFeedback();
                await _launchURL('https://www.app-architects.com/terms-of-use');
              },
              child: Text('terms_of_use'.tr()),
            ),
            const SizedBox(height: 32),
            Text(
              'attributions'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Game Engine:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: () async {
                await feedbackManager.playFeedback();
                await _launchURL('https://flutter.dev/');
              },
              child: const Text('• Flutter'),
            ),
            const SizedBox(height: 16),
            Text(
              'Assets:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Text('• GIFs - [https://gifer.com/]'),
            //const Text('• Sound Effects - [Source]'),
            const SizedBox(height: 16),
            Text(
              'Created By:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton(
              onPressed: () async {
                await feedbackManager.playFeedback();
                await _launchURL('https://www.app-architects.com/');
              },
              child: const Text('Todd @ App Architects'),
            ),
            const SizedBox(height: 16),
            Text(
              'Inspiration:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Text('• Aaron Busse')
          ],
        ),
      ),
    );
  }
}
