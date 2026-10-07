import 'package:flutter/material.dart';

import '../children/child.dart';
import '../children/children_repository.dart';
import 'add_competition_page.dart';
import 'competitions_repository.dart';

class CompetitionsPage extends StatelessWidget {
  final Child child;
  final ChildrenRepository childrenRepository;
  final CompetitionsRepository repository;

  const CompetitionsPage({
    super.key,
    required this.child,
    required this.childrenRepository,
    required this.repository,
  });

  Future<void> _add(BuildContext context) async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddCompetitionPage(
          child: child,
          childrenRepository: childrenRepository,
          repository: repository,
        ),
      ),
    );
    if (added == true && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Competition added')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Competitions')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Align(
          alignment: Alignment.topCenter,
          child: FilledButton.icon(
            onPressed: () => _add(context),
            icon: const Icon(Icons.add),
            label: const Text('Add competition'),
          ),
        ),
      ),
    );
  }
}
