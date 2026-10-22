import 'package:flutter/material.dart';

class TrackBehaviorScreen extends StatefulWidget {
  const TrackBehaviorScreen({super.key});

  @override
  State<TrackBehaviorScreen> createState() =>
      _TrackBehaviorScreenState();
}

class _TrackBehaviorScreenState extends State<TrackBehaviorScreen> {
  final List<String> behaviors = [
    'Focused on a task',
    'Followed instructions',
    'Completed homework',
    'Had difficulty focusing',
  ];

  final Set<String> selectedBehaviors = {};

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF7566D9);
    const darkPurple = Color(0xFF30285E);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF8FF),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: darkPurple,
          ),
        ),
        title: const Text(
          'Track Behavior',
          style: TextStyle(
            color: darkPurple,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: purple,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.track_changes_rounded,
                  color: Colors.white,
                  size: 42,
                ),
                SizedBox(height: 14),
                Text(
                  "How was your child's day?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Select the behaviors you observed today.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Today's Observations",
            style: TextStyle(
              color: darkPurple,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...behaviors.map((behavior) {
            final selected = selectedBehaviors.contains(behavior);

            return Card(
              color: Colors.white,
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: selected
                      ? purple
                      : const Color(0xFFEFEAFB),
                ),
              ),
              child: CheckboxListTile(
                value: selected,
                activeColor: purple,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  behavior,
                  style: const TextStyle(
                    color: darkPurple,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      selectedBehaviors.add(behavior);
                    } else {
                      selectedBehaviors.remove(behavior);
                    }
                  });
                },
              ),
            );
          }),
          const SizedBox(height: 16),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: purple,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Selected ${selectedBehaviors.length} observations.',
                  ),
                ),
              );
            },
            child: const Text('Save Observations'),
          ),
        ],
      ),
    );
  }
}
