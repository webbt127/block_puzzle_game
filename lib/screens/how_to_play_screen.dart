import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/feedback_providers.dart';

class MultiplierTable extends StatelessWidget {
  final String title;
  final List<MapEntry<String, String>> entries;
  final Color color;

  const MultiplierTable({
    super.key,
    required this.title,
    required this.entries,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(2),
            },
            children: entries.map((entry) {
              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                    child: Text(entry.key),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 8, 12, 8),
                    child: Text(
                      entry.value,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class ExampleCard extends StatelessWidget {
  final String description;
  final String calculation;
  final Color color;

  const ExampleCard({
    super.key,
    required this.description,
    required this.calculation,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
          Text(
            calculation,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class HowToPlayScreen extends ConsumerWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<TutorialStep> steps = [
      TutorialStep(
        title: 'Place Blocks',
        description: 'Drag and drop blocks onto the grid. Try to fill rows and columns completely! Point are awarded for each block placed.',
        icon: Icons.drag_indicator,
        color: Colors.blue,
      ),
      TutorialStep(
        title: 'Clear Lines',
        description: 'When a row or column is completely filled, it will be cleared and you\'ll earn points.',
        icon: Icons.clear_all,
        color: Colors.green,
      ),
      TutorialStep(
        title: 'Score Multipliers',
        description: 'Your score is multiplied by both your consecutive clear streak AND the number of lines cleared in a single move!',
        extraWidgets: [
          const SizedBox(height: 16),
          MultiplierTable(
            title: 'Streak Multipliers',
            color: Colors.amber,
            entries: [
              MapEntry('First clear', '1.0x'),
              MapEntry('Second consecutive', '1.5x'),
              MapEntry('Third and beyond', '2.0x'),
            ],
          ),
          const SizedBox(height: 16),
          MultiplierTable(
            title: 'Lines Cleared Multipliers',
            color: Colors.amber,
            entries: [
              MapEntry('1 line', '1.0x'),
              MapEntry('2 lines', '4.0x (2²)'),
              MapEntry('3 lines', '9.0x (3²)'),
              MapEntry('4 lines', '16.0x (4²)'),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'The multipliers stack! Here are some examples:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          ExampleCard(
            description: 'Clear 2 lines on your third consecutive clear:',
            calculation: '2 lines × 100 points × (2.0x streak × 4.0x lines) = 1,600 points!',
            color: Colors.amber,
          ),
          const SizedBox(height: 8),
          ExampleCard(
            description: 'Clear 3 lines on your second consecutive clear:',
            calculation: '3 lines × 100 points × (1.5x streak × 9.0x lines) = 4,050 points!',
            color: Colors.amber,
          ),
          const SizedBox(height: 16),
          const Text(
            'The multiplier resets to 1.0x if you make a move without clearing any lines.',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
        icon: Icons.stars,
        color: Colors.amber,
      ),
      TutorialStep(
        title: 'Reroll Blocks',
        description: 'Stuck with difficult blocks? Use the reroll button to get new ones! You get 3 rerolls per game.',
        icon: Icons.refresh,
        color: Colors.purple,
      ),
      TutorialStep(
        title: 'Game Over',
        description: 'The game ends when you can\'t place any more blocks. Try to get the highest score possible!',
        icon: Icons.sports_score,
        color: Colors.red,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('How to Play'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(feedbackManagerProvider).playFeedback();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.background.withOpacity(0.8),
            ],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          itemCount: steps.length,
          itemBuilder: (context, index) {
            final step = steps[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: step.color.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        step.color.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: step.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                step.icon,
                                size: 32,
                                color: step.color,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                step.title,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: step.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (step.description.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            step.description,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.5,
                            ),
                          ),
                        ],
                        if (step.extraWidgets != null) ...step.extraWidgets!,
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class TutorialStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<Widget>? extraWidgets;

  const TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.extraWidgets,
  });
}
