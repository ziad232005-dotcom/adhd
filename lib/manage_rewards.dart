import 'package:flutter/material.dart';
import 'child.dart';

const Color rewardPurple = Color(0xFF7566D9);
const Color rewardDarkPurple = Color(0xFF30285E);
const Color rewardBackground = Color(0xFFFAF8FF);

class ManageRewardsScreen extends StatefulWidget {
  const ManageRewardsScreen({super.key});

  @override
  State<ManageRewardsScreen> createState() =>
      _ManageRewardsScreenState();
}

class _ManageRewardsScreenState extends State<ManageRewardsScreen> {
  final ChildAppState data = ChildAppState.instance;

  @override
  void initState() {
    super.initState();
    data.addListener(_refresh);
  }

  @override
  void dispose() {
    data.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

Future<void> _openRewardForm({ChildReward? reward}) async {
  final result = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => RewardFormScreen(reward: reward),
    ),
  );

  if (result == true && mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          reward == null
              ? 'Reward added successfully!'
              : 'Reward updated successfully!',
        ),
        backgroundColor: rewardPurple,
      ),
    );
  }
}

  Future<void> _deleteReward(ChildReward reward) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete reward?'),
        content: Text(
          'Are you sure you want to delete "${reward.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      data.deleteReward(reward.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reward deleted')),
      );
    }
  }

  Future<void> _confirmResetPoints() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Reset child points?'),
        content: const Text(
          'This will set the current points to zero. '
          'Task history, focus sessions, and recorded reward '
          'achievements will be retained.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Reset Points'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await data.resetPoints();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Points reset successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rewards = [...data.rewards]
      ..sort((a, b) => a.targetPoints.compareTo(b.targetPoints));

    return Scaffold(
      backgroundColor: rewardBackground,
      appBar: AppBar(
        backgroundColor: rewardBackground,
        foregroundColor: rewardDarkPurple,
        elevation: 0,
        title: const Text(
          'Manage Rewards',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [rewardPurple, Color(0xFF998BEA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.card_giftcard_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Celebrate Every Achievement',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current child points: ${data.points}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${rewards.length} rewards configured',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _openRewardForm(),
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Add New Reward',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: rewardPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Rewards',
              style: TextStyle(
                color: rewardDarkPurple,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            if (rewards.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFECE7FA)),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.redeem_rounded,
                      size: 44,
                      color: rewardPurple,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'No rewards yet',
                      style: TextStyle(
                        color: rewardDarkPurple,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Add a reward and choose how many points '
                      'your child needs to earn it.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              )
            else
              for (final reward in rewards) ...[
                _rewardCard(reward),
                const SizedBox(height: 12),
              ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFECE7FA)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.restart_alt_rounded,
                        color: Colors.redAccent,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Points Management',
                          style: TextStyle(
                            color: rewardDarkPurple,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Reset the current points without deleting task '
                    'history or focus sessions.',
                    style: TextStyle(
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: data.points > 0
                          ? _confirmResetPoints
                          : null,
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('Reset Points'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rewardCard(ChildReward reward) {
    final achieved = data.hasAchievedReward(reward);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: achieved
              ? const Color(0xFFBDEBDD)
              : const Color(0xFFECE7FA),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: achieved
                  ? const Color(0xFFE2F8F0)
                  : const Color(0xFFF0EDFF),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              achieved
                  ? Icons.emoji_events_rounded
                  : Icons.card_giftcard_rounded,
              color: achieved
                  ? const Color(0xFF29A987)
                  : rewardPurple,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.title,
                  style: const TextStyle(
                    color: rewardDarkPurple,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reward.description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${reward.targetPoints} points required',
                  style: const TextStyle(
                    color: rewardPurple,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (achieved)
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      'Achievement recorded',
                      style: TextStyle(
                        color: Color(0xFF27966F),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _openRewardForm(reward: reward);
              } else if (value == 'delete') {
                _deleteReward(reward);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: Text('Edit'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class RewardFormScreen extends StatefulWidget {
  final ChildReward? reward;

  const RewardFormScreen({
    super.key,
    this.reward,
  });

  @override
  State<RewardFormScreen> createState() => _RewardFormScreenState();
}

class _RewardFormScreenState extends State<RewardFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _pointsController;

  final ChildAppState data = ChildAppState.instance;

  bool _isSaving = false;

  bool get _isEditing => widget.reward != null;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(
      text: widget.reward?.title ?? '',
    );

    _descriptionController = TextEditingController(
      text: widget.reward?.description ?? '',
    );

    _pointsController = TextEditingController(
      text: widget.reward?.targetPoints.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _saveReward() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final points = int.tryParse(_pointsController.text.trim());

    if (points == null || points <= 0) return;

    setState(() => _isSaving = true);

    try {
      if (_isEditing) {
        data.updateReward(
          id: widget.reward!.id,
          title: title,
          description: description,
          targetPoints: points,
        );
      } else {
        data.addReward(
          title: title,
          description: description,
          targetPoints: points,
        );
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSaving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: rewardBackground,

      appBar: AppBar(
        backgroundColor: rewardBackground,
        foregroundColor: rewardDarkPurple,
        elevation: 0,
        title: Text(
          _isEditing ? 'Edit Reward' : 'Add New Reward',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: rewardPurple,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.card_giftcard_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Create a Special Reward!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Motivate your child with rewards for reaching their goals.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Reward Name',
                  style: TextStyle(
                    color: rewardDarkPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _inputDecoration(
                    hint: 'e.g. New Toy',
                    icon: Icons.card_giftcard_rounded,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a reward name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                const Text(
                  'Description',
                  style: TextStyle(
                    color: rewardDarkPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _descriptionController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  decoration: _inputDecoration(
                    hint: 'Describe the reward...',
                    icon: Icons.notes_rounded,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                const Text(
                  'Required Points',
                  style: TextStyle(
                    color: rewardDarkPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _pointsController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration(
                    hint: 'e.g. 50',
                    icon: Icons.stars_rounded,
                  ),
                  validator: (value) {
                    final points = int.tryParse(value?.trim() ?? '');

                    if (points == null || points <= 0) {
                      return 'Enter a number greater than zero';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                const Text(
                  'Your child can unlock this reward after collecting the required points.',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveReward,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: rewardPurple,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: rewardPurple.withAlpha(120),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _isEditing ? 'Save Changes' : 'Create Reward',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: rewardPurple,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE5E0F5),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xFFE5E0F5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: rewardPurple,
          width: 1.5,
        ),
      ),
    );
  }
}