import 'package:flutter/material.dart';

import 'parent_ui.dart';

class ParentAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ParentAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

/// "View all" page for the Quick Actions section.
class QuickActionsScreen extends StatelessWidget {
  final List<ParentAction> actions;

  const QuickActionsScreen({super.key, required this.actions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ParentUi.background,
      appBar: parentAppBar(context, 'Quick Actions'),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          itemCount: actions.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final action = actions[index];

            return ParentCard(
              onTap: action.onTap,
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: action.color,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(action.icon, color: ParentUi.purple),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          action.title,
                          style: const TextStyle(
                            color: ParentUi.dark,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          action.subtitle,
                          style: const TextStyle(
                            color: ParentUi.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: ParentUi.purple,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
