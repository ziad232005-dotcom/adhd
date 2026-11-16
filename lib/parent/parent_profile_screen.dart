import 'dart:io';

import 'package:flutter/material.dart';

import '../core/mazid_theme.dart';
import '../main.dart' show WelcomeScreen;
import 'add_child_screen.dart';
import 'child_detail_screen.dart';
import 'edit_parent_profile_screen.dart';
import 'notifications_screen.dart';
import 'parent_store.dart';
import 'parent_ui.dart';
import 'reminders_screen.dart';

/// Profile tab: parent details, children, shortcuts and sign out.
class ParentProfileScreen extends StatelessWidget {
  final List<Map<String, dynamic>> activities;

  const ParentProfileScreen({super.key, this.activities = const []});

  Future<void> _editProfile(BuildContext context) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const EditParentProfileScreen(),
      ),
    );

    if (saved == true && context.mounted) {
      showParentSnack(context, 'Profile updated');
    }
  }

  Widget _infoRow(IconData icon, String label, String value) {
    final empty = value.isEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: ParentUi.purple, size: 20),
          const SizedBox(width: 12),
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(color: ParentUi.muted, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              empty ? 'Not added' : value,
              style: TextStyle(
                color: empty ? ParentUi.muted : ParentUi.dark,
                fontWeight: empty ? FontWeight.w400 : FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You can sign in again at any time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Sign out',
              style: TextStyle(color: ParentUi.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  Widget _avatar(ParentChild child) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: ParentUi.soft,
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: child.imagePath != null
          ? Image.file(
              File(child.imagePath!),
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(
                Icons.face_rounded,
                color: ParentUi.purple,
              ),
            )
          : const Icon(Icons.face_rounded, color: ParentUi.purple),
    );
  }

  Widget _menuTile({
    required IconData icon,
    required String title,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return ParentCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: ParentUi.purple, size: 23),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: ParentUi.dark,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          if (trailing != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                trailing,
                style: const TextStyle(color: ParentUi.muted, fontSize: 12),
              ),
            ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 15,
            color: ParentUi.muted,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = ParentStore.instance;

    return Scaffold(
      backgroundColor: ParentUi.background,
      appBar: parentAppBar(context, 'Profile', showBack: false),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            final profile = store.profile;
            final displayName =
                profile.name.isEmpty ? 'Parent' : profile.name;
            final initial = displayName.characters.first.toUpperCase();
            final pendingReminders =
                store.reminders.where((r) => !r.done).length;

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
              children: [
                ParentCard(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 31,
                        backgroundColor: ParentUi.purple,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                color: ParentUi.dark,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (profile.email.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                profile.email,
                                style: const TextStyle(
                                  color: ParentUi.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            if (profile.phone.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                profile.phone,
                                style: const TextStyle(
                                  color: ParentUi.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Edit profile',
                        onPressed: () => _editProfile(context),
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: ParentUi.purple,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ParentCard(
                  child: Column(
                    children: [
                      _infoRow(
                        Icons.cake_outlined,
                        'Age',
                        profile.age == null ? '' : '${profile.age} years',
                      ),
                      _infoRow(Icons.wc_rounded, 'Gender', profile.gender),
                      _infoRow(
                        Icons.family_restroom_rounded,
                        'Relationship',
                        profile.relationship,
                      ),
                      _infoRow(
                        Icons.location_city_rounded,
                        'City',
                        profile.city,
                      ),
                      _infoRow(
                        Icons.home_outlined,
                        'Address',
                        profile.address,
                      ),
                      _infoRow(
                        Icons.contact_emergency_outlined,
                        'Emergency',
                        [profile.emergencyName, profile.emergencyPhone]
                            .where((e) => e.isNotEmpty)
                            .join(' • '),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'My children',
                        style: TextStyle(
                          color: ParentUi.dark,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddChildScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('Add child'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (store.children.isEmpty)
                  const ParentCard(
                    child: Text(
                      'No children added yet.',
                      style: TextStyle(color: ParentUi.muted, fontSize: 13),
                    ),
                  )
                else
                  for (final child in store.children)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ParentCard(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ChildDetailScreen(childId: child.id),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            _avatar(child),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    child.name,
                                    style: const TextStyle(
                                      color: ParentUi.dark,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${child.age} years old • ${child.grade}',
                                    style: const TextStyle(
                                      color: ParentUi.muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'Edit child',
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddChildScreen(child: child),
                                ),
                              ),
                              icon: const Icon(
                                Icons.edit_outlined,
                                size: 18,
                                color: ParentUi.purple,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                const SizedBox(height: 14),
                const Text(
                  'General',
                  style: TextStyle(
                    color: ParentUi.dark,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _menuTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          NotificationsScreen(activities: activities),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _menuTile(
                  icon: Icons.alarm_rounded,
                  title: 'Reminders',
                  trailing:
                      pendingReminders == 0 ? null : '$pendingReminders',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RemindersScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _menuTile(
                  icon: Icons.info_outline_rounded,
                  title: 'About ${MazidBrand.name}',
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: MazidBrand.name,
                    applicationLegalese: MazidBrand.tagline,
                  ),
                ),
                const SizedBox(height: 22),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ParentUi.red,
                    side: const BorderSide(color: ParentUi.red),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => _signOut(context),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign out'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
